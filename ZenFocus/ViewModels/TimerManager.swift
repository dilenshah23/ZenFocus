//
//  TimerManager.swift
//  ZenFocus
//
//  Core timer logic with stress-adaptive breaks
//

import Foundation
import SwiftUI
import Combine
import UserNotifications

@MainActor
class TimerManager: ObservableObject {
    // MARK: - Published Properties
    @Published var currentPhase: TimerPhase = .focus
    @Published var timerState: TimerState = .idle
    @Published var timeRemaining: TimeInterval = 25 * 60
    @Published var totalTime: TimeInterval = 25 * 60
    @Published var completedFocusSessions: Int = 0
    @Published var currentSessionNumber: Int = 1
    @Published var todaysTotalFocusTime: TimeInterval = 0
    @Published var currentPreset: TimerPreset = .classic
    @Published var currentStressLevel: StressLevel = .normal
    @Published var suggestedBreakExtension: TimeInterval = 0
    @Published var showBreakSuggestion: Bool = false
    
    // Session tracking
    @Published var sessions: [FocusSession] = []
    @Published var currentSession: FocusSession?
    
    // MARK: - Private Properties
    private var timer: Timer?
    private var sessionStartTime: Date?
    private var cancellables = Set<AnyCancellable>()
    
    // MARK: - Computed Properties
    var progress: Double {
        guard totalTime > 0 else { return 0 }
        return 1 - (timeRemaining / totalTime)
    }
    
    var timeRemainingFormatted: String {
        let minutes = Int(timeRemaining) / 60
        let seconds = Int(timeRemaining) % 60
        return String(format: "%02d:%02d", minutes, seconds)
    }
    
    var todaysFocusTimeFormatted: String {
        let hours = Int(todaysTotalFocusTime) / 3600
        let minutes = (Int(todaysTotalFocusTime) % 3600) / 60
        if hours > 0 {
            return "\(hours)h \(minutes)m"
        }
        return "\(minutes)m"
    }
    
    var isBreakPhase: Bool {
        currentPhase == .shortBreak || currentPhase == .longBreak
    }
    
    // MARK: - Initialization
    init() {
        loadTodaysData()
        requestNotificationPermission()
    }
    
    // MARK: - Timer Controls
    func start() {
        guard timerState != .running else { return }
        
        if timerState == .idle {
            // Starting fresh session
            sessionStartTime = Date()
            currentSession = FocusSession(
                phase: currentPhase,
                plannedDuration: totalTime
            )
        }
        
        timerState = .running
        ZenHaptics.medium()
        
        timer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { [weak self] _ in
            Task { @MainActor in
                self?.tick()
            }
        }
        
        // Make sure timer runs even when scrolling
        RunLoop.current.add(timer!, forMode: .common)
    }
    
    func pause() {
        guard timerState == .running else { return }
        
        timerState = .paused
        timer?.invalidate()
        timer = nil
        ZenHaptics.light()
    }
    
    func resume() {
        start()
    }
    
    func stop() {
        timer?.invalidate()
        timer = nil
        
        // Record the session if it was meaningful (at least 1 minute)
        if let session = currentSession,
           let startTime = sessionStartTime {
            let duration = Date().timeIntervalSince(startTime)
            if duration >= 60 {
                var completedSession = session
                completedSession.endTime = Date()
                completedSession.actualDuration = duration
                completedSession.completed = false
                completedSession.stressLevel = currentStressLevel
                sessions.append(completedSession)
                
                if currentPhase == .focus {
                    todaysTotalFocusTime += duration
                }
            }
        }
        
        resetToIdle()
        ZenHaptics.light()
    }
    
    func skip() {
        completeCurrentPhase()
        ZenHaptics.medium()
    }
    
    // MARK: - Preset Management
    func selectPreset(_ preset: TimerPreset) {
        guard timerState == .idle else { return }
        
        currentPreset = preset
        resetTimer(for: .focus)
        ZenHaptics.selection()
    }
    
    // MARK: - Stress-Adaptive Features
    func updateStressLevel(_ level: StressLevel) {
        currentStressLevel = level
        
        // Calculate suggested break extension based on stress
        if isBreakPhase {
            let baseBreakTime = currentPhase == .shortBreak 
                ? currentPreset.shortBreakDuration 
                : currentPreset.longBreakDuration
            
            let multiplier = level.suggestedBreakMultiplier
            suggestedBreakExtension = baseBreakTime * (multiplier - 1)
            
            if suggestedBreakExtension > 0 && timerState == .running {
                showBreakSuggestion = true
            }
        }
    }
    
