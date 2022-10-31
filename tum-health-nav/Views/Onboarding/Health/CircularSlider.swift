//
//  CircularSlider.swift
//  tum-health-nav
//
//  Created by Nikolai Madlener on 30.05.21.
//  Copyright © 2021 TUM. All rights reserved.
//

import SwiftUI

// MARK: - View
// swiftlint:disable all

struct CircularSlider: View {
    
    @ObservedObject var viewModel: ViewModel
    @State var size = UIScreen.main.bounds.width - 200
    
    var body: some View{
        ZStack {
            VStack {
                Text("Set your Daily Goal.")
                Spacer()
            }
            Circle()
                .stroke(Color(UIColor.systemGray5), style: StrokeStyle(lineWidth: 40, lineCap: .round, lineJoin: .round))
                .frame(width: size, height: size)
            
            VStack {
                Spacer()
                RoundedRectangle(cornerRadius: 10)
                    .frame(width: 2, height: 80)
                Spacer().frame(height: 10)
                Image(systemName: "checkmark.shield.fill")
                Text("Recommended").foregroundColor(.gray)
            }
            .frame(width: size, height: size + 180)
            .foregroundColor(Color(UIColor.systemGray2))
            
            HStack(spacing: 0) {
                Image(systemName: "bolt.fill").frame(width: 40)
                RoundedRectangle(cornerRadius: 10)
                    .frame(width: 80, height: 2)
                Spacer()
                
                RoundedRectangle(cornerRadius: 10)
                    .frame(width: 80, height: 2)
                    .foregroundColor(Color(UIColor.systemGray2))
                Image(systemName: "tortoise.fill").frame(width: 40)
            }
            .frame(width: size + 160, height: size)
            .foregroundColor(Color(UIColor.systemGray2))
            
            Circle()
                .trim(from: 0, to: viewModel.progress)
                .stroke(viewModel.type.getColor(), style: StrokeStyle(lineWidth: 40, lineCap: .round))
                .frame(width: size, height: size)
                .rotationEffect(.init(degrees: -90))
            
            Circle()
                .fill(Color.white)
                .frame(width: 40, height: 40)
                .offset(x: size / 2)
                .rotationEffect(.init(degrees: viewModel.angle))
                .gesture(DragGesture().onChanged(viewModel.onDrag(value:)))
                .simultaneousGesture(DragGesture().onEnded { _ in viewModel.setGoal(for: viewModel.type) })
                .rotationEffect(.init(degrees: -90))
            
            Text(String(format: "%.0f", viewModel.progress * viewModel.factor))
                .font(.system(size: 26, weight: .bold, design: .rounded))
                .foregroundColor(viewModel.type.getColor())
                .fontWeight(.heavy)
        }.frame(width: size + 160, height: size + 180)
    }
    
}

// MARK: - ViewModel

extension CircularSlider {
    class ViewModel: ObservableObject {
        
        // State
        @Published var dailyGoals: [DailyGoal]
        @Published var progress : CGFloat
        @Published var angle : Double
        
        var type: GoalType
        var factor: CGFloat
        
        // Misc
        let container: DIContainer
        private var cancelBag = CancelBag()
        
        init(container: DIContainer, type: GoalType, factor: CGFloat) {
            self.container = container
            let appState = container.appState
            self.type = type
            self.factor = factor
            
            _dailyGoals = .init(wrappedValue: appState.value.statistics.dailyGoals)
            _progress = .init(initialValue: 0)
            _angle = .init(initialValue: 0)
            
            progress = CGFloat(getDailyGoal(for: type).goal) / factor
            angle = Double(progress * 360)
            
            cancelBag.collect {
                $dailyGoals
                    .sink { appState[\.statistics.dailyGoals] = $0 }
                appState.map(\.statistics.dailyGoals)
                    .removeDuplicates()
                    .assign(to: \.dailyGoals, on: self)
                
            }
        }
        
        func getDailyGoal(for type: GoalType) -> DailyGoal {
            guard let dailyGoal = dailyGoals.first(where: { $0.type == type }) else {
                print("Couldn't find any dailyGoal with this type. Creating new one.")
                let dailyGoal = DailyGoal(type: type, counter: 0)
                container.services.statisticService.addDailyGoal(dailyGoal: dailyGoal)
                return dailyGoal
            }
            return dailyGoal
        }
        
        func setGoal(for type: GoalType) {
            container.services.statisticService.setGoal(value: Int(progress * factor), type: type, date: Date())
        }
        
        func onDrag(value: DragGesture.Value){
            
            let vector = CGVector(dx: value.location.x, dy: value.location.y)
            let radians = atan2(vector.dy - 27.5, vector.dx - 27.5)
            var angle = roundToNext45Degrees(x: radians * 180 / .pi)
            if angle < 22.5 {
                angle = 360 + angle
            }
            
            withAnimation(Animation.linear(duration: 0.15)) {
                let progress = angle / 360
                self.progress = progress
                self.angle = Double(angle)
            }
        }
        
        func roundToNext45Degrees(x : Double) -> CGFloat {
            return 45 * CGFloat(round(x / 45))
        }
    }
}

// MARK: - Preview

#if DEBUG
struct CircularSlider_Previews: PreviewProvider {
    static var previews: some View {
        CircularSlider(viewModel: .init(container: .preview, type: .met, factor: 500))
    }
}
#endif
