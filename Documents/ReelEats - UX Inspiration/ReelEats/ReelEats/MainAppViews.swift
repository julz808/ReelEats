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
    @State private var showingListView = true // true for List, false for Map
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
    @State private var showingGridView = false // For All Spots grid/list toggle
    @State private var showingByMeDropdown = false
    @State private var showingByOthersDropdown = false
    @State private var myListsSortOrder: MyListsSortOrder = .recentlyCreated
    @State private var showingMyListsSortOptions = false
    @State private var collectionFilter: CollectionFilterType = .byMe
    
    enum ContentType: String, CaseIterable {
        case spots = "All Spots"
        case collections = "My Lists"
    }
    
    enum SortOrder: String, CaseIterable {
        case recentlyAdded = "Recently added"
        case alphabetical = "Alphabetical"
        case rating = "Rating"
        case distance = "Distance"
        
        var icon: String {
            switch self {
            case .recentlyAdded: return "clock"
            case .alphabetical: return "textformat"
            case .rating: return "star"
            case .distance: return "location"
            }
        }
    }
    
    enum MyListsSortOrder: String, CaseIterable {
        case recentlyCreated = "Recently created"
        case alphabetical = "Alphabetical"
        case creator = "Creator"
        
        var icon: String {
            switch self {
            case .recentlyCreated: return "clock"
            case .alphabetical: return "textformat"
            case .creator: return "person"
            }
        }
    }
    
    var body: some View {
        NavigationView {
            VStack(spacing: 0) {
                // Sticky header section - ReelEats logo, search, add button, and toggle
                VStack(spacing: 0) {
                    SpotifyStyleHeader(
                        showingSearch: $showingSearch,
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
                
                // Scrollable content
                ScrollView {
                    LazyVStack(spacing: 0) {
                        
                        if selectedContentType == .spots {
                            // Filter pills (above sort/grid section) - no left padding for proper alignment
                            FilterBar(
                                showingCuisineDropdown: $showingCuisineDropdown,
                                showingDistanceDropdown: $showingDistanceDropdown,
                                showingPriceDropdown: $showingPriceDropdown,
                                showingCollectionsDropdown: $showingCollectionsDropdown
                            )
                                .environmentObject(filterState)
                                .padding(.top, 8)  // Reduced from 16
                                .padding(.bottom, 8)  // Reduced from 12
                            
                            // Spotify-style sort and grid/list toggle
                            SpotifySortAndGrid(
                                sortOrder: $sortOrder,
                                showingGridView: $showingGridView,
                                showingSortOptions: $showingSortOptions
                            )
                            .padding(.horizontal, 16)
                            .padding(.bottom, 16)
                            
                            // Main content based on view toggle
                            if showingListView {
                                // Embedded list content (no separate ScrollView)
                                SpotsListContent(
                                    selectedCategory: $selectedCategory,
                                    sortOrder: sortOrder,
                                    isGridView: showingGridView,
                                    onRestaurantSelect: { restaurant in
                                        selectedRestaurantForDetail = restaurant
                                    }
                                )
                                .environmentObject(store)
                            } else {
                                // Map view placeholder (maps typically need their own container)
                                VStack {
                                    Text("Map view - click a restaurant card to see it on map")
                                        .foregroundColor(.secondary)
                                        .padding()
                                    
                                    // Show restaurant cards that when tapped will switch to map
                                    SpotsListContent(
                                        selectedCategory: $selectedCategory,
                                        sortOrder: sortOrder,
                                        isGridView: showingGridView,
                                        onRestaurantSelect: { restaurant in
                                            selectedRestaurantForDetail = restaurant
                                        }
                                    )
                                    .environmentObject(store)
                                }
                            }
                        } else {
                            // My Lists filters and sort
                            MyListsFilterBar(
                                showingByMeDropdown: $showingByMeDropdown,
                                showingByOthersDropdown: $showingByOthersDropdown,
                                collectionFilter: $collectionFilter
                            )
                            .environmentObject(filterState)
                            .padding(.top, 8)
                            .padding(.bottom, 8)
                            
                            // My Lists sort and grid/list toggle
                            MyListsSortAndGrid(
                                sortOrder: $myListsSortOrder,
                                showingListView: $showingListView,
                                showingSortOptions: $showingMyListsSortOptions
                            )
                            .padding(.horizontal, 16)
                            .padding(.bottom, 16)
                            
                            // Collections content (now embedded in main scroll)
                            CollectionsEmbeddedContent(
                                selectedCollection: $selectedCollection,
                                onRestaurantSelect: { restaurant in
                                    selectedRestaurant = restaurant
                                    showingListView = false // Switch to map view
                                },
                                isListView: showingListView,
                                collectionFilter: collectionFilter
                            )
                            .environmentObject(store)
                        }
                        
                        // Bottom safe area padding
                        Color.clear
                            .frame(height: 100)
                    }
                }
            }
        }
        .navigationBarHidden(true)
        .overlay(
            // UberEats-style bottom sheet overlay
            Group {
                if showingSortOptions {
                    UberEatsBottomSheetOverlay(
                        isPresented: $showingSortOptions,
                        title: "Sort by"
                    ) {
                        VStack(spacing: 0) {
                            ForEach(HomeTabView.SortOrder.allCases, id: \.self) { option in
                                FilterOptionItem(
                                    title: option.rawValue,
                                    isSelected: sortOrder == option,
                                    action: {
                                        HapticManager.shared.selection()
                                        sortOrder = option
                                        withAnimation(.easeInOut(duration: 0.2)) {
                                            showingSortOptions = false
                                        }
                                    }
                                )
                            }
                        }
                        .padding(.bottom, 32)
                    }
                }
                
                // Filter dropdowns as overlays
                if showingCuisineDropdown {
                    UberEatsBottomSheetOverlay(
                        isPresented: $showingCuisineDropdown,
                        title: "Cuisine"
                    ) {
                        GoogleStyleCuisineGrid(
                            cuisineOptions: filterState.cuisineFilter.options,
                            selectedOptions: filterState.cuisineFilter.selectedOptions
                        ) { option in
                            HapticManager.shared.light()
                            if filterState.cuisineFilter.selectedOptions.contains(option) {
                                filterState.cuisineFilter.selectedOptions.remove(option)
                            } else {
                                filterState.cuisineFilter.selectedOptions.insert(option)
                            }
                        }
                    }
                }
                
                if showingDistanceDropdown {
                    UberEatsBottomSheetOverlay(
                        isPresented: $showingDistanceDropdown,
                        title: "Distance"
                    ) {
                        VStack(spacing: 0) {
                            ForEach(filterState.distanceFilter.options, id: \.self) { option in
                                FilterOptionItem(
                                    title: option,
                                    isSelected: filterState.distanceFilter.selectedOptions.contains(option)
                                ) {
                                    HapticManager.shared.light()
                                    filterState.distanceFilter.selectedOptions = Set([option])
                                    withAnimation(.easeInOut(duration: 0.3)) {
                                        showingDistanceDropdown = false
                                    }
                                }
                            }
                        }
                        .padding(.bottom, 20)
                    }
                }
                
                if showingPriceDropdown {
                    UberEatsBottomSheetOverlay(
                        isPresented: $showingPriceDropdown,
                        title: "Price Range"
                    ) {
                        VStack(spacing: 0) {
                            ForEach(filterState.priceFilter.options, id: \.self) { option in
                                FilterOptionItem(
                                    title: option,
                                    isSelected: filterState.priceFilter.selectedOptions.contains(option)
                                ) {
                                    HapticManager.shared.light()
                                    if filterState.priceFilter.selectedOptions.contains(option) {
                                        filterState.priceFilter.selectedOptions.remove(option)
                                    } else {
                                        filterState.priceFilter.selectedOptions.insert(option)
                                    }
                                }
                            }
                        }
                        .padding(.bottom, 20)
                    }
                }
                
                if showingCollectionsDropdown {
                    UberEatsBottomSheetOverlay(
                        isPresented: $showingCollectionsDropdown,
                        title: "My Lists"
                    ) {
                        VStack(spacing: 0) {
                            ForEach(filterState.collectionsFilter.options, id: \.self) { option in
                                FilterOptionItem(
                                    title: option,
                                    isSelected: filterState.collectionsFilter.selectedOptions.contains(option)
                                ) {
                                    HapticManager.shared.light()
                                    if filterState.collectionsFilter.selectedOptions.contains(option) {
                                        filterState.collectionsFilter.selectedOptions.remove(option)
                                    } else {
                                        filterState.collectionsFilter.selectedOptions.insert(option)
                                    }
                                }
                            }
                        }
                        .padding(.bottom, 20)
                    }
                }
                
                // My Lists sort options
                if showingMyListsSortOptions {
                    UberEatsBottomSheetOverlay(
                        isPresented: $showingMyListsSortOptions,
                        title: "Sort by"
                    ) {
                        VStack(spacing: 0) {
                            ForEach(HomeTabView.MyListsSortOrder.allCases, id: \.self) { option in
                                FilterOptionItem(
                                    title: option.rawValue,
                                    isSelected: myListsSortOrder == option,
                                    action: {
                                        HapticManager.shared.selection()
                                        myListsSortOrder = option
                                        withAnimation(.easeInOut(duration: 0.2)) {
                                            showingMyListsSortOptions = false
                                        }
                                    }
                                )
                            }
                        }
                        .padding(.bottom, 32)
                    }
                }
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
                showingListView = false
                selectedCollection = nil
            })
                .environmentObject(store)
        }
        .sheet(isPresented: $showingProfile) {
            ProfileTabView()
                .environmentObject(store)
        }
    }
}

