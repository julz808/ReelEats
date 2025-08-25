import SwiftUI
import MapKit

// MARK: - Loading Dots Animation
struct LoadingDotsView: View {
    @State private var animationOffset: [CGFloat] = [0, 0, 0]
    
    var body: some View {
        HStack(spacing: 8) {
            ForEach(0..<3, id: \.self) { index in
                Circle()
                    .fill(Color(hex: "FF6B6B"))
                    .frame(width: 12, height: 12)
                    .offset(y: animationOffset[index])
                    .animation(
                        Animation
                            .easeInOut(duration: 0.6)
                            .repeatForever()
                            .delay(Double(index) * 0.2),
                        value: animationOffset[index]
                    )
            }
        }
        .onAppear {
            for i in 0..<3 {
                animationOffset[i] = -10
            }
        }
    }
}

// MARK: - Models
struct MockRestaurant: Identifiable, Equatable {
    let id = UUID()
    let name: String
    let address: String
    let imageUrl: String
    let detected: Bool
    var isSelected: Bool = true
    
    static func == (lhs: MockRestaurant, rhs: MockRestaurant) -> Bool {
        return lhs.id == rhs.id
    }
}

struct SearchResult: Identifiable {
    let id = UUID()
    let name: String
    let address: String
    var isSelected: Bool = false
}

// MARK: - Main Instagram Mock View
struct InstagramMockView: View {
    @Environment(\.dismiss) var dismiss
    @State private var showingShareSheet = false
    @State private var shareFlowState: ShareFlowState = .instagram
    @State private var selectedRestaurants: [MockRestaurant] = []
    @State private var searchResults: [SearchResult] = []
    @State private var searchText = ""
    @State private var isSearchExpanded = false
    @State private var showSuccessMessage = false
    
    enum ShareFlowState: Equatable {
        case instagram
        case shareSheet
        case loading
        case successDetected(MockRestaurant)
        case failureNoMatch
        case searchExpanded
        case confirmation
        
        static func == (lhs: ShareFlowState, rhs: ShareFlowState) -> Bool {
            switch (lhs, rhs) {
            case (.instagram, .instagram),
                 (.shareSheet, .shareSheet),
                 (.loading, .loading),
                 (.failureNoMatch, .failureNoMatch),
                 (.searchExpanded, .searchExpanded),
                 (.confirmation, .confirmation):
                return true
            case (.successDetected(let lhsRestaurant), .successDetected(let rhsRestaurant)):
                return lhsRestaurant.id == rhsRestaurant.id
            default:
                return false
            }
        }
    }
    
    // Vue de Monde mock data
    let vueDeMonde = MockRestaurant(
        name: "Vue de Monde",
        address: "Rialto Tower, 525 Collins St, Melbourne",
        imageUrl: "restaurant_image",
        detected: true
    )
    
    // Mock search results
    let mockSearchData = [
        SearchResult(name: "Vue de Monde", address: "Rialto Tower, 525 Collins St, Melbourne"),
        SearchResult(name: "Attica", address: "74 Glen Eira Rd, Ripponlea VIC"),
        SearchResult(name: "Flower Drum", address: "17 Market Ln, Melbourne VIC"),
        SearchResult(name: "Gimlet", address: "386 Little Collins St, Melbourne"),
        SearchResult(name: "Lune Croissanterie", address: "119 Rose St, Fitzroy VIC")
    ]
    
    var body: some View {
        ZStack {
            // Instagram Background
            instagramPostView
            
            // Share Sheet Modal
            if shareFlowState != .instagram {
                shareSheetModal
            }
            
            // Success Message
            if showSuccessMessage {
                successMessageOverlay
            }
        }
        .animation(.spring(response: 0.4, dampingFraction: 0.8), value: shareFlowState)
        .animation(.spring(response: 0.3, dampingFraction: 0.9), value: showSuccessMessage)
    }
    
