//
//  DailyGoal.swift
//  tum-health-nav
//
//  Created by Sven Andabaka on 12.07.20.
//  Copyright © 2020 TUM. All rights reserved.
//

import Foundation
import SwiftUI

struct DailyGoal: Equatable, Identifiable, Codable {
    var id: UUID
    var goal = 0
    var type: GoalType
    var counter: Int
    var tripCounter: Int
    var timestamp: Date

    init(type: GoalType, counter: Int = 0, tripCounter: Int = 0, date: Date = Date()) {
        self.id = UUID()
        self.type = type
        self.counter = counter
        self.tripCounter = tripCounter
        self.timestamp = date
        switch type {
        case .calories:
            self.goal = 600
        case .met:
            self.goal = 30
        case .steps:
            self.goal = 10000
        case .walkDistance:
            self.goal = 7500
        case .bikeDistance:
            self.goal = 8000
        }
    }
}

enum GoalType: String, Codable {
    case met = "Health Points"
    case steps = "Steps"
    case calories = "Calories"
    case walkDistance = "Walking Distance"
    case bikeDistance = "Biking Distance"
}

extension GoalType {
    func getColor() -> Color {
        switch self {
        case .met:
            return Config.metColor
        case .steps:
            return Config.stepColor
        case .calories:
            return Config.caloriesColor
        case .walkDistance:
            return Config.walkDistanceColor
        case .bikeDistance:
            return Config.bikeDistanceColor
        }
    }
}

extension GoalType {
    func getUnit() -> String {
        switch self {
        case .met:
            return "Health Points"
        case .steps:
            return "Steps"
        case .calories:
            return "kCal"
        case .walkDistance:
            return "m"
        case .bikeDistance:
            return "m"
        }
    }
}

extension GoalType {
    static var allCases: [GoalType] {
        [
            .met,
            .steps,
            .calories,
            .walkDistance,
            .bikeDistance
        ]
    }
}
