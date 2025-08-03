import SwiftUI
import Foundation

// MARK: - Post-Onboarding Tutorial Flow (4 Screens + App Integration)

struct PostOnboardingTutorialCoordinator: View {
    @EnvironmentObject var store: RestaurantStore
    @State private var currentScreen = 0
    @State private var isTransitioning = false
    
    var body: some View {
        ZStack {
            switch currentScreen {
            case 0:
                TutorialScreen1(onNext: { moveToNext() })
            case 1:
                TutorialScreen2(onNext: { moveToNext() })
            case 2:
                TutorialScreen3(onNext: { moveToNext() })
            case 3:
                TutorialScreen4(onNext: { moveToNext() })
            case 4:
                AppIntegrationSetupScreen(onNext: { moveToNext() })
            default:
                MainTabView()
                    .onAppear {
                        store.completeSetup()
                    }
            }
            
            // Skip button - appears on all tutorial screens (not MainTabView)
            if currentScreen < 5 {
                VStack {
                    HStack {
                        Spacer()
                        Button("Skip") {
                            store.completeSetup()
                        }
                        .font(.system(size: 16, weight: .medium))
                        .foregroundColor(.gray)
                        .padding(.top, 60)
                        .padding(.trailing, 20)
                    }
                    Spacer()
                }
            }
        }
        .opacity(isTransitioning ? 0.0 : 1.0)
        .animation(.easeInOut(duration: 0.4), value: isTransitioning)
    }
    
    private func moveToNext() {
        withAnimation(.easeInOut(duration: 0.4)) {
            isTransitioning = true
        }
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.4) {
            currentScreen += 1
            withAnimation(.easeInOut(duration: 0.4)) {
                isTransitioning = false
            }
        }
    }
}

// MARK: - Tutorial Screen 1: "A simple way to save and share your favourite food spots"

struct TutorialScreen1: View {
    let onNext: () -> Void
    @State private var isAnimating = false
    @State private var blobAnimating = false
    @State private var hasLogoutButton = true
    
    var body: some View {
        GeometryReader { geometry in
            ZStack {
                // Gradient background matching screenshot
                LinearGradient(
                    colors: [
                        Color.pink.opacity(0.1),
                        Color.purple.opacity(0.05),
                        Color(.systemBackground)
                    ],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
                .ignoresSafeArea()
                
                VStack(spacing: 0) {
                    // Top area with logout button
                    HStack {
                        if hasLogoutButton {
                            Button("logout") {
                                // Handle logout
                            }
                            .font(.system(size: 16))
                            .foregroundColor(.secondary)
                            .opacity(isAnimating ? 1.0 : 0.0)
                            .animation(.easeOut(duration: 0.6).delay(0.2), value: isAnimating)
                        }
                        
                        Spacer()
                    }
                    .padding(.horizontal, 28)
                    .padding(.top, 20)
                    
                    Spacer()
                        .frame(height: geometry.size.height * 0.08)
                    
                    // Animated gradient blobs content area
                    AnimatedGradientBlobs(isAnimating: blobAnimating)
                        .frame(height: geometry.size.height * 0.35)
                    
                    Spacer()
                        .frame(height: 60)
                    
                    // Title text
                    Text("A simple way to save and share your favourite food spots")
                        .font(.system(size: 36, weight: .bold))
                        .foregroundColor(.primary)
                        .multilineTextAlignment(.center)
                        .lineSpacing(4)
                        .padding(.horizontal, 32)
                        .opacity(isAnimating ? 1.0 : 0.0)
                        .offset(y: isAnimating ? 0 : 30)
                        .animation(.spring(response: 0.8, dampingFraction: 0.8).delay(0.5), value: isAnimating)
                    
                    Spacer()
                    
                    // How it works button
                    TutorialButton(
                        title: "How it works",
                        action: onNext,
                        isVisible: isAnimating
                    )
                    .animation(.spring(response: 0.8, dampingFraction: 0.8).delay(0.7), value: isAnimating)
                    
                    Spacer()
                        .frame(height: geometry.safeAreaInsets.bottom + 50)
                }
            }
        }
        .onAppear {
            withAnimation {
                isAnimating = true
            }
            
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                withAnimation {
                    blobAnimating = true
                }
            }
        }
    }
}

