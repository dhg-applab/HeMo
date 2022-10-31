//
//  TripActivity.swift
//  tum-health-nav
//
//  Created by Nikolai Madlener on 16.02.21.
//  Copyright © 2021 TUM. All rights reserved.
//

import Foundation

struct TripActivity: Equatable, Identifiable, Codable {
    var id: UUID
    var type: GoalType
    var counter: Int
    var timestamp: Date
    
    init(type: GoalType, counter: Int = 0, date: Date = Date()) {
        self.id = UUID()
        self.type = type
        self.counter = counter
        self.timestamp = date
    }
}
