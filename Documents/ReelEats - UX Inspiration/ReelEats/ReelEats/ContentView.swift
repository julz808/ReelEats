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
    
    var body: some View {
        ZStack {
            // Main content
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
            
            // Custom bottom navigation with floating + button
            VStack {
                Spacer()
                
                CustomBottomNavBar(
                    selectedTab: $selectedTab,
                    showingAddMenu: $showingAddMenu,
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
        // Initialize with more demo data - using first 15 restaurants to ensure collections are well populated
        savedRestaurants = Array(Melbourne.demoRestaurants.prefix(15))
        
        // Create well-populated collections with multiple items each
        let dateNightRestaurants = Array(Melbourne.demoRestaurants.filter { 
            $0.name.contains("Nobu") || $0.name.contains("Attica") || $0.name.contains("Cumulus") || $0.priceRange == "$$$"
        }.prefix(5).map { $0.id })
        
        let roadTripRestaurants = Array(Melbourne.demoRestaurants.filter { 
            $0.name.contains("Baker Bleu") || $0.name.contains("Seven Seeds") || $0.name.contains("Proud Mary") || $0.category == .cafe
        }.prefix(6).map { $0.id })
        
        let barsRestaurants = Array(Melbourne.demoRestaurants.filter { 
            $0.category == .bars
        }.prefix(4).map { $0.id })
        
        let bestJapRestaurants = Array(Melbourne.demoRestaurants.filter { 
            $0.name.contains("Nobu") || $0.name.contains("Chin Chin") || $0.name.contains("Bar Americano")
        }.prefix(4).map { $0.id })
        
        // Add additional diverse collections
        let brunchFavsRestaurants = Array(Melbourne.demoRestaurants.filter {
            $0.name.contains("Industry Beans") || $0.name.contains("Patricia") || $0.name.contains("Seven Seeds") || $0.category == .cafe
        }.prefix(5).map { $0.id })
        
        let fineDiningRestaurants = Array(Melbourne.demoRestaurants.filter {
            $0.priceRange == "$$$" || $0.name.contains("Nobu") || $0.name.contains("Attica")
        }.prefix(4).map { $0.id })
        
        collections = [
            Collection(name: "date night", restaurantIds: dateNightRestaurants),
            Collection(name: "road trip", restaurantIds: roadTripRestaurants),
            Collection(name: "bars", restaurantIds: barsRestaurants),
            Collection(name: "best jap", restaurantIds: bestJapRestaurants),
            Collection(name: "brunch favs", restaurantIds: brunchFavsRestaurants),
            Collection(name: "fine dining", restaurantIds: fineDiningRestaurants)
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
        let newCollection = Collection(name: name, restaurantIds: [])
        collections.append(newCollection)
    }
    
    func addRestaurantToCollection(restaurant: Restaurant, collection: Collection) {
        // In a real app, this would update the collection's restaurantIds
        print("Added \(restaurant.name) to \(collection.name)")
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