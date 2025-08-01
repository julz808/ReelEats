import SwiftUI
import MapKit

// MARK: - Restaurant Detail View (Matching Screenshots)

struct RestaurantDetailView: View {
    let restaurant: Restaurant
    @EnvironmentObject var store: RestaurantStore
    @Environment(\.dismiss) private var dismiss
    @State private var showingCollectionPicker = false
    @State private var scrollOffset: CGFloat = 0
    @State private var showingInsights = false
    
    var body: some View {
        GeometryReader { geometry in
            ZStack {
                // Clean background
                Color(.systemBackground)
                    .ignoresSafeArea()
                
                // Content overlay
                VStack(spacing: 0) {
                    // Hero image with close button overlay
                    ZStack(alignment: .topTrailing) {
                        AsyncImage(url: URL(string: restaurant.imageURL)) { image in
                            image
                                .resizable()
                                .aspectRatio(contentMode: .fill)
                        } placeholder: {
                            Rectangle()
                                .fill(restaurant.category.color.opacity(0.3))
                                .overlay(
                                    Image(systemName: restaurant.category.icon)
                                        .font(.system(size: 60))
                                        .foregroundColor(restaurant.category.color)
                                )
                        }
                        .frame(height: 300)
                        .clipped()
                        
                        // Close button
                        Button(action: {
                            HapticManager.shared.light()
                            dismiss()
                        }) {
                            Image(systemName: "xmark.circle.fill")
                                .font(.system(size: 28))
                                .foregroundColor(.white)
                                .background(Color.black.opacity(0.3))
                                .clipShape(Circle())
                        }
                        .padding(.trailing, 20)
                        .padding(.top, 60)
                    }
                    
                    // Bottom content card
                    VStack(spacing: 0) {
                        // Drag handle
                        RoundedRectangle(cornerRadius: 2.5)
                            .fill(Color(.systemGray4))
                            .frame(width: 40, height: 4)
                            .padding(.top, 8)
                            .padding(.bottom, 16)
                        
                        // Content section
                        VStack(spacing: 0) {
                            if !showingInsights {
                                // Main detail view - wrapped in ScrollView for better content fitting
                                ScrollView {
                                    VStack(spacing: 20) {
                                    // Category tag
                                    HStack {
                                        HStack(spacing: 4) {
                                            Image(systemName: restaurant.category.icon)
                                                .font(.system(size: 14, weight: .medium))
                                            Text(restaurant.tags.first ?? restaurant.category.rawValue)
                                                .font(.system(size: 14, weight: .medium))
                                        }
                                        .foregroundColor(.white)
                                        .padding(.horizontal, 12)
                                        .padding(.vertical, 6)
                                        .background(restaurant.category.color)
                                        .cornerRadius(20)
                                        
                                        Spacer()
                                    }
                                    .padding(.horizontal, 20)
                                    
                                    // Restaurant name
                                    HStack {
                                        Text(restaurant.name)
                                            .font(.system(size: 28, weight: .bold))
                                            .foregroundColor(.primary)
                                        
                                        Spacer()
                                        
                                        Image(systemName: "star.fill")
                                            .font(.system(size: 20))
                                            .foregroundColor(.yellow)
                                    }
                                    .padding(.horizontal, 20)
                                    
                                    // Source info
                                    HStack(spacing: 16) {
                                        Image(systemName: restaurant.source.icon)
                                            .font(.system(size: 18))
                                            .foregroundColor(.secondary)
                                        
                                        Spacer()
                                        
                                        HStack(spacing: 20) {
                                            Image(systemName: "ellipsis")
                                                .font(.system(size: 18))
                                                .foregroundColor(.secondary)
                                            
                                            Text(restaurant.source.displayName)
                                                .font(.system(size: 14))
                                                .foregroundColor(.secondary)
                                                .padding(.horizontal, 12)
                                                .padding(.vertical, 4)
                                                .overlay(
                                                    RoundedRectangle(cornerRadius: 12)
                                                        .stroke(Color.secondary.opacity(0.3), lineWidth: 1)
                                                )
                                        }
                                    }
                                    .padding(.horizontal, 20)
                                    
                                    // Description
                                    Text(restaurant.description)
                                        .font(.system(size: 16))
                                        .foregroundColor(.secondary)
                                        .multilineTextAlignment(.center)
                                        .padding(.horizontal, 30)
                                        .padding(.top, 8)
                                        .lineLimit(3)
                                    
                                    // Address
                                    HStack {
                                        Image(systemName: "location.fill")
                                            .font(.system(size: 16))
                                            .foregroundColor(.secondary)
                                        
                                        Text(restaurant.address)
                                            .font(.system(size: 16))
                                            .foregroundColor(.secondary)
                                    }
                                    .padding(.top, 10)
                                    
                                    // Mini map preview
                                    RestaurantMiniMap(restaurant: restaurant)
                                        .frame(height: 120)
                                        .cornerRadius(16)
                                        .padding(.horizontal, 20)
                                        .padding(.top, 8)
                                    
                                    // Action buttons
                                    VStack(spacing: 0) {
                                        // Add to Collection button
                                        Button(action: {
                                            HapticManager.shared.medium()
                                            showingCollectionPicker = true
                                        }) {
                                            HStack {
                                                Image(systemName: "folder.badge.plus")
                                                    .font(.system(size: 18, weight: .medium))
                                                
                                                Text("Add to Collection")
                                                    .font(.system(size: 18, weight: .semibold))
                                            }
                                            .foregroundColor(.white)
                                            .frame(maxWidth: .infinity)
                                            .padding(.vertical, 16)
                                            .background(Color.black)
                                            .cornerRadius(16)
                                        }
                                        .padding(.horizontal, 20)
                                        
                                        // Share and View on Map buttons
                                        HStack(spacing: 12) {
                                            Button(action: {
                                                HapticManager.shared.light()
                                            }) {
                                                VStack(spacing: 8) {
                                                    Image(systemName: "square.and.arrow.up")
                                                        .font(.system(size: 20))
                                                    Text("Share")
                                                        .font(.system(size: 14, weight: .medium))
                                                }
                                                .foregroundColor(.primary)
                                                .frame(maxWidth: .infinity)
                                                .padding(.vertical, 16)
                                                .background(Color(.systemGray6))
                                                .cornerRadius(16)
                                            }
                                            
                                            Button(action: {
                                                HapticManager.shared.light()
                                            }) {
                                                VStack(spacing: 8) {
                                                    Image(systemName: "map.fill")
                                                        .font(.system(size: 20))
                                                    Text("View on Map")
                                                        .font(.system(size: 14, weight: .medium))
                                                }
                                                .foregroundColor(.primary)
                                                .frame(maxWidth: .infinity)
                                                .padding(.vertical, 16)
                                                .background(Color(.systemGray6))
                                                .cornerRadius(16)
                                            }
                                        }
                                        .padding(.horizontal, 20)
                                        .padding(.top, 12)
                                    }
                                    .padding(.top, 20)
                                    .padding(.bottom, 40)
                                    }
                                }
                                .frame(maxHeight: 500) // Limit height to ensure it fits on screen
                            } else {
                                // Insights view (scrollable)
                                InsightsView(restaurant: restaurant)
                            }
                        }
                    }
                    .background(Color(.systemBackground))
                    .cornerRadius(showingInsights ? 0 : 24, corners: [.topLeft, .topRight])
                    .offset(y: showingInsights ? 0 : max(0, scrollOffset))
                    .gesture(
                        DragGesture()
                            .onChanged { value in
                                if !showingInsights {
                                    scrollOffset = value.translation.height
                                }
                            }
                            .onEnded { value in
                                withAnimation(.spring()) {
                                    if value.predictedEndTranslation.height < -100 {
                                        HapticManager.shared.medium()
                                        showingInsights = true
                                        scrollOffset = 0
                                    } else {
                                        HapticManager.shared.light()
                                        scrollOffset = 0
                                    }
                                }
                            }
                    )
                }
            }
        }
        .sheet(isPresented: $showingCollectionPicker) {
            CollectionPickerView(restaurant: restaurant)
                .environmentObject(store)
        }
    }
}

