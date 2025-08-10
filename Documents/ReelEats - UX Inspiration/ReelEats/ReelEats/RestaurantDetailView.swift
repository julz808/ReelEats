import SwiftUI
import MapKit
import PhotosUI

// MARK: - Restaurant Detail View (Matching Screenshots)

struct RestaurantDetailView: View {
    let restaurant: Restaurant
    @EnvironmentObject var store: RestaurantStore
    @Environment(\.dismiss) private var dismiss
    @State private var showingCollectionPicker = false
    @State private var userNotes: String = ""
    @State private var userRating: Double = 0.0
    
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
                                        .font(.clashDisplayHeaderTemp(size: 60))
                                        .foregroundColor(restaurant.category.color)
                                )
                        }
                        .frame(height: 300)
                        .clipped()
                        
                        // Close button - moved to top right
                        Button(action: {
                            HapticManager.shared.light()
                            dismiss()
                        }) {
                            Image(systemName: "xmark.circle.fill")
                                .font(.clashDisplayHeaderTemp(size: 28))
                                .foregroundColor(.white)
                                .background(Color.black.opacity(0.3))
                                .clipShape(Circle())
                        }
                        .padding(.trailing, 20)
                        .padding(.top, 50)
                    }
                    
                    // Bottom content card
                    VStack(spacing: 0) {
                        // Drag handle
                        RoundedRectangle(cornerRadius: 2.5)
                            .fill(Color(.systemGray4))
                            .frame(width: 40, height: 4)
                            .padding(.top, 8)
                            .padding(.bottom, 16)
                        
                        // Content section - simplified single mode
                        ScrollView {
                            VStack(spacing: 20) {
                                // Category tag
                                HStack {
                                    HStack(spacing: 4) {
                                        Image(systemName: restaurant.category.icon)
                                            .font(.clashDisplaySecondaryTemp())
                                        Text(restaurant.tags.first ?? restaurant.category.rawValue)
                                            .font(.clashDisplaySecondaryTemp())
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
                                        .font(.poppinsRestaurantNameTemp(size: 28))
                                        .foregroundColor(.primary)
                                    
                                    Spacer()
                                    
                                    Image(systemName: "star.fill")
                                        .font(.clashDisplayRestaurantNameTemp(size: 20))
                                        .foregroundColor(.yellow)
                                }
                                .padding(.horizontal, 20)
                                
                                // Source info
                                HStack(spacing: 16) {
                                    Image(systemName: restaurant.source.icon)
                                        .font(.clashDisplayBodyTemp(size: 18))
                                        .foregroundColor(.secondary)
                                    
                                    Spacer()
                                    
                                    HStack(spacing: 20) {
                                        Image(systemName: "ellipsis")
                                            .font(.clashDisplayBodyTemp(size: 18))
                                            .foregroundColor(.secondary)
                                        
                                        Text(restaurant.source.displayName)
                                            .font(.clashDisplaySecondaryTemp())
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
                                
                                // Description (now italic)
                                Text(restaurant.description)
                                    .font(.poppinsDescriptionTemp(size: 16))
                                    .italic()
                                    .foregroundColor(.secondary)
                                    .multilineTextAlignment(.center)
                                    .padding(.horizontal, 30)
                                    .padding(.top, 8)
                                    .lineLimit(3)
                                
                                // Reserve Action Button (moved from four-button row)
                                Button(action: {
                                    // Reserve CTA moved here above rating
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
                                .padding(.top, 16)
                                
                                // User Rating Section
                                VStack(spacing: 12) {
                                    Text("Your Rating")
                                        .font(.clashDisplayButtonTemp())
                                        .foregroundColor(.primary)
                                    
                                    StarRatingView(rating: $userRating)
                                        .padding(.horizontal, 20)
                                }
                                .padding(.top, 20)
                                
                                // Notes Section
                                VStack(alignment: .leading, spacing: 12) {
                                    Text("Notes")
                                        .font(.clashDisplayButtonTemp())
                                        .foregroundColor(.primary)
                                    
                                    TextField("Add your notes about this spot...", text: $userNotes, axis: .vertical)
                                        .textFieldStyle(.roundedBorder)
                                        .lineLimit(3...6)
                                        .font(.clashDisplayBodyTemp())
                                }
                                .padding(.horizontal, 30)
                                .padding(.top, 20)
                                
                                // View Original Post moved to bottom (swap with Reserve)
                                Button(action: {
                                    HapticManager.shared.light()
                                }) {
                                    HStack(spacing: 8) {
                                        Image(systemName: getSocialMediaIcon())
                                            .font(.clashDisplayBodyTemp(size: 18))
                                        Text("View original post")
                                            .font(.clashDisplaySecondaryTemp())
                                    }
                                    .foregroundColor(.primary)
                                    .frame(maxWidth: .infinity)
                                    .padding(.vertical, 14)
                                    .background(Color(.systemGray6))
                                    .cornerRadius(20)
                                }
                                .padding(.horizontal, 30)
                                .padding(.top, 24)
                                
                                // Address
                                HStack {
                                    Image(systemName: "location.fill")
                                        .font(.clashDisplayBodyTemp())
                                        .foregroundColor(.secondary)
                                    
                                    Text(restaurant.address)
                                        .font(.poppinsSmallTemp(size: 16))
                                        .foregroundColor(.secondary)
                                }
                                .padding(.top, 10)
                                
                                // Mini map preview
                                RestaurantMiniMap(restaurant: restaurant)
                                    .frame(height: 120)
                                    .cornerRadius(16)
                                    .padding(.horizontal, 20)
                                    .padding(.top, 8)
                                
                                // Action buttons - including Make a Booking
                                VStack(spacing: 12) {
                                    // Add to Collection button
                                    Button(action: {
                                        HapticManager.shared.medium()
                                        showingCollectionPicker = true
                                    }) {
                                        HStack {
                                            Image(systemName: "folder.badge.plus")
                                                .font(.clashDisplayBodyTemp(size: 18))
                                            
                                            Text("Add to Collection")
                                                .font(.poppinsAccentTemp(size: 18))
                                        }
                                        .foregroundColor(.white)
                                        .frame(maxWidth: .infinity)
                                        .padding(.vertical, 16)
                                        .background(Color.black)
                                        .cornerRadius(16)
                                    }
                                    .padding(.horizontal, 20)
                                    
                                    // Four action buttons in new order: View Original Post, Directions, Site, Share
                                    HStack(spacing: 8) {
                                        Button(action: {
                                            // TODO: Open original social media post
                                            HapticManager.shared.light()
                                        }) {
                                            VStack(spacing: 6) {
                                                Image(systemName: getSocialMediaIcon())
                                                    .font(.clashDisplayBodyTemp(size: 18))
                                                Text("View Post")
                                                    .font(.clashDisplayCaptionTemp(size: 11))
                                            }
                                            .foregroundColor(.primary)
                                            .frame(maxWidth: .infinity)
                                            .padding(.vertical, 12)
                                            .background(Color(.systemGray6))
                                            .cornerRadius(12)
                                        }
                                        
                                        Button(action: {
                                            HapticManager.shared.light()
                                        }) {
                                            VStack(spacing: 6) {
                                                Image(systemName: "location.north.circle.fill")
                                                    .font(.clashDisplayBodyTemp(size: 18))
                                                Text("Directions")
                                                    .font(.clashDisplayCaptionTemp(size: 11))
                                            }
                                            .foregroundColor(.primary)
                                            .frame(maxWidth: .infinity)
                                            .padding(.vertical, 12)
                                            .background(Color(.systemGray6))
                                            .cornerRadius(12)
                                        }
                                        
                                        Button(action: {
                                            HapticManager.shared.light()
                                        }) {
                                            VStack(spacing: 6) {
                                                Image(systemName: "globe")
                                                    .font(.clashDisplayBodyTemp(size: 18))
                                                Text("Site")
                                                    .font(.clashDisplayCaptionTemp(size: 11))
                                            }
                                            .foregroundColor(.primary)
                                            .frame(maxWidth: .infinity)
                                            .padding(.vertical, 12)
                                            .background(Color(.systemGray6))
                                            .cornerRadius(12)
                                        }
                                        
                                        Button(action: {
                                            HapticManager.shared.light()
                                        }) {
                                            VStack(spacing: 6) {
                                                Image(systemName: "square.and.arrow.up")
                                                    .font(.clashDisplayBodyTemp(size: 18))
                                                Text("Share")
                                                    .font(.clashDisplayCaptionTemp(size: 11))
                                            }
                                            .foregroundColor(.primary)
                                            .frame(maxWidth: .infinity)
                                            .padding(.vertical, 12)
                                            .background(Color(.systemGray6))
                                            .cornerRadius(12)
                                        }
                                    }
                                    .padding(.horizontal, 20)
                                }
                                .padding(.top, 20)
                                .padding(.bottom, 40)
                            }
                        }
                    }
                    .background(Color(.systemBackground))
                    .cornerRadius(24, corners: [.topLeft, .topRight])
                }
            }
        }
        .sheet(isPresented: $showingCollectionPicker) {
            CollectionPickerView(restaurant: restaurant)
                .environmentObject(store)
        }
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
                                .font(.clashDisplayBodyTemp(size: 18))
                                .foregroundColor(.primary)
                                .multilineTextAlignment(.center)
                            
                            Button(action: {
                                HapticManager.shared.light()
                                showingNewCollection = true
                            }) {
                                Text("Add Collection")
                                    .font(.clashDisplayButtonTemp())
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
                        .font(.clashDisplayButtonTemp(size: 18))
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
                            .font(.clashDisplayCardTitleTemp())
                            .foregroundColor(.white)
                    )
                
                VStack(alignment: .leading, spacing: 4) {
                    Text(collection.name)
                        .font(.poppinsCollectionNameTemp(size: 18))
                        .foregroundColor(.primary)
                    
                    Text("\(collection.restaurantIds.count) spots")
                        .font(.clashDisplaySecondaryTemp())
                        .foregroundColor(.secondary)
                }
                
                Spacer()
                
                Image(systemName: "chevron.right")
                    .font(.clashDisplaySecondaryTemp())
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
    @State private var isAnimating = false
    
    // Cover customization options
    @State private var coverMode: CoverMode = .image // .gradient or .image
    @State private var selectedEmoji = "📍"
    @State private var selectedImage: UIImage?
    @State private var selectedPhotoItem: PhotosPickerItem?
    
    enum CoverMode {
        case gradient, image
    }
    
    let isTogetherCollection: Bool
    let onCollectionCreated: ((String) -> Void)?
    
    init(isTogetherCollection: Bool = false, onCollectionCreated: ((String) -> Void)? = nil) {
        self.isTogetherCollection = isTogetherCollection
        self.onCollectionCreated = onCollectionCreated
    }
    
    private let gradientOptions: [[Color]] = [
        [Color.reelEatsAccent.opacity(0.9), Color.reelEatsAccent.opacity(0.6)],
        [.purple.opacity(0.9), .pink.opacity(0.7)],
        [.blue.opacity(0.9), .cyan.opacity(0.7)],
        [.orange.opacity(0.9), .yellow.opacity(0.7)],
        [.green.opacity(0.9), .mint.opacity(0.7)],
        [.red.opacity(0.9), .pink.opacity(0.7)]
    ]
    
    var headerSection: some View {
        VStack(spacing: 24) {
            Text(isTogetherCollection ? "Create a Together Collection" : "Create a Personal Collection")
                .font(.newYorkHeader(size: 22))
                .foregroundColor(.primary)
                .opacity(isAnimating ? 1.0 : 0.0)
                .offset(y: isAnimating ? 0 : -20)
                .animation(.spring(response: 0.8, dampingFraction: 0.8).delay(0.2), value: isAnimating)
            
            previewSection
        }
        .padding(.top, 20)
    }
    
    var previewSection: some View {
        VStack(spacing: 16) {
            ZStack {
                if coverMode == .gradient {
                    // Gradient background
                    RoundedRectangle(cornerRadius: 24)
                        .fill(
                            LinearGradient(
                                colors: gradientOptions[selectedGradient],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                        .frame(width: 140, height: 140)
                        .shadow(color: gradientOptions[selectedGradient][0].opacity(0.3), radius: 20, x: 0, y: 10)
                } else {
                    // Image background
                    RoundedRectangle(cornerRadius: 24)
                        .fill(Color.gray.opacity(0.3))
                        .frame(width: 140, height: 140)
                        .overlay(
                            Group {
                                if let selectedImage = selectedImage {
                                    Image(uiImage: selectedImage)
                                        .resizable()
                                        .aspectRatio(contentMode: .fill)
                                        .frame(width: 140, height: 140)
                                        .clipped()
                                        .cornerRadius(24)
                                } else {
                                    VStack(spacing: 8) {
                                        Image(systemName: "photo")
                                            .font(.newYorkLogo(size: 32))
                                            .foregroundColor(.secondary)
                                        Text("Add Photo")
                                            .font(.newYorkCaption())
                                            .foregroundColor(.secondary)
                                    }
                                }
                            }
                        )
                        .shadow(color: .black.opacity(0.1), radius: 20, x: 0, y: 10)
                }
                
                // Content overlay
                if coverMode == .gradient {
                    if isTogetherCollection {
                        VStack(spacing: 4) {
                            Image(systemName: "person.2.fill")
                                .font(.newYorkLogo(size: 20))
                                .foregroundColor(.white)
                            
                            Text(selectedEmoji)
                                .font(.system(size: 36))
                        }
                        .opacity(isAnimating ? 1.0 : 0.0)
                        .scaleEffect(isAnimating ? 1.0 : 0.5)
                        .animation(.spring(response: 0.8, dampingFraction: 0.7).delay(0.6), value: isAnimating)
                    } else {
                        Text(selectedEmoji)
                            .font(.system(size: 48))
                            .opacity(isAnimating ? 1.0 : 0.0)
                            .scaleEffect(isAnimating ? 1.0 : 0.5)
                            .animation(.spring(response: 0.8, dampingFraction: 0.7).delay(0.6), value: isAnimating)
                    }
                }
            }
            .scaleEffect(isAnimating ? 1.0 : 0.8)
            .animation(.spring(response: 0.8, dampingFraction: 0.7).delay(0.4), value: isAnimating)
            
            Text(collectionName.isEmpty ? (isTogetherCollection ? "Together Collection" : "My Collection") : collectionName)
                .font(.newYorkCardTitle(size: 20))
                .foregroundColor(.primary)
                .opacity(isAnimating ? 1.0 : 0.0)
                .offset(y: isAnimating ? 0 : 10)
                .animation(.spring(response: 0.8, dampingFraction: 0.8).delay(0.8), value: isAnimating)
        }
    }
    
    var inputSection: some View {
        VStack(spacing: 24) {
            VStack(alignment: .leading, spacing: 12) {
                Text("Collection Name")
                    .font(.newYorkButton())
                    .foregroundColor(.secondary)
                
                TextField("Enter collection name", text: $collectionName)
                    .font(.newYorkRestaurantName())
                    .padding(.horizontal, 20)
                    .padding(.vertical, 16)
                    .background(Color(.systemGray6))
                    .cornerRadius(16)
                    .overlay(
                        RoundedRectangle(cornerRadius: 16)
                            .stroke(collectionName.isEmpty ? Color.clear : Color.reelEatsAccent, lineWidth: 2)
                    )
            }
            .padding(.horizontal, 24)
            
            coverCustomizationSection
        }
    }
    
    var coverCustomizationSection: some View {
        VStack(alignment: .leading, spacing: 20) {
            Text("Cover Design")
                .font(.newYorkButton())
                .foregroundColor(.secondary)
                .padding(.horizontal, 24)
            
            // Cover mode selector
            HStack(spacing: 16) {
                coverModeButton(mode: .image, title: "Upload Photo", icon: "photo.fill")
                coverModeButton(mode: .gradient, title: "Gradient + Emoji", icon: "paintpalette.fill")
            }
            .padding(.horizontal, 24)
            
            if coverMode == .gradient {
                gradientAndEmojiSection
            } else {
                imageUploadSection
            }
        }
    }
    
    func coverModeButton(mode: CoverMode, title: String, icon: String) -> some View {
        Button(action: {
            withAnimation(.easeInOut(duration: 0.3)) {
                coverMode = mode
            }
            HapticManager.shared.light()
        }) {
            VStack(spacing: 8) {
                ZStack {
                    Circle()
                        .fill(coverMode == mode ? Color.reelEatsAccent : Color(.systemGray5))
                        .frame(width: 50, height: 50)
                    
                    Image(systemName: icon)
                        .font(.newYorkButton(size: 20))
                        .foregroundColor(coverMode == mode ? .white : .secondary)
                }
                
                Text(title)
                    .font(.newYorkCaption())
                    .foregroundColor(coverMode == mode ? .primary : .secondary)
                    .multilineTextAlignment(.center)
            }
            .frame(maxWidth: .infinity)
        }
        .buttonStyle(PlainButtonStyle())
    }
    
    var gradientAndEmojiSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            // Gradient picker
            VStack(alignment: .leading, spacing: 12) {
                Text("Background Color")
                    .font(.newYorkCaption())
                    .foregroundColor(.secondary)
                    .padding(.horizontal, 24)
                
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 12) {
                        ForEach(0..<gradientOptions.count, id: \.self) { index in
                            gradientButton(for: index)
                        }
                    }
                    .padding(.horizontal, 24)
                }
            }
            
            // Emoji picker
            VStack(alignment: .leading, spacing: 12) {
                Text("Icon Emoji")
                    .font(.newYorkCaption())
                    .foregroundColor(.secondary)
                    .padding(.horizontal, 24)
                
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 12) {
                        ForEach(emojiOptions, id: \.self) { emoji in
                            emojiButton(emoji: emoji)
                        }
                    }
                    .padding(.horizontal, 24)
                }
            }
        }
    }
    
    var imageUploadSection: some View {
        VStack(spacing: 16) {
            PhotosPicker(selection: $selectedPhotoItem, matching: .images, photoLibrary: .shared()) {
                VStack(spacing: 12) {
                    if let selectedImage = selectedImage {
                        Image(uiImage: selectedImage)
                            .resizable()
                            .aspectRatio(contentMode: .fill)
                            .frame(width: 80, height: 80)
                            .clipped()
                            .cornerRadius(12)
                    } else {
                        Image(systemName: "photo.badge.plus")
                            .font(.newYorkButton(size: 32))
                            .foregroundColor(.reelEatsAccent)
                    }
                    
                    Text(selectedImage != nil ? "Change Photo" : "Choose from Gallery")
                        .font(.newYorkButton())
                        .foregroundColor(.reelEatsAccent)
                }
                .frame(maxWidth: .infinity)
                .padding(.vertical, 24)
                .background(Color(.systemGray6))
                .cornerRadius(16)
            }
            .padding(.horizontal, 24)
        }
    }
    
    private let emojiOptions = ["📍", "🍽️", "✨", "😍", "🎉", "❤️", "🔥", "🎆", "🌈", "🌎", "🎁", "💥", "🍕", "☕", "🍔", "🍜", "🍝", "🍺", "🍸", "🍰", "🍭", "🥙", "🍳", "🍴"]
    
    func emojiButton(emoji: String) -> some View {
        Button(action: {
            withAnimation(.easeInOut(duration: 0.2)) {
                selectedEmoji = emoji
            }
            HapticManager.shared.light()
        }) {
            Text(emoji)
                .font(.system(size: 28))
                .frame(width: 45, height: 45)
                .background(
                    Circle()
                        .fill(selectedEmoji == emoji ? Color.reelEatsAccent.opacity(0.2) : Color.clear)
                )
                .overlay(
                    Circle()
                        .stroke(selectedEmoji == emoji ? Color.reelEatsAccent : Color.clear, lineWidth: 2)
                )
        }
        .buttonStyle(PlainButtonStyle())
    }
    
    func gradientButton(for index: Int) -> some View {
        Button(action: {
            withAnimation(.easeInOut(duration: 0.3)) {
                selectedGradient = index
            }
            HapticManager.shared.light()
        }) {
            Circle()
                .fill(
                    LinearGradient(
                        colors: gradientOptions[index],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
                .frame(width: 45, height: 45)
                .overlay(
                    Circle()
                        .stroke(
                            selectedGradient == index ? Color.primary : Color.clear, 
                            lineWidth: 2
                        )
                )
                .shadow(
                    color: gradientOptions[index][0].opacity(0.4), 
                    radius: selectedGradient == index ? 6 : 3, 
                    x: 0, 
                    y: selectedGradient == index ? 3 : 1
                )
                .scaleEffect(selectedGradient == index ? 1.05 : 1.0)
                .animation(.spring(response: 0.4, dampingFraction: 0.8), value: selectedGradient == index)
        }
        .buttonStyle(PlainButtonStyle())
    }
    
    var actionSection: some View {
        VStack(spacing: 16) {
            Button(action: {
                if !collectionName.isEmpty {
                    HapticManager.shared.success()
                    store.createCollection(name: collectionName)
                    
                    if let onCollectionCreated = onCollectionCreated {
                        onCollectionCreated(collectionName)
                    } else {
                        dismiss()
                    }
                }
            }) {
                HStack {
                    Image(systemName: "folder.badge.plus")
                        .font(.newYorkButton(size: 18))
                    
                    Text("Create Collection")
                        .font(.newYorkButton(size: 18))
                }
                .foregroundColor(.white)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 18)
                .background(createButtonBackground)
                .cornerRadius(16)
                .shadow(
                    color: collectionName.isEmpty ? Color.clear : Color.reelEatsAccent.opacity(0.3), 
                    radius: 8, 
                    x: 0, 
                    y: 4
                )
            }
            .disabled(collectionName.isEmpty)
            .scaleEffect(collectionName.isEmpty ? 0.95 : 1.0)
            .animation(.easeInOut(duration: 0.2), value: collectionName.isEmpty)
            .padding(.horizontal, 24)
            
            if collectionName.isEmpty {
                Text("Enter a name to create your collection")
                    .font(.newYorkCaption())
                    .foregroundColor(.secondary)
            }
        }
        .padding(.top, 16)
    }
    
    var createButtonBackground: some ShapeStyle {
        if collectionName.isEmpty {
            return AnyShapeStyle(Color.gray.opacity(0.5))
        } else {
            return AnyShapeStyle(LinearGradient(
                colors: [Color.reelEatsAccent, Color.reelEatsAccent.opacity(0.8)],
                startPoint: .leading,
                endPoint: .trailing
            ))
        }
    }
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 32) {
                    headerSection
                    inputSection
                    actionSection
                }
                .padding(.bottom, 32)
            }
            .navigationTitle("")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") {
                        HapticManager.shared.light()
                        dismiss()
                    }
                    .font(.newYorkButton())
                    .foregroundColor(.secondary)
                }
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Done") {
                        if !collectionName.isEmpty {
                            HapticManager.shared.success()
                            store.createCollection(name: collectionName)
                            
                            if let onCollectionCreated = onCollectionCreated {
                                onCollectionCreated(collectionName)
                            } else {
                                dismiss()
                            }
                        }
                    }
                    .font(.newYorkButton())
                    .foregroundColor(collectionName.isEmpty ? .secondary : .reelEatsAccent)
                    .disabled(collectionName.isEmpty)
                }
            }
        }
        .onChange(of: selectedPhotoItem) { newItem in
            Task {
                if let newItem = newItem {
                    if let data = try? await newItem.loadTransferable(type: Data.self) {
                        if let uiImage = UIImage(data: data) {
                            selectedImage = uiImage
                        }
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
            MapPin(coordinate: CLLocationCoordinate2D(latitude: restaurant.latitude, longitude: restaurant.longitude))
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
                        .font(.clashDisplayRestaurantNameTemp(size: 20))
                        .foregroundColor(.primary)
                }
                
                Spacer()
                
                Text(restaurant.name)
                    .font(.poppinsRestaurantNameTemp(size: 18))
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
                                .font(.clashDisplayHeaderTemp(size: 32))
                                .foregroundColor(.white)
                            
                            Text(restaurant.description)
                                .font(.poppinsDescriptionTemp(size: 18))
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
                                .font(.clashDisplaySecondaryTemp())
                            Text(restaurant.tags.first ?? restaurant.category.rawValue)
                                .font(.clashDisplaySecondaryTemp())
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
                            .font(.clashDisplayBodyTemp(size: 18))
                            .foregroundColor(.secondary)
                        
                        Spacer()
                        
                        Text(restaurant.source.displayName)
                            .font(.clashDisplaySecondaryTemp())
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
                                .font(.clashDisplayHeaderTemp())
                                .foregroundColor(restaurant.category.color)
                            
                            Spacer()
                            
                            Button(action: {}) {
                                Image(systemName: "ellipsis")
                                    .font(.clashDisplayRestaurantNameTemp(size: 20))
                                    .foregroundColor(.secondary)
                            }
                        }
                        
                        Text(restaurant.name)
                            .font(.poppinsRestaurantNameTemp(size: 24))
                        
                        Text(restaurant.description)
                            .font(.poppinsDescriptionTemp(size: 16))
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
                                .font(.clashDisplayButtonTemp(size: 18))
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
                            .font(.clashDisplayCardTitleTemp(size: 20))
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
                .font(.clashDisplayHeaderTemp(size: 28))
            
            VStack(alignment: .leading, spacing: 8) {
                Text(title)
                    .font(.clashDisplayCardTitleTemp(size: 18))
                
                Text(description)
                    .font(.clashDisplayBodyTemp())
                    .foregroundColor(.secondary)
                    .fixedSize(horizontal: false, vertical: true)
            }
        }
    }
}

// MARK: - Star Rating View

struct StarRatingView: View {
    @Binding var rating: Double
    private let maxRating = 5
    
    var body: some View {
        HStack(spacing: 8) {
            ForEach(1...maxRating, id: \.self) { index in
                Button(action: {
                    HapticManager.shared.light()
                    rating = Double(index)
                }) {
                    Image(systemName: index <= Int(rating) ? "star.fill" : "star")
                        .font(.clashDisplayHeaderTemp(size: 24))
                        .foregroundColor(index <= Int(rating) ? .yellow : .gray.opacity(0.3))
                        .animation(.easeInOut(duration: 0.1), value: rating)
                }
            }
        }
    }
}

#Preview {
    RestaurantDetailView(restaurant: Melbourne.demoRestaurants[0])
        .environmentObject(RestaurantStore())
}