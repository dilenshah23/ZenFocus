//
//  TimerView.swift
//  ZenFocus
//
//  The main timer interface with beautiful circular progress
//

import SwiftUI

struct TimerView: View {
    @EnvironmentObject var timerManager: TimerManager
    @EnvironmentObject var healthManager: HealthKitManager
    @EnvironmentObject var settingsManager: SettingsManager
    
    @State private var showPresetPicker: Bool = false
    @State private var showStressInfo: Bool = false
    @State private var animateRing: Bool = false
    @State private var pulseAnimation: Bool = false
    
    @Environment(\.colorScheme) var colorScheme
    
    var body: some View {
        VStack(spacing: 0) {
            // Header
            headerSection
            
            Spacer()
            
            // Timer Circle
            timerCircle
            
            Spacer()
            
            // Controls
            controlsSection
            
            // Session Progress
            sessionProgress
                .padding(.bottom, 100) // Space for tab bar
        }
        .padding(.horizontal, ZenSpacing.lg)
        .onAppear {
            withAnimation(.easeInOut(duration: 1.0).repeatForever(autoreverses: true)) {
                pulseAnimation = true
            }
        }
        .sheet(isPresented: $showPresetPicker) {
            PresetPickerSheet(isPresented: $showPresetPicker)
        }
        .sheet(isPresented: $showStressInfo) {
            StressInfoSheet(isPresented: $showStressInfo)
        }
        .alert("Extend Your Break?", isPresented: $timerManager.showBreakSuggestion) {
            Button("Yes, extend") {
                timerManager.acceptBreakExtension()
            }
            Button("No thanks", role: .cancel) {
                timerManager.declineBreakExtension()
            }
        } message: {
            Text("Your stress levels suggest a longer break might help. Add \(Int(timerManager.suggestedBreakExtension / 60)) minutes?")
        }
    }
    
    // MARK: - Header Section
    private var headerSection: some View {
        VStack(spacing: ZenSpacing.sm) {
            // Greeting & Date
            HStack {
                VStack(alignment: .leading, spacing: ZenSpacing.xxs) {
                    Text(greeting)
                        .font(ZenFont.headline(24))
                        .foregroundColor(colorScheme == .dark ? .white : .zenTextPrimary)
                    
                    Text(dateString)
                        .font(ZenFont.caption())
                        .foregroundColor(.zenTextSecondary)
                }
                
                Spacer()
                
                // Stress Indicator (if health enabled)
                if settingsManager.healthKitEnabled {
                    stressIndicator
                }
            }
            .padding(.top, ZenSpacing.lg)
            
            // Today's Focus Time
            HStack {
                Image(systemName: "flame.fill")
                    .foregroundColor(.zenAccent)
                
                Text("\(timerManager.todaysFocusTimeFormatted) focused today")
                    .font(ZenFont.label())
                    .foregroundColor(.zenTextSecondary)
                
                Spacer()
                
                // Goal progress
                if settingsManager.dailyGoalMinutes > 0 {
                    let progress = min(1.0, timerManager.todaysTotalFocusTime / Double(settingsManager.dailyGoalMinutes * 60))
                    Text("\(Int(progress * 100))% of goal")
                        .font(ZenFont.caption())
                        .foregroundColor(.zenTextMuted)
                }
            }
            .padding(.horizontal, ZenSpacing.md)
            .padding(.vertical, ZenSpacing.sm)
            .background(
                RoundedRectangle(cornerRadius: ZenRadius.md)
                    .fill(colorScheme == .dark ? Color.zenDarkSurface.opacity(0.5) : Color.white.opacity(0.7))
            )
        }
    }
    
    private var greeting: String {
        let hour = Calendar.current.component(.hour, from: Date())
        switch hour {
        case 5..<12: return "Good morning"
        case 12..<17: return "Good afternoon"
        case 17..<21: return "Good evening"
        default: return "Good night"
        }
    }
    