// MARK: - Collection Picker View

struct CollectionPickerView: View {
    let restaurant: Restaurant
    @EnvironmentObject var store: RestaurantStore
    @Environment(\.dismiss) private var dismiss
    @State private var showingNewCollection = false
    
    var body: some View {
        NavigationView {
            VStack(spacing: 24) {
                if store.collections.isEmpty {
                    // Empty state - matching screenshot
                    VStack(spacing: 20) {
                        Spacer()
                        
                        VStack(spacing: 16) {
                            Text("Try creating a new Collection")
                                .font(.system(size: 18, weight: .medium))
                                .foregroundColor(.primary)
                                .multilineTextAlignment(.center)
                            
                            Button(action: {
                                HapticManager.shared.light()
                                showingNewCollection = true
                            }) {
                                Text("Add Collection")
                                    .font(.system(size: 16, weight: .semibold))
                                    .foregroundColor(.white)
                                    .frame(maxWidth: .infinity)
                                    .frame(height: 50)
                                    .background(Color.black)
                                    .cornerRadius(25)
                            }
                            .padding(.horizontal, 40)
                        }
                        
                        Spacer()
                    }
                } else {
                    // Collections list
                    ScrollView {
                        LazyVStack(spacing: 12) {
                            ForEach(store.collections) { collection in
                                CollectionRow(collection: collection) {
                                    // Add to collection
                                    HapticManager.shared.success()
                                    store.addRestaurantToCollection(restaurant: restaurant, collection: collection)
                                    dismiss()
                                }
                            }
                        }
                        .padding(.horizontal, 20)
                        .padding(.top, 20)
                    }
                }
            }
            .navigationTitle("Add to Collection")
            .navigationBarTitleDisplayMode(.inline)
            .navigationBarItems(
                leading: Button("Cancel") {
                    dismiss()
                },
                trailing: Button(action: {
                    showingNewCollection = true
                }) {
                    Image(systemName: "plus")
                        .font(.system(size: 18, weight: .semibold))
                }
            )
        }
        .sheet(isPresented: $showingNewCollection) {
            NewCollectionView()
                .environmentObject(store)
        }
    }
}

