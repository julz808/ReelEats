import SwiftUI

struct PremiumPaywallView: View {
    @Environment(\.dismiss) var dismiss
    @State private var selectedPlan: PricingPlan = .annual

    enum PricingPlan {
        case monthly
        case annual
    }

    var body: some View {
        ZStack {
            // Background
            Color(.systemBackground)
                .ignoresSafeArea()

            VStack(spacing: 0) {
                // Close button
                HStack {
                    Spacer()
                    Button(action: {
                        dismiss()
                    }) {
                        Image(systemName: "xmark")
                            .font(.system(size: 16, weight: .medium))
                            .foregroundColor(.primary)
                            .frame(width: 30, height: 30)
                            .background(Color(.systemGray5))
                            .clipShape(Circle())
                    }
                    .padding(.trailing, 20)
                    .padding(.top, 20)
                }

                VStack(spacing: 16) {
                    // Crown icon
                    ZStack {
                        Circle()
                            .fill(Color.reelEatsAccent.opacity(0.15))
                            .frame(width: 80, height: 80)

                        Image(systemName: "crown.fill")
                            .font(.system(size: 34))
                            .foregroundColor(.reelEatsAccent)
                    }
                    .padding(.top, 4)

                    // Headline
                    Text("You've reached your free limit")
                        .font(.newYorkHeader(size: 24))
                        .foregroundColor(.primary)
                        .multilineTextAlignment(.center)
                        .lineLimit(nil)
                        .fixedSize(horizontal: false, vertical: true)
                        .padding(.horizontal, 32)

                    // Subheadline
                    Text("Upgrade to Premium for unlimited spots and collections")
                        .font(.newYorkBody(size: 16))
                        .foregroundColor(.secondary)
                        .multilineTextAlignment(.center)
                        .lineSpacing(2)
                        .lineLimit(nil)
                        .fixedSize(horizontal: false, vertical: true)
                        .padding(.horizontal, 32)

                    // Benefits section
                    VStack(alignment: .leading, spacing: 12) {
                        HStack(spacing: 12) {
                            Image(systemName: "square.and.arrow.down.fill")
                                .font(.system(size: 18))
                                .foregroundColor(.reelEatsAccent)
                                .frame(width: 22)

                            Text("Unlimited imports of spots")
                                .font(.newYorkButton(size: 15))
                                .foregroundColor(.primary)
                                .lineLimit(nil)
                                .fixedSize(horizontal: false, vertical: true)
                        }

                        HStack(spacing: 12) {
                            Image(systemName: "plus.circle.fill")
                                .font(.system(size: 18))
                                .foregroundColor(.reelEatsAccent)
                                .frame(width: 22)

                            Text("Unlimited adding of spots")
                                .font(.newYorkButton(size: 15))
                                .foregroundColor(.primary)
                                .lineLimit(nil)
                                .fixedSize(horizontal: false, vertical: true)
                        }

                        HStack(spacing: 12) {
                            Image(systemName: "list.bullet.rectangle.portrait.fill")
                                .font(.system(size: 18))
                                .foregroundColor(.reelEatsAccent)
                                .frame(width: 22)

                            Text("Unlimited collections")
                                .font(.newYorkButton(size: 15))
                                .foregroundColor(.primary)
                                .lineLimit(nil)
                                .fixedSize(horizontal: false, vertical: true)
                        }
                    }
                    .padding(.horizontal, 32)
                    .padding(.top, 2)

                    // Free plan info text
                    Text("You can choose to remain on the free plan, however you will only be able to add 3 spots each week.")
                        .font(.newYorkSecondary(size: 12))
                        .foregroundColor(.secondary)
                        .multilineTextAlignment(.center)
                        .lineSpacing(2)
                        .lineLimit(nil)
                        .fixedSize(horizontal: false, vertical: true)
                        .padding(.horizontal, 36)
                        .padding(.top, 4)

                    // Pricing options
                    VStack(spacing: 8) {
                        // Annual plan
                        Button(action: {
                            selectedPlan = .annual
                        }) {
                            HStack {
                                VStack(alignment: .leading, spacing: 2) {
                                    Text("Annual")
                                        .font(.newYorkButton(size: 14))
                                        .foregroundColor(.primary)

                                    HStack(spacing: 4) {
                                        Text("$47.88")
                                            .font(.newYorkSecondary(size: 10))
                                            .foregroundColor(.secondary)
                                            .strikethrough()

                                        Text("Save $17.89")
                                            .font(.newYorkSecondary(size: 10))
                                            .foregroundColor(.reelEatsAccent)
                                    }
                                }

                                Spacer()

                                Text("$29.99")
                                    .font(.newYorkHeader(size: 22))
                                    .foregroundColor(.primary)

                                // Selection indicator
                                Image(systemName: selectedPlan == .annual ? "checkmark.circle.fill" : "circle")
                                    .font(.system(size: 20))
                                    .foregroundColor(selectedPlan == .annual ? .reelEatsAccent : Color(.systemGray4))
                            }
                            .padding(12)
                            .background(Color(.systemGray6))
                            .cornerRadius(12)
                            .overlay(
                                RoundedRectangle(cornerRadius: 12)
                                    .stroke(selectedPlan == .annual ? Color.reelEatsAccent : Color.clear, lineWidth: 2)
                            )
                        }
                        .buttonStyle(PlainButtonStyle())

                        // Monthly plan
                        Button(action: {
                            selectedPlan = .monthly
                        }) {
                            HStack {
                                VStack(alignment: .leading, spacing: 2) {
                                    Text("Monthly")
                                        .font(.newYorkButton(size: 14))
                                        .foregroundColor(.primary)
                                }

                                Spacer()

                                Text("$3.99")
                                    .font(.newYorkHeader(size: 22))
                                    .foregroundColor(.primary)

                                // Selection indicator
                                Image(systemName: selectedPlan == .monthly ? "checkmark.circle.fill" : "circle")
                                    .font(.system(size: 20))
                                    .foregroundColor(selectedPlan == .monthly ? .reelEatsAccent : Color(.systemGray4))
                            }
                            .padding(12)
                            .background(Color(.systemGray6))
                            .cornerRadius(12)
                            .overlay(
                                RoundedRectangle(cornerRadius: 12)
                                    .stroke(selectedPlan == .monthly ? Color.reelEatsAccent : Color.clear, lineWidth: 2)
                            )
                        }
                        .buttonStyle(PlainButtonStyle())
                    }
                    .padding(.horizontal, 32)
                    .padding(.top, 8)

                    // Cancel anytime text
                    Text("Cancel anytime")
                        .font(.newYorkSecondary(size: 11))
                        .foregroundColor(.secondary)
                        .padding(.top, 3)

                    Spacer()

                    // CTA Button
                    Button(action: {
                        // Mock action - just dismiss for now
                        dismiss()
                    }) {
                        HStack(spacing: 8) {
                            Text("Upgrade to Premium")
                                .font(.newYorkButton(size: 18))
                                .foregroundColor(.white)

                            Image(systemName: "arrow.right")
                                .font(.system(size: 15, weight: .semibold))
                                .foregroundColor(.white)
                        }
                        .frame(maxWidth: .infinity)
                        .frame(height: 54)
                        .background(Color.black)
                        .cornerRadius(14)
                    }
                    .padding(.horizontal, 32)

                    // Maybe later button
                    Button(action: {
                        dismiss()
                    }) {
                        Text("Maybe later")
                            .font(.newYorkButton(size: 15))
                            .foregroundColor(.secondary)
                    }
                    .padding(.bottom, 28)
                }
            }
        }
    }
}

#Preview {
    PremiumPaywallView()
}