    private var dateString: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "EEEE, MMM d"
        return formatter.string(from: Date())
    }
    
    // MARK: - Stress Indicator
    private var stressIndicator: some View {
        Button {
            showStressInfo = true
        } label: {
            HStack(spacing: ZenSpacing.xs) {
                Circle()
                    .fill(healthManager.stressLevel.color)
                    .frame(width: 8, height: 8)
                
                if healthManager.currentHeartRate > 0 {
                    HStack(spacing: 2) {
                        Image(systemName: "heart.fill")
                            .font(.system(size: 12))
                        Text("\(Int(healthManager.currentHeartRate))")
                            .font(ZenFont.mono(14))
                    }
                    .foregroundColor(healthManager.stressLevel.color)
                }
            }
            .padding(.horizontal, ZenSpacing.sm)
            .padding(.vertical, ZenSpacing.xs)
            .background(
                Capsule()
                    .fill(colorScheme == .dark ? Color.zenDarkSurface : Color.white)
            )
            .zenShadow(style: .soft)
        }
    }
    
    // MARK: - Timer Circle
    private var timerCircle: some View {
        ZStack {
            // Outer glow
            Circle()
                .fill(timerManager.currentPhase.color.opacity(0.1))
                .frame(width: 320, height: 320)
                .blur(radius: 30)
                .scaleEffect(pulseAnimation && timerManager.timerState == .running ? 1.05 : 1.0)
            
            // Background ring
            Circle()
                .stroke(
                    colorScheme == .dark ? Color.white.opacity(0.1) : Color.black.opacity(0.05),
                    lineWidth: 12
                )
                .frame(width: 280, height: 280)
            
            // Progress ring
            Circle()
                .trim(from: 0, to: timerManager.progress)
                .stroke(
                    timerManager.currentPhase.gradient,
                    style: StrokeStyle(lineWidth: 12, lineCap: .round)
                )
                .frame(width: 280, height: 280)
                .rotationEffect(.degrees(-90))
                .animation(.zenSmooth, value: timerManager.progress)
            
            // Inner circle with content
            VStack(spacing: ZenSpacing.sm) {
                // Phase icon
                Image(systemName: timerManager.currentPhase.icon)
                    .font(.system(size: 28, weight: .light))
                    .foregroundColor(timerManager.currentPhase.color)
                
                // Time display
                Text(timerManager.timeRemainingFormatted)
                    .font(ZenFont.display(64))
                    .foregroundColor(colorScheme == .dark ? .white : .zenTextPrimary)
                    .monospacedDigit()
                    .contentTransition(.numericText())
                    .animation(.zenSmooth, value: timerManager.timeRemainingFormatted)
                
                // Phase name
                Text(timerManager.currentPhase.displayName)
                    .font(ZenFont.label(16))
                    .foregroundColor(.zenTextSecondary)
                
                // Encouragement text (when running)
                if timerManager.timerState == .running {
                    Text(timerManager.currentPhase.randomEncouragement)
                        .font(ZenFont.caption(13))
                        .foregroundColor(.zenTextMuted)
                        .multilineTextAlignment(.center)
                        .padding(.top, ZenSpacing.xs)
                }
            }
            .frame(width: 240, height: 240)
            .background(
                Circle()
                    .fill(colorScheme == .dark ? Color.zenDarkSurface : Color.white)
            )
            .zenShadow(style: .medium)
        }
        .onTapGesture {
            if timerManager.timerState == .idle {
                showPresetPicker = true
            }
        }
    }
    
    // MARK: - Controls Section
    private var controlsSection: some View {
        HStack(spacing: ZenSpacing.xl) {
            // Skip / Reset button
            if timerManager.timerState != .idle {
                Button {
                    timerManager.stop()
                } label: {
                    Image(systemName: "stop.fill")
                        .font(.system(size: 20))
                        .foregroundColor(.zenTextSecondary)
                }
                .buttonStyle(ZenIconButtonStyle(size: 56))
            }
            
            // Main action button
            mainActionButton
            
            // Skip button (when running or paused)
            if timerManager.timerState == .running || timerManager.timerState == .paused {
                Button {
                    timerManager.skip()
                } label: {
                    Image(systemName: "forward.fill")
                        .font(.system(size: 20))
                        .foregroundColor(.zenTextSecondary)
                }
                .buttonStyle(ZenIconButtonStyle(size: 56))
            }
        }
        .padding(.vertical, ZenSpacing.lg)
    }
    
    private var mainActionButton: some View {
        Button {
            handleMainAction()
        } label: {
            ZStack {
                Circle()
                    .fill(timerManager.currentPhase.color)
                    .frame(width: 80, height: 80)
                    .zenShadow(style: .elevated)
                
                Image(systemName: mainActionIcon)
                    .font(.system(size: 28, weight: .semibold))
                    .foregroundColor(.white)
            }
        }
        .scaleEffect(timerManager.timerState == .running ? 1.0 : 1.0)
        .animation(.zenBounce, value: timerManager.timerState)
    }
    
    private var mainActionIcon: String {
        switch timerManager.timerState {
        case .idle, .completed: return "play.fill"
        case .running: return "pause.fill"
        case .paused: return "play.fill"
        }
    }
    
    private func handleMainAction() {
        ZenHaptics.medium()
        
        switch timerManager.timerState {
        case .idle, .completed:
            timerManager.start()
            if settingsManager.healthKitEnabled {
                healthManager.startMonitoring()
            }
        case .running:
            timerManager.pause()
        case .paused:
            timerManager.resume()
        }
    }
    
    // MARK: - Session Progress
    private var sessionProgress: some View {
        VStack(spacing: ZenSpacing.sm) {
            Text("Session \(timerManager.currentSessionNumber)")
                .font(ZenFont.caption())
                .foregroundColor(.zenTextMuted)
            
            HStack(spacing: ZenSpacing.xs) {
                ForEach(0..<timerManager.currentPreset.sessionsUntilLongBreak, id: \.self) { index in
                    Circle()
                        .fill(index < timerManager.completedFocusSessions % timerManager.currentPreset.sessionsUntilLongBreak
                              ? timerManager.currentPhase.color
                              : Color.zenTextMuted.opacity(0.3))
                        .frame(width: 8, height: 8)
                }
            }
            
            // Preset selector button
            Button {
                showPresetPicker = true
            } label: {
                HStack(spacing: ZenSpacing.xs) {
                    Text(timerManager.currentPreset.name)
                        .font(ZenFont.caption())
                    
                    Image(systemName: "chevron.down")
                        .font(.system(size: 10, weight: .semibold))
                }
                .foregroundColor(.zenTextSecondary)
                .padding(.horizontal, ZenSpacing.md)
                .padding(.vertical, ZenSpacing.xs)
                .background(
                    Capsule()
                        .fill(colorScheme == .dark ? Color.zenDarkSurface.opacity(0.5) : Color.white.opacity(0.7))
                )
            }
            .disabled(timerManager.timerState != .idle)
            .opacity(timerManager.timerState == .idle ? 1.0 : 0.5)
        }
    }
}

