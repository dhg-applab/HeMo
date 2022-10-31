//
//  HistoricDailyGoal.swift
//  tum-health-nav
//
//  Created by Sven Andabaka on 27.07.20.
//  Copyright © 2020 TUM. All rights reserved.
//

import Foundation

struct HistoricDailyGoal: Equatable, Identifiable, Codable {
    var id: UUID
    var date = Date()
    var dailyGoals: [DailyGoal]
    
    init(dailyGoals: [DailyGoal]) {
        self.id = UUID()
        self.dailyGoals = dailyGoals
    }
    
    init(date: Date, dailyGoals: [DailyGoal]) {
        self.id = UUID()
        self.date = date
        self.dailyGoals = dailyGoals
    }
}
