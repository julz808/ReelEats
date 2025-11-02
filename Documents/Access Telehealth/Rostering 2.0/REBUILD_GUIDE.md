# Complete Rebuild Guide - Access Telehealth Scheduling Automation

## 🚨 Purpose
This guide provides step-by-step instructions to completely rebuild the scheduling automation system from scratch if all code is lost. Written for data analysts and developers with basic Python knowledge.

## 📋 Prerequisites

### Required Access
1. **PostgreSQL Database**
   - Host: 35.189.18.41
   - Database: postgres
   - Username: julian_ou (or equivalent read-only user)
   - Password: Secure credential storage

2. **Google Cloud Platform**
   - Project with billing enabled
   - APIs enabled: Cloud Functions, Cloud Scheduler, Cloud Storage, Secret Manager

3. **GitHub Repository**
   - Write access to client's GitHub organization
   - Ability to create new repositories

4. **Local Development Environment**
   - Python 3.11+
   - Git
   - VS Code or similar IDE
   - DBeaver or pgAdmin for database exploration

## 🏗️ Step-by-Step Rebuild Process

### Phase 1: Data Discovery & Download (Day 1)

#### Step 1.1: Connect to Database
```bash
# Using psql
psql -h 35.189.18.41 -U julian_ou -d postgres

# Or use DBeaver with these settings:
Host: 35.189.18.41
Port: 5432
Database: postgres
Username: julian_ou
```

#### Step 1.2: Download Required Tables
Export these 9 tables as CSV files:

```sql
-- 1. Service Requests (Tickets)
COPY (SELECT * FROM service_requests 
      WHERE created_at >= CURRENT_DATE - INTERVAL '30 days')
TO '/tmp/service_requests.csv' WITH CSV HEADER;

-- 2. Triage Requests (Links tickets to types)
COPY (SELECT * FROM triage_requests LIMIT 10000)
TO '/tmp/triage_requests.csv' WITH CSV HEADER;

-- 3. Triage Request Types (Type definitions)
COPY (SELECT * FROM triage_request_types)
TO '/tmp/triage_request_types.csv' WITH CSV HEADER;

-- 4. Facilities (Aged care homes)
COPY (SELECT * FROM facilities)
TO '/tmp/facilities.csv' WITH CSV HEADER;

-- 5. Users (Practitioners)
COPY (SELECT * FROM users WHERE practitioner_type_id IS NOT NULL)
TO '/tmp/users.csv' WITH CSV HEADER;

-- 6. Practitioner Types
COPY (SELECT * FROM practitioner_types)
TO '/tmp/practitioner_types.csv' WITH CSV HEADER;

-- 7. Facility Practitioner Mappings
COPY (SELECT * FROM facility_practitioner)
TO '/tmp/facility_practitioner.csv' WITH CSV HEADER;

-- 8. Availabilities
COPY (SELECT * FROM availabilities 
      WHERE start_date >= CURRENT_DATE - INTERVAL '30 days')
TO '/tmp/availabilities.csv' WITH CSV HEADER;

-- 9. Rounds (Bookings)
COPY (SELECT * FROM rounds 
      WHERE start_at >= CURRENT_DATE - INTERVAL '30 days')
TO '/tmp/rounds.csv' WITH CSV HEADER;
```

#### Step 1.3: Get Mapping Files
Download these critical CSV files:
- `triage_type_mapping_cleaned.csv` (5-category system)
- `Clinician_home mapping.csv` (optional)
- Generate new mapping using triage usage analysis if needed

### Phase 2: Project Setup (Day 1)

#### Step 2.1: Create Project Structure
```bash
mkdir access-telehealth-rostering
cd access-telehealth-rostering

# Create directory structure
mkdir -p src/{config,database,extractors,transformers,excel,utils}
mkdir -p data/{mappings,cache,sample}
mkdir -p tests/{unit,integration,fixtures}
mkdir -p deployment
mkdir -p scripts
mkdir -p docs

# Initialize Python project
python3 -m venv venv
source venv/bin/activate  # On Windows: venv\Scripts\activate
```