// MARK: - Preset Picker Sheet
struct PresetPickerSheet: View {
    @Binding var isPresented: Bool
    @EnvironmentObject var timerManager: TimerManager
    @EnvironmentObject var settingsManager: SettingsManager
    @Environment(\.colorScheme) var colorScheme
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: ZenSpacing.md) {
                    ForEach(settingsManager.allPresets) { preset in
                        presetCard(preset)
                    }
                }
                .padding(ZenSpacing.lg)
            }
            .background(colorScheme == .dark ? Color.zenDarkBackground : Color.zenGradientStart)
            .navigationTitle("Choose Timer")
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
    
    private func presetCard(_ preset: TimerPreset) -> some View {
        Button {
            timerManager.selectPreset(preset)
            isPresented = false
        } label: {
            HStack {
                VStack(alignment: .leading, spacing: ZenSpacing.xs) {
                    Text(preset.name)
                        .font(ZenFont.headline())
                        .foregroundColor(colorScheme == .dark ? .white : .zenTextPrimary)
                    
                    Text("\(Int(preset.focusDuration / 60))m focus • \(Int(preset.shortBreakDuration / 60))m break")
                        .font(ZenFont.caption())
                        .foregroundColor(.zenTextSecondary)
                }
                
                Spacer()
                
                if timerManager.currentPreset.id == preset.id {
                    Image(systemName: "checkmark.circle.fill")
                        .foregroundColor(.zenFocus)
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
                                timerManager.currentPreset.id == preset.id ? Color.zenFocus : Color.clear,
                                lineWidth: 2
                            )
                    )
            )
            .zenShadow(style: .soft)
        }
    }
}

