//
//  HealthKitClient.swift
//  tum-health-nav
//
//  Created by Sven Andabaka on 29.07.20.
//  Copyright © 2020 TUM. All rights reserved.
//

import Foundation
import HealthKit
import Combine

// MARK: - RepositoryProtocol
// swiftlint:disable function_parameter_count

protocol HealthKitRepository {
    
    var healthStore: HKHealthStore { get }
    
    func requestHealthDataAccessIfNeeded(completion: @escaping (_ success: Bool) -> Void)
    
    func requestHealthDataAccessIfNeeded(toShare shareTypes: Set<HKSampleType>?,
                                         read readTypes: Set<HKObjectType>?,
                                         completion: @escaping (_ success: Bool) -> Void)
    
    func saveHealthData(_ data: [HKObject], completion: @escaping (_ success: Bool, _ error: Error?) -> Void)
    
    func fetchStatisticsCollection(with identifier: HKQuantityTypeIdentifier,
                                   options: HKStatisticsOptions,
                                   startDate: Date,
                                   endDate: Date,
                                   interval: DateComponents,
                                   type: GoalType,
                                   update: Bool,
                                   completion: @escaping (HKStatisticsCollection) -> Void)
    
    func fetchRoutingSummaryCollection(with identifier: HKQuantityTypeIdentifier,
                                       options: HKStatisticsOptions,
                                       startDate: Date,
                                       endDate: Date,
                                       interval: DateComponents,
                                       update: Bool,
                                       completion: @escaping (HKStatistics) -> Void)
    
    func fetchSingleValue(identifier: HKQuantityTypeIdentifier,
                          startDate: Date,
                          endDate: Date,
                          completion: @escaping (HKQuantitySample) -> Void)
    
    func requestAllHealthDataTypes()
}

// MARK: - RealRepository

struct RealHealthKitRepository: HealthKitRepository {
    
    let healthStore = HKHealthStore()
    
    var readDataTypes: [HKObjectType] {
        allHealthDataTypes
    }
    
    var shareDataTypes: [HKSampleType] {
        []
    }
    
    private var allHealthDataTypes: [HKObjectType] {
        let typeIdentifiers: [String] = [
            HKQuantityTypeIdentifier.stepCount.rawValue,
            HKQuantityTypeIdentifier.distanceWalkingRunning.rawValue,
            HKQuantityTypeIdentifier.activeEnergyBurned.rawValue,
            HKQuantityTypeIdentifier.distanceCycling.rawValue,
            HKQuantityTypeIdentifier.appleExerciseTime.rawValue,
            HKQuantityTypeIdentifier.bodyMass.rawValue,
            HKQuantityTypeIdentifier.height.rawValue,
            HKCharacteristicTypeIdentifier.dateOfBirth.rawValue,
            HKCharacteristicTypeIdentifier.biologicalSex.rawValue
        ]
        
        return typeIdentifiers.compactMap { getSampleType(for: $0) }
    }
    
    var healthKitEnabled: Bool {
        HKHealthStore.isHealthDataAvailable()
    }
    
    func requestAllHealthDataTypes() {
        requestHealthDataAccessIfNeeded { _ in }
    }
    
    func requestHealthDataAccessIfNeeded(completion: @escaping (_ success: Bool) -> Void) {
        requestHealthDataAccessIfNeeded(toShare: Set(shareDataTypes), read: Set(readDataTypes), completion: completion)
    }
    
    func requestHealthDataAccessIfNeeded(toShare shareTypes: Set<HKSampleType>?,
                                         read readTypes: Set<HKObjectType>?,
                                         completion: @escaping (_ success: Bool) -> Void) {
        if !HKHealthStore.isHealthDataAvailable() {
            fatalError("Health data is not available!")
        }
        
        print("Requesting HealthKit authorization...")
        healthStore.requestAuthorization(toShare: shareTypes, read: readTypes) { success, error in
            if let error = error {
                print("requestAuthorization error:", error.localizedDescription)
            }
            
            if success {
                print("HealthKit authorization request was successful!")
            } else {
                print("HealthKit authorization was not successful.")
            }
            
            completion(success)
        }
    }
    
    func saveHealthData(_ data: [HKObject], completion: @escaping (_ success: Bool, _ error: Error?) -> Void) {
        healthStore.save(data, withCompletion: completion)
    }
    