#### Step 2.2: Install Dependencies
Create `requirements.txt`:
```txt
pandas==2.3.2
numpy==2.3.2
openpyxl==3.1.5
psycopg2-binary==2.9.10
python-dotenv==1.1.1
pytz==2025.2
xlsxwriter==3.2.0
google-cloud-storage==2.10.0
google-cloud-secret-manager==2.16.3
functions-framework==3.5.0
```

Install:
```bash
pip install -r requirements.txt
```

### Phase 3: Core Implementation (Day 2-3)

#### Step 3.1: Configuration Module
Create `src/config/settings.py`:
```python
import os
from dotenv import load_dotenv

load_dotenv()

# Database Configuration
DB_CONFIG = {
    'host': os.getenv('DB_HOST', '34.129.212.77'),
    'port': os.getenv('DB_PORT', '5432'),
    'database': os.getenv('DB_NAME', 'postgres'),
    'user': os.getenv('DB_USER'),
    'password': os.getenv('DB_PASSWORD'),
    'connect_timeout': 30
}

# Timezone
TIMEZONE = 'Australia/Sydney'

# Output Configuration
OUTPUT_BUCKET = os.getenv('OUTPUT_BUCKET', 'rostering-reports')
```

#### Step 3.2: Database Connection
Create `src/database/connection.py`:
```python
import psycopg2
from psycopg2 import pool
import time
from typing import Optional
import logging

logger = logging.getLogger(__name__)

class DatabaseConnection:
    def __init__(self, config: dict):
        self.config = config
        self.pool = None
        self._initialize_pool()
    
    def _initialize_pool(self):
        """Create connection pool with retry logic"""
        max_retries = 3
        for attempt in range(max_retries):
            try:
                self.pool = psycopg2.pool.SimpleConnectionPool(
                    1, 20,  # min and max connections
                    **self.config
                )
                logger.info("Database connection pool created")
                return
            except Exception as e:
                if attempt < max_retries - 1:
                    time.sleep(2 ** attempt)  # Exponential backoff
                else:
                    raise e
    
    def execute_query(self, query: str, params: tuple = None):
        """Execute query and return results"""
        conn = self.pool.getconn()
        try:
            with conn.cursor() as cursor:
                cursor.execute(query, params)
                return cursor.fetchall()
        finally:
            self.pool.putconn(conn)
```

#### Step 3.3: Data Extractors
Create `src/extractors/ticket_extractor.py`:
```python
import pandas as pd
from datetime import datetime, timedelta
import pytz

class TicketExtractor:
    def __init__(self, db_connection):
        self.db = db_connection
        self.tz = pytz.timezone('Australia/Sydney')
    
    def extract_tickets_for_date_range(self, base_date: datetime):
        """Extract tickets for 7-day window to cover all requirements"""
        
        # Calculate 7-day date range (base_date ± 3 days + buffer)
        start_date = base_date - timedelta(days=3)
        end_date = base_date + timedelta(days=4)
        
        query = """
        SELECT 
            sr.id,
            sr.status,
            sr.facility_id,
            sr.schedule_at,
            sr.practitioner_type_id,
            tr.triage_request_type_id,
            trt.name as triage_type_name,
            f.name as facility_name
        FROM service_requests sr
        LEFT JOIN triage_requests tr ON sr.id = tr.service_request_id
        LEFT JOIN triage_request_types trt ON tr.triage_request_type_id = trt.id
        LEFT JOIN facilities f ON sr.facility_id = f.id
        WHERE sr.status IN ('Open', 'Allocated')
        AND (sr.schedule_at IS NULL 
             OR DATE(sr.schedule_at) BETWEEN %s AND %s)
        """
        
        results = self.db.execute_query(
            query, 
            (start_date.date(), end_date.date())
        )
        
        df = pd.DataFrame(results, columns=[
            'ticket_id', 'status', 'facility_id', 'schedule_at',
            'practitioner_type_id', 'triage_request_type_id',
            'triage_type_name', 'facility_name'
        ])
        
        return df
```

