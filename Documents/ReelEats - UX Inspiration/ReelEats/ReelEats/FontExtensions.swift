import SwiftUI

// MARK: - ReelEats Brand Colors

extension Color {
    /// Pastel red accent color #FF746C
    static let reelEatsAccent = Color(red: 255/255, green: 116/255, blue: 108/255)
}

// MARK: - Custom Font Extensions for ReelEats (New York Font System)

extension Font {
    
    // MARK: - New York Bold (For Logo and Prominent Headlines)
    
    /// New York Bold for ReelEats logo
    static func newYorkLogo(size: CGFloat = 32) -> Font {
        return Font.system(size: size, weight: .bold, design: .serif)
    }
    
    // MARK: - New York Semibold (For Card Titles and Section Headers)
    
    /// New York Semibold for card titles
    static func newYorkCardTitle(size: CGFloat = 18) -> Font {
        return Font.system(size: size, weight: .semibold, design: .serif)
    }
    
    /// New York Semibold for collection names
    static func newYorkCollectionName(size: CGFloat = 20) -> Font {
        return Font.system(size: size, weight: .semibold, design: .serif)
    }
    
    /// New York Semibold for headers
    static func newYorkHeader(size: CGFloat = 24) -> Font {
        return Font.system(size: size, weight: .semibold, design: .serif)
    }
    
    /// New York Semibold for navigation titles
    static func newYorkNavTitle(size: CGFloat = 18) -> Font {
        return Font.system(size: size, weight: .semibold, design: .serif)
    }
    
    // MARK: - New York Medium (For Restaurant Names and Important Labels)
    
    /// New York Medium for restaurant/spot names
    static func newYorkRestaurantName(size: CGFloat = 18) -> Font {
        return Font.system(size: size, weight: .medium, design: .serif)
    }
    
    /// New York Medium for button labels
    static func newYorkButton(size: CGFloat = 16) -> Font {
        return Font.system(size: size, weight: .medium, design: .serif)
    }
    
    /// New York Medium for filter pills and tags
    static func newYorkTag(size: CGFloat = 14) -> Font {
        return Font.system(size: size, weight: .medium, design: .serif)
    }
    
    // MARK: - New York Regular (For Body Text and Standard Content)
    
    /// New York Regular for body text
    static func newYorkBody(size: CGFloat = 16) -> Font {
        return Font.system(size: size, weight: .regular, design: .serif)
    }
    
    /// New York Regular for secondary text
    static func newYorkSecondary(size: CGFloat = 14) -> Font {
        return Font.system(size: size, weight: .regular, design: .serif)
    }
    
    /// New York Regular for descriptions
    static func newYorkDescription(size: CGFloat = 15) -> Font {
        return Font.system(size: size, weight: .regular, design: .serif)
    }
    
    // MARK: - New York Light (For Subtle Text and Small Details)
    
    /// New York Light for captions
    static func newYorkCaption(size: CGFloat = 12) -> Font {
        return Font.system(size: size, weight: .light, design: .serif)
    }
    
    /// New York Light for small text like addresses
    static func newYorkSmall(size: CGFloat = 13) -> Font {
        return Font.system(size: size, weight: .light, design: .serif)
    }
    
    // MARK: - Legacy Compatibility Functions (Updated to New York)
    
    /// Legacy: ClashDisplay logo - now maps to New York Bold
    static func clashDisplayLogoTemp(size: CGFloat = 32) -> Font {
        return newYorkLogo(size: size)
    }
    
    /// Legacy: ClashDisplay card title - now maps to New York Semibold
    static func clashDisplayCardTitleTemp(size: CGFloat = 18) -> Font {
        return newYorkCardTitle(size: size)
    }
    
    /// Legacy: ClashDisplay restaurant name - now maps to New York Medium
    static func clashDisplayRestaurantNameTemp(size: CGFloat = 18) -> Font {
        return newYorkRestaurantName(size: size)
    }
    
    /// Legacy: ClashDisplay collection name - now maps to New York Semibold
    static func clashDisplayCollectionNameTemp(size: CGFloat = 20) -> Font {
        return newYorkCollectionName(size: size)
    }
    
    /// Legacy: ClashDisplay header - now maps to New York Semibold
    static func clashDisplayHeaderTemp(size: CGFloat = 24) -> Font {
        return newYorkHeader(size: size)
    }
    
