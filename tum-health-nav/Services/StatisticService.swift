//
//  StatisticService.swift
//  tum-health-nav
//
//  Created by Nikolai Madlener on 17.02.21.
//  Copyright © 2021 TUM. All rights reserved.
//

import Foundation
import HealthKit

// MARK: - ServiceProtocol
// swiftlint:disable function_parameter_count

protocol StatisticService {
    
    func initDailyGoals()
    
    func initTripActivities()
    
    func addDailyGoal(dailyGoal: DailyGoal)
    
    func addTripActivity(tripActivity: TripActivity)
    
    func setGoal(value: Int, type: GoalType, date: Date)
    
    func setDailyCounter(with collection: HKStatisticsCollection,
                         options: HKStatisticsOptions,
                         sampleIdentifier: HKQuantityTypeIdentifier,
                         type: GoalType,
                         date: Date)
    

    func setHistoricCounters(with collection: HKStatisticsCollection,
                             options: HKStatisticsOptions,
                             sampleIdentifier: HKQuantityTypeIdentifier,
                             type: GoalType,
                             startDate: Date,
                             endDate: Date)
    func setTripActivity(with statistics: HKStatistics,
                         options: HKStatisticsOptions,
                         sampleIdentifier: HKQuantityTypeIdentifier,
                         type: GoalType,
                         date: Date)
    
    func updateDailyCounter(for type: GoalType)
    
    func updateTripCounter(for type: GoalType)
    
    func updateHistoricCounters(for type: GoalType)
    
    func requestAllHealthDataTypes()
}

// MARK: - RealService

struct RealStatisticService: StatisticService {
    
    let appState: Store<AppState>
    let healthKitRepository: HealthKitRepository
    
    init(appState: Store<AppState>, healthKitRepository: HealthKitRepository) {
        self.healthKitRepository = healthKitRepository
        self.appState = appState
    }
    
    func initDailyGoals() {
        if appState.value.statistics.dailyGoals.isEmpty {
            appState.value.statistics.dailyGoals.append(
                DailyGoal(type: .met)
            )
            appState.value.statistics.dailyGoals.append(
                DailyGoal(type: .walkDistance)
            )
            appState.value.statistics.dailyGoals.append(
                DailyGoal(type: .steps)
            )
            appState.value.statistics.dailyGoals.append(
                DailyGoal(type: .calories)
            )
            appState.value.statistics.dailyGoals.append(
                DailyGoal(type: .bikeDistance)
            )
        }
    }
    
    func initTripActivities() {
        appState.value.statistics.tripActivities = []
        appState.value.statistics.tripActivities.append(
            TripActivity(type: .walkDistance)
        )
        appState.value.statistics.tripActivities.append(
            TripActivity(type: .steps)
        )
        appState.value.statistics.tripActivities.append(
            TripActivity(type: .calories)
        )
    }
    
    func addDailyGoal(dailyGoal: DailyGoal) {
        DispatchQueue.main.async {
            self.appState[\.statistics.dailyGoals].append(dailyGoal)
        }
    }
    
    func addTripActivity(tripActivity: TripActivity) {
        DispatchQueue.main.async {
            self.appState[\.statistics.tripActivities].append(tripActivity)
        }
    }
    
    func setDailyCounter(with collection: HKStatisticsCollection,
                         options: HKStatisticsOptions,
                         sampleIdentifier: HKQuantityTypeIdentifier,
                         type: GoalType,
                         date: Date) {
        if let statistics = collection.statistics(for: date) {
            let quantity = getStatisticsQuantity(for: statistics, with: options)
            if let unit = preferredUnit(for: sampleIdentifier),
               let value = quantity?.doubleValue(for: unit) {
                print("updated daily \(type) counters")
                DispatchQueue.main.async {
                    if let dailyGoal = self.appState[\.statistics.dailyGoals].first(where: { $0.type == type }) {
                        if let index = self.appState[\.statistics.dailyGoals].firstIndex(of: dailyGoal) {
                            self.appState[\.statistics.dailyGoals][index].counter = Int(value)
                        }
                    }
                }
            }
        }
    }
    
    func setGoal(value: Int, type: GoalType, date: Date) {
        DispatchQueue.main.async {
            if let dailyGoal = self.appState[\.statistics.dailyGoals].first(where: { $0.type == type }) {
                if let index = self.appState[\.statistics.dailyGoals].firstIndex(of: dailyGoal) {
                    self.appState[\.statistics.dailyGoals][index].goal = Int(value)
                }
            }
        }
    }
    