#### Step 3.4: Ticket Classification
Create `src/transformers/ticket_classifier.py`:
```python
import pandas as pd

class TicketClassifier:
    def __init__(self, preference_mapping_path: str):
        self.preference_df = pd.read_csv(preference_mapping_path)
        self._prepare_mapping()
    
    def _prepare_mapping(self):
        """Process preference mapping"""
        # Group by triage type and collect all practitioner types
        self.type_mapping = self.preference_df.groupby('Triage type name')['Name (Practitioner Types1)'].apply(
            lambda x: list(set(x))  # Remove duplicates
        ).to_dict()
    
    def classify_ticket(self, triage_id: int, triage_name: str) -> str:
        """
        Classify ticket into 5-category system using ID-based mapping
        
        Returns:
        - "GP Only" (6 triage types)
        - "GP & GPTH Only" (15 triage types) 
        - "Geri Only" (10 triage types)
        - "Geri & Spec Only" (4 triage types)
        - "Other" (79 triage types - all clinician types can handle)
        - "Unclassified" (35 triage types)
        """
        # Load mapping from triage_type_mapping_cleaned.csv
        mapping_df = pd.read_csv('data/triage_type_mapping_cleaned.csv')
        
        # Try ID-based lookup first (most accurate)
        id_match = mapping_df[mapping_df['id'] == triage_id]
        if not id_match.empty and id_match.iloc[0]['Include? Y/N'] == 'Y':
            return id_match.iloc[0]['Classification']
        
        # Fallback to name-based lookup
        name_match = mapping_df[mapping_df['Triage Type Name'].str.lower() == triage_name.lower()]
        if not name_match.empty and name_match.iloc[0]['Include? Y/N'] == 'Y':
            return name_match.iloc[0]['Classification']
        
        return "Unclassified"
```