// MARK: - My Lists Filter Bar

struct MyListsFilterBar: View {
    @Binding var showingByMeDropdown: Bool
    @Binding var showingByOthersDropdown: Bool
    @Binding var collectionFilter: CollectionFilterType
    @EnvironmentObject var filterState: FilterState
    
    var body: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 12) {
                // By Me filter
                FilterPill(
                    text: "By Me",
                    isSelected: collectionFilter == .byMe,
                    hasDropdown: false
                ) {
                    HapticManager.shared.light()
                    collectionFilter = .byMe
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
            }
            .padding(.leading, 16)
        }
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
                withAnimation(.easeInOut(duration: 0.2)) {
                    showingSortOptions = true
                }
            }) {
                HStack(spacing: 6) {
                    Image(systemName: sortOrder.icon)
                        .font(.system(size: 14, weight: .medium))
                    
                    Text(sortOrder.rawValue)
                        .font(.system(size: 14, weight: .medium))
                    
                    Image(systemName: "chevron.down")
                        .font(.system(size: 10, weight: .semibold))
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
                    .font(.system(size: 16, weight: .medium))
                    .foregroundColor(.primary)
                    .frame(width: 32, height: 32)
            }
        }
    }
}

// MARK: - Spotify Style Header

struct SpotifyStyleHeader: View {
    @Binding var showingSearch: Bool
    @Binding var showingAddMenu: Bool
    @Binding var showingProfile: Bool
    
