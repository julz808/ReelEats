import SwiftUI
import Foundation

// This file is created directly in your Xcode project directory
// It should be automatically detected by Xcode

struct OnboardingCoordinator: View {
    @EnvironmentObject var store: RestaurantStore
    @State private var currentStep = 0
    
    var body: some View {
        ZStack {
            if currentStep == 0 {
                WelcomeScreen {
                    withAnimation(.easeInOut(duration: 0.5)) {
                        currentStep += 1
                    }
                }
            } else if currentStep == 1 {
                AuthScreen {
                    withAnimation(.easeInOut(duration: 0.5)) {
                        currentStep += 1
                    }
                }
            } else {
                PostOnboardingTutorialCoordinator()
                    .environmentObject(store)
            }
        }
    }
}

struct WelcomeScreen: View {
    let onNext: () -> Void
    @State private var isAnimating = false
    
    var body: some View {
        ZStack {
            LinearGradient(
                colors: [Color(.systemBackground), Color(.systemGray6)],
                startPoint: .top,
                endPoint: .bottom
            )
            .ignoresSafeArea()
            
            VStack(spacing: 50) {
                Spacer()
                
                // Animated ReelEats logo with mascot
                MascotView(size: 120)
                .scaleEffect(isAnimating ? 1.0 : 0.3)
                .rotationEffect(.degrees(isAnimating ? 0 : 180))
                .animation(.spring(response: 1.2, dampingFraction: 0.6), value: isAnimating)
                
                // Brand name with gradient
                VStack(spacing: 20) {
                    HStack(spacing: 6) {
                        Text("ReelEats")
                            .font(.system(size: 52, weight: .bold))
                            .foregroundStyle(
                                LinearGradient(
                                    colors: [.primary, .primary.opacity(0.7)],
                                    startPoint: .leading,
                                    endPoint: .trailing
                                )
                            )
                        
                        Text(".")
                            .font(.system(size: 52, weight: .bold))
                            .foregroundColor(.orange)
                    }
                    .opacity(isAnimating ? 1.0 : 0.0)
                    .offset(y: isAnimating ? 0 : 30)
                    .animation(.spring(response: 0.8, dampingFraction: 0.8).delay(0.4), value: isAnimating)
                    
                    Text("From feed to fed")
                        .font(.system(size: 22, weight: .medium))
                        .foregroundColor(.secondary)
                        .opacity(isAnimating ? 1.0 : 0.0)
                        .offset(y: isAnimating ? 0 : 20)
                        .animation(.spring(response: 0.8, dampingFraction: 0.8).delay(0.6), value: isAnimating)
                }
                
                Spacer()
                
                // Get Started button with premium feel
                Button(action: {
                    HapticManager.shared.medium()
                    onNext()
                }) {
                    Text("Get Started")
                        .font(.system(size: 19, weight: .semibold))
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .frame(height: 60)
                        .background(
                            LinearGradient(
                                colors: [Color.black, Color.black.opacity(0.8)],
                                startPoint: .top,
                                endPoint: .bottom
                            )
                        )
                        .cornerRadius(30)
                        .shadow(color: .black.opacity(0.3), radius: 10, x: 0, y: 5)
                }
                .padding(.horizontal, 32)
                .opacity(isAnimating ? 1.0 : 0.0)
                .offset(y: isAnimating ? 0 : 30)
                .animation(.spring(response: 0.8, dampingFraction: 0.8).delay(0.8), value: isAnimating)
                
                Spacer()
            }
        }
        .onAppear {
            withAnimation {
                isAnimating = true
            }
        }
    }
}

struct AuthScreen: View {
    let onNext: () -> Void
    @State private var isPresented = false
    
    var body: some View {
        ZStack {
            // Dimmed background
            Color.black.opacity(0.5)
                .ignoresSafeArea()
                .onTapGesture { /* dismiss */ }
            
            VStack {
                Spacer()
                
                // Authentication modal
                VStack(spacing: 36) {
                    VStack(spacing: 18) {
                        Text("Sign in to continue")
                            .font(.system(size: 28, weight: .bold))
                            .foregroundColor(.primary)
                        
                        Text("By continuing, you agree to our terms of service, privacy policy and marketing emails which you can unsubscribe at any time.")
                            .font(.system(size: 16))
                            .foregroundColor(.secondary)
                            .multilineTextAlignment(.center)
                            .lineSpacing(3)
                    }
                    
                    VStack(spacing: 18) {
                        // Continue with Apple
                        AuthButton(
                            title: "Continue with Apple",
                            icon: "applelogo",
                            backgroundColor: .black,
                            textColor: .white,
                            action: simulateAuth
                        )
                        
                        // Continue with Google
                        AuthButton(
                            title: "Continue with Google",
                            icon: "G",
                            backgroundColor: .white,
                            textColor: .black,
                            hasBorder: true,
                            action: simulateAuth
                        )
                    }
                }
                .padding(.top, 40)
                .padding(.horizontal, 36)
                .padding(.bottom, 50)
                .background(
                    RoundedRectangle(cornerRadius: 24)
                        .fill(Color(.systemBackground))
                        .shadow(color: .black.opacity(0.15), radius: 25, x: 0, y: 15)
                )
                .offset(y: isPresented ? 0 : 500)
                .animation(.spring(response: 0.7, dampingFraction: 0.8), value: isPresented)
            }
            .padding(.horizontal, 24)
        }
        .onAppear {
            withAnimation {
                isPresented = true
            }
        }
    }
    
    private func simulateAuth() {
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.8) {
            onNext()
        }
    }
}

struct AuthButton: View {
    let title: String
    let icon: String
    let backgroundColor: Color
    let textColor: Color
    let hasBorder: Bool
    let action: () -> Void
    @State private var isPressed = false
    
    init(title: String, icon: String, backgroundColor: Color, textColor: Color, hasBorder: Bool = false, action: @escaping () -> Void) {
        self.title = title
        self.icon = icon
        self.backgroundColor = backgroundColor
        self.textColor = textColor
        self.hasBorder = hasBorder
        self.action = action
    }
    
    var body: some View {
        Button(action: {
            HapticManager.shared.light()
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
                if icon == "G" {
                    Text("G")
                        .font(.system(size: 19, weight: .bold))
                        .foregroundColor(.black)
                        .frame(width: 22, height: 22)
                        .background(Color.white)
                        .clipShape(Circle())
                } else {
                    Image(systemName: icon)
                        .font(.system(size: 19, weight: .medium))
                        .foregroundColor(textColor)
                }
                
                Text(title)
                    .font(.system(size: 18, weight: .semibold))
                    .foregroundColor(textColor)
            }
            .frame(maxWidth: .infinity)
            .frame(height: 56)
            .background(
                RoundedRectangle(cornerRadius: 28)
                    .fill(backgroundColor)
                    .overlay(
                        hasBorder ? RoundedRectangle(cornerRadius: 28).stroke(Color.gray.opacity(0.3), lineWidth: 1) : nil
                    )
            )
            .scaleEffect(isPressed ? 0.97 : 1.0)
        }
    }
}

// MARK: - Mascot Component

struct MascotView: View {
    var size: CGFloat = 24
    
    var body: some View {
        Image("ReelEats mascot")
            .resizable()
            .aspectRatio(contentMode: .fit)
            .frame(width: size, height: size)
    }
}

#Preview {
    OnboardingCoordinator()
        .environmentObject(RestaurantStore())
}