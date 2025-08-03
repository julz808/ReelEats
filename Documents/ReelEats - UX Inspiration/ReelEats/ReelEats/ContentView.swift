import SwiftUI
import Foundation

struct ContentView: View {
    @StateObject private var restaurantStore = RestaurantStore()
    
    var body: some View {
        Group {
            if restaurantStore.isOnboarding {
                OnboardingCoordinator()
                    .environmentObject(restaurantStore)
            } else {
                MainTabView()
                    .environmentObject(restaurantStore)
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
    
    var body: some View {
        ZStack {
            // Main content
            Group {
                if selectedTab == 0 {
                    SavedTabView()
                        .environmentObject(store)
                } else {
                    MapTabView()
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
    
    init() {
        // Initialize with some demo data - using first 10 restaurants
        savedRestaurants = Array(Melbourne.demoRestaurants.prefix(10))
        
        // Create the 4 specific collections requested
        let dateNightRestaurants = Array(Melbourne.demoRestaurants.filter { 
            $0.name.contains("Nobu") || $0.name.contains("Attica") || $0.name.contains("Flower Drum")
        }.prefix(3).map { $0.id })
        
        let roadTripRestaurants = Array(Melbourne.demoRestaurants.filter { 
            $0.name.contains("Baker Bleu") || $0.name.contains("Seven Seeds") || $0.name.contains("Market Lane")
        }.prefix(3).map { $0.id })
        
        let barsRestaurants = Array(Melbourne.demoRestaurants.filter { 
            $0.category == .bars
        }.prefix(4).map { $0.id })
        
        let bestJapRestaurants = Array(Melbourne.demoRestaurants.filter { 
            $0.name.contains("Nobu") || $0.name.contains("Chin Chin") || $0.name.contains("Tipo")
        }.prefix(3).map { $0.id })
        
        collections = [
            Collection(name: "date night", restaurantIds: dateNightRestaurants),
            Collection(name: "road trip", restaurantIds: roadTripRestaurants),
            Collection(name: "bars", restaurantIds: barsRestaurants),
            Collection(name: "best jap", restaurantIds: bestJapRestaurants)
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
}

#Preview {
    ContentView()
}