# Clash Display Font Setup Instructions

## Steps to Install Clash Display Fonts in ReelEats

### 1. Download Clash Display Font Family
Download the following font files:
- ClashDisplay-Light.ttf (or .otf)
- ClashDisplay-Regular.ttf (or .otf)
- ClashDisplay-Semibold.ttf (or .otf)

You can get them from:
- The official type foundry
- Licensed font distributors
- Or any legitimate source where you have a license

### 2. Add Fonts to Xcode Project

1. Open your ReelEats project in Xcode
2. Create a new folder called "Fonts" in the ReelEats group (right-click on ReelEats folder → New Group → name it "Fonts")
3. Drag and drop all three font files into the Fonts folder
4. When prompted, make sure to:
   - ✅ Check "Copy items if needed"
   - ✅ Check "Add to targets: ReelEats"

### 3. Update Info.plist

Add the following to your Info.plist file:

```xml
<key>UIAppFonts</key>
<array>
    <string>ClashDisplay-Light.ttf</string>
    <string>ClashDisplay-Regular.ttf</string>
    <string>ClashDisplay-Semibold.ttf</string>
</array>
```

Note: Use .otf extension if you downloaded OTF files instead of TTF.

### 4. Verify Font Installation

1. Build and run the app
2. Check the console output for font loading status
3. You should see:
   ```
   🔤 Font Status:
      Clash Display Semibold: ✅ Loaded
      Clash Display Regular: ✅ Loaded
      Clash Display Light: ✅ Loaded
   ```

### 5. Font Usage Guide

The FontExtensions.swift file has been updated with the new Clash Display font system:

**For Logo (SemiBold):**
- `.clashDisplayLogo()` or `.clashDisplayLogoTemp()` (32pt default)

**For Headers (SemiBold):**
- `.clashDisplayHeader()` or `.clashDisplayHeaderTemp()` (24pt default)
- `.clashDisplayNavTitle()` or `.clashDisplayNavTitleTemp()` (18pt default)

**For Body Text (Regular):**
- `.clashDisplayRestaurantName()` or `.clashDisplayRestaurantNameTemp()` (18pt default)
- `.clashDisplayCollectionName()` or `.clashDisplayCollectionNameTemp()` (20pt default)
- `.clashDisplayBody()` or `.clashDisplayBodyTemp()` (16pt default)
- `.clashDisplaySecondary()` or `.clashDisplaySecondaryTemp()` (14pt default)
- `.clashDisplayButton()` or `.clashDisplayButtonTemp()` (16pt default)
- `.clashDisplayTag()` or `.clashDisplayTagTemp()` (14pt default)

**For Subtle Text (Light):**
- `.clashDisplayDescription()` or `.clashDisplayDescriptionTemp()` (15pt default)
- `.clashDisplayCaption()` or `.clashDisplayCaptionTemp()` (12pt default)
- `.clashDisplaySmall()` or `.clashDisplaySmallTemp()` (13pt default)

### 6. Current Status

The app is currently using system font fallbacks (the "Temp" versions) which will automatically switch to Clash Display once the fonts are installed. The existing Poppins font references have been mapped to the appropriate Clash Display variants for backward compatibility.

### 7. Testing

After installation, you can test the fonts by:
1. Running the app and checking various screens
2. Opening FontExtensions.swift and running the FontPreview in the SwiftUI preview
3. Checking that the ReelEats logo uses SemiBold variant
4. Verifying that all other text uses Regular or Light variants as appropriate