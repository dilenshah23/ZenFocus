//
//  TimerModels.swift
//  ZenFocus
//
//  Core data models for the timer system
//

import Foundation
import SwiftUI

// MARK: - Timer Phase
enum TimerPhase: String, CaseIterable, Codable {
    case focus = "Focus"
    case shortBreak = "Short Break"
    case longBreak = "Long Break"
    
    var displayName: String {
        rawValue
    }
    
    var icon: String {
        switch self {
        case .focus: return "brain.head.profile"
        case .shortBreak: return "cup.and.saucer.fill"
        case .longBreak: return "leaf.fill"
        }
    }
    
    var color: Color {
        switch self {
        case .focus: return .zenFocus
        case .shortBreak: return .zenBreak
        case .longBreak: return .zenRest
        }
    }
    
    var gradient: LinearGradient {
        switch self {
        case .focus: return ZenGradients.focusRing
        case .shortBreak: return ZenGradients.breakRing
        case .longBreak: return ZenGradients.restRing
        }
    }
    
    var encouragement: [String] {
        switch self {
        case .focus:
            return [
                "Deep work time 🧠",
                "You've got this!",
                "Stay in the zone",
                "One step at a time",
                "Focus on what matters"
            ]
        case .shortBreak:
            return [
                "Breathe and relax ☕",
                "Quick recharge",
                "Stretch a little",
                "Rest your eyes",
                "You earned this break"
            ]
        case .longBreak:
            return [
                "Time to fully recharge 🌿",
                "Take a proper break",
                "Move around a bit",
                "Refresh your mind",
                "Great progress today!"
            ]
        }
    }
    
    var randomEncouragement: String {
        encouragement.randomElement() ?? encouragement[0]
    }
}

// MARK: - Timer State
enum TimerState: String, Codable {
    case idle
    case running
    case paused
    case completed
}

// MARK: - Session
struct FocusSession: Identifiable, Codable {
    let id: UUID
    let startTime: Date
    var endTime: Date?
    let phase: TimerPhase
    let plannedDuration: TimeInterval
    var actualDuration: TimeInterval?
    var completed: Bool
    var averageHeartRate: Double?
    var stressLevel: StressLevel?
    var notes: String?
    
    init(
        id: UUID = UUID(),
        startTime: Date = Date(),
        endTime: Date? = nil,
        phase: TimerPhase,
        plannedDuration: TimeInterval,
        actualDuration: TimeInterval? = nil,
        completed: Bool = false,
        averageHeartRate: Double? = nil,
        stressLevel: StressLevel? = nil,
        notes: String? = nil
    ) {
        self.id = id
        self.startTime = startTime
        self.endTime = endTime
        self.phase = phase
        self.plannedDuration = plannedDuration
        self.actualDuration = actualDuration
        self.completed = completed
        self.averageHeartRate = averageHeartRate
        self.stressLevel = stressLevel
        self.notes = notes
    }
}

// MARK: - Stress Level
enum StressLevel: String, Codable, CaseIterable {
    case low
    case normal
    case elevated
    case high
    
    var displayName: String {
        rawValue.capitalized
    }
    
    var color: Color {
        switch self {
        case .low: return .zenHeartLow
        case .normal: return .zenHeartMedium
        case .elevated: return .zenHeartElevated
        case .high: return .zenHeartHigh
        }
    }
    
    var icon: String {
        switch self {
        case .low: return "heart.fill"
        case .normal: return "heart.fill"
        case .elevated: return "heart.fill"
        case .high: return "heart.fill"
        }
    }
    
    var recommendation: String {
        switch self {
        case .low:
            return "Your stress is low. Great time for deep focus!"
        case .normal:
            return "You're in a good state. Keep up the great work!"
        case .elevated:
            return "Consider a breathing exercise during your break."
        case .high:
            return "Your stress is elevated. A longer break might help."
        }
    }
    
    var suggestedBreakMultiplier: Double {
        switch self {
        case .low: return 1.0
        case .normal: return 1.0
        case .elevated: return 1.25
        case .high: return 1.5
        }
    }
    
    static func from(hrv: Double) -> StressLevel {
        // HRV-based stress estimation (simplified)
        // Higher HRV generally indicates lower stress
        switch hrv {
        case 70...: return .low
        case 50..<70: return .normal
        case 30..<50: return .elevated
        default: return .high
        }
    }
    
    static func from(heartRate: Double, restingHeartRate: Double) -> StressLevel {
        let ratio = heartRate / max(restingHeartRate, 50)
        switch ratio {
        case ..<1.1: return .low
        case 1.1..<1.3: return .normal
        case 1.3..<1.5: return .elevated
        default: return .high
        }
    }
}

// MARK: - Timer Preset
struct TimerPreset: Identifiable, Codable, Hashable {
    let id: UUID
    var name: String
    var focusDuration: TimeInterval // in seconds
    var shortBreakDuration: TimeInterval
    var longBreakDuration: TimeInterval
    var sessionsUntilLongBreak: Int
    var isDefault: Bool
    
    init(
        id: UUID = UUID(),
        name: String,
        focusDuration: TimeInterval,
        shortBreakDuration: TimeInterval,
        longBreakDuration: TimeInterval,
        sessionsUntilLongBreak: Int = 4,
        isDefault: Bool = false
    ) {
        self.id = id
        self.name = name
        self.focusDuration = focusDuration
        self.shortBreakDuration = shortBreakDuration
        self.longBreakDuration = longBreakDuration
        self.sessionsUntilLongBreak = sessionsUntilLongBreak
        self.isDefault = isDefault
    }
    