    var body: some View {
        HStack(spacing: 16) {
            // ReelEats title only
            Text("ReelEats")
                .font(.poppinsLogoTemp(size: 22))
                .foregroundColor(.primary)
            
            Spacer()
            
            // Search and Add buttons
            HStack(spacing: 20) {
                Button(action: {
                    HapticManager.shared.light()
                    showingSearch = true
                }) {
                    Image(systemName: "magnifyingglass")
                        .font(.system(size: 20, weight: .medium))
                        .foregroundColor(.primary)
                }
                
                Button(action: {
                    HapticManager.shared.light()
                    showingProfile = true
                }) {
                    Circle()
                        .fill(Color.orange.opacity(0.2))
                        .frame(width: 32, height: 32)
                        .overlay(
                            Image(systemName: "person.fill")
                                .font(.system(size: 16))
                                .foregroundColor(.orange)
                        )
                }
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
                            .font(.system(size: 16, weight: .semibold))
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
                        .font(.system(size: 14, weight: .medium))
                        .foregroundColor(.primary)
                    
                    Text(sortOrder.rawValue)
                        .font(.system(size: 16, weight: .medium))
                        .foregroundColor(.primary)
                    
                    Image(systemName: "chevron.down")
                        .font(.system(size: 12, weight: .medium))
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
                                    .font(.system(size: 14, weight: .medium))
                                    .foregroundColor(sortOrder == option ? .white : .primary)
                                    .frame(width: 16)
                                
                                Text(option.rawValue)
                                    .font(.system(size: 15, weight: .medium))
                                    .foregroundColor(sortOrder == option ? .white : .primary)
                                
                                Spacer()
                                
                                if sortOrder == option {
                                    Image(systemName: "checkmark")
                                        .font(.system(size: 12, weight: .semibold))
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
    @Binding var showingGridView: Bool
    @Binding var showingSortOptions: Bool
    
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
                        .font(.system(size: 14, weight: .medium))
                        .foregroundColor(.primary)
                    
                    Text(sortOrder.shortName)
                        .font(.system(size: 14, weight: .medium))
                        .foregroundColor(.primary)
                }
                .padding(.horizontal, 8)
                .padding(.vertical, 6)
            }
            .buttonStyle(PlainButtonStyle())
            
            Spacer()
            
            // Grid/List toggle (show opposite of current state)
            Button(action: {
                HapticManager.shared.light()
                withAnimation(.easeInOut(duration: 0.2)) {
                    showingGridView.toggle()
                }
            }) {
                Image(systemName: showingGridView ? "list.bullet" : "square.grid.2x2")
                    .font(.system(size: 18, weight: .medium))
                    .foregroundColor(.primary)
                    .frame(width: 32, height: 32)
            }
            .buttonStyle(PlainButtonStyle())
        }
        
    }
}

// MARK: - UberEats-style Bottom Sheet Overlay (doesn't move content)

struct UberEatsBottomSheetOverlay<Content: View>: View {
    @Binding var isPresented: Bool
    let title: String
    let content: () -> Content
    