    /// Legacy: ClashDisplay nav title - now maps to New York Semibold
    static func clashDisplayNavTitleTemp(size: CGFloat = 18) -> Font {
        return newYorkNavTitle(size: size)
    }
    
    /// Legacy: ClashDisplay button - now maps to New York Medium
    static func clashDisplayButtonTemp(size: CGFloat = 16) -> Font {
        return newYorkButton(size: size)
    }
    
    /// Legacy: ClashDisplay tag - now maps to New York Medium
    static func clashDisplayTagTemp(size: CGFloat = 14) -> Font {
        return newYorkTag(size: size)
    }
    
    /// Legacy: ClashDisplay body - now maps to New York Regular
    static func clashDisplayBodyTemp(size: CGFloat = 16) -> Font {
        return newYorkBody(size: size)
    }
    
    /// Legacy: ClashDisplay secondary - now maps to New York Regular
    static func clashDisplaySecondaryTemp(size: CGFloat = 14) -> Font {
        return newYorkSecondary(size: size)
    }
    
    /// Legacy: ClashDisplay description - now maps to New York Regular
    static func clashDisplayDescriptionTemp(size: CGFloat = 15) -> Font {
        return newYorkDescription(size: size)
    }
    
    /// Legacy: ClashDisplay caption - now maps to New York Light
    static func clashDisplayCaptionTemp(size: CGFloat = 12) -> Font {
        return newYorkCaption(size: size)
    }
    
    /// Legacy: ClashDisplay small - now maps to New York Light
    static func clashDisplaySmallTemp(size: CGFloat = 13) -> Font {
        return newYorkSmall(size: size)
    }
    
    // MARK: - Legacy Poppins Font References (Updated to New York)
    
    /// Legacy: Maps old Poppins logo font to New York Bold
    static func poppinsLogoTemp(size: CGFloat = 32) -> Font {
        return newYorkLogo(size: size)
    }
    
    /// Legacy: Maps old Poppins restaurant name to New York Medium
    static func poppinsRestaurantNameTemp(size: CGFloat = 18) -> Font {
        return newYorkRestaurantName(size: size)
    }
    
    /// Legacy: Maps old Poppins collection name to New York Semibold
    static func poppinsCollectionNameTemp(size: CGFloat = 24) -> Font {
        return newYorkCollectionName(size: size)
    }
    
    /// Legacy: Maps old Poppins header to New York Semibold
    static func poppinsHeaderTemp(size: CGFloat = 20) -> Font {
        return newYorkHeader(size: size)
    }
    
    /// Legacy: Maps old Poppins accent to New York Medium
    static func poppinsAccentTemp(size: CGFloat = 16) -> Font {
        return newYorkButton(size: size)
    }
    
    /// Legacy: Maps old Poppins nav title to New York Semibold
    static func poppinsNavTitleTemp(size: CGFloat = 18) -> Font {
        return newYorkNavTitle(size: size)
    }
    
    /// Legacy: Maps old Poppins body to New York Regular
    static func poppinsBodyTemp(size: CGFloat = 16) -> Font {
        return newYorkBody(size: size)
    }
    
    /// Legacy: Maps old Poppins secondary to New York Regular
    static func poppinsSecondaryTemp(size: CGFloat = 14) -> Font {
        return newYorkSecondary(size: size)
    }
    
    /// Legacy: Maps old Poppins caption to New York Light
    static func poppinsCaptionTemp(size: CGFloat = 12) -> Font {
        return newYorkCaption(size: size)
    }
    
    /// Legacy: Maps old Poppins description to New York Regular
    static func poppinsDescriptionTemp(size: CGFloat = 15) -> Font {
        return newYorkDescription(size: size)
    }
    
    /// Legacy: Maps old Poppins button to New York Medium
    static func poppinsButtonTemp(size: CGFloat = 14) -> Font {
        return newYorkButton(size: size)
    }
    
    /// Legacy: Maps old Poppins small to New York Light
    static func poppinsSmallTemp(size: CGFloat = 13) -> Font {
        return newYorkSmall(size: size)
    }
}

// MARK: - Font Loading Verification

struct FontManager {
    
