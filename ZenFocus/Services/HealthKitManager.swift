//
//  HealthKitManager.swift
//  ZenFocus
//
//  HealthKit integration for heart rate and HRV monitoring
//

import Foundation
import HealthKit
import Combine

@MainActor
class HealthKitManager: ObservableObject {
    // MARK: - Published Properties
    @Published var isAuthorized: Bool = false
    @Published var currentHeartRate: Double = 0
    @Published var restingHeartRate: Double = 60
    @Published var currentHRV: Double = 50
    @Published var stressLevel: StressLevel = .normal
    @Published var isMonitoring: Bool = false
    @Published var heartRateHistory: [HeartRateReading] = []
    @Published var hrvHistory: [HRVReading] = []
    
    // MARK: - Private Properties
    private let healthStore = HKHealthStore()
    private var heartRateQuery: HKObserverQuery?
    private var hrvQuery: HKObserverQuery?
    private var cancellables = Set<AnyCancellable>()
    
    // Heart rate type
    private let heartRateType = HKQuantityType.quantityType(forIdentifier: .heartRate)!
    private let hrvType = HKQuantityType.quantityType(forIdentifier: .heartRateVariabilitySDNN)!
    private let restingHeartRateType = HKQuantityType.quantityType(forIdentifier: .restingHeartRate)!
    
    // MARK: - Initialization
    init() {
        checkAuthorizationStatus()
    }
    
    // MARK: - Authorization
    var isHealthKitAvailable: Bool {
        HKHealthStore.isHealthDataAvailable()
    }
    
    func requestAuthorization() async {
        guard isHealthKitAvailable else {
            print("HealthKit is not available on this device")
            return
        }
        
        let typesToRead: Set<HKObjectType> = [
            heartRateType,
            hrvType,
            restingHeartRateType
        ]
        
        do {
            try await healthStore.requestAuthorization(toShare: [], read: typesToRead)
            await MainActor.run {
                self.isAuthorized = true
                self.fetchRestingHeartRate()
            }
        } catch {
            print("HealthKit authorization failed: \(error.localizedDescription)")
        }
    }
    
    private func checkAuthorizationStatus() {
        let status = healthStore.authorizationStatus(for: heartRateType)
        isAuthorized = status == .sharingAuthorized
    }
    
    // MARK: - Heart Rate Monitoring
    func startMonitoring() {
        guard isAuthorized else { return }
        
        isMonitoring = true
        startHeartRateObserver()
        startHRVObserver()
        
        // Fetch recent data
        fetchRecentHeartRate()
        fetchRecentHRV()
    }
    
    func stopMonitoring() {
        isMonitoring = false
        
        if let query = heartRateQuery {
            healthStore.stop(query)
            heartRateQuery = nil
        }
        
        if let query = hrvQuery {
            healthStore.stop(query)
            hrvQuery = nil
        }
    }
    
    private func startHeartRateObserver() {
        heartRateQuery = HKObserverQuery(
            sampleType: heartRateType,
            predicate: nil
        ) { [weak self] _, completionHandler, error in
            if error != nil {
                completionHandler()
                return
            }
            
            Task { @MainActor in
                self?.fetchRecentHeartRate()
            }
            
            completionHandler()
        }
        
        if let query = heartRateQuery {
            healthStore.execute(query)
        }
    }
    
    private func startHRVObserver() {
        hrvQuery = HKObserverQuery(
            sampleType: hrvType,
            predicate: nil
        ) { [weak self] _, completionHandler, error in
            if error != nil {
                completionHandler()
                return
            }
            
            Task { @MainActor in
                self?.fetchRecentHRV()
            }
            
            completionHandler()
        }
        
        if let query = hrvQuery {
            healthStore.execute(query)
        }
    }
    
    // MARK: - Data Fetching
    private func fetchRecentHeartRate() {
        let sortDescriptor = NSSortDescriptor(key: HKSampleSortIdentifierStartDate, ascending: false)
        let predicate = HKQuery.predicateForSamples(
            withStart: Date().addingTimeInterval(-3600), // Last hour
            end: Date(),
            options: .strictStartDate
        )
        
        let query = HKSampleQuery(
            sampleType: heartRateType,
            predicate: predicate,
            limit: 10,
            sortDescriptors: [sortDescriptor]
        ) { [weak self] _, samples, error in
            guard let samples = samples as? [HKQuantitySample],
                  let mostRecent = samples.first else {
                return
            }
            
            let heartRate = mostRecent.quantity.doubleValue(for: HKUnit(from: "count/min"))
            
            Task { @MainActor in
                self?.currentHeartRate = heartRate
                self?.updateStressLevel()
                
                // Add to history
                let reading = HeartRateReading(
                    timestamp: mostRecent.startDate,
                    value: heartRate
                )
                self?.heartRateHistory.append(reading)
                
                // Keep only last 100 readings
                if let count = self?.heartRateHistory.count, count > 100 {
                    self?.heartRateHistory.removeFirst(count - 100)
                }
            }
        }
        
        healthStore.execute(query)
    }
    
