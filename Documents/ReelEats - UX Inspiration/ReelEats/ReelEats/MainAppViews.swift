import SwiftUI
import MapKit

// MARK: - Extensions

extension View {
    func cornerRadius(_ radius: CGFloat, corners: UIRectCorner) -> some View {
        clipShape(RoundedCorner(radius: radius, corners: corners))
    }
}

struct RoundedCorner: Shape {
    var radius: CGFloat = .infinity
    var corners: UIRectCorner = .allCorners
    
    func path(in rect: CGRect) -> Path {
        let path = UIBezierPath(
            roundedRect: rect,
            byRoundingCorners: corners,
            cornerRadii: CGSize(width: radius, height: radius)
        )
        return Path(path.cgPath)
    }
}

// MARK: - Main App Views

// MARK: - Saved Tab View (Matches Screenshot Exactly)

struct SavedTabView: View {
    @EnvironmentObject var store: RestaurantStore
    @State private var selectedCategory: RestaurantCategory? = .all
    @State private var showingDetail = false
    @State private var selectedRestaurant: Restaurant?
    @State private var isAnimating = false
    @State private var selectedView: SavedViewType = .allSpots
    @State private var selectedCollection: Collection?
    @State private var showingProfile = false
    
    enum SavedViewType: String, CaseIterable {
        case allSpots = "All Spots"
        case collections = "Collections"
    }
    
    var body: some View {
        GeometryReader { geometry in
            VStack(spacing: 0) {
                // Header with logo and profile - positioned at very top
                VStack(spacing: 0) {
                    HStack {
                        // ReelEats logo with mascot
                        HStack(spacing: 8) {
                            MascotView(size: 28)
                            
                            Text("ReelEats")
                                .font(.system(size: 22, weight: .bold))
                                .foregroundColor(.primary)
                        }
                        
                        Spacer()
                        
                        // Profile button with person icon
                        Button(action: {
                            HapticManager.shared.light()
                            showingProfile = true
                        }) {
                            ZStack {
                                Circle()
                                    .fill(
                                        LinearGradient(
                                            colors: [Color.blue, Color.purple, Color.cyan],
                                            startPoint: .topLeading,
                                            endPoint: .bottomTrailing
                                        )
                                    )
                                    .frame(width: 32, height: 32)
                                
                                Image(systemName: "person.fill")
                                    .font(.system(size: 14, weight: .medium))
                                    .foregroundColor(.white)
                            }
                        }
                    }
                    .padding(.horizontal, 20)
                    .padding(.top, 50)
                    
                    // View toggle (All Spots / Collections)
                    HStack(spacing: 0) {
                        ForEach(SavedViewType.allCases, id: \.self) { viewType in
                            Button(action: {
                                HapticManager.shared.selection()
                                withAnimation(.easeInOut(duration: 0.2)) {
                                    selectedView = viewType
                                }
                            }) {
                                Text(viewType.rawValue)
                                    .font(.system(size: 16, weight: .semibold))
                                    .foregroundColor(selectedView == viewType ? .primary : .secondary)
                                    .frame(maxWidth: .infinity)
                                    .padding(.vertical, 8)
                            }
                        }
                    }
                    .background(
                        GeometryReader { geometry in
                            RoundedRectangle(cornerRadius: 2)
                                .fill(Color.primary)
                                .frame(width: geometry.size.width / 2, height: 2)
                                .offset(x: selectedView == .allSpots ? 0 : geometry.size.width / 2)
                                .animation(.easeInOut(duration: 0.2), value: selectedView)
                        }
                        .frame(height: 2),
                        alignment: .bottom
                    )
                    .padding(.horizontal, 20)
                    .padding(.top, 16)
                    
                    // New Airbnb-style filters - only show for All Spots view
                    if selectedView == .allSpots {
                        FilterBar()
                            .padding(.top, 8)
                    }
                }
                .background(Color(.systemBackground))
                
                // Content area
                if selectedView == .allSpots {
                    if filteredRestaurants.isEmpty {
                        EmptyStateView()
                            .transition(.opacity)
                    } else {
                        RestaurantListView(
                            restaurants: filteredRestaurants,
                            onRestaurantTap: { restaurant in
                                selectedRestaurant = restaurant
                                showingDetail = true
                            }
                        )
                        .transition(.opacity)
                    }
                } else {
                    CollectionsGridView(
                        collections: store.collections,
                        onCollectionTap: { collection in
                            selectedCollection = collection
                        }
                    )
                    .transition(.opacity)
                }
            }
        }
        .navigationBarHidden(true)
        .edgesIgnoringSafeArea(.top)
        .sheet(isPresented: $showingDetail) {
            if let restaurant = selectedRestaurant {
                RestaurantDetailView(restaurant: restaurant)
                    .environmentObject(store)
            }
        }
        .fullScreenCover(item: $selectedCollection) { collection in
            CollectionDetailView(collection: collection)
                .environmentObject(store)
        }
        .sheet(isPresented: $showingProfile) {
            ProfileTabView()
                .environmentObject(store)
        }
        .onAppear {
            withAnimation(.easeInOut(duration: 0.6)) {
                isAnimating = true
            }
        }
    }
    
    private var filteredRestaurants: [Restaurant] {
        guard let category = selectedCategory, category != .all else { return store.savedRestaurants }
        return store.savedRestaurants.filter { $0.category == category }
    }
}

// MARK: - Category Filter Button

struct CategoryFilterButton: View {
    let category: RestaurantCategory
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            HStack(spacing: 6) {
                Image(systemName: category.icon)
                    .font(.system(size: 14, weight: .medium))
                    .foregroundColor(isSelected ? .white : category.color)
                
                Text(category.rawValue)
                    .font(.system(size: 14, weight: .medium))
                    .foregroundColor(isSelected ? .white : .primary)
            }
            .padding(.horizontal, 14)
            .padding(.vertical, 8)
            .background(
                RoundedRectangle(cornerRadius: 18)
                    .fill(isSelected ? category.color : Color(.systemGray6))
            )
        }
        .buttonStyle(PlainButtonStyle())
    }
}

// MARK: - Empty State View (Matching Screenshot)

struct EmptyStateView: View {
    @EnvironmentObject var store: RestaurantStore
    
    var body: some View {
        VStack(spacing: 24) {
            Spacer()
            
            // Get Started tutorial card
            VStack(spacing: 16) {
                HStack {
                    Text("Get Started")
                        .font(.system(size: 16, weight: .medium))
                        .foregroundColor(.orange)
                    
                    Spacer()
                    
                    // Loading indicator
                    ProgressView()
                        .scaleEffect(0.8)
                        .tint(.black)
                }
                
                VStack(alignment: .leading, spacing: 8) {
                    Text("Import 3 posts")
                        .font(.system(size: 24, weight: .bold))
                        .foregroundColor(.primary)
                    
                    Text("How to share from other apps")
                        .font(.system(size: 16))
                        .foregroundColor(.secondary)
                }
            }
            .padding(.horizontal, 20)
            .padding(.vertical, 24)
            .background(
                RoundedRectangle(cornerRadius: 16)
                    .fill(Color(.systemGray6))
            )
            .padding(.horizontal, 20)
            
            Spacer()
            
            // Demo restaurant cards
            LazyVStack(spacing: 16) {
                ForEach(Melbourne.demoRestaurants.prefix(3), id: \.id) { restaurant in
                    DemoRestaurantCard(restaurant: restaurant)
                        .onTapGesture {
                            HapticManager.shared.success()
                            store.saveRestaurant(restaurant)
                        }
                }
            }
            .padding(.horizontal, 20)
            
            Spacer()
        }
    }
}

// MARK: - Collections Grid View

struct CollectionsGridView: View {
    let collections: [Collection]
    let onCollectionTap: (Collection) -> Void
    
    var body: some View {
        ScrollView {
            LazyVGrid(columns: Array(repeating: GridItem(.flexible(), spacing: 16), count: 2), spacing: 16) {
                ForEach(collections) { collection in
                    CollectionAlbumCard(collection: collection)
                        .onTapGesture {
                            HapticManager.shared.medium()
                            onCollectionTap(collection)
                        }
                }
            }
            .padding(.horizontal, 20)
            .padding(.top, 20)
            .padding(.bottom, 100) // Space for floating button
        }
    }
}

// MARK: - Collection Detail View (Spotify-like Full Screen)

struct CollectionDetailView: View {
    let collection: Collection
    @EnvironmentObject var store: RestaurantStore
    @Environment(\.dismiss) private var dismiss
    @State private var showingAddSpots = false
    @State private var showingShareSheet = false
    @State private var showingEditCollection = false
    @State private var selectedCategory: RestaurantCategory? = nil
    @State private var selectedRestaurant: Restaurant?
    @State private var showingDetail = false
    
    private var collectionSpots: [Restaurant] {
        let filtered = store.savedRestaurants.filter { restaurant in
            collection.restaurantIds.contains(restaurant.id)
        }
        
        if let category = selectedCategory {
            return filtered.filter { $0.category == category }
        }
        return filtered
    }
    
