import SwiftUI

// MARK: - Custom Font Extensions for ReelEats (Poppins Font System)

extension Font {
    
    // MARK: - Poppins Bold (For Logos, Headers, Accents, Important Text)
    
    /// Poppins Bold for ReelEats logo
    static func poppinsLogo(size: CGFloat = 32) -> Font {
        return Font.custom("Poppins-Bold", size: size)
    }
    
    /// Poppins Bold for restaurant names
    static func poppinsRestaurantName(size: CGFloat = 18) -> Font {
        return Font.custom("Poppins-Bold", size: size)
    }
    
    /// Poppins Bold for collection names
    static func poppinsCollectionName(size: CGFloat = 24) -> Font {
        return Font.custom("Poppins-Bold", size: size)
    }
    
    /// Poppins Bold for section headers
    static func poppinsHeader(size: CGFloat = 20) -> Font {
        return Font.custom("Poppins-Bold", size: size)
    }
    
    /// Poppins Bold for button labels and accents
    static func poppinsAccent(size: CGFloat = 16) -> Font {
        return Font.custom("Poppins-Bold", size: size)
    }
    
    /// Poppins Bold for navigation titles
    static func poppinsNavTitle(size: CGFloat = 18) -> Font {
        return Font.custom("Poppins-Bold", size: size)
    }
    
    // MARK: - Poppins Regular (For Body Text, Secondary Text, Descriptions)
    
    /// Poppins Regular for body text
    static func poppinsBody(size: CGFloat = 16) -> Font {
        return Font.custom("Poppins-Regular", size: size)
    }
    
    /// Poppins Regular for secondary/subtitle text
    static func poppinsSecondary(size: CGFloat = 14) -> Font {
        return Font.custom("Poppins-Regular", size: size)
    }
    
    /// Poppins Regular for captions
    static func poppinsCaption(size: CGFloat = 12) -> Font {
        return Font.custom("Poppins-Regular", size: size)
    }
    
    /// Poppins Regular for descriptions
    static func poppinsDescription(size: CGFloat = 15) -> Font {
        return Font.custom("Poppins-Regular", size: size)
    }
    
    /// Poppins Regular for button text (secondary buttons)
    static func poppinsButton(size: CGFloat = 14) -> Font {
        return Font.custom("Poppins-Regular", size: size)
    }
    
    /// Poppins Regular for small text like addresses
    static func poppinsSmall(size: CGFloat = 13) -> Font {
        return Font.custom("Poppins-Regular", size: size)
    }
    
    // MARK: - Fallback System Fonts (in case custom fonts fail to load)
    
    /// Fallback for Poppins Bold fonts using system font
    static func systemPoppinsBold(size: CGFloat) -> Font {
        return Font.system(size: size, weight: .bold, design: .default)
    }
    
    /// Fallback for Poppins Regular fonts using system font
    static func systemPoppinsRegular(size: CGFloat) -> Font {
        return Font.system(size: size, weight: .regular, design: .default)
    }
    
    // MARK: - Temporary System Font Implementation (until Poppins fonts are added)
    
    /// Poppins Bold logo with system font fallback (using Avenir Next)
    static func poppinsLogoTemp(size: CGFloat = 32) -> Font {
        return Font.custom("AvenirNext-Bold", size: size)
    }
    
    /// Poppins Bold restaurant name with system font fallback (using Avenir Next)
    static func poppinsRestaurantNameTemp(size: CGFloat = 18) -> Font {
        return Font.custom("AvenirNext-DemiBold", size: size)
    }
    
    /// Poppins Bold collection name with system font fallback (using Avenir Next)
    static func poppinsCollectionNameTemp(size: CGFloat = 24) -> Font {
        return Font.custom("AvenirNext-Bold", size: size)
    }
    
    /// Poppins Bold header with system font fallback (using Avenir Next)
    static func poppinsHeaderTemp(size: CGFloat = 20) -> Font {
        return Font.custom("AvenirNext-DemiBold", size: size)
    }
    
