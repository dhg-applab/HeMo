//
//  HealthKitHelper.swift
//  tum-health-nav
//
//  Created by Sven Andabaka on 29.07.20.
//  Copyright © 2020 TUM. All rights reserved.
//

import Foundation
import HealthKit

// MARK: Sample Type Identifier Support

/// Return an HKSampleType based on the input identifier that corresponds to an HKQuantityTypeIdentifier, HKCategoryTypeIdentifier
/// or other valid HealthKit identifier. Returns nil otherwise.
func getSampleType(for identifier: String) -> HKObjectType? {
    if let quantityType = HKQuantityType.quantityType(forIdentifier: HKQuantityTypeIdentifier(rawValue: identifier)) {
        return quantityType
    }
    
    if let categoryType = HKCategoryType.categoryType(forIdentifier: HKCategoryTypeIdentifier(rawValue: identifier)) {
        return categoryType
    }
    
    if let characteristicType = HKCharacteristicType.characteristicType(forIdentifier: HKCharacteristicTypeIdentifier(rawValue: identifier)) {
        return characteristicType
    }
    
    return nil
}

func getSampleIdentifier(for type: GoalType) -> HKQuantityTypeIdentifier {
    switch type {
    case .met:
        return HKQuantityTypeIdentifier.appleExerciseTime
    case .steps:
        return HKQuantityTypeIdentifier.stepCount
    case .calories:
        return HKQuantityTypeIdentifier.activeEnergyBurned
    case .walkDistance:
        return HKQuantityTypeIdentifier.distanceWalkingRunning
    case .bikeDistance:
        return HKQuantityTypeIdentifier.distanceCycling
    }
}

func getStatisticsOptions(for quantityTypeIdentifier: HKQuantityTypeIdentifier) -> HKStatisticsOptions {
    switch quantityTypeIdentifier {
    case .stepCount, .distanceWalkingRunning, .appleExerciseTime, .activeEnergyBurned, .distanceCycling:
        return .cumulativeSum
    default:
        return .discreteAverage
    }
}

/// Return the statistics value in `statistics` based on the desired `statisticsOption`.
func getStatisticsQuantity(for statistics: HKStatistics, with statisticsOptions: HKStatisticsOptions) -> HKQuantity? {
    var statisticsQuantity: HKQuantity?
    
    switch statisticsOptions {
    case .cumulativeSum:
        statisticsQuantity = statistics.sumQuantity()
    case .discreteAverage:
        statisticsQuantity = statistics.averageQuantity()
    default:
        break
    }
    
    return statisticsQuantity
}

/// Returns the appropriate unit to use with an identifier corresponding to a HealthKit data type.
func preferredUnit(for quantityTypeIdentifier: HKQuantityTypeIdentifier) -> HKUnit? {
    switch quantityTypeIdentifier {
    case .stepCount:
        return .count()
    case .appleExerciseTime:
        return .minute()
    case .distanceWalkingRunning, .distanceCycling:
        return .meter()
    case .bodyMass:
        return .gramUnit(with: .kilo)
    case .activeEnergyBurned:
        return .kilocalorie()
    case .height:
        return .meterUnit(with: .centi)
    default:
        return nil
    }
}