#### Step 3.5: Excel Generator with Dynamic Date Picker
Create `src/excel/generator.py`:
```python
import pandas as pd
from openpyxl import Workbook
from openpyxl.utils.dataframe import dataframe_to_rows
from openpyxl.worksheet.datavalidation import DataValidation
from openpyxl.styles import Font, PatternFill, Alignment
from datetime import datetime, timedelta

class ExcelGenerator:
    def __init__(self):
        self.wb = Workbook()
        
    def create_dynamic_excel(self, nurse_data: pd.DataFrame, 
                           doctor_data: pd.DataFrame,
                           output_path: str):
        """Generate Excel with dynamic date picker"""
        
        # Remove default sheet
        self.wb.remove(self.wb.active)
        
        # Create sheets
        ws_nurse = self.wb.create_sheet("Tickets and Nurses")
        ws_doctor = self.wb.create_sheet("Tickets and Doctors")
        
        # Add date picker to both sheets
        self._add_date_picker(ws_nurse)
        self._add_date_picker(ws_doctor)
        
        # Add data with formulas
        self._add_nurse_data(ws_nurse, nurse_data)
        self._add_doctor_data(ws_doctor, doctor_data)
        
        # Apply formatting
        self._format_sheets()
        
        # Save
        self.wb.save(output_path)
    
    def _add_date_picker(self, ws):
        """Add date dropdown to sheet"""
        # Add dropdown in A1
        ws['A1'] = "Select Date:"
        ws['B1'] = "Today"  # Default value
        
        # Create data validation
        dv = DataValidation(
            type="list",
            formula1='"Yesterday,Today,Tomorrow"',
            allow_blank=False
        )
        dv.add('B1')
        ws.add_data_validation(dv)
        
        # Add formula for actual date
        ws['A2'] = "Selected Date:"
        ws['B2'] = '=TODAY()+MATCH(B1,{"Yesterday","Today","Tomorrow"},0)-2'
        
        # Format
        ws['A1'].font = Font(bold=True)
        ws['B1'].fill = PatternFill(start_color="FFE4B5", 
                                    end_color="FFE4B5", 
                                    fill_type="solid")
    
    def _add_nurse_data(self, ws, data):
        """Add nurse schedule data with dynamic formulas"""
        
        # 5-Category Headers starting from row 4
        headers = [
            "Home Name", "GP Only", "GP & GPTH Only", "Geri Only", 
            "Geri & Spec Only", "Other", "Unclassified", "Total Tickets",
            "Total GP hours (next 3 days)", "Total Geri hours (next 3 days)",
            "Total General Phy hours (next 3 days)", "Total Nurse Prac hours (next 3 days)"
            # Add nurse-specific columns dynamically
        ]
        
        for col, header in enumerate(headers, 1):
            ws.cell(row=4, column=col, value=header)
            ws.cell(row=4, column=col).font = Font(bold=True)
            ws.cell(row=4, column=col).fill = PatternFill(
                start_color="4472C4", end_color="4472C4", fill_type="solid"
            )
        
        # Add data with formulas
        for row_idx, (facility, facility_data) in enumerate(data.groupby('facility_name'), 5):
            ws.cell(row=row_idx, column=1, value=facility)
            
            # 5-Category COUNTIFS formulas with business day filtering
            ws.cell(row=row_idx, column=2, 
                   value=f'=COUNTIFS(TicketData!B:B,$B$2,TicketData!C:C,A{row_idx},TicketData!D:D,"GP Only")')
            ws.cell(row=row_idx, column=3,
                   value=f'=COUNTIFS(TicketData!B:B,$B$2,TicketData!C:C,A{row_idx},TicketData!D:D,"GP & GPTH Only")')
            ws.cell(row=row_idx, column=4,
                   value=f'=COUNTIFS(TicketData!B:B,$B$2,TicketData!C:C,A{row_idx},TicketData!D:D,"Geri Only")')
            ws.cell(row=row_idx, column=5,
                   value=f'=COUNTIFS(TicketData!B:B,$B$2,TicketData!C:C,A{row_idx},TicketData!D:D,"Geri & Spec Only")')
            ws.cell(row=row_idx, column=6,
                   value=f'=COUNTIFS(TicketData!B:B,$B$2,TicketData!C:C,A{row_idx},TicketData!D:D,"Other")')
            ws.cell(row=row_idx, column=7,
                   value=f'=COUNTIFS(TicketData!B:B,$B$2,TicketData!C:C,A{row_idx},TicketData!D:D,"Unclassified")')
            ws.cell(row=row_idx, column=8,
                   value=f'=SUM(B{row_idx}:G{row_idx})')  # Total Tickets
```

### Phase 4: Cloud Function Deployment (Day 4)

#### Step 4.1: Create Cloud Function Entry Point
Create `deployment/main.py`:
```python
import functions_framework
from datetime import datetime
import pytz
import logging
from src.main import generate_daily_report

logging.basicConfig(level=logging.INFO)
logger = logging.getLogger(__name__)

@functions_framework.http
def rostering_report(request):
    """Cloud Function entry point"""
    try:
        # Get current time in AEST
        tz = pytz.timezone('Australia/Sydney')
        current_time = datetime.now(tz)
        
        logger.info(f"Starting report generation at {current_time}")
        
        # Generate report
        output_path = generate_daily_report(current_time)
        
        logger.info(f"Report generated: {output_path}")
        
        return {'status': 'success', 'file': output_path}, 200
        
    except Exception as e:
        logger.error(f"Error generating report: {str(e)}")
        return {'status': 'error', 'message': str(e)}, 500
```

