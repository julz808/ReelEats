import SwiftUI
import Foundation
import AVKit

// MARK: - Post-Onboarding Tutorial Flow (7 Screens Total)

struct PostOnboardingTutorialCoordinator: View {
    @EnvironmentObject var store: RestaurantStore
    @State private var currentScreen = 0
    @State private var isTransitioning = false
    @State private var username = ""
    @State private var selectedCountry = "Australia"
    @State private var selectedProfileImageIndex = 0
    @State private var selectedGender = "Prefer not to say"
    @State private var dateOfBirth = Date()

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
                TutorialScreen5(onNext: { moveToNext() })
            case 5:
                UsernameInputScreen(username: $username, onNext: { moveToNext() })
            case 6:
                ProfilePictureSelectionScreen(selectedIndex: $selectedProfileImageIndex, onNext: { moveToNext() })
            case 7:
                TellUsAboutYourselfScreen(
                    selectedCountry: $selectedCountry,
                    selectedGender: $selectedGender,
                    dateOfBirth: $dateOfBirth,
                    onNext: { moveToNext() }
                )
            default:
                MainTabView()
                    .onAppear {
                        store.completeSetup()
                    }
            }

            // Skip button - appears on all tutorial screens (not MainTabView)
            if currentScreen < 8 {
                VStack {
                    HStack {
                        Spacer()
                        Button("Skip") {
                            store.completeSetup()
                        }
                        .font(.clashDisplayBodyTemp())
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
    @State private var orbitAnimating = false
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
                            .font(.clashDisplayBodyTemp())
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

                    // Orbiting app logos around ReelEats logo
                    OrbitingAppLogos(isAnimating: orbitAnimating)
                        .frame(height: geometry.size.height * 0.35)

                    Spacer()
                        .frame(height: 60)

                    // Title text
                    Text("A simple way to save and share your favourite food spots")
                        .font(.clashDisplayHeaderTemp(size: 36))
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
                    orbitAnimating = true
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

    var body: some View {
        TutorialScreenBase(
            title: "Import restaurant content from social media",
            buttonText: "Continue",
            gradientColors: [
                Color.blue.opacity(0.08),
                Color.cyan.opacity(0.05),
                Color(.systemBackground)
            ],
            content: {
                // Share extension demo video
                ShareExtensionVideoView(isAnimating: contentAnimating)
                    .onAppear {
                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.4) {
                            withAnimation(.spring(response: 0.8, dampingFraction: 0.8)) {
                                contentAnimating = true
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
    @State private var scannerAnimating = false

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
                // Reels screenshot with scanning animation
                ScanningReelsScreenshot(
                    isAnimating: isAnimating,
                    scannerAnimating: scannerAnimating
                )
                .onAppear {
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.4) {
                        withAnimation(.spring(response: 0.8, dampingFraction: 0.8)) {
                            isAnimating = true
                        }
                    }

                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.8) {
                        scannerAnimating = true
                    }
                }
            },
            onNext: onNext
        )
    }
}

// MARK: - Tutorial Screen 4: Collections Demo

struct TutorialScreen4: View {
    let onNext: () -> Void
    @State private var isAnimating = false
    @State private var collectionsAnimating = false
    @State private var cardsAnimating = false

    var body: some View {
        TutorialScreenBase(
            title: "...So you can create collections for you and with others",
            buttonText: "Continue",
            gradientColors: [
                Color.purple.opacity(0.08),
                Color.pink.opacity(0.05),
                Color(.systemBackground)
            ],
            content: {
                // Mock collections interface
                MockCollectionsView(
                    isAnimating: collectionsAnimating,
                    cardsAnimating: cardsAnimating
                )
                .onAppear {
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.4) {
                        withAnimation(.spring(response: 0.8, dampingFraction: 0.8)) {
                            collectionsAnimating = true
                        }
                    }

                    DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
                        withAnimation(.spring(response: 0.6, dampingFraction: 0.7)) {
                            cardsAnimating = true
                        }
                    }
                }
            },
            onNext: onNext
        )
    }
}

// MARK: - Tutorial Screen 5: Map Integration Demo

struct TutorialScreen5: View {
    let onNext: () -> Void
    @State private var isAnimating = false

    var body: some View {
        TutorialScreenBase(
            title: "...and see all your spots on a map",
            buttonText: "Continue",
            gradientColors: [
                Color.orange.opacity(0.08),
                Color.yellow.opacity(0.05),
                Color(.systemBackground)
            ],
            content: {
                // Map screenshot with red outline
                MapScreenshot(isAnimating: isAnimating)
                    .onAppear {
                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.4) {
                            withAnimation(.spring(response: 0.8, dampingFraction: 0.8)) {
                                isAnimating = true
                            }
                        }
                    }
            },
            onNext: onNext
        )
    }
}

// MARK: - Username Input Screen

struct UsernameInputScreen: View {
    @Binding var username: String
    let onNext: () -> Void
    @State private var isAnimating = false
    @FocusState private var isTextFieldFocused: Bool