    // Default presets
    static let classic = TimerPreset(
        name: "Classic",
        focusDuration: 25 * 60,
        shortBreakDuration: 5 * 60,
        longBreakDuration: 15 * 60,
        sessionsUntilLongBreak: 4,
        isDefault: true
    )
    
    static let extended = TimerPreset(
        name: "Extended",
        focusDuration: 50 * 60,
        shortBreakDuration: 10 * 60,
        longBreakDuration: 30 * 60,
        sessionsUntilLongBreak: 2
    )
    
    static let quick = TimerPreset(
        name: "Quick",
        focusDuration: 15 * 60,
        shortBreakDuration: 3 * 60,
        longBreakDuration: 10 * 60,
        sessionsUntilLongBreak: 4
    )
    
    static let defaults: [TimerPreset] = [.classic, .extended, .quick]
}

// MARK: - Daily Stats
struct DailyStats: Codable, Identifiable {
    var id: Date { date }
    let date: Date
    var totalFocusTime: TimeInterval
    var completedSessions: Int
    var averageStressLevel: Double?
    var focusScore: Int? // 0-100
    
    init(
        date: Date = Calendar.current.startOfDay(for: Date()),
        totalFocusTime: TimeInterval = 0,
        completedSessions: Int = 0,
        averageStressLevel: Double? = nil,
        focusScore: Int? = nil
    ) {
        self.date = date
        self.totalFocusTime = totalFocusTime
        self.completedSessions = completedSessions
        self.averageStressLevel = averageStressLevel
        self.focusScore = focusScore
    }
}

// MARK: - Breathing Exercise
struct BreathingExercise: Identifiable, Codable {
    let id: UUID
    let name: String
    let description: String
    let inhale: TimeInterval
    let hold1: TimeInterval
    let exhale: TimeInterval
    let hold2: TimeInterval
    let cycles: Int
    let icon: String
    
    init(
        id: UUID = UUID(),
        name: String,
        description: String,
        inhale: TimeInterval,
        hold1: TimeInterval = 0,
        exhale: TimeInterval,
        hold2: TimeInterval = 0,
        cycles: Int = 4,
        icon: String = "wind"
    ) {
        self.id = id
        self.name = name
        self.description = description
        self.inhale = inhale
        self.hold1 = hold1
        self.exhale = exhale
        self.hold2 = hold2
        self.cycles = cycles
        self.icon = icon
    }
    
    var totalDuration: TimeInterval {
        Double(cycles) * (inhale + hold1 + exhale + hold2)
    }
    
    // Built-in exercises
    static let boxBreathing = BreathingExercise(
        name: "Box Breathing",
        description: "Equal counts for inhale, hold, exhale, hold. Great for calming anxiety.",
        inhale: 4,
        hold1: 4,
        exhale: 4,
        hold2: 4,
        cycles: 4,
        icon: "square"
    )
    
    static let relaxingBreath = BreathingExercise(
        name: "4-7-8 Relaxing",
        description: "Dr. Weil's relaxing breath technique. Perfect for stress relief.",
        inhale: 4,
        hold1: 7,
        exhale: 8,
        hold2: 0,
        cycles: 4,
        icon: "moon.stars"
    )
    
    static let coherentBreathing = BreathingExercise(
        name: "Coherent Breathing",
        description: "5 breaths per minute for heart-brain coherence.",
        inhale: 6,
        hold1: 0,
        exhale: 6,
        hold2: 0,
        cycles: 5,
        icon: "heart.circle"
    )
    
    static let energizingBreath = BreathingExercise(
        name: "Energizing Breath",
        description: "Shorter exhale to increase energy and alertness.",
        inhale: 4,
        hold1: 2,
        exhale: 2,
        hold2: 0,
        cycles: 6,
        icon: "bolt"
    )
    
    static let defaults: [BreathingExercise] = [
        .boxBreathing,
        .relaxingBreath,
        .coherentBreathing,
        .energizingBreath
    ]
}

// MARK: - Breathing Phase
enum BreathingPhase: String {
    case inhale = "Breathe In"
    case hold1 = "Hold"
    case exhale = "Breathe Out"
    case hold2 = "Hold"
    case complete = "Complete"
    
    var color: Color {
        switch self {
        case .inhale: return .zenFocus
        case .hold1, .hold2: return .zenBreak
        case .exhale: return .zenRest
        case .complete: return .zenSuccess
        }
    }
}

// MARK: - Ambient Sound
struct AmbientSound: Identifiable, Codable, Hashable {
    let id: UUID
    let name: String
    let icon: String
    let filename: String
    var isPremium: Bool
    
    init(
        id: UUID = UUID(),
        name: String,
        icon: String,
        filename: String,
        isPremium: Bool = false
    ) {
        self.id = id
        self.name = name
        self.icon = icon
        self.filename = filename
        self.isPremium = isPremium
    }
    
    static let silence = AmbientSound(name: "Silence", icon: "speaker.slash", filename: "")
    static let rain = AmbientSound(name: "Rain", icon: "cloud.rain", filename: "rain")
    static let ocean = AmbientSound(name: "Ocean", icon: "water.waves", filename: "ocean")
    static let forest = AmbientSound(name: "Forest", icon: "leaf", filename: "forest")
    static let fireplace = AmbientSound(name: "Fireplace", icon: "flame", filename: "fireplace", isPremium: true)
    static let whiteNoise = AmbientSound(name: "White Noise", icon: "waveform", filename: "whitenoise")
    static let cafe = AmbientSound(name: "Café", icon: "cup.and.saucer", filename: "cafe", isPremium: true)
    
    static let defaults: [AmbientSound] = [
        .silence, .rain, .ocean, .forest, .fireplace, .whiteNoise, .cafe
    ]
}