// MARK: - Tutorial Screen 2: Social Media Import Demo

struct TutorialScreen2: View {
    let onNext: () -> Void
    @State private var isAnimating = false
    @State private var contentAnimating = false
    @State private var shareIconsAnimating = false
    
    var body: some View {
        TutorialScreenBase(
            title: "Import restaurant content from social media into ReelEats",
            buttonText: "Continue",
            gradientColors: [
                Color.blue.opacity(0.08),
                Color.cyan.opacity(0.05),
                Color(.systemBackground)
            ],
            content: {
                VStack(spacing: 28) {
                    // Mock social media post with restaurant content
                    RestaurantSocialMediaPost(isAnimating: contentAnimating)
                    
                    // Share destination icons
                    HStack(spacing: 24) {
                        ForEach([
                            ("📍", "Location"),
                            ("📱", "Mobile"),
                            ("💬", "Messages"),
                            ("📧", "Mail")
                        ], id: \.0) { icon, name in
                            ShareDestinationIcon(
                                icon: icon,
                                name: name,
                                isAnimating: shareIconsAnimating
                            )
                        }
                    }
                }
                .onAppear {
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.4) {
                        withAnimation(.spring(response: 0.8, dampingFraction: 0.8)) {
                            contentAnimating = true
                        }
                    }
                    
                    DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
                        withAnimation(.spring(response: 0.6, dampingFraction: 0.7)) {
                            shareIconsAnimating = true
                        }
                    }
                }
            },
            onNext: onNext
        )
    }
}

// MARK: - Tutorial Screen 3: Content Extraction Demo

struct TutorialScreen3: View {
    let onNext: () -> Void
    @State private var isAnimating = false
    @State private var contentAnimating = false
    @State private var tagsAnimating = false
    
    var body: some View {
        TutorialScreenBase(
            title: "We'll extract the important bits & bobs",
            buttonText: "Continue",
            gradientColors: [
                Color.green.opacity(0.08),
                Color.mint.opacity(0.05),
                Color(.systemBackground)
            ],
            content: {
                // Mock TikTok-style interface showing content extraction
                MockTikTokContentExtraction(
                    isAnimating: contentAnimating,
                    tagsAnimating: tagsAnimating
                )
                .onAppear {
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.4) {
                        withAnimation(.spring(response: 0.8, dampingFraction: 0.8)) {
                            contentAnimating = true
                        }
                    }
                    
                    DispatchQueue.main.asyncAfter(deadline: .now() + 1.2) {
                        withAnimation(.spring(response: 0.6, dampingFraction: 0.7)) {
                            tagsAnimating = true
                        }
                    }
                }
            },
            onNext: onNext
        )
    }
}

// MARK: - Tutorial Screen 4: Map Integration Demo

struct TutorialScreen4: View {
    let onNext: () -> Void
    @State private var isAnimating = false
    @State private var mapAnimating = false
    @State private var pinsAnimating = false
    
    var body: some View {
        TutorialScreenBase(
            title: "And automatically pin restaurants on the map",
            buttonText: "Get Started",
            gradientColors: [
                Color.orange.opacity(0.08),
                Color.yellow.opacity(0.05),
                Color(.systemBackground)
            ],
            content: {
                // Mock map interface with restaurant pins
                MockMapWithRestaurantPins(
                    isAnimating: mapAnimating,
                    pinsAnimating: pinsAnimating
                )
                .onAppear {
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.4) {
                        withAnimation(.spring(response: 0.8, dampingFraction: 0.8)) {
                            mapAnimating = true
                        }
                    }
                    
                    DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
                        withAnimation(.spring(response: 0.6, dampingFraction: 0.7)) {
                            pinsAnimating = true
                        }
                    }
                }
            },
            onNext: onNext
        )
    }
}