    var body: some View {
        ScrollView {
            VStack(spacing: 0) {
                // Header with back button and collection image (reduced size)
                ZStack(alignment: .topLeading) {
                    // Background gradient (reduced height)
                    LinearGradient(
                        colors: [Color.purple.opacity(0.8), Color.pink.opacity(0.8)],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                    .frame(height: 300)
                    
                    VStack(spacing: 0) {
                        // Back button
                        HStack {
                            Button(action: {
                                dismiss()
                            }) {
                                Image(systemName: "chevron.left")
                                    .font(.system(size: 20, weight: .medium))
                                    .foregroundColor(.white)
                            }
                            .padding(.top, 50)
                            .padding(.leading, 20)
                            
                            Spacer()
                        }
                        
                        Spacer()
                        
                        // Collection image (reduced size)
                        RoundedRectangle(cornerRadius: 8)
                            .fill(
                                LinearGradient(
                                    colors: [Color.purple.opacity(0.9), Color.pink.opacity(0.9)],
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                )
                            )
                            .frame(width: 180, height: 180)
                            .overlay(
                                Text(collection.name.prefix(1).uppercased())
                                    .font(.system(size: 60, weight: .bold))
                                    .foregroundColor(.white.opacity(0.8))
                            )
                            .shadow(color: .black.opacity(0.3), radius: 15, x: 0, y: 8)
                        
                        Spacer().frame(height: 20)
                    }
                }
                
                // Content section with white background (increased spacing)
                VStack(alignment: .leading, spacing: 24) {
                    VStack(alignment: .leading, spacing: 16) {
                        // Collection title (increased spacing from banner)
                        Text(collection.name)
                            .font(.system(size: 28, weight: .bold))
                            .foregroundColor(.primary)
                            .padding(.horizontal, 20)
                            .padding(.top, 8)
                        
                        // Creator and collaborators section (like Spotify)
                        HStack(spacing: 12) {
                            // Creator profile circle
                            Circle()
                                .fill(Color.orange)
                                .frame(width: 32, height: 32)
                                .overlay(
                                    Text("J")
                                        .font(.system(size: 16, weight: .bold))
                                        .foregroundColor(.white)
                                )
                            
                            // Collaborator circles (if any)
                            ForEach(0..<2, id: \.self) { index in
                                Circle()
                                    .fill(Color.gray.opacity(0.3))
                                    .frame(width: 32, height: 32)
                                    .overlay(
                                        Image(systemName: "plus")
                                            .font(.system(size: 14, weight: .medium))
                                            .foregroundColor(.gray)
                                    )
                            }
                            
                            Text("Julz")
                                .font(.system(size: 14, weight: .medium))
                                .foregroundColor(.primary)
                            
                            Spacer()
                        }
                        .padding(.horizontal, 20)
                        
                        // Spots count (like playlist duration)
                        Text("\(collectionSpots.count) spots")
                            .font(.system(size: 14))
                            .foregroundColor(.secondary)
                            .padding(.horizontal, 20)
                    }
                    
                    // Action buttons row (exactly as requested)
                    HStack(spacing: 20) {
                        // Add Collaborators (same icon as Spotify)
                        Button(action: {}) {
                            Image(systemName: "person.badge.plus")
                                .font(.system(size: 24))
                                .foregroundColor(.secondary)
                        }
                        
                        // Share button
                        Button(action: {
                            showingShareSheet = true
                        }) {
                            Image(systemName: "square.and.arrow.up")
                                .font(.system(size: 24))
                                .foregroundColor(.secondary)
                        }
                        
                        // Add button (add a new spot)
                        Button(action: {
                            showingAddSpots = true
                        }) {
                            Image(systemName: "plus")
                                .font(.system(size: 24))
                                .foregroundColor(.secondary)
                        }
                        
                        // Edit button (edit collection i.e. title, picture)
                        Button(action: {
                            showingEditCollection = true
                        }) {
                            Image(systemName: "pencil")
                                .font(.system(size: 24))
                                .foregroundColor(.secondary)
                        }
                        
                        Spacer()
                    }
                    .padding(.horizontal, 20)
                    
                    // New Airbnb-style filters
                    FilterBar()
                        .padding(.top, 8)
                    
                    // Restaurant list (exactly like All Spots)
                    VStack(spacing: 0) {
                        if collectionSpots.isEmpty {
                            VStack(spacing: 20) {
                                Text("No spots in this collection")
                                    .font(.system(size: 18, weight: .medium))
                                    .foregroundColor(.secondary)
                                
                                Button("Add Spots") {
                                    showingAddSpots = true
                                }
                                .font(.system(size: 16, weight: .semibold))
                                .foregroundColor(.white)
                                .padding(.horizontal, 20)
                                .padding(.vertical, 12)
                                .background(Color.black)
                                .cornerRadius(25)
                            }
                            .padding(.top, 50)
                        } else {
                            ForEach(collectionSpots.indices, id: \.self) { index in
                                let restaurant = collectionSpots[index]
                                
                                HStack(spacing: 12) {
                                    // Index number (like Spotify track numbers)
                                    Text("\(index + 1)")
                                        .font(.system(size: 16, weight: .medium))
                                        .foregroundColor(.secondary)
                                        .frame(width: 20, alignment: .leading)
                                    
                                    // Restaurant image
                                    AsyncImage(url: URL(string: restaurant.imageURL)) { image in
                                        image
                                            .resizable()
                                            .aspectRatio(contentMode: .fill)
                                    } placeholder: {
                                        Rectangle()
                                            .fill(restaurant.category.color.opacity(0.3))
                                            .overlay(
                                                Image(systemName: restaurant.category.icon)
                                                    .font(.system(size: 20))
                                                    .foregroundColor(restaurant.category.color)
                                            )
                                    }
                                    .frame(width: 56, height: 56)
                                    .cornerRadius(4)
                                    
                                    // Restaurant info
                                    VStack(alignment: .leading, spacing: 4) {
                                        Text(restaurant.name)
                                            .font(.system(size: 16, weight: .medium))
                                            .foregroundColor(.primary)
                                            .lineLimit(1)
                                        
                                        HStack(spacing: 8) {
                                            Text(restaurant.category.rawValue)
                                                .font(.system(size: 14))
                                                .foregroundColor(.secondary)
                                            
                                            Text("•")
                                                .font(.system(size: 14))
                                                .foregroundColor(.secondary)
                                            
                                            Text(restaurant.priceRange)
                                                .font(.system(size: 14))
                                                .foregroundColor(.secondary)
                                        }
                                    }
                                    
                                    Spacer()
                                    
                                    // Three dots menu
                                    Button(action: {}) {
                                        Image(systemName: "ellipsis")
                                            .font(.system(size: 16))
                                            .foregroundColor(.secondary)
                                    }
                                }
                                .padding(.horizontal, 20)
                                .padding(.vertical, 8)
                                .contentShape(Rectangle())
                                .onTapGesture {
                                    selectedRestaurant = restaurant
                                    showingDetail = true
                                }
                            }
                        }
                    }
                    .padding(.top, 12)
                    .padding(.bottom, 100)
                }
            }
        }
        .background(Color(.systemBackground))
        .edgesIgnoringSafeArea(.top)
        .sheet(isPresented: $showingAddSpots) {
            AddSpotView()
                .environmentObject(store)
        }
        .sheet(isPresented: $showingShareSheet) {
            Text("Share Collection")
        }
        .sheet(isPresented: $showingEditCollection) {
            Text("Edit Collection")
        }
        .sheet(isPresented: $showingDetail) {
            if let restaurant = selectedRestaurant {
                RestaurantDetailView(restaurant: restaurant)
                    .environmentObject(store)
            }
        }
    }
}
// MARK: - Custom Restaurant Options Sheet (ReelEats Style)

struct RestaurantOptionsSheet: View {
    let restaurant: Restaurant
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        VStack(spacing: 0) {
            // Handle indicator
            RoundedRectangle(cornerRadius: 2.5)
                .fill(Color(.systemGray4))
                .frame(width: 40, height: 4)
                .padding(.top, 12)
                .padding(.bottom, 20)
            
            // Restaurant header
            HStack(spacing: 12) {
                AsyncImage(url: URL(string: restaurant.imageURL)) { image in
                    image
                        .resizable()
                        .aspectRatio(contentMode: .fill)
                } placeholder: {
                    Rectangle()
                        .fill(restaurant.category.color.opacity(0.3))
                        .overlay(
                            Image(systemName: restaurant.category.icon)
                                .font(.system(size: 16))
                                .foregroundColor(restaurant.category.color)
                        )
                }
                .frame(width: 50, height: 50)
                .clipShape(RoundedRectangle(cornerRadius: 8))
                
                VStack(alignment: .leading, spacing: 4) {
                    Text(restaurant.name)
                        .font(.system(size: 16, weight: .semibold))
                        .foregroundColor(.primary)
                        .lineLimit(1)
                    
                    Text(restaurant.category.rawValue + " • " + restaurant.priceRange)
                        .font(.system(size: 14))
                        .foregroundColor(.secondary)
                }
                
                Spacer()
            }
            .padding(.horizontal, 20)
            .padding(.bottom, 30)
            
            // Options list
            VStack(spacing: 0) {
                OptionsButton(
                    icon: "square.and.arrow.up",
                    title: "Share",
                    subtitle: "Send to friends",
                    action: {
                        HapticManager.shared.medium()
                        dismiss()
                    }
                )
                
                OptionsButton(
                    icon: "folder.badge.plus",
                    title: "Add to Collection",
                    subtitle: "Save to your collections",
                    action: {
                        HapticManager.shared.medium()
                        dismiss()
                    }
                )
                
                OptionsButton(
                    icon: "calendar.badge.plus",
                    title: "Make a Booking",
                    subtitle: "Reserve a table",
                    action: {
                        HapticManager.shared.medium()
                        dismiss()
                    }
                )
                
                OptionsButton(
                    icon: "map.fill",
                    title: "View on Map",
                    subtitle: "See location",
                    action: {
                        HapticManager.shared.medium()
                        dismiss()
                    }
                )
            }
            .padding(.horizontal, 20)
            
            Spacer()
        }
        .background(Color(.systemBackground))
        .presentationDetents([.medium])
        .presentationDragIndicator(.hidden)
    }
}

struct OptionsButton: View {
    let icon: String
    let title: String
    let subtitle: String
    let action: () -> Void
    @State private var isPressed = false
    