    var body: some View {
        ZStack {
            if isPresented {
                // Background overlay - darkens the screen
                Color.black.opacity(0.3)
                    .ignoresSafeArea()
                    .onTapGesture {
                        withAnimation(.spring(response: 0.4, dampingFraction: 0.8)) {
                            isPresented = false
                        }
                    }
                
                // Bottom sheet with padding for bottom nav bar
                VStack {
                    Spacer()
                    
                    VStack(spacing: 0) {
                        // Handle bar
                        RoundedRectangle(cornerRadius: 2.5)
                            .fill(Color(.systemGray3))
                            .frame(width: 40, height: 4)
                            .padding(.top, 8)
                            .padding(.bottom, 12)
                        
                        // Title
                        HStack {
                            Text(title)
                                .font(.system(size: 18, weight: .semibold))
                                .foregroundColor(.primary)
                            
                            Spacer()
                            
                            Button(action: {
                                withAnimation(.easeInOut(duration: 0.3)) {
                                    isPresented = false
                                }
                            }) {
                                Image(systemName: "xmark")
                                    .font(.system(size: 16, weight: .medium))
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
                    .cornerRadius(16, corners: [.topLeft, .topRight])
                    .shadow(color: .black.opacity(0.15), radius: 12, x: 0, y: -4)
                    .transition(.move(edge: .bottom).combined(with: .opacity))
                    .padding(.bottom, 85) // Position just above bottom nav bar
                }
            }
        }
        .animation(.spring(response: 0.4, dampingFraction: 0.8), value: isPresented)
    }
}

extension HomeTabView.SortOrder {
    var shortName: String {
        switch self {
        case .recentlyAdded: return "Recents"
        case .alphabetical: return "A-Z"
        case .rating: return "Rating"
        case .distance: return "Distance"
        }
    }
}

// MARK: - My Lists Filter Bar


// MARK: - My Lists Sort and Grid Toggle


// MARK: - View Toggle (List/Map)

struct ViewToggle: View {
    @Binding var showingListView: Bool
    @Binding var sortOrder: HomeTabView.SortOrder
    @State private var showingSortMenu = false
    
    var body: some View {
        HStack(spacing: 16) {
            // List/Map toggle buttons
            HStack(spacing: 8) {
                Button(action: {
                    HapticManager.shared.light()
                    showingListView = true
                }) {
                    Image(systemName: showingListView ? "list.bullet" : "list.bullet")
                        .font(.system(size: 16, weight: .medium))
                        .foregroundColor(showingListView ? .primary : .secondary)
                        .frame(width: 24, height: 24)
                }
                
                Button(action: {
                    HapticManager.shared.light()
                    showingListView = false
                }) {
                    Image(systemName: !showingListView ? "map.fill" : "map")
                        .font(.system(size: 16, weight: .medium))
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
                            .font(.system(size: 14))
                        Text("Recents")
                            .font(.system(size: 14, weight: .medium))
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
        case .alphabetical:
            return restaurants.sorted { $0.name < $1.name }
        case .rating:
            return restaurants.sorted { $0.rating > $1.rating }
        case .distance:
            return restaurants.sorted { ($0.latitude + $0.longitude) < ($1.latitude + $1.longitude) } // Simple distance approximation
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
    var isGridView: Bool = false
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
        case .alphabetical:
            return restaurants.sorted { $0.name < $1.name }
        case .rating:
            return restaurants.sorted { $0.rating > $1.rating }
        case .distance:
            return restaurants.sorted { ($0.latitude + $0.longitude) < ($1.latitude + $1.longitude) } // Simple distance approximation
        }
    }
    
    var body: some View {
        if isGridView {
            // Grid view - 3 cards per row, Spotify-style
            LazyVGrid(
                columns: Array(repeating: GridItem(.flexible(), spacing: 8), count: 3), 
                spacing: 16
            ) {
                ForEach(sortedRestaurants) { restaurant in
                    RestaurantGridCard(restaurant: restaurant)
                        .environmentObject(store)
                        .onTapGesture {
                            HapticManager.shared.medium()
                            onRestaurantSelect(restaurant)
                        }
                }
            }
            .padding(.horizontal, 16)
        } else {
            // List view
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
}

// MARK: - Restaurant Grid Card (Spotify-style square card)

struct RestaurantGridCard: View {
    let restaurant: Restaurant
    @EnvironmentObject var store: RestaurantStore
    
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
                            .font(.system(size: 20))
                            .foregroundColor(restaurant.category.color)
                    )
            }
            .aspectRatio(1.0, contentMode: .fit) // Square image
            .clipShape(RoundedRectangle(cornerRadius: 8))
            
            // Content section with fixed height
            VStack(alignment: .leading, spacing: 4) {
                Text(restaurant.name)
                    .font(.system(size: 13, weight: .semibold))
                    .foregroundColor(.primary)
                    .lineLimit(2)
                    .multilineTextAlignment(.leading)
                    .fixedSize(horizontal: false, vertical: true)
                
                HStack(spacing: 3) {
                    Image(systemName: "star.fill")
                        .font(.system(size: 9))
                        .foregroundColor(.yellow)
                    
                    Text(String(format: "%.1f", restaurant.rating))
                        .font(.system(size: 11))
                        .foregroundColor(.secondary)
                    
                    Spacer()
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
    var collectionFilter: CollectionFilterType = .byMe
    @EnvironmentObject var store: RestaurantStore
    
    private var filteredCollections: [Collection] {
        switch collectionFilter {
        case .byMe:
            return store.collections
        case .byOthers:
            return [] // No "by others" collections in demo
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
                                    .font(.system(size: 16))
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
                    .font(.system(size: 18, weight: .semibold))
                    .foregroundColor(.primary)
                
                Text("\(restaurantsInCollection.count) spots")
                    .font(.system(size: 14))
                    .foregroundColor(.secondary)
            }
            
            Spacer()
            
            // Arrow
            Image(systemName: "chevron.right")
                .font(.system(size: 14))
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
                    .font(.system(size: 18, weight: .medium))
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
    case byMe = "By me"
    case byOthers = "By others"
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
    @State private var isGridView = false
    @State private var showingRestaurantDetail = false
    @State private var collectionFilter: CollectionFilterType = .byMe
    @State private var isCollectionsGridView = true // Default to grid for collections
    
    private var headerView: some View {
        VStack(spacing: 0) {
            HStack {
                // ReelEats logo with mascot
                HStack(spacing: 8) {
                    MascotView(size: 28)
                    
                    Text("ReelEats")
                        .font(.poppinsLogoTemp(size: 22))
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
                                    .font(.system(size: 16, weight: .medium))
                                    .foregroundColor(sortOption == option ? .black : .secondary)
                                    .frame(width: 20)
                                
                                Text(option.rawValue)
                                    .font(.poppinsBodyTemp(size: 16))
                                    .foregroundColor(sortOption == option ? .black : .primary)
                                
                                Spacer()
                                
                                if sortOption == option {
                                    Image(systemName: "checkmark")
                                        .font(.system(size: 14, weight: .medium))
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
                        if isGridView {
                            Text("Grid view coming soon...")
                                .foregroundColor(.secondary)
                                .padding()
                        } else {
                            RestaurantListView(
                                restaurants: sortedFilteredRestaurants,
                                onRestaurantTap: { restaurant in
                                    selectedRestaurant = restaurant
                                    showingRestaurantDetail = true
                                }
                            )
                            .transition(.opacity)
                        }
                    }
                } else {
                    if isCollectionsGridView {
                        CollectionsGridView(
                            collections: filteredCollections,
                            onCollectionTap: { collection in
                                selectedCollection = collection
                            }
                        )
                        .transition(.opacity)
                    } else {
                        // List view for collections
                        ScrollView {
                            LazyVStack(spacing: 12) {
                                ForEach(store.collections) { collection in
                                    CollectionListCard(collection: collection) {
                                        selectedCollection = collection
                                    }
                                }
                            }
                            .padding(.horizontal, 20)
                            .padding(.top, 20)
                            .padding(.bottom, 100)
                        }
                    }
                }
            }
        }
        .navigationBarHidden(true)
        .edgesIgnoringSafeArea(.top)
        .fullScreenCover(item: $selectedCollection) { collection in
            CollectionDetailView(collection: collection, onRestaurantSelect: onRestaurantSelect)
                .environmentObject(store)
        }
        .sheet(isPresented: $showingProfile) {
            ProfileTabView()
                .environmentObject(store)
        }
        .sheet(isPresented: $showingRestaurantDetail) {
            if let restaurant = selectedRestaurant {
                FullScreenRestaurantDetailView(restaurant: restaurant)
                    .environmentObject(store)
            }
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
    
    private var filteredCollections: [Collection] {
        // For now, all collections are "by me" since there's no user distinction
        // In a real app, you'd filter based on creator
        switch collectionFilter {
        case .byMe:
            return store.collections
        case .byOthers:
            return [] // No "by others" collections in demo
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
                        RoundedRectangle(cornerRadius: 2.5)
                            .fill(Color(.systemGray4))
                            .frame(width: 36, height: 4)
                            .padding(.top, 12)
                            .padding(.bottom, 16)
                        
                        // Title
                        HStack {
                            Text(title)
                                .font(.system(size: 20, weight: .semibold))
                                .foregroundColor(.primary)
                            
                            Spacer()
                            
                            Button(action: {
                                withAnimation(.easeInOut(duration: 0.3)) {
                                    isPresented = false
                                }
                            }) {
                                Image(systemName: "xmark")
                                    .font(.system(size: 16, weight: .medium))
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
                    .font(.system(size: 16, weight: .medium))
                    .foregroundColor(.primary)
                
                Spacer()
                
                if isSelected {
                    Image(systemName: "checkmark")
                        .font(.system(size: 16, weight: .semibold))
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
    let onSelection: (String) -> Void
    
    // Cuisine to emoji mapping
    private func emojiForCuisine(_ cuisine: String) -> String {
        switch cuisine.lowercased() {
        case "italian":
            return "🍝"
        case "japanese":
            return "🍣"
        case "chinese":
            return "🥡"
        case "mexican":
            return "🌮"
        case "american":
            return "🍔"
        case "french":
            return "🥖"
        case "indian":
            return "🍛"
        case "thai":
            return "🍜"
        case "korean":
            return "🍲"
        case "vietnamese":
            return "🥢"
        case "mediterranean":
            return "🫒"
        case "greek":
            return "🧆"
        case "turkish":
            return "🥙"
        case "spanish":
            return "🥘"
        case "british":
            return "🫖"
        case "german":
            return "🥨"
        case "lebanese":
            return "🧄"
        case "moroccan":
            return "🌶️"
        case "ethiopian":
            return "🌶️"
        case "brazilian":
            return "🥥"
        case "pizza":
            return "🍕"
        case "burgers":
            return "🍔"
        case "seafood":
            return "🦐"
        case "steakhouse":
            return "🥩"
        case "vegetarian":
            return "🥗"
        case "vegan":
            return "🌱"
        case "desserts":
            return "🍰"
        case "coffee":
            return "☕"
        case "bakery":
            return "🥐"
        default:
            return "🍽️"
        }
    }
    
    var body: some View {
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
            .padding(.bottom, 20)
        }
        .frame(maxHeight: 400)
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
            VStack(spacing: 8) {
                Text(emoji)
                    .font(.system(size: 32))
                
                Text(title)
                    .font(.system(size: 14, weight: .medium))
                    .foregroundColor(isSelected ? .white : .primary)
                    .multilineTextAlignment(.center)
                    .lineLimit(2)
            }
            .frame(maxWidth: .infinity, minHeight: 80)
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
                        .font(.system(size: 16))
                    
                    if isSelected {
                        Image(systemName: category.icon)
                            .font(.system(size: 12, weight: .semibold))
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
    @State private var tempRating: Double = 0.0
    
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
                            .font(.system(size: 32))
                    )
                }
                .frame(height: 140)
                .clipped()
                .overlay(
                    // Visit status badge
                    VStack {
                        HStack {
                            Spacer()
                            
                            Button(action: {
                                HapticManager.shared.light()
                                toggleVisitStatus()
                            }) {
                                Image(systemName: userVisitStatus.icon)
                                    .font(.system(size: 16, weight: .medium))
                                    .foregroundColor(.white)
                                    .frame(width: 32, height: 32)
                                    .background(
                                        Circle()
                                            .fill(userVisitStatus == .visited ? .green : .gray.opacity(0.8))
                                    )
                                    .shadow(color: .black.opacity(0.2), radius: 4, x: 0, y: 2)
                            }
                        }
                        .padding(.trailing, 12)
                        .padding(.top, 12)
                        
                        Spacer()
                        
                        // 5 star rating system - bottom right, smaller
                        HStack {
                            Spacer()
                            
                            HStack(spacing: 1) {
                                ForEach(1...5, id: \.self) { star in
                                    Button(action: {
                                        HapticManager.shared.light()
                                        tempRating = userRating
                                        showingRatingSlider = true
                                    }) {
                                        Image(systemName: star <= Int(userRating) ? "star.fill" : "star")
                                            .font(.system(size: 10))
                                            .foregroundColor(star <= Int(userRating) ? .black : .gray.opacity(0.3))
                                    }
                                }
                            }
                        }
                        .padding(.trailing, 12)
                        .padding(.bottom, 12)
                    }
                )
                
                // Restaurant info
                VStack(alignment: .leading, spacing: 6) {
                    Text(restaurant.name)
                        .font(.poppinsRestaurantNameTemp(size: 17))
                        .foregroundColor(.primary)
                        .lineLimit(2)
                    
                    Text(locationDisplay)
                        .font(.poppinsSecondaryTemp(size: 13))
                        .foregroundColor(.secondary)
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
    @State private var isGridView = true
    
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
            .padding(.bottom, 100)
        } else {
            if isGridView {
                // Grid view - same as Collections tab
                LazyVGrid(columns: Array(repeating: GridItem(.flexible(), spacing: 16), count: 2), spacing: 16) {
                    ForEach(collectionSpots) { restaurant in
                        CollectionRestaurantCard(
                            restaurant: restaurant,
                            onTap: {
                                selectedRestaurant = restaurant
                                showingRestaurantDetail = true
                            }
                        )
                        .environmentObject(store)
                    }
                }
                .padding(.horizontal, 20)
                .padding(.top, 12)
                .padding(.bottom, 100)
            } else {
                // List view - removed numbering
                VStack(spacing: 0) {
                    ForEach(collectionSpots) { restaurant in
                        HStack(spacing: 12) {
                            // Restaurant image (no numbering)
                            LinearGradient(
                                colors: [restaurant.category.color.opacity(0.2), restaurant.category.color.opacity(0.05)],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                            .overlay(
                                Text(restaurant.emoji)
                                    .font(.system(size: 24))
                            )
                            .frame(width: 56, height: 56)
                            .cornerRadius(4)
                            
                            // Restaurant info
                            VStack(alignment: .leading, spacing: 4) {
                                Text(restaurant.name)
                                    .font(.poppinsRestaurantNameTemp(size: 16))
                                    .foregroundColor(.primary)
                                    .lineLimit(1)
                                
                                Text(restaurant.description)
                                    .font(.system(size: 14, weight: .bold, design: .default))
                                    .italic()
                                    .foregroundColor(.secondary)
                                    .lineLimit(1)
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
                            showingRestaurantDetail = true
                        }
                    }
                }
                .padding(.top, 12)
                .padding(.bottom, 100)
            }
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
                    
                    // Filter pills and controls (same as Collections tab)
                    VStack(spacing: 16) {
                        // Filter pills
                        HStack(spacing: 12) {
                            ForEach(CollectionFilterType.allCases, id: \.self) { filter in
                                Button(action: {
                                    selectedFilter = filter
                                }) {
                                    Text(filter.rawValue)
                                        .font(.system(size: 14, weight: selectedFilter == filter ? .semibold : .medium))
                                        .foregroundColor(selectedFilter == filter ? .primary : .secondary)
                                        .padding(.horizontal, 16)
                                        .padding(.vertical, 8)
                                        .background(
                                            RoundedRectangle(cornerRadius: 20)
                                                .fill(selectedFilter == filter ? Color(.systemGray5) : Color.clear)
                                        )
                                }
                            }
                            
                            Spacer()
                        }
                        .padding(.horizontal, 20)
                        
                        // Sorting and view toggle
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
                                        .font(.system(size: 14))
                                    Text(selectedSort.displayName)
                                        .font(.system(size: 14, weight: .medium))
                                }
                                .foregroundColor(.primary)
                            }
                            
                            Spacer()
                            
                            // Grid/List toggle
                            Button(action: {
                                isGridView.toggle()
                            }) {
                                Image(systemName: isGridView ? "list.bullet" : "square.grid.2x2")
                                    .font(.system(size: 18))
                                    .foregroundColor(.primary)
                            }
                        }
                        .padding(.horizontal, 20)
                    }
                    .padding(.top, 8)
                    
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
            RoundedRectangle(cornerRadius: 2.5)
                .fill(Color(.systemGray4))
                .frame(width: 40, height: 4)
                .padding(.top, 12)
                .padding(.bottom, 20)
            
            // Restaurant header
            HStack(spacing: 12) {
                LinearGradient(
                    colors: [restaurant.category.color.opacity(0.2), restaurant.category.color.opacity(0.05)],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
                .overlay(
                    Text(restaurant.emoji)
                        .font(.system(size: 22))
                )
                .frame(width: 50, height: 50)
                .clipShape(RoundedRectangle(cornerRadius: 8))
                
                VStack(alignment: .leading, spacing: 4) {
                    Text(restaurant.name)
                        .font(.poppinsRestaurantNameTemp(size: 16))
                        .foregroundColor(.primary)
                        .lineLimit(1)
                    
                    Text(restaurant.description)
                        .font(.system(size: 14, weight: .bold, design: .default))
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
        VStack(alignment: .leading, spacing: 12) {
            // Emoji display with enhanced styling
            LinearGradient(
                colors: [restaurant.category.color.opacity(0.2), restaurant.category.color.opacity(0.05)],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .overlay(
                Text(restaurant.emoji)
                    .font(.system(size: 80))
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
                            .font(.system(size: 13, weight: .medium))
                            .foregroundColor(.orange)
                        
                        Text(String(format: "%.1f", restaurant.rating))
                            .font(.poppinsSecondaryTemp(size: 14))
                            .foregroundColor(.primary)
                            .fontWeight(.medium)
                    }
                    
                    Text("•")
                        .font(.system(size: 12))
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

// MARK: - My Lists Filter Bar


// MARK: - My Lists Sort and Grid Toggle


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
                    .font(.system(size: 32))
            )
            .onAppear {
                withAnimation(.easeInOut(duration: 0.3)) {
                    imageLoaded = true
                }
            }
            .frame(width: 60, height: 60) // Reduced from 80x80 to 60x60
            .clipShape(RoundedRectangle(cornerRadius: 12))
            
            // Restaurant info - more space for text
            VStack(alignment: .leading, spacing: 4) {
                // Restaurant name with three dots on same line
                HStack {
                    Text(restaurantDisplayName)
                        .font(.system(size: 16, weight: .semibold))
                        .foregroundColor(.primary)
                        .lineLimit(1)
                    
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
                
                // Description only
                Text(restaurant.description)
                    .font(.system(size: 14, weight: .bold, design: .default))
                    .italic()
                    .foregroundColor(.secondary)
                    .lineLimit(1)
                
                // Location
                Text(locationDisplay)
                    .font(.system(size: 13))
                    .foregroundColor(.secondary)
                    .lineLimit(1)
                
                // 5 star rating system - below location, smaller and on right
                HStack {
                    Spacer()
                    
                    HStack(spacing: 1) {
                        ForEach(1...5, id: \.self) { star in
                            Button(action: {
                                HapticManager.shared.light()
                                showingRatingSlider = true
                            }) {
                                Image(systemName: star <= Int(userRating) ? "star.fill" : "star")
                                    .font(.system(size: 10))
                                    .foregroundColor(star <= Int(userRating) ? .black : .gray.opacity(0.3))
                            }
                        }
                    }
                }
                .padding(.top, 2)
            }
            
            Spacer()
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
                    .font(.system(size: 60))
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
                                .font(.system(size: 12, weight: .semibold))
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
                                .font(.system(size: 16, weight: .medium))
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
                                        .font(.system(size: 12))
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
                        .font(.system(size: 13, weight: .medium))
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
            RoundedRectangle(cornerRadius: 2.5)
                .fill(Color(.systemGray4))
                .frame(width: 40, height: 4)
                .padding(.top, 8)
            
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
                                    .font(.system(size: 32))
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
                .font(.system(size: size))
                .foregroundColor(.gray.opacity(0.3))
            
            Image(systemName: "star.fill")
                .font(.system(size: size))
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
                            .font(.system(size: 28))
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
                                .font(.system(size: 80))
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
                                        .font(.system(size: 14))
                                        .foregroundColor(.secondary)
                                    
                                    Text(restaurant.address)
                                        .font(.system(size: 16))
                                        .foregroundColor(.secondary)
                                }
                                
                                Text("•")
                                    .foregroundColor(.secondary)
                                
                                Text(isOpen ? "Open" : "Closed")
                                    .font(.system(size: 16, weight: .medium))
                                    .foregroundColor(isOpen ? .green : .red)
                            }
                            
                            // Description
                            Text(restaurant.description)
                                .font(.system(size: 18))
                                .foregroundColor(.secondary)
                                .multilineTextAlignment(.center)
                                .padding(.horizontal, 20)
                        }
                        
                        // User rating section
                        if userRating > 0 {
                            VStack(spacing: 12) {
                                HStack(spacing: 2) {
                                    ForEach(1...5, id: \.self) { star in
                                        Image(systemName: star <= Int(userRating) ? "star.fill" : "star")
                                            .font(.system(size: 24))
                                            .foregroundColor(star <= Int(userRating) ? .yellow : .gray.opacity(0.3))
                                    }
                                }
                                .onTapGesture {
                                    HapticManager.shared.light()
                                    showingRatingSlider = true
                                }
                                
                                if !userNotes.isEmpty {
                                    Text(userNotes)
                                        .font(.system(size: 16))
                                        .foregroundColor(.secondary)
                                        .italic()
                                        .padding(.horizontal, 40)
                                        .multilineTextAlignment(.center)
                                }
                            }
                            .padding(.vertical, 20)
                            .frame(maxWidth: .infinity)
                            .background(Color(.systemGray6))
                            .cornerRadius(16)
                            .padding(.horizontal, 20)
                        } else {
                            Button(action: {
                                HapticManager.shared.light()
                                showingRatingSlider = true
                            }) {
                                VStack(spacing: 8) {
                                    HStack(spacing: 2) {
                                        ForEach(1...5, id: \.self) { _ in
                                            Image(systemName: "star")
                                                .font(.system(size: 20))
                                                .foregroundColor(.gray.opacity(0.3))
                                        }
                                    }
                                    
                                    Text("Rate this place")
                                        .font(.system(size: 16, weight: .medium))
                                        .foregroundColor(.primary)
                                }
                                .padding(.vertical, 20)
                                .frame(maxWidth: .infinity)
                                .background(Color(.systemGray6))
                                .cornerRadius(16)
                            }
                            .padding(.horizontal, 20)
                        }
                        
                        // Source info
                        if restaurant.source != .web {
                            HStack {
                                Image(systemName: restaurant.source.icon)
                                    .font(.system(size: 16))
                                    .foregroundColor(.secondary)
                                
                                Text("Imported from \(restaurant.source.displayName)")
                                    .font(.system(size: 14))
                                    .foregroundColor(.secondary)
                            }
                            .padding(.horizontal, 16)
                            .padding(.vertical, 8)
                            .background(Color(.systemGray6))
                            .cornerRadius(20)
                        }
                        
                        Spacer(minLength: 100) // Space for bottom bar
                    }
                    .padding(.top, 20)
                }
                
                // Fixed bottom action bar
                VStack(spacing: 0) {
                    Divider()
                    
                    HStack(spacing: 16) {
                        ActionButton(icon: "square.and.arrow.up", title: "Share") {
                            HapticManager.shared.light()
                            // TODO: Implement share
                        }
                        
                        ActionButton(icon: "location.arrow.fill", title: "Directions") {
                            HapticManager.shared.light()
                            // TODO: Open in maps
                        }
                        
                        ActionButton(icon: "calendar.badge.plus", title: "Reserve") {
                            HapticManager.shared.light()
                            // TODO: Make reservation
                        }
                        
                        ActionButton(icon: "globe", title: "Site") {
                            HapticManager.shared.light()
                            // TODO: Open website
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

// MARK: - My Lists Filter Bar


// MARK: - My Lists Sort and Grid Toggle


// MARK: - Map View (Matching Screenshot)

struct MapTabView: View {
    @Binding var selectedRestaurant: Restaurant?
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
    @State private var showingLocationInfo = false
    
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
                            .font(.poppinsCollectionNameTemp(size: 24))
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
            
            // Location Info Panel for selected restaurant
            if showingLocationInfo, let restaurant = selectedRestaurant {
                LocationInfoPanel(
                    restaurant: restaurant,
                    onClose: {
                        withAnimation(.spring(response: 0.6, dampingFraction: 0.8)) {
                            showingLocationInfo = false
                            selectedRestaurant = nil
                        }
                    }
                )
                .environmentObject(store)
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
                    FilterBar(
                        showingCuisineDropdown: .constant(false),
                        showingDistanceDropdown: .constant(false),
                        showingPriceDropdown: .constant(false),
                        showingCollectionsDropdown: .constant(false)
                    )
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
                                            .font(.poppinsRestaurantNameTemp(size: 16))
                                        
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
        .onChange(of: selectedRestaurant) { _, newRestaurant in
            if let restaurant = newRestaurant {
                // Zoom to selected restaurant location
                withAnimation(.easeInOut(duration: 1.0)) {
                    region = MKCoordinateRegion(
                        center: CLLocationCoordinate2D(
                            latitude: restaurant.latitude,
                            longitude: restaurant.longitude
                        ),
                        span: MKCoordinateSpan(latitudeDelta: 0.01, longitudeDelta: 0.01)
                    )
                }
                
                // Show location info panel
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                    withAnimation(.spring(response: 0.6, dampingFraction: 0.8)) {
                        showingLocationInfo = true
                    }
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
                    RoundedRectangle(cornerRadius: 2.5)
                        .fill(Color(.systemGray4))
                        .frame(width: 40, height: 4)
                        .padding(.top, 8)
                        .padding(.bottom, 16)
                    
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
                                        .font(.system(size: 14))
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
                                        .font(.system(size: 14, weight: .medium))
                                        .foregroundColor(.green)
                                }
                                
                                // Visit status and rating
                                HStack(spacing: 16) {
                                    HStack(spacing: 8) {
                                        Image(systemName: userVisitStatus.icon)
                                            .font(.system(size: 16))
                                            .foregroundColor(userVisitStatus == .visited ? .green : .orange)
                                        
                                        Text(userVisitStatus.rawValue)
                                            .font(.system(size: 14, weight: .medium))
                                            .foregroundColor(.secondary)
                                    }
                                    
                                    if userVisitStatus == .visited && userRating > 0 {
                                        HStack(spacing: 4) {
                                            ForEach(1...5, id: \.self) { star in
                                                Image(systemName: star <= Int(userRating) ? "star.fill" : "star")
                                                    .font(.system(size: 14))
                                                    .foregroundColor(star <= Int(userRating) ? .yellow : .gray.opacity(0.3))
                                            }
                                            Text("(\(Int(userRating))/5)")
                                                .font(.system(size: 12))
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
                icon: "location.fill",
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
                    .font(.system(size: 20, weight: .medium))
                    .foregroundColor(.primary)
                
                Text(title)
                    .font(.system(size: 12, weight: .medium))
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
                        .font(.system(size: 15))
                    
                    if isSelected {
                        Image(systemName: category.icon)
                            .font(.system(size: 11, weight: .semibold))
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
                        
                        // Center floating + button
                        Button(action: {
                            HapticManager.shared.light()
                            withAnimation(.spring(response: 0.4, dampingFraction: 0.8)) {
                                showingAddMenu.toggle()
                            }
                        }) {
                            Image(systemName: showingAddMenu ? "xmark" : "plus")
                                .font(.system(size: 20, weight: .bold))
                                .foregroundColor(.white)
                                .frame(width: 50, height: 50)
                                .background(Color.black)
                                .clipShape(Circle())
                                .shadow(color: .black.opacity(0.3), radius: 8, x: 0, y: 4)
                                .rotationEffect(.degrees(showingAddMenu ? 45 : 0))
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
    case desserts = "Desserts"
    case fastfood = "Fast Food"
    case finedining = "Fine Dining"
    
    var icon: String {
        switch self {
        case .all: return "list.bullet"
        case .restaurants: return "fork.knife"
        case .cafe: return "cup.and.saucer.fill"
        case .bars: return "wineglass.fill"
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
        case .desserts: return "🧁"
        case .fastfood: return "🍔"
        case .finedining: return "🥂"
        }
    }
    
    var color: Color {
        switch self {
        case .all: return Color(red: 0.5, green: 0.5, blue: 0.5)
        case .restaurants: return Color(red: 0.2, green: 0.6, blue: 1.0)
        case .cafe: return Color(red: 0.8, green: 0.5, blue: 0.2)
        case .bars: return Color(red: 0.7, green: 0.3, blue: 0.9)
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
    let restaurantIds: [UUID]
}

// MARK: - Melbourne Demo Data

struct Melbourne {
    static let demoRestaurants: [Restaurant] = [
        Restaurant(
            name: "Baker Bleu Opens Biggest Australian Bakery",
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
struct FilterBar: View {
    @EnvironmentObject var filterState: FilterState
    @Binding var showingCuisineDropdown: Bool
    @Binding var showingDistanceDropdown: Bool
    @Binding var showingPriceDropdown: Bool
    @Binding var showingCollectionsDropdown: Bool
    
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
                .padding(.leading, 16)  // Add left padding to align with other content
            }
        }
        .sheet(isPresented: $filterState.showingMoreFilters) {
            MoreFiltersSheet()
        }
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
    
    // Clean design without emojis
    
    private var gradientColors: [Color] {
        if isSelected {
            return [Color.black.opacity(0.9), Color.black]
        } else {
            return [Color.white, Color.white.opacity(0.95)]
        }
    }
    
    var body: some View {
        Button(action: {
            HapticManager.shared.light()
            action()
        }) {
            HStack(spacing: 8) {
                // Clean text without emojis
                Text(text)
                    .font(.poppinsAccentTemp(size: 14))
                    .foregroundColor(isSelected ? .white : .primary)
                
                if hasDropdown {
                    Image(systemName: "chevron.down")
                        .font(.system(size: 11, weight: .semibold))
                        .foregroundColor(isSelected ? .white.opacity(0.8) : .secondary)
                }
            }
            .padding(.horizontal, 14)
            .padding(.vertical, 8)
            .background(
                LinearGradient(
                    colors: gradientColors,
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
            )
            .clipShape(Capsule())
            .overlay(
                Capsule()
                    .stroke(
                        isSelected ? Color.clear : Color.black.opacity(0.06),
                        lineWidth: isSelected ? 0 : 1
                    )
            )
            .shadow(
                color: isSelected ? .black.opacity(0.25) : .black.opacity(0.04),
                radius: isSelected ? 8 : 2,
                x: 0,
                y: isSelected ? 3 : 1
            )
            .scaleEffect(isPressed ? 0.95 : 1.0)
        }
        .scaleEffect(isSelected ? 1.05 : 1.0)
        .animation(.spring(response: 0.3, dampingFraction: 0.7), value: isSelected)
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

// MARK: - My Lists Filter Bar


// MARK: - My Lists Sort and Grid Toggle


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

// MARK: - My Lists Filter Bar


// MARK: - My Lists Sort and Grid Toggle