// MARK: - App Integration Setup Screen

struct AppIntegrationSetupScreen: View {
    let onNext: () -> Void
    @State private var isAnimating = false
    @State private var appsVisible = false
    @State private var completedApps: Set<String> = []
    
    private let socialApps = [
        SocialAppIntegration(name: "Instagram", icon: "camera.fill", color: .pink, description: "Share restaurant posts"),
        SocialAppIntegration(name: "TikTok", icon: "music.note", color: .black, description: "Save food videos"),
        SocialAppIntegration(name: "Safari", icon: "safari.fill", color: .blue, description: "Bookmark restaurant websites")
    ]
    
    var body: some View {
        GeometryReader { geometry in
            ZStack {
                Color(.systemBackground)
                    .ignoresSafeArea()
                
                VStack(spacing: 0) {
                    // Header with blurred background and back button
                    AppIntegrationHeader()
                        .frame(height: geometry.size.height * 0.45)
                    
                    Spacer()
                    
                    // Setup content
                    VStack(spacing: 32) {
                        // Title section
                        VStack(spacing: 18) {
                            HStack {
                                Image(systemName: "exclamationmark.triangle.fill")
                                    .font(.system(size: 18, weight: .medium))
                                    .foregroundColor(.orange)
                                
                                Text("Set Up Required")
                                    .font(.system(size: 18, weight: .semibold))
                                    .foregroundColor(.orange)
                                
                                Spacer()
                            }
                            
                            VStack(alignment: .leading, spacing: 8) {
                                Text("Set up sharing content from your favourite apps")
                                    .font(.system(size: 28, weight: .bold))
                                    .foregroundColor(.primary)
                                    .multilineTextAlignment(.leading)
                                    .lineSpacing(2)
                                    .fixedSize(horizontal: false, vertical: true)
                            }
                        }
                        .opacity(isAnimating ? 1.0 : 0.0)
                        .offset(y: isAnimating ? 0 : 30)
                        .animation(.spring(response: 0.8, dampingFraction: 0.8).delay(0.3), value: isAnimating)
                        
                        // Social apps integration list
                        VStack(spacing: 18) {
                            ForEach(Array(socialApps.enumerated()), id: \.offset) { index, app in
                                SocialAppIntegrationRow(
                                    app: app,
                                    isCompleted: completedApps.contains(app.name),
                                    onTap: {
                                        handleAppIntegration(app.name, isLast: index == socialApps.count - 1)
                                    }
                                )
                                .opacity(appsVisible ? 1.0 : 0.0)
                                .offset(x: appsVisible ? 0 : -100)
                                .animation(.spring(response: 0.7, dampingFraction: 0.8).delay(0.6 + Double(index) * 0.1), value: appsVisible)
                            }
                        }
                    }
                    .padding(.horizontal, 32)
                    
                    Spacer()
                        .frame(height: geometry.safeAreaInsets.bottom + 60)
                }
            }
        }
        .onAppear {
            withAnimation {
                isAnimating = true
            }
            
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                withAnimation {
                    appsVisible = true
                }
            }
        }
    }
    
    private func handleAppIntegration(_ appName: String, isLast: Bool) {
        completedApps.insert(appName)
        
        if isLast && completedApps.count == socialApps.count {
            // All apps integrated, move to main app
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.8) {
                onNext()
            }
        }
    }
}

// MARK: - Supporting Components

struct TutorialScreenBase<Content: View>: View {
    let title: String
    let buttonText: String
    let gradientColors: [Color]
    @ViewBuilder let content: Content
    let onNext: () -> Void
    @State private var isAnimating = false
    