    var body: some View {
        Button(action: {
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
            HStack(spacing: 16) {
                Circle()
                    .fill(Color(.systemGray6))
                    .frame(width: 44, height: 44)
                    .overlay(
                        Image(systemName: icon)
                            .font(.system(size: 18, weight: .medium))
                            .foregroundColor(.primary)
                    )
                
                VStack(alignment: .leading, spacing: 2) {
                    Text(title)
                        .font(.system(size: 16, weight: .medium))
                        .foregroundColor(.primary)
                    
                    Text(subtitle)
                        .font(.system(size: 14))
                        .foregroundColor(.secondary)
                }
                
                Spacer()
                
                Image(systemName: "chevron.right")
                    .font(.system(size: 14, weight: .medium))
                    .foregroundColor(.secondary)
            }
            .padding(.vertical, 16)
            .background(Color(.systemBackground))
            .scaleEffect(isPressed ? 0.98 : 1.0)
        }
        .buttonStyle(PlainButtonStyle())
    }
}

// MARK: - Airbnb-Style Spot Card

struct AirbnbStyleSpotCard: View {
    let restaurant: Restaurant
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            // Image
            AsyncImage(url: URL(string: restaurant.imageURL)) { image in
                image
                    .resizable()
                    .aspectRatio(contentMode: .fill)
            } placeholder: {
                Rectangle()
                    .fill(restaurant.category.color.opacity(0.3))
                    .overlay(
                        Image(systemName: restaurant.category.icon)
                            .font(.system(size: 30))
                            .foregroundColor(restaurant.category.color)
                    )
            }
            .frame(height: 180)
            .clipShape(RoundedRectangle(cornerRadius: 12))
            
            // Spot info
            VStack(alignment: .leading, spacing: 4) {
                Text(restaurant.name.components(separatedBy: " ").prefix(3).joined(separator: " "))
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundColor(.primary)
                    .lineLimit(2)
                
                HStack(spacing: 4) {
                    Image(systemName: "star.fill")
                        .font(.system(size: 12))
                        .foregroundColor(.yellow)
                    
                    Text(String(format: "%.1f", restaurant.rating))
                        .font(.system(size: 14))
                        .foregroundColor(.secondary)
                    
                    Text("•")
                        .font(.system(size: 14))
                        .foregroundColor(.secondary)
                    
                    Text(restaurant.category.rawValue)
                        .font(.system(size: 14))
                        .foregroundColor(.secondary)
                }
            }
        }
        .background(Color(.systemBackground))
    }
}

// MARK: - Collaborator Avatars

struct CollaboratorAvatars: View {
    private let colors: [Color] = [.blue, .green, .orange, .purple]
    
    var body: some View {
        HStack(spacing: -8) {
            ForEach(0..<min(3, colors.count), id: \.self) { index in
                Circle()
                    .fill(colors[index])
                    .frame(width: 24, height: 24)
                    .overlay(
                        Circle()
                            .stroke(Color(.systemBackground), lineWidth: 2)
                    )
            }
            
            if colors.count > 3 {
                Circle()
                    .fill(Color(.systemGray5))
                    .frame(width: 24, height: 24)
                    .overlay(
                        Text("+\(colors.count - 3)")
                            .font(.system(size: 10, weight: .medium))
                            .foregroundColor(.secondary)
                    )
                    .overlay(
                        Circle()
                            .stroke(Color(.systemBackground), lineWidth: 2)
                    )
            }
        }
    }
}

// MARK: - Empty Collection State

struct EmptyCollectionState: View {
    let collectionName: String
    
    var body: some View {
        VStack(spacing: 20) {
            Image(systemName: "folder")
                .font(.system(size: 60))
                .foregroundColor(.secondary.opacity(0.5))
            
            VStack(spacing: 8) {
                Text("No spots yet")
                    .font(.system(size: 20, weight: .semibold))
                    .foregroundColor(.primary)
                
                Text("Start adding spots to your \(collectionName) collection")
                    .font(.system(size: 16))
                    .foregroundColor(.secondary)
                    .multilineTextAlignment(.center)
            }
        }
        .padding(.vertical, 60)
        .padding(.horizontal, 40)
    }
}

// MARK: - Collection Album Card

struct CollectionAlbumCard: View {
    let collection: Collection
    
    private let gradientColors: [Color] = [
        Color.purple.opacity(0.8),
        Color.pink.opacity(0.8)
    ]
    
    private var isCollaborative: Bool {
        collection.name.contains("date night") || collection.name.contains("road trip")
    }
    
    var body: some View {
        VStack(spacing: 0) {
            // Album cover with gradient
            RoundedRectangle(cornerRadius: 16)
                .fill(
                    LinearGradient(
                        colors: gradientColors,
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
                .aspectRatio(1.0, contentMode: .fit)
                .overlay(
                    VStack {
                        // Collaborative indicator at top
                        if isCollaborative {
                            HStack {
                                Spacer()
                                CollaboratorAvatars()
                                    .padding(.trailing, 12)
                                    .padding(.top, 12)
                            }
                        }
                        
                        Spacer()
                        
                        Text(collection.name.lowercased())
                            .font(.system(size: 18, weight: .bold))
                            .foregroundColor(.white)
                            .multilineTextAlignment(.center)
                            .padding(.horizontal, 12)
                            .padding(.bottom, 16)
                    }
                )
            
            // Collection info
            VStack(alignment: .leading, spacing: 4) {
                HStack {
                    Text(collection.name)
                        .font(.system(size: 16, weight: .semibold))
                        .foregroundColor(.primary)
                        .lineLimit(1)
                    
                    Spacer()
                    
                    if isCollaborative {
                        Image(systemName: "person.2.fill")
                            .font(.system(size: 12))
                            .foregroundColor(.secondary)
                    }
                }
                
                Text("\(collection.restaurantIds.count) spots")
                    .font(.system(size: 14))
                    .foregroundColor(.secondary)
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(.horizontal, 4)
            .padding(.top, 8)
        }
    }
}

// MARK: - Restaurant List View

struct RestaurantListView: View {
    let restaurants: [Restaurant]
    let onRestaurantTap: (Restaurant) -> Void
    
    var body: some View {
        ScrollView {
            LazyVStack(spacing: 16) {
                ForEach(restaurants) { restaurant in
                    RestaurantListCard(restaurant: restaurant)
                        .onTapGesture {
                            HapticManager.shared.medium()
                            onRestaurantTap(restaurant)
                        }
                }
            }
            .padding(.horizontal, 20)
            .padding(.top, 20)
            .padding(.bottom, 100) // Space for floating button
        }
    }
}

// MARK: - Restaurant List Card (Landscape Format)

struct RestaurantListCard: View {
    let restaurant: Restaurant
    @State private var imageLoaded = false
    
    @State private var showingOptions = false
    
    var body: some View {
        HStack(spacing: 12) {
            // Restaurant image - smaller than before
            AsyncImage(url: URL(string: restaurant.imageURL)) { image in
                image
                    .resizable()
                    .aspectRatio(contentMode: .fill)
                    .onAppear {
                        withAnimation(.easeInOut(duration: 0.3)) {
                            imageLoaded = true
                        }
                    }
            } placeholder: {
                Rectangle()
                    .fill(restaurant.category.color.opacity(0.3))
                    .overlay(
                        Image(systemName: restaurant.category.icon)
                            .font(.system(size: 20))
                            .foregroundColor(restaurant.category.color)
                    )
            }
            .frame(width: 60, height: 60) // Reduced from 80x80 to 60x60
            .clipShape(RoundedRectangle(cornerRadius: 12))
            
            // Restaurant info - more space for text
            VStack(alignment: .leading, spacing: 4) {
                // Restaurant name
                Text(restaurantDisplayName)
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundColor(.primary)
                    .lineLimit(1)
                
                // Category and price (removed rating)
                HStack(spacing: 4) {
                    // Category only
                    Text(restaurant.category.rawValue)
                        .font(.system(size: 14))
                        .foregroundColor(.secondary)
                    
                    Text("•")
                        .font(.system(size: 14))
                        .foregroundColor(.secondary)
                    
                    // Price range
                    Text(restaurant.priceRange)
                        .font(.system(size: 14))
                        .foregroundColor(.secondary)
                    
                    Spacer()
                }
                
                // Location (suburb, state only)
                Text(locationDisplay)
                    .font(.system(size: 13))
                    .foregroundColor(.secondary)
                    .lineLimit(1)
            }
            
            Spacer()
            
            // Three dots menu button
            Button(action: {
                HapticManager.shared.light()
                showingOptions = true
            }) {
                Image(systemName: "ellipsis")
                    .font(.system(size: 16, weight: .medium))
                    .foregroundColor(.secondary)
                    .frame(width: 24, height: 24)
            }
        }
        .padding(16)
        .background(Color(.systemBackground))
        .cornerRadius(16)
        .shadow(color: .black.opacity(0.05), radius: 8, x: 0, y: 4)
        .scaleEffect(imageLoaded ? 1.0 : 0.95)
        .opacity(imageLoaded ? 1.0 : 0.8)
        .sheet(isPresented: $showingOptions) {
            RestaurantOptionsSheet(restaurant: restaurant)
        }
    }
    
    private var restaurantDisplayName: String {
        // Extract just the restaurant name, removing extra text
        let name = restaurant.name
        if name.contains("Opens") {
            return String(name.split(separator: " ").prefix(2).joined(separator: " "))
        }
        return name
    }
    
    private var locationDisplay: String {
        // Extract suburb and state only from address (e.g., "Cremorne VIC")
        let components = restaurant.address.components(separatedBy: ", ")
        if components.count >= 2 {
            // Get suburb from second component and state from last component
            let suburb = components[1].trimmingCharacters(in: .whitespaces)
            let stateComponent = components.last ?? ""
            let state = stateComponent.split(separator: " ").last ?? ""
            return "\(suburb) \(state)"
        }
        return restaurant.address
    }
}

// MARK: - Restaurant Card (Exactly Matching Screenshot)

struct RestaurantCard: View {
    let restaurant: Restaurant
    @State private var imageLoaded = false
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            // Restaurant image
            AsyncImage(url: URL(string: restaurant.imageURL)) { image in
                image
                    .resizable()
                    .aspectRatio(contentMode: .fill)
                    .onAppear {
                        withAnimation(.easeInOut(duration: 0.3)) {
                            imageLoaded = true
                        }
                    }
            } placeholder: {
                Rectangle()
                    .fill(restaurant.category.color.opacity(0.3))
                    .overlay(
                        Text(restaurant.category.icon)
                            .font(.system(size: 40))
                    )
            }
            .frame(height: 140)
            .clipped()
            .cornerRadius(12)
            .overlay(
                // Category tag in top-left
                VStack {
                    HStack {
                        HStack(spacing: 4) {
                            Image(systemName: restaurant.category.icon)
                                .font(.system(size: 11, weight: .medium))
                            Text(restaurant.tags.first ?? restaurant.category.rawValue)
                                .font(.system(size: 11, weight: .medium))
                        }
                        .padding(.horizontal, 8)
                        .padding(.vertical, 4)
                        .background(restaurant.category.color)
                        .foregroundColor(.white)
                        .cornerRadius(8)
                        
                        Spacer()
                    }
                    .padding(8)
                    
                    Spacer()
                }
            )
            
            // Restaurant info
            VStack(alignment: .leading, spacing: 4) {
                Text(restaurant.name)
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundColor(.primary)
                    .lineLimit(2)
                
                HStack(spacing: 4) {
                    Image(systemName: restaurant.source.icon)
                        .font(.system(size: 12))
                        .foregroundColor(.secondary)
                    
                    Text(restaurant.source.displayName)
                        .font(.system(size: 12))
                        .foregroundColor(.secondary)
                }
            }
        }
        .background(Color(.systemBackground))
        .cornerRadius(12)
        .shadow(color: .black.opacity(0.05), radius: 4, x: 0, y: 2)
        .scaleEffect(imageLoaded ? 1.0 : 0.95)
        .opacity(imageLoaded ? 1.0 : 0.8)
    }
}

// MARK: - Demo Restaurant Card

struct DemoRestaurantCard: View {
    let restaurant: Restaurant
    
