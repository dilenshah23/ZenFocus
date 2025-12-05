//
//  BreathingView.swift
//  ZenFocus
//
//  Guided breathing exercises with visual feedback
//

import SwiftUI

struct BreathingView: View {
    @EnvironmentObject var healthManager: HealthKitManager
    @EnvironmentObject var settingsManager: SettingsManager
    
    @State private var selectedExercise: BreathingExercise = .boxBreathing
    @State private var isBreathing: Bool = false
    @State private var currentPhase: BreathingPhase = .inhale
    @State private var phaseProgress: Double = 0
    @State private var currentCycle: Int = 1
    @State private var breathScale: CGFloat = 0.6
    @State private var showExercisePicker: Bool = false
    
    @Environment(\.colorScheme) var colorScheme
    
    private let breathingTimer = Timer.publish(every: 0.05, on: .main, in: .common).autoconnect()
    
    var body: some View {
        VStack(spacing: 0) {
            // Header
            headerSection
            
            Spacer()
            
            // Breathing Circle
            breathingCircle
            
            Spacer()
            
            // Instructions
            instructionsSection
            
            // Controls
            controlsSection
                .padding(.bottom, 100) // Space for tab bar
        }
        .padding(.horizontal, ZenSpacing.lg)
        .sheet(isPresented: $showExercisePicker) {
            ExercisePickerSheet(
                isPresented: $showExercisePicker,
                selectedExercise: $selectedExercise
            )
        }
        .onReceive(breathingTimer) { _ in
            if isBreathing {
                updateBreathing()
            }
        }
    }
    
    // MARK: - Header
    private var headerSection: some View {
        VStack(spacing: ZenSpacing.sm) {
            HStack {
                VStack(alignment: .leading, spacing: ZenSpacing.xxs) {
                    Text("Breathe")
                        .font(ZenFont.title())
                        .foregroundColor(colorScheme == .dark ? .white : .zenTextPrimary)
                    
                    Text("Take a moment to relax")
                        .font(ZenFont.caption())
                        .foregroundColor(.zenTextSecondary)
                }
                
                Spacer()
                
                // Heart rate (if available)
                if settingsManager.healthKitEnabled && healthManager.currentHeartRate > 0 {
                    HStack(spacing: ZenSpacing.xs) {
                        Image(systemName: "heart.fill")
                            .foregroundColor(.zenHeartMedium)
                        Text("\(Int(healthManager.currentHeartRate))")
                            .font(ZenFont.mono())
                    }
                    .padding(.horizontal, ZenSpacing.md)
                    .padding(.vertical, ZenSpacing.xs)
                    .background(
                        Capsule()
                            .fill(colorScheme == .dark ? Color.zenDarkSurface : Color.white)
                    )
                }
            }
            .padding(.top, ZenSpacing.lg)
        }
    }
    
    // MARK: - Breathing Circle
    private var breathingCircle: some View {
        ZStack {
            // Outer glow
            Circle()
                .fill(currentPhase.color.opacity(0.15))
                .frame(width: 320, height: 320)
                .blur(radius: 40)
            
            // Animated breathing circle
            Circle()
                .fill(
                    RadialGradient(
                        colors: [
                            currentPhase.color.opacity(0.3),
                            currentPhase.color.opacity(0.1)
                        ],
                        center: .center,
                        startRadius: 0,
                        endRadius: 140
                    )
                )
                .frame(width: 280 * breathScale, height: 280 * breathScale)
                .animation(.easeInOut(duration: getCurrentPhaseDuration()), value: breathScale)
            
            // Inner circle with instruction
            VStack(spacing: ZenSpacing.md) {
                Text(currentPhase.rawValue)
                    .font(ZenFont.headline(24))
                    .foregroundColor(colorScheme == .dark ? .white : .zenTextPrimary)
                
                if isBreathing {
                    Text("\(Int(ceil(getRemainingTime())))")
                        .font(ZenFont.display(48))
                        .foregroundColor(currentPhase.color)
                        .monospacedDigit()
                        .contentTransition(.numericText())
                }
                
                if isBreathing {
                    Text("Cycle \(currentCycle) of \(selectedExercise.cycles)")
                        .font(ZenFont.caption())
                        .foregroundColor(.zenTextMuted)
                }
            }
            .frame(width: 180, height: 180)
            .background(
                Circle()
                    .fill(colorScheme == .dark ? Color.zenDarkSurface : Color.white)
            )
            .zenShadow(style: .medium)
        }
    }
    