// MARK: - Collection Row

struct CollectionRow: View {
    let collection: Collection
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            HStack {
                // Collection preview - gradient background like in screenshot
                RoundedRectangle(cornerRadius: 12)
                    .fill(
                        LinearGradient(
                            colors: [Color.purple.opacity(0.8), Color.pink.opacity(0.8)],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .frame(width: 60, height: 60)
                    .overlay(
                        Text(collection.name.prefix(1).uppercased())
                            .font(.system(size: 24, weight: .bold))
                            .foregroundColor(.white)
                    )
                
                VStack(alignment: .leading, spacing: 4) {
                    Text(collection.name)
                        .font(.system(size: 18, weight: .medium))
                        .foregroundColor(.primary)
                    
                    Text("\(collection.restaurantIds.count) spots")
                        .font(.system(size: 14))
                        .foregroundColor(.secondary)
                }
                
                Spacer()
                
                Image(systemName: "chevron.right")
                    .font(.system(size: 14))
                    .foregroundColor(.secondary)
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 12)
            .background(Color(.systemGray6))
            .cornerRadius(12)
        }
        .buttonStyle(PlainButtonStyle())
    }
}

// MARK: - New Collection View

struct NewCollectionView: View {
    @EnvironmentObject var store: RestaurantStore
    @Environment(\.dismiss) private var dismiss
    @State private var collectionName = ""
    @State private var selectedGradient = 0
    
    private let gradientOptions: [[Color]] = [
        [.purple.opacity(0.8), .pink.opacity(0.8)],
        [.blue.opacity(0.8), .cyan.opacity(0.8)],
        [.orange.opacity(0.8), .yellow.opacity(0.8)],
        [.green.opacity(0.8), .mint.opacity(0.8)],
        [.red.opacity(0.8), .pink.opacity(0.8)]
    ]
    