    // MARK: - Instagram Post View
    var instagramPostView: some View {
        VStack(spacing: 0) {
            // Instagram Header
            HStack {
                Button(action: { dismiss() }) {
                    Image(systemName: "chevron.left")
                        .font(.system(size: 20, weight: .medium))
                        .foregroundColor(.black)
                }
                
                Spacer()
                
                Text("Instagram")
                    .font(.system(size: 17, weight: .semibold))
                
                Spacer()
                
                Image(systemName: "paperplane")
                    .font(.system(size: 20))
                    .foregroundColor(.black)
            }
            .padding(.horizontal)
            .padding(.vertical, 12)
            .background(Color.white)
            
            ScrollView {
                VStack(spacing: 0) {
                    // Post Header
                    HStack {
                        Circle()
                            .fill(
                                LinearGradient(
                                    colors: [.orange, .pink, .purple],
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                )
                            )
                            .frame(width: 32, height: 32)
                        
                        VStack(alignment: .leading, spacing: 0) {
                            Text("melbournefoodie")
                                .font(.system(size: 14, weight: .semibold))
                            Text("Melbourne, Victoria")
                                .font(.system(size: 11))
                                .foregroundColor(.gray)
                        }
                        
                        Spacer()
                        
                        Image(systemName: "ellipsis")
                            .font(.system(size: 14))
                    }
                    .padding(.horizontal, 12)
                    .padding(.vertical, 8)
                    
                    // Post Image
                    ZStack {
                        Rectangle()
                            .fill(
                                LinearGradient(
                                    colors: [Color(hex: "2C3E50"), Color(hex: "3498DB")],
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                )
                            )
                            .aspectRatio(1, contentMode: .fit)
                        
                        VStack(spacing: 8) {
                            Image(systemName: "fork.knife.circle.fill")
                                .font(.system(size: 60))
                                .foregroundColor(.white.opacity(0.9))
                            
                            Text("Vue de Monde")
                                .font(.system(size: 24, weight: .bold))
                                .foregroundColor(.white)
                            
                            Text("Fine Dining Experience")
                                .font(.system(size: 14))
                                .foregroundColor(.white.opacity(0.8))
                        }
                    }
                    
                    // Action Buttons
                    HStack(spacing: 16) {
                        Image(systemName: "heart")
                            .font(.system(size: 24))
                        
                        Image(systemName: "bubble.right")
                            .font(.system(size: 24))
                        
                        Button(action: {
                            showingShareSheet = true
                            shareFlowState = .shareSheet
                        }) {
                            Image(systemName: "paperplane")
                                .font(.system(size: 24))
                                .foregroundColor(.black)
                        }
                        
                        Spacer()
                        
                        Image(systemName: "bookmark")
                            .font(.system(size: 24))
                    }
                    .padding(.horizontal, 12)
                    .padding(.vertical, 12)
                    
                    // Post Caption
                    VStack(alignment: .leading, spacing: 4) {
                        Text("12,543 likes")
                            .font(.system(size: 14, weight: .semibold))
                        
                        HStack(alignment: .top, spacing: 4) {
                            Text("melbournefoodie")
                                .font(.system(size: 14, weight: .semibold))
                            Text("Incredible dining experience at Vue de Monde! The 15-course degustation was absolutely mind-blowing 🍽️✨")
                                .font(.system(size: 14))
                        }
                        
                        Text("View all 234 comments")
                            .font(.system(size: 14))
                            .foregroundColor(.gray)
                            .padding(.top, 4)
                        
                        Text("2 hours ago")
                            .font(.system(size: 11))
                            .foregroundColor(.gray)
                            .padding(.top, 2)
                    }
                    .padding(.horizontal, 12)
                    .frame(maxWidth: .infinity, alignment: .leading)
                }
            }
            .background(Color.white)
        }
        .background(Color.white)
    }
    
