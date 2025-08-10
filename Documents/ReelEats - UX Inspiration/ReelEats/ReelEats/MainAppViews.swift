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

// MARK: - Home Tab View (Spotify Library Style)

struct HomeTabView: View {
    @Binding var selectedRestaurant: Restaurant?
    @EnvironmentObject var store: RestaurantStore
    @StateObject private var filterState = FilterState()
    @State private var selectedContentType: ContentType = .spots
    // All Spots always shows list view, Collections always shows grid view
    @State private var selectedCategory: RestaurantCategory? = .all
    @State private var selectedCollection: Collection?
    @State private var showingProfile = false
    @State private var showingSearch = false
    @State private var showingAddMenu = false
    @State private var sortOrder: SortOrder = .recentlyAdded
    @State private var showingSortOptions = false
    @State private var showingCuisineDropdown = false
    @State private var showingDistanceDropdown = false
    @State private var showingPriceDropdown = false
    @State private var showingCollectionsDropdown = false
    @State private var selectedRestaurantForDetail: Restaurant?
    @State private var showingByMeDropdown = false
    @State private var showingByOthersDropdown = false
    @State private var collectionsSortOrder: SortOrder = .recentlyAdded
    @State private var showingCollectionsSortOptions = false
    @State private var collectionFilter: CollectionFilterType = .all
    
    enum ContentType: String, CaseIterable {
        case spots = "All Spots"
        case collections = "Collections"
    }
    
    enum SortOrder: String, CaseIterable {
        case recentlyAdded = "Recently added"
        case recentlyViewed = "Recently viewed"
        case alphabetical = "Alphabetical"
        
        var icon: String {
            switch self {
            case .recentlyAdded: return "clock"
            case .recentlyViewed: return "eye"
            case .alphabetical: return "textformat"
            }
        }
        
        var shortName: String {
            switch self {
            case .recentlyAdded: return "Recent"
            case .recentlyViewed: return "Viewed"
            case .alphabetical: return "A-Z"
            }
        }
    }
    
    enum MyListsSortOrder: String, CaseIterable {
        case recentlyAdded = "Recently added"
        case recentlyViewed = "Recently viewed"
        case alphabetical = "Alphabetical"
        
        var icon: String {
            switch self {
            case .recentlyAdded: return "clock"
            case .recentlyViewed: return "eye"
            case .alphabetical: return "textformat"
            }
        }
        
        var shortName: String {
            switch self {
            case .recentlyAdded: return "Recent"
            case .recentlyViewed: return "Viewed"
            case .alphabetical: return "A-Z"
            }
        }
    }
    
    var body: some View {
        NavigationView {
            VStack(spacing: 0) {
                // Sticky header section - ReelEats logo, search, add button, and toggle
                VStack(spacing: 0) {
                    SpotifyStyleHeader(
                        showingAddMenu: $showingAddMenu,
                        showingProfile: $showingProfile
                    )
                    .padding(.top, 8)
                    
                    // Spots/Collections toggle (fixed/sticky)
                    SpotCollectionToggle(selectedContentType: $selectedContentType)
                        .padding(.top, 16)
                        .padding(.bottom, 12)
                }
                .background(Color(.systemBackground))
                .zIndex(1000)
                
                // Scrollable content - simplified
                mainScrollContent
            }
        }
        .navigationBarHidden(true)
        .overlay(
            // UberEats-style bottom sheet overlay
            Group {
                
                
            }
        )
        .sheet(isPresented: $showingSearch) {
            SearchView()
                .environmentObject(store)
        }
        .sheet(item: $selectedRestaurantForDetail) { restaurant in
            FullScreenRestaurantDetailView(restaurant: restaurant)
                .environmentObject(store)
        }
        .fullScreenCover(item: $selectedCollection) { collection in
            CollectionDetailView(collection: collection, onRestaurantSelect: { restaurant in
                selectedRestaurant = restaurant
                selectedCollection = nil
            })
                .environmentObject(store)
        }
        .sheet(isPresented: $showingProfile) {
            ProfileTabView()
                .environmentObject(store)
        }
        .sheet(isPresented: $showingSortOptions) {
            SortOptionsBottomSheet(sortOrder: $sortOrder)
        }
        .sheet(isPresented: $showingCollectionsSortOptions) {
            SortOptionsBottomSheet(sortOrder: $collectionsSortOrder)
        }
    }
    
    // MARK: - Computed Properties to reduce body complexity
    
    private var mainScrollContent: some View {
        ScrollView {
            LazyVStack(spacing: 0) {
                if selectedContentType == .spots {
                    spotsContent
                } else {
                    collectionsContent
                }
                
                // Bottom safe area padding
                Color.clear
                    .frame(height: 100)
            }
        }
    }
    
    private var spotsContent: some View {
        VStack(spacing: 0) {
            // Filter pills
            FilterBar(
                showingCuisineDropdown: $showingCuisineDropdown,
                showingDistanceDropdown: $showingDistanceDropdown,
                showingPriceDropdown: $showingPriceDropdown,
                showingCollectionsDropdown: $showingCollectionsDropdown
            )
            .environmentObject(filterState)
            .padding(.top, 8)
            .padding(.bottom, 8)
            
            // Sort and grid toggle
            SpotifySortAndGrid(
                sortOrder: $sortOrder,
                showingSortOptions: $showingSortOptions,
                showingSearch: $showingSearch
            )
            .padding(.horizontal, 16)
            .padding(.bottom, 16)
            
            // Spots list content
            SpotsListContent(
                selectedCategory: $selectedCategory,
                sortOrder: sortOrder,
                onRestaurantSelect: { restaurant in
                    selectedRestaurantForDetail = restaurant
                }
            )
            .environmentObject(store)
        }
    }
    
    private var collectionsContent: some View {
        VStack(spacing: 0) {
            // Filter bar for collections
            MyListsFilterBar(
                showingByMeDropdown: $showingByMeDropdown,
                showingByOthersDropdown: $showingByOthersDropdown,
                collectionFilter: $collectionFilter
            )
            .environmentObject(filterState)
            .padding(.top, 8)
            .padding(.bottom, 8)
            
            // Collections sort
            SpotifySortAndGrid(
                sortOrder: $collectionsSortOrder,
                showingSortOptions: $showingCollectionsSortOptions,
                showingSearch: .constant(false)
            )
            .padding(.horizontal, 16)
            .padding(.bottom, 16)
            
            // Collections embedded content
            CollectionsEmbeddedContent(
                selectedCollection: $selectedCollection,
                onRestaurantSelect: { restaurant in
                    selectedRestaurant = restaurant
                },
                isListView: false,
                collectionFilter: collectionFilter
            )
            .environmentObject(store)
        }
    }
}

// MARK: - Sort Options Bottom Sheet

struct SortOptionsBottomSheet: View {
    @Binding var sortOrder: HomeTabView.SortOrder
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        VStack(spacing: 0) {
            // Handle
            ConsistentDragHandle()
            
            // Header
            Text("Sort By")
                .font(.newYorkHeader(size: 20))
                .foregroundColor(.primary)
                .padding(.bottom, 20)
            
            // Sort options
            VStack(spacing: 0) {
                ForEach(HomeTabView.SortOrder.allCases, id: \.self) { option in
                    Button(action: {
                        HapticManager.shared.selection()
                        sortOrder = option
                        dismiss()
                    }) {
                        HStack(spacing: 12) {
                            Text(option.rawValue)
                                .font(.newYorkButton())
                                .foregroundColor(sortOrder == option ? .reelEatsAccent : .primary)
                            
                            Spacer()
                            
                            if sortOrder == option {
                                Image(systemName: "checkmark")
                                    .font(.newYorkButton())
                                    .foregroundColor(.reelEatsAccent)
                            }
                        }
                        .padding(.horizontal, 20)
                        .padding(.vertical, 16)
                    }
                    .buttonStyle(PlainButtonStyle())
                    
                    if option != HomeTabView.SortOrder.allCases.last {
                        Rectangle()
                            .fill(Color(.systemGray5))
                            .frame(height: 1)
                            .padding(.leading, 20)
                    }
                }
            }
            
            Spacer(minLength: 20)
        }
        .background(Color(.systemBackground))
        .presentationDetents([.height(250), .medium])
        .presentationDragIndicator(.visible)
    }
}

// MARK: - My Lists Filter Bar

struct MyListsFilterBar: View {
    @Binding var showingByMeDropdown: Bool
    @Binding var showingByOthersDropdown: Bool
    @Binding var collectionFilter: CollectionFilterType
    @EnvironmentObject var filterState: FilterState
    
    var body: some View {
        HStack(spacing: 12) {
            // All filter
            FilterPill(
                text: "All",
                isSelected: collectionFilter == .all,
                hasDropdown: false
            ) {
                HapticManager.shared.light()
                collectionFilter = .all
            }
            
            // By Me filter
            FilterPill(
                text: "By Me",
                isSelected: collectionFilter == .byMe,
                hasDropdown: false
            ) {
                HapticManager.shared.light()
                collectionFilter = .byMe
            }
            
            // By Us filter
            FilterPill(
                text: "By Us",
                isSelected: collectionFilter == .byUs,
                hasDropdown: false
            ) {
                HapticManager.shared.light()
                collectionFilter = .byUs
            }
            
            // By Others filter
            FilterPill(
                text: "By Others",
                isSelected: collectionFilter == .byOthers,
                hasDropdown: false
            ) {
                HapticManager.shared.light()
                collectionFilter = .byOthers
            }
            
            Spacer()
        }
        .padding(.horizontal, 16)
    }
}

// MARK: - My Lists Sort and Grid Toggle

struct MyListsSortAndGrid: View {
    @Binding var sortOrder: HomeTabView.MyListsSortOrder
    @Binding var showingListView: Bool
    @Binding var showingSortOptions: Bool
    
    var body: some View {
        HStack(spacing: 16) {
            // Sort button
            Button(action: {
                HapticManager.shared.light()
                GlobalOverlayManager.shared.present(title: "Sort by") {
                    VStack(spacing: 0) {
                        ForEach(HomeTabView.MyListsSortOrder.allCases, id: \.self) { option in
                            FilterOptionItem(
                                title: option.rawValue,
                                isSelected: sortOrder == option,
                                action: {
                                    HapticManager.shared.selection()
                                    sortOrder = option
                                    GlobalOverlayManager.shared.dismiss()
                                }
                            )
                        }
                    }
                    .padding(.bottom, 32)
                }
            }) {
                HStack(spacing: 6) {
                    Image(systemName: sortOrder.icon)
                        .font(.clashDisplaySecondaryTemp())
                    
                    Text(sortOrder.rawValue)
                        .font(.clashDisplaySecondaryTemp())
                    
                    Image(systemName: "chevron.down")
                        .font(.clashDisplayCaptionTemp(size: 10))
                }
                .foregroundColor(.primary)
            }
            .buttonStyle(PlainButtonStyle())
            
            Spacer()
            
            // Grid/List toggle
            Button(action: {
                HapticManager.shared.light()
                withAnimation(.spring(response: 0.3, dampingFraction: 0.8)) {
                    showingListView.toggle()
                }
            }) {
                Image(systemName: showingListView ? "square.grid.2x2" : "list.bullet")
                    .font(.clashDisplayBodyTemp())
                    .foregroundColor(.primary)
                    .frame(width: 32, height: 32)
            }
        }
    }
}

// MARK: - Spotify Style Header

struct SpotifyStyleHeader: View {
    @Binding var showingAddMenu: Bool
    @Binding var showingProfile: Bool
    
    var body: some View {
        HStack(spacing: 16) {
            // ReelEats title only
            Text("ReelEats")
                .font(.poppinsLogoTemp(size: 22))
                .fontWeight(.black)
                .foregroundColor(.primary)
                .shadow(color: .primary.opacity(0.1), radius: 0, x: 0.5, y: 0.5)
            
            Spacer()
            
            // Profile button only
            Button(action: {
                HapticManager.shared.light()
                showingProfile = true
            }) {
                Circle()
                    .fill(Color.reelEatsAccent.opacity(0.2))
                    .frame(width: 32, height: 32)
                    .overlay(
                        Image(systemName: "person.fill")
                            .font(.clashDisplayBodyTemp())
                            .foregroundColor(.reelEatsAccent)
                    )
            }
        }
        .padding(.horizontal, 16)
        .padding(.top, 8)
        .padding(.bottom, 4)
    }
}

// MARK: - Content Type Pills

// MARK: - Spotify-style Toggle (underline style)

struct SpotCollectionToggle: View {
    @Binding var selectedContentType: HomeTabView.ContentType
    
    var body: some View {
        HStack(spacing: 24) {
            ForEach(HomeTabView.ContentType.allCases, id: \.self) { contentType in
                Button(action: {
                    HapticManager.shared.light()
                    withAnimation(.easeInOut(duration: 0.3)) {
                        selectedContentType = contentType
                    }
                }) {
                    VStack(spacing: 6) {
                        Text(contentType.rawValue)
                            .font(.clashDisplayButtonTemp())
                            .foregroundColor(selectedContentType == contentType ? .primary : .secondary)
                        
                        // Underline indicator
                        Rectangle()
                            .fill(Color.black)
                            .frame(width: contentType.rawValue.count < 10 ? 60 : 80, height: 2)
                            .opacity(selectedContentType == contentType ? 1 : 0)
                            .animation(.easeInOut(duration: 0.3), value: selectedContentType)
                    }
                }
                .buttonStyle(PlainButtonStyle())
            }
            
            Spacer()
        }
        .padding(.horizontal, 16)
    }
}

// MARK: - Sort Dropdown (sleek modern style)

struct SortDropdown: View {
    @Binding var sortOrder: HomeTabView.SortOrder
    @State private var showingOptions = false
    
    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            // Main button
            Button(action: {
                HapticManager.shared.light()
                withAnimation(.easeInOut(duration: 0.2)) {
                    showingOptions.toggle()
                }
            }) {
                HStack(spacing: 8) {
                    Image(systemName: sortOrder.icon)
                        .font(.clashDisplaySecondaryTemp())
                        .foregroundColor(.primary)
                    
                    Text(sortOrder.rawValue)
                        .font(.clashDisplayBodyTemp())
                        .foregroundColor(.primary)
                    
                    Image(systemName: "chevron.down")
                        .font(.clashDisplayCaptionTemp())
                        .foregroundColor(.secondary)
                        .rotationEffect(.degrees(showingOptions ? 180 : 0))
                }
                .padding(.horizontal, 12)
                .padding(.vertical, 10)
                .background(
                    RoundedRectangle(cornerRadius: 8)
                        .fill(Color(.systemGray6))
                )
            }
            .buttonStyle(PlainButtonStyle())
            
            // Dropdown options
            if showingOptions {
                VStack(spacing: 0) {
                    ForEach(HomeTabView.SortOrder.allCases, id: \.self) { option in
                        Button(action: {
                            HapticManager.shared.selection()
                            withAnimation(.easeInOut(duration: 0.2)) {
                                sortOrder = option
                                showingOptions = false
                            }
                        }) {
                            HStack(spacing: 12) {
                                Image(systemName: option.icon)
                                    .font(.clashDisplaySecondaryTemp())
                                    .foregroundColor(sortOrder == option ? .white : .primary)
                                    .frame(width: 16)
                                
                                Text(option.rawValue)
                                    .font(.clashDisplayBodyTemp(size: 15))
                                    .foregroundColor(sortOrder == option ? .white : .primary)
                                
                                Spacer()
                                
                                if sortOrder == option {
                                    Image(systemName: "checkmark")
                                        .font(.clashDisplayCaptionTemp())
                                        .foregroundColor(.white)
                                }
                            }
                            .padding(.horizontal, 12)
                            .padding(.vertical, 10)
                            .background(
                                RoundedRectangle(cornerRadius: 6)
                                    .fill(sortOrder == option ? Color.black : Color.clear)
                            )
                        }
                        .buttonStyle(PlainButtonStyle())
                    }
                }
                .padding(.vertical, 8)
                .background(
                    RoundedRectangle(cornerRadius: 12)
                        .fill(Color(.systemBackground))
                        .shadow(color: .black.opacity(0.1), radius: 12, x: 0, y: 4)
                )
                .padding(.top, 4)
                .transition(.opacity.combined(with: .scale(scale: 0.95)))
            }
        }
        .zIndex(showingOptions ? 1000 : 0)
    }
}

// MARK: - Spotify-style Sort and Grid Toggle

struct SpotifySortAndGrid: View {
    @Binding var sortOrder: HomeTabView.SortOrder
    @Binding var showingSortOptions: Bool
    @Binding var showingSearch: Bool
    @State private var showingInlineSearch = false
    @State private var searchText = ""
    
    var body: some View {
        HStack(spacing: 12) {
            // Sort button (UberEats style - no pill outline)
            Button(action: {
                HapticManager.shared.light()
                withAnimation(.easeInOut(duration: 0.2)) {
                    showingSortOptions.toggle()
                }
            }) {
                HStack(spacing: 6) {
                    Image(systemName: "arrow.up.arrow.down")
                        .font(.clashDisplaySecondaryTemp())
                        .foregroundColor(.primary)
                    
                    Text(sortOrder.shortName)
                        .font(.clashDisplaySecondaryTemp())
                        .foregroundColor(.primary)
                }
                .padding(.horizontal, 8)
                .padding(.vertical, 6)
            }
            .buttonStyle(PlainButtonStyle())
            
            // Animated search bar
            if showingInlineSearch {
                TextField("Search places...", text: $searchText)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                    .font(.clashDisplaySecondaryTemp())
                    .transition(.move(edge: .trailing).combined(with: .opacity))
                    .onSubmit {
                        // TODO: Implement search functionality
                    }
            } else {
                Spacer()
            }
            
            // Search button/cancel button
            Button(action: {
                HapticManager.shared.light()
                withAnimation(.easeInOut(duration: 0.3)) {
                    if showingInlineSearch {
                        showingInlineSearch = false
                        searchText = ""
                    } else {
                        showingInlineSearch = true
                    }
                }
            }) {
                Image(systemName: showingInlineSearch ? "xmark" : "magnifyingglass")
                    .font(.newYorkButton(size: 18))
                    .foregroundColor(.primary)
                    .frame(width: 32, height: 32)
            }
        }
    }
}

// MARK: - Add to Collection Modal

struct AddToCollectionModal: View {
    let restaurant: Restaurant
    @EnvironmentObject var store: RestaurantStore
    @Environment(\.dismiss) private var dismiss
    @State private var selectedCollections: Set<UUID> = []
    
    var body: some View {
        VStack(spacing: 0) {
            // Handle
            ConsistentDragHandle()
            
            // Header
            VStack(spacing: 16) {
                Text("Add to Collection")
                    .font(.newYorkHeader(size: 20))
                    .foregroundColor(.primary)
                
                HStack(spacing: 12) {
                    // Restaurant image/emoji
                    RoundedRectangle(cornerRadius: 8)
                        .fill(restaurant.category.color.opacity(0.2))
                        .overlay(
                            Text(restaurant.emoji)
                                .font(.clashDisplayBodyTemp(size: 24))
                        )
                        .frame(width: 50, height: 50)
                    
                    VStack(alignment: .leading, spacing: 4) {
                        Text(restaurant.name)
                            .font(.newYorkRestaurantName())
                            .foregroundColor(.primary)
                        
                        Text(restaurant.category.rawValue)
                            .font(.newYorkSecondary())
                            .foregroundColor(.secondary)
                    }
                    
                    Spacer()
                }
                .padding(.horizontal, 20)
            }
            .padding(.bottom, 20)
            
            // Collections list
            ScrollView {
                LazyVStack(spacing: 12) {
                    ForEach(store.collections) { collection in
                        AddToCollectionRow(
                            collection: collection,
                            restaurant: restaurant,
                            isSelected: selectedCollections.contains(collection.id),
                            onTap: {
                                HapticManager.shared.light()
                                if selectedCollections.contains(collection.id) {
                                    selectedCollections.remove(collection.id)
                                } else {
                                    selectedCollections.insert(collection.id)
                                }
                            }
                        )
                    }
                }
                .padding(.horizontal, 20)
            }
            
            // Save button
            VStack {
                Rectangle()
                    .fill(Color(.systemGray5))
                    .frame(height: 1)
                
                Button(action: {
                    HapticManager.shared.medium()
                    for collectionId in selectedCollections {
                        if let collection = store.collections.first(where: { $0.id == collectionId }) {
                            store.addRestaurantToCollection(restaurant: restaurant, collection: collection)
                        }
                    }
                    dismiss()
                }) {
                    HStack {
                        Text(selectedCollections.isEmpty ? "Select Collections" : "Save to \(selectedCollections.count) Collection\(selectedCollections.count == 1 ? "" : "s")")
                            .font(.newYorkButton())
                            .foregroundColor(selectedCollections.isEmpty ? .secondary : .white)
                    }
                    .frame(maxWidth: .infinity)
                    .frame(height: 50)
                    .background(
                        RoundedRectangle(cornerRadius: 12)
                            .fill(selectedCollections.isEmpty ? Color(.systemGray5) : Color.reelEatsAccent)
                    )
                }
                .disabled(selectedCollections.isEmpty)
                .padding(.horizontal, 20)
                .padding(.bottom, 20)
            }
        }
        .background(Color(.systemBackground))
        .presentationDetents([.height(500), .large])
        .presentationDragIndicator(.visible)
    }
}

struct AddToCollectionRow: View {
    let collection: Collection
    let restaurant: Restaurant
    let isSelected: Bool
    let onTap: () -> Void
    @EnvironmentObject var store: RestaurantStore
    
    private var isAlreadyInCollection: Bool {
        collection.restaurantIds.contains(restaurant.id)
    }
    
    var body: some View {
        Button(action: onTap) {
            HStack(spacing: 12) {
                // Collection icon/image
                RoundedRectangle(cornerRadius: 8)
                    .fill(Color.reelEatsAccent.opacity(0.2))
                    .overlay(
                        Text(collection.name.prefix(1).uppercased())
                            .font(.newYorkButton())
                            .foregroundColor(.reelEatsAccent)
                    )
                    .frame(width: 40, height: 40)
                
                VStack(alignment: .leading, spacing: 4) {
                    Text(collection.name)
                        .font(.newYorkButton())
                        .foregroundColor(.primary)
                    
                    Text("\(collection.restaurantIds.count) spots")
                        .font(.newYorkSecondary())
                        .foregroundColor(.secondary)
                }
                
                Spacer()
                
                // Spotify-style circle selector
                ZStack {
                    Circle()
                        .stroke(Color(.systemGray3), lineWidth: 2)
                        .frame(width: 20, height: 20)
                    
                    if isSelected {
                        Circle()
                            .fill(Color.reelEatsAccent)
                            .frame(width: 20, height: 20)
                        
                        Image(systemName: "checkmark")
                            .font(.system(size: 12, weight: .semibold))
                            .foregroundColor(.white)
                    }
                }
            }
            .padding(.vertical, 12)
            .padding(.horizontal, 16)
            .background(
                RoundedRectangle(cornerRadius: 12)
                    .fill(Color.clear)
            )
        }
        .buttonStyle(PlainButtonStyle())
        .disabled(false)
    }
}

