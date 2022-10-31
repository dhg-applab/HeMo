//
//  NavigationConstraintsService.swift
//  tum-health-nav
//
//  Created by Nikolai Madlener on 31.01.21.
//  Copyright © 2021 TUM. All rights reserved.
//

import Foundation

// MARK: - ServiceProtocol

protocol NavigationConstraintsService {
    
    func activateConstraintPreference(with mode: OTPRequestMode)
    
    func deactivateConstraintPreference(with mode: OTPRequestMode)
    
    func initConstraintPreferences()
    
    func initModePreferences()
    
    func calculateOptimalConstraints()
    
    func toggleMode(for mode: ModePreference)
    
    func addConstraintPreference(with mode: OTPRequestMode)
}

// MARK: - RealService

struct RealNavigationConstraintsService: NavigationConstraintsService {
    
    let appState: Store<AppState>
    
    func activateConstraintPreference(with mode: OTPRequestMode) {
        if let index = appState.value.navigationConstraints.constraintPreferences.firstIndex(where: { $0.lowerBound.mode == mode }) {
            DispatchQueue.main.async {
                self.appState[\.navigationConstraints.constraintPreferences][index].active = true
            }
        }
    }
    
    func deactivateConstraintPreference(with mode: OTPRequestMode) {
        if let index = appState.value.navigationConstraints.constraintPreferences.firstIndex(where: { $0.lowerBound.mode == mode }) {
            DispatchQueue.main.async {
                self.appState[\.navigationConstraints.constraintPreferences][index].active = false
            }
        }
    }
    
    func initConstraintPreferences() {
        if appState.value.navigationConstraints.constraintPreferences.isEmpty {
            appState.value.navigationConstraints.activeModes.forEach { addConstraintPreference(with: $0) }
        }
    }
    
    func initModePreferences() {
        if appState.value.navigationConstraints.modePreferences.isEmpty {
            appState.value.navigationConstraints.modePreferences.append(
                ModePreference(
                    value: true,
                    mode: .walk
                )
            )
            appState.value.navigationConstraints.modePreferences.append(
                ModePreference(
                    value: true,
                    mode: .bicycle
                )
            )
            appState.value.navigationConstraints.modePreferences.append(
                ModePreference(
                    value: true,
                    mode: .transit
                )
            )
            appState.value.navigationConstraints.modePreferences.append(
                ModePreference(
                    value: false,
                    mode: .car
                )
            )
        }
    }
    
    func calculateOptimalConstraints() {
        let preferedMode = appState.value.navigationConstraints.preferedMode
        if let index = appState.value.navigationConstraints.constraintPreferences.firstIndex(where: { $0.lowerBound.mode == preferedMode }) {
            appState.value.navigationConstraints.constraintPreferences[index].lowerBound.value = 1000
            appState.value.navigationConstraints.constraintPreferences[index].upperBound.value = 3000
        }
        if let index = appState.value.navigationConstraints.constraintPreferences.firstIndex(where: { $0.lowerBound.mode != preferedMode }) {
            appState.value.navigationConstraints.constraintPreferences[index].lowerBound.value = 0
            appState.value.navigationConstraints.constraintPreferences[index].upperBound.value = 10000
        }
    }
    
    func toggleMode(for mode: ModePreference) {
        if mode.value {
            deactivateConstraintPreference(with: mode.mode)
        } else {
            activateConstraintPreference(with: mode.mode)
        }
        if let index = appState.value.navigationConstraints.modePreferences.firstIndex(where: { $0.mode == mode.mode }) {
            DispatchQueue.main.async {
                self.appState[\.navigationConstraints.modePreferences][index].value.toggle()
            }
        }
    }
    
    func addConstraintPreference(with mode: OTPRequestMode) {
        // TODO adjust min and max Values
        
        switch mode {
        case .bicycle:
            appState.value.navigationConstraints.constraintPreferences.append(
                RangeDistanceConstraintPreference(
                    lowerBound: DistanceConstraintPreference(
                        value: 1000,
                        mode: .bicycle,
                        conditionOperator: .minimumValue),
                    upperBound: DistanceConstraintPreference(
                        value: 10000,
                        mode: .bicycle,
                        conditionOperator: .maximumValue),
                    maxValue: 20000
                )
            )
        case .walk:
            appState.value.navigationConstraints.constraintPreferences.append(
                RangeDistanceConstraintPreference(
                    lowerBound: DistanceConstraintPreference(
                        value: 1000,
                        mode: .walk,
                        conditionOperator: .minimumValue),
                    upperBound: DistanceConstraintPreference(
                        value: 2000,
                        mode: .walk,
                        conditionOperator: .maximumValue),
                    maxValue: 10000
                )
            )
        default:
            return
        }
        
        appState.value.navigationConstraints.constraintPreferences =
            appState.value.navigationConstraints.constraintPreferences.sorted(by: { lhs, rhs in
                lhs.lowerBound.mode == .walk && rhs.lowerBound.mode == .bicycle
            })
    }
}

// MARK: - StubService

struct StubNavigationConstraintsService: NavigationConstraintsService {
    
    func getOTPRequestConstraints(constraintPreferences: [RangeDistanceConstraintPreference]) -> OTPRequestConstraintWrapper {
        OTPRequestConstraintWrapper(constraints: [])
    }
    
    func activateConstraintPreference(with mode: OTPRequestMode) {}
    
    func deactivateConstraintPreference(with mode: OTPRequestMode) {}
    
    func initConstraintPreferences() {}
    
    func initModePreferences() {}
    
    func calculateOptimalConstraints() {}
    
    func toggleMode(for mode: ModePreference) {}
    
    func addConstraintPreference(with mode: OTPRequestMode) {}
}
