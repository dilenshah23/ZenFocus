//
//  ContentView.swift
//  ZenFocus
//
//  Main tab-based navigation
//

import SwiftUI

struct ContentView: View {
    @EnvironmentObject var timerManager: TimerManager
    @EnvironmentObject var healthManager: HealthKitManager
    @EnvironmentObject var settingsManager: SettingsManager
    
    @State private var selectedTab: Tab = .timer
    @State private var showOnboarding: Bool = false
    
    @AppStorage("hasCompletedOnboarding") private var hasCompletedOnboarding: Bool = false
    
    enum Tab: String, CaseIterable {
        case timer = "Timer"
        case breathe = "Breathe"
        case stats = "Stats"
        case settings = "Settings"
        
        var icon: String {
            switch self {
            case .timer: return "timer"
            case .breathe: return "wind"
            case .stats: return "chart.bar.fill"
            case .settings: return "gearshape.fill"
            }
        }
        
        var selectedIcon: String {
            switch self {
            case .timer: return "timer"
            case .breathe: return "wind"
            case .stats: return "chart.bar.fill"
            case .settings: return "gearshape.fill"
            }
        }
    }
    
    var body: some View {
        ZStack {
            // Background
            backgroundGradient
                .ignoresSafeArea()
            
            // Main Content
            TabView(selection: $selectedTab) {
                TimerView()
                    .tag(Tab.timer)
                
                BreathingView()
                    .tag(Tab.breathe)
                
                StatsView()
                    .tag(Tab.stats)
                
                SettingsView()
                    .tag(Tab.settings)
            }
            .tabViewStyle(.page(indexDisplayMode: .never))
            
            // Custom Tab Bar
            VStack {
                Spacer()
                customTabBar
            }
        }
        .onAppear {
            if !hasCompletedOnboarding {
                showOnboarding = true
            }
        }
        .sheet(isPresented: $showOnboarding) {
            OnboardingView(isPresented: $showOnboarding)
        }
    }
    
    // MARK: - Background
    @ViewBuilder
    private var backgroundGradient: some View {
        if settingsManager.isDarkMode || colorScheme == .dark {
            ZenGradients.darkBackground
        } else {
            ZenGradients.warmBackground
        }
    }
    
    @Environment(\.colorScheme) var colorScheme
    
    // MARK: - Custom Tab Bar
    private var customTabBar: some View {
        HStack(spacing: 0) {
            ForEach(Tab.allCases, id: \.self) { tab in
                tabButton(for: tab)
            }
        }
        .padding(.horizontal, ZenSpacing.lg)
        .padding(.vertical, ZenSpacing.sm)
        .background(
            Capsule()
                .fill(colorScheme == .dark ? Color.zenDarkSurface : Color.white)
                .shadow(color: Color.black.opacity(0.1), radius: 20, x: 0, y: 5)
        )
        .padding(.horizontal, ZenSpacing.xl)
        .padding(.bottom, ZenSpacing.md)
    }
    
    private func tabButton(for tab: Tab) -> some View {
        Button {
            withAnimation(.zenSpring) {
                selectedTab = tab
            }
            ZenHaptics.selection()
        } label: {
            VStack(spacing: ZenSpacing.xxs) {
                Image(systemName: selectedTab == tab ? tab.selectedIcon : tab.icon)
                    .font(.system(size: 20, weight: selectedTab == tab ? .semibold : .regular))
                    .foregroundColor(selectedTab == tab ? settingsManager.accentColor : .zenTextMuted)
                    .scaleEffect(selectedTab == tab ? 1.1 : 1.0)
                
                Text(tab.rawValue)
                    .font(ZenFont.caption(11))
                    .foregroundColor(selectedTab == tab ? settingsManager.accentColor : .zenTextMuted)
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, ZenSpacing.xs)
        }
        .buttonStyle(.plain)
    }
}

// MARK: - Preview
#Preview {
    ContentView()
        .environmentObject(TimerManager())
        .environmentObject(HealthKitManager())
        .environmentObject(SettingsManager())
}
