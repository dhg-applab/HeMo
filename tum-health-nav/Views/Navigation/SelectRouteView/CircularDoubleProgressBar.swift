//
//  CircularDoubleProgressBar.swift
//  tum-health-nav
//
//  Created by Nikolai Madlener on 27.05.21.
//  Copyright © 2021 TUM. All rights reserved.
//

import SwiftUI

// MARK: - View
// swiftlint:disable all

struct CircularDoubleProgressBar: View {
    
    var dailyGoal: DailyGoal
    @Binding var distance: Int
    var width: Int
    var radius: Int

    var body: some View {
        
        ZStack {
            Circle()
                .stroke(lineWidth: CGFloat(width))
                .opacity(0.3)
                .foregroundColor(Color.gray)
            
            Circle()
                .trim(from: 0.0, to: getAchievablePA())
                .stroke(style: StrokeStyle(lineWidth: CGFloat(width), lineCap: .round, lineJoin: .round))
                .foregroundColor(dailyGoal.type.getColor())
                .saturation(2)
                .brightness(0.1)
                .opacity(0.35)
                .rotationEffect(Angle(degrees: 270))

            Circle()
                .trim(from: 0.0, to: getReachedPA())
                .stroke(style: StrokeStyle(lineWidth: CGFloat(width), lineCap: .round, lineJoin: .round))
                .foregroundColor(dailyGoal.type.getColor())
                .rotationEffect(Angle(degrees: 270))
            
            VStack {
                getGoalTypeIcon(for: dailyGoal.type)
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(width: 10, height: 10)
                    .offset(y: -5)
                Spacer()
            }
            
        }.frame(width: CGFloat(radius), height: CGFloat(radius))
    }
    
    func getAchievablePA() -> CGFloat {
        return CGFloat(dailyGoal.counter) / CGFloat(dailyGoal.goal)
                + CGFloat(distance) / CGFloat(dailyGoal.goal)
    }
    
    func getReachedPA() -> CGFloat {
        return CGFloat(dailyGoal.counter) / CGFloat(dailyGoal.goal)
    }
    
    func getGoalTypeIcon(for type: GoalType) -> Image {
        switch type {
        case GoalType.met:
            return Image(systemName: "heart.fill")
        case GoalType.steps:
            return Image(systemName: "figure.walk")
        case GoalType.calories:
            return Image(systemName: "flame.fill")
        case GoalType.walkDistance:
            return Image(systemName: "figure.walk")
        case GoalType.bikeDistance:
            return Image(systemName: "bicycle")
        }
    }
}

// MARK: - Preview

#if DEBUG
struct CircularDoubleProgressBar_Previews: PreviewProvider {
    static var previews: some View {
        CircularDoubleProgressBar(dailyGoal: DailyGoal(type: .bikeDistance, counter: 5000),
                                distance: .constant(5000),
                                width: 14,
                                radius: 90
                                  )
            .frame(width: 40, height: 40)
        .aspectRatio(contentMode: .fit)
    }
}
#endif