    var body: some View {
        RestaurantListCard(restaurant: restaurant)
            .opacity(0.7)
            .overlay(
                RoundedRectangle(cornerRadius: 16)
                    .stroke(Color.gray.opacity(0.5), style: StrokeStyle(lineWidth: 2, dash: [5]))
            )
    }
}


struct AddMenuOption: View {
    let icon: String
    let title: String
    let action: () -> Void
    @State private var isPressed = false
    
    var body: some View {
        Button(action: {
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
            HStack(spacing: 12) {
                Image(systemName: icon)
                    .font(.system(size: 18, weight: .medium))
                    .foregroundColor(.primary)
                    .frame(width: 24)
                
                Text(title)
                    .font(.system(size: 16, weight: .medium))
                    .foregroundColor(.primary)
                
                Spacer()
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 12)
            .background(
                RoundedRectangle(cornerRadius: 12)
                    .fill(Color(.systemBackground))
                    .shadow(color: .black.opacity(0.1), radius: 8, x: 0, y: 4)
            )
            .scaleEffect(isPressed ? 0.97 : 1.0)
        }
        .buttonStyle(PlainButtonStyle())
    }
}

// MARK: - Modern Map View for iOS 17+

struct ModernMapView: View {
    @Binding var region: MKCoordinateRegion
    let restaurants: [Restaurant]
    
    var body: some View {
        Map(coordinateRegion: $region, annotationItems: restaurants) { restaurant in
            MapAnnotation(coordinate: CLLocationCoordinate2D(latitude: restaurant.latitude, longitude: restaurant.longitude)) {
                RestaurantMapPin(restaurant: restaurant)
            }
        }
    }
}

// MARK: - Map View (Matching Screenshot)

struct MapTabView: View {
    @EnvironmentObject var store: RestaurantStore
    @State private var selectedCategory: RestaurantCategory? = .all
    @State private var selectedCollection: Collection?
    @State private var showingBottomSheet = false
    @State private var bottomSheetOffset: CGFloat = 350
    @State private var showingProfile = false
    @State private var region = MKCoordinateRegion(
        center: CLLocationCoordinate2D(latitude: -37.8136, longitude: 144.9631), // Melbourne CBD
        span: MKCoordinateSpan(latitudeDelta: 0.05, longitudeDelta: 0.05)
    )
    
    var body: some View {
        ZStack {
            // Map with proper API usage
            ModernMapView(region: $region, restaurants: filteredMapRestaurants)
            .ignoresSafeArea()
            
            // Top overlay with profile button and optional collection name
            VStack {
                HStack {
                    if let collection = selectedCollection {
                        Text(collection.name)
                            .font(.system(size: 24, weight: .semibold))
                            .foregroundColor(.primary)
                            .padding(.horizontal, 20)
                            .padding(.vertical, 10)
                            .background(Color(.systemBackground))
                            .cornerRadius(20)
                    }
                    
                    Spacer()
                    
                    // Profile button with person icon - positioned at top right
                    Button(action: {
                        HapticManager.shared.light()
                        showingProfile = true
                    }) {
                        ZStack {
                            Circle()
                                .fill(
                                    LinearGradient(
                                        colors: [Color.blue, Color.purple, Color.cyan],
                                        startPoint: .topLeading,
                                        endPoint: .bottomTrailing
                                    )
                                )
                                .frame(width: 32, height: 32)
                            
                            Image(systemName: "person.fill")
                                .font(.system(size: 14, weight: .medium))
                                .foregroundColor(.white)
                        }
                    }
                }
                .padding(.horizontal, 20)
                .padding(.top, 50)
                
                Spacer()
            }
            
            // Bottom sheet with collections and categories
            VStack {
                Spacer()
                
                // Bottom sheet
                VStack(spacing: 0) {
                    // Drag handle
                    RoundedRectangle(cornerRadius: 2.5)
                        .fill(Color(.systemGray4))
                        .frame(width: 40, height: 5)
                        .padding(.top, 8)
                        .padding(.bottom, 20)
                    
                    // New Airbnb-style filters
                    FilterBar()
                        .padding(.top, 8)
                    .padding(.bottom, 20)
                    
                    // Spots in collection count
                    if let collection = selectedCollection {
                        HStack {
                            Text("\(filteredMapRestaurants.count) spots in collection")
                                .font(.system(size: 18, weight: .semibold))
                            
                            Spacer()
                            
                            Button(action: {
                                selectedCollection = nil
                            }) {
                                Image(systemName: "xmark.circle.fill")
                                    .font(.system(size: 24))
                                    .foregroundColor(.secondary)
                            }
                        }
                        .padding(.horizontal, 20)
                        .padding(.bottom, 20)
                    }
                    
                    // Restaurant list or Collections
                    ScrollView {
                        if selectedCollection != nil {
                            // Show restaurants in collection
                            VStack(spacing: 16) {
                                ForEach(filteredMapRestaurants) { restaurant in
                                    HStack(spacing: 12) {
                                        // Restaurant icon
                                        Circle()
                                            .fill(restaurant.category.color.opacity(0.2))
                                            .frame(width: 50, height: 50)
                                            .overlay(
                                                Image(systemName: restaurant.category.icon)
                                                    .font(.system(size: 20))
                                                    .foregroundColor(restaurant.category.color)
                                            )
                                        
                                        Text(restaurant.name)
                                            .font(.system(size: 16, weight: .medium))
                                        
                                        Spacer()
                                    }
                                    .padding(.horizontal, 20)
                                }
                            }
                            .padding(.vertical, 10)
                        } else {
                            // Show collections
                            VStack(alignment: .leading, spacing: 20) {
                                HStack {
                                    Text("My Collections")
                                        .font(.system(size: 20, weight: .bold))
                                    
                                    Image(systemName: "chevron.right")
                                        .font(.system(size: 16))
                                        .foregroundColor(.secondary)
                                    
                                    Spacer()
                                    
                                    Button(action: {}) {
                                        Image(systemName: "plus")
                                            .font(.system(size: 20))
                                            .foregroundColor(.orange)
                                    }
                                }
                                .padding(.horizontal, 20)
                                
                                // Collections grid
                                ScrollView(.horizontal, showsIndicators: false) {
                                    HStack(spacing: 12) {
                                        ForEach(store.collections) { collection in
                                            CollectionCard(collection: collection)
                                                .frame(width: 150, height: 180)
                                                .onTapGesture {
                                                    HapticManager.shared.medium()
                                                    selectedCollection = collection
                                                }
                                        }
                                    }
                                    .padding(.horizontal, 20)
                                }
                            }
                            .padding(.top, 10)
                        }
                    }
                    .frame(maxHeight: 300)
                }
                .background(Color(.systemBackground))
                .cornerRadius(20, corners: [.topLeft, .topRight])
                .shadow(color: .black.opacity(0.1), radius: 10, x: 0, y: -5)
                .offset(y: bottomSheetOffset)
                .gesture(
                    DragGesture()
                        .onChanged { value in
                            bottomSheetOffset = max(0, min(350, value.translation.height + (showingBottomSheet ? 0 : 350)))
                        }
                        .onEnded { value in
                            withAnimation(.spring()) {
                                if value.predictedEndTranslation.height > 100 {
                                    bottomSheetOffset = 350
                                    showingBottomSheet = false
                                } else {
                                    bottomSheetOffset = 0
                                    showingBottomSheet = true
                                }
                            }
                        }
                )
            }
        }
        .onAppear {
            // Start with bottom sheet partially visible
            withAnimation(.spring()) {
                bottomSheetOffset = 200
            }
        }
        .sheet(isPresented: $showingProfile) {
            ProfileTabView()
                .environmentObject(store)
        }
    }
    
