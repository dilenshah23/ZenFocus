//
//  OnboardingView.swift
//  ZenFocus
//
//  Beautiful onboarding experience for new users
//

import SwiftUI

struct OnboardingView: View {
    @Binding var isPresented: Bool
    @EnvironmentObject var healthManager: HealthKitManager
    @EnvironmentObject var settingsManager: SettingsManager
    
    @State private var currentPage: Int = 0
    @AppStorage("hasCompletedOnboarding") private var hasCompletedOnboarding: Bool = false
    
    var body: some View {
        ZStack {
            // Background gradient
            LinearGradient(
                colors: backgroundColors,
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .ignoresSafeArea()
            .animation(.easeInOut(duration: 0.5), value: currentPage)
            
            VStack(spacing: 0) {
                // Skip button
                HStack {
                    Spacer()
                    Button("Skip") {
                        completeOnboarding()
                    }
                    .font(ZenFont.label())
                    .foregroundColor(.white.opacity(0.8))
                    .padding()
                }
                
                // Page content
                TabView(selection: $currentPage) {
                    welcomePage.tag(0)
                    focusPage.tag(1)
                    breathePage.tag(2)
                    healthPage.tag(3)
                    readyPage.tag(4)
                }
                .tabViewStyle(.page(indexDisplayMode: .never))
                
                // Page indicators
                HStack(spacing: ZenSpacing.sm) {
                    ForEach(0..<5) { index in
                        Circle()
                            .fill(currentPage == index ? Color.white : Color.white.opacity(0.4))
                            .frame(width: 8, height: 8)
                            .scaleEffect(currentPage == index ? 1.2 : 1.0)
                            .animation(.zenSpring, value: currentPage)
                    }
                }
                .padding(.bottom, ZenSpacing.lg)
                
                // Action button
                actionButton
                    .padding(.horizontal, ZenSpacing.xl)
                    .padding(.bottom, ZenSpacing.xxl)
            }
        }
    }
    
    // MARK: - Background Colors
    private var backgroundColors: [Color] {
        switch currentPage {
        case 0: return [Color(hex: "5B8A72"), Color(hex: "3D6B5C")] // Sage
        case 1: return [Color(hex: "E8985E"), Color(hex: "C77B47")] // Terracotta
        case 2: return [Color(hex: "7BA3C9"), Color(hex: "5A87B0")] // Blue
        case 3: return [Color(hex: "D4726A"), Color(hex: "B85A52")] // Coral
        case 4: return [Color(hex: "5B8A72"), Color(hex: "3D6B5C")] // Sage
        default: return [Color.zenFocus, Color.zenFocus.opacity(0.8)]
        }
    }
    
    // MARK: - Pages
    private var welcomePage: some View {
        OnboardingPage(
            icon: "brain.head.profile",
            title: "Welcome to ZenFocus",
            subtitle: "A smarter way to focus",
            description: "Combine the power of the Pomodoro technique with biometric awareness to work better, not harder."
        )
    }
    
    private var focusPage: some View {
        OnboardingPage(
            icon: "timer",
            title: "Focus Smarter",
            subtitle: "Structured productivity",
            description: "Work in focused intervals with strategic breaks. Track your sessions and build momentum day after day."
        )
    }
    
    private var breathePage: some View {
        OnboardingPage(
            icon: "wind",
            title: "Breathe & Recover",
            subtitle: "Guided relaxation",
            description: "During breaks, access guided breathing exercises to reduce stress and prepare for your next focus session."
        )
    }
    
    private var healthPage: some View {
        OnboardingPage(
            icon: "heart.fill",
            title: "Stress-Aware Breaks",
            subtitle: "Connect your Apple Watch",
            description: "ZenFocus monitors your heart rate and HRV to suggest optimal break lengths based on your actual stress levels."
        )
    }
    
    private var readyPage: some View {
        OnboardingPage(
            icon: "sparkles",
            title: "You're All Set!",
            subtitle: "Let's begin",
            description: "Start your first focus session and experience the difference of mindful productivity."
        )
    }
    
    // MARK: - Action Button
    private var actionButton: some View {
        Button {
            handleAction()
        } label: {
            Text(buttonText)
                .font(ZenFont.headline())
                .foregroundColor(buttonTextColor)
                .frame(maxWidth: .infinity)
                .padding(.vertical, ZenSpacing.md)
                .background(
                    RoundedRectangle(cornerRadius: ZenRadius.full)
                        .fill(Color.white)
                )
        }
    }
    
    private var buttonText: String {
        switch currentPage {
        case 3: return healthManager.isAuthorized ? "Continue" : "Connect Apple Health"
        case 4: return "Get Started"
        default: return "Continue"
        }
    }
    
    private var buttonTextColor: Color {
        switch currentPage {
        case 0, 4: return Color(hex: "5B8A72")
        case 1: return Color(hex: "E8985E")
        case 2: return Color(hex: "7BA3C9")
        case 3: return Color(hex: "D4726A")
        default: return .zenFocus
        }
    }
    
    private func handleAction() {
        ZenHaptics.medium()
        
        if currentPage == 3 && !healthManager.isAuthorized {
            // Request health authorization
            Task {
                await healthManager.requestAuthorization()
                settingsManager.healthKitEnabled = true
            }
        }
        
        if currentPage < 4 {
            withAnimation(.zenSpring) {
                currentPage += 1
            }
        } else {
            completeOnboarding()
        }
    }
    
    private func completeOnboarding() {
        hasCompletedOnboarding = true
        isPresented = false
        ZenHaptics.success()
    }
}

// MARK: - Onboarding Page
struct OnboardingPage: View {
    let icon: String
    let title: String
    let subtitle: String
    let description: String
    
