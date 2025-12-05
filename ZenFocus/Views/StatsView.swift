//
//  StatsView.swift
//  ZenFocus
//
//  Statistics and progress tracking
//

import SwiftUI
import Charts

struct StatsView: View {
    @EnvironmentObject var timerManager: TimerManager
    @EnvironmentObject var settingsManager: SettingsManager
    
    @State private var selectedTimeRange: TimeRange = .week
    @Environment(\.colorScheme) var colorScheme
    
    enum TimeRange: String, CaseIterable {
        case week = "Week"
        case month = "Month"
        case year = "Year"
    }
    
    var body: some View {
        ScrollView {
            VStack(spacing: ZenSpacing.lg) {
                // Header
                headerSection
                
                // Today's Summary
                todaySummaryCard
                
                // Time Range Picker
                timeRangePicker
                
                // Focus Chart
                focusChartCard
                
                // Session History
                sessionHistoryCard
                
                // Streak Card
                streakCard
                
                Spacer(minLength: 100) // Space for tab bar
            }
            .padding(.horizontal, ZenSpacing.lg)
        }
    }
    
    // MARK: - Header
    private var headerSection: some View {
        HStack {
            VStack(alignment: .leading, spacing: ZenSpacing.xxs) {
                Text("Statistics")
                    .font(ZenFont.title())
                    .foregroundColor(colorScheme == .dark ? .white : .zenTextPrimary)
                
                Text("Track your focus journey")
                    .font(ZenFont.caption())
                    .foregroundColor(.zenTextSecondary)
            }
            
            Spacer()
        }
        .padding(.top, ZenSpacing.lg)
    }
    
    // MARK: - Today's Summary
    private var todaySummaryCard: some View {
        VStack(spacing: ZenSpacing.md) {
            HStack {
                Text("Today")
                    .font(ZenFont.headline())
                    .foregroundColor(colorScheme == .dark ? .white : .zenTextPrimary)
                
                Spacer()
                
                Text(formattedDate(Date()))
                    .font(ZenFont.caption())
                    .foregroundColor(.zenTextMuted)
            }
            
            HStack(spacing: ZenSpacing.lg) {
                // Focus Time
                statItem(
                    value: timerManager.todaysFocusTimeFormatted,
                    label: "Focus Time",
                    icon: "brain.head.profile",
                    color: .zenFocus
                )
                
                Divider()
                    .frame(height: 50)
                
                // Sessions
                statItem(
                    value: "\(timerManager.completedFocusSessions)",
                    label: "Sessions",
                    icon: "checkmark.circle.fill",
                    color: .zenBreak
                )
                
                Divider()
                    .frame(height: 50)
                
                // Goal Progress
                let goalProgress = min(1.0, timerManager.todaysTotalFocusTime / Double(settingsManager.dailyGoalMinutes * 60))
                statItem(
                    value: "\(Int(goalProgress * 100))%",
                    label: "Goal",
                    icon: "target",
                    color: .zenAccent
                )
            }
            
            // Progress bar
            GeometryReader { geometry in
                ZStack(alignment: .leading) {
                    RoundedRectangle(cornerRadius: 4)
                        .fill(Color.zenTextMuted.opacity(0.2))
                        .frame(height: 8)
                    
                    RoundedRectangle(cornerRadius: 4)
                        .fill(
                            LinearGradient(
                                colors: [.zenFocus, .zenFocus.opacity(0.7)],
                                startPoint: .leading,
                                endPoint: .trailing
                            )
                        )
                        .frame(width: geometry.size.width * min(1.0, timerManager.todaysTotalFocusTime / Double(settingsManager.dailyGoalMinutes * 60)), height: 8)
                }
            }
            .frame(height: 8)
        }
        .padding(ZenSpacing.lg)
        .background(
            RoundedRectangle(cornerRadius: ZenRadius.lg)
                .fill(colorScheme == .dark ? Color.zenDarkSurface : Color.white)
        )
        .zenShadow(style: .medium)
    }
    
    private func statItem(value: String, label: String, icon: String, color: Color) -> some View {
        VStack(spacing: ZenSpacing.xs) {
            Image(systemName: icon)
                .font(.system(size: 20))
                .foregroundColor(color)
            
            Text(value)
                .font(ZenFont.headline(20))
                .foregroundColor(colorScheme == .dark ? .white : .zenTextPrimary)
            
            Text(label)
                .font(ZenFont.caption(12))
                .foregroundColor(.zenTextMuted)
        }
        .frame(maxWidth: .infinity)
    }
    