    private var filteredMapRestaurants: [Restaurant] {
        var restaurants = store.savedRestaurants
        
        if let collection = selectedCollection {
            // Filter by collection (in a real app, this would check collection.restaurantIds)
            restaurants = restaurants.filter { _ in true } // Show all for now
        }
        
        if let category = selectedCategory, category != .all {
            restaurants = restaurants.filter { $0.category == category }
        }
        
        return restaurants
    }
}

// MARK: - Map Category Button

struct MapCategoryButton: View {
    let category: RestaurantCategory
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            HStack(spacing: 6) {
                Image(systemName: category.icon)
                    .font(.system(size: 14, weight: .medium))
                    .foregroundColor(isSelected ? .white : category.color)
                
                Text(category.rawValue)
                    .font(.system(size: 14, weight: .medium))
                    .foregroundColor(isSelected ? .white : .primary)
            }
            .padding(.horizontal, 12)
            .padding(.vertical, 8)
            .background(
                RoundedRectangle(cornerRadius: 18)
                    .fill(isSelected ? category.color : Color(.systemBackground))
                    .shadow(color: .black.opacity(0.1), radius: 2, x: 0, y: 1)
            )
        }
        .buttonStyle(PlainButtonStyle())
    }
}

// MARK: - Restaurant Map Pin

struct RestaurantMapPin: View {
    let restaurant: Restaurant
    
    var body: some View {
        VStack(spacing: 4) {
            // Pin
            Circle()
                .fill(restaurant.category.color)
                .frame(width: 12, height: 12)
                .overlay(
                    Circle()
                        .stroke(Color.white, lineWidth: 2)
                )
            
            // Restaurant name
            Text(restaurant.name)
                .font(.system(size: 10, weight: .medium))
                .foregroundColor(.black)
                .padding(.horizontal, 6)
                .padding(.vertical, 2)
                .background(
                    RoundedRectangle(cornerRadius: 4)
                        .fill(Color.white)
                        .shadow(color: .black.opacity(0.2), radius: 2, x: 0, y: 1)
                )
        }
    }
}

// MARK: - Profile View (Matching Screenshot)

struct ProfileTabView: View {
    @EnvironmentObject var store: RestaurantStore
    @State private var showingSettings = false
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 24) {
                    // Header with settings
                    HStack {
                        Text("Julian Ou")
                            .font(.system(size: 32, weight: .bold))
                            .foregroundColor(.primary)
                        
                        Spacer()
                        
                        Button(action: {
                            HapticManager.shared.light()
                            showingSettings = true
                        }) {
                            Image(systemName: "gearshape.fill")
                                .font(.system(size: 24))
                                .foregroundColor(.primary)
                        }
                    }
                    .padding(.horizontal, 20)
                    .padding(.top, 20)
                    
                    // Profile section
                    HStack(spacing: 20) {
                        // Profile image
                        Circle()
                            .fill(
                                LinearGradient(
                                    colors: [Color.blue, Color.purple, Color.cyan],
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                )
                            )
                            .frame(width: 80, height: 80)
                        
                        // Media saved count
                        VStack(alignment: .leading, spacing: 4) {
                            Text("\(store.savedRestaurants.count)")
                                .font(.system(size: 24, weight: .bold))
                                .foregroundColor(.primary)
                            
                            Text("Media Saved")
                                .font(.system(size: 16))
                                .foregroundColor(.secondary)
                        }
                        
                        Spacer()
                    }
                    .padding(.horizontal, 20)
                    
                    // Edit Profile button
                    Button(action: {}) {
                        Text("Edit Profile")
                            .font(.system(size: 16, weight: .medium))
                            .foregroundColor(.primary)
                            .frame(maxWidth: .infinity)
                            .frame(height: 44)
                            .background(Color(.systemGray6))
                            .cornerRadius(12)
                    }
                    .padding(.horizontal, 20)
                    
                    // Help categorize section
                    VStack(spacing: 16) {
                        VStack(alignment: .leading, spacing: 12) {
                            Text("Help us categorize restaurant content")
                                .font(.system(size: 20, weight: .bold))
                                .foregroundColor(.primary)
                            
                            Text("Add where you live, so to differentiate between travel or just local dining")
                                .font(.system(size: 16))
                                .foregroundColor(.secondary)
                        }
                        
                        HStack(spacing: 12) {
                            Button("Add Home Country") {
                                // Add home country action
                            }
                            .font(.system(size: 16, weight: .medium))
                            .foregroundColor(.primary)
                            .padding(.horizontal, 20)
                            .padding(.vertical, 12)
                            .background(Color(.systemBackground))
                            .overlay(
                                RoundedRectangle(cornerRadius: 25)
                                    .stroke(Color.gray.opacity(0.3), lineWidth: 1)
                            )
                            .cornerRadius(25)
                            
                            Button("Later") {
                                // Later action
                            }
                            .font(.system(size: 16, weight: .medium))
                            .foregroundColor(.secondary)
                            
                            Spacer()
                        }
                    }
                    .padding(.horizontal, 20)
                    .padding(.vertical, 20)
                    .background(Color(.systemGray6))
                    .cornerRadius(16)
                    .padding(.horizontal, 20)
                    
                    // My Collections section
                    VStack(alignment: .leading, spacing: 16) {
                        HStack {
                            Text("My Collections")
                                .font(.system(size: 20, weight: .bold))
                                .foregroundColor(.primary)
                            
                            Spacer()
                            
                            Button(action: {}) {
                                Image(systemName: "chevron.right")
                                    .font(.system(size: 16, weight: .medium))
                                    .foregroundColor(.secondary)
                            }
                            
                            Button(action: {}) {
                                Image(systemName: "plus")
                                    .font(.system(size: 18, weight: .semibold))
                                    .foregroundColor(.white)
                                    .frame(width: 32, height: 32)
                                    .background(Color.orange)
                                    .clipShape(Circle())
                            }
                        }
                        
                        if store.collections.isEmpty {
                            HStack {
                                Image(systemName: "folder")
                                    .font(.system(size: 16))
                                    .foregroundColor(.secondary)
                                
                                Text("You have no collections yet!")
                                    .font(.system(size: 16))
                                    .foregroundColor(.secondary)
                            }
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 40)
                        } else {
                            // Collections grid
                            LazyVGrid(columns: Array(repeating: GridItem(.flexible(), spacing: 12), count: 2), spacing: 12) {
                                ForEach(store.collections) { collection in
                                    CollectionCard(collection: collection)
                                }
                            }
                        }
                    }
                    .padding(.horizontal, 20)
                    
                    // Extracts section
                    VStack(alignment: .leading, spacing: 16) {
                        Text("Extracts")
                            .font(.system(size: 20, weight: .bold))
                            .foregroundColor(.primary)
                        
                        HStack(spacing: 16) {
                            // Spots extract
                            VStack(spacing: 12) {
                                Circle()
                                    .fill(Color.blue.opacity(0.2))
                                    .frame(width: 60, height: 60)
                                    .overlay(
                                        Text("📍")
                                            .font(.system(size: 24))
                                    )
                                
                                Text("Spots")
                                    .font(.system(size: 16, weight: .medium))
                                    .foregroundColor(.blue)
                            }
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 20)
                            .background(Color.blue.opacity(0.1))
                            .cornerRadius(16)
                            
                            // Recipes extract
                            VStack(spacing: 12) {
                                Circle()
                                    .fill(Color.orange.opacity(0.2))
                                    .frame(width: 60, height: 60)
                                    .overlay(
                                        Text("📖")
                                            .font(.system(size: 24))
                                    )
                                
                                Text("Recipes")
                                    .font(.system(size: 16, weight: .medium))
                                    .foregroundColor(.orange)
                            }
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 20)
                            .background(Color.orange.opacity(0.1))
                            .cornerRadius(16)
                        }
                    }
                    .padding(.horizontal, 20)
                    
                    Spacer()
                }
            }
        }
        .navigationBarHidden(true)
        .sheet(isPresented: $showingSettings) {
            SettingsView()
                .environmentObject(store)
        }
    }
}

// MARK: - Collection Card

struct CollectionCard: View {
    let collection: Collection
    
    private let gradientColors: [Color] = [
        Color.purple.opacity(0.8),
        Color.pink.opacity(0.8)
    ]
    
    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            // Collection preview with gradient
            RoundedRectangle(cornerRadius: 12)
                .fill(
                    LinearGradient(
                        colors: gradientColors,
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
                .aspectRatio(1.2, contentMode: .fit)
                .overlay(
                    Text(collection.name.lowercased())
                        .font(.system(size: 16, weight: .medium))
                        .foregroundColor(.white)
                        .padding(.horizontal, 12)
                        .padding(.bottom, 12),
                    alignment: .bottomLeading
                )
        }
        .cornerRadius(12)
    }
}

// MARK: - Settings View

struct SettingsView: View {
    @EnvironmentObject var store: RestaurantStore
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        NavigationView {
            List {
                Section {
                    HStack {
                        Circle()
                            .fill(
                                LinearGradient(
                                    colors: [Color.blue, Color.purple, Color.cyan],
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                )
                            )
                            .frame(width: 50, height: 50)
                        
                        VStack(alignment: .leading) {
                            Text("Julian Ou")
                                .font(.system(size: 18, weight: .semibold))
                            Text("julian@example.com")
                                .font(.system(size: 14))
                                .foregroundColor(.secondary)
                        }
                        
                        Spacer()
                    }
                    .padding(.vertical, 8)
                }
                
                Section("Sharing") {
                    SettingsRow(icon: "square.and.arrow.up", title: "Sharing guides", subtitle: "How to share from other apps")
                }
                
                Section("App Integration") {
                    SettingsRow(icon: "camera.fill", title: "Instagram", subtitle: "Connected")
                    SettingsRow(icon: "music.note", title: "TikTok", subtitle: "Connected")
                    SettingsRow(icon: "safari.fill", title: "Safari", subtitle: "Connected")
                }
                
                Section("Support") {
                    SettingsRow(icon: "questionmark.circle", title: "Help & Support")
                    SettingsRow(icon: "envelope", title: "Contact Us")
                }
            }
            .navigationTitle("Settings")
            .navigationBarTitleDisplayMode(.large)
            .navigationBarItems(
                trailing: Button("Done") {
                    dismiss()
                }
            )
        }
    }
}