    // MARK: - Share Sheet Modal
    var shareSheetModal: some View {
        ZStack {
            // Dimmed background
            Color.black.opacity(0.4)
                .ignoresSafeArea()
                .onTapGesture {
                    if shareFlowState == .shareSheet {
                        shareFlowState = .instagram
                    }
                }
            
            VStack(spacing: 0) {
                Spacer()
                
                switch shareFlowState {
                case .shareSheet:
                    shareSheetView
                case .loading:
                    loadingView
                case .successDetected(let restaurant):
                    successView(restaurant: restaurant)
                case .failureNoMatch:
                    failureView
                case .searchExpanded:
                    expandedSearchView
                case .confirmation:
                    confirmationView
                default:
                    EmptyView()
                }
            }
        }
    }
    
    // MARK: - Share Sheet View
    var shareSheetView: some View {
        VStack(spacing: 0) {
            // Handle
            RoundedRectangle(cornerRadius: 2.5)
                .fill(Color.gray.opacity(0.4))
                .frame(width: 36, height: 5)
                .padding(.top, 8)
                .padding(.bottom, 20)
            
            // Share options grid
            VStack(spacing: 24) {
                // First row of apps
                HStack(spacing: 20) {
                    shareAppIcon(name: "ReelEats (Success)", icon: "fork.knife.circle.fill", color: Color(hex: "FF6B6B")) {
                        shareFlowState = .loading
                        DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                            selectedRestaurants = [vueDeMonde]
                            shareFlowState = .successDetected(vueDeMonde)
                        }
                    }
                    
                    shareAppIcon(name: "ReelEats (Fail)", icon: "fork.knife.circle", color: .gray) {
                        shareFlowState = .loading
                        DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                            shareFlowState = .failureNoMatch
                        }
                    }
                    
                    shareAppIcon(name: "Messages", icon: "message.fill", color: .green)
                    shareAppIcon(name: "Mail", icon: "envelope.fill", color: .blue)
                }
                
                // Second row
                HStack(spacing: 20) {
                    shareAppIcon(name: "WhatsApp", icon: "phone.fill", color: .green)
                    shareAppIcon(name: "Twitter", icon: "bird.fill", color: .cyan)
                    shareAppIcon(name: "Facebook", icon: "f.circle.fill", color: .blue)
                    shareAppIcon(name: "More", icon: "ellipsis.circle.fill", color: .gray)
                }
            }
            .padding(.horizontal, 20)
            
            Divider()
                .padding(.vertical, 20)
            
            // Action buttons
            VStack(spacing: 0) {
                ShareActionRow(icon: "link", title: "Copy Link")
                ShareActionRow(icon: "safari", title: "Open in Safari")
                ShareActionRow(icon: "plus.circle", title: "Add to Reading List")
            }
            .padding(.horizontal, 20)
            