// MARK: - Stress Info Sheet
struct StressInfoSheet: View {
    @Binding var isPresented: Bool
    @EnvironmentObject var healthManager: HealthKitManager
    @Environment(\.colorScheme) var colorScheme
    
    var body: some View {
        NavigationView {
            VStack(spacing: ZenSpacing.xl) {
                // Current Status
                VStack(spacing: ZenSpacing.md) {
                    Circle()
                        .fill(healthManager.stressLevel.color)
                        .frame(width: 80, height: 80)
                        .overlay(
                            Image(systemName: "heart.fill")
                                .font(.system(size: 36))
                                .foregroundColor(.white)
                        )
                    
                    Text(healthManager.stressLevel.displayName)
                        .font(ZenFont.title())
                        .foregroundColor(colorScheme == .dark ? .white : .zenTextPrimary)
                    
                    Text(healthManager.stressLevel.recommendation)
                        .font(ZenFont.body())
                        .foregroundColor(.zenTextSecondary)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal)
                }
                
                // Metrics
                HStack(spacing: ZenSpacing.lg) {
                    metricCard(
                        title: "Heart Rate",
                        value: "\(Int(healthManager.currentHeartRate))",
                        unit: "BPM",
                        icon: "heart.fill"
                    )
                    
                    metricCard(
                        title: "HRV",
                        value: "\(Int(healthManager.currentHRV))",
                        unit: "ms",
                        icon: "waveform.path.ecg"
                    )
                }
                .padding(.horizontal)
                
                Spacer()
            }
            .padding(.top, ZenSpacing.xl)
            .background(colorScheme == .dark ? Color.zenDarkBackground : Color.zenGradientStart)
            .navigationTitle("Stress Level")
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
    
    private func metricCard(title: String, value: String, unit: String, icon: String) -> some View {
        VStack(spacing: ZenSpacing.sm) {
            Image(systemName: icon)
                .font(.system(size: 24))
                .foregroundColor(.zenTextMuted)
            
            Text(value)
                .font(ZenFont.display(36))
                .foregroundColor(colorScheme == .dark ? .white : .zenTextPrimary)
            
            Text(unit)
                .font(ZenFont.caption())
                .foregroundColor(.zenTextMuted)
            
            Text(title)
                .font(ZenFont.label())
                .foregroundColor(.zenTextSecondary)
        }
        .frame(maxWidth: .infinity)
        .padding(ZenSpacing.lg)
        .background(
            RoundedRectangle(cornerRadius: ZenRadius.lg)
                .fill(colorScheme == .dark ? Color.zenDarkSurface : Color.white)
        )
        .zenShadow(style: .soft)
    }
}

// MARK: - Preview
#Preview {
    TimerView()
        .environmentObject(TimerManager())
        .environmentObject(HealthKitManager())
        .environmentObject(SettingsManager())
}
