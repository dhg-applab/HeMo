//
//  CircularProgressBar.swift
//  tum-health-nav
//
//  Created by Sven Andabaka on 23.07.20.
//  Copyright © 2020 TUM. All rights reserved.
//

import SwiftUI

// MARK: - View

struct CircularProgressBar: View {
    
    var dailyGoal: DailyGoal
    var width = 25
    @State var progress: CGFloat = 0.0
    
    var body: some View {
        ZStack {
            Circle()
                .stroke(lineWidth: CGFloat(width))
                .opacity(0.3)
                .foregroundColor(Color.gray)
            Circle()
                .trim(from: 0.0, to: self.progress)
                .stroke(style: StrokeStyle(lineWidth: CGFloat(width), lineCap: .round, lineJoin: .round))
                .animation(.spring())
                .foregroundColor(dailyGoal.type.getColor())
                .rotationEffect(Angle(degrees: 270))
//            Circle()
//                .trim(from: 0.0, to: CGFloat(dailyGoal.reachedByTrips))
//                .stroke(style: StrokeStyle(lineWidth: CGFloat(width), lineCap: .round, lineJoin: .round))
//                .foregroundColor(dailyGoal.type.getColor())
//                .brightness(0.3)
//                .rotationEffect(Angle(degrees: 270))
//                .animation(.linear)
        }
        .onAppear {
            progress = CGFloat(Float(dailyGoal.counter) / Float(dailyGoal.goal))
        }
        .onDisappear {
            progress = 0.0
        }
    }
}

// MARK: - Preview

#if DEBUG
struct CircularProgressBar_Previews: PreviewProvider {
    static var previews: some View {
        CircularProgressBar(dailyGoal: DailyGoal(type: .met, counter: 244))
            .frame(width: 230, height: 230)
    }
}
#endif