    var body: some View {
        NavigationView {
            VStack(spacing: 24) {
                // Collection preview
                VStack(spacing: 20) {
                    RoundedRectangle(cornerRadius: 20)
                        .fill(
                            LinearGradient(
                                colors: gradientOptions[selectedGradient],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                        .frame(width: 120, height: 120)
                        .overlay(
                            Text(collectionName.isEmpty ? "?" : collectionName.prefix(1).uppercased())
                                .font(.system(size: 40, weight: .bold))
                                .foregroundColor(.white)
                        )
                    
                    Text(collectionName.isEmpty ? "New Collection" : collectionName)
                        .font(.system(size: 18, weight: .medium))
                        .foregroundColor(.primary)
                }
                .padding(.top, 40)
                
                // Collection name input
                VStack(alignment: .leading, spacing: 8) {
                    Text("Collection Name")
                        .font(.system(size: 16, weight: .medium))
                        .foregroundColor(.primary)
                    
                    TextField("Enter name", text: $collectionName)
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                }
                .padding(.horizontal, 20)
                
                // Gradient picker
                VStack(alignment: .leading, spacing: 12) {
                    Text("Cover Style")
                        .font(.system(size: 16, weight: .medium))
                        .foregroundColor(.primary)
                        .padding(.horizontal, 20)
                    
                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack(spacing: 12) {
                            ForEach(0..<gradientOptions.count, id: \.self) { index in
                                Circle()
                                    .fill(
                                        LinearGradient(
                                            colors: gradientOptions[index],
                                            startPoint: .topLeading,
                                            endPoint: .bottomTrailing
                                        )
                                    )
                                    .frame(width: 50, height: 50)
                                    .overlay(
                                        Circle()
                                            .stroke(Color.black, lineWidth: selectedGradient == index ? 3 : 0)
                                    )
                                    .onTapGesture {
                                        selectedGradient = index
                                    }
                            }
                        }
                        .padding(.horizontal, 20)
                    }
                }
                
                Spacer()
                
                // Create button
                Button(action: {
                    if !collectionName.isEmpty {
                        store.createCollection(name: collectionName)
                        dismiss()
                    }
                }) {
                    Text("Create Collection")
                        .font(.system(size: 16, weight: .semibold))
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .frame(height: 50)
                        .background(collectionName.isEmpty ? Color.gray : Color.black)
                        .cornerRadius(25)
                }
                .disabled(collectionName.isEmpty)
                .padding(.horizontal, 20)
                .padding(.bottom, 40)
            }
            .navigationTitle("New Collection")
            .navigationBarTitleDisplayMode(.inline)
            .navigationBarItems(
                leading: Button("Cancel") {
                    dismiss()
                }
            )
        }
    }
}

// MARK: - Restaurant Mini Map Component

struct RestaurantMiniMap: View {
    let restaurant: Restaurant
    @State private var region: MKCoordinateRegion
    
    init(restaurant: Restaurant) {
        self.restaurant = restaurant
        self._region = State(initialValue: MKCoordinateRegion(
            center: CLLocationCoordinate2D(latitude: restaurant.latitude, longitude: restaurant.longitude),
            span: MKCoordinateSpan(latitudeDelta: 0.01, longitudeDelta: 0.01)
        ))
    }
    