    // MARK: - Instructions
    private var instructionsSection: some View {
        VStack(spacing: ZenSpacing.md) {
            // Exercise selector
            Button {
                showExercisePicker = true
            } label: {
                HStack(spacing: ZenSpacing.sm) {
                    Image(systemName: selectedExercise.icon)
                        .font(.system(size: 20))
                        .foregroundColor(.zenFocus)
                    
                    VStack(alignment: .leading, spacing: 2) {
                        Text(selectedExercise.name)
                            .font(ZenFont.headline())
                            .foregroundColor(colorScheme == .dark ? .white : .zenTextPrimary)
                        
                        Text(formatDuration(selectedExercise.totalDuration))
                            .font(ZenFont.caption())
                            .foregroundColor(.zenTextMuted)
                    }
                    
                    Spacer()
                    
                    Image(systemName: "chevron.right")
                        .font(.system(size: 14, weight: .semibold))
                        .foregroundColor(.zenTextMuted)
                }
                .padding(ZenSpacing.md)
                .background(
                    RoundedRectangle(cornerRadius: ZenRadius.md)
                        .fill(colorScheme == .dark ? Color.zenDarkSurface : Color.white)
                )
                .zenShadow(style: .soft)
            }
            .disabled(isBreathing)
            .opacity(isBreathing ? 0.5 : 1.0)
            
            // Description
            if !isBreathing {
                Text(selectedExercise.description)
                    .font(ZenFont.caption())
                    .foregroundColor(.zenTextSecondary)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, ZenSpacing.lg)
            }
        }
        .padding(.horizontal, ZenSpacing.md)
    }
    
    // MARK: - Controls
    private var controlsSection: some View {
        HStack(spacing: ZenSpacing.xl) {
            if isBreathing {
                // Stop button
                Button {
                    stopBreathing()
                } label: {
                    Image(systemName: "stop.fill")
                        .font(.system(size: 20))
                        .foregroundColor(.zenTextSecondary)
                }
                .buttonStyle(ZenIconButtonStyle(size: 56))
            }
            
            // Main action button
            Button {
                if isBreathing {
                    stopBreathing()
                } else {
                    startBreathing()
                }
            } label: {
                ZStack {
                    Circle()
                        .fill(Color.zenRest)
                        .frame(width: 80, height: 80)
                        .zenShadow(style: .elevated)
                    
                    Image(systemName: isBreathing ? "pause.fill" : "play.fill")
                        .font(.system(size: 28, weight: .semibold))
                        .foregroundColor(.white)
                }
            }
        }
        .padding(.vertical, ZenSpacing.lg)
    }
    
    // MARK: - Breathing Logic
    private func startBreathing() {
        isBreathing = true
        currentCycle = 1
        currentPhase = .inhale
        phaseProgress = 0
        breathScale = 0.6
        
        // Start monitoring if enabled
        if settingsManager.healthKitEnabled {
            healthManager.startMonitoring()
        }
        
        ZenHaptics.medium()
        updateBreathScale()
    }
    
    private func stopBreathing() {
        isBreathing = false
        currentPhase = .inhale
        phaseProgress = 0
        breathScale = 0.6
        
        ZenHaptics.light()
    }
    
    private func updateBreathing() {
        let phaseDuration = getCurrentPhaseDuration()
        let increment = 0.05 / phaseDuration
        
        phaseProgress += increment
        
        if phaseProgress >= 1.0 {
            advancePhase()
        }
    }
    
    private func advancePhase() {
        phaseProgress = 0
        
        switch currentPhase {
        case .inhale:
            currentPhase = selectedExercise.hold1 > 0 ? .hold1 : .exhale
        case .hold1:
            currentPhase = .exhale
        case .exhale:
            currentPhase = selectedExercise.hold2 > 0 ? .hold2 : .inhale
            if selectedExercise.hold2 == 0 {
                completeCycle()
            }
        case .hold2:
            currentPhase = .inhale
            completeCycle()
        case .complete:
            stopBreathing()
            return
        }
        
        updateBreathScale()
        ZenHaptics.light()
    }
    
    private func completeCycle() {
        if currentCycle >= selectedExercise.cycles {
            currentPhase = .complete
            ZenHaptics.success()
            DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
                stopBreathing()
            }
        } else {
            currentCycle += 1
        }
    }
    
    private func updateBreathScale() {
        withAnimation(.easeInOut(duration: getCurrentPhaseDuration())) {
            switch currentPhase {
            case .inhale:
                breathScale = 1.0
            case .hold1, .hold2:
                break // Maintain current scale
            case .exhale:
                breathScale = 0.6
            case .complete:
                breathScale = 0.8
            }
        }
    }
    
    private func getCurrentPhaseDuration() -> TimeInterval {
        switch currentPhase {
        case .inhale: return selectedExercise.inhale
        case .hold1: return selectedExercise.hold1
        case .exhale: return selectedExercise.exhale
        case .hold2: return selectedExercise.hold2
        case .complete: return 1.0
        }
    }
    
    private func getRemainingTime() -> TimeInterval {
        let duration = getCurrentPhaseDuration()
        return duration * (1 - phaseProgress)
    }
    
    private func formatDuration(_ duration: TimeInterval) -> String {
        let minutes = Int(duration) / 60
        let seconds = Int(duration) % 60
        if minutes > 0 {
            return "\(minutes)m \(seconds)s"
        }
        return "\(seconds)s"
    }
}