    var body: some View {
        GeometryReader { geometry in
            ZStack {
                // Gradient background
                LinearGradient(
                    colors: gradientColors,
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
                .ignoresSafeArea()
                
                VStack(spacing: 0) {
                    Spacer()
                        .frame(height: geometry.size.height * 0.1)
                    
                    // Content area
                    content
                        .frame(height: geometry.size.height * 0.4)
                    
                    Spacer()
                        .frame(height: 60)
                    
                    // Title
                    Text(title)
                        .font(.system(size: 36, weight: .bold))
                        .foregroundColor(.primary)
                        .multilineTextAlignment(.center)
                        .lineSpacing(4)
                        .padding(.horizontal, 32)
                        .opacity(isAnimating ? 1.0 : 0.0)
                        .offset(y: isAnimating ? 0 : 30)
                        .animation(.spring(response: 0.8, dampingFraction: 0.8).delay(0.5), value: isAnimating)
                    
                    Spacer()
                    
                    // Action button
                    TutorialButton(
                        title: buttonText,
                        action: onNext,
                        isVisible: isAnimating
                    )
                    .animation(.spring(response: 0.8, dampingFraction: 0.8).delay(0.7), value: isAnimating)
                    
                    Spacer()
                        .frame(height: geometry.safeAreaInsets.bottom + 50)
                }
            }
        }
        .onAppear {
            withAnimation {
                isAnimating = true
            }
        }
    }
}

struct TutorialButton: View {
    let title: String
    let action: () -> Void
    let isVisible: Bool
    @State private var isPressed = false
    
    var body: some View {
        Button(action: {
            HapticManager.shared.light()
            withAnimation(.easeInOut(duration: 0.1)) {
                isPressed = true
            }
            
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                withAnimation(.easeInOut(duration: 0.1)) {
                    isPressed = false
                }
                action()
            }
        }) {
            Text(title)
                .font(.system(size: 19, weight: .semibold))
                .foregroundColor(.white)
                .frame(maxWidth: .infinity)
                .frame(height: 60)
                .background(
                    RoundedRectangle(cornerRadius: 30)
                        .fill(Color.black)
                        .shadow(color: .black.opacity(0.25), radius: 12, x: 0, y: 6)
                )
                .scaleEffect(isPressed ? 0.97 : 1.0)
        }
        .padding(.horizontal, 32)
        .opacity(isVisible ? 1.0 : 0.0)
        .offset(y: isVisible ? 0 : 30)
    }
}

struct AnimatedGradientBlobs: View {
    let isAnimating: Bool
    
    var body: some View {
        ZStack {
            // Primary blob
            Circle()
                .fill(
                    RadialGradient(
                        colors: [
                            Color.pink.opacity(0.4),
                            Color.purple.opacity(0.2),
                            Color.clear
                        ],
                        center: .center,
                        startRadius: 80,
                        endRadius: 250
                    )
                )
                .frame(width: 400, height: 400)
                .blur(radius: 50)
                .scaleEffect(isAnimating ? 1.2 : 0.8)
                .offset(x: isAnimating ? 20 : -20, y: isAnimating ? -30 : 10)
                .animation(.easeInOut(duration: 4.0).repeatForever(autoreverses: true), value: isAnimating)
            
            // Secondary blob
            Circle()
                .fill(
                    RadialGradient(
                        colors: [
                            Color.orange.opacity(0.3),
                            Color.yellow.opacity(0.15),
                            Color.clear
                        ],
                        center: .bottomTrailing,
                        startRadius: 50,
                        endRadius: 180
                    )
                )
                .frame(width: 300, height: 300)
                .blur(radius: 40)
                .offset(x: isAnimating ? -40 : 60, y: isAnimating ? 40 : -20)
                .scaleEffect(isAnimating ? 0.9 : 1.1)
                .animation(.easeInOut(duration: 3.5).repeatForever(autoreverses: true), value: isAnimating)
            
            // Tertiary accent blob
            Circle()
                .fill(
                    RadialGradient(
                        colors: [
                            Color.mint.opacity(0.25),
                            Color.clear
                        ],
                        center: .topLeading,
                        startRadius: 30,
                        endRadius: 120
                    )
                )
                .frame(width: 200, height: 200)
                .blur(radius: 30)
                .offset(x: isAnimating ? 80 : -30, y: isAnimating ? -60 : 30)
                .scaleEffect(isAnimating ? 1.3 : 0.7)
                .animation(.easeInOut(duration: 5.0).repeatForever(autoreverses: true), value: isAnimating)
        }
    }
}