#### Step 4.2: Deploy to GCP
```bash
# Set up GCP project
gcloud config set project YOUR_PROJECT_ID

# Create secrets
echo -n "julian_ou" | gcloud secrets create db-user --data-file=-
echo -n "YOUR_PASSWORD" | gcloud secrets create db-password --data-file=-

# Deploy function
gcloud functions deploy rostering-report \
    --runtime python311 \
    --trigger-http \
    --allow-unauthenticated \
    --memory 2GB \
    --timeout 540s \
    --set-env-vars DB_HOST=34.129.212.77,DB_NAME=postgres \
    --set-secrets 'DB_USER=db-user:latest,DB_PASSWORD=db-password:latest'

# Create Cloud Scheduler job
gcloud scheduler jobs create http daily-rostering-report \
    --schedule="0 5 * * *" \
    --uri="https://REGION-PROJECT.cloudfunctions.net/rostering-report" \
    --http-method=POST \
    --time-zone="Australia/Sydney"
```

### Phase 5: Testing & Validation (Day 5)

#### Step 5.1: Local Testing
```python
# Create test script
python scripts/test_local.py

# Test with sample data
python -m pytest tests/

# Validate Excel output
python scripts/validate_output.py
```

#### Step 5.2: Production Testing
```bash
# Test Cloud Function
curl https://REGION-PROJECT.cloudfunctions.net/rostering-report

# Check logs
gcloud functions logs read rostering-report

# Download and verify output
gsutil cp gs://rostering-reports/latest.xlsx ./test_output.xlsx
```

## 🔧 Troubleshooting Guide

### Common Issues

#### 1. Database Connection Fails
```python
# Check network connectivity
ping 34.129.212.77

# Test with psql
psql -h 34.129.212.77 -U julian_ou -d postgres -c "SELECT 1"

# Verify credentials
echo $DB_PASSWORD
```

#### 2. Missing Data in Output
```sql
-- Check data exists
SELECT COUNT(*) FROM service_requests WHERE status IN ('Open', 'Allocated');
SELECT COUNT(*) FROM triage_requests;
SELECT COUNT(*) FROM rounds WHERE start_at >= CURRENT_DATE;
```

#### 3. Excel Formula Errors
- Ensure date formats are consistent (DD/MM/YYYY)
- Check timezone conversions
- Verify data validation ranges

#### 4. Cloud Function Timeout
- Optimize database queries (add indexes)
- Increase function timeout (max 540s)
- Consider splitting into multiple functions

## 📅 Data Query Window Requirements

### PostgreSQL Query Strategy for 5 AM Daily Run

When the system runs at 5 AM AEST each morning, it needs to pull the following data windows:

#### **Service Requests (Tickets)**
```sql
-- Pull all Open/Allocated tickets, apply business day filtering in Python
WHERE sr.status IN ('Open', 'Allocated')
-- No date filtering in SQL - business day logic applied after extraction
```
**Business Day Filtering Logic (applied in Python)**:
- **Monday/Tuesday/Wednesday**: Include today + 2 calendar days
- **Thursday/Friday**: Include today + 4 calendar days (includes weekend + 2 business days)
- **Saturday**: Include today + 3 calendar days  
- **Sunday**: Include today + 2 calendar days
- **All tickets with NULL scheduled_at**: Always included
**Reasoning**: Provides 2 business days forward visibility regardless of weekends

#### **Rounds (Bookings/Rostering)**
```sql 
-- Pull 7 days of rounds data
WHERE DATE(start_at) BETWEEN CURRENT_DATE - 3 AND CURRENT_DATE + 4
```
**Reasoning**: 
- Shows "working today" status for yesterday/today/tomorrow
- Provides "last roster hour complete" (day-1 data)
- Calculates rostered hours for selected day

#### **Availabilities (Staff Schedules)**
```sql
-- Pull extended availability window for business day calculations
WHERE (end_date IS NULL OR end_date >= CURRENT_DATE - 1)
AND start_date <= CURRENT_DATE + 7
```
**Reasoning**: 
- Need future 7 days to calculate "next 3 business days" 
- Recurring schedules may span longer periods
- Include ongoing availabilities (null end dates)