    private func fetchRecentHRV() {
        let sortDescriptor = NSSortDescriptor(key: HKSampleSortIdentifierStartDate, ascending: false)
        let predicate = HKQuery.predicateForSamples(
            withStart: Date().addingTimeInterval(-86400), // Last 24 hours
            end: Date(),
            options: .strictStartDate
        )
        
        let query = HKSampleQuery(
            sampleType: hrvType,
            predicate: predicate,
            limit: 10,
            sortDescriptors: [sortDescriptor]
        ) { [weak self] _, samples, error in
            guard let samples = samples as? [HKQuantitySample],
                  let mostRecent = samples.first else {
                return
            }
            
            let hrv = mostRecent.quantity.doubleValue(for: HKUnit.secondUnit(with: .milli))
            
            Task { @MainActor in
                self?.currentHRV = hrv
                self?.updateStressLevel()
                
                // Add to history
                let reading = HRVReading(
                    timestamp: mostRecent.startDate,
                    value: hrv
                )
                self?.hrvHistory.append(reading)
                
                // Keep only last 50 readings
                if let count = self?.hrvHistory.count, count > 50 {
                    self?.hrvHistory.removeFirst(count - 50)
                }
            }
        }
        
        healthStore.execute(query)
    }
    
    private func fetchRestingHeartRate() {
        let sortDescriptor = NSSortDescriptor(key: HKSampleSortIdentifierStartDate, ascending: false)
        
        let query = HKSampleQuery(
            sampleType: restingHeartRateType,
            predicate: nil,
            limit: 1,
            sortDescriptors: [sortDescriptor]
        ) { [weak self] _, samples, error in
            guard let samples = samples as? [HKQuantitySample],
                  let mostRecent = samples.first else {
                return
            }
            
            let restingHR = mostRecent.quantity.doubleValue(for: HKUnit(from: "count/min"))
            
            Task { @MainActor in
                self?.restingHeartRate = restingHR
            }
        }
        
        healthStore.execute(query)
    }
    
    // MARK: - Stress Level Calculation
    private func updateStressLevel() {
        // Combine HRV and heart rate for stress estimation
        let hrvStress = StressLevel.from(hrv: currentHRV)
        let hrStress = StressLevel.from(heartRate: currentHeartRate, restingHeartRate: restingHeartRate)
        
        // Weight HRV more heavily as it's a better stress indicator
        let hrvWeight = 0.7
        let hrWeight = 0.3
        
        let hrvScore = stressScore(for: hrvStress)
        let hrScore = stressScore(for: hrStress)
        
        let combinedScore = hrvWeight * hrvScore + hrWeight * hrScore
        
        stressLevel = stressLevel(from: combinedScore)
    }
    
    private func stressScore(for level: StressLevel) -> Double {
        switch level {
        case .low: return 0
        case .normal: return 0.33
        case .elevated: return 0.66
        case .high: return 1.0
        }
    }
    
    private func stressLevel(from score: Double) -> StressLevel {
        switch score {
        case ..<0.2: return .low
        case 0.2..<0.5: return .normal
        case 0.5..<0.75: return .elevated
        default: return .high
        }
    }
    
    // MARK: - Focus Score Calculation
    func calculateFocusScore(during session: FocusSession) -> Int {
        guard !heartRateHistory.isEmpty else { return 75 } // Default score
        
        let sessionReadings = heartRateHistory.filter {
            $0.timestamp >= session.startTime &&
            $0.timestamp <= (session.endTime ?? Date())
        }
        
        guard !sessionReadings.isEmpty else { return 75 }
        
        // Calculate heart rate variability during the session
        let values = sessionReadings.map { $0.value }
        let mean = values.reduce(0, +) / Double(values.count)
        let variance = values.map { pow($0 - mean, 2) }.reduce(0, +) / Double(values.count)
        let stdDev = sqrt(variance)
        
        // Lower variance = more stable = better focus
        // Score from 0-100 based on stability
        let stabilityScore = max(0, 100 - (stdDev * 5))
        
        // Also consider if heart rate stayed close to resting
        let elevationRatio = mean / restingHeartRate
        let elevationPenalty = max(0, (elevationRatio - 1.0) * 30)
        
        let finalScore = Int(min(100, max(0, stabilityScore - elevationPenalty)))
        return finalScore
    }
}

// MARK: - Supporting Types
struct HeartRateReading: Identifiable {
    let id = UUID()
    let timestamp: Date
    let value: Double
}

struct HRVReading: Identifiable {
    let id = UUID()
    let timestamp: Date
    let value: Double
}