            // Cancel button
            Button(action: {
                shareFlowState = .instagram
            }) {
                Text("Cancel")
                    .font(.system(size: 17))
                    .foregroundColor(.blue)
                    .frame(maxWidth: .infinity)
                    .frame(height: 56)
                    .background(Color(.systemGray6))
                    .cornerRadius(14)
            }
            .padding(.horizontal, 20)
            .padding(.vertical, 20)
        }
        .background(Color.white)
        .cornerRadius(20, corners: [.topLeft, .topRight])
    }
    
    // MARK: - Loading View
    var loadingView: some View {
        VStack(spacing: 24) {
            // Loading dots animation
            LoadingDotsView()
            
            Text("Finding this spot...")
                .font(.newYorkButton())
                .foregroundColor(.gray)
        }
        .frame(height: UIScreen.main.bounds.height * 0.5)
        .frame(maxWidth: .infinity)
        .background(Color.white)
        .cornerRadius(20, corners: [.topLeft, .topRight])
    }
    
    // MARK: - Success View
    func successView(restaurant: MockRestaurant) -> some View {
        VStack(spacing: 0) {
            // Handle
            RoundedRectangle(cornerRadius: 2.5)
                .fill(Color.gray.opacity(0.4))
                .frame(width: 36, height: 5)
                .padding(.top, 8)
            
            // Close button
            HStack {
                Spacer()
                Button(action: {
                    shareFlowState = .instagram
                }) {
                    Image(systemName: "xmark")
                        .font(.system(size: 16, weight: .medium))
                        .foregroundColor(.gray)
                        .frame(width: 30, height: 30)
                        .background(Color(.systemGray6))
                        .clipShape(Circle())
                }
            }
            .padding(.horizontal, 20)
            .padding(.top, 12)
            
            ScrollView {
                VStack(spacing: 20) {
                    // Detected restaurant card
                    HStack(spacing: 12) {
                        // Restaurant image
                        RoundedRectangle(cornerRadius: 8)
                            .fill(
                                LinearGradient(
                                    colors: [Color(hex: "FF6B6B"), Color(hex: "4ECDC4")],
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                )
                            )
                            .frame(width: 60, height: 60)
                            .overlay(
                                Image(systemName: "fork.knife")
                                    .font(.system(size: 24))
                                    .foregroundColor(.white)
                            )
                        
                        VStack(alignment: .leading, spacing: 4) {
                            Text(restaurant.name)
                                .font(.newYorkRestaurantName())
                                .foregroundColor(.primary)
                            
                            Text(restaurant.address)
                                .font(.newYorkSecondary())
                                .foregroundColor(.gray)
                                .lineLimit(2)
                            
                        }
                        
                        Spacer()
                        
                        // Selection circle
                        Button(action: {
                            if let index = selectedRestaurants.firstIndex(where: { $0.id == restaurant.id }) {
                                selectedRestaurants[index].isSelected.toggle()
                            }
                        }) {
                            Circle()
                                .strokeBorder(Color(hex: "FF6B6B"), lineWidth: 2)
                                .background(
                                    Circle().fill(restaurant.isSelected ? Color(hex: "FF6B6B") : Color.clear)
                                )
                                .frame(width: 24, height: 24)
                                .overlay(
                                    Image(systemName: "checkmark")
                                        .font(.system(size: 12, weight: .bold))
                                        .foregroundColor(.white)
                                        .opacity(restaurant.isSelected ? 1 : 0)
                                )
                        }
                    }
                    .padding(.horizontal, 20)
                    
                    // Search for different place
                    Button(action: {
                        searchResults = mockSearchData
                        shareFlowState = .searchExpanded
                    }) {
                        HStack {
                            Image(systemName: "magnifyingglass")
                                .font(.system(size: 14))
                                .foregroundColor(.gray)
                            
                            Text("find a different place")
                                .font(.newYorkButton())
                                .foregroundColor(.gray)
                            
                            Spacer()
                        }
                        .padding(.horizontal, 16)
                        .padding(.vertical, 12)
                        .background(Color(.systemGray6))
                        .cornerRadius(10)
                    }
                    .padding(.horizontal, 20)
                }
                .padding(.top, 20)
            }
            
            // Add button
            Button(action: {
                showSuccessMessage = true
                DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                    showSuccessMessage = false
                    shareFlowState = .instagram
                }
            }) {
                Text("add 1 place")
                    .font(.newYorkButton())
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .frame(height: 50)
                    .background(Color.black)
                    .cornerRadius(25)
            }
            .padding(.horizontal, 20)
            .padding(.vertical, 20)
        }
        .frame(height: UIScreen.main.bounds.height * 0.5)
        .background(Color.white)
        .cornerRadius(20, corners: [.topLeft, .topRight])
    }
    
    // MARK: - Failure View
    var failureView: some View {
        VStack(spacing: 0) {
            // Handle
            RoundedRectangle(cornerRadius: 2.5)
                .fill(Color.gray.opacity(0.4))
                .frame(width: 36, height: 5)
                .padding(.top, 8)
            
            // Close button
            HStack {
                Spacer()
                Button(action: {
                    shareFlowState = .instagram
                }) {
                    Image(systemName: "xmark")
                        .font(.system(size: 16, weight: .medium))
                        .foregroundColor(.gray)
                        .frame(width: 30, height: 30)
                        .background(Color(.systemGray6))
                        .clipShape(Circle())
                }
            }
            .padding(.horizontal, 20)
            .padding(.top, 12)
            
            Spacer()
            
            VStack(spacing: 24) {
                // Mascot/Icon
                ZStack {
                    Circle()
                        .fill(Color(hex: "FF6B6B").opacity(0.1))
                        .frame(width: 80, height: 80)
                    
                    Text("👀")
                        .font(.system(size: 40))
                }
                
                Text("we couldn't find the place")
                    .font(.newYorkHeader(size: 18))
                    .foregroundColor(.primary)
                
                // Search bar
                Button(action: {
                    searchResults = mockSearchData
                    shareFlowState = .searchExpanded
                }) {
                    HStack {
                        Image(systemName: "magnifyingglass")
                            .font(.system(size: 14))
                            .foregroundColor(.gray)
                        
                        Text("search for it yourself")
                            .font(.newYorkButton())
                            .foregroundColor(.gray)
                        
                        Spacer()
                    }
                    .padding(.horizontal, 16)
                    .padding(.vertical, 12)
                    .background(Color(.systemGray6))
                    .cornerRadius(10)
                }
                .padding(.horizontal, 20)
            }
            
            Spacer()
        }
        .frame(height: UIScreen.main.bounds.height * 0.5)
        .background(Color.white)
        .cornerRadius(20, corners: [.topLeft, .topRight])
    }
    
    // MARK: - Expanded Search View
    var expandedSearchView: some View {
        VStack(spacing: 0) {
            // Search Header
            HStack {
                Button(action: {
                    if selectedRestaurants.isEmpty {
                        shareFlowState = .failureNoMatch
                    } else {
                        shareFlowState = .successDetected(selectedRestaurants.first!)
                    }
                }) {
                    Image(systemName: "chevron.left")
                        .font(.system(size: 20, weight: .medium))
                        .foregroundColor(.black)
                }
                
                HStack {
                    Image(systemName: "magnifyingglass")
                        .font(.system(size: 14))
                        .foregroundColor(.gray)
                    
                    TextField("Search restaurants", text: $searchText)
                        .font(.newYorkButton())
                    
                    if !searchText.isEmpty {
                        Button(action: { searchText = "" }) {
                            Image(systemName: "xmark.circle.fill")
                                .font(.system(size: 14))
                                .foregroundColor(.gray)
                        }
                    }
                }
                .padding(.horizontal, 12)
                .padding(.vertical, 8)
                .background(Color(.systemGray6))
                .cornerRadius(10)
                .padding(.leading, 8)
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 12)
            .background(Color.white)
            
            
            Divider()
            
            // Search Results
            ScrollView {
                VStack(spacing: 0) {
                    ForEach(searchResults.indices, id: \.self) { index in
                        HStack(spacing: 12) {
                            Image(systemName: "mappin.circle.fill")
                                .font(.system(size: 24))
                                .foregroundColor(Color(hex: "FF6B6B").opacity(0.8))
                            
                            VStack(alignment: .leading, spacing: 2) {
                                Text(searchResults[index].name)
                                    .font(.newYorkRestaurantName())
                                    .foregroundColor(.primary)
                                
                                Text(searchResults[index].address)
                                    .font(.newYorkSecondary())
                                    .foregroundColor(.gray)
                            }
                            
                            Spacer()
                            
                            Button(action: {
                                searchResults[index].isSelected.toggle()
                                if searchResults[index].isSelected {
                                    selectedRestaurants.append(
                                        MockRestaurant(
                                            name: searchResults[index].name,
                                            address: searchResults[index].address,
                                            imageUrl: "",
                                            detected: false
                                        )
                                    )
                                } else {
                                    selectedRestaurants.removeAll { $0.name == searchResults[index].name }
                                }
                            }) {
                                Circle()
                                    .strokeBorder(Color(hex: "FF6B6B"), lineWidth: 2)
                                    .background(
                                        Circle().fill(searchResults[index].isSelected ? Color(hex: "FF6B6B") : Color.clear)
                                    )
                                    .frame(width: 24, height: 24)
                                    .overlay(
                                        Image(systemName: "checkmark")
                                            .font(.system(size: 12, weight: .bold))
                                            .foregroundColor(.white)
                                            .opacity(searchResults[index].isSelected ? 1 : 0)
                                    )
                            }
                        }
                        .padding(.horizontal, 16)
                        .padding(.vertical, 12)
                        
                        if index < searchResults.count - 1 {
                            Divider()
                                .padding(.leading, 52)
                        }
                    }
                }
            }
            
            
            // Add button
            if !selectedRestaurants.isEmpty {
                Button(action: {
                    showSuccessMessage = true
                    DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                        showSuccessMessage = false
                        shareFlowState = .instagram
                    }
                }) {
                    Text("add \(selectedRestaurants.count) place\(selectedRestaurants.count > 1 ? "s" : "")")
                        .font(.newYorkButton())
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .frame(height: 50)
                        .background(Color.black)
                        .cornerRadius(25)
                }
                .padding(.horizontal, 20)
                .padding(.vertical, 20)
            }
        }
        .frame(maxHeight: .infinity)
        .background(Color.white)
    }
    
    // MARK: - Confirmation View
    var confirmationView: some View {
        EmptyView()
    }
    
    // MARK: - Success Message Overlay
    var successMessageOverlay: some View {
        VStack {
            Spacer()
            
            HStack(spacing: 12) {
                Image(systemName: "checkmark.circle.fill")
                    .font(.system(size: 24))
                    .foregroundColor(.white)
                
                Text("Successfully added to ReelEats!")
                    .font(.newYorkButton())
                    .foregroundColor(.white)
            }
            .padding(.horizontal, 20)
            .padding(.vertical, 16)
            .background(Color.black.opacity(0.85))
            .cornerRadius(12)
            .padding(.bottom, 100)
        }
    }
    
    // MARK: - Helper Views
    func shareAppIcon(name: String, icon: String, color: Color, action: (() -> Void)? = nil) -> some View {
        Button(action: { action?() }) {
            VStack(spacing: 8) {
                ZStack {
                    Circle()
                        .fill(color.opacity(0.1))
                        .frame(width: 60, height: 60)
                    
                    Image(systemName: icon)
                        .font(.system(size: 24))
                        .foregroundColor(color)
                }
                
                Text(name)
                    .font(.system(size: 11))
                    .foregroundColor(.primary)
                    .lineLimit(2)
                    .multilineTextAlignment(.center)
                    .frame(width: 70)
            }
        }
    }
}

