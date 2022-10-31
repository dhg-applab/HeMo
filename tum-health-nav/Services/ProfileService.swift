//
//  ProfileService.swift
//  tum-health-nav
//
//  Created by Nikolai Madlener on 17.02.21.
//  Copyright © 2021 TUM. All rights reserved.
//

import Foundation
import Combine
import HealthKit

// MARK: - ServiceProtocol

protocol ProfileService {
    
    func updateWeightFromHealthKit()
    
    func updateHeightFromHealthKit()
    
    func updateBirthdayFromHealthKit()
    
    func updateSexFromHealthKit()
}

// MARK: - RealService

struct RealProfileService: ProfileService {
    
    let appState: Store<AppState>
    let healthKitRepository: HealthKitRepository
    
    init(appState: Store<AppState>, healthKitRepository: HealthKitRepository) {
        self.healthKitRepository = healthKitRepository
        self.appState = appState
    }
    
    func updateWeightFromHealthKit() {
        let identifier = HKQuantityTypeIdentifier.bodyMass
        
        healthKitRepository.fetchSingleValue(identifier: identifier, startDate: Date(), endDate: Date()) { sample in
            DispatchQueue.main.async {
                if let unit = preferredUnit(for: identifier) {
                    let value = sample.quantity.doubleValue(for: unit)
                    appState[\.profile.weight] = value
                }
            }
        }
    }
    
    func updateHeightFromHealthKit() {
        let identifier = HKQuantityTypeIdentifier.height
        
        healthKitRepository.fetchSingleValue(identifier: identifier, startDate: Date(), endDate: Date()) { sample in
            DispatchQueue.main.async {
                if let unit = preferredUnit(for: identifier) {
                    let value = sample.quantity.doubleValue(for: unit)
                    appState[\.profile.height] = Int(value)
                }
            }
        }
    }
    
    // swiftlint:disable force_unwrapping
    func updateBirthdayFromHealthKit() {
        let objectType = HKObjectType.characteristicType(forIdentifier: .dateOfBirth)!
        
        healthKitRepository.requestHealthDataAccessIfNeeded(toShare: nil, read: Set([objectType])) { success in
            if success {
                DispatchQueue.main.async {
                    do {
                        let dateComponents = try healthKitRepository.healthStore.dateOfBirthComponents()
                        appState[\.profile.birthday] = dateComponents.date!
                    } catch {
                        print("Couldn't retrieve birthdate")
                    }
                }
            }
        }
    }
    
    // swiftlint:disable force_unwrapping
    func updateSexFromHealthKit() {
        let objectType = HKObjectType.characteristicType(forIdentifier: .biologicalSex)!
        
        healthKitRepository.requestHealthDataAccessIfNeeded(toShare: nil, read: Set([objectType])) { success in
            if success {
                DispatchQueue.main.async {
                    do {
                        let sexObj = try self.healthKitRepository.healthStore.biologicalSex()
                        var sexString = ""
                        switch sexObj.biologicalSex {
                        case .female:
                            sexString = "Female"
                        case .male:
                            sexString = "Male"
                        case .other:
                            sexString = "Other"
                        default:
                            return
                        }
                        appState[\.profile.sex] = sexString
                    } catch {
                        print("Couldn't retrieve birthdate")
                    }
                }
            }
        }
    }
}

// MARK: - StubService

struct StubProfileService: ProfileService {
    
    func updateWeightFromHealthKit() {}
    
    func updateHeightFromHealthKit() {}
    
    func updateBirthdayFromHealthKit() {}
    
    func updateSexFromHealthKit() {}
}
