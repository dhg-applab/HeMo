//
//  StatisticsCell.swift
//  tum-health-nav
//
//  Created by Sven Andabaka on 23.07.20.
//  Copyright © 2020 TUM. All rights reserved.
//

import SwiftUI

// MARK: - View
// swiftlint:disable all

struct StatisticsCell: View {
    
    var dailyGoal: DailyGoal
    
    var body: some View {
        HStack {
            VStack(alignment: .leading, spacing: 10) {
                HStack {
                    getGoalTypeIcon(for: dailyGoal.type).foregroundColor(dailyGoal.type.getColor())
                    Text(dailyGoal.type.rawValue)
                        .font(Font.headline.weight(.medium))
                        .foregroundColor(dailyGoal.type.getColor())
                        Spacer()
                }.frame(maxWidth: 200)
                
                HStack(alignment: .bottom, spacing: 0) {
                    Text("\(dailyGoal.counter)")
                        .font(.system(size: 26, weight: .bold, design: .rounded))
                        .fixedSize()
                        .foregroundColor(Color.white)
                    Text("/\(dailyGoal.goal)")
                        .font(.system(size: 26, weight: .bold, design: .rounded))
                        .fixedSize()
                        .foregroundColor(Color.gray)
                    Text("\(getGoalTypeUnit(for: dailyGoal.type))")
                        .font(.system(size: 20, weight: .bold, design: .rounded))
                        .fixedSize()
                        .foregroundColor(Color.gray)
                        .padding(2)
                }
            }
            Spacer()
            CircularProgressBar(dailyGoal: dailyGoal, width: 12)
                .frame(width: 40, height: 40)
                .padding()
            Image(systemName: "chevron.right").foregroundColor(Color.gray)
        }
        .padding()
        .background(Color(UIColor.systemGray6))
        .cornerRadius(25)
    }
    
    func getGoalTypeIcon(for type: GoalType) -> Image {
        switch type {
        case GoalType.steps:
            return Image(systemName: "figure.walk")
        case GoalType.calories:
            return Image(systemName: "flame.fill")
        case GoalType.walkDistance:
            return Image(systemName: "figure.walk")
        case GoalType.bikeDistance:
            return Image(systemName: "bicycle")
        default:
            return Image(systemName: "questionmark")
        }
    }
    
    func getGoalTypeUnit(for type: GoalType) -> String {
        switch type {
        case GoalType.steps:
            return ""
        case GoalType.calories:
            return "kcal"
        case GoalType.walkDistance:
            return "m"
        case GoalType.bikeDistance:
            return "m"
        default:
            return ""
        }
    }
}

// MARK: - Preview

#if DEBUG
struct StatisticsCell_Previews: PreviewProvider {
    static var previews: some View {
        StatisticsCell(dailyGoal: DailyGoal(type: .steps))
            .padding(.horizontal, 20)
            .padding(.vertical, 4)
    }
}
#endif
