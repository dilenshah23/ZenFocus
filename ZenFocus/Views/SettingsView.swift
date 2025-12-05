//
//  SettingsView.swift
//  ZenFocus
//
//  App settings and preferences
//

import SwiftUI

struct SettingsView: View {
    @EnvironmentObject var settingsManager: SettingsManager
    @EnvironmentObject var healthManager: HealthKitManager
    
    @State private var showPremiumSheet: Bool = false
    @State private var showAboutSheet: Bool = false
    
    @Environment(\.colorScheme) var colorScheme
    
    var body: some View {
        ScrollView {
            VStack(spacing: ZenSpacing.lg) {
                // Header
                headerSection
                
                // Premium Banner (if not premium)
                if !settingsManager.isPremium {
                    premiumBanner
                }
                
                // Settings Sections
                timerSettingsSection
                healthIntegrationSection
                appearanceSection
                notificationsSection
                aboutSection
                
                Spacer(minLength: 100) // Space for tab bar
            }
            .padding(.horizontal, ZenSpacing.lg)
        }
        .sheet(isPresented: $showPremiumSheet) {
            PremiumSheet(isPresented: $showPremiumSheet)
        }
        .sheet(isPresented: $showAboutSheet) {
            AboutSheet(isPresented: $showAboutSheet)
        }
    }
    
    // MARK: - Header
    private var headerSection: some View {
        HStack {
            VStack(alignment: .leading, spacing: ZenSpacing.xxs) {
                Text("Settings")
                    .font(ZenFont.title())
                    .foregroundColor(colorScheme == .dark ? .white : .zenTextPrimary)
                
                Text("Customize your experience")
                    .font(ZenFont.caption())
                    .foregroundColor(.zenTextSecondary)
            }
            
            Spacer()
        }
        .padding(.top, ZenSpacing.lg)
    }
    