// MARK: - Global Overlay Manager for Window-Level Presentation

class GlobalOverlayManager: ObservableObject {
    static let shared = GlobalOverlayManager()
    
    @Published var isPresented: Bool = false
    @Published var title: String = ""
    @Published var content: AnyView = AnyView(EmptyView())
    
    private init() {}
    
    func present<Content: View>(title: String, @ViewBuilder content: @escaping () -> Content) {
        self.title = title
        self.content = AnyView(content())
        withAnimation(.spring(response: 0.4, dampingFraction: 0.8)) {
            self.isPresented = true
        }
    }
    
    func dismiss() {
        withAnimation(.spring(response: 0.4, dampingFraction: 0.8)) {
            self.isPresented = false
        }
    }
}

// MARK: - Window-Level Bottom Sheet Overlay

struct WindowLevelBottomSheet: View {
    @ObservedObject private var overlayManager = GlobalOverlayManager.shared
    
    var body: some View {
        ZStack {
            if overlayManager.isPresented {
                // Full screen overlay that covers everything including nav bars
                Rectangle()
                    .fill(Color.black.opacity(0.3))
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                    .ignoresSafeArea(.all)
                    .onTapGesture {
                        overlayManager.dismiss()
                    }
                
                // Bottom sheet that truly starts from the absolute bottom
                VStack(spacing: 0) {
                    Spacer()
                    
                    // Content area with rounded top corners
                    VStack(spacing: 0) {
                        // Handle bar
                        RoundedRectangle(cornerRadius: 2.5)
                            .fill(Color(.systemGray3))
                            .frame(width: 40, height: 4)
                            .padding(.top, 8)
                            .padding(.bottom, 12)
                        
                        // Title with close button
                        HStack {
                            Text(overlayManager.title)
                                .font(.clashDisplayButtonTemp(size: 18))
                                .foregroundColor(.primary)
                            
                            Spacer()
                            
                            Button(action: {
                                overlayManager.dismiss()
                            }) {
                                Image(systemName: "xmark")
                                    .font(.clashDisplayBodyTemp())
                                    .foregroundColor(.secondary)
                                    .padding(8)
                                    .background(Color(.systemGray6))
                                    .clipShape(Circle())
                            }
                        }
                        .padding(.horizontal, 20)
                        .padding(.bottom, 20)
                        
                        // Dynamic content
                        overlayManager.content
                            .frame(maxWidth: .infinity)
                    }
                    .background(Color(.systemBackground))
                    .cornerRadius(16, corners: [.topLeft, .topRight])
                    .shadow(color: .black.opacity(0.15), radius: 12, x: 0, y: -4)
                    
                    // Solid extension to cover bottom nav bar and safe area
                    Rectangle()
                        .fill(Color(.systemBackground))
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                }
                .transition(.move(edge: .bottom))
                .zIndex(10000) // Highest possible z-index
            }
        }
        .animation(.spring(response: 0.4, dampingFraction: 0.8), value: overlayManager.isPresented)
    }
}


// MARK: - My Lists Filter Bar


// MARK: - My Lists Sort and Grid Toggle


// MARK: - View Toggle (List/Map)

struct ViewToggle: View {
    @Binding var showingListView: Bool
    @Binding var showingSearch: Bool
    @Binding var sortOrder: HomeTabView.SortOrder
    @State private var showingSortMenu = false
    
    var body: some View {
        HStack(spacing: 16) {
            // Search button
            Button(action: {
                HapticManager.shared.light()
                showingSearch = true
            }) {
                Image(systemName: "magnifyingglass")
                    .font(.newYorkButton(size: 18))
                    .foregroundColor(.primary)
                    .frame(width: 32, height: 32)
            }
            
            Spacer()
            
            // List/Map toggle buttons
            HStack(spacing: 8) {
                Button(action: {
                    HapticManager.shared.light()
                    showingListView = true
                }) {
                    Image(systemName: showingListView ? "list.bullet" : "list.bullet")
                        .font(.clashDisplayBodyTemp())
                        .foregroundColor(showingListView ? .primary : .secondary)
                        .frame(width: 24, height: 24)
                }
                
                Button(action: {
                    HapticManager.shared.light()
                    showingListView = false
                }) {
                    Image(systemName: !showingListView ? "map.fill" : "map")
                        .font(.clashDisplayBodyTemp())
                        .foregroundColor(!showingListView ? .primary : .secondary)
                        .frame(width: 24, height: 24)
                }
            }
            
            // Recents sort button (only for list view)
            if showingListView {
                Button(action: {
                    HapticManager.shared.light()
                    showingSortMenu.toggle()
                }) {
                    HStack(spacing: 6) {
                        Image(systemName: sortOrder.icon)
                            .font(.clashDisplaySecondaryTemp())
                        Text("Recents")
                            .font(.clashDisplaySecondaryTemp())
                    }
                    .foregroundColor(.secondary)
                }
                .actionSheet(isPresented: $showingSortMenu) {
                    ActionSheet(
                        title: Text("Sort By"),
                        buttons: HomeTabView.SortOrder.allCases.map { order in
                            .default(Text(order.rawValue)) {
                                sortOrder = order
                            }
                        } + [.cancel()]
                    )
                }
            }
        }
    }
}

// MARK: - My Lists Filter Bar


// MARK: - My Lists Sort and Grid Toggle


// MARK: - SpotsListView (Based on original SavedTabView)

struct SpotsListView: View {
    @Binding var selectedCategory: RestaurantCategory?
    var sortOrder: HomeTabView.SortOrder
    let onRestaurantSelect: (Restaurant) -> Void
    @EnvironmentObject var store: RestaurantStore
    
    var sortedRestaurants: [Restaurant] {
        var restaurants = store.savedRestaurants
        
        if let category = selectedCategory, category != .all {
            restaurants = restaurants.filter { $0.category == category }
        }
        
        switch sortOrder {
        case .recentlyAdded:
            return restaurants // Assuming they're already in added order
        case .recentlyViewed:
            return restaurants // TODO: Sort by recently viewed (would need view tracking)
        case .alphabetical:
            return restaurants.sorted { $0.name < $1.name }
        }
    }
    
    var body: some View {
        ScrollView {
            LazyVStack(spacing: 12) {
                ForEach(sortedRestaurants) { restaurant in
                    RestaurantListCard(restaurant: restaurant)
                        .environmentObject(store)
                        .onTapGesture {
                            HapticManager.shared.medium()
                            onRestaurantSelect(restaurant)
                        }
                }
            }
            .padding(.horizontal, 16)
            .padding(.top, 8)
            .padding(.bottom, 100)
        }
    }
}

// MARK: - My Lists Filter Bar


// MARK: - My Lists Sort and Grid Toggle


// MARK: - SpotsListContent (For embedded scrolling - no ScrollView wrapper)

struct SpotsListContent: View {
    @Binding var selectedCategory: RestaurantCategory?
    var sortOrder: HomeTabView.SortOrder
    let onRestaurantSelect: (Restaurant) -> Void
    @EnvironmentObject var store: RestaurantStore
    
    var sortedRestaurants: [Restaurant] {
        var restaurants = store.savedRestaurants
        
        if let category = selectedCategory, category != .all {
            restaurants = restaurants.filter { $0.category == category }
        }
        
        switch sortOrder {
        case .recentlyAdded:
            return restaurants // Assuming they're already in added order
        case .recentlyViewed:
            return restaurants // TODO: Sort by recently viewed (would need view tracking)
        case .alphabetical:
            return restaurants.sorted { $0.name < $1.name }
        }
    }
    
    var body: some View {
        // All Spots always shows list view
        LazyVStack(spacing: 12) {
            ForEach(sortedRestaurants) { restaurant in
                RestaurantListCard(restaurant: restaurant)
                    .environmentObject(store)
                    .onTapGesture {
                        HapticManager.shared.medium()
                        onRestaurantSelect(restaurant)
                    }
            }
        }
        .padding(.horizontal, 16)
    }
}

// MARK: - Restaurant Grid Card (Spotify-style square card)

struct RestaurantGridCard: View {
    let restaurant: Restaurant
    @EnvironmentObject var store: RestaurantStore
    @State private var showingOptions = false
    @State private var showingAddToCollection = false
    
    private var isInCollection: Bool {
        store.collections.contains { collection in
            collection.restaurantIds.contains(restaurant.id)
        }
    }
    
    var body: some View {
        VStack(spacing: 0) {
            // Image section - Square aspect ratio for consistency
            AsyncImage(url: URL(string: restaurant.imageURL)) { image in
                image
                    .resizable()
                    .aspectRatio(contentMode: .fill)
            } placeholder: {
                Rectangle()
                    .fill(restaurant.category.color.opacity(0.2))
                    .overlay(
                        Image(systemName: restaurant.category.icon)
                            .font(.clashDisplayRestaurantNameTemp(size: 20))
                            .foregroundColor(restaurant.category.color)
                    )
            }
            .aspectRatio(1.0, contentMode: .fit) // Square image
            .clipShape(RoundedRectangle(cornerRadius: 8))
            
            // Content section with fixed height
            VStack(alignment: .leading, spacing: 4) {
                Text(restaurant.name)
                    .font(.clashDisplaySmallTemp())
                    .foregroundColor(.primary)
                    .lineLimit(2)
                    .multilineTextAlignment(.leading)
                    .fixedSize(horizontal: false, vertical: true)
                
                HStack(spacing: 3) {
                    Spacer()
                    
                    // Collection indicator: red tick if in collection, grey + if not
                    Button(action: {
                        HapticManager.shared.light()
                        if isInCollection {
                            // TODO: Remove from collections
                        } else {
                            showingAddToCollection = true
                        }
                    }) {
                        Group {
                            if isInCollection {
                                Image(systemName: "checkmark.circle.fill")
                                    .foregroundColor(.reelEatsAccent)
                            } else {
                                Image(systemName: "plus.circle")
                                    .foregroundColor(.gray.opacity(0.6))
                            }
                        }
                        .font(.clashDisplayBodyTemp(size: 18))
                    }
                }
            }
            .padding(.horizontal, 4)
            .padding(.vertical, 6)
            .frame(maxWidth: .infinity, alignment: .leading)
            .frame(height: 50) // Fixed height for consistent card sizes
            
            Spacer(minLength: 0)
        }
        .frame(maxWidth: .infinity)
        .background(Color(.systemBackground))
        .cornerRadius(10)
        .overlay(
            RoundedRectangle(cornerRadius: 10)
                .stroke(Color(.systemGray6), lineWidth: 0.5)
        )
        .shadow(color: .black.opacity(0.08), radius: 3, x: 0, y: 1)
    }
}

// MARK: - CollectionsEmbeddedContent (For embedded scrolling)

struct CollectionsEmbeddedContent: View {
    @Binding var selectedCollection: Collection?
    let onRestaurantSelect: (Restaurant) -> Void
    var isListView: Bool = false
    var collectionFilter: CollectionFilterType = .all
    @EnvironmentObject var store: RestaurantStore
    
    private var filteredCollections: [Collection] {
        switch collectionFilter {
        case .all:
            return store.collections
        case .byMe:
            return store.collections.filter { $0.filterType == .byMe }
        case .byUs:
            return store.collections.filter { $0.filterType == .byUs }
        case .byOthers:
            return store.collections.filter { $0.filterType == .byOthers }
        }
    }
    
    var body: some View {
        if isListView {
            // List view - collections as rows
            LazyVStack(spacing: 12) {
                ForEach(filteredCollections) { collection in
                    CollectionListCard(collection: collection) {
                        HapticManager.shared.medium()
                        selectedCollection = collection
                    }
                }
            }
            .padding(.horizontal, 16)
        } else {
            // Grid view - collections as 2-column grid (default)
            LazyVGrid(columns: Array(repeating: GridItem(.flexible(), spacing: 16), count: 2), spacing: 16) {
                ForEach(filteredCollections) { collection in
                    CollectionAlbumCard(collection: collection)
                        .onTapGesture {
                            HapticManager.shared.medium()
                            selectedCollection = collection
                        }
                }
            }
            .padding(.horizontal, 16)
        }
    }
}

// MARK: - Collection List Card (for My Lists list view)

struct CollectionListCard: View {
    let collection: Collection
    let onTap: () -> Void
    @EnvironmentObject var store: RestaurantStore
    
    var restaurantsInCollection: [Restaurant] {
        return store.savedRestaurants.filter { restaurant in
            collection.restaurantIds.contains(restaurant.id)
        }
    }
    
    var body: some View {
        HStack(spacing: 12) {
            // Collection images - show first 3 restaurants
            HStack(spacing: -8) {
                ForEach(Array(restaurantsInCollection.prefix(3).enumerated()), id: \.element.id) { index, restaurant in
                    AsyncImage(url: URL(string: restaurant.imageURL)) { image in
                        image
                            .resizable()
                            .aspectRatio(contentMode: .fill)
                    } placeholder: {
                        Rectangle()
                            .fill(restaurant.category.color.opacity(0.3))
                            .overlay(
                                Image(systemName: restaurant.category.icon)
                                    .font(.clashDisplayBodyTemp())
                                    .foregroundColor(restaurant.category.color)
                            )
                    }
                    .frame(width: 50, height: 50)
                    .clipShape(RoundedRectangle(cornerRadius: 8))
                    .overlay(
                        RoundedRectangle(cornerRadius: 8)
                            .stroke(Color.white, lineWidth: 2)
                    )
                    .zIndex(Double(3 - index))
                }
            }
            
            // Collection info
            VStack(alignment: .leading, spacing: 4) {
                Text(collection.name)
                    .font(.clashDisplayButtonTemp(size: 18))
                    .foregroundColor(.primary)
                
                Text("\(restaurantsInCollection.count) spots")
                    .font(.clashDisplaySecondaryTemp())
                    .foregroundColor(.secondary)
            }
            
            Spacer()
            
            // Arrow
            Image(systemName: "chevron.right")
                .font(.clashDisplaySecondaryTemp())
                .foregroundColor(.secondary)
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 12)
        .background(Color(.systemBackground))
        .cornerRadius(12)
        .overlay(
            RoundedRectangle(cornerRadius: 12)
                .stroke(Color(.systemGray5), lineWidth: 1)
        )
        .shadow(color: .black.opacity(0.05), radius: 4, x: 0, y: 2)
        .onTapGesture {
            onTap()
        }
    }
}

// MARK: - MapView (Wrapper for MapTabView)

struct MapView: View {
    @Binding var selectedRestaurant: Restaurant?
    @EnvironmentObject var store: RestaurantStore
    
    var body: some View {
        MapTabView(selectedRestaurant: $selectedRestaurant)
            .environmentObject(store)
    }
}

// MARK: - CollectionsView

struct CollectionsView: View {
    @Binding var selectedCollection: Collection?
    let onRestaurantSelect: (Restaurant) -> Void
    @EnvironmentObject var store: RestaurantStore
    
    var body: some View {
        ScrollView {
            LazyVGrid(columns: Array(repeating: GridItem(.flexible(), spacing: 16), count: 2), spacing: 16) {
                ForEach(store.collections) { collection in
                    CollectionAlbumCard(collection: collection)
                        .onTapGesture {
                            HapticManager.shared.medium()
                            selectedCollection = collection
                        }
                }
            }
            .padding(.horizontal, 16)
            .padding(.top, 16)
            .padding(.bottom, 100)
        }
    }
}

// MARK: - My Lists Filter Bar


// MARK: - My Lists Sort and Grid Toggle


// MARK: - SearchView (Placeholder)

struct SearchView: View {
    @EnvironmentObject var store: RestaurantStore
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        NavigationView {
            VStack {
                Text("Search functionality coming soon!")
                    .font(.clashDisplayBodyTemp(size: 18))
                    .foregroundColor(.secondary)
                    .padding(.top, 50)
                
                Spacer()
            }
            .navigationTitle("Search")
            .navigationBarTitleDisplayMode(.inline)
            .navigationBarItems(
                trailing: Button("Done") {
                    dismiss()
                }
            )
        }
    }
}

// MARK: - My Lists Filter Bar


// MARK: - My Lists Sort and Grid Toggle


// MARK: - Global Enums

enum SavedViewType: String, CaseIterable {
    case allSpots = "All Spots"
    case collections = "Collections"
}

enum CollectionFilterType: String, CaseIterable {
    case all = "All"
    case byMe = "By Me"
    case byUs = "By Us"
    case byOthers = "By Others"
}

enum SortOption: String, CaseIterable {
    case recents = "Recents"
    case recentlyAdded = "Recently added"
    case alphabetical = "Alphabetical"
    case rating = "Rating (high to low)"
    case newest = "Newest"
    
    var displayName: String {
        return self.rawValue
    }
    
    var icon: String {
        switch self {
        case .recents: return "clock"
        case .recentlyAdded: return "plus.circle"
        case .alphabetical: return "textformat"
        case .rating: return "star.fill"
        case .newest: return "calendar"
        }
    }
}

// MARK: - My Lists Filter Bar


// MARK: - My Lists Sort and Grid Toggle


// MARK: - Saved Tab View (Legacy - now used as SpotsListView)

struct SavedTabView: View {
    let onRestaurantSelect: (Restaurant) -> Void
    @EnvironmentObject var store: RestaurantStore
    @State private var selectedCategory: RestaurantCategory? = .all
    @State private var showingDetail = false
    @State private var selectedRestaurant: Restaurant?
    @State private var isAnimating = false
    @State private var selectedView: SavedViewType = .allSpots
    @State private var selectedCollection: Collection?
    @State private var showingProfile = false
    @State private var sortOption: SortOption = .recents
    @State private var showingSortOptions = false
    // Grid/List toggle removed - using dedicated views for All Spots (list) and Collections (grid)
    @State private var showingRestaurantDetail = false
    @State private var collectionFilter: CollectionFilterType = .all
    // Collections always use grid view
    
    
    private var headerView: some View {
        VStack(spacing: 0) {
            HStack {
                // ReelEats logo with mascot
                HStack(spacing: 8) {
                    MascotView(size: 28)
                    
                    Text("ReelEats")
                        .font(.poppinsLogoTemp(size: 22))
                        .fontWeight(.black)
                        .foregroundColor(.primary)
                        .shadow(color: .primary.opacity(0.1), radius: 0, x: 0.5, y: 0.5)
                }
                
                Spacer()
                
                // Profile button with person icon
                Button(action: {
                    HapticManager.shared.light()
                    showingProfile = true
                }) {
                    Circle()
                        .fill(Color.reelEatsAccent.opacity(0.2))
                        .frame(width: 32, height: 32)
                        .overlay(
                            Image(systemName: "person.fill")
                                .font(.clashDisplayBodyTemp())
                                .foregroundColor(.reelEatsAccent)
                        )
                }
            }
            .padding(.horizontal, 20)
            .padding(.top, 50)
            .padding(.bottom, 16)
        }
        .background(Color(.systemBackground))
    }
    
    private var sortOptionsDropdown: some View {
        Group {
            if showingSortOptions {
                VStack(spacing: 0) {
                    ForEach(SortOption.allCases, id: \.self) { option in
                        Button(action: {
                            HapticManager.shared.selection()
                            sortOption = option
                            withAnimation(.easeInOut(duration: 0.2)) {
                                showingSortOptions = false
                            }
                        }) {
                            HStack {
                                Image(systemName: option.icon)
                                    .font(.clashDisplayBodyTemp())
                                    .foregroundColor(sortOption == option ? .black : .secondary)
                                    .frame(width: 20)
                                
                                Text(option.rawValue)
                                    .font(.poppinsBodyTemp(size: 16))
                                    .foregroundColor(sortOption == option ? .black : .primary)
                                
                                Spacer()
                                
                                if sortOption == option {
                                    Image(systemName: "checkmark")
                                        .font(.clashDisplaySecondaryTemp())
                                        .foregroundColor(.black)
                                }
                            }
                            .padding(.horizontal, 20)
                            .padding(.vertical, 12)
                            .background(sortOption == option ? Color.black.opacity(0.05) : Color.clear)
                        }
                        .buttonStyle(PlainButtonStyle())
                        
                        if option != SortOption.allCases.last {
                            Divider()
                                .padding(.horizontal, 20)
                        }
                    }
                }
                .background(Color(.systemBackground))
                .cornerRadius(12)
                .shadow(color: .black.opacity(0.1), radius: 8, x: 0, y: 4)
                .padding(.horizontal, 20)
                .padding(.bottom, 8)
                .transition(.opacity.combined(with: .scale(scale: 0.95)))
            }
        }
    }
    
    var body: some View {
        GeometryReader { geometry in
            VStack(spacing: 0) {
                // Fixed header with only logo and profile - positioned at very top
                headerView
                
                // Sort options dropdown
                sortOptionsDropdown
                
                // Content area
                if selectedView == .allSpots {
                    if sortedFilteredRestaurants.isEmpty {
                        EmptyStateView()
                            .transition(.opacity)
                    } else {
                        // All Spots always uses list view
                        RestaurantListView(
                                restaurants: sortedFilteredRestaurants,
                                onRestaurantTap: { restaurant in
                                    selectedRestaurant = restaurant
                                    showingRestaurantDetail = true
                                }
                            )
                            .transition(.opacity)
                    }
                } else {
                    // Collections always use grid view
                    CollectionsGridView(
                        collections: filteredCollections,
                        onCollectionTap: { collection in
                            selectedCollection = collection
                        }
                    )
                    .transition(.opacity)
                }
            }
        }
    }
    
    private var filteredRestaurants: [Restaurant] {
        guard let category = selectedCategory, category != .all else { return store.savedRestaurants }
        return store.savedRestaurants.filter { $0.category == category }
    }
    
    private var filteredCollections: [Collection] {
        switch collectionFilter {
        case .all:
            return store.collections
        case .byMe:
            return store.collections.filter { $0.filterType == .byMe }
        case .byUs:
            return store.collections.filter { $0.filterType == .byUs }
        case .byOthers:
            return store.collections.filter { $0.filterType == .byOthers }
        }
    }
    
    private var sortedFilteredRestaurants: [Restaurant] {
        let filtered = filteredRestaurants
        switch sortOption {
        case .recents:
            // For recents, we'll show them in reverse order (most recent first)
            return filtered.reversed()
        case .recentlyAdded:
            // Same as recents for now, could be enhanced with actual date tracking
            return filtered.reversed()
        case .alphabetical:
            return filtered.sorted { $0.name.localizedCaseInsensitiveCompare($1.name) == .orderedAscending }
        case .rating:
            // Sort by user rating, high to low
            return filtered.sorted { 
                let rating1 = store.getUserData(for: $0.id)?.userRating ?? 0.0
                let rating2 = store.getUserData(for: $1.id)?.userRating ?? 0.0
                return rating1 > rating2
            }
        case .newest:
            // Same as recently added
            return filtered.reversed()
        }
    }
}

// MARK: - My Lists Filter Bar


// MARK: - My Lists Sort and Grid Toggle



// MARK: - Uber-Style Bottom Sheet

struct UberStyleBottomSheet<Content: View>: View {
    @Binding var isPresented: Bool
    let title: String
    let content: () -> Content
    
