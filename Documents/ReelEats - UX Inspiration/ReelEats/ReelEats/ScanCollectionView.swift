import SwiftUI

// MARK: - Scan Collection View (Placeholder for QR Code Scanning)

struct ScanCollectionView: View {
    @Environment(\.dismiss) private var dismiss
    @EnvironmentObject var store: RestaurantStore
    
    var body: some View {
        NavigationView {
            VStack(spacing: 30) {
                Spacer()
                
                // QR Code icon
                Image(systemName: "qrcode.viewfinder")
                    .font(.system(size: 80))
                    .foregroundColor(.orange)
                
                VStack(spacing: 16) {
                    Text("Scan Collection")
                        .font(.system(size: 24, weight: .bold))
                        .foregroundColor(.primary)
                    
                    Text("Coming Soon!")
                        .font(.system(size: 18, weight: .medium))
                        .foregroundColor(.secondary)
                    
                    Text("Point your camera at a friend's collection QR code to instantly add their favorite spots to your saved list.")
                        .font(.system(size: 16))
                        .foregroundColor(.secondary)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal, 40)
                }
                
                Spacer()
                
                // Close button
                Button(action: {
                    dismiss()
                }) {
                    Text("Close")
                        .font(.system(size: 18, weight: .semibold))
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 16)
                        .background(Color.black)
                        .cornerRadius(16)
                }
                .padding(.horizontal, 20)
                .padding(.bottom, 40)
            }
            .navigationTitle("Scan Collection")
            .navigationBarTitleDisplayMode(.inline)
            .navigationBarItems(
                trailing: Button("Close") {
                    dismiss()
                }
            )
        }
    }
}

#Preview {
    ScanCollectionView()
        .environmentObject(RestaurantStore())
}