    // MARK: - Time Range Picker
    private var timeRangePicker: some View {
        HStack(spacing: ZenSpacing.xs) {
            ForEach(TimeRange.allCases, id: \.self) { range in
                Button {
                    withAnimation(.zenSpring) {
                        selectedTimeRange = range
                    }
                    ZenHaptics.selection()
                } label: {
                    Text(range.rawValue)
                        .font(ZenFont.label())
                        .foregroundColor(selectedTimeRange == range ? .white : .zenTextSecondary)
                        .padding(.horizontal, ZenSpacing.md)
                        .padding(.vertical, ZenSpacing.sm)
                        .background(
                            Capsule()
                                .fill(selectedTimeRange == range ? Color.zenFocus : Color.clear)
                        )
                }
            }
        }
        .padding(ZenSpacing.xxs)
        .background(
            Capsule()
                .fill(colorScheme == .dark ? Color.zenDarkSurface : Color.white)
        )
        .zenShadow(style: .soft)
    }
    
    // MARK: - Focus Chart
    private var focusChartCard: some View {
        VStack(alignment: .leading, spacing: ZenSpacing.md) {
            Text("Focus Time")
                .font(ZenFont.headline())
                .foregroundColor(colorScheme == .dark ? .white : .zenTextPrimary)
            
            // Chart
            if #available(iOS 16.0, *) {
                Chart(generateChartData()) { item in
                    BarMark(
                        x: .value("Day", item.label),
                        y: .value("Minutes", item.minutes)
                    )
                    .foregroundStyle(Color.zenFocus.gradient)
                    .cornerRadius(4)
                }
                .frame(height: 180)
                .chartYAxis {
                    AxisMarks(position: .leading) { value in
                        AxisValueLabel {
                            if let minutes = value.as(Int.self) {
                                Text("\(minutes)m")
                                    .font(ZenFont.caption(10))
                                    .foregroundColor(.zenTextMuted)
                            }
                        }
                    }
                }
                .chartXAxis {
                    AxisMarks { value in
                        AxisValueLabel {
                            if let label = value.as(String.self) {
                                Text(label)
                                    .font(ZenFont.caption(10))
                                    .foregroundColor(.zenTextMuted)
                            }
                        }
                    }
                }
            } else {
                // Fallback for iOS 15
                simpleFallbackChart
            }
        }
        .padding(ZenSpacing.lg)
        .background(
            RoundedRectangle(cornerRadius: ZenRadius.lg)
                .fill(colorScheme == .dark ? Color.zenDarkSurface : Color.white)
        )
        .zenShadow(style: .medium)
    }
    
    private var simpleFallbackChart: some View {
        HStack(alignment: .bottom, spacing: ZenSpacing.xs) {
            ForEach(generateChartData()) { item in
                VStack(spacing: ZenSpacing.xxs) {
                    RoundedRectangle(cornerRadius: 4)
                        .fill(Color.zenFocus)
                        .frame(width: 30, height: CGFloat(item.minutes) * 1.5)
                    
                    Text(item.label)
                        .font(ZenFont.caption(10))
                        .foregroundColor(.zenTextMuted)
                }
            }
        }
        .frame(height: 180)
    }
    
    // MARK: - Session History
    private var sessionHistoryCard: some View {
        VStack(alignment: .leading, spacing: ZenSpacing.md) {
            HStack {
                Text("Recent Sessions")
                    .font(ZenFont.headline())
                    .foregroundColor(colorScheme == .dark ? .white : .zenTextPrimary)
                
                Spacer()
                
                Button("See All") {
                    // Navigate to full history
                }
                .font(ZenFont.label())
                .foregroundColor(.zenFocus)
            }
            
            if timerManager.sessions.isEmpty {
                VStack(spacing: ZenSpacing.md) {
                    Image(systemName: "clock")
                        .font(.system(size: 40))
                        .foregroundColor(.zenTextMuted)
                    
                    Text("No sessions yet")
                        .font(ZenFont.body())
                        .foregroundColor(.zenTextSecondary)
                    
                    Text("Complete a focus session to see your history")
                        .font(ZenFont.caption())
                        .foregroundColor(.zenTextMuted)
                        .multilineTextAlignment(.center)
                }
                .frame(maxWidth: .infinity)
                .padding(.vertical, ZenSpacing.xl)
            } else {
                VStack(spacing: ZenSpacing.sm) {
                    ForEach(timerManager.sessions.suffix(5).reversed()) { session in
                        sessionRow(session)
                    }
                }
            }
        }
        .padding(ZenSpacing.lg)
        .background(
            RoundedRectangle(cornerRadius: ZenRadius.lg)
                .fill(colorScheme == .dark ? Color.zenDarkSurface : Color.white)
        )
        .zenShadow(style: .medium)
    }
    
    private func sessionRow(_ session: FocusSession) -> some View {
        HStack(spacing: ZenSpacing.md) {
            // Phase indicator
            Circle()
                .fill(session.phase.color)
                .frame(width: 8, height: 8)
            
            VStack(alignment: .leading, spacing: 2) {
                Text(session.phase.displayName)
                    .font(ZenFont.label())
                    .foregroundColor(colorScheme == .dark ? .white : .zenTextPrimary)
                
                Text(formatSessionTime(session.startTime))
                    .font(ZenFont.caption(12))
                    .foregroundColor(.zenTextMuted)
            }
            
            Spacer()
            
            // Duration
            if let duration = session.actualDuration {
                Text(formatDuration(duration))
                    .font(ZenFont.mono(14))
                    .foregroundColor(.zenTextSecondary)
            }
            
            // Completion status
            Image(systemName: session.completed ? "checkmark.circle.fill" : "xmark.circle")
                .foregroundColor(session.completed ? .zenSuccess : .zenTextMuted)
        }
        .padding(.vertical, ZenSpacing.xs)
    }
    
    // MARK: - Streak Card
    private var streakCard: some View {
        HStack(spacing: ZenSpacing.lg) {
            // Current streak
            VStack(spacing: ZenSpacing.xs) {
                Image(systemName: "flame.fill")
                    .font(.system(size: 28))
                    .foregroundColor(.zenAccent)
                
                Text("\(calculateCurrentStreak())")
                    .font(ZenFont.display(36))
                    .foregroundColor(colorScheme == .dark ? .white : .zenTextPrimary)
                
                Text("Day Streak")
                    .font(ZenFont.caption())
                    .foregroundColor(.zenTextMuted)
            }
            .frame(maxWidth: .infinity)
            
            Divider()
                .frame(height: 80)
            
            // Best streak
            VStack(spacing: ZenSpacing.xs) {
                Image(systemName: "trophy.fill")
                    .font(.system(size: 28))
                    .foregroundColor(.zenBreak)
                
                Text("\(calculateBestStreak())")
                    .font(ZenFont.display(36))
                    .foregroundColor(colorScheme == .dark ? .white : .zenTextPrimary)
                
                Text("Best Streak")
                    .font(ZenFont.caption())
                    .foregroundColor(.zenTextMuted)
            }
            .frame(maxWidth: .infinity)
        }
        .padding(ZenSpacing.lg)
        .background(
            RoundedRectangle(cornerRadius: ZenRadius.lg)
                .fill(colorScheme == .dark ? Color.zenDarkSurface : Color.white)
        )
        .zenShadow(style: .medium)
    }
    
    // MARK: - Helper Functions
    private func formattedDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "MMM d, yyyy"
        return formatter.string(from: date)
    }
    
    private func formatSessionTime(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "h:mm a"
        return formatter.string(from: date)
    }
    
    private func formatDuration(_ duration: TimeInterval) -> String {
        let minutes = Int(duration) / 60
        let seconds = Int(duration) % 60
        return String(format: "%d:%02d", minutes, seconds)
    }
    
    private func generateChartData() -> [ChartDataPoint] {
        // Generate sample data based on time range
        let calendar = Calendar.current
        var data: [ChartDataPoint] = []
        
        switch selectedTimeRange {
        case .week:
            for i in 0..<7 {
                let date = calendar.date(byAdding: .day, value: -6 + i, to: Date())!
                let dayName = calendar.shortWeekdaySymbols[calendar.component(.weekday, from: date) - 1]
                let minutes = Int.random(in: 30...180) // Sample data
                data.append(ChartDataPoint(label: dayName, minutes: minutes, date: date))
            }
        case .month:
            for i in 0..<4 {
                let weekLabel = "W\(i + 1)"
                let minutes = Int.random(in: 200...800) // Sample data
                data.append(ChartDataPoint(label: weekLabel, minutes: minutes, date: Date()))
            }
        case .year:
            let monthSymbols = calendar.shortMonthSymbols
            for i in 0..<12 {
                let minutes = Int.random(in: 500...3000) // Sample data
                data.append(ChartDataPoint(label: monthSymbols[i], minutes: minutes, date: Date()))
            }
        }
        
        return data
    }
    
    private func calculateCurrentStreak() -> Int {
        // Simplified streak calculation
        // In real implementation, would check consecutive days with completed sessions
        return max(1, timerManager.completedFocusSessions / 4)
    }
    
    private func calculateBestStreak() -> Int {
        return max(calculateCurrentStreak(), 7) // Sample best streak
    }
}

// MARK: - Chart Data Point
struct ChartDataPoint: Identifiable {
    let id = UUID()
    let label: String
    let minutes: Int
    let date: Date
}

// MARK: - Preview
#Preview {
    StatsView()
        .environmentObject(TimerManager())
        .environmentObject(SettingsManager())
}