    var body: some View {
        ZStack {
            if isPresented {
                // Background overlay
                Color.black.opacity(0.3)
                    .ignoresSafeArea()
                    .onTapGesture {
                        withAnimation(.easeInOut(duration: 0.3)) {
                            isPresented = false
                        }
                    }
                
                // Bottom sheet
                VStack(spacing: 0) {
                    Spacer()
                    
                    VStack(spacing: 0) {
                        // Handle bar
                        ConsistentDragHandle()
                        
                        // Title
                        HStack {
                            Text(title)
                                .font(.clashDisplayButtonTemp(size: 20))
                                .foregroundColor(.primary)
                            
                            Spacer()
                            
                            Button(action: {
                                withAnimation(.easeInOut(duration: 0.3)) {
                                    isPresented = false
                                }
                            }) {
                                Image(systemName: "xmark")
                                    .font(.clashDisplayBodyTemp())
                                    .foregroundColor(.secondary)
                                    .padding(8)
                                    .background(Color(.systemGray6))
                                    .clipShape(Circle())
                            }
                        }
                        .padding(.horizontal, 20)
                        .padding(.bottom, 20)
                        
                        // Content
                        content()
                    }
                    .background(Color(.systemBackground))
                    .cornerRadius(20, corners: [.topLeft, .topRight])
                    .shadow(color: .black.opacity(0.1), radius: 10, x: 0, y: -5)
                }
                .transition(.move(edge: .bottom).combined(with: .opacity))
            }
        }
        .animation(.easeInOut(duration: 0.3), value: isPresented)
    }
}

// MARK: - Filter Option Item

struct FilterOptionItem: View {
    let title: String
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            HStack {
                Text(title)
                    .font(.clashDisplayBodyTemp())
                    .foregroundColor(.primary)
                
                Spacer()
                
                if isSelected {
                    Image(systemName: "checkmark")
                        .font(.clashDisplayButtonTemp())
                        .foregroundColor(.blue)
                }
            }
            .padding(.horizontal, 20)
            .padding(.vertical, 16)
            .background(isSelected ? Color.blue.opacity(0.05) : Color.clear)
        }
        .buttonStyle(PlainButtonStyle())
    }
}

// MARK: - Google-Style Cuisine Grid

struct GoogleStyleCuisineGrid: View {
    let cuisineOptions: [String]
    let selectedOptions: Set<String>
    @Binding var isPresented: Bool
    let onSelection: (String) -> Void
    
    // Cuisine to emoji mapping
    private func emojiForCuisine(_ cuisine: String) -> String {
        switch cuisine.lowercased() {
        case "italian":
            return "🍝"
        case "asian":
            return "🍜"
        case "mexican":
            return "🌮"
        case "korean":
            return "🍲"
        case "chinese":
            return "🥡"
        case "pizza":
            return "🍕"
        case "burgers":
            return "🍔"
        case "cafe":
            return "☕"
        case "fine dining":
            return "🥂"
        case "brunch":
            return "🥞"
        case "bars":
            return "🍸"
        case "healthy":
            return "🥗"
        case "desserts":
            return "🍰"
        case "seafood":
            return "🦐"
        case "bbq":
            return "🍖"
        default:
            return "🍽️"
        }
    }
    
    var body: some View {
        VStack(spacing: 0) {
            ScrollView {
                LazyVGrid(columns: Array(repeating: GridItem(.flexible(), spacing: 12), count: 3), spacing: 12) {
                    ForEach(cuisineOptions, id: \.self) { cuisine in
                        CuisineGridItem(
                            emoji: emojiForCuisine(cuisine),
                            title: cuisine,
                            isSelected: selectedOptions.contains(cuisine)
                        ) {
                            onSelection(cuisine)
                        }
                    }
                }
                .padding(.horizontal, 20)
                .padding(.top, 16)
                .padding(.bottom, 24)
            }
            .frame(maxHeight: 480) // Increased height to accommodate 15 items
            
            // Apply and Reset buttons - always visible at bottom
            HStack(spacing: 12) {
                Button(action: {
                    // Reset all selections
                    for option in selectedOptions {
                        onSelection(option)
                    }
                }) {
                    Text("Reset")
                        .font(.newYorkButton())
                        .foregroundColor(.primary)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 16)
                        .background(Color(.systemGray6))
                        .cornerRadius(12)
                }
                
                Button(action: {
                    withAnimation(.easeInOut(duration: 0.3)) {
                        isPresented = false
                    }
                    GlobalOverlayManager.shared.dismiss()
                }) {
                    Text("Apply")
                        .font(.newYorkButton())
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 16)
                        .background(Color.reelEatsAccent)
                        .cornerRadius(12)
                }
            }
            .padding(.horizontal, 20)
            .padding(.bottom, 20)
            .background(Color(.systemBackground))
        }
    }
}

// MARK: - Cuisine Grid Item

struct CuisineGridItem: View {
    let emoji: String
    let title: String
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            VStack(spacing: 6) {
                Text(emoji)
                    .font(.clashDisplayHeaderTemp(size: 24))
                
                Text(title)
                    .font(.clashDisplayCaptionTemp(size: 12))
                    .foregroundColor(isSelected ? .white : .primary)
                    .multilineTextAlignment(.center)
                    .lineLimit(2)
            }
            .frame(maxWidth: .infinity, minHeight: 70)
            .padding(.horizontal, 8)
            .padding(.vertical, 12)
            .background(
                RoundedRectangle(cornerRadius: 12)
                    .fill(isSelected ? Color.blue : Color(.systemGray6))
            )
            .overlay(
                RoundedRectangle(cornerRadius: 12)
                    .stroke(isSelected ? Color.blue : Color.clear, lineWidth: 2)
            )
            .scaleEffect(isSelected ? 0.95 : 1.0)
            .animation(.easeInOut(duration: 0.2), value: isSelected)
        }
        .buttonStyle(PlainButtonStyle())
    }
}

// MARK: - Category Filter Button

struct CategoryFilterButton: View {
    let category: RestaurantCategory
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            HStack(spacing: 8) {
                // Modern emoji + icon combination
                HStack(spacing: 4) {
                    Text(category.emoji)
                        .font(.clashDisplayBodyTemp())
                    
                    if isSelected {
                        Image(systemName: category.icon)
                            .font(.clashDisplayCaptionTemp())
                            .foregroundColor(.white)
                    }
                }
                
                Text(category.rawValue)
                    .font(.poppinsAccentTemp(size: 15))
                    .foregroundColor(isSelected ? .white : .primary)
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 10)
            .background(
                Group {
                    if isSelected {
                        LinearGradient(
                            colors: category.gradientColors,
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    } else {
                        LinearGradient(
                            colors: [Color(.systemGray6), Color(.systemGray5)],
                            startPoint: .top,
                            endPoint: .bottom
                        )
                    }
                }
            )
            .clipShape(Capsule())
            .overlay(
                Capsule()
                    .stroke(
                        isSelected ? 
                            category.color.opacity(0.3) : 
                            Color.black.opacity(0.08),
                        lineWidth: 1
                    )
            )
            .shadow(
                color: isSelected ? category.color.opacity(0.3) : .black.opacity(0.1),
                radius: isSelected ? 8 : 3,
                x: 0,
                y: isSelected ? 4 : 2
            )
        }
        .buttonStyle(PlainButtonStyle())
        .scaleEffect(isSelected ? 1.05 : 1.0)
        .animation(.spring(response: 0.3, dampingFraction: 0.7), value: isSelected)
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
                        .font(.clashDisplayBodyTemp())
                        .foregroundColor(.orange)
                    
                    Spacer()
                    
                    // Loading indicator
                    ProgressView()
                        .scaleEffect(0.8)
                        .tint(.black)
                }
                
                VStack(alignment: .leading, spacing: 8) {
                    Text("Import 3 posts")
                        .font(.clashDisplayCardTitleTemp())
                        .foregroundColor(.primary)
                    
                    Text("How to share from other apps")
                        .font(.clashDisplayBodyTemp())
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

// MARK: - My Lists Filter Bar


// MARK: - My Lists Sort and Grid Toggle


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

// MARK: - My Lists Filter Bar


// MARK: - My Lists Sort and Grid Toggle


// MARK: - Collection Restaurant Card (for grid view in collections)

struct CollectionRestaurantCard: View {
    let restaurant: Restaurant
    let onTap: () -> Void
    @EnvironmentObject var store: RestaurantStore
    @State private var imageLoaded = false
    @State private var showingRatingSlider = false
    @State private var showingOptions = false
    @State private var showingAddToCollection = false
    @State private var tempRating: Double = 0.0
    
    private var isInCollection: Bool {
        store.collections.contains { collection in
            collection.restaurantIds.contains(restaurant.id)
        }
    }
    
    var body: some View {
        Button(action: onTap) {
            VStack(spacing: 0) {
                // Restaurant image
                AsyncImage(url: URL(string: restaurant.imageURL)) { image in
                    image
                        .resizable()
                        .aspectRatio(contentMode: .fill)
                        .onAppear {
                            withAnimation(.easeOut(duration: 0.3)) {
                                imageLoaded = true
                            }
                        }
                } placeholder: {
                    LinearGradient(
                        colors: [restaurant.category.color.opacity(0.2), restaurant.category.color.opacity(0.05)],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                    .overlay(
                        Text(restaurant.emoji)
                            .font(.clashDisplayHeaderTemp(size: 32))
                    )
                }
                .frame(height: 120)
                .clipped()
                .overlay(
                    // Collection indicator - bottom right only
                    VStack {
                        Spacer()
                        
                        HStack {
                            Spacer()
                            
                            Button(action: {
                                HapticManager.shared.light()
                                if isInCollection {
                                    // TODO: Remove from collections
                                } else {
                                    // TODO: Add to collection
                                    showingOptions = true
                                }
                            }) {
                                Group {
                                    if isInCollection {
                                        Image(systemName: "checkmark.circle.fill")
                                            .foregroundColor(.reelEatsAccent)
                                    } else {
                                        Image(systemName: "plus.circle")
                                            .foregroundColor(.gray.opacity(0.6))
                                    }
                                }
                                .font(.clashDisplayBodyTemp(size: 18))
                            }
                        }
                        .padding(.trailing, 12)
                        .padding(.bottom, 12)
                    }
                )
                
                // Restaurant info with inline visit status button
                VStack(alignment: .leading, spacing: 6) {
                    Text(restaurant.name)
                        .font(.poppinsRestaurantNameTemp(size: 17))
                        .foregroundColor(.primary)
                        .lineLimit(2)
                    
                    HStack {
                        Text(locationDisplay)
                            .font(.poppinsSecondaryTemp(size: 13))
                            .foregroundColor(.secondary)
                        
                        Spacer()
                        
                        // Visit status button moved here
                        Button(action: {
                            HapticManager.shared.light()
                            toggleVisitStatus()
                        }) {
                            Image(systemName: userVisitStatus.icon)
                                .font(.clashDisplayBodyTemp())
                                .foregroundColor(userVisitStatus == .visited ? .green : .gray)
                                .frame(width: 24, height: 24)
                                .background(
                                    Circle()
                                        .fill(userVisitStatus == .visited ? Color.green.opacity(0.2) : Color.gray.opacity(0.1))
                                )
                        }
                    }
                }
                .padding(.horizontal, 4)
            }
            .padding(14)
            .background(
                RoundedRectangle(cornerRadius: 18)
                    .fill(Color(.systemBackground))
                    .shadow(color: .black.opacity(0.1), radius: 10, x: 0, y: 4)
            )
            .scaleEffect(imageLoaded ? 1.0 : 0.95)
            .opacity(imageLoaded ? 1.0 : 0.8)
        }
        .buttonStyle(PlainButtonStyle())
        .sheet(isPresented: $showingRatingSlider) {
            RatingSliderView(
                restaurant: restaurant,
                currentRating: $tempRating,
                onSave: { rating, notes in
                    store.updateUserRating(for: restaurant.id, rating: rating)
                    showingRatingSlider = false
                }
            )
            .presentationDetents([.height(450)])
            .presentationDragIndicator(.visible)
        }
    }
    
    private var locationDisplay: String {
        let components = restaurant.address.components(separatedBy: ", ")
        if components.count >= 2 {
            let suburbAndMore = components[1].trimmingCharacters(in: .whitespaces)
            let parts = suburbAndMore.split(separator: " ")
            
            if parts.count >= 2 {
                let suburb = String(parts[0])
                let state = String(parts[1])
                return "\(suburb) \(state)"
            }
        }
        return restaurant.address
    }
    
    private var userVisitStatus: VisitStatus {
        store.getUserData(for: restaurant.id)?.visitStatus ?? .wantToTry
    }
    
    private var userRating: Double {
        store.getUserData(for: restaurant.id)?.userRating ?? 0.0
    }
    
    private func toggleVisitStatus() {
        let currentStatus = userVisitStatus
        let newStatus: VisitStatus = currentStatus == .wantToTry ? .visited : .wantToTry
        
        store.updateVisitStatus(for: restaurant.id, status: newStatus)
        
        // If marking as visited, show rating slider
        if newStatus == .visited {
            tempRating = userRating
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                showingRatingSlider = true
            }
        }
        if newStatus == .visited {
            tempRating = userRating
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                showingRatingSlider = true
            }
        }
    }
}

// MARK: - My Lists Filter Bar


// MARK: - My Lists Sort and Grid Toggle


// MARK: - Collection Detail View (Spotify-like Full Screen)

struct CollectionDetailView: View {
    let collection: Collection
    let onRestaurantSelect: (Restaurant) -> Void
    @EnvironmentObject var store: RestaurantStore
    @Environment(\.dismiss) private var dismiss
    @State private var showingAddSpots = false
    @State private var showingShareSheet = false
    @State private var showingEditCollection = false
    @State private var selectedCategory: RestaurantCategory? = nil
    @State private var selectedRestaurant: Restaurant?
    @State private var showingDetail = false
    @State private var showingRestaurantDetail = false
    @State private var selectedFilter: CollectionFilterType = .byMe
    @State private var selectedSort: SortOption = .alphabetical
    // Filter dropdown states
    @State private var showingCuisineDropdown = false
    @State private var showingDistanceDropdown = false
    @State private var showingPriceDropdown = false
    @State private var showingCollectionsDropdown = false
    
    private var collectionSpots: [Restaurant] {
        let filtered = store.savedRestaurants.filter { restaurant in
            collection.restaurantIds.contains(restaurant.id)
        }
        
        let categoryFiltered = if let category = selectedCategory {
            filtered.filter { $0.category == category }
        } else {
            filtered
        }
        
        // Apply sorting
        switch selectedSort {
        case .alphabetical:
            return categoryFiltered.sorted { $0.name < $1.name }
        case .newest:
            return categoryFiltered // For collections, newest means recently added - would need timestamps
        case .rating:
            return categoryFiltered.sorted { (lhs, rhs) in
                let lhsRating = store.getUserData(for: lhs.id)?.userRating ?? 0.0
                let rhsRating = store.getUserData(for: rhs.id)?.userRating ?? 0.0
                return lhsRating > rhsRating
            }
        case .recents:
            return categoryFiltered // Default order
        case .recentlyAdded:
            return categoryFiltered // Default order - would need timestamps to implement properly
        }
    }
    
    @ViewBuilder
    private var restaurantListSection: some View {
        if collectionSpots.isEmpty {
            VStack(spacing: 20) {
                Text("No spots in this collection")
                    .font(.clashDisplayBodyTemp(size: 18))
                    .foregroundColor(.secondary)
                
                Button("Add Spots") {
                    showingAddSpots = true
                }
                .font(.clashDisplayButtonTemp())
                .foregroundColor(.white)
                .padding(.horizontal, 20)
                .padding(.vertical, 12)
                .background(Color.black)
                .cornerRadius(25)
            }
            .padding(.top, 50)
            .padding(.bottom, 100)
        } else {
            // List view - exactly like All Spots with same card layout
            LazyVStack(spacing: 12) {
                ForEach(collectionSpots) { restaurant in
                    RestaurantListCard(restaurant: restaurant)
                        .environmentObject(store)
                        .onTapGesture {
                            HapticManager.shared.medium()
                            selectedRestaurant = restaurant
                            showingRestaurantDetail = true
                        }
                }
            }
            .padding(.horizontal, 16)
            .padding(.top, 12)
            .padding(.bottom, 100)
        }
    }
    
    var body: some View {
        ScrollView {
            VStack(spacing: 0) {
                headerSection
                contentSection
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
        .sheet(isPresented: $showingRestaurantDetail) {
            if let restaurant = selectedRestaurant {
                FullScreenRestaurantDetailView(restaurant: restaurant)
                    .environmentObject(store)
            }
        }
    }
    
    private var headerSection: some View {
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
                            .font(.clashDisplayRestaurantNameTemp(size: 20))
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
                            .font(.clashDisplayHeaderTemp(size: 60))
                            .foregroundColor(.white.opacity(0.8))
                    )
                    .shadow(color: .black.opacity(0.3), radius: 15, x: 0, y: 8)
                
                Spacer().frame(height: 20)
            }
        }
    }
    
    private var contentSection: some View {
        VStack(alignment: .leading, spacing: 24) {
                    VStack(alignment: .leading, spacing: 16) {
                        // Collection title (increased spacing from banner)
                        Text(collection.name)
                            .font(.poppinsCollectionNameTemp(size: 28))
                            .foregroundColor(.primary)
                            .padding(.horizontal, 20)
                            .padding(.top, 8)
                        
                        // Creator and collaborators section (like Spotify)
                        HStack(spacing: 12) {
                            // Creator profile circle (smaller)
                            Circle()
                                .fill(Color.reelEatsAccent)
                                .frame(width: 28, height: 28)
                                .overlay(
                                    Text("J")
                                        .font(.clashDisplaySecondaryTemp())
                                        .foregroundColor(.white)
                                )
                            
                            // Collaborator circles (colored with letters, smaller)
                            ForEach(Array(["M", "A"].enumerated()), id: \.offset) { index, letter in
                                let colors: [Color] = [.blue, .green, .orange, .purple]
                                Circle()
                                    .fill(colors[index % colors.count])
                                    .frame(width: 28, height: 28)
                                    .overlay(
                                        Text(letter)
                                            .font(.clashDisplaySecondaryTemp())
                                            .foregroundColor(.white)
                                    )
                            }
                            
                            Spacer()
                        }
                        .padding(.horizontal, 20)
                        
                        // Spots count (like playlist duration)
                        Text("\(collectionSpots.count) spots")
                            .font(.clashDisplaySecondaryTemp())
                            .foregroundColor(.secondary)
                            .padding(.horizontal, 20)
                    }
                    
                    // Action buttons row (exactly as requested)
                    HStack(spacing: 20) {
                        // Add Collaborators (same icon as Spotify)
                        Button(action: {}) {
                            Image(systemName: "person.badge.plus")
                                .font(.clashDisplayHeaderTemp())
                                .foregroundColor(.secondary)
                        }
                        
                        // Share button
                        Button(action: {
                            showingShareSheet = true
                        }) {
                            Image(systemName: "square.and.arrow.up")
                                .font(.clashDisplayHeaderTemp())
                                .foregroundColor(.secondary)
                        }
                        
                        // Add button (add a new spot)
                        Button(action: {
                            showingAddSpots = true
                        }) {
                            Image(systemName: "plus")
                                .font(.clashDisplayHeaderTemp())
                                .foregroundColor(.secondary)
                        }
                        
                        // Edit button (edit collection i.e. title, picture)
                        Button(action: {
                            showingEditCollection = true
                        }) {
                            Image(systemName: "pencil")
                                .font(.clashDisplayHeaderTemp())
                                .foregroundColor(.secondary)
                        }
                        
                        Spacer()
                    }
                    .padding(.horizontal, 20)
                    
                    // Filter pills (matching All Spots style)
                    FilterBar(
                        showingCuisineDropdown: $showingCuisineDropdown,
                        showingDistanceDropdown: $showingDistanceDropdown,
                        showingPriceDropdown: $showingPriceDropdown,
                        showingCollectionsDropdown: $showingCollectionsDropdown
                    )
                    .padding(.top, 8)
                    
                    // Sort section only
                    HStack(spacing: 16) {
                        // Sort dropdown
                        Menu {
                            ForEach(SortOption.allCases, id: \.self) { option in
                                Button(action: {
                                    selectedSort = option
                                }) {
                                    HStack {
                                        Text(option.displayName)
                                        if selectedSort == option {
                                            Image(systemName: "checkmark")
                                        }
                                    }
                                }
                            }
                        } label: {
                            HStack(spacing: 6) {
                                Image(systemName: "arrow.up.arrow.down")
                                    .font(.clashDisplaySecondaryTemp())
                                Text(selectedSort.displayName)
                                    .font(.clashDisplaySecondaryTemp())
                            }
                            .foregroundColor(.primary)
                        }
                        
                        Spacer()
                    }
                    .padding(.horizontal, 20)
                    .padding(.top, 12)
                    
                    // Restaurant list with grid/list views
                    restaurantListSection
        }
    }
}

// MARK: - My Lists Filter Bar


// MARK: - My Lists Sort and Grid Toggle

// MARK: - Custom Restaurant Options Sheet (ReelEats Style)