    var body: some View {
        GeometryReader { geometry in
            ZStack {
                LinearGradient(
                    colors: [
                        Color.blue.opacity(0.08),
                        Color.cyan.opacity(0.05),
                        Color(.systemBackground)
                    ],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
                .ignoresSafeArea()

                VStack(spacing: 0) {
                    Spacer()
                        .frame(height: geometry.size.height * 0.15)

                    // Icon/Visual Element
                    Circle()
                        .fill(
                            LinearGradient(
                                colors: [Color.blue.opacity(0.2), Color.cyan.opacity(0.3)],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                        .frame(width: 120, height: 120)
                        .overlay(
                            Text("👤")
                                .font(.clashDisplayHeaderTemp(size: 60))
                        )
                        .opacity(isAnimating ? 1.0 : 0.0)
                        .scaleEffect(isAnimating ? 1.0 : 0.8)
                        .animation(.spring(response: 0.8, dampingFraction: 0.8).delay(0.2), value: isAnimating)

                    Spacer()
                        .frame(height: 60)

                    // Title
                    Text("Choose your username")
                        .font(.clashDisplayHeaderTemp(size: 32))
                        .foregroundColor(.primary)
                        .multilineTextAlignment(.center)
                        .lineLimit(2)
                        .minimumScaleFactor(0.8)
                        .padding(.horizontal, 32)
                        .opacity(isAnimating ? 1.0 : 0.0)
                        .offset(y: isAnimating ? 0 : 30)
                        .animation(.spring(response: 0.8, dampingFraction: 0.8).delay(0.4), value: isAnimating)

                    Spacer()
                        .frame(height: 40)

                    // Username Input Field
                    VStack(spacing: 12) {
                        HStack {
                            Text("@")
                                .font(.clashDisplayBodyTemp(size: 20))
                                .foregroundColor(.secondary)

                            TextField("username", text: $username)
                                .font(.clashDisplayBodyTemp(size: 20))
                                .foregroundColor(.primary)
                                .autocapitalization(.none)
                                .autocorrectionDisabled()
                                .focused($isTextFieldFocused)
                        }
                        .padding(.horizontal, 24)
                        .padding(.vertical, 20)
                        .background(
                            RoundedRectangle(cornerRadius: 16)
                                .fill(Color(.systemBackground))
                                .shadow(color: .black.opacity(0.1), radius: 10, x: 0, y: 4)
                        )

                        Text("You can always change this later")
                            .font(.clashDisplaySecondaryTemp())
                            .foregroundColor(.secondary)
                    }
                    .padding(.horizontal, 32)
                    .opacity(isAnimating ? 1.0 : 0.0)
                    .offset(y: isAnimating ? 0 : 30)
                    .animation(.spring(response: 0.8, dampingFraction: 0.8).delay(0.6), value: isAnimating)

                    Spacer()

                    // Continue button
                    TutorialButton(
                        title: "Continue",
                        action: {
                            if !username.isEmpty {
                                onNext()
                            }
                        },
                        isVisible: isAnimating
                    )
                    .opacity(username.isEmpty ? 0.5 : 1.0)
                    .animation(.spring(response: 0.8, dampingFraction: 0.8).delay(0.8), value: isAnimating)

                    Spacer()
                        .frame(height: geometry.safeAreaInsets.bottom + 50)
                }
            }
        }
        .onAppear {
            withAnimation {
                isAnimating = true
            }
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.8) {
                isTextFieldFocused = true
            }
        }
    }
}

// MARK: - Profile Picture Selection Screen

struct ProfilePictureSelectionScreen: View {
    @Binding var selectedIndex: Int
    let onNext: () -> Void
    @State private var isAnimating = false
    @State private var useEmoji = true  // Toggle between emoji and photo

    private let profileEmojis = ["👨", "👩", "🧑", "👨‍🦱", "👩‍🦰", "🧔", "👨‍🦳", "👩‍🦳", "🐶", "🐱", "🦊", "🐼"]

    var body: some View {
        GeometryReader { geometry in
            ZStack {
                LinearGradient(
                    colors: [
                        Color.reelEatsAccent.opacity(0.08),
                        Color.orange.opacity(0.05),
                        Color(.systemBackground)
                    ],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
                .ignoresSafeArea()

                VStack(spacing: 0) {
                    Spacer()
                        .frame(height: geometry.size.height * 0.10)

                    // Selected Profile Picture Preview
                    Circle()
                        .fill(
                            LinearGradient(
                                colors: [Color.reelEatsAccent.opacity(0.3), Color.orange.opacity(0.4)],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                        .frame(width: 140, height: 140)
                        .overlay(
                            Text(profileEmojis[selectedIndex])
                                .font(.clashDisplayHeaderTemp(size: 70))
                        )
                        .shadow(color: .black.opacity(0.15), radius: 20, x: 0, y: 10)
                        .opacity(isAnimating ? 1.0 : 0.0)
                        .scaleEffect(isAnimating ? 1.0 : 0.8)
                        .animation(.spring(response: 0.8, dampingFraction: 0.8).delay(0.2), value: isAnimating)

                    Spacer()
                        .frame(height: 40)

                    // Title
                    Text("Select your profile picture")
                        .font(.clashDisplayHeaderTemp(size: 32))
                        .foregroundColor(.primary)
                        .multilineTextAlignment(.center)
                        .lineLimit(2)
                        .minimumScaleFactor(0.8)
                        .padding(.horizontal, 32)
                        .opacity(isAnimating ? 1.0 : 0.0)
                        .offset(y: isAnimating ? 0 : 30)
                        .animation(.spring(response: 0.8, dampingFraction: 0.8).delay(0.4), value: isAnimating)

                    Spacer()
                        .frame(height: 30)

                    // Toggle between Emoji and Photo
                    HStack(spacing: 12) {
                        ToggleButton(title: "Emoji", isSelected: useEmoji) {
                            withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                                useEmoji = true
                            }
                        }

                        ToggleButton(title: "Photo", isSelected: !useEmoji) {
                            withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                                useEmoji = false
                            }
                        }
                    }
                    .padding(.horizontal, 32)
                    .opacity(isAnimating ? 1.0 : 0.0)
                    .animation(.spring(response: 0.8, dampingFraction: 0.8).delay(0.5), value: isAnimating)

                    Spacer()
                        .frame(height: 30)

                    // Profile Picture Selection Area
                    if useEmoji {
                        // Emoji Grid
                        LazyVGrid(columns: [GridItem(.adaptive(minimum: 70), spacing: 16)], spacing: 16) {
                            ForEach(profileEmojis.indices, id: \.self) { index in
                                Button(action: {
                                    HapticManager.shared.light()
                                    withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                                        selectedIndex = index
                                    }
                                }) {
                                    Circle()
                                        .fill(
                                            selectedIndex == index ?
                                            LinearGradient(
                                                colors: [Color.reelEatsAccent.opacity(0.2), Color.orange.opacity(0.3)],
                                                startPoint: .topLeading,
                                                endPoint: .bottomTrailing
                                            ) :
                                            LinearGradient(
                                                colors: [Color(.systemGray5), Color(.systemGray6)],
                                                startPoint: .topLeading,
                                                endPoint: .bottomTrailing
                                            )
                                        )
                                        .frame(width: 70, height: 70)
                                        .overlay(
                                            Text(profileEmojis[index])
                                                .font(.clashDisplayHeaderTemp(size: 35))
                                        )
                                        .overlay(
                                            Circle()
                                                .stroke(selectedIndex == index ? Color.reelEatsAccent : Color.clear, lineWidth: 3)
                                        )
                                        .scaleEffect(selectedIndex == index ? 1.05 : 1.0)
                                }
                            }
                        }
                        .padding(.horizontal, 32)
                        .opacity(isAnimating ? 1.0 : 0.0)
                        .offset(y: isAnimating ? 0 : 30)
                        .animation(.spring(response: 0.8, dampingFraction: 0.8).delay(0.6), value: isAnimating)
                    } else {
                        // Photo Gallery Picker
                        Button(action: {
                            HapticManager.shared.light()
                            // Photo picker would open here
                        }) {
                            VStack(spacing: 16) {
                                Image(systemName: "photo.on.rectangle.angled")
                                    .font(.system(size: 50))
                                    .foregroundColor(.reelEatsAccent)

                                Text("Choose from Photos")
                                    .font(.clashDisplayButtonTemp(size: 18))
                                    .foregroundColor(.primary)
                            }
                            .frame(height: 200)
                            .frame(maxWidth: .infinity)
                            .background(
                                RoundedRectangle(cornerRadius: 20)
                                    .fill(Color(.systemGray6))
                            )
                        }
                        .padding(.horizontal, 32)
                        .opacity(isAnimating ? 1.0 : 0.0)
                        .offset(y: isAnimating ? 0 : 30)
                        .animation(.spring(response: 0.8, dampingFraction: 0.8).delay(0.6), value: isAnimating)
                    }

                    Spacer()

                    // Continue button
                    TutorialButton(
                        title: "Continue",
                        action: onNext,
                        isVisible: isAnimating
                    )
                    .animation(.spring(response: 0.8, dampingFraction: 0.8).delay(0.8), value: isAnimating)

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

// MARK: - Country Selection Screen

struct CountrySelectionScreen: View {
    @Binding var selectedCountry: String
    let onNext: () -> Void
    @State private var isAnimating = false
    @State private var showingPicker = false
    @State private var searchText = ""

    private let countries = [
        "Afghanistan", "Albania", "Algeria", "Argentina", "Australia", "Austria",
        "Bangladesh", "Belgium", "Brazil", "Bulgaria",
        "Canada", "Chile", "China", "Colombia", "Costa Rica", "Croatia", "Cuba", "Czech Republic",
        "Denmark", "Dominican Republic", "Egypt", "Estonia", "Ethiopia",
        "Finland", "France",
        "Germany", "Ghana", "Greece",
        "Hong Kong", "Hungary",
        "Iceland", "India", "Indonesia", "Iran", "Iraq", "Ireland", "Israel", "Italy",
        "Jamaica", "Japan", "Jordan",
        "Kenya", "Kuwait", "South Korea",
        "Latvia", "Lebanon", "Libya", "Lithuania", "Luxembourg",
        "Malaysia", "Malta", "Mexico", "Morocco",
        "Netherlands", "New Zealand", "Nigeria", "Norway",
        "Pakistan", "Peru", "Philippines", "Poland", "Portugal",
        "Qatar", "Romania", "Russia",
        "Saudi Arabia", "Serbia", "Singapore", "Slovakia", "Slovenia", "South Africa", "Spain", "Sri Lanka", "Sweden", "Switzerland", "Syria",
        "Taiwan", "Thailand", "Tunisia", "Turkey",
        "Ukraine", "United Arab Emirates", "United Kingdom", "United States", "Uruguay",
        "Venezuela", "Vietnam",
        "Yemen",
        "Zimbabwe"
    ]

    private var filteredCountries: [String] {
        if searchText.isEmpty {
            return countries
        } else {
            return countries.filter { $0.localizedCaseInsensitiveContains(searchText) }
        }
    }

    var body: some View {
        GeometryReader { geometry in
            ZStack {
                LinearGradient(
                    colors: [
                        Color.green.opacity(0.08),
                        Color.mint.opacity(0.05),
                        Color(.systemBackground)
                    ],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
                .ignoresSafeArea()

                VStack(spacing: 0) {
                    Spacer()
                        .frame(height: geometry.size.height * 0.15)

                    // Icon/Visual Element
                    Circle()
                        .fill(
                            LinearGradient(
                                colors: [Color.green.opacity(0.2), Color.mint.opacity(0.3)],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                        .frame(width: 120, height: 120)
                        .overlay(
                            Text("🌍")
                                .font(.clashDisplayHeaderTemp(size: 60))
                        )
                        .opacity(isAnimating ? 1.0 : 0.0)
                        .scaleEffect(isAnimating ? 1.0 : 0.8)
                        .animation(.spring(response: 0.8, dampingFraction: 0.8).delay(0.2), value: isAnimating)

                    Spacer()
                        .frame(height: 60)

                    // Title
                    Text("Select your home country")
                        .font(.clashDisplayHeaderTemp(size: 32))
                        .foregroundColor(.primary)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal, 32)
                        .opacity(isAnimating ? 1.0 : 0.0)
                        .offset(y: isAnimating ? 0 : 30)
                        .animation(.spring(response: 0.8, dampingFraction: 0.8).delay(0.4), value: isAnimating)

                    Spacer()
                        .frame(height: 40)

                    // Country Picker Button
                    Button(action: {
                        HapticManager.shared.light()
                        withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                            showingPicker.toggle()
                        }
                    }) {
                        HStack {
                            Text(selectedCountry)
                                .font(.clashDisplayBodyTemp(size: 20))
                                .foregroundColor(.primary)

                            Spacer()

                            Image(systemName: showingPicker ? "chevron.up" : "chevron.down")
                                .font(.clashDisplayBodyTemp(size: 16))
                                .foregroundColor(.secondary)
                        }
                        .padding(.horizontal, 24)
                        .padding(.vertical, 20)
                        .background(
                            RoundedRectangle(cornerRadius: 16)
                                .fill(Color(.systemBackground))
                                .shadow(color: .black.opacity(0.1), radius: 10, x: 0, y: 4)
                        )
                    }
                    .padding(.horizontal, 32)
                    .opacity(isAnimating ? 1.0 : 0.0)
                    .offset(y: isAnimating ? 0 : 30)
                    .animation(.spring(response: 0.8, dampingFraction: 0.8).delay(0.6), value: isAnimating)

                    // Custom Country Picker with Search
                    if showingPicker {
                        VStack(spacing: 0) {
                            // Search field
                            HStack {
                                Image(systemName: "magnifyingglass")
                                    .foregroundColor(.secondary)

                                TextField("Search countries", text: $searchText)
                                    .font(.clashDisplayBodyTemp(size: 16))
                                    .autocorrectionDisabled()

                                if !searchText.isEmpty {
                                    Button(action: {
                                        searchText = ""
                                    }) {
                                        Image(systemName: "xmark.circle.fill")
                                            .foregroundColor(.secondary)
                                    }
                                }
                            }
                            .padding(.horizontal, 16)
                            .padding(.vertical, 12)
                            .background(Color(.systemGray6))
                            .cornerRadius(12)
                            .padding(.horizontal, 16)
                            .padding(.top, 12)

                            // Country list
                            ScrollView {
                                VStack(spacing: 0) {
                                    ForEach(filteredCountries, id: \.self) { country in
                                        Button(action: {
                                            HapticManager.shared.light()
                                            withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                                                selectedCountry = country
                                                showingPicker = false
                                                searchText = ""
                                            }
                                        }) {
                                            HStack {
                                                Text(country)
                                                    .font(.clashDisplayBodyTemp(size: 16))
                                                    .foregroundColor(.primary)

                                                Spacer()

                                                if selectedCountry == country {
                                                    Image(systemName: "checkmark")
                                                        .foregroundColor(.green)
                                                        .font(.clashDisplayBodyTemp(size: 16))
                                                }
                                            }
                                            .padding(.horizontal, 20)
                                            .padding(.vertical, 14)
                                            .background(selectedCountry == country ? Color.green.opacity(0.1) : Color.clear)
                                        }

                                        Divider()
                                            .padding(.leading, 20)
                                    }
                                }
                            }
                            .frame(height: 300)
                        }
                        .background(
                            RoundedRectangle(cornerRadius: 16)
                                .fill(Color(.systemBackground))
                                .shadow(color: .black.opacity(0.15), radius: 20, x: 0, y: 10)
                        )
                        .padding(.horizontal, 32)
                        .padding(.top, 12)
                        .transition(.scale.combined(with: .opacity))
                    }

                    Spacer()

                    // Continue button
                    TutorialButton(
                        title: "Continue",
                        action: onNext,
                        isVisible: isAnimating
                    )
                    .animation(.spring(response: 0.8, dampingFraction: 0.8).delay(0.8), value: isAnimating)

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
                        .font(.clashDisplayHeaderTemp(size: 26))
                        .foregroundColor(.primary)
                        .multilineTextAlignment(.center)
                        .lineSpacing(1)
                        .padding(.horizontal, 32)
                        .fixedSize(horizontal: false, vertical: true)
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
                .font(.clashDisplayButtonTemp(size: 19))
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

struct OrbitingAppLogos: View {
    let isAnimating: Bool
    @State private var rotationAngle: Double = 0

    private let appLogos = [
        ("instagram logo", 0.0),      // Top
        ("Safari", 72.0),              // Top-right
        ("Google Keep", 144.0),        // Bottom-right
        ("TikTok", 216.0),            // Bottom-left
        ("notes app", 288.0)           // Top-left
    ]

    var body: some View {
        ZStack {
            // Background gradient blobs for depth
            Circle()
                .fill(
                    RadialGradient(
                        colors: [
                            Color.pink.opacity(0.15),
                            Color.purple.opacity(0.08),
                            Color.clear
                        ],
                        center: .center,
                        startRadius: 50,
                        endRadius: 200
                    )
                )
                .frame(width: 400, height: 400)
                .blur(radius: 40)
                .scaleEffect(isAnimating ? 1.1 : 0.9)
                .animation(.easeInOut(duration: 3.0).repeatForever(autoreverses: true), value: isAnimating)

            // Grey circle outline
            Circle()
                .stroke(Color.gray.opacity(0.3), lineWidth: 1.5)
                .frame(width: 260, height: 260)
                .opacity(isAnimating ? 1.0 : 0.0)
                .animation(.easeOut(duration: 0.8).delay(0.3), value: isAnimating)

            // ReelEats logo in center - 10% bigger than doubled size
            Group {
                if let uiImage = UIImage(named: "ReelEats logo") {
                    Image(uiImage: uiImage)
                        .resizable()
                        .scaledToFit()
                        .frame(width: 176, height: 176)
                } else {
                    Circle()
                        .fill(Color.reelEatsAccent.opacity(0.2))
                        .frame(width: 176, height: 176)
                        .overlay(
                            Text("R")
                                .font(.clashDisplayHeaderTemp(size: 88))
                                .foregroundColor(.reelEatsAccent)
                        )
                }
            }
            .scaleEffect(isAnimating ? 1.0 : 0.7)
            .opacity(isAnimating ? 1.0 : 0.0)
            .animation(.spring(response: 0.8, dampingFraction: 0.7).delay(0.2), value: isAnimating)

            // Orbiting app logos
            ZStack {
                ForEach(Array(appLogos.enumerated()), id: \.offset) { index, logo in
                    OrbitingLogo(
                        imageName: logo.0,
                        baseAngle: logo.1,
                        rotationAngle: rotationAngle,
                        isAnimating: isAnimating,
                        delay: Double(index) * 0.1
                    )
                }
            }
            .rotationEffect(.degrees(rotationAngle))
            .animation(.linear(duration: 20.0).repeatForever(autoreverses: false), value: rotationAngle)
        }
        .onAppear {
            // Start the orbit animation
            DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
                rotationAngle = 360
            }
        }
    }
}

struct OrbitingLogo: View {
    let imageName: String
    let baseAngle: Double
    let rotationAngle: Double  // Not used in calculation now, rotation is done at parent level
    let isAnimating: Bool
    let delay: Double

    private let orbitRadius: CGFloat = 130

    // Custom sizing for logos that have more padding/transparency
    private var logoSize: CGFloat {
        if imageName == "Safari" {
            return 125  // Safari has more transparent padding, so make it bigger
        } else if imageName == "notes app" {
            return 48   // Notes app slightly smaller
        }
        return 55
    }

    var body: some View {
        Group {
            if let uiImage = UIImage(named: imageName) {
                Image(uiImage: uiImage)
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(width: logoSize, height: logoSize)
            } else {
                Circle()
                    .fill(Color.gray.opacity(0.2))
                    .frame(width: 55, height: 55)
            }
        }
        .rotationEffect(.degrees(-rotationAngle))  // Counter-rotate to keep logo upright
        .offset(x: orbitRadius * cos(baseAngle * .pi / 180),
                y: orbitRadius * sin(baseAngle * .pi / 180))
        .scaleEffect(isAnimating ? 1.0 : 0.5)
        .opacity(isAnimating ? 1.0 : 0.0)
        .animation(.spring(response: 0.8, dampingFraction: 0.7).delay(0.4 + delay), value: isAnimating)
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

struct ShareExtensionVideoView: View {
    let isAnimating: Bool
    @State private var player: AVPlayer?

    var body: some View {
        VStack {
            if let player = player {
                GeometryReader { geometry in
                    VideoPlayer(player: player)
                        .aspectRatio(contentMode: .fill)
                        .frame(width: geometry.size.width * 1.6, height: geometry.size.height * 1.15)
                        .offset(x: -geometry.size.width * 0.27, y: -geometry.size.height * 0.08)
                }
                .frame(width: 195, height: 380)
                .clipShape(RoundedRectangle(cornerRadius: 24))
                .overlay(
                    RoundedRectangle(cornerRadius: 24)
                        .stroke(Color.reelEatsAccent, lineWidth: 3)
                )
                .shadow(color: .black.opacity(0.2), radius: 20, x: 0, y: 10)
                .scaleEffect(isAnimating ? 1.0 : 0.9)
                .opacity(isAnimating ? 1.0 : 0.0)
            } else {
                RoundedRectangle(cornerRadius: 24)
                    .fill(Color.black.opacity(0.1))
                    .frame(width: 200, height: 380)
                    .overlay(
                        ProgressView()
                    )
            }
        }
        .onAppear {
            setupPlayer()
        }
        .onDisappear {
            player?.pause()
        }
    }

    private func setupPlayer() {
        guard let videoURL = Bundle.main.url(forResource: "Share extension demo video", withExtension: "mp4") else {
            print("Video file not found")
            return
        }

        player = AVPlayer(url: videoURL)
        player?.play()

        // Loop the video
        NotificationCenter.default.addObserver(
            forName: .AVPlayerItemDidPlayToEndTime,
            object: player?.currentItem,
            queue: .main
        ) { _ in
            player?.seek(to: .zero)
            player?.play()
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
                                    .font(.clashDisplayHeaderTemp())
                            )

                        VStack(alignment: .leading, spacing: 4) {
                            Text("melbourne_foodie")
                                .font(.clashDisplayButtonTemp())
                                .foregroundColor(.white)

                            Text("Best pizza spot in the city! 🔥✨")
                                .font(.clashDisplaySecondaryTemp())
                                .foregroundColor(.gray)
                        }

                        Spacer()

                        Button("Share") {
                            // Share action
                        }
                        .font(.clashDisplayBodyTemp(size: 15))
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
                                    .font(.clashDisplayHeaderTemp(size: 60))

                                Text("Margherita Paradise")
                                    .font(.clashDisplayButtonTemp())
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
                        .font(.clashDisplayHeaderTemp())
                )

            Text(name)
                .font(.clashDisplayCaptionTemp(size: 11))
                .foregroundColor(.secondary)
        }
        .scaleEffect(isAnimating ? 1.0 : 0.3)
        .opacity(isAnimating ? 1.0 : 0.0)
    }
}

struct ScanningReelsScreenshot: View {
    let isAnimating: Bool
    let scannerAnimating: Bool
    @State private var scannerOffset: CGFloat = -180
    @State private var showRestaurantCard = false

    var body: some View {
        ZStack {
            // Reels screenshot with rounded corners and red border
            if let uiImage = UIImage(named: "Reels screenshot") {
                Image(uiImage: uiImage)
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(width: 200, height: 360)
                    .clipShape(RoundedRectangle(cornerRadius: 20))
                    .overlay(
                        RoundedRectangle(cornerRadius: 20)
                            .stroke(Color.reelEatsAccent, lineWidth: 3)
                    )
                    .shadow(color: .black.opacity(0.15), radius: 20, x: 0, y: 10)
            } else {
                RoundedRectangle(cornerRadius: 20)
                    .fill(Color.gray.opacity(0.2))
                    .frame(width: 200, height: 360)
                    .overlay(
                        Text("Screenshot")
                            .font(.clashDisplayBodyTemp())
                            .foregroundColor(.secondary)
                    )
            }

            // Scanning line overlay - THICKER WITH ROUNDED EDGES & MORE GLOW
            if scannerAnimating {
                RoundedRectangle(cornerRadius: 10)
                    .fill(
                        LinearGradient(
                            colors: [
                                Color.reelEatsAccent.opacity(0.0),
                                Color.reelEatsAccent.opacity(0.9),
                                Color.reelEatsAccent.opacity(0.9),
                                Color.reelEatsAccent.opacity(0.0)
                            ],
                            startPoint: .top,
                            endPoint: .bottom
                        )
                    )
                    .frame(width: 240, height: 20)
                    .shadow(color: Color.reelEatsAccent.opacity(0.8), radius: 15, x: 0, y: 0)
                    .shadow(color: Color.reelEatsAccent.opacity(0.6), radius: 25, x: 0, y: 0)
                    .offset(y: scannerOffset)
                    .animation(.easeInOut(duration: 2.5).repeatForever(autoreverses: true), value: scannerOffset)
                    .onAppear {
                        scannerOffset = 180

                        // Show restaurant card after scanner starts moving
                        DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
                            withAnimation(.spring(response: 0.6, dampingFraction: 0.8)) {
                                showRestaurantCard = true
                            }
                        }
                    }
            }

            // Restaurant card appears after one scan lap - positioned to the left
            if showRestaurantCard {
                ExtractedRestaurantCard()
                    .transition(.scale.combined(with: .opacity))
                    .offset(x: -35)  // Shift left so emoji aligns with screenshot edge
            }
        }
        .frame(width: 220, height: 360)
        .scaleEffect(isAnimating ? 1.0 : 0.9)
        .opacity(isAnimating ? 1.0 : 0.0)
    }
}

struct ExtractedRestaurantCard: View {
    var body: some View {
        HStack(spacing: 12) {
            // Pasta emoji on the left
            Circle()
                .fill(Color.white.opacity(0.95))
                .frame(width: 50, height: 50)
                .overlay(
                    Text("🍝")
                        .font(.clashDisplayHeaderTemp(size: 28))
                )
                .shadow(color: .black.opacity(0.1), radius: 4, x: 0, y: 2)

            // Restaurant details on the right
            VStack(alignment: .leading, spacing: 2) {
                Text("Marameo")
                    .font(.clashDisplayButtonTemp(size: 18))
                    .foregroundColor(.primary)

                Text("Italian")
                    .font(.clashDisplaySecondaryTemp(size: 14))
                    .foregroundColor(.secondary)

                Text("Melbourne, VIC")
                    .font(.clashDisplaySecondaryTemp(size: 13))
                    .foregroundColor(.secondary)
            }

            Spacer()
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 10)
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(Color(.systemBackground).opacity(0.85))
                .shadow(color: .black.opacity(0.15), radius: 12, x: 0, y: 6)
        )
        .frame(width: 230)
    }
}

struct MapScreenshot: View {
    let isAnimating: Bool

    var body: some View {
        ZStack {
            // Map screenshot with rounded corners and red border - LANDSCAPE & BIGGER
            if let uiImage = UIImage(named: "Map") {
                Image(uiImage: uiImage)
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(maxWidth: 340)
                    .clipShape(RoundedRectangle(cornerRadius: 24))
                    .overlay(
                        RoundedRectangle(cornerRadius: 24)
                            .stroke(Color.reelEatsAccent, lineWidth: 3)
                    )
                    .shadow(color: .black.opacity(0.15), radius: 20, x: 0, y: 10)
            } else {
                RoundedRectangle(cornerRadius: 24)
                    .fill(Color.gray.opacity(0.2))
                    .frame(width: 340, height: 240)
                    .overlay(
                        Text("Map")
                            .font(.clashDisplayBodyTemp())
                            .foregroundColor(.secondary)
                    )
            }
        }
        .scaleEffect(isAnimating ? 1.0 : 0.9)
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
                                    .font(.clashDisplayHeaderTemp(size: 80))
                                
                                Text("Croissant Heaven")
                                    .font(.clashDisplaySecondaryTemp())
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
                                        .font(.clashDisplayCaptionTemp())
                                    Text(text)
                                        .font(.clashDisplayCaptionTemp())
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

struct MockCollectionsView: View {
    let isAnimating: Bool
    let cardsAnimating: Bool

    private let collections = [
        ("☕", "Melbourne coffee", Color.brown, 15, "person.fill"),
        ("🍷", "Date night", Color.purple, 12, "person.2.fill"),
        ("🍕", "Pizza in NYC", Color.red, 20, "person.3.fill")
    ]

    var body: some View {
        VStack(spacing: 20) {
            ForEach(Array(collections.enumerated()), id: \.offset) { index, collection in
                RoundedRectangle(cornerRadius: 16)
                    .fill(
                        LinearGradient(
                            colors: [
                                collection.2.opacity(0.15),
                                collection.2.opacity(0.05)
                            ],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .frame(height: 80)
                    .overlay(
                        HStack(spacing: 16) {
                            Circle()
                                .fill(collection.2.opacity(0.3))
                                .frame(width: 50, height: 50)
                                .overlay(
                                    Text(collection.0)
                                        .font(.clashDisplayHeaderTemp(size: 28))
                                )

                            VStack(alignment: .leading, spacing: 4) {
                                Text(collection.1)
                                    .font(.clashDisplayButtonTemp(size: 18))
                                    .foregroundColor(.primary)
                                    .lineLimit(1)

                                Text("\(collection.3) spots")
                                    .font(.clashDisplaySecondaryTemp())
                                    .foregroundColor(.secondary)
                            }

                            Spacer()

                            Image(systemName: collection.4)
                                .font(.clashDisplayBodyTemp(size: 18))
                                .foregroundColor(.secondary)
                        }
                        .padding(.horizontal, 20)
                    )
                    .scaleEffect(cardsAnimating ? 1.0 : 0.9)
                    .opacity(cardsAnimating ? 1.0 : 0.0)
                    .animation(.spring(response: 0.6, dampingFraction: 0.7).delay(Double(index) * 0.1), value: cardsAnimating)
            }
        }
        .padding(.horizontal, 32)
        .opacity(isAnimating ? 1.0 : 0.0)
        .scaleEffect(isAnimating ? 1.0 : 0.95)
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
                                .font(.clashDisplayCaptionTemp())
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
                                            .font(.clashDisplayRestaurantNameTemp(size: 20))
                                    )

                                Text(name)
                                    .font(.clashDisplayCaptionTemp(size: 10))
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

// MARK: - Tell Us About Yourself Screen (Country, Gender, Date of Birth)

struct TellUsAboutYourselfScreen: View {
    @Binding var selectedCountry: String
    @Binding var selectedGender: String
    @Binding var dateOfBirth: Date
    let onNext: () -> Void
    @State private var isAnimating = false
    @State private var showingCountryPicker = false
    @State private var searchText = ""

    private let genders = ["Male", "Female", "Non-binary", "Prefer not to say"]
    private let countries = [
        "Afghanistan", "Albania", "Algeria", "Argentina", "Australia", "Austria",
        "Bangladesh", "Belgium", "Brazil", "Bulgaria",
        "Canada", "Chile", "China", "Colombia", "Costa Rica", "Croatia", "Cuba", "Czech Republic",
        "Denmark", "Dominican Republic", "Egypt", "Estonia", "Ethiopia",
        "Finland", "France",
        "Germany", "Ghana", "Greece",
        "Hong Kong", "Hungary",
        "Iceland", "India", "Indonesia", "Iran", "Iraq", "Ireland", "Israel", "Italy",
        "Jamaica", "Japan", "Jordan",
        "Kenya", "Kuwait", "South Korea",
        "Latvia", "Lebanon", "Libya", "Lithuania", "Luxembourg",
        "Malaysia", "Malta", "Mexico", "Morocco",
        "Netherlands", "New Zealand", "Nigeria", "Norway",
        "Pakistan", "Peru", "Philippines", "Poland", "Portugal",
        "Qatar", "Romania", "Russia",
        "Saudi Arabia", "Serbia", "Singapore", "Slovakia", "Slovenia", "South Africa", "Spain", "Sri Lanka", "Sweden", "Switzerland", "Syria",
        "Taiwan", "Thailand", "Tunisia", "Turkey",
        "Ukraine", "United Arab Emirates", "United Kingdom", "United States", "Uruguay",
        "Venezuela", "Vietnam",
        "Yemen",
        "Zimbabwe"
    ]

    private var filteredCountries: [String] {
        if searchText.isEmpty {
            return countries
        } else {
            return countries.filter { $0.localizedCaseInsensitiveContains(searchText) }
        }
    }

    var body: some View {
        GeometryReader { geometry in
            ZStack {
                LinearGradient(
                    colors: [
                        Color.reelEatsAccent.opacity(0.08),
                        Color.orange.opacity(0.05),
                        Color(.systemBackground)
                    ],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
                .ignoresSafeArea()

                ScrollView {
                    VStack(spacing: 0) {
                        Spacer()
                            .frame(height: geometry.size.height * 0.08)

                        // Icon/Visual Element
                        Circle()
                            .fill(
                                LinearGradient(
                                    colors: [Color.reelEatsAccent.opacity(0.2), Color.orange.opacity(0.3)],
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                )
                            )
                            .frame(width: 100, height: 100)
                            .overlay(
                                Text("👤")
                                    .font(.clashDisplayHeaderTemp(size: 50))
                            )
                            .opacity(isAnimating ? 1.0 : 0.0)
                            .scaleEffect(isAnimating ? 1.0 : 0.8)
                            .animation(.spring(response: 0.8, dampingFraction: 0.8).delay(0.2), value: isAnimating)

                        Spacer()
                            .frame(height: 30)

                        // Title
                        Text("Tell us about yourself")
                            .font(.clashDisplayHeaderTemp(size: 30))
                            .foregroundColor(.primary)
                            .multilineTextAlignment(.center)
                            .padding(.horizontal, 32)
                            .opacity(isAnimating ? 1.0 : 0.0)
                            .offset(y: isAnimating ? 0 : 30)
                            .animation(.spring(response: 0.8, dampingFraction: 0.8).delay(0.4), value: isAnimating)

                        Spacer()
                            .frame(height: 40)

                        // Country Selection
                        VStack(alignment: .leading, spacing: 12) {
                            Text("Country")
                                .font(.clashDisplayButtonTemp(size: 16))
                                .foregroundColor(.secondary)
                                .padding(.horizontal, 32)

                            Button(action: {
                                HapticManager.shared.light()
                                withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                                    showingCountryPicker.toggle()
                                }
                            }) {
                                HStack {
                                    Text(selectedCountry)
                                        .font(.clashDisplayBodyTemp(size: 18))
                                        .foregroundColor(.primary)

                                    Spacer()

                                    Image(systemName: showingCountryPicker ? "chevron.up" : "chevron.down")
                                        .font(.clashDisplayBodyTemp(size: 14))
                                        .foregroundColor(.secondary)
                                }
                                .padding(.horizontal, 20)
                                .padding(.vertical, 16)
                                .background(
                                    RoundedRectangle(cornerRadius: 16)
                                        .fill(Color(.systemBackground))
                                        .shadow(color: .black.opacity(0.08), radius: 8, x: 0, y: 4)
                                )
                            }
                            .padding(.horizontal, 32)

                            // Country Picker
                            if showingCountryPicker {
                                VStack(spacing: 0) {
                                    // Search field
                                    HStack {
                                        Image(systemName: "magnifyingglass")
                                            .foregroundColor(.secondary)

                                        TextField("Search countries", text: $searchText)
                                            .font(.clashDisplayBodyTemp(size: 16))
                                            .autocorrectionDisabled()

                                        if !searchText.isEmpty {
                                            Button(action: {
                                                searchText = ""
                                            }) {
                                                Image(systemName: "xmark.circle.fill")
                                                    .foregroundColor(.secondary)
                                            }
                                        }
                                    }
                                    .padding(.horizontal, 16)
                                    .padding(.vertical, 12)
                                    .background(Color(.systemGray6))
                                    .cornerRadius(12)
                                    .padding(.horizontal, 16)
                                    .padding(.top, 12)

                                    // Country list
                                    ScrollView {
                                        VStack(spacing: 0) {
                                            ForEach(filteredCountries, id: \.self) { country in
                                                Button(action: {
                                                    HapticManager.shared.light()
                                                    withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                                                        selectedCountry = country
                                                        showingCountryPicker = false
                                                        searchText = ""
                                                    }
                                                }) {
                                                    HStack {
                                                        Text(country)
                                                            .font(.clashDisplayBodyTemp(size: 16))
                                                            .foregroundColor(.primary)

                                                        Spacer()

                                                        if selectedCountry == country {
                                                            Image(systemName: "checkmark")
                                                                .foregroundColor(.reelEatsAccent)
                                                                .font(.clashDisplayBodyTemp(size: 16))
                                                        }
                                                    }
                                                    .padding(.horizontal, 20)
                                                    .padding(.vertical, 14)
                                                    .background(selectedCountry == country ? Color.reelEatsAccent.opacity(0.1) : Color.clear)
                                                }

                                                Divider()
                                                    .padding(.leading, 20)
                                            }
                                        }
                                    }
                                    .frame(height: 200)
                                }
                                .background(
                                    RoundedRectangle(cornerRadius: 16)
                                        .fill(Color(.systemBackground))
                                        .shadow(color: .black.opacity(0.12), radius: 16, x: 0, y: 8)
                                )
                                .padding(.horizontal, 32)
                                .padding(.top, 8)
                                .transition(.scale.combined(with: .opacity))
                            }
                        }
                        .opacity(isAnimating ? 1.0 : 0.0)
                        .offset(y: isAnimating ? 0 : 30)
                        .animation(.spring(response: 0.8, dampingFraction: 0.8).delay(0.5), value: isAnimating)

                        Spacer()
                            .frame(height: 28)

                        // Gender Selection
                        VStack(alignment: .leading, spacing: 12) {
                            Text("Gender")
                                .font(.clashDisplayButtonTemp(size: 16))
                                .foregroundColor(.secondary)
                                .padding(.horizontal, 32)

                            ScrollView(.horizontal, showsIndicators: false) {
                                HStack(spacing: 12) {
                                    ForEach(genders, id: \.self) { gender in
                                        Button(action: {
                                            HapticManager.shared.light()
                                            withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                                                selectedGender = gender
                                            }
                                        }) {
                                            Text(gender)
                                                .font(.clashDisplayButtonTemp(size: 15))
                                                .foregroundColor(selectedGender == gender ? .white : .primary)
                                                .padding(.horizontal, 20)
                                                .padding(.vertical, 12)
                                                .background(
                                                    RoundedRectangle(cornerRadius: 20)
                                                        .fill(selectedGender == gender ? Color.reelEatsAccent : Color(.systemGray6))
                                                )
                                        }
                                    }
                                }
                                .padding(.horizontal, 32)
                            }
                        }
                        .opacity(isAnimating ? 1.0 : 0.0)
                        .offset(y: isAnimating ? 0 : 30)
                        .animation(.spring(response: 0.8, dampingFraction: 0.8).delay(0.6), value: isAnimating)

                        Spacer()
                            .frame(height: 28)

                        // Date of Birth Selection
                        VStack(alignment: .leading, spacing: 12) {
                            Text("Date of Birth")
                                .font(.clashDisplayButtonTemp(size: 16))
                                .foregroundColor(.secondary)
                                .padding(.horizontal, 32)

                            DatePicker(
                                "",
                                selection: $dateOfBirth,
                                in: ...Date(),
                                displayedComponents: .date
                            )
                            .datePickerStyle(.wheel)
                            .labelsHidden()
                            .padding(.horizontal, 32)
                            .tint(.reelEatsAccent)
                        }
                        .opacity(isAnimating ? 1.0 : 0.0)
                        .offset(y: isAnimating ? 0 : 30)
                        .animation(.spring(response: 0.8, dampingFraction: 0.8).delay(0.7), value: isAnimating)

                        Spacer()
                            .frame(height: 40)

                        // Continue button
                        TutorialButton(
                            title: "Get Started",
                            action: onNext,
                            isVisible: isAnimating
                        )
                        .animation(.spring(response: 0.8, dampingFraction: 0.8).delay(0.9), value: isAnimating)

                        Spacer()
                            .frame(height: geometry.safeAreaInsets.bottom + 50)
                    }
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

// MARK: - Toggle Button Component

struct ToggleButton: View {
    let title: String
    let isSelected: Bool
    let action: () -> Void

    var body: some View {
        Button(action: {
            HapticManager.shared.light()
            action()
        }) {
            Text(title)
                .font(.clashDisplayButtonTemp(size: 16))
                .foregroundColor(isSelected ? .white : .primary)
                .padding(.horizontal, 24)
                .padding(.vertical, 12)
                .frame(maxWidth: .infinity)
                .background(
                    RoundedRectangle(cornerRadius: 12)
                        .fill(isSelected ? Color.reelEatsAccent : Color(.systemGray6))
                )
        }
    }
}

// MARK: - MascotView is defined in CompleteOnboarding.swift

#Preview {
    PostOnboardingTutorialCoordinator()
        .environmentObject(RestaurantStore())
}