    func setHistoricCounters(with collection: HKStatisticsCollection,
                             options: HKStatisticsOptions,
                             sampleIdentifier: HKQuantityTypeIdentifier,
                             type: GoalType,
                             startDate: Date,
                             endDate: Date) {
        collection.enumerateStatistics(from: startDate, to: endDate) { statistics, _ in
            let quantity = getStatisticsQuantity(for: statistics, with: options)
            if let unit = preferredUnit(for: sampleIdentifier),
               let value = quantity?.doubleValue(for: unit) {
                DispatchQueue.main.async {
                    let dailyGoal = DailyGoal(type: type, counter: Int(value), date: statistics.startDate)
                    guard let historicDailyGoal = self.appState[\.statistics.historicDailyGoals]
                            .first(where: { Calendar.current.isDate($0.date, inSameDayAs: statistics.startDate) }) else {
                        self.appState[\.statistics.historicDailyGoals].append(HistoricDailyGoal(date: statistics.startDate, dailyGoals: [dailyGoal]))
                        return
                    }
                    if let index = self.appState[\.statistics.historicDailyGoals]
                        .firstIndex(where: { Calendar.current.isDate($0.date, inSameDayAs: statistics.startDate) }) {
                        self.appState[\.statistics.historicDailyGoals][index].dailyGoals.append(dailyGoal)
                    }
                    if let index = self.appState[\.statistics.historicDailyGoals]
                        .firstIndex(where: { Calendar.current.isDate($0.date, inSameDayAs: statistics.startDate) }) {
                        if let index2 = self.appState[\.statistics.historicDailyGoals][index].dailyGoals.firstIndex(where: { $0.type == type }) {
                            self.appState[\.statistics.historicDailyGoals][index].dailyGoals[index2].counter = Int(value)
                        }
                    }
                }
            }
        }
        print("Historic daily goals for \(type) updated")
    }
    
    func setTripActivity(with statistics: HKStatistics,
                         options: HKStatisticsOptions,
                         sampleIdentifier: HKQuantityTypeIdentifier,
                         type: GoalType,
                         date: Date) {
        let quantity = getStatisticsQuantity(for: statistics, with: options)
        if let unit = preferredUnit(for: sampleIdentifier),
           let value = quantity?.doubleValue(for: unit) {
            print("updated daily \(type) counters")
            DispatchQueue.main.async {
                if let index = self.appState[\.statistics.tripActivities].firstIndex(where: { $0.type == type }) {
                    self.appState[\.statistics.tripActivities][index].counter = Int(value)
                }
            }
        }
    }
    
    func updateDailyCounter(for type: GoalType) {
        let sampleIdentifier = getSampleIdentifier(for: type)
        let options = getStatisticsOptions(for: sampleIdentifier)
        let startDate = Calendar.current.startOfDay(for: Date())
        let endDate = Calendar.current.startOfDay(for: Date.tomorrow)
        
        healthKitRepository.fetchStatisticsCollection(with: sampleIdentifier,
                                                      options: options,
                                                      startDate: startDate,
                                                      endDate: endDate,
                                                      interval: DateComponents(day: 1),
                                                      type: type,
                                                      update: true) { collection in
            setDailyCounter(with: collection,
                            options: options,
                            sampleIdentifier: sampleIdentifier,
                            type: type,
                            date: startDate)
        }
    }
    
    func updateHistoricCounters(for type: GoalType) {
        let startDate = Calendar.current.startOfMonth(Date())
        if Calendar.current.isDateInToday(startDate) {
            return
        }
        
        let sampleIdentifier = getSampleIdentifier(for: type)
        let options = getStatisticsOptions(for: sampleIdentifier)
        let endDate = Calendar.current.startOfDay(for: Date.tomorrow)
        
        healthKitRepository.fetchStatisticsCollection(with: sampleIdentifier,
                                                      options: options,
                                                      startDate: startDate,
                                                      endDate: endDate,
                                                      interval: DateComponents(day: 1),
                                                      type: type,
                                                      update: false) { collection in
            setHistoricCounters(with: collection,
                                options: options,
                                sampleIdentifier: sampleIdentifier,
                                type: type,
                                startDate: startDate,
                                endDate: endDate)
        }
    }
    
    func updateTripCounter(for type: GoalType) {
        let sampleIdentifier = getSampleIdentifier(for: type)
        let options = getStatisticsOptions(for: sampleIdentifier)
        let startDate = appState[\.trip.startDate]
        let endDate = appState[\.trip.endDate]
        
        healthKitRepository.fetchRoutingSummaryCollection(with: sampleIdentifier,
                                                          options: options,
                                                          startDate: startDate,
                                                          endDate: endDate,
                                                          interval: DateComponents(hour: 1),
                                                          update: true) { statistics in
            self.setTripActivity(with: statistics,
                                 options: options,
                                 sampleIdentifier: sampleIdentifier,
                                 type: type,
                                 date: startDate)
        }
    }
    
    func requestAllHealthDataTypes() {
        healthKitRepository.requestAllHealthDataTypes()
    }
}

// MARK: - StubService

struct StubStatisticService: StatisticService {
    
    func initDailyGoals() {}
    
    func initTripActivities() {}
    
    func addDailyGoal(dailyGoal: DailyGoal) {}
    
    func addTripActivity(tripActivity: TripActivity) {}
    
    func setGoal(value: Int, type: GoalType, date: Date) {}
    
    func setDailyCounter(with collection: HKStatisticsCollection,
                         options: HKStatisticsOptions,
                         sampleIdentifier: HKQuantityTypeIdentifier,
                         type: GoalType,
                         date: Date) {}
    
    func setHistoricCounters(with collection: HKStatisticsCollection,
                             options: HKStatisticsOptions,
                             sampleIdentifier: HKQuantityTypeIdentifier,
                             type: GoalType,
                             startDate: Date,
                             endDate: Date) {}
    
    func setTripActivity(with statistics: HKStatistics,
                         options: HKStatisticsOptions,
                         sampleIdentifier: HKQuantityTypeIdentifier,
                         type: GoalType,
                         date: Date) {}
    
    func updateDailyCounter(for type: GoalType) {}
    
    func updateHistoricCounters(for type: GoalType) {}
    
    func updateTripCounter(for type: GoalType) {}
    
    func requestAllHealthDataTypes() {}
}