#### **Lookup Tables (Facilities, Users, Practitioner Types)**
```sql
-- Always pull all active records (no date filtering)
WHERE is_deactivated = FALSE OR is_deactivated IS NULL
```
**Reasoning**: 
- Small tables, no performance impact
- Need complete mappings for data integrity

### **Total Query Window: 7 Days**
- **Start**: CURRENT_DATE - 3 days  
- **End**: CURRENT_DATE + 4 days (or +7 for availability calculations)

### **Performance Impact**
- **Tickets**: ~700K total, ~15K per week (manageable)
- **Rounds**: ~45K total, ~2K per week (fast)
- **Availability**: ~35K total records (static, fast)
- **Expected query time**: < 30 seconds total

### **Alternative Approaches Considered**
1. **3-day window only**: Risk missing edge cases with timezone/scheduling
2. **30-day window**: Unnecessary data volume, slower queries
3. **Dynamic window**: Too complex, harder to optimize

**Conclusion**: 7-day window provides optimal balance of completeness and performance.

## 📊 Data Validation Checklist

### Pre-Deployment
- [ ] All 9 tables accessible
- [ ] Mapping files present and cleaned
- [ ] Test with 1 week of data
- [ ] Excel opens without errors
- [ ] Date picker works correctly
- [ ] All formulas calculate

### Post-Deployment
- [ ] Daily execution at 5 AM AEST
- [ ] File uploaded to Cloud Storage
- [ ] Email notifications sent
- [ ] Scheduling team can access
- [ ] Data matches expectations

## 🔑 Key Business Rules

### Ticket Classification (5-Category System)
```
1. GP Only (6 triage types):
   - Only GPs can handle these tickets
   - Examples: Ear Syringe Only, Immunisations, RMMR Sign Off
   
2. GP & GPTH Only (15 triage types):
   - GPs and GP Telehealth can handle
   - Examples: Advance Care Directive, EPC, External Referral Needed
   
3. Geri Only (10 triage types):
   - Only Geriatricians can handle
   - Examples: Assessment of Cognition, Falls and Bone Health, Mood/Depression
   
4. Geri & Spec Only (4 triage types):
   - Geriatricians and Specialists can handle
   - Examples: Palliative Needs Assessment (1) and (2)
   
5. Other (79 triage types):
   - All clinician types can handle these tickets
   - Examples: S8 medication, Pain Management, Blood Pressure Review
   
6. Unclassified (35 triage types):
   - No classification assigned or Include? = 'N'
   - Includes inactive/deprecated triage types
```

### Working Status
```
Nurse Working Today = 
    EXISTS (rounds WHERE nurse_id = X AND date = selected_date)
```

### Rostered Hours Calculation
```
Hours = SUM(end_at - start_at) for all rounds in date range
Convert to decimal hours (e.g., 1.5 hours)
```

### Business Days
```python
def get_next_business_days(start_date, count=3):
    days = []
    current = start_date
    while len(days) < count:
        current += timedelta(days=1)
        if current.weekday() < 5:  # Monday = 0, Friday = 4
            days.append(current)
    return days
```

## 🚀 Quick Start Commands

```bash
# Clone and setup
git clone [repo-url]
cd access-telehealth-rostering
python3 -m venv venv
source venv/bin/activate
pip install -r requirements.txt

# Configure
cp .env.example .env
# Edit .env with database credentials

# Test locally
python src/main.py

# Deploy
./scripts/deploy.sh

# Monitor
gcloud functions logs read rostering-report --limit 50
```

## 📞 Support Contacts

- **Database Issues**: IT Support Team
- **GCP Access**: Cloud Platform Team
- **Business Logic**: Scheduling Team Lead
- **Code Issues**: Development Team

## 📝 Final Notes

This system is critical for daily operations. Always:
1. Test changes in development first
2. Keep backups of mapping files
3. Monitor daily executions
4. Document any modifications
5. Notify scheduling team of any delays

Last Updated: 2025-09-05
Current System: 5-Category Classification + Australian Date Formatting + Business Day Filtering