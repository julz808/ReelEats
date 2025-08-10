import SwiftUI
import Foundation

struct ContentView: View {
    @StateObject private var restaurantStore = RestaurantStore()
    @StateObject private var filterState = FilterState()
    
    var body: some View {
        Group {
            if restaurantStore.isOnboarding {
                OnboardingCoordinator()
                    .environmentObject(restaurantStore)
                    .environmentObject(filterState)
            } else {
                MainTabView()
                    .environmentObject(restaurantStore)
                    .environmentObject(filterState)
            }
        }
        .preferredColorScheme(.light)
    }
}

// MARK: - Onboarding views moved to CompleteOnboarding.swift

struct MainTabView: View {
    @EnvironmentObject var store: RestaurantStore
    @State private var selectedTab = 0
    @State private var showingAddMenu = false
    @State private var showingProfile = false
    @State private var showingAddSpot = false
    @State private var showingCreateCollection = false
    @State private var showingScanCollection = false
    @State private var selectedRestaurantForMap: Restaurant?
    
    // New ReciMe-style sheet states
    @State private var showingRecimeSheet = false
    @State private var showingAddSpotsOptions = false
    @State private var showingCreatePersonalCollection = false
    @State private var showingCreateTogetherCollection = false
    
    // Sub-states for Add Spots options
    @State private var showingUploadPhoto = false
    @State private var showingPasteText = false
    
    // Collection sharing state
    @State private var showingCollectionSharing = false
    @State private var createdCollectionName = ""
    
    var body: some View {
        ZStack {
            // Main content with conditional darkening
            Group {
                if selectedTab == 0 {
                    // Home tab
                    HomeTabView(selectedRestaurant: $selectedRestaurantForMap)
                        .environmentObject(store)
                } else if selectedTab == 1 {
                    // Map tab
                    MapTabView(selectedRestaurant: $selectedRestaurantForMap)
                        .environmentObject(store)
                }
            }
            .overlay(
                // Darken main content when popout is showing, but don't cover nav bar area
                showingRecimeSheet ? 
                Color.black.opacity(0.3)
                    .ignoresSafeArea(.all, edges: [.top, .leading, .trailing])
                    .onTapGesture {
                        withAnimation(.easeInOut(duration: 0.3)) {
                            showingRecimeSheet = false
                        }
                    }
                : nil
            )
            
            // RecimeStyle popout - positioned to hover above nav bar
            if showingRecimeSheet {
                VStack {
                    Spacer()
                    
                    RecimeStyleActionSheet(
                        showingAddSpotsOptions: $showingAddSpotsOptions,
                        showingCreatePersonalCollection: $showingCreatePersonalCollection,
                        showingCreateTogetherCollection: $showingCreateTogetherCollection
                    )
                    .environmentObject(store)
                    .transition(.move(edge: .bottom))
                    .padding(.bottom, 42) // No gap between modal and nav bar
                }
            }
            
            // Window-level overlay that can cover the bottom nav bar
            WindowLevelBottomSheet()
            
            // Custom bottom navigation - ALWAYS on top and visible
            VStack {
                Spacer()
                
                CustomBottomNavBar(
                    selectedTab: $selectedTab,
                    showingAddMenu: $showingAddMenu,
                    showingRecimeSheet: $showingRecimeSheet,
                    onManualSearch: {
                        showingAddSpot = true
                    },
                    onCreateCollection: {
                        showingCreateCollection = true
                    },
                    onScanCollection: {
                        showingScanCollection = true
                    }
                )
            }
        }
        .sheet(isPresented: $showingProfile) {
            ProfileTabView()
                .environmentObject(store)
        }
        .sheet(isPresented: $showingAddSpot) {
            AddSpotView()
                .environmentObject(store)
        }
        .sheet(isPresented: $showingCreateCollection) {
            NewCollectionView()
                .environmentObject(store)
        }
        .sheet(isPresented: $showingScanCollection) {
            ScanCollectionView()
                .environmentObject(store)
        }
        .sheet(isPresented: $showingAddSpotsOptions) {
            AddSpotsOptionsView(
                showingUploadPhoto: $showingUploadPhoto,
                showingPasteText: $showingPasteText
            )
            .environmentObject(store)
        }
        .sheet(isPresented: $showingCreatePersonalCollection) {
            NewCollectionView(isTogetherCollection: false)
                .environmentObject(store)
        }
        .sheet(isPresented: $showingCreateTogetherCollection) {
            TogetherCollectionView(
                showingCollectionSharing: $showingCollectionSharing,
                createdCollectionName: $createdCollectionName
            )
            .environmentObject(store)
        }
        .sheet(isPresented: $showingUploadPhoto) {
            ImportFromGalleryView()
                .environmentObject(store)
        }
        .sheet(isPresented: $showingPasteText) {
            ImportFromTextView()
                .environmentObject(store)
        }
        .sheet(isPresented: $showingCollectionSharing) {
            CollectionSharingSheet(collectionName: createdCollectionName)
        }
        .animation(.easeInOut(duration: 0.3), value: showingRecimeSheet)
        .onAppear {
            store.completeSetup()
        }
    }
}

