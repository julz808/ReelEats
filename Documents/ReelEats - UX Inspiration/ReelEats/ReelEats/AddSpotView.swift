import SwiftUI
import MapKit

// MARK: - Add Spot Search View

struct AddSpotView: View {
    @Environment(\.dismiss) private var dismiss
    @EnvironmentObject var store: RestaurantStore
    @State private var searchText = ""
    @State private var searchResults: [MockLocationResult] = []
    @State private var isSearching = false
    @State private var showingDetailSheet = false
    @State private var selectedLocation: MockLocationResult?
    
    var body: some View {
        NavigationView {
            VStack(spacing: 0) {
                // Search header
                VStack(spacing: 16) {
                    HStack {
                        Button("Cancel") {
                            dismiss()
                        }
                        .foregroundColor(.primary)
                        
                        Spacer()
                        
                        Text("Add Spot")
                            .font(.system(size: 18, weight: .semibold))
                        
                        Spacer()
                        
                        // Invisible spacer for symmetry
                        Text("Cancel")
                            .opacity(0)
                    }
                    .padding(.horizontal, 20)
                    .padding(.top, 10)
                    
                    // Search bar
                    HStack {
                        Image(systemName: "magnifyingglass")
                            .foregroundColor(.secondary)
                        
                        TextField("Search for restaurants, cafes, bars...", text: $searchText)
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
                    .padding(.horizontal, 16)
                    .padding(.vertical, 12)
                    .background(Color(.systemGray6))
                    .cornerRadius(12)
                    .padding(.horizontal, 20)
                }
                .padding(.bottom, 20)
                .background(Color(.systemBackground))
                
                if isSearching {
                    // Loading state
                    VStack(spacing: 20) {
                        Spacer()
                        
                        ProgressView()
                            .scaleEffect(1.2)
                        
                        Text("Searching nearby spots...")
                            .font(.system(size: 16))
                            .foregroundColor(.secondary)
                        
                        Spacer()
                    }
                } else if searchResults.isEmpty && !searchText.isEmpty {
                    // No results state
                    VStack(spacing: 20) {
                        Spacer()
                        
                        Image(systemName: "magnifyingglass")
                            .font(.system(size: 50))
                            .foregroundColor(.secondary.opacity(0.5))
                        
                        Text("No spots found")
                            .font(.system(size: 18, weight: .medium))
                            .foregroundColor(.primary)
                        
                        Text("Try searching for a different location or restaurant name")
                            .font(.system(size: 14))
                            .foregroundColor(.secondary)
                            .multilineTextAlignment(.center)
                            .padding(.horizontal, 40)
                        
                        Spacer()
                    }
                } else if searchResults.isEmpty {
                    // Initial state
                    VStack(spacing: 24) {
                        Spacer()
                        
                        VStack(spacing: 16) {
                            Image(systemName: "location.magnifyingglass")
                                .font(.system(size: 60))
                                .foregroundColor(.orange)
                            
                            Text("Find Your Next Spot")
                                .font(.system(size: 22, weight: .bold))
                                .foregroundColor(.primary)
                            
                            Text("Search for restaurants, cafes, bars and more using our AI-powered search")
                                .font(.system(size: 16))
                                .foregroundColor(.secondary)
                                .multilineTextAlignment(.center)
                                .padding(.horizontal, 40)
                        }
                        
                        // Quick search suggestions
                        VStack(alignment: .leading, spacing: 12) {
                            Text("Popular Searches")
                                .font(.system(size: 14, weight: .medium))
                                .foregroundColor(.secondary)
                                .padding(.horizontal, 20)
                            
                            ScrollView(.horizontal, showsIndicators: false) {
                                HStack(spacing: 12) {
                                    ForEach(["Italian restaurants", "Coffee near me", "Best brunch", "Rooftop bars", "Sushi places"], id: \.self) { suggestion in
                                        Button(action: {
                                            searchText = suggestion
                                            performSearch()
                                        }) {
                                            Text(suggestion)
                                                .font(.system(size: 14, weight: .medium))
                                                .foregroundColor(.primary)
                                                .padding(.horizontal, 16)
                                                .padding(.vertical, 8)
                                                .background(Color(.systemGray6))
                                                .cornerRadius(20)
                                        }
                                    }
                                }
                                .padding(.horizontal, 20)
                            }
                        }
                        
                        Spacer()
                    }
                    .padding(.top, 40)
                } else {
                    // Results list
                    ScrollView {
                        LazyVStack(spacing: 12) {
                            ForEach(searchResults) { result in
                                SearchResultRow(result: result) {
                                    selectedLocation = result
                                    showingDetailSheet = true
                                }
                            }
                        }
                        .padding(.horizontal, 20)
                        .padding(.top, 10)
                    }
                }
            }
            .background(Color(.systemBackground))
        }
        .sheet(isPresented: $showingDetailSheet) {
            if let location = selectedLocation {
                AddSpotDetailView(location: location)
                    .environmentObject(store)
            }
        }
        .onChange(of: searchText) { _, newValue in
            if newValue.isEmpty {
                searchResults = []
            }
        }
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

// MARK: - Search Result Row

struct SearchResultRow: View {
    let result: MockLocationResult
    let onTap: () -> Void
    
    var body: some View {
        Button(action: onTap) {
            HStack(spacing: 12) {
                // Location image or icon
                if let imageURL = result.imageURL {
                    AsyncImage(url: URL(string: imageURL)) { image in
                        image
                            .resizable()
                            .aspectRatio(contentMode: .fill)
                    } placeholder: {
                        Rectangle()
                            .fill(result.category.color.opacity(0.3))
                            .overlay(
                                Image(systemName: result.category.icon)
                                    .font(.system(size: 24))
                                    .foregroundColor(result.category.color)
                            )
                    }
                    .frame(width: 60, height: 60)
                    .cornerRadius(12)
                } else {
                    Rectangle()
                        .fill(result.category.color.opacity(0.3))
                        .overlay(
                            Image(systemName: result.category.icon)
                                .font(.system(size: 24))
                                .foregroundColor(result.category.color)
                        )
                        .frame(width: 60, height: 60)
                        .cornerRadius(12)
                }
                
                VStack(alignment: .leading, spacing: 4) {
                    Text(result.name)
                        .font(.system(size: 16, weight: .medium))
                        .foregroundColor(.primary)
                        .multilineTextAlignment(.leading)
                    
                    HStack(spacing: 6) {
                        Text(result.category.rawValue.capitalized)
                            .font(.system(size: 12, weight: .medium))
                            .foregroundColor(.white)
                            .padding(.horizontal, 8)
                            .padding(.vertical, 3)
                            .background(result.category.color)
                            .cornerRadius(10)
                        
                        if result.rating > 0 {
                            HStack(spacing: 2) {
                                Image(systemName: "star.fill")
                                    .font(.system(size: 10))
                                    .foregroundColor(.yellow)
                                
                                Text(String(format: "%.1f", result.rating))
                                    .font(.system(size: 12))
                                    .foregroundColor(.secondary)
                            }
                        }
                    }
                    
                    Text(result.address)
                        .font(.system(size: 12))
                        .foregroundColor(.secondary)
                        .lineLimit(1)
                    
                    if let distance = result.distance {
                        Text("\(String(format: "%.1f", distance)) km away")
                            .font(.system(size: 11))
                            .foregroundColor(.orange)
                    }
                }
                
                Spacer()
                
                Image(systemName: "chevron.right")
                    .font(.system(size: 12))
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
        }
        .buttonStyle(PlainButtonStyle())
    }
}

// MARK: - Add Spot Detail View

struct AddSpotDetailView: View {
    let location: MockLocationResult
    @Environment(\.dismiss) private var dismiss
    @EnvironmentObject var store: RestaurantStore
    @State private var showingSuccessAlert = false
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 24) {
                    // Header image
                    if let imageURL = location.imageURL {
                        AsyncImage(url: URL(string: imageURL)) { image in
                            image
                                .resizable()
                                .aspectRatio(contentMode: .fill)
                        } placeholder: {
                            Rectangle()
                                .fill(location.category.color.opacity(0.3))
                                .overlay(
                                    Image(systemName: location.category.icon)
                                        .font(.system(size: 60))
                                        .foregroundColor(location.category.color)
                                )
                        }
                        .frame(height: 200)
                        .clipped()
                        .cornerRadius(16)
                    }
                    
                    VStack(spacing: 16) {
                        // Title and category
                        VStack(spacing: 8) {
                            Text(location.name)
                                .font(.system(size: 24, weight: .bold))
                                .multilineTextAlignment(.center)
                            
                            HStack(spacing: 12) {
                                Text(location.category.rawValue.capitalized)
                                    .font(.system(size: 14, weight: .medium))
                                    .foregroundColor(.white)
                                    .padding(.horizontal, 12)
                                    .padding(.vertical, 6)
                                    .background(location.category.color)
                                    .cornerRadius(20)
                                
                                if location.rating > 0 {
                                    HStack(spacing: 4) {
                                        Image(systemName: "star.fill")
                                            .font(.system(size: 14))
                                            .foregroundColor(.yellow)
                                        
                                        Text(String(format: "%.1f", location.rating))
                                            .font(.system(size: 14, weight: .medium))
                                    }
                                }
                            }
                        }
                        
                        // Address and distance
                        VStack(spacing: 8) {
                            HStack(spacing: 8) {
                                Image(systemName: "location.fill")
                                    .font(.system(size: 14))
                                    .foregroundColor(.secondary)
                                
                                Text(location.address)
                                    .font(.system(size: 14))
                                    .foregroundColor(.secondary)
                            }
                            
                            if let distance = location.distance {
                                Text("\(String(format: "%.1f", distance)) km from your location")
                                    .font(.system(size: 12))
                                    .foregroundColor(.orange)
                            }
                        }
                        
                        // Description
                        if !location.description.isEmpty {
                            Text(location.description)
                                .font(.system(size: 16))
                                .foregroundColor(.secondary)
                                .multilineTextAlignment(.center)
                                .padding(.horizontal, 20)
                        }
                        
                        // Add to saved button
                        Button(action: {
                            addToSaved()
                        }) {
                            HStack {
                                Image(systemName: "heart.fill")
                                    .font(.system(size: 18))
                                
                                Text("Add to Saved")
                                    .font(.system(size: 18, weight: .semibold))
                            }
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 16)
                            .background(Color.black)
                            .cornerRadius(16)
                        }
                        .padding(.horizontal, 20)
                        .padding(.top, 20)
                    }
                    .padding(.horizontal, 20)
                }
            }
            .navigationTitle("Spot Details")
            .navigationBarTitleDisplayMode(.inline)
            .navigationBarItems(
                trailing: Button("Close") {
                    dismiss()
                }
            )
        }
        .alert("Added to Saved!", isPresented: $showingSuccessAlert) {
            Button("OK") {
                dismiss()
            }
        } message: {
            Text("\(location.name) has been added to your saved spots.")
        }
    }
    
    private func addToSaved() {
        // Convert MockLocationResult to Restaurant
        let restaurant = Restaurant(
            name: location.name,
            category: location.category,
            imageURL: location.imageURL ?? "",
            description: location.description.isEmpty ? "Added from search" : location.description,
            rating: location.rating,
            priceRange: "$$",
            address: location.address,
            latitude: location.coordinate.latitude,
            longitude: location.coordinate.longitude,
            tags: [location.category.rawValue],
            source: .web
        )
        
        store.saveRestaurant(restaurant)
        HapticManager.shared.success()
        showingSuccessAlert = true
    }
}