struct SettingsRow: View {
    let icon: String
    let title: String
    let subtitle: String?
    
    init(icon: String, title: String, subtitle: String? = nil) {
        self.icon = icon
        self.title = title
        self.subtitle = subtitle
    }
    
    var body: some View {
        HStack {
            Image(systemName: icon)
                .font(.system(size: 16))
                .foregroundColor(.blue)
                .frame(width: 24)
            
            VStack(alignment: .leading, spacing: 2) {
                Text(title)
                    .font(.system(size: 16))
                
                if let subtitle = subtitle {
                    Text(subtitle)
                        .font(.system(size: 14))
                        .foregroundColor(.secondary)
                }
            }
            
            Spacer()
        }
        .padding(.vertical, 4)
    }
}

// MARK: - Custom Bottom Navigation Bar

struct CustomBottomNavBar: View {
    @Binding var selectedTab: Int
    @Binding var showingAddMenu: Bool
    let onManualSearch: () -> Void
    let onCreateCollection: () -> Void
    let onScanCollection: () -> Void
    
    var body: some View {
        ZStack(alignment: .bottom) {
            // Menu options (appear above the nav bar)
            if showingAddMenu {
                VStack {
                    Spacer()
                    VStack(spacing: 12) {
                        // Add Spot option
                        AddMenuOption(
                            icon: "plus.circle",
                            title: "Add Spot",
                            action: {
                                HapticManager.shared.medium()
                                withAnimation(.easeInOut(duration: 0.2)) {
                                    showingAddMenu = false
                                }
                                DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
                                    onManualSearch()
                                }
                            }
                        )
                        .opacity(showingAddMenu ? 1.0 : 0.0)
                        .scaleEffect(showingAddMenu ? 1.0 : 0.1)
                        .animation(.spring(response: 0.4, dampingFraction: 0.8).delay(0.2), value: showingAddMenu)
                        
                        // Create Collection option
                        AddMenuOption(
                            icon: "folder.badge.plus",
                            title: "Create Collection",
                            action: {
                                HapticManager.shared.medium()
                                withAnimation(.easeInOut(duration: 0.2)) {
                                    showingAddMenu = false
                                }
                                DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
                                    onCreateCollection()
                                }
                            }
                        )
                        .opacity(showingAddMenu ? 1.0 : 0.0)
                        .scaleEffect(showingAddMenu ? 1.0 : 0.1)
                        .animation(.spring(response: 0.4, dampingFraction: 0.8).delay(0.1), value: showingAddMenu)
                        
                        // Scan Collection option
                        AddMenuOption(
                            icon: "qrcode.viewfinder",
                            title: "Scan Collection",
                            action: {
                                HapticManager.shared.medium()
                                withAnimation(.easeInOut(duration: 0.2)) {
                                    showingAddMenu = false
                                }
                                DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
                                    onScanCollection()
                                }
                            }
                        )
                        .opacity(showingAddMenu ? 1.0 : 0.0)
                        .scaleEffect(showingAddMenu ? 1.0 : 0.1)
                        .animation(.spring(response: 0.4, dampingFraction: 0.8), value: showingAddMenu)
                    }
                    .frame(maxWidth: .infinity)
                    .padding(.horizontal, 60) // Add horizontal padding to center and reduce width
                    .padding(.bottom, 130) // Position above the nav bar
                }
            }
            
            // Bottom navigation bar with proper positioning
            VStack(spacing: 0) {
                Spacer()
                
                ZStack(alignment: .bottom) {
                    // Nav bar background - extends all the way to bottom
                    Rectangle()
                        .fill(Color(.systemBackground))
                        .frame(height: 80) // Reduced height
                        .shadow(color: .black.opacity(0.1), radius: 1, x: 0, y: -1)
                    
                    // Navigation items
                    HStack {
                        // Saved tab
                        Spacer()
                        TabBarItem(
                            icon: selectedTab == 0 ? "bookmark.fill" : "bookmark",
                            title: "Saved",
                            isSelected: selectedTab == 0
                        ) {
                            HapticManager.shared.selection()
                            selectedTab = 0
                        }
                        
                        Spacer()
                        
                        // Center floating + button
                        Button(action: {
                            HapticManager.shared.light()
                            withAnimation(.spring(response: 0.4, dampingFraction: 0.8)) {
                                showingAddMenu.toggle()
                            }
                        }) {
                            Image(systemName: showingAddMenu ? "xmark" : "plus")
                                .font(.system(size: 20, weight: .bold)) // Slightly smaller icon
                                .foregroundColor(.white)
                                .frame(width: 50, height: 50) // Slightly smaller circle
                                .background(Color.black)
                                .clipShape(Circle())
                                .shadow(color: .black.opacity(0.3), radius: 8, x: 0, y: 4)
                                .rotationEffect(.degrees(showingAddMenu ? 45 : 0))
                        }
                        .offset(y: -17) // Adjusted so only top third peeks above nav bar
                        
                        Spacer()
                        
                        // Map tab
                        TabBarItem(
                            icon: selectedTab == 1 ? "map.fill" : "map",
                            title: "Map",
                            isSelected: selectedTab == 1
                        ) {
                            HapticManager.shared.selection()
                            selectedTab = 1
                        }
                        Spacer()
                    }
                    .padding(.bottom, 25) // Further reduced padding for shorter nav bar
                }
            }
            .ignoresSafeArea(.container, edges: .bottom)
        }
    }
}

// MARK: - Tab Bar Item

struct TabBarItem: View {
    let icon: String
    let title: String
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            Image(systemName: icon)
                .font(.system(size: 24, weight: .medium)) // Slightly larger since no text
                .foregroundColor(isSelected ? .black : .gray)
        }
        .buttonStyle(PlainButtonStyle())
    }
}


// MARK: - Supporting Models and Data

enum RestaurantCategory: String, CaseIterable {
    case all = "All"
    case restaurants = "Restaurants"
    case cafe = "Cafe"
    case bars = "Bars"
    
    var icon: String {
        switch self {
        case .all: return "list.bullet"
        case .restaurants: return "fork.knife"
        case .cafe: return "cup.and.saucer.fill"
        case .bars: return "wineglass.fill"
        }
    }
    
    var color: Color {
        switch self {
        case .all: return .gray
        case .restaurants: return .blue
        case .cafe: return .brown
        case .bars: return .purple
        }
    }
}

enum SocialSource: String, CaseIterable {
    case instagram = "instagram"
    case tiktok = "tiktok"
    case web = "web"
    
    var displayName: String {
        switch self {
        case .instagram: return "Instagram"
        case .tiktok: return "TikTok"
        case .web: return "Web"
        }
    }
    
    var icon: String {
        switch self {
        case .instagram: return "camera.fill"
        case .tiktok: return "music.note"
        case .web: return "safari.fill"
        }
    }
}

struct Restaurant: Identifiable {
    let id = UUID()
    let name: String
    let category: RestaurantCategory
    let imageURL: String
    let description: String
    let rating: Double
    let priceRange: String
    let address: String
    let latitude: Double
    let longitude: Double
    let tags: [String]
    let source: SocialSource
}

struct Collection: Identifiable {
    let id = UUID()
    let name: String
    let restaurantIds: [UUID]
}

// MARK: - Melbourne Demo Data