    func fetchStatisticsCollection(with identifier: HKQuantityTypeIdentifier,
                                   options: HKStatisticsOptions,
                                   startDate: Date,
                                   endDate: Date,
                                   interval: DateComponents,
                                   type: GoalType,
                                   update: Bool = false,
                                   completion: @escaping (HKStatisticsCollection) -> Void) {
        
        guard let quantityType = HKObjectType.quantityType(forIdentifier: identifier) else {
            fatalError("*** Unable to create a step count type ***")
        }
        
        requestHealthDataAccessIfNeeded(toShare: nil, read: Set([quantityType])) { success in
            if success {
                let query = HKObserverQuery(sampleType: quantityType, predicate: nil) { query, _, errorOrNil in
                    
                    if errorOrNil != nil {
                        // Properly handle the error.
                        return
                    }
                    
                    let predicate = HKQuery.predicateForSamples(withStart: startDate, end: endDate, options: .strictStartDate)
                    
                    // Create the query
                    let query = HKStatisticsCollectionQuery(quantityType: quantityType,
                                                            quantitySamplePredicate: predicate,
                                                            options: options,
                                                            anchorDate: startDate,
                                                            intervalComponents: interval)
                    
                    query.initialResultsHandler = { _, results, _ in
                        if let statsCollection = results {
                            completion(statsCollection)
                        }
                    }
                    
                    if update {
                        query.statisticsUpdateHandler = { _, _, result, _ in
                            if let statsCollection = result {
                                completion(statsCollection)
                            }
                        }
                    }
                    
                    healthStore.execute(query)
                }
                healthStore.execute(query)
            }
        }
    }
    
    func fetchRoutingSummaryCollection(with identifier: HKQuantityTypeIdentifier,
                                       options: HKStatisticsOptions,
                                       startDate: Date,
                                       endDate: Date,
                                       interval: DateComponents,
                                       update: Bool = false,
                                       completion: @escaping (HKStatistics) -> Void) {
        
        guard let quantityType = HKObjectType.quantityType(forIdentifier: identifier) else {
            fatalError("*** Unable to create a step count type ***")
        }
        
        requestHealthDataAccessIfNeeded(toShare: nil, read: Set([quantityType])) { success in
            if success {
                let predicate = HKQuery.predicateForSamples(withStart: startDate, end: endDate, options: [.strictStartDate])
                
                // Create the query
                let query = HKStatisticsQuery(quantityType: quantityType, quantitySamplePredicate: predicate, options: options) { _, result, _ in
                    if let result = result {
                        completion(result)
                    }
                }
                healthStore.execute(query)
            }
        }
    }
    
    func fetchSingleValue(identifier: HKQuantityTypeIdentifier,
                          startDate: Date,
                          endDate: Date,
                          completion: @escaping (HKQuantitySample) -> Void) {

        guard let quantityType = HKObjectType.quantityType(forIdentifier: identifier) else {
            fatalError("*** Unable to create a step count type ***")
        }

        requestHealthDataAccessIfNeeded(toShare: nil, read: Set([quantityType])) { success in
            if success {

                let query = HKSampleQuery(sampleType: quantityType,
                                          predicate: nil,
                                          limit: 1,
                                          sortDescriptors: nil) { _, results, _ in
                    if let result = results?.first as? HKQuantitySample {
                        completion(result)
                    }
                }

                healthStore.execute(query)
            }
        }
    }
}

// MARK: - StubRepository

struct StubHealthKitRepository: HealthKitRepository {
    let healthStore = HKHealthStore()
    func requestHealthDataAccessIfNeeded(completion: @escaping (_ success: Bool) -> Void) {}
    
    func requestHealthDataAccessIfNeeded(toShare shareTypes: Set<HKSampleType>?,
                                         read readTypes: Set<HKObjectType>?,
                                         completion: @escaping (_ success: Bool) -> Void) {}
    
    func saveHealthData(_ data: [HKObject], completion: @escaping (_ success: Bool, _ error: Error?) -> Void) {}
    
    func fetchStatisticsCollection(with identifier: HKQuantityTypeIdentifier,
                                   options: HKStatisticsOptions,
                                   startDate: Date,
                                   endDate: Date,
                                   interval: DateComponents,
                                   type: GoalType,
                                   update: Bool = false,
                                   completion: @escaping (HKStatisticsCollection) -> Void) {}
    
    func fetchRoutingSummaryCollection(with identifier: HKQuantityTypeIdentifier,
                                       options: HKStatisticsOptions,
                                       startDate: Date,
                                       endDate: Date,
                                       interval: DateComponents,
                                       update: Bool = false,
                                       completion: @escaping (HKStatistics) -> Void) {}
    
    func fetchSingleValue(identifier: HKQuantityTypeIdentifier,
                          startDate: Date,
                          endDate: Date,
                          completion: @escaping (HKQuantitySample) -> Void) {}
    
    func requestAllHealthDataTypes() {}
}