// MARK: - Exercise Picker Sheet
struct ExercisePickerSheet: View {
    @Binding var isPresented: Bool
    @Binding var selectedExercise: BreathingExercise
    @Environment(\.colorScheme) var colorScheme
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: ZenSpacing.md) {
                    ForEach(BreathingExercise.defaults) { exercise in
                        exerciseCard(exercise)
                    }
                }
                .padding(ZenSpacing.lg)
            }
            .background(colorScheme == .dark ? Color.zenDarkBackground : Color.zenGradientStart)
            .navigationTitle("Breathing Exercises")
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
    
    private func exerciseCard(_ exercise: BreathingExercise) -> some View {
        Button {
            selectedExercise = exercise
            isPresented = false
            ZenHaptics.selection()
        } label: {
            HStack(spacing: ZenSpacing.md) {
                // Icon
                ZStack {
                    Circle()
                        .fill(Color.zenRest.opacity(0.2))
                        .frame(width: 50, height: 50)
                    
                    Image(systemName: exercise.icon)
                        .font(.system(size: 22))
                        .foregroundColor(.zenRest)
                }
                
                // Info
                VStack(alignment: .leading, spacing: ZenSpacing.xxs) {
                    Text(exercise.name)
                        .font(ZenFont.headline())
                        .foregroundColor(colorScheme == .dark ? .white : .zenTextPrimary)
                    
                    Text(exercise.description)
                        .font(ZenFont.caption())
                        .foregroundColor(.zenTextSecondary)
                        .lineLimit(2)
                    
                    // Pattern
                    HStack(spacing: ZenSpacing.xs) {
                        patternBadge("In \(Int(exercise.inhale))s")
                        if exercise.hold1 > 0 {
                            patternBadge("Hold \(Int(exercise.hold1))s")
                        }
                        patternBadge("Out \(Int(exercise.exhale))s")
                        if exercise.hold2 > 0 {
                            patternBadge("Hold \(Int(exercise.hold2))s")
                        }
                    }
                    .padding(.top, ZenSpacing.xxs)
                }
                
                Spacer()
                
                if selectedExercise.id == exercise.id {
                    Image(systemName: "checkmark.circle.fill")
                        .foregroundColor(.zenRest)
                        .font(.system(size: 24))
                }
            }
            .padding(ZenSpacing.md)
            .background(
                RoundedRectangle(cornerRadius: ZenRadius.md)
                    .fill(colorScheme == .dark ? Color.zenDarkSurface : Color.white)
                    .overlay(
                        RoundedRectangle(cornerRadius: ZenRadius.md)
                            .stroke(
                                selectedExercise.id == exercise.id ? Color.zenRest : Color.clear,
                                lineWidth: 2
                            )
                    )
            )
            .zenShadow(style: .soft)
        }
    }
    
    private func patternBadge(_ text: String) -> some View {
        Text(text)
            .font(ZenFont.caption(11))
            .foregroundColor(.zenTextMuted)
            .padding(.horizontal, ZenSpacing.xs)
            .padding(.vertical, 2)
            .background(
                Capsule()
                    .fill(Color.zenTextMuted.opacity(0.1))
            )
    }
}

// MARK: - Preview
#Preview {
    BreathingView()
        .environmentObject(HealthKitManager())
        .environmentObject(SettingsManager())
}