struct Melbourne {
    static let demoRestaurants: [Restaurant] = [
        Restaurant(
            name: "Baker Bleu Opens Biggest Australian Bakery",
            category: .restaurants,
            imageURL: "https://images.unsplash.com/photo-1509440159596-0249088772ff?ixlib=rb-4.0.3&auto=format&fit=crop&w=800&q=80",
            description: "Sourdough Pizza & Breakfast Sandwiches",
            rating: 4.6,
            priceRange: "$$",
            address: "65 Dover St, Cremorne VIC 3121",
            latitude: -37.8289,
            longitude: 144.9923,
            tags: ["Restaurants"],
            source: .instagram
        ),
        Restaurant(
            name: "Seven Seeds Coffee Roasters",
            category: .cafe,
            imageURL: "https://images.unsplash.com/photo-1501339847302-ac426a4a7cbb?ixlib=rb-4.0.3&auto=format&fit=crop&w=800&q=80",
            description: "Specialty coffee roasters with amazing single origin beans",
            rating: 4.6,
            priceRange: "$$",
            address: "114 Berkeley St, Carlton VIC 3053",
            latitude: -37.8146,
            longitude: 144.9596,
            tags: ["Cafe"],
            source: .instagram
        ),
        Restaurant(
            name: "Cumulus Inc.",
            category: .restaurants,
            imageURL: "https://images.unsplash.com/photo-1517248135467-4c7edcad34c4?ixlib=rb-4.0.3&auto=format&fit=crop&w=800&q=80",
            description: "Contemporary dining with seasonal ingredients",
            rating: 4.3,
            priceRange: "$$",
            address: "45 Flinders Ln, Melbourne VIC 3000",
            latitude: -37.8176,
            longitude: 144.9653,
            tags: ["Restaurants"],
            source: .web
        ),
        Restaurant(
            name: "The Everleigh",
            category: .bars,
            imageURL: "https://images.unsplash.com/photo-1569718212165-3a8278d5f624?ixlib=rb-4.0.3&auto=format&fit=crop&w=800&q=80",
            description: "Classic cocktails in an elegant 1920s-style bar",
            rating: 4.4,
            priceRange: "$$$",
            address: "150-156 Gertrude St, Fitzroy VIC 3065",
            latitude: -37.8136,
            longitude: 144.9631,
            tags: ["Bars"],
            source: .tiktok
        ),
        Restaurant(
            name: "Proud Mary Coffee",
            category: .cafe,
            imageURL: "https://images.unsplash.com/photo-1551183053-bf91a1d81141?ixlib=rb-4.0.3&auto=format&fit=crop&w=800&q=80",
            description: "Award-winning specialty coffee and all-day brunch",
            rating: 4.8,
            priceRange: "$",
            address: "Home Kitchen",
            latitude: -37.8176,
            longitude: 144.9653,
            tags: ["Cafe"],
            source: .instagram
        ),
        Restaurant(
            name: "Chin Chin Restaurant",
            category: .restaurants,
            imageURL: "https://images.unsplash.com/photo-1504674900247-0877df9cc836?ixlib=rb-4.0.3&auto=format&fit=crop&w=800&q=80",
            description: "Modern Southeast Asian dining experience",
            rating: 4.5,
            priceRange: "$$",
            address: "125 Flinders Ln, Melbourne VIC 3000",
            latitude: -37.8167,
            longitude: 144.9657,
            tags: ["Restaurants"],
            source: .instagram
        ),
        Restaurant(
            name: "Industry Beans",
            category: .cafe,
            imageURL: "https://images.unsplash.com/photo-1499636136210-6f4ee915583e?ixlib=rb-4.0.3&auto=format&fit=crop&w=800&q=80",
            description: "Coffee roasters with innovative brunch menu",
            rating: 4.9,
            priceRange: "$",
            address: "Home Kitchen",
            latitude: -37.8176,
            longitude: 144.9653,
            tags: ["Cafe"],
            source: .tiktok
        ),
        Restaurant(
            name: "Black Pearl Bar",
            category: .bars,
            imageURL: "https://images.unsplash.com/photo-1571019613914-85f342c6a11e?ixlib=rb-4.0.3&auto=format&fit=crop&w=800&q=80",
            description: "Hidden cocktail bar with creative seasonal drinks",
            rating: 4.7,
            priceRange: "$$",
            address: "304 Brunswick St, Fitzroy VIC 3065",
            latitude: -37.8136,
            longitude: 144.9631,
            tags: ["Bars"],
            source: .web
        ),
        Restaurant(
            name: "Nobu Melbourne",
            category: .restaurants,
            imageURL: "https://images.unsplash.com/photo-1579027989536-b7b1f875659b?ixlib=rb-4.0.3&auto=format&fit=crop&w=800&q=80",
            description: "World-renowned Japanese fine dining experience",
            rating: 4.8,
            priceRange: "$$$",
            address: "Crown Entertainment Complex, Southbank VIC 3006",
            latitude: -37.8226,
            longitude: 144.9598,
            tags: ["Restaurants"],
            source: .instagram
        ),
        Restaurant(
            name: "Attica",
            category: .restaurants,
            imageURL: "https://images.unsplash.com/photo-1540189549336-e6e99c3679fe?ixlib=rb-4.0.3&auto=format&fit=crop&w=800&q=80",
            description: "Contemporary Australian fine dining with native ingredients",
            rating: 4.9,
            priceRange: "$$$",
            address: "74 Glen Eira Rd, Ripponlea VIC 3185",
            latitude: -37.8676,
            longitude: 145.0187,
            tags: ["Restaurants"],
            source: .web
        ),
        Restaurant(
            name: "Bar Americano",
            category: .bars,
            imageURL: "https://images.unsplash.com/photo-1514362545857-3bc16c4c7d1b?ixlib=rb-4.0.3&auto=format&fit=crop&w=800&q=80",
            description: "Classic American cocktails in intimate setting",
            rating: 4.6,
            priceRange: "$$$",
            address: "20 Presgrave Pl, Melbourne VIC 3000",
            latitude: -37.8136,
            longitude: 144.9631,
            tags: ["Bars"],
            source: .tiktok
        ),
        Restaurant(
            name: "Patricia Coffee Brewers",
            category: .cafe,
            imageURL: "https://images.unsplash.com/photo-1497515114629-f71d768fd07c?ixlib=rb-4.0.3&auto=format&fit=crop&w=800&q=80",
            description: "Specialty coffee roasters with exceptional brews",
            rating: 4.5,
            priceRange: "$$",
            address: "Cnr Little Bourke & Somerset Pl, Melbourne VIC 3000",
            latitude: -37.8146,
            longitude: 144.9596,
            tags: ["Cafe"],
            source: .instagram
        ),
        Restaurant(
            name: "Tipo 00",
            category: .restaurants,
            imageURL: "https://images.unsplash.com/photo-1551183053-bf91a1d81141?ixlib=rb-4.0.3&auto=format&fit=crop&w=800&q=80",
            description: "Authentic Italian pasta made fresh daily",
            rating: 4.7,
            priceRange: "$$",
            address: "361 Little Bourke St, Melbourne VIC 3000",
            latitude: -37.8123,
            longitude: 144.9589,
            tags: ["Restaurants"],
            source: .instagram
        ),
        Restaurant(
            name: "Romeo Lane",
            category: .bars,
            imageURL: "https://images.unsplash.com/photo-1569718212165-3a8278d5f624?ixlib=rb-4.0.3&auto=format&fit=crop&w=800&q=80",
            description: "Intimate wine bar with European influence",
            rating: 4.4,
            priceRange: "$$",
            address: "Shop 4/108 Bourke St, Melbourne VIC 3000",
            latitude: -37.8136,
            longitude: 144.9631,
            tags: ["Bars"],
            source: .web
        ),
        Restaurant(
            name: "Market Lane Coffee",
            category: .cafe,
            imageURL: "https://images.unsplash.com/photo-1495474472287-4d71bcdd2085?ixlib=rb-4.0.3&auto=format&fit=crop&w=800&q=80",
            description: "Award-winning coffee with multiple locations",
            rating: 4.3,
            priceRange: "$$",
            address: "Shop 19 Prahran Market, Prahran VIC 3181",
            latitude: -37.8456,
            longitude: 144.9876,
            tags: ["Cafe"],
            source: .instagram
        ),
        Restaurant(
            name: "Flower Drum",
            category: .restaurants,
            imageURL: "https://images.unsplash.com/photo-1563379091339-03246963d4fb?ixlib=rb-4.0.3&auto=format&fit=crop&w=800&q=80",
            description: "Legendary Cantonese fine dining restaurant",
            rating: 4.8,
            priceRange: "$$$",
            address: "17 Market Ln, Melbourne VIC 3000",
            latitude: -37.8156,
            longitude: 144.9687,
            tags: ["Restaurants"],
            source: .web
        ),
        Restaurant(
            name: "1806",
            category: .bars,
            imageURL: "https://images.unsplash.com/photo-1572116469696-31de0f17cc34?ixlib=rb-4.0.3&auto=format&fit=crop&w=800&q=80",
            description: "Award-winning cocktail bar with creative drinks",
            rating: 4.9,
            priceRange: "$$$",
            address: "169 Exhibition St, Melbourne VIC 3000",
            latitude: -37.8156,
            longitude: 144.9734,
            tags: ["Bars"],
            source: .instagram
        )
    ]
}

// MARK: - New Airbnb-Style Filter System

// Filter Data Models
enum FilterType {
    case dropdown(DropdownFilter)
    case toggle(ToggleFilter)
    case button(ButtonFilter)
}

struct DropdownFilter {
    let id: String
    let label: String
    let defaultText: String
    let options: [String]
    let multiSelect: Bool
    var selectedOptions: Set<String> = []
    
    var displayText: String {
        if selectedOptions.isEmpty {
            return defaultText
        }
        if multiSelect && selectedOptions.count > 1 {
            return "\(selectedOptions.count) selected"
        }
        return selectedOptions.first ?? defaultText
    }
}

struct ToggleFilter {
    let id: String
    let label: String
    var isEnabled: Bool = false
}

struct ButtonFilter {
    let id: String
    let label: String
    let action: String
}

// Filter State Manager
class FilterState: ObservableObject {
    @Published var cuisineFilter = DropdownFilter(
        id: "cuisine",
        label: "Cuisine",
        defaultText: "All Cuisine",
        options: ["Italian", "Asian", "Mexican", "Healthy", "Pizza", "Burgers", "Cafe", "Fine Dining", "Brunch"],
        multiSelect: true
    )
    
    @Published var distanceFilter = DropdownFilter(
        id: "distance", 
        label: "Distance",
        defaultText: "Distance",
        options: ["Walking (5min)", "Short drive (15min)", "Anywhere"],
        multiSelect: false
    )
    
    @Published var priceFilter = DropdownFilter(
        id: "price",
        label: "Price",
        defaultText: "Price", 
        options: ["$", "$$", "$$$", "Any budget"],
        multiSelect: true
    )
    
    @Published var openNowFilter = ToggleFilter(
        id: "openNow",
        label: "Open Now"
    )
    
    @Published var collectionsFilter = DropdownFilter(
        id: "collections",
        label: "My Lists",
        defaultText: "My Lists",
        options: ["date night", "road trip", "bars", "best jap"],
        multiSelect: false
    )
    
    @Published var showingMoreFilters = false
    
    var hasActiveFilters: Bool {
        !cuisineFilter.selectedOptions.isEmpty ||
        !distanceFilter.selectedOptions.isEmpty ||
        !priceFilter.selectedOptions.isEmpty ||
        openNowFilter.isEnabled ||
        !collectionsFilter.selectedOptions.isEmpty
    }
    