struct RestaurantOptionsSheet: View {
    let restaurant: Restaurant
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        VStack(spacing: 0) {
            // Handle indicator
            ConsistentDragHandle()
            
            // Restaurant header
            HStack(spacing: 12) {
                LinearGradient(
                    colors: [restaurant.category.color.opacity(0.2), restaurant.category.color.opacity(0.05)],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
                .overlay(
                    Text(restaurant.emoji)
                        .font(.clashDisplayHeaderTemp(size: 22))
                )
                .frame(width: 50, height: 50)
                .clipShape(RoundedRectangle(cornerRadius: 8))
                
                VStack(alignment: .leading, spacing: 4) {
                    Text(restaurant.name)
                        .font(.poppinsRestaurantNameTemp(size: 16))
                        .foregroundColor(.primary)
                        .lineLimit(1)
                    
                    Text(restaurant.description)
                        .font(.clashDisplaySecondaryTemp())
                        .italic()
                        .foregroundColor(.secondary)
                        .lineLimit(1)
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
                            .font(.clashDisplayBodyTemp(size: 18))
                            .foregroundColor(.primary)
                    )
                
                VStack(alignment: .leading, spacing: 2) {
                    Text(title)
                        .font(.clashDisplayBodyTemp())
                        .foregroundColor(.primary)
                    
                    Text(subtitle)
                        .font(.clashDisplaySecondaryTemp())
                        .foregroundColor(.secondary)
                }
                
                Spacer()
                
                Image(systemName: "chevron.right")
                    .font(.clashDisplaySecondaryTemp())
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
        VStack(alignment: .leading, spacing: 12) {
            // Emoji display with enhanced styling
            LinearGradient(
                colors: [restaurant.category.color.opacity(0.2), restaurant.category.color.opacity(0.05)],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .overlay(
                Text(restaurant.emoji)
                    .font(.clashDisplayHeaderTemp(size: 80))
            )
            .frame(height: 185)
            .clipShape(RoundedRectangle(cornerRadius: 16))
            .overlay(
                // Subtle inner shadow for depth
                RoundedRectangle(cornerRadius: 16)
                    .stroke(Color.black.opacity(0.05), lineWidth: 0.5)
            )
            
            // Enhanced spot info
            VStack(alignment: .leading, spacing: 6) {
                Text(restaurant.name.components(separatedBy: " ").prefix(3).joined(separator: " "))
                    .font(.poppinsRestaurantNameTemp(size: 17))
                    .foregroundColor(.primary)
                    .lineLimit(2)
                
                HStack(spacing: 6) {
                    // Enhanced star rating
                    HStack(spacing: 2) {
                        Image(systemName: "star.fill")
                            .font(.clashDisplaySmallTemp())
                            .foregroundColor(.orange)
                        
                        Text(String(format: "%.1f", restaurant.rating))
                            .font(.poppinsSecondaryTemp(size: 14))
                            .foregroundColor(.primary)
                            .fontWeight(.medium)
                    }
                    
                    Text("•")
                        .font(.clashDisplayCaptionTemp())
                        .foregroundColor(.secondary.opacity(0.6))
                    
                    Text(restaurant.description)
                        .font(.poppinsSecondaryTemp(size: 14))
                        .foregroundColor(.secondary)
                }
            }
            .padding(.horizontal, 2)
        }
        .padding(16)
        .background(
            RoundedRectangle(cornerRadius: 20)
                .fill(Color(.systemBackground))
                .shadow(color: .black.opacity(0.08), radius: 12, x: 0, y: 4)
                .shadow(color: .black.opacity(0.04), radius: 2, x: 0, y: 1)
        )
        .overlay(
            RoundedRectangle(cornerRadius: 20)
                .stroke(Color.black.opacity(0.03), lineWidth: 1)
        )
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
                            .font(.clashDisplayCaptionTemp(size: 10))
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

// MARK: - My Lists Filter Bar


// MARK: - My Lists Sort and Grid Toggle


// MARK: - Empty Collection State

struct EmptyCollectionState: View {
    let collectionName: String
    
    var body: some View {
        VStack(spacing: 20) {
            Image(systemName: "folder")
                .font(.clashDisplayHeaderTemp(size: 60))
                .foregroundColor(.secondary.opacity(0.5))
            
            VStack(spacing: 8) {
                Text("No spots yet")
                    .font(.clashDisplayButtonTemp(size: 20))
                    .foregroundColor(.primary)
                
                Text("Start adding spots to your \(collectionName) collection")
                    .font(.clashDisplayBodyTemp())
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
    
    // Collaborative visuals removed per request
    private var isCollaborative: Bool { false }
    
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
                        Spacer()
                        Text(collection.name.lowercased())
                            .font(.poppinsCollectionNameTemp(size: 18))
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
                        .font(.poppinsCollectionNameTemp(size: 16))
                        .foregroundColor(.primary)
                        .lineLimit(1)
                    
                    Spacer()
                    
                    if isCollaborative {
                        Image(systemName: "person.2.fill")
                            .font(.clashDisplayCaptionTemp())
                            .foregroundColor(.secondary)
                    }
                }
                
                Text("\(collection.restaurantIds.count) spots • \(collection.creatorText)")
                    .font(.clashDisplaySecondaryTemp())
                    .foregroundColor(.secondary)
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(.horizontal, 4)
            .padding(.top, 8)
        }
    }
}

// MARK: - My Lists Filter Bar


// MARK: - My Lists Sort and Grid Toggle


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

// MARK: - My Lists Filter Bar


// MARK: - My Lists Sort and Grid Toggle


// MARK: - Restaurant List Card (Landscape Format)

struct RestaurantListCard: View {
    let restaurant: Restaurant
    @EnvironmentObject var store: RestaurantStore
    @State private var imageLoaded = false
    @State private var showingOptions = false
    @State private var showingRatingSlider = false
    @State private var showingAddToCollection = false
    @State private var tempRating: Double = 0.0
    
    var body: some View {
        HStack(spacing: 12) {
            // Restaurant image - smaller than before
            LinearGradient(
                colors: [restaurant.category.color.opacity(0.2), restaurant.category.color.opacity(0.05)],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .overlay(
                Text(restaurant.emoji)
                    .font(.clashDisplayHeaderTemp(size: 30))
            )
            .onAppear {
                withAnimation(.easeInOut(duration: 0.3)) {
                    imageLoaded = true
                }
            }
            .frame(width: 52, height: 52)
            .clipShape(RoundedRectangle(cornerRadius: 12))
            
            // Restaurant info - more space for text
            VStack(alignment: .leading, spacing: 4) {
                // Restaurant name with three dots on same line
                HStack {
                    Text(restaurantDisplayName)
                        .font(.clashDisplayButtonTemp())
                        .foregroundColor(.primary)
                        .lineLimit(1)
                    
                    Spacer()
                    
                    // Three dots menu button
                    Button(action: {
                        HapticManager.shared.light()
                        showingOptions = true
                    }) {
                        Image(systemName: "ellipsis")
                            .font(.clashDisplayBodyTemp())
                            .foregroundColor(.secondary)
                            .frame(width: 24, height: 24)
                    }
                }
                
                // Description only
                Text(restaurant.description)
                    .font(.clashDisplaySecondaryTemp())
                    .italic()
                    .foregroundColor(.secondary)
                    .lineLimit(1)
                
                // Location + collection indicator inline
                HStack {
                    Text(locationDisplay)
                        .font(.clashDisplaySmallTemp())
                        .foregroundColor(.secondary)
                        .lineLimit(1)
                    Spacer()
                    Button(action: {
                        HapticManager.shared.light()
                        if isInCollection {
                            // TODO: Remove from collections
                        } else {
                            showingAddToCollection = true
                        }
                    }) {
                        Group {
                            if isInCollection {
                                Image(systemName: "checkmark.circle.fill")
                                    .foregroundColor(.reelEatsAccent)
                            } else {
                                Image(systemName: "plus.circle")
                                    .foregroundColor(.gray.opacity(0.6))
                            }
                        }
                        .font(.clashDisplayBodyTemp(size: 16))
                    }
                }
            }
            
            Spacer()
        }
        .padding(.horizontal, 12)
        .padding(.vertical, 10)
        .background(Color(.systemBackground))
        .cornerRadius(16)
        .shadow(color: .black.opacity(0.05), radius: 8, x: 0, y: 4)
        .scaleEffect(imageLoaded ? 1.0 : 0.95)
        .opacity(imageLoaded ? 1.0 : 0.8)
        .sheet(isPresented: $showingOptions) {
            RestaurantOptionsSheet(restaurant: restaurant)
        }
        .sheet(isPresented: $showingRatingSlider) {
            RatingSliderView(
                restaurant: restaurant,
                currentRating: $tempRating,
                onSave: { rating, notes in
                    store.updateUserRating(for: restaurant.id, rating: rating)
                    // TODO: Store notes with rating
                    showingRatingSlider = false
                }
            )
            .presentationDetents([.height(450)])
            .presentationDragIndicator(.visible)
        }
        .sheet(isPresented: $showingAddToCollection) {
            AddToCollectionModal(restaurant: restaurant)
                .environmentObject(store)
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
            // Get the second component which contains "Suburb STATE Postcode"
            let suburbAndMore = components[1].trimmingCharacters(in: .whitespaces)
            let parts = suburbAndMore.split(separator: " ")
            
            if parts.count >= 2 {
                // Get suburb (first part) and state (second part), ignore postcode
                let suburb = String(parts[0])
                let state = String(parts[1])
                return "\(suburb) \(state)"
            }
        }
        return restaurant.address
    }
    
    private var userVisitStatus: VisitStatus {
        store.getUserData(for: restaurant.id)?.visitStatus ?? .wantToTry
    }
    
    private var userRating: Double {
        store.getUserData(for: restaurant.id)?.userRating ?? 0.0
    }
    
    private var isInCollection: Bool {
        store.collections.contains { collection in
            collection.restaurantIds.contains(restaurant.id)
        }
    }
    
    private func toggleVisitStatus() {
        let currentStatus = userVisitStatus
        let newStatus: VisitStatus = currentStatus == .wantToTry ? .visited : .wantToTry
        
        store.updateVisitStatus(for: restaurant.id, status: newStatus)
        
        // If marking as visited, show rating slider
        if newStatus == .visited {
            tempRating = userRating
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                showingRatingSlider = true
            }
        }
    }
}

// MARK: - My Lists Filter Bar


// MARK: - My Lists Sort and Grid Toggle


// MARK: - Restaurant Card (Exactly Matching Screenshot)

struct RestaurantCard: View {
    let restaurant: Restaurant
    @EnvironmentObject var store: RestaurantStore
    @State private var imageLoaded = false
    @State private var showingRatingSlider = false
    @State private var tempRating: Double = 0.0
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            // Enhanced restaurant image
            LinearGradient(
                colors: [restaurant.category.color.opacity(0.3), restaurant.category.color.opacity(0.1)],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .overlay(
                Text(restaurant.emoji)
                    .font(.clashDisplayHeaderTemp(size: 60))
            )
            .onAppear {
                withAnimation(.easeInOut(duration: 0.3)) {
                    imageLoaded = true
                }
            }
            .frame(height: 145)
            .clipShape(RoundedRectangle(cornerRadius: 14))
            .overlay(
                // Modern category tag and visit status toggle
                VStack {
                    HStack {
                        HStack(spacing: 6) {
                            Image(systemName: restaurant.category.icon)
                                .font(.clashDisplayCaptionTemp())
                            Text(restaurant.tags.first ?? restaurant.category.rawValue)
                                .font(.poppinsAccentTemp(size: 12))
                        }
                        .padding(.horizontal, 12)
                        .padding(.vertical, 6)
                        .background(
                            Capsule()
                                .fill(.ultraThinMaterial)
                                .overlay(
                                    Capsule()
                                        .stroke(restaurant.category.color.opacity(0.3), lineWidth: 1)
                                )
                        )
                        .foregroundColor(restaurant.category.color)
                        
                        Spacer()
                        
                        // Visit status toggle button
                        Button(action: {
                            HapticManager.shared.medium()
                            toggleVisitStatus()
                        }) {
                            Image(systemName: userVisitStatus.icon)
                                .font(.clashDisplayBodyTemp())
                                .foregroundColor(userVisitStatus == .visited ? .green : .white)
                                .frame(width: 32, height: 32)
                                .background(
                                    Circle()
                                        .fill(userVisitStatus == .visited ? Color.green.opacity(0.2) : Color.black.opacity(0.3))
                                        .overlay(
                                            Circle()
                                                .stroke(userVisitStatus == .visited ? Color.green : Color.white.opacity(0.5), lineWidth: 1)
                                        )
                                )
                        }
                        .scaleEffect(imageLoaded ? 1.0 : 0.8)
                        .animation(.spring(response: 0.5, dampingFraction: 0.6), value: userVisitStatus)
                    }
                    .padding(12)
                    
                    Spacer()
                    
                    // Star rating display (bottom right, only if visited)
                    if userVisitStatus == .visited && userRating > 0 {
                        HStack {
                            Spacer()
                            HStack(spacing: 2) {
                                ForEach(1...5, id: \.self) { star in
                                    Image(systemName: star <= Int(userRating) ? "star.fill" : "star")
                                        .font(.clashDisplayCaptionTemp())
                                        .foregroundColor(star <= Int(userRating) ? .yellow : .gray.opacity(0.3))
                                }
                            }
                            .padding(.horizontal, 10)
                            .padding(.vertical, 6)
                            .background(
                                Capsule()
                                    .fill(.ultraThinMaterial)
                            )
                        }
                        .padding(.trailing, 12)
                        .padding(.bottom, 12)
                    }
                }
            )
            
            // Enhanced restaurant info
            VStack(alignment: .leading, spacing: 6) {
                Text(restaurant.name)
                    .font(.poppinsRestaurantNameTemp(size: 17))
                    .foregroundColor(.primary)
                    .lineLimit(2)
                
                HStack(spacing: 6) {
                    Image(systemName: restaurant.source.icon)
                        .font(.clashDisplaySmallTemp())
                        .foregroundColor(.secondary)
                    
                    Text(restaurant.source.displayName)
                        .font(.poppinsSecondaryTemp(size: 13))
                        .foregroundColor(.secondary)
                }
            }
            .padding(.horizontal, 4)
        }
        .padding(14)
        .background(
            RoundedRectangle(cornerRadius: 18)
                .fill(Color(.systemBackground))
                .shadow(color: .black.opacity(0.1), radius: 10, x: 0, y: 4)
                .shadow(color: .black.opacity(0.05), radius: 2, x: 0, y: 1)
        )
        .overlay(
            RoundedRectangle(cornerRadius: 18)
                .stroke(Color.black.opacity(0.04), lineWidth: 1)
        )
        .scaleEffect(imageLoaded ? 1.0 : 0.95)
        .opacity(imageLoaded ? 1.0 : 0.8)
        .sheet(isPresented: $showingRatingSlider) {
            RatingSliderView(
                restaurant: restaurant,
                currentRating: $tempRating,
                onSave: { rating, notes in
                    store.updateUserRating(for: restaurant.id, rating: rating)
                    showingRatingSlider = false
                }
            )
            .presentationDetents([.height(450)])
            .presentationDragIndicator(.visible)
        }
    }
    
    private var userVisitStatus: VisitStatus {
        store.getUserData(for: restaurant.id)?.visitStatus ?? .wantToTry
    }
    
    private var userRating: Double {
        store.getUserData(for: restaurant.id)?.userRating ?? 0.0
    }
    
    private func toggleVisitStatus() {
        let currentStatus = userVisitStatus
        let newStatus: VisitStatus = currentStatus == .wantToTry ? .visited : .wantToTry
        
        store.updateVisitStatus(for: restaurant.id, status: newStatus)
        
        // If marking as visited, show rating slider
        if newStatus == .visited {
            tempRating = userRating
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                showingRatingSlider = true
            }
        }
    }
}

// MARK: - My Lists Filter Bar


// MARK: - My Lists Sort and Grid Toggle


// MARK: - Rating Slider View (Letterboxd Style)

struct RatingSliderView: View {
    let restaurant: Restaurant
    @Binding var currentRating: Double
    let onSave: (Double, String) -> Void
    @Environment(\.dismiss) private var dismiss
    @State private var isAnimating = false
    @State private var notes: String = ""
    @FocusState private var isNotesFocused: Bool
    
    var body: some View {
        VStack(spacing: 24) {
            // Handle bar
            ConsistentDragHandle()
            
            VStack(spacing: 20) {
                // Title
                Text("Rate your experience")
                    .font(.poppinsHeaderTemp(size: 20))
                    .foregroundColor(.primary)
                
                // Restaurant name
                Text(restaurant.name)
                    .font(.poppinsRestaurantNameTemp(size: 16))
                    .foregroundColor(.secondary)
                    .lineLimit(1)
                
                // Star rating slider
                VStack(spacing: 16) {
                    HStack(spacing: 8) {
                        ForEach(1...5, id: \.self) { star in
                            Button(action: {
                                HapticManager.shared.light()
                                withAnimation(.spring(response: 0.4, dampingFraction: 0.8)) {
                                    currentRating = Double(star)
                                }
                            }) {
                                Image(systemName: star <= Int(currentRating) ? "star.fill" : "star")
                                    .font(.clashDisplayHeaderTemp(size: 32))
                                    .foregroundColor(star <= Int(currentRating) ? .yellow : .gray.opacity(0.3))
                                    .scaleEffect(star <= Int(currentRating) ? (isAnimating ? 1.2 : 1.0) : 1.0)
                                    .animation(.spring(response: 0.3, dampingFraction: 0.6), value: currentRating)
                            }
                        }
                    }
                    
                    // Rating description
                    Text(ratingDescription)
                        .font(.poppinsBodyTemp(size: 16))
                        .foregroundColor(.secondary)
                        .animation(.easeInOut(duration: 0.2), value: currentRating)
                }
                
                // Notes field
                VStack(alignment: .leading, spacing: 8) {
                    Text("Notes (optional)")
                        .font(.poppinsSecondaryTemp(size: 14))
                        .foregroundColor(.secondary)
                    
                    TextField("Add your notes about this place...", text: $notes)
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                        .focused($isNotesFocused)
                }
                .padding(.horizontal, 20)
                
                // Save button
                Button(action: {
                    HapticManager.shared.success()
                    onSave(currentRating, notes)
                }) {
                    Text("Save Rating")
                        .font(.poppinsAccentTemp(size: 18))
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .frame(height: 50)
                        .background(
                            LinearGradient(
                                colors: currentRating > 0 ? [.black, .black.opacity(0.8)] : [.gray, .gray.opacity(0.8)],
                                startPoint: .top,
                                endPoint: .bottom
                            )
                        )
                        .cornerRadius(25)
                }
                .disabled(currentRating == 0)
                .padding(.horizontal, 20)
            }
            
            Spacer()
        }
        .padding(.horizontal, 24)
        .onAppear {
            withAnimation(.spring(response: 0.6, dampingFraction: 0.8).delay(0.2)) {
                isAnimating = true
            }
        }
        .onTapGesture {
            isNotesFocused = false
        }
    }
    
    private var ratingDescription: String {
        switch Int(currentRating) {
        case 0:
            return "Tap a star to rate"
        case 1:
            return "Terrible"
        case 2:
            return "Poor"
        case 3:
            return "Good"
        case 4:
            return "Great"
        case 5:
            return "Amazing!"
        default:
            return ""
        }
    }
}

// MARK: - My Lists Filter Bar


// MARK: - My Lists Sort and Grid Toggle


// Star view that supports partial fill
struct StarView: View {
    let fillAmount: Double
    let size: CGFloat
    
    var body: some View {
        ZStack {
            Image(systemName: "star")
                .font(.clashDisplayHeaderTemp(size: size))
                .foregroundColor(.gray.opacity(0.3))
            
            Image(systemName: "star.fill")
                .font(.clashDisplayHeaderTemp(size: size))
                .foregroundColor(.yellow)
                .mask(
                    GeometryReader { geometry in
                        Rectangle()
                            .frame(width: geometry.size.width * fillAmount)
                    }
                )
        }
    }
}

// MARK: - My Lists Filter Bar


// MARK: - My Lists Sort and Grid Toggle


// MARK: - Collection List Card


// MARK: - Full Screen Restaurant Detail View

struct FullScreenRestaurantDetailView: View {
    let restaurant: Restaurant
    @EnvironmentObject var store: RestaurantStore
    @Environment(\.dismiss) private var dismiss
    @State private var showingRatingSlider = false
    @State private var tempRating: Double = 0.0
    @State private var editableUserNotes: String = ""
    
    private var userRating: Double {
        store.getUserData(for: restaurant.id)?.userRating ?? 0.0
    }
    
    private var userNotes: String {
        // TODO: Get notes from store
        ""
    }
    
    var body: some View {
        ZStack {
            Color(.systemBackground)
                .ignoresSafeArea()
            
            VStack(spacing: 0) {
                // Header with close button
                HStack {
                    Button(action: {
                        HapticManager.shared.light()
                        dismiss()
                    }) {
                        Image(systemName: "xmark.circle.fill")
                            .font(.clashDisplayHeaderTemp(size: 28))
                            .foregroundColor(.secondary.opacity(0.6))
                    }
                    
                    Spacer()
                }
                .padding(.horizontal, 20)
                .padding(.vertical, 16)
                
                ScrollView {
                    VStack(spacing: 24) {
                        // Restaurant emoji
                        LinearGradient(
                            colors: [restaurant.category.color.opacity(0.2), restaurant.category.color.opacity(0.05)],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                        .overlay(
                            Text(restaurant.emoji)
                                .font(.clashDisplayHeaderTemp(size: 80))
                        )
                        .frame(width: 140, height: 140)
                        .clipShape(RoundedRectangle(cornerRadius: 24))
                        
                        // Restaurant info
                        VStack(spacing: 16) {
                            // Name
                            Text(restaurant.name)
                                .font(.poppinsHeaderTemp(size: 28))
                                .foregroundColor(.primary)
                                .multilineTextAlignment(.center)
                            
                            // Location and status
                            HStack(spacing: 16) {
                                HStack(spacing: 8) {
                                    Image(systemName: "location.fill")
                                        .font(.clashDisplaySecondaryTemp())
                                        .foregroundColor(.secondary)
                                    
                                    Text(restaurant.address)
                                        .font(.clashDisplayBodyTemp())
                                        .foregroundColor(.secondary)
                                }
                                
                                Text("•")
                                    .foregroundColor(.secondary)
                                
                                Text(isOpen ? "Open" : "Closed")
                                    .font(.clashDisplayBodyTemp())
                                    .foregroundColor(isOpen ? .green : .red)
                            }
                            
                            // Description (italic)
                            Text(restaurant.description)
                                .font(.newYorkDescription(size: 18))
                                .italic()
                                .foregroundColor(.secondary)
                                .multilineTextAlignment(.center)
                                .padding(.horizontal, 20)
                        }
                        
                        // Social Media Source Link
                        Button(action: {
                            // TODO: Open original social media post
                            HapticManager.shared.light()
                        }) {
                            HStack(spacing: 8) {
                                Image(systemName: getSocialMediaIcon())
                                    .font(.clashDisplayBodyTemp(size: 18))
                                    .foregroundColor(.primary)
                                
                                Text("View original post")
                                    .font(.clashDisplaySecondaryTemp())
                                    .foregroundColor(.primary)
                            }
                            .padding(.horizontal, 16)
                            .padding(.vertical, 8)
                            .background(Color(.systemGray6))
                            .cornerRadius(20)
                        }
                        
                        // User Rating Section
                        VStack(spacing: 12) {
                            Text("Your Rating")
                                .font(.clashDisplayButtonTemp())
                                .foregroundColor(.primary)
                            
                            HStack(spacing: 8) {
                                ForEach(1...5, id: \.self) { index in
                                    Button(action: {
                                        HapticManager.shared.light()
                                        store.updateUserRating(for: restaurant.id, rating: Double(index))
                                    }) {
                                        Image(systemName: index <= Int(userRating) ? "star.fill" : "star")
                                            .font(.clashDisplayHeaderTemp(size: 24))
                                            .foregroundColor(index <= Int(userRating) ? .yellow : .gray.opacity(0.3))
                                            .animation(.easeInOut(duration: 0.1), value: userRating)
                                    }
                                }
                            }
                        }
                        .padding(.top, 20)
                        
                        // Notes Section
                        VStack(alignment: .leading, spacing: 12) {
                            Text("Notes")
                                .font(.clashDisplayButtonTemp())
                                .foregroundColor(.primary)
                            
                            TextField("Add your notes about this spot...", text: $editableUserNotes, axis: .vertical)
                                .textFieldStyle(.roundedBorder)
                                .lineLimit(3...6)
                                .font(.clashDisplayBodyTemp())
                        }
                        .padding(.horizontal, 30)
                        .padding(.top, 20)
                        
                        // Reserve CTA Button
                        Button(action: {
                            // TODO: Handle reservation
                            HapticManager.shared.medium()
                        }) {
                            Text("Reserve")
                                .font(.clashDisplayButtonTemp(size: 18))
                                .foregroundColor(.white)
                                .frame(maxWidth: .infinity)
                                .padding(.vertical, 16)
                                .background(Color.reelEatsAccent)
                                .cornerRadius(16)
                        }
                        .padding(.horizontal, 30)
                        .padding(.top, 24)
                        
                        
                        Spacer(minLength: 100) // Space for bottom bar
                    }
                    .padding(.top, 20)
                }
                
                // Fixed bottom action bar
                VStack(spacing: 0) {
                    Divider()
                    
                    HStack(spacing: 12) {
                        ActionButton(icon: "calendar.badge.plus", title: "Reserve") {
                            HapticManager.shared.light()
                            // TODO: Make reservation
                        }
                        
                        ActionButton(icon: "location.north.circle.fill", title: "Directions") {
                            HapticManager.shared.light()
                            // TODO: Open in maps
                        }
                        
                        ActionButton(icon: "globe", title: "Site") {
                            HapticManager.shared.light()
                            // TODO: Open website
                        }
                        
                        ActionButton(icon: "square.and.arrow.up", title: "Share") {
                            HapticManager.shared.light()
                            // TODO: Implement share
                        }
                    }
                    .padding(.horizontal, 20)
                    .padding(.vertical, 16)
                    .background(Color(.systemBackground))
                }
            }
        }
    }
    
    private var isOpen: Bool {
        // Simple mock logic - in real app would check actual hours
        let hour = Calendar.current.component(.hour, from: Date())
        return hour >= 8 && hour < 22
    }
    
    // Helper function to get social media icon based on source
    private func getSocialMediaIcon() -> String {
        switch restaurant.source {
        case .instagram:
            return "camera.fill"
        case .tiktok:
            return "music.note"
        case .web:
            return "globe"
        }
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
                    .font(.clashDisplayBodyTemp(size: 18))
                    .foregroundColor(.primary)
                    .frame(width: 24)
                
                Text(title)
                    .font(.clashDisplayBodyTemp())
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
    let onRestaurantTap: (Restaurant) -> Void
    
    var body: some View {
        Map(coordinateRegion: $region, annotationItems: restaurants) { restaurant in
            MapAnnotation(coordinate: CLLocationCoordinate2D(latitude: restaurant.latitude, longitude: restaurant.longitude)) {
                EmojiMapPin(restaurant: restaurant, onTap: {
                    onRestaurantTap(restaurant)
                })
            }
        }
    }
}

// MARK: - Custom Emoji Map Pin
struct EmojiMapPin: View {
    let restaurant: Restaurant
    let onTap: () -> Void
    
    var body: some View {
        Button(action: {
            HapticManager.shared.medium()
            onTap()
        }) {
            ZStack {
                // White circle background with red outline
                Circle()
                    .fill(Color.white)
                    .frame(width: 36, height: 36)
                    .overlay(
                        Circle()
                            .stroke(Color.reelEatsAccent, lineWidth: 2)
                    )
                    .shadow(color: .black.opacity(0.1), radius: 2, x: 0, y: 1)
                
                // Restaurant emoji
                Text(restaurant.emoji)
                    .font(.system(size: 18))
            }
        }
        .buttonStyle(PlainButtonStyle())
    }
}

// MARK: - Map Top Overlay
struct MapTopOverlay: View {
    let selectedCollection: Collection?
    @State private var searchText = ""
    
    var body: some View {
        VStack(spacing: 16) {
            // Modern search bar
            HStack {
                Image(systemName: "magnifyingglass")
                    .font(.newYorkButton())
                    .foregroundColor(.secondary)
                
                TextField("Search places...", text: $searchText)
                    .textFieldStyle(PlainTextFieldStyle())
                    .font(.newYorkBody())
                
                if !searchText.isEmpty {
                    Button(action: {
                        searchText = ""
                    }) {
                        Image(systemName: "xmark.circle.fill")
                            .font(.newYorkButton())
                            .foregroundColor(.secondary)
                    }
                }
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 12)
            .background(
                RoundedRectangle(cornerRadius: 25)
                    .fill(Color(.systemBackground))
                    .shadow(color: .black.opacity(0.1), radius: 8, x: 0, y: 2)
            )
            .padding(.horizontal, 20)
            
            // Optional collection name
            HStack {
                if let collection = selectedCollection {
                    Text(collection.name)
                        .font(.poppinsCollectionNameTemp(size: 24))
                        .foregroundColor(.primary)
                        .padding(.horizontal, 20)
                        .padding(.vertical, 10)
                        .background(
                            RoundedRectangle(cornerRadius: 20)
                                .fill(Color(.systemBackground))
                                .shadow(color: .black.opacity(0.1), radius: 4, x: 0, y: 1)
                        )
                }
                
                Spacer()
            }
            .padding(.horizontal, 20)
            
            Spacer()
        }
        .padding(.top, 50)
    }
}

// MARK: - Map Bottom Sheet View (Simplified for Compiler)
struct MapBottomSheetView: View {
    @Binding var selectedCollection: Collection?
    @Binding var selectedCategory: RestaurantCategory?
    @Binding var selectedRestaurant: Restaurant?
    let filteredMapRestaurants: [Restaurant]
    let bottomSheetOffset: CGFloat
    let showingBottomSheet: Bool
    let onDragChanged: (DragGesture.Value) -> Void
    let onDragEnded: (DragGesture.Value) -> Void
    @EnvironmentObject var store: RestaurantStore
    @State private var searchText: String = ""
    
    var body: some View {
        VStack {
            Spacer()
            
            VStack(spacing: 0) {
                // Drag handle
                ConsistentDragHandle()
                
                // Show content depending on whether a restaurant is selected
                if selectedRestaurant != nil {
                    detailContentView
                } else {
                    // Optional collection header if user selected a collection
                    if let collection = selectedCollection {
                        collectionHeaderView(collection)
                    }
                    // Reduce whitespace between handle and search by pulling content up slightly
                    mainContentView.padding(.top, -8)
                }
            }
            .background(Color(.systemBackground))
            .cornerRadius(20, corners: [.topLeft, .topRight])
            .shadow(color: .black.opacity(0.1), radius: 10, x: 0, y: -5)
            .offset(y: bottomSheetOffset)
            .gesture(
                DragGesture()
                    .onChanged(onDragChanged)
                    .onEnded(onDragEnded)
            )
        }
    }
    
    // MARK: - Computed Properties to simplify view
    
    private var searchBarView: some View {
        HStack {
            Image(systemName: "magnifyingglass")
                .font(.newYorkButton())
                .foregroundColor(.secondary)
            
            TextField("Search places...", text: $searchText)
                .textFieldStyle(PlainTextFieldStyle())
                .font(.newYorkBody())
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 12)
        .background(Color(.systemGray6))
        .cornerRadius(12)
        .padding(.horizontal, 20)
        .padding(.bottom, 16)
    }
    
    private func collectionHeaderView(_ collection: Collection) -> some View {
        HStack {
            Text("\(filteredMapRestaurants.count) spots in collection")
                .font(.clashDisplayButtonTemp(size: 18))
            
            Spacer()
            
            Button(action: {
                selectedCollection = nil
            }) {
                Image(systemName: "xmark.circle.fill")
                    .font(.clashDisplayHeaderTemp())
                    .foregroundColor(.secondary)
            }
        }
        .padding(.horizontal, 20)
        .padding(.bottom, 20)
    }
    
    private var mainContentView: some View {
        ScrollView {
            VStack(spacing: 24) {
                // First element in sheet: search bar
                searchBarView
                
                if selectedCollection != nil { restaurantListContent }
                else { newCollectionsContent; newAllSpotsContent }
            }
            .padding(.vertical, 20)
        }
    }
    
    private var restaurantListContent: some View {
        ForEach(filteredMapRestaurants.prefix(5), id: \.id) { restaurant in
            Button(action: { selectedRestaurant = restaurant }) {
                RestaurantRowView(restaurant: restaurant)
            }
            .buttonStyle(PlainButtonStyle())
        }
    }
    
    private var allSpotsContent: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("All Spots")
                .font(.newYorkCollectionName(size: 20))
                .foregroundColor(.primary)
                .padding(.horizontal, 20)
            
            categoryPillsView
        }
    }
    
    private var categoryPillsView: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 8) {
                ForEach([RestaurantCategory.restaurants, .cafe, .bars], id: \.self) { category in
                    CategoryPillButton(category: category, selectedCategory: $selectedCategory)
                }
            }
            .padding(.horizontal, 20)
        }
    }
    