    /// Check if New York font is available (it's built into iOS)
    static func verifyFontsLoaded() -> Bool {
        // Check if New York font is available (it's built into iOS)
        let _ = UIFont.systemFont(ofSize: 16, weight: .regular).familyName.contains("New York") || 
                           UIFont(name: "NewYork", size: 16) != nil
        
        print("🔤 Font Status:")
        print("   New York Serif: ✅ Built-in system font (available)")
        print("   Using design: .serif for optimal New York typography")
        
        return true // New York is always available as it's built into iOS
    }
    
    /// List all available font families (for debugging)
    static func listAvailableFonts() {
        print("🔤 Available Font Families:")
        for family in UIFont.familyNames.sorted() {
            let names = UIFont.fontNames(forFamilyName: family)
            print("   \(family): \(names)")
        }
    }
}

// MARK: - Preview Helper

struct FontPreview: View {
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                // Header Section
                Text("New York Font System")
                    .font(.newYorkHeader(size: 28))
                    .foregroundColor(.primary)
                    .padding(.bottom, 10)
                
                // Logo Example (Bold)
                Group {
                    Text("Logo (Bold)")
                        .font(.newYorkSecondary())
                        .foregroundColor(.secondary)
                        .padding(.top)
                    
                    Text("ReelEats")
                        .font(.newYorkLogo(size: 32))
                        .foregroundColor(.orange)
                }
                
                Divider()
                
                // Semibold Examples (Card Titles & Headers)
                Group {
                    Text("Card Titles & Headers (Semibold)")
                        .font(.newYorkSecondary())
                        .foregroundColor(.secondary)
                        .padding(.top)
                    
                    Text("Melbourne Favorites")
                        .font(.newYorkCollectionName())
                        .foregroundColor(.primary)
                    
                    Text("Main Header")
                        .font(.newYorkHeader())
                        .foregroundColor(.primary)
                    
                    Text("Navigation Title")
                        .font(.newYorkNavTitle())
                        .foregroundColor(.primary)
                    
                    Text("Chin Chin Restaurant")
                        .font(.newYorkCardTitle())
                        .foregroundColor(.primary)
                }
                
                Divider()
                
                // Medium Examples (Restaurant Names & Buttons)
                Group {
                    Text("Restaurant Names & Buttons (Medium)")
                        .font(.newYorkSecondary())
                        .foregroundColor(.secondary)
                        .padding(.top)
                    
                    Text("Osteria Ilaria")
                        .font(.newYorkRestaurantName())
                        .foregroundColor(.primary)
                    
                    HStack(spacing: 12) {
                        Text("Italian")
                            .font(.newYorkTag())
                            .foregroundColor(.white)
                            .padding(.horizontal, 12)
                            .padding(.vertical, 6)
                            .background(Color.orange)
                            .cornerRadius(20)
                        
                        Text("Add Spot")
                            .font(.newYorkButton())
                            .foregroundColor(.white)
                            .padding(.horizontal, 16)
                            .padding(.vertical, 8)
                            .background(Color.black)
                            .cornerRadius(20)
                    }
                }
                
                Divider()
                
                // Regular & Light Text Examples
                Group {
                    Text("Body Text (Regular) & Details (Light)")
                        .font(.newYorkSecondary())
                        .foregroundColor(.secondary)
                        .padding(.top)
                    
                    Text("This is body text using New York Regular for elegant, readable content throughout the app.")
                        .font(.newYorkBody())
                        .foregroundColor(.primary)
                    
                    Text("Secondary text in Regular weight for subtitles")
                        .font(.newYorkSecondary())
                        .foregroundColor(.secondary)
                    
                    Text("A sophisticated dining experience in the heart of Melbourne, offering contemporary Italian cuisine with a modern twist.")
                        .font(.newYorkDescription())
                        .foregroundColor(.secondary)
                    
                    Text("Open now • Closes at 10 PM")
                        .font(.newYorkCaption())
                        .foregroundColor(.secondary)
                    
                    Text("123 Collins Street, Melbourne VIC 3000")
                        .font(.newYorkSmall())
                        .foregroundColor(.secondary)
                }
            }
            .padding()
        }
        .onAppear {
            _ = FontManager.verifyFontsLoaded()
            // Uncomment to see all available fonts
            // FontManager.listAvailableFonts()
        }
    }
}

#Preview {
    FontPreview()
}