    var body: some View {
        Map(coordinateRegion: .constant(region), annotationItems: [restaurant]) { restaurant in
            MapAnnotation(coordinate: CLLocationCoordinate2D(latitude: restaurant.latitude, longitude: restaurant.longitude)) {
                Circle()
                    .fill(restaurant.category.color)
                    .frame(width: 12, height: 12)
                    .overlay(
                        Circle()
                            .stroke(Color.white, lineWidth: 2)
                    )
            }
        }
    }
}

// MARK: - Insights View

struct InsightsView: View {
    let restaurant: Restaurant
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        VStack(spacing: 0) {
            // Header
            HStack {
                Button(action: {
                    dismiss()
                }) {
                    Image(systemName: "chevron.left")
                        .font(.system(size: 20, weight: .medium))
                        .foregroundColor(.primary)
                }
                
                Spacer()
                
                Text(restaurant.name)
                    .font(.system(size: 18, weight: .semibold))
                    .lineLimit(1)
                
                Spacer()
            }
            .padding(.horizontal, 20)
            .padding(.vertical, 16)
            .background(Color(.systemBackground))
            
            ScrollView {
                VStack(alignment: .leading, spacing: 32) {
                    // Hero image with overlay text
                    ZStack(alignment: .bottomLeading) {
                        AsyncImage(url: URL(string: restaurant.imageURL)) { image in
                            image
                                .resizable()
                                .aspectRatio(contentMode: .fill)
                        } placeholder: {
                            Rectangle()
                                .fill(restaurant.category.color.opacity(0.3))
                        }
                        .frame(height: 300)
                        .clipped()
                        
                        // Text overlay
                        VStack(alignment: .leading, spacing: 8) {
                            Text(restaurant.name.uppercased())
                                .font(.system(size: 32, weight: .black))
                                .foregroundColor(.white)
                            
                            Text(restaurant.description)
                                .font(.system(size: 18, weight: .medium))
                                .foregroundColor(.white)
                        }
                        .padding(20)
                        .background(
                            LinearGradient(colors: [.clear, .black.opacity(0.7)], startPoint: .top, endPoint: .bottom)
                        )
                    }
                    
                    // Category pill
                    HStack {
                        HStack(spacing: 4) {
                            Image(systemName: restaurant.category.icon)
                                .font(.system(size: 14, weight: .medium))
                            Text(restaurant.tags.first ?? restaurant.category.rawValue)
                                .font(.system(size: 14, weight: .medium))
                        }
                        .foregroundColor(.white)
                        .padding(.horizontal, 16)
                        .padding(.vertical, 8)
                        .background(restaurant.category.color)
                        .cornerRadius(20)
                        
                        Spacer()
                    }
                    .padding(.horizontal, 20)
                    
                    // Source info
                    HStack(spacing: 16) {
                        Image(systemName: restaurant.source.icon)
                            .font(.system(size: 18))
                            .foregroundColor(.secondary)
                        
                        Spacer()
                        
                        Text(restaurant.source.displayName)
                            .font(.system(size: 14))
                            .foregroundColor(.secondary)
                            .padding(.horizontal, 12)
                            .padding(.vertical, 4)
                            .overlay(
                                RoundedRectangle(cornerRadius: 12)
                                    .stroke(Color.secondary.opacity(0.3), lineWidth: 1)
                            )
                    }
                    .padding(.horizontal, 20)
                    
                    // Key insights
                    VStack(alignment: .leading, spacing: 24) {
                        InsightRow(
                            emoji: "😋",
                            title: "Indulge in Treats",
                            description: "Sometimes, the best experiences involve indulging in your favorite treats. Don't hesitate to treat yourself!"
                        )
                        
                        InsightRow(
                            emoji: "⭐",
                            title: "Offer Unique Quality",
                            description: "Exceptional quality and unique offerings can create a strong demand. \(restaurant.name)'s menu is a prime example."
                        )
                        
                        InsightRow(
                            emoji: "📣",
                            title: "Embrace Recommendations",
                            description: "Word-of-mouth and personal recommendations are powerful. The reviewer's enthusiasm highlights the restaurant's appeal."
                        )
                    }
                    .padding(.horizontal, 20)
                    
                    Divider()
                        .padding(.horizontal, 20)
                    
                    // Restaurant details section
                    VStack(alignment: .leading, spacing: 20) {
                        HStack {
                            Image(systemName: restaurant.category.icon)
                                .font(.system(size: 24))
                                .foregroundColor(restaurant.category.color)
                            
                            Spacer()
                            
                            Button(action: {}) {
                                Image(systemName: "ellipsis")
                                    .font(.system(size: 20))
                                    .foregroundColor(.secondary)
                            }
                        }
                        
                        Text(restaurant.name)
                            .font(.system(size: 24, weight: .bold))
                        
                        Text(restaurant.description)
                            .font(.system(size: 16))
                            .foregroundColor(.secondary)
                            .fixedSize(horizontal: false, vertical: true)
                    }
                    .padding(.horizontal, 20)
                    
                    // Map section
                    VStack(alignment: .leading, spacing: 12) {
                        RestaurantMiniMap(restaurant: restaurant)
                            .frame(height: 200)
                            .cornerRadius(16)
                        
                        Button(action: {}) {
                            Text("View on map")
                                .font(.system(size: 18, weight: .semibold))
                                .foregroundColor(.white)
                                .frame(maxWidth: .infinity)
                                .padding(.vertical, 16)
                                .background(Color.black)
                                .cornerRadius(50)
                        }
                    }
                    .padding(.horizontal, 20)
                    
                    // Recently Saved section
                    VStack(alignment: .leading, spacing: 16) {
                        Text("Recently Saved")
                            .font(.system(size: 20, weight: .bold))
                            .padding(.horizontal, 20)
                        
                        // Add some placeholder for recently saved items
                        Rectangle()
                            .fill(Color(.systemGray6))
                            .frame(height: 100)
                            .padding(.horizontal, 20)
                    }
                    .padding(.top, 20)
                    .padding(.bottom, 40)
                }
            }
        }
    }
}

struct InsightRow: View {
    let emoji: String
    let title: String
    let description: String
    
    var body: some View {
        HStack(alignment: .top, spacing: 16) {
            Text(emoji)
                .font(.system(size: 28))
            
            VStack(alignment: .leading, spacing: 8) {
                Text(title)
                    .font(.system(size: 18, weight: .bold))
                
                Text(description)
                    .font(.system(size: 16))
                    .foregroundColor(.secondary)
                    .fixedSize(horizontal: false, vertical: true)
            }
        }
    }
}

#Preview {
    RestaurantDetailView(restaurant: Melbourne.demoRestaurants[0])
        .environmentObject(RestaurantStore())
}