    private var collectionsContent: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Collections")
                .font(.newYorkCollectionName(size: 20))
                .foregroundColor(.primary)
                .padding(.horizontal, 20)
            
            ForEach(store.collections.prefix(4), id: \.id) { collection in
                CollectionRowView(collection: collection)
            }
        }
    }
    
    // MARK: - New Map Bottom Sheet Content
    
    private var newCollectionsContent: some View {
        VStack(alignment: .leading, spacing: 16) {
            // Collections header with filter pills
            VStack(alignment: .leading, spacing: 12) {
                Text("Collections")
                    .font(.newYorkCollectionName(size: 20))
                    .foregroundColor(.primary)
                    .padding(.horizontal, 20)
                
                // Collection filter pills (identical to home)
                MyListsFilterBar(
                    showingByMeDropdown: .constant(false),
                    showingByOthersDropdown: .constant(false),
                    collectionFilter: .constant(.all)
                )
                .environmentObject(store)
            }
            
            // Horizontal scrollable collection cards
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 16) {
                    ForEach(store.collections.prefix(6), id: \.id) { collection in
                        MapCollectionCard(collection: collection) {
                            selectedCollection = collection
                        }
                    }
                }
                .padding(.horizontal, 20)
            }
        }
    }
    
    private var newAllSpotsContent: some View {
        VStack(alignment: .leading, spacing: 16) {
            // All Spots header with filter pills
            VStack(alignment: .leading, spacing: 12) {
                Text("All Spots")
                    .font(.newYorkCollectionName(size: 20))
                    .foregroundColor(.primary)
                    .padding(.horizontal, 20)
                
                // All Spots filter pills (identical to home)
                ModernFilterBar()
                    .padding(.horizontal, 4) // Slight adjustment for pill alignment
            }
            
            // Vertical scrollable spots with circular emoji + name
            LazyVStack(spacing: 12) {
                ForEach(filteredMapRestaurants.prefix(8), id: \.id) { restaurant in
                    MapSpotRow(restaurant: restaurant) {
                        selectedRestaurant = restaurant
                    }
                }
            }
            .padding(.horizontal, 20)
        }
    }
    
    private var detailContentView: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack {
                Button(action: { withAnimation { selectedRestaurant = nil } }) {
                    Image(systemName: "chevron.left")
                        .font(.newYorkButton())
                        .foregroundColor(.primary)
                }
                Text("Spot Details")
                    .font(.newYorkCollectionName(size: 18))
                Spacer()
            }
            .padding(.horizontal, 20)
            
            if let restaurant = selectedRestaurant {
                // Reuse the list card look for detail header
                RestaurantListCard(restaurant: restaurant)
                    .environmentObject(store)
                    .padding(.horizontal, 16)
            }
        }
        .padding(.vertical, 20)
    }
}

// MARK: - Supporting Views for MapBottomSheetView

struct MapCollectionCard: View {
    let collection: Collection
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            VStack(alignment: .leading, spacing: 12) {
                // Collection preview with sample restaurant emojis
                HStack(spacing: -8) {
                    ForEach(collection.restaurantIds.prefix(3), id: \.self) { restaurantId in
                        if let restaurant = Melbourne.demoRestaurants.first(where: { $0.id == restaurantId }) {
                            Circle()
                                .fill(restaurant.category.color.opacity(0.2))
                                .frame(width: 40, height: 40)
                                .overlay(
                                    Text(restaurant.emoji)
                                        .font(.title3)
                                )
                        }
                    }
                    
                    if collection.restaurantIds.count > 3 {
                        Circle()
                            .fill(Color(.systemGray5))
                            .frame(width: 40, height: 40)
                            .overlay(
                                Text("+\(collection.restaurantIds.count - 3)")
                                    .font(.newYorkCaption())
                                    .foregroundColor(.secondary)
                            )
                    }
                    
                    Spacer()
                }
                .frame(height: 40)
                
                // Collection info
                VStack(alignment: .leading, spacing: 4) {
                    Text(collection.name)
                        .font(.newYorkCollectionName(size: 16))
                        .foregroundColor(.primary)
                        .lineLimit(1)
                    
                    HStack {
                        Text("\(collection.restaurantIds.count) spots")
                            .font(.newYorkCaption())
                            .foregroundColor(.secondary)
                        
                        Spacer()
                        
                        Text(collection.creatorText)
                            .font(.newYorkCaption())
                            .foregroundColor(.secondary)
                    }
                }
            }
            .padding(16)
            .frame(width: 160)
            .background(
                RoundedRectangle(cornerRadius: 16)
                    .fill(Color(.systemBackground))
                    .shadow(color: .black.opacity(0.1), radius: 8, x: 0, y: 2)
            )
        }
        .buttonStyle(PlainButtonStyle())
    }
}

struct MapSpotRow: View {
    let restaurant: Restaurant
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            HStack(spacing: 12) {
                // Circular emoji
                Circle()
                    .fill(restaurant.category.color.opacity(0.2))
                    .frame(width: 44, height: 44)
                    .overlay(
                        Text(restaurant.emoji)
                            .font(.title2)
                    )
                
                // Restaurant name and info
                VStack(alignment: .leading, spacing: 2) {
                    Text(restaurant.name)
                        .font(.newYorkBody())
                        .foregroundColor(.primary)
                        .lineLimit(1)
                    
                    Text(restaurant.category.rawValue)
                        .font(.newYorkCaption())
                        .foregroundColor(.secondary)
                }
                
                Spacer()
                
                // Distance or category icon
                Image(systemName: restaurant.category.icon)
                    .font(.newYorkCaption())
                    .foregroundColor(restaurant.category.color)
            }
            .padding(.vertical, 8)
        }
        .buttonStyle(PlainButtonStyle())
    }
}

struct RestaurantRowView: View {
    let restaurant: Restaurant
    
    var body: some View {
        HStack(spacing: 12) {
            Circle()
                .fill(restaurant.category.color.opacity(0.2))
                .frame(width: 40, height: 40)
                .overlay(
                    Text(restaurant.category.emoji)
                        .font(.title2)
                )
            
            Text(restaurant.name)
                .font(.newYorkBody())
            
            Spacer()
        }
        .padding(.horizontal, 20)
    }
}

struct CategoryPillButton: View {
    let category: RestaurantCategory
    @Binding var selectedCategory: RestaurantCategory?
    
    var body: some View {
        Button(action: {
            HapticManager.shared.light()
            selectedCategory = selectedCategory == category ? .all : category
        }) {
            Text(category.rawValue)
                .font(.newYorkTag())
                .foregroundColor(selectedCategory == category ? .white : .primary)
                .padding(.horizontal, 12)
                .padding(.vertical, 6)
                .background(selectedCategory == category ? Color.reelEatsAccent : Color.clear)
                .overlay(
                    RoundedRectangle(cornerRadius: 20)
                        .stroke(selectedCategory == category ? Color.clear : Color(.systemGray4), lineWidth: 1)
                )
                .cornerRadius(20)
        }
    }
}

struct CollectionRowView: View {
    let collection: Collection
    
    var body: some View {
        HStack {
            Text(collection.name)
                .font(.newYorkBody())
            
            Spacer()
            
            Text("\(collection.restaurantIds.count) spots")
                .font(.newYorkCaption())
                .foregroundColor(.secondary)
        }
        .padding(.horizontal, 20)
    }
}

// MARK: - My Lists Filter Bar


// MARK: - My Lists Sort and Grid Toggle


// MARK: - Map View (Matching Screenshot)

struct MapTabView: View {
    @Binding var selectedRestaurant: Restaurant?
    @EnvironmentObject var store: RestaurantStore
    @State private var selectedCategory: RestaurantCategory? = .all
    @State private var selectedCollection: Collection?
    @State private var showingBottomSheet = false
    @State private var bottomSheetOffset: CGFloat = UIScreen.main.bounds.height * 0.7 // 30% visible by default
    @State private var dragStartOffset: CGFloat = 0
    @State private var isDraggingSheet = false
    @State private var showingProfile = false
    @State private var region = MKCoordinateRegion(
        center: CLLocationCoordinate2D(latitude: -37.8136, longitude: 144.9631), // Melbourne CBD
        span: MKCoordinateSpan(latitudeDelta: 0.05, longitudeDelta: 0.05)
    )
    @State private var showingLocationInfo = false
    
    enum BottomSheetLevel: CaseIterable {
        case ten, thirty, fifty, ninety
        var visible: CGFloat {
            switch self { case .ten: return 0.10; case .thirty: return 0.30; case .fifty: return 0.50; case .ninety: return 0.90 }
        }
    }
    
    private func offset(for level: BottomSheetLevel) -> CGFloat {
        UIScreen.main.bounds.height * (1 - level.visible)
    }
    
    private var snapOffsets: [CGFloat] {
        [offset(for: .ten), offset(for: .thirty), offset(for: .fifty), offset(for: .ninety)]
    }
    
    var body: some View {
        ZStack {
            // Map with proper API usage
            ModernMapView(region: $region, restaurants: filteredMapRestaurants) { restaurant in
                selectedRestaurant = restaurant
            }
            .ignoresSafeArea()
            
            // Floating category filters just above bottom sheet
            VStack {
                Spacer()
                HStack(spacing: 12) {
                    // Location circular filter
                    Button(action: {}) {
                        Image(systemName: "location.circle.fill")
                            .font(.title3)
                            .foregroundColor(.white)
                            .frame(width: 36, height: 36)
                            .background(Color.reelEatsAccent)
                            .clipShape(Circle())
                            .shadow(color: .black.opacity(0.08), radius: 4, x: 0, y: 2)
                    }
                    
                    ForEach([RestaurantCategory.restaurants, .cafe, .bars, .bakery], id: \.self) { category in
                        Button(action: { selectedCategory = selectedCategory == category ? .all : category }) {
                            HStack(spacing: 8) {
                                Text(category.rawValue)
                                    .font(.newYorkTag())
                                    .lineLimit(1)
                                    .fixedSize(horizontal: true, vertical: false)
                            }
                            .padding(.horizontal, category == .restaurants ? 16 : 12)
                            .padding(.vertical, 8)
                            .background(selectedCategory == category ? Color.reelEatsAccent : Color(.systemBackground))
                            .foregroundColor(selectedCategory == category ? .white : .primary)
                            .clipShape(Capsule())
                            .shadow(color: .black.opacity(0.08), radius: 3, x: 0, y: 1)
                        }
                    }
                    Spacer()
                }
                .padding(.horizontal, 16)
                // Track the sheet top precisely (tiny gap)
                .offset(y: bottomSheetOffset - offset(for: .thirty))
                .padding(.bottom, 6)
            }
            .zIndex(3)
            
            // Bottom sheet
            MapBottomSheetView(
                selectedCollection: $selectedCollection,
                selectedCategory: $selectedCategory,
                selectedRestaurant: $selectedRestaurant,
                filteredMapRestaurants: filteredMapRestaurants,
                bottomSheetOffset: bottomSheetOffset,
                showingBottomSheet: showingBottomSheet,
                onDragChanged: { value in
                    if !isDraggingSheet { isDraggingSheet = true; dragStartOffset = bottomSheetOffset }
                    // Clamp with correct bounds: .ninety is the minimum offset (most visible), .ten is maximum (least visible)
                    let minOffset = offset(for: .ninety)
                    let maxOffset = offset(for: .ten)
                    bottomSheetOffset = min(max(minOffset, dragStartOffset + value.translation.height), maxOffset)
                },
                onDragEnded: { value in
                    withAnimation(.spring()) {
                        isDraggingSheet = false
                        let nearest = snapOffsets.min(by: { abs($0 - bottomSheetOffset) < abs($1 - bottomSheetOffset) }) ?? bottomSheetOffset
                        let minOffset = offset(for: .ninety)
                        // Cap downward to screenshot-like position slightly above nav by not exceeding .thirty when released near bottom
                        let maxOffset = offset(for: .ten)
                        bottomSheetOffset = min(max(minOffset, nearest), maxOffset)
                        showingBottomSheet = nearest <= offset(for: .fifty)
                    }
                }
            )
            .environmentObject(store)
            .zIndex(2)
        }
        .onAppear {
            bottomSheetOffset = offset(for: .thirty)
        }
        // Defensive clamp in case any external state nudges the offset
        .onChange(of: bottomSheetOffset) { _, newVal in
            let clamped = min(max(offset(for: .ninety), newVal), offset(for: .ten))
            if clamped != newVal { bottomSheetOffset = clamped }
        }
        .onChange(of: selectedRestaurant) { _, newRestaurant in
            if let restaurant = newRestaurant {
                withAnimation(.easeInOut(duration: 1.0)) {
                    region = MKCoordinateRegion(
                        center: CLLocationCoordinate2D(
                            latitude: restaurant.latitude,
                            longitude: restaurant.longitude
                        ),
                        span: MKCoordinateSpan(latitudeDelta: 0.01, longitudeDelta: 0.01)
                    )
                }
            }
        }
        .sheet(isPresented: $showingProfile) {
            ProfileTabView()
                .environmentObject(store)
        }
    }
    
    private var filteredMapRestaurants: [Restaurant] {
        var restaurants = store.savedRestaurants
        
        if let _ = selectedCollection {
            // Filter by collection (in a real app, this would check collection.restaurantIds)
            restaurants = restaurants.filter { _ in true } // Show all for now
        }
        
        if let category = selectedCategory, category != .all {
            restaurants = restaurants.filter { $0.category == category }
        }
        
        return restaurants
    }
}

// MARK: - Map Collections Section
struct MapCollectionsSection: View {
    @EnvironmentObject var store: RestaurantStore
    
    var body: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 12) {
                ForEach(store.collections) { collection in
                    CollectionCard(collection: collection)
                        .frame(width: 150, height: 180)
                }
            }
            .padding(.horizontal, 20)
        }
    }
}

// MARK: - Location Info Panel (Similar to provided screenshots)

struct LocationInfoPanel: View {
    let restaurant: Restaurant
    let onClose: () -> Void
    @EnvironmentObject var store: RestaurantStore
    @State private var dragOffset: CGFloat = 0
    @State private var isExpanded = false
    @State private var showingRatingSlider = false
    @State private var tempRating: Double = 0.0
    
    private var userVisitStatus: VisitStatus {
        store.getUserData(for: restaurant.id)?.visitStatus ?? .wantToTry
    }
    
    private var userRating: Double {
        store.getUserData(for: restaurant.id)?.userRating ?? 0.0
    }
    