    func clearAll() {
        cuisineFilter.selectedOptions.removeAll()
        distanceFilter.selectedOptions.removeAll()
        priceFilter.selectedOptions.removeAll()
        openNowFilter.isEnabled = false
        collectionsFilter.selectedOptions.removeAll()
    }
}

// Main Filter Bar Component
struct FilterBar: View {
    @EnvironmentObject var filterState: FilterState
    @State private var showingCuisineDropdown = false
    @State private var showingDistanceDropdown = false
    @State private var showingPriceDropdown = false
    @State private var showingCollectionsDropdown = false
    
    var body: some View {
        VStack(spacing: 0) {
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 12) {
                    // Cuisine Filter
                    FilterPill(
                        text: filterState.cuisineFilter.displayText,
                        isSelected: !filterState.cuisineFilter.selectedOptions.isEmpty,
                        hasDropdown: true
                    ) {
                        withAnimation(.easeInOut(duration: 0.2)) {
                            showingCuisineDropdown.toggle()
                        }
                    }
                    
                    // Distance Filter
                    FilterPill(
                        text: filterState.distanceFilter.displayText,
                        isSelected: !filterState.distanceFilter.selectedOptions.isEmpty,
                        hasDropdown: true
                    ) {
                        withAnimation(.easeInOut(duration: 0.2)) {
                            showingDistanceDropdown.toggle()
                        }
                    }
                    
                    // Price Filter
                    FilterPill(
                        text: filterState.priceFilter.displayText,
                        isSelected: !filterState.priceFilter.selectedOptions.isEmpty,
                        hasDropdown: true
                    ) {
                        withAnimation(.easeInOut(duration: 0.2)) {
                            showingPriceDropdown.toggle()
                        }
                    }
                    
                    // Open Now Toggle
                    FilterPill(
                        text: filterState.openNowFilter.label,
                        isSelected: filterState.openNowFilter.isEnabled,
                        hasDropdown: false
                    ) {
                        HapticManager.shared.light()
                        withAnimation(.easeInOut(duration: 0.2)) {
                            filterState.openNowFilter.isEnabled.toggle()
                        }
                    }
                    
                    // My Lists Filter
                    FilterPill(
                        text: filterState.collectionsFilter.displayText,
                        isSelected: !filterState.collectionsFilter.selectedOptions.isEmpty,
                        hasDropdown: true
                    ) {
                        withAnimation(.easeInOut(duration: 0.2)) {
                            showingCollectionsDropdown.toggle()
                        }
                    }
                    
                    // More Filters Button
                    FilterPill(
                        text: "Filters",
                        isSelected: false,
                        hasDropdown: false,
                        isSpecial: true
                    ) {
                        filterState.showingMoreFilters = true
                    }
                    
                    // Clear All (only show if filters are active)
                    if filterState.hasActiveFilters {
                        Button(action: {
                            HapticManager.shared.light()
                            withAnimation(.easeInOut(duration: 0.3)) {
                                filterState.clearAll()
                            }
                        }) {
                            Text("Clear all")
                                .font(.system(size: 14, weight: .medium))
                                .foregroundColor(.primary)
                                .underline()
                        }
                        .transition(.opacity)
                    }
                }
                .padding(.horizontal, 20)
            }
            .padding(.vertical, 12)
            
            // Dropdown overlays
            if showingCuisineDropdown {
                FilterDropdown(
                    filter: $filterState.cuisineFilter,
                    isShowing: $showingCuisineDropdown
                )
                .transition(.asymmetric(
                    insertion: .opacity.combined(with: .move(edge: .top)),
                    removal: .opacity
                ))
            }
            
            if showingDistanceDropdown {
                FilterDropdown(
                    filter: $filterState.distanceFilter,
                    isShowing: $showingDistanceDropdown
                )
                .transition(.asymmetric(
                    insertion: .opacity.combined(with: .move(edge: .top)),
                    removal: .opacity
                ))
            }
            
            if showingPriceDropdown {
                FilterDropdown(
                    filter: $filterState.priceFilter,
                    isShowing: $showingPriceDropdown
                )
                .transition(.asymmetric(
                    insertion: .opacity.combined(with: .move(edge: .top)),
                    removal: .opacity
                ))
            }
            
            if showingCollectionsDropdown {
                FilterDropdown(
                    filter: $filterState.collectionsFilter,
                    isShowing: $showingCollectionsDropdown
                )
                .transition(.asymmetric(
                    insertion: .opacity.combined(with: .move(edge: .top)),
                    removal: .opacity
                ))
            }
        }
        .sheet(isPresented: $filterState.showingMoreFilters) {
            MoreFiltersSheet()
        }
    }
}

// Filter Pill Component (Airbnb style)
struct FilterPill: View {
    let text: String
    let isSelected: Bool
    let hasDropdown: Bool
    var isSpecial: Bool = false
    let action: () -> Void
    @State private var isPressed = false
    
    var body: some View {
        Button(action: {
            HapticManager.shared.light()
            action()
        }) {
            HStack(spacing: 6) {
                Text(text)
                    .font(.system(size: 14, weight: .medium))
                    .foregroundColor(isSelected ? .white : .primary)
                
                if hasDropdown {
                    Image(systemName: "chevron.down")
                        .font(.system(size: 12, weight: .medium))
                        .foregroundColor(isSelected ? .white : .secondary)
                }
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 10)
            .background(
                RoundedRectangle(cornerRadius: 24)
                    .fill(isSelected ? Color.black : (isSpecial ? Color.gray.opacity(0.1) : Color(.systemGray6)))
                    .overlay(
                        RoundedRectangle(cornerRadius: 24)
                            .stroke(isSelected ? Color.clear : Color(.systemGray4), lineWidth: 1)
                    )
            )
            .scaleEffect(isPressed ? 0.95 : 1.0)
        }
        .onLongPressGesture(minimumDuration: 0, maximumDistance: .infinity, pressing: { pressing in
            withAnimation(.easeInOut(duration: 0.1)) {
                isPressed = pressing
            }
        }, perform: {})
    }
}

// Filter Dropdown Component
struct FilterDropdown: View {
    @Binding var filter: DropdownFilter
    @Binding var isShowing: Bool
    
    var body: some View {
        VStack(spacing: 0) {
            VStack(alignment: .leading, spacing: 8) {
                // Title
                Text(filter.label)
                    .font(.system(size: 18, weight: .semibold))
                    .foregroundColor(.primary)
                    .padding(.horizontal, 20)
                    .padding(.top, 20)
                
                // Options
                LazyVStack(spacing: 4) {
                    ForEach(filter.options, id: \.self) { option in
                        FilterOptionRow(
                            text: option,
                            isSelected: filter.selectedOptions.contains(option),
                            multiSelect: filter.multiSelect
                        ) {
                            if filter.multiSelect {
                                if filter.selectedOptions.contains(option) {
                                    filter.selectedOptions.remove(option)
                                } else {
                                    filter.selectedOptions.insert(option)
                                }
                            } else {
                                if filter.selectedOptions.contains(option) {
                                    filter.selectedOptions.removeAll()
                                } else {
                                    filter.selectedOptions.removeAll()
                                    filter.selectedOptions.insert(option)
                                }
                                withAnimation(.easeInOut(duration: 0.2)) {
                                    isShowing = false
                                }
                            }
                        }
                    }
                }
                .padding(.horizontal, 20)
                
                // Apply button for multi-select
                if filter.multiSelect {
                    Button(action: {
                        withAnimation(.easeInOut(duration: 0.2)) {
                            isShowing = false
                        }
                    }) {
                        Text("Apply")
                            .font(.system(size: 16, weight: .semibold))
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 14)
                            .background(Color.black)
                            .cornerRadius(12)
                    }
                    .padding(.horizontal, 20)
                    .padding(.bottom, 20)
                }
            }
            .background(Color(.systemBackground))
            .cornerRadius(16)
            .shadow(color: .black.opacity(0.1), radius: 8, x: 0, y: 4)
            .padding(.horizontal, 20)
            .padding(.top, 8)
        }
        .onTapGesture {
            withAnimation(.easeInOut(duration: 0.2)) {
                isShowing = false
            }
        }
    }
}

// Filter Option Row
struct FilterOptionRow: View {
    let text: String
    let isSelected: Bool
    let multiSelect: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: {
            HapticManager.shared.selection()
            action()
        }) {
            HStack {
                Text(text)
                    .font(.system(size: 16, weight: .medium))
                    .foregroundColor(.primary)
                
                Spacer()
                
                if multiSelect {
                    // Checkbox for multi-select
                    Image(systemName: isSelected ? "checkmark.square.fill" : "square")
                        .font(.system(size: 20))
                        .foregroundColor(isSelected ? .black : .gray)
                } else {
                    // Radio button for single select
                    Circle()
                        .fill(isSelected ? Color.black : Color.clear)
                        .frame(width: 20, height: 20)
                        .overlay(
                            Circle()
                                .stroke(Color.gray, lineWidth: 2)
                        )
                        .overlay(
                            Circle()
                                .fill(Color.white)
                                .frame(width: 8, height: 8)
                                .opacity(isSelected ? 1 : 0)
                        )
                }
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 12)
            .background(
                RoundedRectangle(cornerRadius: 8)
                    .fill(isSelected ? Color.black.opacity(0.05) : Color.clear)
            )
        }
    }
}

// More Filters Bottom Sheet
struct MoreFiltersSheet: View {
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        NavigationView {
            VStack(alignment: .leading, spacing: 24) {
                Text("More filters coming soon!")
                    .font(.system(size: 18, weight: .medium))
                    .foregroundColor(.secondary)
                    .padding(.horizontal, 20)
                
                Spacer()
            }
            .navigationTitle("More Filters")
            .navigationBarTitleDisplayMode(.inline)
            .navigationBarItems(
                trailing: Button("Done") {
                    dismiss()
                }
            )
        }
    }
}