// MARK: - Restaurant Store

class RestaurantStore: ObservableObject {
    @Published var isOnboarding: Bool = true
    @Published var savedRestaurants: [Restaurant] = []
    @Published var collections: [Collection] = []
    @Published var userInteractions: [RestaurantUserData] = []
    
    init() {
        // Initialize with more demo data - using first 25 restaurants but only adding some to collections
        savedRestaurants = Array(Melbourne.demoRestaurants.prefix(25))
        
        // Create well-populated collections with multiple items each
        let dateNightRestaurants = Array(Melbourne.demoRestaurants.filter { 
            $0.name.contains("Nobu") || $0.name.contains("Attica")
        }.prefix(2).map { $0.id })
        
        let roadTripRestaurants = Array(Melbourne.demoRestaurants.filter { 
            $0.name.contains("Baker Bleu") || $0.name.contains("Proud Mary")
        }.prefix(2).map { $0.id })
        
        let barsRestaurants = Array(Melbourne.demoRestaurants.filter { 
            $0.category == .bars
        }.prefix(2).map { $0.id })
        
        let bestJapRestaurants = Array(Melbourne.demoRestaurants.filter { 
            $0.name.contains("Nobu") || $0.name.contains("Chin Chin")
        }.prefix(2).map { $0.id })
        
        // Add additional diverse collections (smaller sizes)
        let brunchFavsRestaurants = Array(Melbourne.demoRestaurants.filter {
            $0.name.contains("Industry Beans") || $0.name.contains("Patricia")
        }.prefix(2).map { $0.id })
        
        let fineDiningRestaurants = Array(Melbourne.demoRestaurants.filter {
            $0.name.contains("Attica")
        }.prefix(1).map { $0.id })
        
        collections = [
            Collection(name: "date night", restaurantIds: dateNightRestaurants, creators: ["Julz", "Alex"], isCollaborative: true),
            Collection(name: "road trip", restaurantIds: roadTripRestaurants, creators: ["Julz", "Sam", "Maya"], isCollaborative: true),
            Collection(name: "bars", restaurantIds: barsRestaurants, creators: ["Julz"], isCollaborative: false),
            Collection(name: "best jap", restaurantIds: bestJapRestaurants, creators: ["Emma"], isCollaborative: false),
            Collection(name: "brunch favs", restaurantIds: brunchFavsRestaurants, creators: ["David", "Lisa"], isCollaborative: true),
            Collection(name: "fine dining", restaurantIds: fineDiningRestaurants, creators: ["Julz"], isCollaborative: false)
        ]
    }
    
    func completeSetup() {
        isOnboarding = false
    }
    
    func saveRestaurant(_ restaurant: Restaurant) {
        if !savedRestaurants.contains(where: { $0.id == restaurant.id }) {
            savedRestaurants.append(restaurant)
        }
    }
    
    func removeRestaurant(_ restaurant: Restaurant) {
        savedRestaurants.removeAll { $0.id == restaurant.id }
    }
    
    func createCollection(name: String) {
        let newCollection = Collection(name: name, restaurantIds: [], creators: ["Julz"], isCollaborative: false)
        collections.append(newCollection)
    }
    
    func addRestaurantToCollection(restaurant: Restaurant, collection: Collection) {
        if let index = collections.firstIndex(where: { $0.id == collection.id }) {
            if !collections[index].restaurantIds.contains(restaurant.id) {
                collections[index].restaurantIds.append(restaurant.id)
            }
        }
    }
    
    // MARK: - User Data Management
    
    func getUserData(for restaurantId: UUID) -> RestaurantUserData? {
        return userInteractions.first { $0.restaurantId == restaurantId }
    }
    
    func updateVisitStatus(for restaurantId: UUID, status: VisitStatus) {
        if let index = userInteractions.firstIndex(where: { $0.restaurantId == restaurantId }) {
            userInteractions[index].visitStatus = status
            if status == .visited {
                userInteractions[index].dateVisited = Date()
            } else {
                userInteractions[index].dateVisited = nil
                userInteractions[index].userRating = 0.0
            }
        } else {
            let newUserData = RestaurantUserData(
                restaurantId: restaurantId,
                visitStatus: status,
                userRating: 0.0,
                dateVisited: status == .visited ? Date() : nil
            )
            userInteractions.append(newUserData)
        }
    }
    
    func updateUserRating(for restaurantId: UUID, rating: Double) {
        if let index = userInteractions.firstIndex(where: { $0.restaurantId == restaurantId }) {
            userInteractions[index].userRating = rating
        } else {
            let newUserData = RestaurantUserData(
                restaurantId: restaurantId,
                visitStatus: .visited,
                userRating: rating,
                dateVisited: Date()
            )
            userInteractions.append(newUserData)
        }
    }
}

#Preview {
    ContentView()
}