// MARK: - Mock Google Maps API

struct MockLocationResult: Identifiable {
    let id = UUID()
    let name: String
    let address: String
    let coordinate: CLLocationCoordinate2D
    let category: RestaurantCategory
    let rating: Double
    let imageURL: String?
    let description: String
    let distance: Double?
}

class MockGoogleMapsAPI {
    static func search(query: String) -> [MockLocationResult] {
        let searchQuery = query.lowercased()
        
        // Mock search results based on query
        var results: [MockLocationResult] = []
        
        if searchQuery.contains("italian") || searchQuery.contains("pasta") {
            results.append(contentsOf: [
                MockLocationResult(
                    name: "Tipo 00",
                    address: "361 Little Bourke St, Melbourne",
                    coordinate: CLLocationCoordinate2D(latitude: -37.8136, longitude: 144.9631),
                    category: .restaurants,
                    rating: 4.6,
                    imageURL: "https://images.unsplash.com/photo-1555396273-367ea4eb4db5?ixlib=rb-4.0.3&w=400",
                    description: "Contemporary Italian restaurant known for handmade pasta",
                    distance: 1.2
                ),
                MockLocationResult(
                    name: "Osteria Ilaria",
                    address: "46 Collins St, Melbourne",
                    coordinate: CLLocationCoordinate2D(latitude: -37.8174, longitude: 144.9685),
                    category: .restaurants,
                    rating: 4.4,
                    imageURL: nil,
                    description: "Authentic Italian dining experience",
                    distance: 0.8
                )
            ])
        }
        
        if searchQuery.contains("coffee") || searchQuery.contains("cafe") {
            results.append(contentsOf: [
                MockLocationResult(
                    name: "Seven Seeds Coffee",
                    address: "114 Berkeley St, Carlton",
                    coordinate: CLLocationCoordinate2D(latitude: -37.7991, longitude: 144.9658),
                    category: .cafe,
                    rating: 4.5,
                    imageURL: "https://images.unsplash.com/photo-1501339847302-ac426a4a7cbb?ixlib=rb-4.0.3&w=400",
                    description: "Specialty coffee roasters with excellent brews",
                    distance: 2.1
                ),
                MockLocationResult(
                    name: "Market Lane Coffee",
                    address: "Curtin House, 252 Swanston St",
                    coordinate: CLLocationCoordinate2D(latitude: -37.8136, longitude: 144.9672),
                    category: .cafe,
                    rating: 4.3,
                    imageURL: nil,
                    description: "Popular coffee spot in the heart of the city",
                    distance: 0.5
                )
            ])
        }
        
        if searchQuery.contains("bar") || searchQuery.contains("drinks") {
            results.append(contentsOf: [
                MockLocationResult(
                    name: "Eau De Vie",
                    address: "1 Malthouse Ln, Melbourne",
                    coordinate: CLLocationCoordinate2D(latitude: -37.8174, longitude: 144.9685),
                    category: .bars,
                    rating: 4.7,
                    imageURL: "https://images.unsplash.com/photo-1514362545857-3bc16c4c7d1b?ixlib=rb-4.0.3&w=400",
                    description: "Whiskey bar with extensive selection",
                    distance: 0.9
                ),
                MockLocationResult(
                    name: "Bomba Tapas Bar",
                    address: "27 Hardware Ln, Melbourne",
                    coordinate: CLLocationCoordinate2D(latitude: -37.8155, longitude: 144.9665),
                    category: .bars,
                    rating: 4.2,
                    imageURL: nil,
                    description: "Spanish tapas and cocktails",
                    distance: 0.7
                )
            ])
        }
        
        if searchQuery.contains("sushi") || searchQuery.contains("japanese") {
            results.append(contentsOf: [
                MockLocationResult(
                    name: "Nobu Melbourne",
                    address: "Crown Casino, 8 Whiteman St",
                    coordinate: CLLocationCoordinate2D(latitude: -37.8217, longitude: 144.9584),
                    category: .restaurants,
                    rating: 4.8,
                    imageURL: "https://images.unsplash.com/photo-1579584425555-c3ce17fd4351?ixlib=rb-4.0.3&w=400",
                    description: "High-end Japanese cuisine",
                    distance: 1.5
                ),
                MockLocationResult(
                    name: "Kenzan Japanese Restaurant",
                    address: "45 Collins St, Melbourne",
                    coordinate: CLLocationCoordinate2D(latitude: -37.8174, longitude: 144.9685),
                    category: .restaurants,
                    rating: 4.3,
                    imageURL: nil,
                    description: "Traditional Japanese restaurant",
                    distance: 0.8
                )
            ])
        }
        
        if searchQuery.contains("brunch") || searchQuery.contains("breakfast") {
            results.append(contentsOf: [
                MockLocationResult(
                    name: "Higher Ground",
                    address: "650 Little Bourke St, Melbourne",
                    coordinate: CLLocationCoordinate2D(latitude: -37.8147, longitude: 144.9536),
                    category: .cafe,
                    rating: 4.4,
                    imageURL: "https://images.unsplash.com/photo-1533089860892-a7c6f0a88666?ixlib=rb-4.0.3&w=400",
                    description: "Popular brunch spot with amazing coffee",
                    distance: 1.8
                ),
                MockLocationResult(
                    name: "Grain Store",
                    address: "517 Flinders Ln, Melbourne",
                    coordinate: CLLocationCoordinate2D(latitude: -37.8174, longitude: 144.9685),
                    category: .cafe,
                    rating: 4.2,
                    imageURL: nil,
                    description: "Contemporary cafe with healthy options",
                    distance: 1.0
                )
            ])
        }
        
        // Generic search results if no specific category matches
        if results.isEmpty {
            results = [
                MockLocationResult(
                    name: "Local Favorite Bistro",
                    address: "123 Collins St, Melbourne",
                    coordinate: CLLocationCoordinate2D(latitude: -37.8174, longitude: 144.9685),
                    category: .restaurants,
                    rating: 4.1,
                    imageURL: nil,
                    description: "A hidden gem in the city",
                    distance: 0.6
                ),
                MockLocationResult(
                    name: "The Corner Cafe",
                    address: "456 Flinders St, Melbourne",
                    coordinate: CLLocationCoordinate2D(latitude: -37.8183, longitude: 144.9671),
                    category: .cafe,
                    rating: 4.0,
                    imageURL: nil,
                    description: "Cozy neighborhood cafe",
                    distance: 1.1
                )
            ]
        }
        
        return results
    }
}


#Preview {
    AddSpotView()
        .environmentObject(RestaurantStore())
}