    @State private var isAnimated: Bool = false
    
    var body: some View {
        VStack(spacing: ZenSpacing.xl) {
            Spacer()
            
            // Icon
            ZStack {
                Circle()
                    .fill(Color.white.opacity(0.2))
                    .frame(width: 180, height: 180)
                    .scaleEffect(isAnimated ? 1.0 : 0.8)
                
                Circle()
                    .fill(Color.white.opacity(0.1))
                    .frame(width: 220, height: 220)
                    .scaleEffect(isAnimated ? 1.0 : 0.9)
                
                Image(systemName: icon)
                    .font(.system(size: 80, weight: .light))
                    .foregroundColor(.white)
                    .scaleEffect(isAnimated ? 1.0 : 0.5)
            }
            .animation(.zenBounce.delay(0.2), value: isAnimated)
            
            // Text content
            VStack(spacing: ZenSpacing.md) {
                Text(subtitle.uppercased())
                    .font(ZenFont.caption(14))
                    .foregroundColor(.white.opacity(0.8))
                    .tracking(2)
                    .opacity(isAnimated ? 1.0 : 0)
                    .offset(y: isAnimated ? 0 : 20)
                
                Text(title)
                    .font(ZenFont.title(32))
                    .foregroundColor(.white)
                    .multilineTextAlignment(.center)
                    .opacity(isAnimated ? 1.0 : 0)
                    .offset(y: isAnimated ? 0 : 20)
                
                Text(description)
                    .font(ZenFont.body())
                    .foregroundColor(.white.opacity(0.9))
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, ZenSpacing.xl)
                    .opacity(isAnimated ? 1.0 : 0)
                    .offset(y: isAnimated ? 0 : 20)
            }
            .animation(.zenSmooth.delay(0.3), value: isAnimated)
            
            Spacer()
            Spacer()
        }
        .onAppear {
            isAnimated = true
        }
        .onDisappear {
            isAnimated = false
        }
    }
}

// MARK: - Preview
#Preview {
    OnboardingView(isPresented: .constant(true))
        .environmentObject(HealthKitManager())
        .environmentObject(SettingsManager())
}
