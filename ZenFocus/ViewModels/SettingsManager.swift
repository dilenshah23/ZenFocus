//
//  SettingsManager.swift
//  ZenFocus
//
//  User preferences and settings management
//

import Foundation
import SwiftUI
import Combine

@MainActor
class SettingsManager: ObservableObject {
    // MARK: - Appearance
    @AppStorage("isDarkMode") var isDarkMode: Bool = false
    @AppStorage("useSystemAppearance") var useSystemAppearance: Bool = true
    @AppStorage("accentColorIndex") var accentColorIndex: Int = 0
    
    // MARK: - Timer Settings
    @AppStorage("autoStartBreaks") var autoStartBreaks: Bool = false
    @AppStorage("autoStartFocus") var autoStartFocus: Bool = false
    @AppStorage("showTimeInStatusBar") var showTimeInStatusBar: Bool = true
    
    // MARK: - Notifications
    @AppStorage("notificationsEnabled") var notificationsEnabled: Bool = true
    @AppStorage("soundEnabled") var soundEnabled: Bool = true
    @AppStorage("vibrationEnabled") var vibrationEnabled: Bool = true
    
    // MARK: - Health Integration
    @AppStorage("healthKitEnabled") var healthKitEnabled: Bool = false
    @AppStorage("stressAdaptiveBreaks") var stressAdaptiveBreaks: Bool = true
    @AppStorage("showHeartRateDuringFocus") var showHeartRateDuringFocus: Bool = false
    
    // MARK: - Breathing Exercises
    @AppStorage("suggestBreathingOnBreak") var suggestBreathingOnBreak: Bool = true
    @AppStorage("preferredBreathingExerciseId") var preferredBreathingExerciseId: String = ""
    
    // MARK: - Sound Settings
    @AppStorage("selectedAmbientSoundId") var selectedAmbientSoundId: String = ""
    @AppStorage("ambientSoundVolume") var ambientSoundVolume: Double = 0.5
    @AppStorage("playTickingSound") var playTickingSound: Bool = false
    
    // MARK: - Premium
    @AppStorage("isPremium") var isPremium: Bool = false
    @AppStorage("premiumPurchaseDate") var premiumPurchaseDate: Date?
    
    // MARK: - Statistics
    @AppStorage("dailyGoalMinutes") var dailyGoalMinutes: Int = 120
    @AppStorage("weeklyGoalDays") var weeklyGoalDays: Int = 5
    
    // MARK: - Presets
    @Published var customPresets: [TimerPreset] = []
    
    // MARK: - Accent Colors
    static let accentColors: [Color] = [
        .zenFocus,      // Sage green (default)
        .zenBreak,      // Terracotta
        .zenRest,       // Calm blue
        Color(hex: "9B7EBD"), // Lavender
        Color(hex: "E8A87C"), // Peach
        Color(hex: "85CDCA"), // Teal
    ]
    
    var accentColor: Color {
        Self.accentColors[safe: accentColorIndex] ?? .zenFocus
    }
    
    // MARK: - Initialization
    init() {
        loadCustomPresets()
    }
    
    // MARK: - Preset Management
    func savePreset(_ preset: TimerPreset) {
        if let index = customPresets.firstIndex(where: { $0.id == preset.id }) {
            customPresets[index] = preset
        } else {
            customPresets.append(preset)
        }
        saveCustomPresets()
    }
    
    func deletePreset(_ preset: TimerPreset) {
        customPresets.removeAll { $0.id == preset.id }
        saveCustomPresets()
    }
    
    var allPresets: [TimerPreset] {
        TimerPreset.defaults + customPresets
    }
    
    private func loadCustomPresets() {
        if let data = UserDefaults.standard.data(forKey: "customPresets"),
           let presets = try? JSONDecoder().decode([TimerPreset].self, from: data) {
            customPresets = presets
        }
    }
    
    private func saveCustomPresets() {
        if let data = try? JSONEncoder().encode(customPresets) {
            UserDefaults.standard.set(data, forKey: "customPresets")
        }
    }
    
    // MARK: - Reset
    func resetToDefaults() {
        isDarkMode = false
        useSystemAppearance = true
        accentColorIndex = 0
        autoStartBreaks = false
        autoStartFocus = false
        showTimeInStatusBar = true
        notificationsEnabled = true
        soundEnabled = true
        vibrationEnabled = true
        healthKitEnabled = false
        stressAdaptiveBreaks = true
        showHeartRateDuringFocus = false
        suggestBreathingOnBreak = true
        preferredBreathingExerciseId = ""
        selectedAmbientSoundId = ""
        ambientSoundVolume = 0.5
        playTickingSound = false
        dailyGoalMinutes = 120
        weeklyGoalDays = 5
    }
}

// MARK: - Array Extension
extension Array {
    subscript(safe index: Index) -> Element? {
        return indices.contains(index) ? self[index] : nil
    }
}