    /// Poppins Bold accent with system font fallback (using Avenir Next)
    static func poppinsAccentTemp(size: CGFloat = 16) -> Font {
        return Font.custom("AvenirNext-DemiBold", size: size)
    }
    
    /// Poppins Bold nav title with system font fallback (using Avenir Next)
    static func poppinsNavTitleTemp(size: CGFloat = 18) -> Font {
        return Font.custom("AvenirNext-DemiBold", size: size)
    }
    
    /// Poppins Regular body with system font fallback (using Avenir Next)
    static func poppinsBodyTemp(size: CGFloat = 16) -> Font {
        return Font.custom("AvenirNext-Regular", size: size)
    }
    
    /// Poppins Regular secondary with system font fallback (using Avenir Next)
    static func poppinsSecondaryTemp(size: CGFloat = 14) -> Font {
        return Font.custom("AvenirNext-Regular", size: size)
    }
    
    /// Poppins Regular caption with system font fallback (using Avenir Next)
    static func poppinsCaptionTemp(size: CGFloat = 12) -> Font {
        return Font.custom("AvenirNext-Regular", size: size)
    }
    
    /// Poppins Regular description with system font fallback (using Avenir Next)
    static func poppinsDescriptionTemp(size: CGFloat = 15) -> Font {
        return Font.custom("AvenirNext-Regular", size: size)
    }
    
    /// Poppins Regular button with system font fallback (using Avenir Next)
    static func poppinsButtonTemp(size: CGFloat = 14) -> Font {
        return Font.custom("AvenirNext-Regular", size: size)
    }
    
    /// Poppins Regular small with system font fallback (using Avenir Next)
    static func poppinsSmallTemp(size: CGFloat = 13) -> Font {
        return Font.custom("AvenirNext-Regular", size: size)
    }
}

// MARK: - Font Loading Verification

struct FontManager {
    
    /// Check if custom fonts are properly loaded
    static func verifyFontsLoaded() -> Bool {
        let poppinsBoldLoaded = UIFont(name: "Poppins-Bold", size: 16) != nil
        let poppinsRegularLoaded = UIFont(name: "Poppins-Regular", size: 16) != nil
        
        print("🔤 Font Status:")
        print("   Poppins Bold: \(poppinsBoldLoaded ? "✅ Loaded" : "❌ Failed to load")")
        print("   Poppins Regular: \(poppinsRegularLoaded ? "✅ Loaded" : "❌ Failed to load")")
        
        return poppinsBoldLoaded && poppinsRegularLoaded
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
            VStack(alignment: .leading, spacing: 16) {
                Group {
                    Text("ReelEats")
                        .font(.poppinsLogo(size: 32))
                        .foregroundColor(.primary)
                    
                    Text("Restaurant Name")
                        .font(.poppinsRestaurantName())
                        .foregroundColor(.primary)
                    
                    Text("Collection Title")
                        .font(.poppinsCollectionName())
                        .foregroundColor(.primary)
                    
                    Text("Section Header")
                        .font(.poppinsHeader())
                        .foregroundColor(.primary)
                    
                    Text("Button Label")
                        .font(.poppinsAccent())
                        .foregroundColor(.primary)
                }
                
                Divider()
                
                Group {
                    Text("This is body text that should use Poppins Regular font for easy reading and excellent legibility.")
                        .font(.poppinsBody())
                        .foregroundColor(.primary)
                    
                    Text("Secondary text using Poppins Regular")
                        .font(.poppinsSecondary())
                        .foregroundColor(.secondary)
                    
                    Text("Small caption text")
                        .font(.poppinsCaption())
                        .foregroundColor(.secondary)
                    
                    Text("Restaurant description text that provides details about the venue, cuisine, and atmosphere.")
                        .font(.poppinsDescription())
                        .foregroundColor(.secondary)
                    
                    Text("123 Sample Street, Melbourne VIC")
                        .font(.poppinsSmall())
                        .foregroundColor(.secondary)
                }
            }
            .padding()
        }
        .onAppear {
            _ = FontManager.verifyFontsLoaded()
        }
    }
}

#Preview {
    FontPreview()
}