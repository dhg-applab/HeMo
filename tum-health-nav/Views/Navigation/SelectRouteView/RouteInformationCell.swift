//
//  RouteInformationCell.swift
//  tum-health-nav
//
//  Created by Sven Andabaka on 15.06.20.
//  Copyright © 2020 TUM. All rights reserved.
//

import SwiftUI

// MARK: - View
// swiftlint:disable all
struct RouteInformationCell: View {
    
    @ObservedObject var viewModel: ViewModel
    
    @State var healthPoints: Int
    @State var time: TimeInterval
    @State var bikeDistance: Int
    @State var walkDistance: Int
    
    let recommended: Bool
    
    var timeString: String {
        let time = Int(self.time)
        if time < 60 {
            return "\(time)s"
        }
        let timeInMinutes = time / 60
        if timeInMinutes < 60 {
            return "\(timeInMinutes)min"
        }
        let minutesOfHours = timeInMinutes % 60
        let minutesOfHoursString = minutesOfHours == 0 ? "" : (minutesOfHours < 10 ? ":0\(minutesOfHours)" : ":\(minutesOfHours)")
        return "\(timeInMinutes / 60)" + minutesOfHoursString + "h"
    }
    
    var header: String {
        recommended ? "Recommended" : "Alternative"
    }
    
    var backgroundColor: Color {
        recommended ? Config.recommendationColor : Color(UIColor.systemGray4)
    }
    
    var foregroundColor: Color {
        recommended ? Color.black : Color.white
    }
    
    var body: some View {
        VStack {
            HStack {
                //Spacer()
                if recommended { Image(systemName: "bolt.fill").foregroundColor(Color.pink)}
                Text(header).foregroundColor(recommended ? Color.pink : Color.white)
                Spacer()
            }
            .font(.headline)
            .padding(.bottom, 10)
            .padding(.top, -5)
            .padding(.horizontal, 12)
            HStack {
                VStack(alignment: .leading, spacing: 0) {
                    HStack {
                        Image(systemName: "heart.circle.fill")
                            .resizable()
                            .background(Color.pink)
                            .cornerRadius(10)
                            .frame(width: 20, height: 20)
                        Text("\(healthPoints)")
                    }.padding(.bottom, 4)
                    HStack {
                        Image(systemName: "clock.fill")
                            .resizable()
                            .cornerRadius(10)
                            .frame(width: 20, height: 20)
                        Text(timeString)
                    }.padding(.bottom, 4)
        
                    getDistancSubView()
                }
                Spacer()
                getAchievablePASubView().padding(.trailing, 8)
            }
            .padding(.horizontal, 12)
        }
        .padding()
        .foregroundColor(Color.white)
        .background(Color(UIColor.systemGray4))
        .cornerRadius(20)
        .shadow(radius: 10)
    }
    
    private func getDistanceString(distance: Int) -> String {
        if distance < 1000 {
            return "\(distance) m"
        }
        return "\(String(format: "%.1f", Double(distance) / 1000)) km"
    }
    
    private func getDistancSubView() -> AnyView {
        AnyView(
            VStack(alignment: .leading, spacing: 0) {
                HStack {
                    Image(systemName: "figure.walk")
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        //.foregroundColor(foregroundColor)
                        .frame(width: 20, height: 20)
                    Text(getDistanceString(distance: walkDistance))
                }.padding(.bottom, 4)
                HStack {
                    Image(systemName: "bicycle")
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        //.foregroundColor(foregroundColor)
                        .frame(width: 20, height: 20)
                    Text(getDistanceString(distance: bikeDistance))
                }
            }
        )
    }
    
    private func getAchievablePASubView() -> AnyView {
        AnyView(
            ZStack(alignment: .center) {
                CircularDoubleProgressBar(dailyGoal: self.viewModel.getDailyGoal(for: GoalType.met), distance: self.$healthPoints,
                                          width: 14,
                                          radius: 85)
                CircularDoubleProgressBar(dailyGoal: self.viewModel.getDailyGoal(for: GoalType.walkDistance),
                                          distance: self.$walkDistance,
                                          width: 14,
                                          radius: 55)
                CircularDoubleProgressBar(dailyGoal: self.viewModel.getDailyGoal(for: GoalType.bikeDistance), distance: self.$bikeDistance,
                                          width: 14,
                                          radius: 25)
            }
        )
    }
}

extension RouteInformationCell {
    class ViewModel: ObservableObject {
        
        // State
        @Published var dailyGoals: [DailyGoal]
        
        // Misc
        let container: DIContainer
        private var cancelBag = CancelBag()
        
        init(container: DIContainer) {
            self.container = container
            let appState = container.appState
            
            _dailyGoals = .init(initialValue: appState.value.statistics.dailyGoals)
            
            cancelBag.collect {
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
    }
}

// MARK: - Preview

#if DEBUG
struct RouteInformationCell_Previews: PreviewProvider {
    static var previews: some View {
        RouteInformationCell(viewModel: .init(container: .preview), healthPoints: 25, time: 43545, bikeDistance: 1513, walkDistance: 300, recommended: false)
            .frame(width: 280, height: 320)
        //.previewLayout(.sizeThatFits)
    }
}
#endif
