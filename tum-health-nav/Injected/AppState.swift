//
//  AppState.swift
//  tum-health-nav
//
//  Created by Nikolai Madlener on 30.01.21.
//  Copyright © 2021 TUM. All rights reserved.
//

import MapboxGeocoder

// MARK: - AppState

struct AppState: Equatable, Codable {
    var general = General()
    var trip = Trip()
    var profile = Profile()
    var statistics = Statistics()
    var navigationConstraints = NavigationConstraints()
}

// MARK: - Extenstions

extension AppState {
    struct Location: Equatable, Codable {
        var address = ""
        var placemarks = [GeocodedPlacemark]()
        var location: CLLocationCoordinate2D?
    }
}

extension AppState {
    struct General: Equatable, Codable {
        var onboarded = false
        var popToRoot = false
        var navigationBarHidden = true
        var activeCard = 0
    }
}

extension AppState {
    struct Trip: Equatable, Codable {
        var leaveBy = Date()
        var startingPoint = Location()
        var destination = Location()
        var startDate = Date()
        var endDate = Date()
    }
}

extension AppState {
    struct Profile: Equatable, Codable {
        var imageName = "person.circle.fill"
        var firstName = ""
        var lastName = ""
        var birthday: Date?
        var height: Int?
        var weight: Double?
        var sex: String?
    }
}

extension AppState {
    struct Statistics: Equatable, Codable {
        var dailyGoals = [DailyGoal]()
        var historicDailyGoals = [HistoricDailyGoal]()
        var tripActivities = [TripActivity]()
    }
}

extension AppState {
    struct NavigationConstraints: Equatable, Codable {
        var modePreferences = [ModePreference]()
        var constraintPreferences = [RangeDistanceConstraintPreference]()
        var activeModes: [OTPRequestMode] {
            modePreferences.filter { $0.value }.map { $0.mode }.unique()
        }
        var calculatePreferencesAutomatically = true
        var preferedMode = OTPRequestMode.walk
    }
}

extension Sequence where Iterator.Element: Hashable {
    func unique() -> [Iterator.Element] {
        var seen: Set<Iterator.Element> = []
        return filter { seen.insert($0).inserted }
    }
}

func == (lhs: AppState, rhs: AppState) -> Bool {
    lhs.trip == rhs.trip &&
        lhs.profile == rhs.profile &&
        lhs.statistics == rhs.statistics &&
        lhs.general == rhs.general &&
        lhs.navigationConstraints == rhs.navigationConstraints
}

// MARK: - Preview

#if DEBUG
extension AppState {
    static var preview: AppState {
        let state = AppState()
        return state
    }
}
#endif