    var body: some View {
        GeometryReader { geometry in
            VStack(spacing: 0) {
                Spacer()
                
                VStack(spacing: 0) {
                    // Drag handle
                    ConsistentDragHandle()
                    
                    // Content
                    ScrollView {
                        VStack(spacing: 20) {
                            // Restaurant name and basic info
                            VStack(spacing: 12) {
                                Text(restaurant.name)
                                    .font(.poppinsRestaurantNameTemp(size: 24))
                                    .foregroundColor(.primary)
                                    .multilineTextAlignment(.center)
                                
                                Text(restaurant.description)
                                    .font(.poppinsDescriptionTemp(size: 16))
                                    .foregroundColor(.secondary)
                                    .multilineTextAlignment(.center)
                                    .padding(.horizontal, 20)
                                
                                // Address
                                HStack(spacing: 8) {
                                    Image(systemName: "location.fill")
                                        .font(.clashDisplaySecondaryTemp())
                                        .foregroundColor(.secondary)
                                    
                                    Text(restaurant.address)
                                        .font(.poppinsSmallTemp(size: 14))
                                        .foregroundColor(.secondary)
                                }
                                
                                // Open/Closed status (mock)
                                HStack(spacing: 8) {
                                    Circle()
                                        .fill(Color.green)
                                        .frame(width: 8, height: 8)
                                    
                                    Text("Open • Closes at 10 PM")
                                        .font(.clashDisplaySecondaryTemp())
                                        .foregroundColor(.green)
                                }
                                
                                // Visit status and rating
                                HStack(spacing: 16) {
                                    HStack(spacing: 8) {
                                        Image(systemName: userVisitStatus.icon)
                                            .font(.clashDisplayBodyTemp())
                                            .foregroundColor(userVisitStatus == .visited ? .green : .orange)
                                        
                                        Text(userVisitStatus.rawValue)
                                            .font(.clashDisplaySecondaryTemp())
                                            .foregroundColor(.secondary)
                                    }
                                    
                                    if userVisitStatus == .visited && userRating > 0 {
                                        HStack(spacing: 4) {
                                            ForEach(1...5, id: \.self) { star in
                                                Image(systemName: star <= Int(userRating) ? "star.fill" : "star")
                                                    .font(.clashDisplaySecondaryTemp())
                                                    .foregroundColor(star <= Int(userRating) ? .yellow : .gray.opacity(0.3))
                                            }
                                            Text("(\(Int(userRating))/5)")
                                                .font(.clashDisplayCaptionTemp())
                                                .foregroundColor(.secondary)
                                        }
                                    }
                                }
                            }
                            .padding(.horizontal, 24)
                            
                            // Bottom Action Panel
                            BottomActionPanel(restaurant: restaurant)
                                .padding(.horizontal, 20)
                                .padding(.bottom, 40)
                        }
                    }
                    .frame(maxHeight: isExpanded ? geometry.size.height * 0.7 : 200)
                }
                .background(Color(.systemBackground))
                .cornerRadius(24, corners: [.topLeft, .topRight])
                .shadow(color: .black.opacity(0.15), radius: 20, x: 0, y: -10)
                .offset(y: dragOffset)
                .gesture(
                    DragGesture()
                        .onChanged { value in
                            let newOffset = max(-100, min(300, value.translation.height))
                            dragOffset = newOffset
                        }
                        .onEnded { value in
                            withAnimation(.spring(response: 0.6, dampingFraction: 0.8)) {
                                if value.predictedEndTranslation.height > 100 {
                                    onClose()
                                } else if value.predictedEndTranslation.height < -50 {
                                    isExpanded = true
                                    dragOffset = -50
                                } else {
                                    dragOffset = 0
                                    isExpanded = false
                                }
                            }
                        }
                )
            }
        }
        .ignoresSafeArea()
        .sheet(isPresented: $showingRatingSlider) {
            RatingSliderView(
                restaurant: restaurant,
                currentRating: $tempRating,
                onSave: { rating, notes in
                    store.updateUserRating(for: restaurant.id, rating: rating)
                    // TODO: Store notes with rating
                    showingRatingSlider = false
                }
            )
            .presentationDetents([.height(450)])
            .presentationDragIndicator(.visible)
        }
    }
}

// MARK: - My Lists Filter Bar


// MARK: - My Lists Sort and Grid Toggle


// MARK: - Bottom Action Panel (Share, Directions, Book, Site)

struct BottomActionPanel: View {
    let restaurant: Restaurant
    
    var body: some View {
        HStack(spacing: 12) {
            ActionButton(
                icon: "square.and.arrow.up",
                title: "Share",
                action: { /* Share action */ }
            )
            
            ActionButton(
                icon: "location.north.circle.fill",
                title: "Directions",
                action: { /* Directions action */ }
            )
            
            ActionButton(
                icon: "calendar.badge.plus",
                title: "Book",
                action: { /* Booking action */ }
            )
            
            ActionButton(
                icon: "safari",
                title: "Site",
                action: { /* Website action */ }
            )
        }
    }
}

// MARK: - My Lists Filter Bar


// MARK: - My Lists Sort and Grid Toggle


// MARK: - Action Button Component

struct ActionButton: View {
    let icon: String
    let title: String
    let action: () -> Void
    @State private var isPressed = false
    
    var body: some View {
        Button(action: {
            HapticManager.shared.light()
            action()
        }) {
            VStack(spacing: 8) {
                Image(systemName: icon)
                    .font(.clashDisplayRestaurantNameTemp(size: 20))
                    .foregroundColor(.primary)
                
                Text(title)
                    .font(.clashDisplayCaptionTemp())
                    .foregroundColor(.primary)
            }
            .frame(maxWidth: .infinity)
            .frame(height: 60)
            .background(Color(.systemGray6))
            .cornerRadius(12)
            .scaleEffect(isPressed ? 0.95 : 1.0)
        }
        .buttonStyle(PlainButtonStyle())
        .onPressGesture(
            onPress: { isPressed = true },
            onRelease: { isPressed = false }
        )
    }
}

// Custom press gesture for better button feedback
extension View {
    func onPressGesture(onPress: @escaping () -> Void, onRelease: @escaping () -> Void) -> some View {
        self.simultaneousGesture(
            DragGesture(minimumDistance: 0)
                .onChanged { _ in onPress() }
                .onEnded { _ in onRelease() }
        )
    }
}

// MARK: - Map Category Button

struct MapCategoryButton: View {
    let category: RestaurantCategory
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            HStack(spacing: 8) {
                // Modern emoji + icon combination
                HStack(spacing: 4) {
                    Text(category.emoji)
                        .font(.newYorkSecondary(size: 15))
                    
                    if isSelected {
                        Image(systemName: category.icon)
                            .font(.clashDisplayCaptionTemp(size: 11))
                            .foregroundColor(.white)
                    }
                }
                
                Text(category.rawValue)
                    .font(.poppinsAccentTemp(size: 14))
                    .foregroundColor(isSelected ? .white : .primary)
            }
            .padding(.horizontal, 14)
            .padding(.vertical, 9)
            .background(
                Group {
                    if isSelected {
                        LinearGradient(
                            colors: category.gradientColors,
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    } else {
                        Color(.systemBackground)
                            .overlay(
                                RoundedRectangle(cornerRadius: 16)
                                    .stroke(Color.black.opacity(0.1), lineWidth: 1)
                            )
                    }
                }
            )
            .clipShape(RoundedRectangle(cornerRadius: 16))
            .shadow(
                color: isSelected ? category.color.opacity(0.3) : .black.opacity(0.08),
                radius: isSelected ? 6 : 2,
                x: 0,
                y: isSelected ? 3 : 1
            )
        }
        .buttonStyle(PlainButtonStyle())
        .scaleEffect(isSelected ? 1.05 : 1.0)
        .animation(.spring(response: 0.3, dampingFraction: 0.7), value: isSelected)
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
                .font(.poppinsRestaurantNameTemp(size: 10))
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

// MARK: - My Lists Filter Bar


// MARK: - My Lists Sort and Grid Toggle


// MARK: - Profile View (Matching Screenshot)

struct ProfileTabView: View {
    @EnvironmentObject var store: RestaurantStore
    @State private var showingSettings = false
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 24) {
                    // Header
                    HStack {
                        Text("Julian Ou")
                            .font(.newYorkHeader(size: 32))
                            .foregroundColor(.primary)
                        
                        Spacer()
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
                                .font(.clashDisplayCardTitleTemp())
                                .foregroundColor(.primary)
                            
                            Text("Media Saved")
                                .font(.clashDisplayBodyTemp())
                                .foregroundColor(.secondary)
                        }
                        
                        Spacer()
                    }
                    .padding(.horizontal, 20)
                    
                    // Edit Profile button
                    Button(action: {}) {
                        Text("Edit Profile")
                            .font(.clashDisplayBodyTemp())
                            .foregroundColor(.primary)
                            .frame(maxWidth: .infinity)
                            .frame(height: 44)
                            .background(Color(.systemGray6))
                            .cornerRadius(12)
                    }
                    .padding(.horizontal, 20)
                    
                    // Settings Sections
                    VStack(spacing: 24) {
                        // Sharing section
                        VStack(alignment: .leading, spacing: 16) {
                            Text("Sharing")
                                .font(.newYorkCollectionName(size: 20))
                                .foregroundColor(.primary)
                                .padding(.horizontal, 20)
                            
                            VStack(spacing: 12) {
                                ModernSettingsRow(icon: "square.and.arrow.up", title: "Sharing guides", subtitle: "How to share from other apps")
                            }
                            .padding(.horizontal, 20)
                            .padding(.vertical, 16)
                            .background(Color(.systemGray6))
                            .cornerRadius(16)
                            .padding(.horizontal, 20)
                        }
                        
                        // App Integration section
                        VStack(alignment: .leading, spacing: 16) {
                            Text("App Integration")
                                .font(.newYorkCollectionName(size: 20))
                                .foregroundColor(.primary)
                                .padding(.horizontal, 20)
                            
                            VStack(spacing: 12) {
                                ModernSettingsRow(icon: "camera.fill", title: "Instagram", subtitle: "Connected")
                                ModernSettingsRow(icon: "music.note", title: "TikTok", subtitle: "Connected")
                                ModernSettingsRow(icon: "safari.fill", title: "Safari", subtitle: "Connected")
                            }
                            .padding(.horizontal, 20)
                            .padding(.vertical, 16)
                            .background(Color(.systemGray6))
                            .cornerRadius(16)
                            .padding(.horizontal, 20)
                        }
                        
                        // Support section
                        VStack(alignment: .leading, spacing: 16) {
                            Text("Support")
                                .font(.newYorkCollectionName(size: 20))
                                .foregroundColor(.primary)
                                .padding(.horizontal, 20)
                            
                            VStack(spacing: 12) {
                                ModernSettingsRow(icon: "questionmark.circle", title: "Help & Support")
                                ModernSettingsRow(icon: "envelope", title: "Contact Us")
                            }
                            .padding(.horizontal, 20)
                            .padding(.vertical, 16)
                            .background(Color(.systemGray6))
                            .cornerRadius(16)
                            .padding(.horizontal, 20)
                        }
                    }
                    
                    
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

// MARK: - My Lists Filter Bar


// MARK: - My Lists Sort and Grid Toggle


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
                        .font(.poppinsCollectionNameTemp(size: 16))
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
                                .font(.clashDisplayButtonTemp(size: 18))
                            Text("julian@example.com")
                                .font(.clashDisplaySecondaryTemp())
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

// MARK: - My Lists Filter Bar


// MARK: - My Lists Sort and Grid Toggle


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
                .font(.clashDisplayBodyTemp())
                .foregroundColor(.blue)
                .frame(width: 24)
            
            VStack(alignment: .leading, spacing: 2) {
                Text(title)
                    .font(.clashDisplayBodyTemp())
                
                if let subtitle = subtitle {
                    Text(subtitle)
                        .font(.clashDisplaySecondaryTemp())
                        .foregroundColor(.secondary)
                }
            }
            
            Spacer()
        }
        .padding(.vertical, 4)
    }
}

// MARK: - Consistent Drag Handle Component
struct ConsistentDragHandle: View {
    var body: some View {
        RoundedRectangle(cornerRadius: 2.5)
            .fill(Color(.systemGray4))
            .frame(width: 40, height: 4)
            .padding(.top, 8)
            .padding(.bottom, 12)
    }
}

// MARK: - Modern Settings Row (for Profile Integration)
struct ModernSettingsRow: View {
    let icon: String
    let title: String
    let subtitle: String?
    
    init(icon: String, title: String, subtitle: String? = nil) {
        self.icon = icon
        self.title = title
        self.subtitle = subtitle
    }
    
    var body: some View {
        HStack(spacing: 12) {
            // Icon with accent color
            Image(systemName: icon)
                .font(.newYorkButton())
                .foregroundColor(.reelEatsAccent)
                .frame(width: 24, height: 24)
            
            // Content
            VStack(alignment: .leading, spacing: 2) {
                Text(title)
                    .font(.newYorkBody())
                    .foregroundColor(.primary)
                
                if let subtitle = subtitle {
                    Text(subtitle)
                        .font(.newYorkSecondary())
                        .foregroundColor(.secondary)
                }
            }
            
            Spacer()
            
            // Chevron
            Image(systemName: "chevron.right")
                .font(.newYorkCaption())
                .foregroundColor(.secondary)
        }
        .padding(.vertical, 8)
    }
}

// MARK: - ReciMe Style Action Sheet

struct RecimeStyleActionSheet: View {
    @Binding var showingAddSpotsOptions: Bool
    @Binding var showingCreatePersonalCollection: Bool
    @Binding var showingCreateTogetherCollection: Bool
    
    private func dismiss() {
        // This will be handled by the parent view
    }
    
    var body: some View {
        VStack(spacing: 0) {
            // Handle bar only
            ConsistentDragHandle()
            
            // Action buttons - all with red theme
            VStack(spacing: 16) {
                // Add Spots
                ActionSheetButton(
                    icon: "location.fill",
                    title: "Add Spots",
                    subtitle: "Search, upload screenshot or paste text",
                    iconColor: .white,
                    backgroundColor: Color.reelEatsAccent
                ) {
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                        showingAddSpotsOptions = true
                    }
                }
                
                // Create Personal Collection
                ActionSheetButton(
                    icon: "person.fill",
                    title: "Create Personal Collection",
                    subtitle: "Create a personal collection to your own taste",
                    iconColor: .white,
                    backgroundColor: Color.reelEatsAccent
                ) {
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                        showingCreatePersonalCollection = true
                    }
                }
                
                // Create Together Collection
                ActionSheetButton(
                    icon: "person.2.fill",
                    title: "Create Together Collection",
                    subtitle: "Create a collection together with friends",
                    iconColor: .white,
                    backgroundColor: Color.reelEatsAccent
                ) {
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                        showingCreateTogetherCollection = true
                    }
                }
            }
            .padding(.horizontal, 8)
            
        }
        .padding(.horizontal, 12)
        .padding(.bottom, 24) // Much less bottom padding
        
        .background(
            RoundedRectangle(cornerRadius: 20)
                .fill(Color(.systemBackground))
                .shadow(color: .black.opacity(0.15), radius: 20, x: 0, y: -10)
        )
        .padding(.horizontal, 2) // Further reduced horizontal padding to make wider
    }
}

// MARK: - Add Spots Options View

struct AddSpotsOptionsView: View {
    @Environment(\.dismiss) private var dismiss
    @State private var searchText = ""
    @State private var searchResults: [MockLocationResult] = []
    @State private var isSearching = false
    @Binding var showingUploadPhoto: Bool
    @Binding var showingPasteText: Bool
    
    var body: some View {
        VStack(spacing: 0) {
            // Header
            VStack(spacing: 16) {
                // Handle bar
                ConsistentDragHandle()
                
                HStack {
                    Button("Cancel") {
                        dismiss()
                    }
                    .font(.newYorkButton())
                    .foregroundColor(.secondary)
                    
                    Spacer()
                    
                    Text("Add Spots")
                        .font(.newYorkHeader(size: 18))
                        .foregroundColor(.primary)
                    
                    Spacer()
                    
                    // Invisible spacer for symmetry
                    Text("Cancel")
                        .opacity(0)
                        .font(.newYorkButton())
                }
                .padding(.horizontal, 24)
            }
            .padding(.bottom, 24)
            
            // Search section - takes most space
            VStack(spacing: 20) {
                // Search bar
                HStack {
                    Image(systemName: "magnifyingglass")
                        .foregroundColor(.secondary)
                        .font(.newYorkButton())
                    
                    TextField("Search for restaurants, cafes, bars...", text: $searchText)
                        .font(.newYorkBody())
                        .textFieldStyle(PlainTextFieldStyle())
                        .onSubmit {
                            performSearch()
                        }
                    
                    if !searchText.isEmpty {
                        Button(action: {
                            searchText = ""
                            searchResults = []
                        }) {
                            Image(systemName: "xmark.circle.fill")
                                .foregroundColor(.secondary)
                        }
                    }
                }
                .padding(.horizontal, 20)
                .padding(.vertical, 16)
                .background(Color(.systemGray6))
                .cornerRadius(16)
                .padding(.horizontal, 24)
                
                // Search results or empty state
                if isSearching {
                    VStack {
                        ProgressView()
                            .scaleEffect(1.2)
                        Text("Searching...")
                            .font(.newYorkSecondary())
                            .foregroundColor(.secondary)
                    }
                    .frame(maxWidth: .infinity, minHeight: 100)
                } else if !searchResults.isEmpty {
                    ScrollView {
                        LazyVStack(spacing: 12) {
                            ForEach(searchResults) { result in
                                CompactSearchResultRow(result: result) {
                                    // Handle selection
                                    dismiss()
                                }
                            }
                        }
                        .padding(.horizontal, 24)
                    }
                } else if !searchText.isEmpty {
                    VStack(spacing: 12) {
                        Image(systemName: "magnifyingglass")
                            .font(.newYorkHeader(size: 40))
                            .foregroundColor(.secondary.opacity(0.6))
                        
                        Text("No results found")
                            .font(.newYorkBody())
                            .foregroundColor(.secondary)
                    }
                    .frame(maxWidth: .infinity, minHeight: 100)
                } else {
                    VStack(spacing: 12) {
                        Image(systemName: "location.magnifyingglass")
                            .font(.newYorkHeader(size: 40))
                            .foregroundColor(.reelEatsAccent)
                        
                        Text("Search for your favorite spots")
                            .font(.newYorkBody())
                            .foregroundColor(.secondary)
                    }
                    .frame(maxWidth: .infinity, minHeight: 100)
                }
            }
            .frame(maxHeight: .infinity)
            
            // Alternative options - bottom section
            VStack(spacing: 16) {
                HStack(spacing: 1) {
                    Rectangle()
                        .fill(Color(.systemGray5))
                        .frame(height: 1)
                    
                    Text("or")
                        .font(.newYorkSecondary())
                        .foregroundColor(.secondary)
                        .padding(.horizontal, 16)
                    
                    Rectangle()
                        .fill(Color(.systemGray5))
                        .frame(height: 1)
                }
                .padding(.horizontal, 24)
                
                // Two option buttons side by side
                HStack(spacing: 16) {
                    // Upload Photo button
                    Button(action: {
                        dismiss()
                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                            showingUploadPhoto = true
                        }
                    }) {
                        VStack(spacing: 12) {
                            ZStack {
                                Circle()
                                    .fill(Color.reelEatsAccent)
                                    .frame(width: 44, height: 44)
                                
                                Image(systemName: "photo.on.rectangle")
                                    .font(.newYorkButton(size: 16))
                                    .foregroundColor(.white)
                            }
                            
                            Text("Upload Photo")
                                .font(.newYorkButton())
                                .foregroundColor(.primary)
                                .multilineTextAlignment(.center)
                        }
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 20)
                        .background(Color(.systemGray6))
                        .cornerRadius(16)
                    }
                    .buttonStyle(PlainButtonStyle())
                    
                    // Paste Text button
                    Button(action: {
                        dismiss()
                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                            showingPasteText = true
                        }
                    }) {
                        VStack(spacing: 12) {
                            ZStack {
                                Circle()
                                    .fill(Color.reelEatsAccent)
                                    .frame(width: 44, height: 44)
                                
                                Image(systemName: "text.alignleft")
                                    .font(.newYorkButton(size: 16))
                                    .foregroundColor(.white)
                            }
                            
                            Text("Paste Text")
                                .font(.newYorkButton())
                                .foregroundColor(.primary)
                                .multilineTextAlignment(.center)
                        }
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 20)
                        .background(Color(.systemGray6))
                        .cornerRadius(16)
                    }
                    .buttonStyle(PlainButtonStyle())
                }
                .padding(.horizontal, 24)
            }
            .padding(.bottom, 32)
        }
        .presentationDetents([.large])
        .presentationDragIndicator(.hidden)
    }
    
    private func performSearch() {
        guard !searchText.isEmpty else { return }
        
        isSearching = true
        
        // Simulate API delay
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
            isSearching = false
            searchResults = MockGoogleMapsAPI.search(query: searchText)
        }
    }
}

// MARK: - Compact Search Result Row

struct CompactSearchResultRow: View {
    let result: MockLocationResult
    let onTap: () -> Void
    
    var body: some View {
        Button(action: onTap) {
            HStack(spacing: 16) {
                // Location image or icon
                ZStack {
                    RoundedRectangle(cornerRadius: 10)
                        .fill(result.category.color.opacity(0.2))
                        .frame(width: 50, height: 50)
                    
                    Image(systemName: result.category.icon)
                        .font(.newYorkButton())
                        .foregroundColor(result.category.color)
                }
                
                VStack(alignment: .leading, spacing: 4) {
                    Text(result.name)
                        .font(.newYorkRestaurantName())
                        .foregroundColor(.primary)
                        .multilineTextAlignment(.leading)
                    
                    HStack(spacing: 8) {
                        Text(result.category.rawValue.capitalized)
                            .font(.newYorkCaption())
                            .foregroundColor(.white)
                            .padding(.horizontal, 8)
                            .padding(.vertical, 2)
                            .background(result.category.color)
                            .cornerRadius(8)
                        
                        if result.rating > 0 {
                            HStack(spacing: 2) {
                                Image(systemName: "star.fill")
                                    .font(.newYorkCaption())
                                    .foregroundColor(.yellow)
                                
                                Text(String(format: "%.1f", result.rating))
                                    .font(.newYorkCaption())
                                    .foregroundColor(.secondary)
                            }
                        }
                    }
                    
                    Text(result.address)
                        .font(.newYorkCaption())
                        .foregroundColor(.secondary)
                        .lineLimit(1)
                }
                
                Spacer()
                
                Image(systemName: "plus.circle.fill")
                    .font(.newYorkButton())
                    .foregroundColor(.reelEatsAccent)
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 12)
            .background(Color(.systemBackground))
            .cornerRadius(12)
            .overlay(
                RoundedRectangle(cornerRadius: 12)
                    .stroke(Color(.systemGray5), lineWidth: 1)
            )
        }
        .buttonStyle(PlainButtonStyle())
    }
}

// MARK: - Collection Sharing Sheet (Spotify-style)

struct CollectionSharingSheet: View {
    @Environment(\.dismiss) private var dismiss
    let collectionName: String
    @State private var isAnimating = false
    