    func acceptBreakExtension() {
        timeRemaining += suggestedBreakExtension
        totalTime += suggestedBreakExtension
        showBreakSuggestion = false
        suggestedBreakExtension = 0
        ZenHaptics.success()
    }
    
    func declineBreakExtension() {
        showBreakSuggestion = false
        suggestedBreakExtension = 0
    }
    
    // MARK: - Private Methods
    private func tick() {
        guard timerState == .running else { return }
        
        if timeRemaining > 0 {
            timeRemaining -= 1
            
            // Update focus time for focus sessions
            if currentPhase == .focus {
                todaysTotalFocusTime += 1
            }
        } else {
            completeCurrentPhase()
        }
    }
    
    private func completeCurrentPhase() {
        timer?.invalidate()
        timer = nil
        
        // Record completed session
        if let session = currentSession,
           let startTime = sessionStartTime {
            var completedSession = session
            completedSession.endTime = Date()
            completedSession.actualDuration = Date().timeIntervalSince(startTime)
            completedSession.completed = true
            completedSession.stressLevel = currentStressLevel
            sessions.append(completedSession)
        }
        
        ZenHaptics.success()
        sendCompletionNotification()
        
        // Determine next phase
        let nextPhase = determineNextPhase()
        transitionTo(nextPhase)
    }
    
    private func determineNextPhase() -> TimerPhase {
        switch currentPhase {
        case .focus:
            completedFocusSessions += 1
            if completedFocusSessions % currentPreset.sessionsUntilLongBreak == 0 {
                return .longBreak
            }
            return .shortBreak
            
        case .shortBreak, .longBreak:
            currentSessionNumber += 1
            return .focus
        }
    }
    
    private func transitionTo(_ phase: TimerPhase) {
        currentPhase = phase
        timerState = .completed
        resetTimer(for: phase)
        
        // Small delay before auto-showing the next phase
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) { [weak self] in
            self?.timerState = .idle
        }
    }
    
    private func resetTimer(for phase: TimerPhase) {
        switch phase {
        case .focus:
            totalTime = currentPreset.focusDuration
        case .shortBreak:
            totalTime = currentPreset.shortBreakDuration
        case .longBreak:
            totalTime = currentPreset.longBreakDuration
        }
        timeRemaining = totalTime
        currentSession = nil
        sessionStartTime = nil
    }
    
    private func resetToIdle() {
        timerState = .idle
        currentPhase = .focus
        resetTimer(for: .focus)
        currentSession = nil
        sessionStartTime = nil
    }
    
    // MARK: - Persistence
    private func loadTodaysData() {
        // Load today's sessions from UserDefaults
        let today = Calendar.current.startOfDay(for: Date())
        
        if let data = UserDefaults.standard.data(forKey: "sessions"),
           let savedSessions = try? JSONDecoder().decode([FocusSession].self, from: data) {
            sessions = savedSessions.filter { 
                Calendar.current.isDate($0.startTime, inSameDayAs: today)
            }
            
            todaysTotalFocusTime = sessions
                .filter { $0.phase == .focus && $0.completed }
                .compactMap { $0.actualDuration }
                .reduce(0, +)
            
            completedFocusSessions = sessions
                .filter { $0.phase == .focus && $0.completed }
                .count
        }
    }
    
    func saveSessions() {
        if let data = try? JSONEncoder().encode(sessions) {
            UserDefaults.standard.set(data, forKey: "sessions")
        }
    }
    
    // MARK: - Notifications
    private func requestNotificationPermission() {
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .sound, .badge]) { _, _ in }
    }
    
    private func sendCompletionNotification() {
        let content = UNMutableNotificationContent()
        
        switch currentPhase {
        case .focus:
            content.title = "Focus Session Complete! 🎉"
            content.body = "Great work! Time for a break."
        case .shortBreak:
            content.title = "Break Over"
            content.body = "Ready to focus again?"
        case .longBreak:
            content.title = "Long Break Complete"
            content.body = "Feeling refreshed? Let's go!"
        }
        
        content.sound = .default
        
        let request = UNNotificationRequest(
            identifier: UUID().uuidString,
            content: content,
            trigger: nil
        )
        
        UNUserNotificationCenter.current().add(request)
    }
}