    // MARK: - Premium Banner
    private var premiumBanner: some View {
        Button {
            showPremiumSheet = true
        } label: {
            HStack(spacing: ZenSpacing.md) {
                ZStack {
                    Circle()
                        .fill(
                            LinearGradient(
                                colors: [Color(hex: "FFD700"), Color(hex: "FFA500")],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                        .frame(width: 50, height: 50)
                    
                    Image(systemName: "crown.fill")
                        .font(.system(size: 24))
                        .foregroundColor(.white)
                }
                
                VStack(alignment: .leading, spacing: 2) {
                    Text("Upgrade to Premium")
                        .font(ZenFont.headline())
                        .foregroundColor(colorScheme == .dark ? .white : .zenTextPrimary)
                    
                    Text("Unlock all features & remove limits")
                        .font(ZenFont.caption())
                        .foregroundColor(.zenTextSecondary)
                }
                
                Spacer()
                
                Image(systemName: "chevron.right")
                    .foregroundColor(.zenTextMuted)
            }
            .padding(ZenSpacing.md)
            .background(
                RoundedRectangle(cornerRadius: ZenRadius.lg)
                    .fill(
                        LinearGradient(
                            colors: [
                                Color(hex: "FFD700").opacity(0.15),
                                Color(hex: "FFA500").opacity(0.1)
                            ],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .overlay(
                        RoundedRectangle(cornerRadius: ZenRadius.lg)
                            .stroke(Color(hex: "FFD700").opacity(0.3), lineWidth: 1)
                    )
            )
        }
    }
    
    // MARK: - Timer Settings
    private var timerSettingsSection: some View {
        settingsSection(title: "Timer", icon: "timer") {
            // Daily Goal
            settingsRow(
                title: "Daily Goal",
                subtitle: "\(settingsManager.dailyGoalMinutes) minutes",
                icon: "target"
            ) {
                Stepper(
                    "",
                    value: $settingsManager.dailyGoalMinutes,
                    in: 30...480,
                    step: 15
                )
                .labelsHidden()
            }
            
            // Auto-start breaks
            settingsToggle(
                title: "Auto-start Breaks",
                subtitle: "Automatically begin break timer",
                icon: "play.circle",
                isOn: $settingsManager.autoStartBreaks
            )
            
            // Auto-start focus
            settingsToggle(
                title: "Auto-start Focus",
                subtitle: "Automatically begin next focus session",
                icon: "arrow.clockwise",
                isOn: $settingsManager.autoStartFocus
            )
        }
    }
    
    // MARK: - Health Integration
    private var healthIntegrationSection: some View {
        settingsSection(title: "Health", icon: "heart.fill") {
            // HealthKit toggle
            settingsRow(
                title: "Apple Health",
                subtitle: healthManager.isAuthorized ? "Connected" : "Not connected",
                icon: "heart.text.square"
            ) {
                Toggle("", isOn: $settingsManager.healthKitEnabled)
                    .labelsHidden()
                    .tint(.zenFocus)
                    .onChange(of: settingsManager.healthKitEnabled) { enabled in
                        if enabled {
                            Task {
                                await healthManager.requestAuthorization()
                            }
                        }
                    }
            }
            
            if settingsManager.healthKitEnabled {
                // Stress-adaptive breaks
                settingsToggle(
                    title: "Smart Break Suggestions",
                    subtitle: "Adjust breaks based on stress level",
                    icon: "brain.head.profile",
                    isOn: $settingsManager.stressAdaptiveBreaks
                )
                
                // Show heart rate during focus
                settingsToggle(
                    title: "Show Heart Rate",
                    subtitle: "Display during focus sessions",
                    icon: "waveform.path.ecg",
                    isOn: $settingsManager.showHeartRateDuringFocus
                )
            }
        }
    }
    
    // MARK: - Appearance
    private var appearanceSection: some View {
        settingsSection(title: "Appearance", icon: "paintbrush.fill") {
            // Dark mode
            settingsToggle(
                title: "Dark Mode",
                subtitle: "Use dark theme",
                icon: "moon.fill",
                isOn: $settingsManager.isDarkMode
            )
            
            // Accent color
            settingsRow(
                title: "Accent Color",
                subtitle: nil,
                icon: "paintpalette"
            ) {
                HStack(spacing: ZenSpacing.xs) {
                    ForEach(0..<SettingsManager.accentColors.count, id: \.self) { index in
                        Circle()
                            .fill(SettingsManager.accentColors[index])
                            .frame(width: 28, height: 28)
                            .overlay(
                                Circle()
                                    .stroke(Color.white, lineWidth: settingsManager.accentColorIndex == index ? 2 : 0)
                            )
                            .shadow(color: settingsManager.accentColorIndex == index ? SettingsManager.accentColors[index].opacity(0.5) : .clear, radius: 4)
                            .onTapGesture {
                                settingsManager.accentColorIndex = index
                                ZenHaptics.selection()
                            }
                    }
                }
            }
        }
    }
    
    // MARK: - Notifications
    private var notificationsSection: some View {
        settingsSection(title: "Notifications", icon: "bell.fill") {
            settingsToggle(
                title: "Notifications",
                subtitle: "Session completion alerts",
                icon: "bell.badge",
                isOn: $settingsManager.notificationsEnabled
            )
            
            settingsToggle(
                title: "Sound",
                subtitle: "Play completion sounds",
                icon: "speaker.wave.2",
                isOn: $settingsManager.soundEnabled
            )
            
            settingsToggle(
                title: "Vibration",
                subtitle: "Haptic feedback",
                icon: "iphone.radiowaves.left.and.right",
                isOn: $settingsManager.vibrationEnabled
            )
        }
    }
    
    // MARK: - About
    private var aboutSection: some View {
        settingsSection(title: "About", icon: "info.circle.fill") {
            Button {
                showAboutSheet = true
            } label: {
                settingsRow(
                    title: "About ZenFocus",
                    subtitle: "Version 1.0.0",
                    icon: "info.circle"
                ) {
                    Image(systemName: "chevron.right")
                        .foregroundColor(.zenTextMuted)
                }
            }
            
            Link(destination: URL(string: "https://example.com/privacy")!) {
                settingsRow(
                    title: "Privacy Policy",
                    subtitle: nil,
                    icon: "hand.raised"
                ) {
                    Image(systemName: "arrow.up.right")
                        .foregroundColor(.zenTextMuted)
                }
            }
            
            Link(destination: URL(string: "https://example.com/terms")!) {
                settingsRow(
                    title: "Terms of Service",
                    subtitle: nil,
                    icon: "doc.text"
                ) {
                    Image(systemName: "arrow.up.right")
                        .foregroundColor(.zenTextMuted)
                }
            }
        }
    }
    
    // MARK: - Helper Views
    private func settingsSection<Content: View>(
        title: String,
        icon: String,
        @ViewBuilder content: () -> Content
    ) -> some View {
        VStack(alignment: .leading, spacing: ZenSpacing.sm) {
            HStack(spacing: ZenSpacing.xs) {
                Image(systemName: icon)
                    .foregroundColor(.zenFocus)
                    .font(.system(size: 14))
                
                Text(title)
                    .font(ZenFont.label())
                    .foregroundColor(.zenTextSecondary)
            }
            .padding(.leading, ZenSpacing.xs)
            
            VStack(spacing: 1) {
                content()
            }
            .background(
                RoundedRectangle(cornerRadius: ZenRadius.lg)
                    .fill(colorScheme == .dark ? Color.zenDarkSurface : Color.white)
            )
            .zenShadow(style: .soft)
        }
    }
    
    private func settingsRow<Content: View>(
        title: String,
        subtitle: String?,
        icon: String,
        @ViewBuilder trailing: () -> Content
    ) -> some View {
        HStack(spacing: ZenSpacing.md) {
            Image(systemName: icon)
                .font(.system(size: 18))
                .foregroundColor(.zenTextMuted)
                .frame(width: 24)
            
            VStack(alignment: .leading, spacing: 2) {
                Text(title)
                    .font(ZenFont.body())
                    .foregroundColor(colorScheme == .dark ? .white : .zenTextPrimary)
                
                if let subtitle = subtitle {
                    Text(subtitle)
                        .font(ZenFont.caption(12))
                        .foregroundColor(.zenTextMuted)
                }
            }
            
            Spacer()
            
            trailing()
        }
        .padding(ZenSpacing.md)
    }
    
    private func settingsToggle(
        title: String,
        subtitle: String?,
        icon: String,
        isOn: Binding<Bool>
    ) -> some View {
        settingsRow(title: title, subtitle: subtitle, icon: icon) {
            Toggle("", isOn: isOn)
                .labelsHidden()
                .tint(.zenFocus)
        }
    }
}

// MARK: - Premium Sheet
struct PremiumSheet: View {
    @Binding var isPresented: Bool
    @EnvironmentObject var settingsManager: SettingsManager
    @Environment(\.colorScheme) var colorScheme
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: ZenSpacing.xl) {
                    // Header
                    VStack(spacing: ZenSpacing.md) {
                        ZStack {
                            Circle()
                                .fill(
                                    LinearGradient(
                                        colors: [Color(hex: "FFD700"), Color(hex: "FFA500")],
                                        startPoint: .topLeading,
                                        endPoint: .bottomTrailing
                                    )
                                )
                                .frame(width: 100, height: 100)
                            
                            Image(systemName: "crown.fill")
                                .font(.system(size: 48))
                                .foregroundColor(.white)
                        }
                        
                        Text("ZenFocus Premium")
                            .font(ZenFont.title())
                            .foregroundColor(colorScheme == .dark ? .white : .zenTextPrimary)
                        
                        Text("Unlock the full experience")
                            .font(ZenFont.body())
                            .foregroundColor(.zenTextSecondary)
                    }
                    .padding(.top, ZenSpacing.xl)
                    
                    // Features
                    VStack(spacing: ZenSpacing.md) {
                        premiumFeature(icon: "timer", title: "Unlimited Custom Timers", description: "Create as many presets as you need")
                        premiumFeature(icon: "chart.bar.fill", title: "Advanced Analytics", description: "Detailed insights and trends")
                        premiumFeature(icon: "heart.fill", title: "Full Health Integration", description: "Complete biometric tracking")
                        premiumFeature(icon: "wind", title: "All Breathing Exercises", description: "Access every technique")
                        premiumFeature(icon: "speaker.wave.3.fill", title: "Premium Sounds", description: "Exclusive ambient soundscapes")
                        premiumFeature(icon: "applewatch", title: "Apple Watch App", description: "Control from your wrist")
                    }
                    .padding(.horizontal, ZenSpacing.lg)
                    
                    // Pricing
                    VStack(spacing: ZenSpacing.md) {
                        pricingOption(
                            title: "Annual",
                            price: "$29.99",
                            period: "per year",
                            savings: "Save 50%",
                            isPopular: true
                        )
                        
                        pricingOption(
                            title: "Monthly",
                            price: "$4.99",
                            period: "per month",
                            savings: nil,
                            isPopular: false
                        )
                        
                        pricingOption(
                            title: "Lifetime",
                            price: "$79.99",
                            period: "one-time",
                            savings: "Best Value",
                            isPopular: false
                        )
                    }
                    .padding(.horizontal, ZenSpacing.lg)
                    
                    // Restore purchases
                    Button("Restore Purchases") {
                        // Restore logic
                    }
                    .font(ZenFont.label())
                    .foregroundColor(.zenFocus)
                    
                    Spacer(minLength: ZenSpacing.xl)
                }
            }
            .background(colorScheme == .dark ? Color.zenDarkBackground : Color.zenGradientStart)
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Close") {
                        isPresented = false
                    }
                }
            }
        }
    }
    
    private func premiumFeature(icon: String, title: String, description: String) -> some View {
        HStack(spacing: ZenSpacing.md) {
            Image(systemName: icon)
                .font(.system(size: 22))
                .foregroundColor(.zenFocus)
                .frame(width: 40)
            
            VStack(alignment: .leading, spacing: 2) {
                Text(title)
                    .font(ZenFont.headline())
                    .foregroundColor(colorScheme == .dark ? .white : .zenTextPrimary)
                
                Text(description)
                    .font(ZenFont.caption())
                    .foregroundColor(.zenTextSecondary)
            }
            
            Spacer()
        }
    }
    
    private func pricingOption(
        title: String,
        price: String,
        period: String,
        savings: String?,
        isPopular: Bool
    ) -> some View {
        Button {
            // Purchase logic
        } label: {
            HStack {
                VStack(alignment: .leading, spacing: 2) {
                    HStack(spacing: ZenSpacing.xs) {
                        Text(title)
                            .font(ZenFont.headline())
                        
                        if isPopular {
                            Text("POPULAR")
                                .font(ZenFont.caption(10))
                                .foregroundColor(.white)
                                .padding(.horizontal, ZenSpacing.xs)
                                .padding(.vertical, 2)
                                .background(
                                    Capsule()
                                        .fill(Color.zenFocus)
                                )
                        }
                    }
                    
                    if let savings = savings {
                        Text(savings)
                            .font(ZenFont.caption())
                            .foregroundColor(.zenSuccess)
                    }
                }
                .foregroundColor(colorScheme == .dark ? .white : .zenTextPrimary)
                
                Spacer()
                
                VStack(alignment: .trailing, spacing: 0) {
                    Text(price)
                        .font(ZenFont.headline(20))
                        .foregroundColor(colorScheme == .dark ? .white : .zenTextPrimary)
                    
                    Text(period)
                        .font(ZenFont.caption())
                        .foregroundColor(.zenTextMuted)
                }
            }
            .padding(ZenSpacing.md)
            .background(
                RoundedRectangle(cornerRadius: ZenRadius.md)
                    .fill(colorScheme == .dark ? Color.zenDarkSurface : Color.white)
                    .overlay(
                        RoundedRectangle(cornerRadius: ZenRadius.md)
                            .stroke(isPopular ? Color.zenFocus : Color.clear, lineWidth: 2)
                    )
            )
            .zenShadow(style: .soft)
        }
    }
}