    var body: some View {
        VStack(spacing: 0) {
            // Header
            VStack(spacing: 16) {
                // Handle bar
                ConsistentDragHandle()
                
                HStack {
                    Button("Done") {
                        dismiss()
                    }
                    .font(.newYorkButton())
                    .foregroundColor(.reelEatsAccent)
                    
                    Spacer()
                }
                .padding(.horizontal, 24)
            }
            .padding(.bottom, 32)
            
            // Collection preview
            VStack(spacing: 24) {
                // Collection artwork preview
                ZStack {
                    RoundedRectangle(cornerRadius: 20)
                        .fill(
                            LinearGradient(
                                colors: [Color.reelEatsAccent, Color.reelEatsAccent.opacity(0.7)],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                        .frame(width: 200, height: 200)
                        .shadow(color: Color.reelEatsAccent.opacity(0.3), radius: 20, x: 0, y: 10)
                        .scaleEffect(isAnimating ? 1.0 : 0.8)
                        .animation(.spring(response: 0.8, dampingFraction: 0.7), value: isAnimating)
                    
                    VStack {
                        Image(systemName: "person.2.fill")
                            .font(.newYorkLogo(size: 32))
                            .foregroundColor(.white)
                        
                        Text(collectionName.prefix(1).uppercased())
                            .font(.newYorkLogo(size: 48))
                            .foregroundColor(.white)
                    }
                    .opacity(isAnimating ? 1.0 : 0.0)
                    .animation(.spring(response: 0.8, dampingFraction: 0.7).delay(0.2), value: isAnimating)
                }
                
                VStack(spacing: 12) {
                    Text(collectionName)
                        .font(.newYorkCardTitle(size: 24))
                        .foregroundColor(.primary)
                        .opacity(isAnimating ? 1.0 : 0.0)
                        .animation(.spring(response: 0.8, dampingFraction: 0.8).delay(0.4), value: isAnimating)
                    
                    Text("Collection • Julian Ou")
                        .font(.newYorkSecondary())
                        .foregroundColor(.secondary)
                        .opacity(isAnimating ? 1.0 : 0.0)
                        .animation(.spring(response: 0.8, dampingFraction: 0.8).delay(0.6), value: isAnimating)
                }
            }
            .padding(.vertical, 32)
            
            // Page indicator dots
            HStack(spacing: 8) {
                Circle()
                    .fill(Color.primary)
                    .frame(width: 8, height: 8)
                Circle()
                    .fill(Color(.systemGray4))
                    .frame(width: 8, height: 8)
                Circle()
                    .fill(Color(.systemGray4))
                    .frame(width: 8, height: 8)
            }
            .padding(.bottom, 40)
            
            // Share options
            HStack(spacing: 20) {
                ShareOptionButton(icon: "link", label: "Copy link", backgroundColor: Color(.systemGray6))
                ShareOptionButton(icon: "message.fill", label: "Message", backgroundColor: Color.blue)
                ShareOptionButton(icon: "camera.fill", label: "Instagram", backgroundColor: LinearGradient(colors: [.pink, .orange], startPoint: .topLeading, endPoint: .bottomTrailing))
                ShareOptionButton(icon: "square.and.arrow.up", label: "More", backgroundColor: Color(.systemGray6))
            }
            .padding(.horizontal, 24)
            
            Spacer()
        }
        .presentationDetents([.large])
        .presentationDragIndicator(.hidden)
        .onAppear {
            withAnimation {
                isAnimating = true
            }
        }
    }
}

// MARK: - Share Option Button

struct ShareOptionButton: View {
    let icon: String
    let label: String
    let backgroundColor: AnyShapeStyle
    
    init(icon: String, label: String, backgroundColor: Color) {
        self.icon = icon
        self.label = label
        self.backgroundColor = AnyShapeStyle(backgroundColor)
    }
    
    init(icon: String, label: String, backgroundColor: LinearGradient) {
        self.icon = icon
        self.label = label
        self.backgroundColor = AnyShapeStyle(backgroundColor)
    }
    
    var body: some View {
        Button(action: {
            HapticManager.shared.light()
            // Handle share action
        }) {
            VStack(spacing: 8) {
                ZStack {
                    Circle()
                        .fill(backgroundColor)
                        .frame(width: 60, height: 60)
                    
                    Image(systemName: icon)
                        .font(.newYorkButton(size: 20))
                        .foregroundColor(.white)
                }
                
                Text(label)
                    .font(.newYorkCaption())
                    .foregroundColor(.primary)
                    .multilineTextAlignment(.center)
            }
        }
        .buttonStyle(PlainButtonStyle())
    }
}

// MARK: - Action Sheet Button

struct ActionSheetButton: View {
    let icon: String
    let title: String
    let subtitle: String
    let iconColor: Color
    let backgroundColor: Color
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            HStack(spacing: 16) {
                // Icon container - smaller size
                ZStack {
                    Circle()
                        .fill(backgroundColor)
                        .frame(width: 44, height: 44)
                    
                    Image(systemName: icon)
                        .font(.newYorkButton(size: 18))
                        .foregroundColor(iconColor)
                }
                
                // Text content - flexible width to prevent cutoff
                VStack(alignment: .leading, spacing: 4) {
                    Text(title)
                        .font(.newYorkRestaurantName(size: 16))
                        .foregroundColor(.primary)
                        .multilineTextAlignment(.leading)
                        .lineLimit(1)
                        .truncationMode(.tail)
                    
                    Text(subtitle)
                        .font(.newYorkSecondary())
                        .foregroundColor(.secondary)
                        .multilineTextAlignment(.leading)
                        .lineLimit(2)
                        .fixedSize(horizontal: false, vertical: true)
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                
                Spacer()
            }
            .frame(maxWidth: .infinity)
            .padding(.horizontal, 16)
            .padding(.vertical, 18)
            .background(Color(.systemBackground))
            .cornerRadius(16)
            .overlay(
                RoundedRectangle(cornerRadius: 16)
                    .stroke(Color(.systemGray5), lineWidth: 1)
            )
        }
        .buttonStyle(PlainButtonStyle())
    }
}

// MARK: - Together Collection View (Extends NewCollectionView with sharing)

struct TogetherCollectionView: View {
    @EnvironmentObject var store: RestaurantStore
    @Environment(\.dismiss) private var dismiss
    @Binding var showingCollectionSharing: Bool
    @Binding var createdCollectionName: String
    
    var body: some View {
        NewCollectionView(isTogetherCollection: true) { collectionName in
            // This closure is called when collection is created
            createdCollectionName = collectionName
            dismiss()
            // Show sharing sheet after a brief delay
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                showingCollectionSharing = true
            }
        }
        .environmentObject(store)
    }
}

// MARK: - Import Options Sheet

struct ImportOptionsSheet: View {
    @Environment(\.dismiss) private var dismiss
    @Binding var showingImportFromGallery: Bool
    @Binding var showingImportFromText: Bool
    
    var body: some View {
        NavigationView {
            VStack(spacing: 24) {
                // Header
                VStack(spacing: 16) {
                    Text("Import Options")
                        .font(.newYorkHeader(size: 24))
                        .foregroundColor(.primary)
                    
                    Text("Choose how you'd like to import your restaurant list")
                        .font(.newYorkBody())
                        .foregroundColor(.secondary)
                        .multilineTextAlignment(.center)
                }
                .padding(.top, 32)
                
                // Import options
                VStack(spacing: 20) {
                    // Import from Gallery
                    ImportOptionCard(
                        icon: "photo.on.rectangle",
                        title: "Import from Gallery",
                        subtitle: "Select screenshots of restaurant lists",
                        iconColor: .green,
                        backgroundColor: Color.green.opacity(0.1)
                    ) {
                        dismiss()
                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                            showingImportFromGallery = true
                        }
                    }
                    
                    // Import from Text
                    ImportOptionCard(
                        icon: "text.alignleft",
                        title: "Paste Text",
                        subtitle: "Paste restaurant names from your notes",
                        iconColor: .orange,
                        backgroundColor: Color.orange.opacity(0.1)
                    ) {
                        dismiss()
                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                            showingImportFromText = true
                        }
                    }
                }
                .padding(.horizontal, 24)
                
                Spacer()
            }
            .navigationBarItems(
                trailing: Button("Done") { dismiss() }
                    .font(.newYorkButton())
                    .foregroundColor(.reelEatsAccent)
            )
        }
        .presentationDetents([.medium])
    }
}

// MARK: - Import Option Card

struct ImportOptionCard: View {
    let icon: String
    let title: String
    let subtitle: String
    let iconColor: Color
    let backgroundColor: Color
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            VStack(spacing: 16) {
                // Icon
                ZStack {
                    Circle()
                        .fill(backgroundColor)
                        .frame(width: 72, height: 72)
                    
                    Image(systemName: icon)
                        .font(.newYorkButton(size: 28))
                        .foregroundColor(iconColor)
                }
                
                // Text
                VStack(spacing: 8) {
                    Text(title)
                        .font(.newYorkCardTitle())
                        .foregroundColor(.primary)
                        .multilineTextAlignment(.center)
                    
                    Text(subtitle)
                        .font(.newYorkSecondary())
                        .foregroundColor(.secondary)
                        .multilineTextAlignment(.center)
                }
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, 32)
            .padding(.horizontal, 20)
            .background(Color(.systemGray6))
            .cornerRadius(20)
        }
        .buttonStyle(PlainButtonStyle())
    }
}

// MARK: - Import from Gallery View

struct ImportFromGalleryView: View {
    @Environment(\.dismiss) private var dismiss
    @EnvironmentObject var store: RestaurantStore
    @State private var selectedImages: [UIImage] = []
    @State private var showingImagePicker = false
    @State private var showingProcessing = false
    
    var body: some View {
        NavigationView {
            VStack(spacing: 24) {
                if selectedImages.isEmpty {
                    // Empty state
                    VStack(spacing: 24) {
                        Spacer()
                        
                        VStack(spacing: 20) {
                            Image(systemName: "photo.on.rectangle.angled")
                                .font(.newYorkHeader(size: 64))
                                .foregroundColor(.green)
                            
                            VStack(spacing: 12) {
                                Text("Import from Photos")
                                    .font(.newYorkCardTitle(size: 22))
                                    .foregroundColor(.primary)
                                
                                Text("Select screenshots of restaurant lists from your gallery. We'll extract the restaurant names for you.")
                                    .font(.newYorkBody())
                                    .foregroundColor(.secondary)
                                    .multilineTextAlignment(.center)
                            }
                        }
                        
                        Button(action: {
                            showingImagePicker = true
                        }) {
                            Text("Select Photos")
                                .font(.newYorkButton(size: 18))
                                .foregroundColor(.white)
                                .frame(maxWidth: .infinity)
                                .padding(.vertical, 16)
                                .background(Color.green)
                                .cornerRadius(16)
                        }
                        .padding(.horizontal, 32)
                        
                        Spacer()
                    }
                } else {
                    // Selected images state
                    ScrollView {
                        LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 2), spacing: 16) {
                            ForEach(0..<selectedImages.count, id: \.self) { index in
                                Image(uiImage: selectedImages[index])
                                    .resizable()
                                    .aspectRatio(contentMode: .fill)
                                    .frame(height: 200)
                                    .cornerRadius(12)
                                    .clipped()
                            }
                        }
                        .padding(.horizontal, 20)
                    }
                    
                    Button(action: {
                        showingProcessing = true
                        // Simulate processing
                        DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
                            showingProcessing = false
                            dismiss()
                        }
                    }) {
                        HStack {
                            if showingProcessing {
                                ProgressView()
                                    .progressViewStyle(CircularProgressViewStyle(tint: .white))
                                    .scaleEffect(0.8)
                            }
                            
                            Text(showingProcessing ? "Processing..." : "Process Images")
                                .font(.newYorkButton(size: 18))
                        }
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 16)
                        .background(showingProcessing ? Color.gray : Color.green)
                        .cornerRadius(16)
                        .disabled(showingProcessing)
                    }
                    .padding(.horizontal, 20)
                }
            }
            .navigationTitle("Import from Gallery")
            .navigationBarTitleDisplayMode(.inline)
            .navigationBarItems(
                leading: Button("Cancel") { dismiss() }
                    .font(.newYorkButton())
                    .foregroundColor(.secondary),
                trailing: selectedImages.isEmpty ? nil : Button("Add More") {
                    showingImagePicker = true
                }
                .font(.newYorkButton())
                .foregroundColor(.green)
            )
        }
        .sheet(isPresented: $showingImagePicker) {
            // Mock image picker - in real app would use PHPickerViewController
            MockImagePickerView(selectedImages: $selectedImages)
        }
    }
}

// MARK: - Mock Image Picker

struct MockImagePickerView: View {
    @Environment(\.dismiss) private var dismiss
    @Binding var selectedImages: [UIImage]
    
    var body: some View {
        NavigationView {
            VStack(spacing: 20) {
                Text("Mock Image Picker")
                    .font(.newYorkHeader())
                
                Text("In a real app, this would open the photo library picker")
                    .font(.newYorkBody())
                    .foregroundColor(.secondary)
                    .multilineTextAlignment(.center)
                
                Button(action: {
                    // Add mock images
                    selectedImages = [UIImage(systemName: "photo")!]
                    dismiss()
                }) {
                    Text("Add Mock Images")
                        .font(.newYorkButton())
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 16)
                        .background(Color.green)
                        .cornerRadius(16)
                }
                .padding(.horizontal, 32)
            }
            .padding()
            .navigationBarItems(
                trailing: Button("Cancel") { dismiss() }
            )
        }
    }
}

// MARK: - Import from Text View

struct ImportFromTextView: View {
    @Environment(\.dismiss) private var dismiss
    @EnvironmentObject var store: RestaurantStore
    @State private var pastedText = ""
    @State private var extractedRestaurants: [String] = []
    @State private var showingResults = false
    
    var body: some View {
        NavigationView {
            VStack(spacing: 24) {
                if !showingResults {
                    // Text input state
                    VStack(alignment: .leading, spacing: 16) {
                        VStack(alignment: .leading, spacing: 8) {
                            Text("Paste Restaurant Names")
                                .font(.newYorkCardTitle())
                                .foregroundColor(.primary)
                            
                            Text("Paste a list of restaurant names from your notes or any text source")
                                .font(.newYorkSecondary())
                                .foregroundColor(.secondary)
                        }
                        
                        TextEditor(text: $pastedText)
                            .font(.newYorkBody())
                            .padding(.horizontal, 16)
                            .padding(.vertical, 12)
                            .frame(minHeight: 200)
                            .background(Color(.systemGray6))
                            .cornerRadius(16)
                            .overlay(
                                RoundedRectangle(cornerRadius: 16)
                                    .stroke(pastedText.isEmpty ? Color.clear : Color.reelEatsAccent, lineWidth: 2)
                            )
                    }
                    .padding(.horizontal, 20)
                    
                    if !pastedText.isEmpty {
                        Button(action: {
                            processText()
                        }) {
                            Text("Process Text")
                                .font(.newYorkButton(size: 18))
                                .foregroundColor(.white)
                                .frame(maxWidth: .infinity)
                                .padding(.vertical, 16)
                                .background(Color.reelEatsAccent)
                                .cornerRadius(16)
                        }
                        .padding(.horizontal, 20)
                    }
                } else {
                    // Results state
                    VStack(alignment: .leading, spacing: 16) {
                        VStack(alignment: .leading, spacing: 8) {
                            Text("Found Restaurants")
                                .font(.newYorkCardTitle())
                                .foregroundColor(.primary)
                            
                            Text("\(extractedRestaurants.count) restaurants found")
                                .font(.newYorkSecondary())
                                .foregroundColor(.secondary)
                        }
                        
                        ScrollView {
                            LazyVStack(spacing: 12) {
                                ForEach(extractedRestaurants, id: \.self) { restaurant in
                                    HStack {
                                        Text("🍽️")
                                            .font(.newYorkButton())
                                        
                                        Text(restaurant)
                                            .font(.newYorkRestaurantName())
                                            .foregroundColor(.primary)
                                        
                                        Spacer()
                                        
                                        Image(systemName: "checkmark.circle.fill")
                                            .font(.newYorkSecondary())
                                            .foregroundColor(.green)
                                    }
                                    .padding(.horizontal, 16)
                                    .padding(.vertical, 12)
                                    .background(Color(.systemGray6))
                                    .cornerRadius(12)
                                }
                            }
                            .padding(.horizontal, 20)
                        }
                        
                        Button(action: {
                            // Add restaurants to saved
                            dismiss()
                        }) {
                            Text("Add All to Saved")
                                .font(.newYorkButton(size: 18))
                                .foregroundColor(.white)
                                .frame(maxWidth: .infinity)
                                .padding(.vertical, 16)
                                .background(Color.reelEatsAccent)
                                .cornerRadius(16)
                        }
                        .padding(.horizontal, 20)
                    }
                }
                
                Spacer()
            }
            .padding(.top, 20)
            .navigationTitle("Import from Text")
            .navigationBarTitleDisplayMode(.inline)
            .navigationBarItems(
                leading: Button("Cancel") { dismiss() }
                    .font(.newYorkButton())
                    .foregroundColor(.secondary),
                trailing: showingResults ? Button("Edit") {
                    showingResults = false
                }
                .font(.newYorkButton())
                .foregroundColor(.reelEatsAccent) : nil
            )
        }
    }
    
    private func processText() {
        // Simple text processing - split by lines and filter non-empty
        let lines = pastedText.components(separatedBy: .newlines)
            .map { $0.trimmingCharacters(in: .whitespacesAndNewlines) }
            .filter { !$0.isEmpty && $0.count > 2 }
        
        extractedRestaurants = lines
        showingResults = true
    }
}

// MARK: - Custom Bottom Navigation Bar

struct CustomBottomNavBar: View {
    @Binding var selectedTab: Int
    @Binding var showingAddMenu: Bool
    @Binding var showingRecimeSheet: Bool
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
                        // Home tab
                        Spacer()
                        TabBarItem(
                            icon: selectedTab == 0 ? "house.fill" : "house",
                            title: "Home",
                            isSelected: selectedTab == 0
                        ) {
                            HapticManager.shared.selection()
                            selectedTab = 0
                        }
                        
                        Spacer()
                        
                        // Center floating + button with animation to X
                        Button(action: {
                            HapticManager.shared.light()
                            if showingRecimeSheet {
                                showingRecimeSheet = false
                            } else {
                                showingRecimeSheet = true
                            }
                        }) {
                            Image(systemName: showingRecimeSheet ? "xmark" : "plus")
                                .font(.newYorkButton(size: 24))
                                .foregroundColor(.white)
                                .frame(width: 60, height: 60)
                                .background(Color.reelEatsAccent)
                                .clipShape(Circle())
                                .shadow(color: .reelEatsAccent.opacity(0.4), radius: 8, x: 0, y: 4)
                                .rotationEffect(.degrees(showingRecimeSheet ? 90 : 0))
                                .animation(.spring(response: 0.3, dampingFraction: 0.8), value: showingRecimeSheet)
                        }
                        .offset(y: -17)
                        
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

// MARK: - My Lists Filter Bar


// MARK: - My Lists Sort and Grid Toggle


// MARK: - Tab Bar Item

struct TabBarItem: View {
    let icon: String
    let title: String
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            Image(systemName: icon)
                .font(.newYorkButton(size: 24)) // Slightly larger since no text
                .foregroundColor(isSelected ? .reelEatsAccent : .gray)
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
    case bakery = "Bakery"
    case desserts = "Desserts"
    case fastfood = "Fast Food"
    case finedining = "Fine Dining"
    
    var icon: String {
        switch self {
        case .all: return "list.bullet"
        case .restaurants: return "fork.knife"
        case .cafe: return "cup.and.saucer.fill"
        case .bars: return "wineglass.fill"
        case .bakery: return "bag.fill"
        case .desserts: return "birthday.cake.fill"
        case .fastfood: return "takeoutbag.and.cup.and.straw.fill"
        case .finedining: return "flame.fill"
        }
    }
    
    var emoji: String {
        switch self {
        case .all: return "🍽️"
        case .restaurants: return "🍝"
        case .cafe: return "☕"
        case .bars: return "🍸"
        case .bakery: return "🥐"
        case .desserts: return "🍰"
        case .fastfood: return "🍔"
        case .finedining: return "🍷"
        }
    }
    
    var color: Color {
        switch self {
        case .all: return Color(red: 0.5, green: 0.5, blue: 0.5)
        case .restaurants: return Color(red: 0.2, green: 0.6, blue: 1.0)
        case .cafe: return Color(red: 0.8, green: 0.5, blue: 0.2)
        case .bars: return Color(red: 0.7, green: 0.3, blue: 0.9)
        case .bakery: return Color(red: 0.92, green: 0.78, blue: 0.48)
        case .desserts: return Color(red: 1.0, green: 0.4, blue: 0.8)
        case .fastfood: return Color(red: 1.0, green: 0.6, blue: 0.2)
        case .finedining: return Color(red: 0.8, green: 0.7, blue: 0.2)
        }
    }
    
    var gradientColors: [Color] {
        switch self {
        case .all: return [Color(red: 0.6, green: 0.6, blue: 0.6), Color(red: 0.4, green: 0.4, blue: 0.4)]
        case .restaurants: return [Color(red: 0.3, green: 0.7, blue: 1.0), Color(red: 0.1, green: 0.5, blue: 0.9)]
        case .cafe: return [Color(red: 0.9, green: 0.6, blue: 0.3), Color(red: 0.7, green: 0.4, blue: 0.1)]
        case .bars: return [Color(red: 0.8, green: 0.4, blue: 1.0), Color(red: 0.6, green: 0.2, blue: 0.8)]
        case .bakery: return [Color(red: 0.96, green: 0.86, blue: 0.60), Color(red: 0.88, green: 0.72, blue: 0.40)]
        case .desserts: return [Color(red: 1.0, green: 0.5, blue: 0.9), Color(red: 0.9, green: 0.3, blue: 0.7)]
        case .fastfood: return [Color(red: 1.0, green: 0.7, blue: 0.3), Color(red: 0.9, green: 0.5, blue: 0.1)]
        case .finedining: return [Color(red: 0.9, green: 0.8, blue: 0.3), Color(red: 0.7, green: 0.6, blue: 0.1)]
        }
    }
}

// MARK: - My Lists Filter Bar


// MARK: - My Lists Sort and Grid Toggle


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

// MARK: - My Lists Filter Bar


// MARK: - My Lists Sort and Grid Toggle


struct Restaurant: Identifiable, Equatable {
    let id = UUID()
    let name: String
    let category: RestaurantCategory
    let imageURL: String
    let emoji: String
    let description: String
    let rating: Double
    let priceRange: String
    let address: String
    let latitude: Double
    let longitude: Double
    let tags: [String]
    let source: SocialSource
    
    static func == (lhs: Restaurant, rhs: Restaurant) -> Bool {
        return lhs.id == rhs.id
    }
}

// User interaction data for restaurants
struct RestaurantUserData: Identifiable {
    let id = UUID()
    let restaurantId: UUID
    var visitStatus: VisitStatus = .wantToTry
    var userRating: Double = 0.0
    var dateVisited: Date?
    
