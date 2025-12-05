//
//  ZenFocusApp.swift
//  ZenFocus
//
//  A biometric-aware Pomodoro timer that adapts to your stress levels
//

import SwiftUI

@main
struct ZenFocusApp: App {
    @StateObject private var timerManager = TimerManager()
    @StateObject private var healthManager = HealthKitManager()
    @StateObject private var settingsManager = SettingsManager()
    
    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(timerManager)
                .environmentObject(healthManager)
                .environmentObject(settingsManager)
                .preferredColorScheme(settingsManager.isDarkMode ? .dark : nil)
        }
    }
}