struct ShareActionRow: View {
    let icon: String
    let title: String
    
    var body: some View {
        HStack {
            Image(systemName: icon)
                .font(.system(size: 20))
                .foregroundColor(.blue)
                .frame(width: 24)
            
            Text(title)
                .font(.system(size: 17))
                .foregroundColor(.primary)
            
            Spacer()
        }
        .padding(.vertical, 12)
    }
}

// MARK: - Color Extension
extension Color {
    init(hex: String) {
        let hex = hex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var int: UInt64 = 0
        Scanner(string: hex).scanHexInt64(&int)
        let a, r, g, b: UInt64
        switch hex.count {
        case 3:
            (a, r, g, b) = (255, (int >> 8) * 17, (int >> 4 & 0xF) * 17, (int & 0xF) * 17)
        case 6:
            (a, r, g, b) = (255, int >> 16, int >> 8 & 0xFF, int & 0xFF)
        case 8:
            (a, r, g, b) = (int >> 24, int >> 16 & 0xFF, int >> 8 & 0xFF, int & 0xFF)
        default:
            (a, r, g, b) = (255, 0, 0, 0)
        }
        
        self.init(
            .sRGB,
            red: Double(r) / 255,
            green: Double(g) / 255,
            blue: Double(b) / 255,
            opacity: Double(a) / 255
        )
    }
}