    init(restaurantId: UUID, visitStatus: VisitStatus = .wantToTry, userRating: Double = 0.0, dateVisited: Date? = nil) {
        self.restaurantId = restaurantId
        self.visitStatus = visitStatus
        self.userRating = userRating
        self.dateVisited = dateVisited
    }
}

enum VisitStatus: String, CaseIterable {
    case wantToTry = "Want to try"
    case visited = "Visited"
    
    var icon: String {
        switch self {
        case .wantToTry: return "bookmark"
        case .visited: return "checkmark.circle.fill"
        }
    }
    
    var color: Color {
        switch self {
        case .wantToTry: return .blue
        case .visited: return .green
        }
    }
}

// MARK: - My Lists Filter Bar


// MARK: - My Lists Sort and Grid Toggle



struct Collection: Identifiable {
    let id = UUID()
    let name: String
    var restaurantIds: [UUID]
    let creators: [String] // Array of creator names
    let isCollaborative: Bool
    
    var creatorText: String {
        if creators.count == 1 {
            return creators[0]
        } else if creators.count == 2 {
            return "\(creators[0]) +1"
        } else if creators.count > 2 {
            return "\(creators[0]) +\(creators.count - 1)"
        }
        return ""
    }
    
    var filterType: CollectionFilterType {
        if creators.contains("Julz") && creators.count == 1 {
            return .byMe
        } else if creators.contains("Julz") && creators.count > 1 {
            return .byUs
        } else {
            return .byOthers
        }
    }
}

// MARK: - Melbourne Demo Data

struct Melbourne {
    static let demoRestaurants: [Restaurant] = [
        Restaurant(
            name: "Baker Bleu",
            category: .restaurants,
            imageURL: "https://images.unsplash.com/photo-1509440159596-0249088772ff?ixlib=rb-4.0.3&auto=format&fit=crop&w=800&q=80",
            emoji: "🥖",
            description: "artisan sourdough bakery",
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
            emoji: "☕",
            description: "specialty coffee roasters",
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
            emoji: "🍿",
            description: "modern fine dining",
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
            emoji: "🍸",
            description: "classic cocktail bar",
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
            emoji: "🥐",
            description: "all-day brunch spot",
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
            emoji: "🍜",
            description: "modern southeast asian",
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
            emoji: "🥞",
            description: "innovative brunch menu",
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
            emoji: "🍷",
            description: "hidden cocktail bar",
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
            emoji: "🍣",
            description: "japanese fine dining",
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
            emoji: "🍃",
            description: "native australian cuisine",
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
            emoji: "🍹",
            description: "intimate american bar",
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
            emoji: "☕",
            description: "specialty coffee brewers",
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
            emoji: "🍝",
            description: "authentic italian pasta",
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
            emoji: "🍷",
            description: "intimate wine bar",
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
            emoji: "☕",
            description: "award-winning coffee",
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
            emoji: "🥟",
            description: "cantonese fine dining",
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
            emoji: "🍸",
            description: "creative cocktail bar",
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
    @Published var sortByFilter = DropdownFilter(
        id: "sortBy",
        label: "Sort By",
        defaultText: "Sort By",
        options: ["Most recently added", "Closest to me"],
        multiSelect: false
    )
    
    @Published var visitStatusFilter = DropdownFilter(
        id: "visitStatus",
        label: "Visit Status", 
        defaultText: "Visit Status",
        options: ["Want to try", "Visited", "Both"],
        multiSelect: false
    )
    
    @Published var cuisineFilter = DropdownFilter(
        id: "cuisine",
        label: "Cuisine",
        defaultText: "All Cuisine",
        options: ["Italian", "Asian", "Mexican", "Korean", "Chinese", "Pizza", "Burgers", "Cafe", "Fine Dining", "Brunch", "Bars", "Healthy", "Desserts", "Seafood", "BBQ"],
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
        !sortByFilter.selectedOptions.isEmpty ||
        !visitStatusFilter.selectedOptions.isEmpty ||
        !cuisineFilter.selectedOptions.isEmpty ||
        !distanceFilter.selectedOptions.isEmpty ||
        !priceFilter.selectedOptions.isEmpty ||
        openNowFilter.isEnabled ||
        !collectionsFilter.selectedOptions.isEmpty
    }
    
    func clearAll() {
        sortByFilter.selectedOptions.removeAll()
        visitStatusFilter.selectedOptions.removeAll()
        cuisineFilter.selectedOptions.removeAll()
        distanceFilter.selectedOptions.removeAll()
        priceFilter.selectedOptions.removeAll()
        openNowFilter.isEnabled = false
        collectionsFilter.selectedOptions.removeAll()
    }
}

// Main Filter Bar Component
// MARK: - Modern Three-Pill Filter System

enum VenueType: String, CaseIterable {
    case restaurant = "Restaurant"
    case cafe = "Cafe"
    case bar = "Bar"
    case bakery = "Bakery"
}

enum ModernFilterViewState {
    case primary
    case secondary(VenueType)
    
    var categoryName: String {
        switch self {
        case .primary:
            return ""
        case .secondary(.restaurant):
            return "Cuisine"
        case .secondary(.cafe):
            return "Vibes"
        case .secondary(.bar):
            return "Vibes"
        case .secondary(.bakery):
            return "Types"
        }
    }
}

class ModernFilterState: ObservableObject {
    @Published var currentState: ModernFilterViewState = .primary
    @Published var selectedVenueType: VenueType? = nil
    @Published var showingBottomSheet = false
    @Published var selectedOptions: Set<String> = []
    
    func reset() {
        withAnimation(.easeInOut(duration: 0.4)) {
            currentState = .primary
            selectedVenueType = nil
            selectedOptions.removeAll()
        }
    }
    
    func selectVenueType(_ type: VenueType) {
        withAnimation(.easeInOut(duration: 0.4)) {
            currentState = .secondary(type)
            selectedVenueType = type
        }
    }
    
    func showBottomSheet() {
        showingBottomSheet = true
    }
    
    var categoryDisplayText: String {
        guard !selectedOptions.isEmpty else { return currentState.categoryName }
        return "\(currentState.categoryName) (\(selectedOptions.count))"
    }
}

struct ModernFilterBar: View {
    @StateObject private var filterState = ModernFilterState()
    
    var body: some View {
        HStack(spacing: 12) {
            switch filterState.currentState {
            case .primary:
                // Primary pills
                ForEach(VenueType.allCases, id: \.self) { venueType in
                    ModernFilterPill(text: venueType.rawValue, style: .primary) {
                        HapticManager.shared.light()
                        filterState.selectVenueType(venueType)
                    }
                    .transition(.opacity)
                }
                
            case .secondary(let selectedType):
                // X button
                ModernFilterPill(text: "✕", style: .reset) {
                    HapticManager.shared.light()
                    filterState.reset()
                }
                .transition(.opacity)
                
                // Selected venue type pill
                ModernFilterPill(text: selectedType.rawValue, style: .selected) {
                    // No action needed
                }
                .transition(.opacity)
                
                // Category dropdown pill
                ModernFilterPill(text: filterState.categoryDisplayText, style: .category, hasDropdown: true) {
                    HapticManager.shared.light()
                    filterState.showBottomSheet()
                }
                .transition(.opacity)
            }
            
            Spacer()
        }
        .padding(.horizontal, 16)
        .sheet(isPresented: $filterState.showingBottomSheet) {
            if let venueType = filterState.selectedVenueType {
                CategoryBottomSheet(
                    venueType: venueType,
                    selectedOptions: $filterState.selectedOptions
                )
                .presentationDetents([.height(calculateSheetHeight(for: venueType))])
                .presentationDragIndicator(.visible)
            }
        }
    }
    
    private func calculateSheetHeight(for venueType: VenueType) -> CGFloat {
        // Tighter, best-practice sizing: show full rows and leave a little whitespace at the bottom
        let headerHeight: CGFloat = 84
        let cardHeight: CGFloat = 56
        let rowSpacing: CGFloat = 12
        let bottomPadding: CGFloat = 20
        let screenMax: CGFloat = UIScreen.main.bounds.height * 0.88
        
        let itemCount = getCategoryCount(for: venueType)
        let rows = ceil(Double(itemCount) / 2.0) // 2 columns
        let gridHeight = CGFloat(rows) * cardHeight + max(0, CGFloat(rows - 1)) * rowSpacing
        let desired = headerHeight + gridHeight + bottomPadding
        
        // Ensure reasonable min/max bounds
        return min(max(desired, 280), screenMax)
    }
    
    private func getCategoryCount(for venueType: VenueType) -> Int {
        switch venueType {
        case .restaurant:
            return 12 // Italian, Japanese, Mexican, Thai, Pizza, Indian, American, Mediterranean, Korean, French, Vietnamese, Middle Eastern
        case .cafe:
            return 10 // European, Matcha, Japanese, Plant-filled, Study-friendly, Minimalist, Industrial, Cozy, Parisian, Organic
        case .bar:
            return 10 // Cocktail, Dive, Rooftop, Sports, Wine, Speakeasy, Dance, Chill, Date Night, Live Music
        case .bakery:
            return 10 // French, Sandwiches, Japanese, Cupcakes, Donuts, Bagels, Artisan Bread, Pastries, German, Cakes
        }
    }
}

enum PillStyle {
    case primary
    case selected
    case category
    case reset
}

struct ModernFilterPill: View {
    let text: String
    let style: PillStyle
    var hasDropdown: Bool = false
    let action: () -> Void
    @State private var isPressed = false
    
    private var backgroundColor: Color {
        switch style {
        case .primary:
            return Color.clear
        case .selected:
            return Color.reelEatsAccent
        case .category:
            return Color.clear
        case .reset:
            return Color.clear
        }
    }
    
    private var textColor: Color {
        switch style {
        case .primary:
            return .primary
        case .selected:
            return .white
        case .category:
            return .primary
        case .reset:
            return .primary
        }
    }
    
    var body: some View {
        Button(action: {
            action()
        }) {
            HStack(spacing: 6) {
                Text(text)
                    .font(.newYorkTag(size: 14))
                    .foregroundColor(textColor)
                
                if hasDropdown {
                    Image(systemName: "chevron.down")
                        .font(.system(size: 10, weight: .medium))
                        .foregroundColor(textColor)
                }
            }
            .padding(.horizontal, 12)
            .padding(.vertical, 6)
            .background(backgroundColor)
            .overlay(
                RoundedRectangle(cornerRadius: 20)
                    .stroke(style == .selected ? Color.clear : Color(.systemGray4), lineWidth: 1)
            )
            .cornerRadius(20)
        }
        .scaleEffect(isPressed ? 0.95 : 1.0)
        .onTapGesture {
            withAnimation(.easeInOut(duration: 0.1)) {
                isPressed = true
            }
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                withAnimation(.easeInOut(duration: 0.1)) {
                    isPressed = false
                }
            }
        }
    }
}

struct CategoryBottomSheet: View {
    let venueType: VenueType
    @Binding var selectedOptions: Set<String>
    @Environment(\.dismiss) private var dismiss
    
    private var categoryOptions: [String] {
        switch venueType {
        case .restaurant:
            return [
                "🍝 Italian", "🍜 Japanese", "🌮 Mexican", "🍛 Thai", "🍕 Pizza",
                "🥘 Indian", "🍔 American", "🥗 Mediterranean", "🍱 Korean", "🥖 French",
                "🍲 Vietnamese", "🌯 Middle Eastern"
            ]
        case .cafe:
            return [
                "☕ European", "🍵 Matcha", "🌸 Japanese", "🪴 Plant-filled",
                "📚 Study-friendly", "✨ Minimalist", "🏭 Industrial", "🧸 Cozy",
                "🥐 Parisian", "🌿 Organic"
            ]
        case .bar:
            return [
                "🍸 Cocktail", "🍺 Dive", "🏙️ Rooftop", "📺 Sports", "🍷 Wine",
                "🕯️ Speakeasy", "💃 Dance", "🌙 Chill", "💕 Date Night", "🎵 Live Music"
            ]
        case .bakery:
            return [
                "🥐 French", "🥪 Sandwiches", "🍡 Japanese", "🧁 Cupcakes", "🍩 Donuts",
                "🥯 Bagels", "🍞 Artisan Bread", "🥧 Pastries", "🥨 German", "🍰 Cakes"
            ]
        }
    }
    
    var body: some View {
        NavigationView {
            VStack(spacing: 20) {
                // Header
                HStack {
                    Text(venueType.rawValue)
                        .font(.newYorkHeader(size: 24))
                        .foregroundColor(.primary)
                    
                    Spacer()
                    
                    Button("Done") {
                        dismiss()
                    }
                    .font(.newYorkButton())
                    .foregroundColor(.reelEatsAccent)
                }
                .padding(.horizontal, 20)
                .padding(.top, 20)
                
                // Grid of options
                ScrollView {
                    LazyVGrid(columns: Array(repeating: GridItem(.flexible(), spacing: 12), count: 2), spacing: 12) {
                        ForEach(categoryOptions, id: \.self) { option in
                            CategoryCard(
                                option: option,
                                isSelected: selectedOptions.contains(option)
                            ) {
                                HapticManager.shared.light()
                                withAnimation(.spring(response: 0.3, dampingFraction: 0.8)) {
                                    if selectedOptions.contains(option) {
                                        selectedOptions.remove(option)
                                    } else {
                                        selectedOptions.insert(option)
                                    }
                                }
                            }
                        }
                    }
                    .padding(.horizontal, 20)
                }
            }
        }
    }
}

struct CategoryCard: View {
    let option: String
    let isSelected: Bool
    let action: () -> Void
    @State private var isPressed = false
    
    var body: some View {
        Button(action: action) {
            HStack {
                Text(option)
                    .font(.newYorkRestaurantName(size: 16))
                    .foregroundColor(.primary)
                    .multilineTextAlignment(.leading)
                
                Spacer()
                
                if isSelected {
                    Image(systemName: "checkmark.circle.fill")
                        .font(.system(size: 20))
                        .foregroundColor(.reelEatsAccent)
                }
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 16)
            .background(
                RoundedRectangle(cornerRadius: 12)
                    .fill(isSelected ? Color.reelEatsAccent.opacity(0.1) : Color(.systemGray6))
                    .overlay(
                        RoundedRectangle(cornerRadius: 12)
                            .stroke(isSelected ? Color.reelEatsAccent : Color.clear, lineWidth: 2)
                    )
            )
        }
        .scaleEffect(isPressed ? 1.05 : 1.0)
        .animation(.spring(response: 0.3, dampingFraction: 0.8), value: isPressed)
        .onTapGesture {
            withAnimation {
                isPressed = true
            }
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                withAnimation {
                    isPressed = false
                }
            }
        }
    }
}

struct FilterBar: View {
    @EnvironmentObject var filterState: FilterState
    @Binding var showingCuisineDropdown: Bool
    @Binding var showingDistanceDropdown: Bool
    @Binding var showingPriceDropdown: Bool
    @Binding var showingCollectionsDropdown: Bool
    
    var body: some View {
        // Replace old filter system with modern three-pill system
        ModernFilterBar()
    }
}

// MARK: - My Lists Filter Bar


// MARK: - My Lists Sort and Grid Toggle



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
                // Clean text without emojis - updated font and style
                Text(text)
                    .font(.newYorkTag())
                    .foregroundColor(isSelected ? .white : .primary)
                
                if hasDropdown {
                    Image(systemName: "chevron.down")
                        .font(.newYorkCaption())
                        .foregroundColor(isSelected ? .white.opacity(0.8) : .secondary)
                }
            }
            .padding(.horizontal, 12)
            .padding(.vertical, 6)
            .background(isSelected ? Color.reelEatsAccent : Color.clear)
            .overlay(
                RoundedRectangle(cornerRadius: 20)
                    .stroke(isSelected ? Color.clear : Color(.systemGray4), lineWidth: 1)
            )
            .cornerRadius(20)
        }
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
                    .font(.clashDisplayButtonTemp(size: 18))
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
                            .font(.clashDisplayButtonTemp())
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 14)
                            .background(Color.reelEatsAccent)
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

// MARK: - My Lists Filter Bar


// MARK: - My Lists Sort and Grid Toggle


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
                    .font(.clashDisplayBodyTemp())
                    .foregroundColor(.primary)
                
                Spacer()
                
                if multiSelect {
                    // Checkbox for multi-select
                    Image(systemName: isSelected ? "checkmark.square.fill" : "square")
                        .font(.clashDisplayRestaurantNameTemp(size: 20))
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

// MARK: - My Lists Filter Bar


// MARK: - My Lists Sort and Grid Toggle


// More Filters Bottom Sheet
struct MoreFiltersSheet: View {
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        NavigationView {
            VStack(alignment: .leading, spacing: 24) {
                Text("More filters coming soon!")
                    .font(.clashDisplayBodyTemp(size: 18))
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

// MARK: - My Lists Filter Bar


// MARK: - My Lists Sort and Grid Toggle

// MARK: - Distance Slider View

struct DistanceSliderView: View {
    @Binding var isPresented: Bool
    @State private var distanceValue: Double = 5.0 // Default 5km
    
    private var distanceText: String {
        if distanceValue <= 1 {
            return "Walking (5min)"
        } else if distanceValue <= 10 {
            return "Short drive (\(Int(distanceValue))km)"
        } else {
            return "Anywhere"
        }
    }
    
    var body: some View {
        VStack(spacing: 24) {
            VStack(spacing: 16) {
                Text(distanceText)
                    .font(.newYorkHeader(size: 20))
                    .foregroundColor(.primary)
                
                Text("\(String(format: "%.0f", distanceValue)) km radius")
                    .font(.newYorkSecondary())
                    .foregroundColor(.secondary)
            }
            .padding(.top, 8)
            
            // Distance slider
            VStack(spacing: 16) {
                Slider(value: $distanceValue, in: 0...25, step: 1) {
                    Text("Distance")
                } minimumValueLabel: {
                    Text("0km")
                        .font(.newYorkCaption())
                        .foregroundColor(.secondary)
                } maximumValueLabel: {
                    Text("25km+")
                        .font(.newYorkCaption())
                        .foregroundColor(.secondary)
                }
                .accentColor(.reelEatsAccent)
                
                // Distance markers
                HStack {
                    VStack(spacing: 4) {
                        Circle()
                            .fill(distanceValue <= 1 ? Color.reelEatsAccent : Color.gray.opacity(0.3))
                            .frame(width: 8, height: 8)
                        Text("Walking")
                            .font(.newYorkCaption(size: 10))
                            .foregroundColor(.secondary)
                    }
                    
                    Spacer()
                    
                    VStack(spacing: 4) {
                        Circle()
                            .fill(distanceValue > 1 && distanceValue <= 10 ? Color.reelEatsAccent : Color.gray.opacity(0.3))
                            .frame(width: 8, height: 8)
                        Text("Drive")
                            .font(.newYorkCaption(size: 10))
                            .foregroundColor(.secondary)
                    }
                    
                    Spacer()
                    
                    VStack(spacing: 4) {
                        Circle()
                            .fill(distanceValue > 10 ? Color.reelEatsAccent : Color.gray.opacity(0.3))
                            .frame(width: 8, height: 8)
                        Text("Anywhere")
                            .font(.newYorkCaption(size: 10))
                            .foregroundColor(.secondary)
                    }
                }
                .padding(.horizontal, 8)
            }
            .padding(.horizontal, 20)
            
            // Apply and Reset buttons
            HStack(spacing: 12) {
                Button(action: {
                    distanceValue = 5.0
                }) {
                    Text("Reset")
                        .font(.newYorkButton())
                        .foregroundColor(.primary)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 16)
                        .background(Color(.systemGray6))
                        .cornerRadius(12)
                }
                
                Button(action: {
                    withAnimation(.easeInOut(duration: 0.3)) {
                        isPresented = false
                    }
                }) {
                    Text("Apply")
                        .font(.newYorkButton())
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 16)
                        .background(Color.reelEatsAccent)
                        .cornerRadius(12)
                }
            }
            .padding(.horizontal, 20)
            .padding(.bottom, 20)
        }
    }
}
// MARK: - UberEats Style Price Selector

struct UberEatsPriceSelector: View {
    let selectedOptions: Set<String>
    @Binding var isPresented: Bool
    let onSelectionChange: (String) -> Void
    
    private let priceOptions = ["$", "$$", "$$$", "$$$$"]
    
    var body: some View {
        VStack(spacing: 24) {
            // Horizontal price pills
            HStack(spacing: 16) {
                ForEach(priceOptions, id: \.self) { option in
                    PricePill(
                        text: option,
                        isSelected: selectedOptions.contains(option)
                    ) {
                        onSelectionChange(option)
                    }
                }
            }
            .padding(.horizontal, 20)
            .padding(.top, 8)
            
            // Apply and Reset buttons
            HStack(spacing: 12) {
                Button(action: {
                    // Reset all selections
                    for option in selectedOptions {
                        onSelectionChange(option)
                    }
                }) {
                    Text("Reset")
                        .font(.newYorkButton())
                        .foregroundColor(.primary)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 16)
                        .background(Color(.systemGray6))
                        .cornerRadius(12)
                }
                
                Button(action: {
                    withAnimation(.easeInOut(duration: 0.3)) {
                        isPresented = false
                    }
                }) {
                    Text("Apply")
                        .font(.newYorkButton())
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 16)
                        .background(Color.reelEatsAccent)
                        .cornerRadius(12)
                }
            }
            .padding(.horizontal, 20)
            .padding(.bottom, 20)
        }
    }
}

// MARK: - Price Pill Component

struct PricePill: View {
    let text: String
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            Text(text)
                .font(.newYorkButton(size: 24))
                .foregroundColor(isSelected ? .white : .primary)
                .frame(width: 70, height: 70)
                .background(
                    Circle()
                        .fill(isSelected ? Color.black : Color(.systemGray6))
                )
                .overlay(
                    Circle()
                        .stroke(isSelected ? Color.black : Color(.systemGray4), lineWidth: isSelected ? 0 : 1)
                )
        }
        .buttonStyle(PlainButtonStyle())
        .scaleEffect(isSelected ? 0.95 : 1.0)
        .animation(.easeInOut(duration: 0.2), value: isSelected)
    }
}


// MARK: - Collections Sort Only (No Grid Toggle)
struct CollectionsSortOnly: View {
    @Binding var sortOrder: HomeTabView.MyListsSortOrder
    @Binding var showingSortOptions: Bool
    
    var body: some View {
        HStack(spacing: 12) {
            // Sort button (matching SpotifySortAndGrid style exactly)
            Button(action: {
                HapticManager.shared.light()
                withAnimation(.easeInOut(duration: 0.2)) {
                    showingSortOptions.toggle()
                }
            }) {
                HStack(spacing: 6) {
                    Image(systemName: "arrow.up.arrow.down")
                        .font(.clashDisplaySecondaryTemp())
                        .foregroundColor(.primary)
                    
                    Text(sortOrder.shortName)
                        .font(.clashDisplaySecondaryTemp())
                        .foregroundColor(.primary)
                }
                .padding(.horizontal, 8)
                .padding(.vertical, 6)
            }
            .buttonStyle(PlainButtonStyle())
            
            Spacer()
            
            // Collections are always grid view - no toggle needed
        }
    }
}