struct RestaurantSocialMediaPost: View {
    let isAnimating: Bool
    
    var body: some View {
        RoundedRectangle(cornerRadius: 20)
            .fill(Color.black.opacity(0.88))
            .frame(height: 240)
            .overlay(
                VStack(spacing: 18) {
                    // User header
                    HStack(spacing: 14) {
                        Circle()
                            .fill(
                                LinearGradient(
                                    colors: [.orange, .red],
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                )
                            )
                            .frame(width: 44, height: 44)
                            .overlay(
                                Text("🍕")
                                    .font(.system(size: 24))
                            )
                        
                        VStack(alignment: .leading, spacing: 4) {
                            Text("melbourne_foodie")
                                .font(.system(size: 16, weight: .semibold))
                                .foregroundColor(.white)
                            
                            Text("Best pizza spot in the city! 🔥✨")
                                .font(.system(size: 14))
                                .foregroundColor(.gray)
                        }
                        
                        Spacer()
                        
                        Button("Share") {
                            // Share action
                        }
                        .font(.system(size: 15, weight: .medium))
                        .foregroundColor(.blue)
                    }
                    .padding(.horizontal, 20)
                    
                    // Content preview
                    RoundedRectangle(cornerRadius: 14)
                        .fill(
                            LinearGradient(
                                colors: [
                                    Color.orange.opacity(0.8),
                                    Color.red.opacity(0.6),
                                    Color.yellow.opacity(0.4)
                                ],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                        .frame(height: 140)
                        .overlay(
                            VStack {
                                Text("🍕")
                                    .font(.system(size: 60))
                                
                                Text("Margherita Paradise")
                                    .font(.system(size: 16, weight: .semibold))
                                    .foregroundColor(.white)
                            }
                        )
                        .padding(.horizontal, 20)
                }
                .padding(.vertical, 20)
            )
            .padding(.horizontal, 32)
            .scaleEffect(isAnimating ? 1.0 : 0.9)
            .opacity(isAnimating ? 1.0 : 0.0)
    }
}

struct ShareDestinationIcon: View {
    let icon: String
    let name: String
    let isAnimating: Bool
    
    var body: some View {
        VStack(spacing: 8) {
            Circle()
                .fill(Color.white)
                .frame(width: 56, height: 56)
                .shadow(color: .black.opacity(0.1), radius: 8, x: 0, y: 4)
                .overlay(
                    Text(icon)
                        .font(.system(size: 24))
                )
            
            Text(name)
                .font(.system(size: 11, weight: .medium))
                .foregroundColor(.secondary)
        }
        .scaleEffect(isAnimating ? 1.0 : 0.3)
        .opacity(isAnimating ? 1.0 : 0.0)
    }
}

struct MockTikTokContentExtraction: View {
    let isAnimating: Bool
    let tagsAnimating: Bool
    
    var body: some View {
        RoundedRectangle(cornerRadius: 24)
            .fill(Color.black)
            .frame(width: 260, height: 360)
            .overlay(
                VStack(spacing: 0) {
                    // Video content area
                    RoundedRectangle(cornerRadius: 20)
                        .fill(
                            LinearGradient(
                                colors: [
                                    Color.orange.opacity(0.4),
                                    Color.yellow.opacity(0.6),
                                    Color.red.opacity(0.3)
                                ],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                        .overlay(
                            VStack {
                                Text("🥐")
                                    .font(.system(size: 80))
                                
                                Text("Croissant Heaven")
                                    .font(.system(size: 14, weight: .medium))
                                    .foregroundColor(.white)
                            }
                        )
                        .padding(.top, 20)
                        .padding(.horizontal, 20)
                    
                    Spacer()
                    
                    // Extracted tags
                    VStack(alignment: .leading, spacing: 12) {
                        HStack(spacing: 12) {
                            ForEach([
                                ("📍", "Place", Color.blue),
                                ("🍰", "Recipe", Color.orange),
                                ("📖", "Book", Color.purple)
                            ], id: \.0) { icon, text, color in
                                HStack(spacing: 6) {
                                    Text(icon)
                                        .font(.system(size: 12))
                                    Text(text)
                                        .font(.system(size: 12, weight: .medium))
                                        .foregroundColor(.white)
                                }
                                .padding(.horizontal, 12)
                                .padding(.vertical, 8)
                                .background(
                                    RoundedRectangle(cornerRadius: 12)
                                        .fill(color.opacity(0.8))
                                )
                                .scaleEffect(tagsAnimating ? 1.0 : 0.1)
                                .opacity(tagsAnimating ? 1.0 : 0.0)
                            }
                            
                            Spacer()
                        }
                        .padding(.horizontal, 20)
                        .padding(.bottom, 20)
                    }
                }
            )
            .scaleEffect(isAnimating ? 1.0 : 0.8)
            .opacity(isAnimating ? 1.0 : 0.0)
    }
}

struct MockMapWithRestaurantPins: View {
    let isAnimating: Bool
    let pinsAnimating: Bool
    
    var body: some View {
        RoundedRectangle(cornerRadius: 20)
            .fill(
                LinearGradient(
                    colors: [
                        Color.green.opacity(0.2),
                        Color.mint.opacity(0.4),
                        Color.blue.opacity(0.1)
                    ],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
            )
            .frame(height: 300)
            .overlay(
                VStack {
                    HStack {
                        Spacer()
                        
                        VStack(spacing: 10) {
                            Circle()
                                .fill(Color.red)
                                .frame(width: 16, height: 16)
                            
                            Text("📍 My Location")
                                .font(.system(size: 12, weight: .medium))
                                .foregroundColor(.black)
                                .padding(.horizontal, 12)
                                .padding(.vertical, 6)
                                .background(
                                    RoundedRectangle(cornerRadius: 10)
                                        .fill(Color.white.opacity(0.9))
                                )
                        }
                        .scaleEffect(pinsAnimating ? 1.0 : 0.3)
                        .opacity(pinsAnimating ? 1.0 : 0.0)
                        
                        Spacer()
                    }
                    .padding(.top, 30)
                    
                    Spacer()
                    
                    // Restaurant category pins
                    HStack(spacing: 24) {
                        ForEach([
                            ("🍕", "Pizza", Color.red),
                            ("☕", "Cafe", Color.brown),
                            ("🍸", "Bar", Color.purple)
                        ], id: \.0) { emoji, name, color in
                            VStack(spacing: 8) {
                                Circle()
                                    .fill(color.opacity(0.8))
                                    .frame(width: 40, height: 40)
                                    .overlay(
                                        Text(emoji)
                                            .font(.system(size: 20))
                                    )
                                
                                Text(name)
                                    .font(.system(size: 10, weight: .medium))
                                    .foregroundColor(.black)
                            }
                            .padding(12)
                            .background(
                                RoundedRectangle(cornerRadius: 12)
                                    .fill(Color.white.opacity(0.9))
                            )
                            .scaleEffect(pinsAnimating ? 1.0 : 0.3)
                            .opacity(pinsAnimating ? 1.0 : 0.0)
                        }
                    }
                    .padding(.horizontal, 28)
                    .padding(.bottom, 30)
                }
            )
            .padding(.horizontal, 32)
            .scaleEffect(isAnimating ? 1.0 : 0.9)
            .opacity(isAnimating ? 1.0 : 0.0)
    }
}

struct AppIntegrationHeader: View {
    var body: some View {
        ZStack {
            // Blurred background with app icons
            VStack {
                ForEach(0..<4) { row in
                    HStack {
                        ForEach(0..<5) { col in
                            RoundedRectangle(cornerRadius: 12)
                                .fill(Color.gray.opacity(0.3))
                                .frame(width: 60, height: 60)
                        }
                    }
                }
            }
            .blur(radius: 12)
            .opacity(0.4)
            
            // Back button overlay
            VStack {
                HStack {
                    Button(action: {}) {
                        Circle()
                            .fill(Color.white)
                            .frame(width: 44, height: 44)
                            .overlay(
                                Image(systemName: "arrow.left")
                                    .font(.system(size: 18, weight: .medium))
                                    .foregroundColor(.black)
                            )
                            .shadow(color: .black.opacity(0.1), radius: 8, x: 0, y: 4)
                    }
                    
                    Spacer()
                }
                .padding(.horizontal, 32)
                .padding(.top, 24)
                
                Spacer()
            }
            
            // ReelEats app icon in center with mascot
            RoundedRectangle(cornerRadius: 28)
                .fill(Color.white)
                .frame(width: 120, height: 120)
                .overlay(
                    MascotView(size: 84)
                )
                .shadow(color: .black.opacity(0.15), radius: 16, x: 0, y: 8)
        }
    }
}

struct SocialAppIntegration {
    let name: String
    let icon: String
    let color: Color
    let description: String
}

struct SocialAppIntegrationRow: View {
    let app: SocialAppIntegration
    let isCompleted: Bool
    let onTap: () -> Void
    @State private var isPressed = false
    
    var body: some View {
        Button(action: {
            HapticManager.shared.light()
            withAnimation(.easeInOut(duration: 0.1)) {
                isPressed = true
            }
            
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                withAnimation(.easeInOut(duration: 0.1)) {
                    isPressed = false
                }
                onTap()
            }
        }) {
            HStack(spacing: 18) {
                Circle()
                    .fill(app.color)
                    .frame(width: 44, height: 44)
                    .overlay(
                        Group {
                            if isCompleted {
                                Image(systemName: "checkmark")
                                    .font(.system(size: 20, weight: .bold))
                                    .foregroundColor(.white)
                            } else {
                                Image(systemName: app.icon)
                                    .font(.system(size: 22, weight: .medium))
                                    .foregroundColor(app.color == .black ? .white : .white)
                            }
                        }
                    )
                    .scaleEffect(isCompleted ? 1.1 : 1.0)
                    .animation(.spring(response: 0.3, dampingFraction: 0.6), value: isCompleted)
                
                VStack(alignment: .leading, spacing: 4) {
                    Text(app.name)
                        .font(.system(size: 18, weight: .medium))
                        .foregroundColor(.primary)
                    
                    Text(app.description)
                        .font(.system(size: 14))
                        .foregroundColor(.secondary)
                }
                
                Spacer()
                
                if isCompleted {
                    Text("Connected")
                        .font(.system(size: 14, weight: .medium))
                        .foregroundColor(.green)
                }
            }
            .padding(.horizontal, 24)
            .padding(.vertical, 20)
            .background(
                RoundedRectangle(cornerRadius: 16)
                    .fill(isCompleted ? Color.green.opacity(0.1) : Color(.systemGray6))
                    .overlay(
                        RoundedRectangle(cornerRadius: 16)
                            .stroke(isCompleted ? Color.green.opacity(0.3) : Color.clear, lineWidth: 1)
                    )
            )
            .scaleEffect(isPressed ? 0.98 : 1.0)
        }
    }
}

// MARK: - MascotView is defined in CompleteOnboarding.swift

#Preview {
    PostOnboardingTutorialCoordinator()
        .environmentObject(RestaurantStore())
}