// MARK: - About Sheet
struct AboutSheet: View {
    @Binding var isPresented: Bool
    @Environment(\.colorScheme) var colorScheme
    
    var body: some View {
        NavigationView {
            VStack(spacing: ZenSpacing.xl) {
                Spacer()
                
                // App icon
                RoundedRectangle(cornerRadius: 24)
                    .fill(
                        LinearGradient(
                            colors: [Color.zenFocus, Color.zenFocus.opacity(0.7)],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .frame(width: 120, height: 120)
                    .overlay(
                        Image(systemName: "brain.head.profile")
                            .font(.system(size: 50))
                            .foregroundColor(.white)
                    )
                    .zenShadow(style: .elevated)
                
                VStack(spacing: ZenSpacing.xs) {
                    Text("ZenFocus")
                        .font(ZenFont.title(32))
                        .foregroundColor(colorScheme == .dark ? .white : .zenTextPrimary)
                    
                    Text("Version 1.0.0")
                        .font(ZenFont.caption())
                        .foregroundColor(.zenTextMuted)
                }
                
                Text("A mindful productivity timer that adapts to your stress levels, helping you focus better and recover smarter.")
                    .font(ZenFont.body())
                    .foregroundColor(.zenTextSecondary)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, ZenSpacing.xl)
                
                Spacer()
                
                VStack(spacing: ZenSpacing.sm) {
                    Text("Made with ❤️ for focused minds")
                        .font(ZenFont.caption())
                        .foregroundColor(.zenTextMuted)
                    
                    Text("© 2024 ZenFocus")
                        .font(ZenFont.caption(12))
                        .foregroundColor(.zenTextMuted)
                }
                .padding(.bottom, ZenSpacing.xl)
            }
            .background(colorScheme == .dark ? Color.zenDarkBackground : Color.zenGradientStart)
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Done") {
                        isPresented = false
                    }
                }
            }
        }
    }
}

// MARK: - Preview
#Preview {
    SettingsView()
        .environmentObject(SettingsManager())
        .environmentObject(HealthKitManager())
}
