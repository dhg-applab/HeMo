//
//  DataPillsView.swift
//  tum-health-nav
//
//  Created by Sven Andabaka on 28.07.20.
//  Copyright © 2020 TUM. All rights reserved.
//

import SwiftUI

// MARK: - View
// swiftlint:disable all
struct DataPillsView: View {
    
    @ObservedObject var viewModel: ViewModel
    @Environment(\.calendar) var calendar
    
    static let labelHeight: CGFloat = 20
    static let minPillHeight: CGFloat = 30
    
    let week: Date
    let type: GoalType
    
    private var days: [Date] {
        guard
            let weekInterval = calendar.dateInterval(of: .weekOfYear, for: week)
        else { return [] }
        return calendar.generateDates(
            inside: weekInterval,
            matching: DateComponents(hour: 0, minute: 0, second: 0)
        )
    }
    
    @State var biggestValue: Int = 1
    
    // swiftlint:disable closure_body_length
    var body: some View {
        let dailygoal = viewModel.getDailyGoal(for: type, on: Date(), adding: false)
        
        return VStack(spacing: 0) {
            HStack {
                if let firstDay = days.first {
                    Text("\(firstDay, formatter: DateFormatter.dayAndMonth)")
                        .font(.system(size: 16, weight: .bold))
                } else {
                    Text("")
                }
                Text(" - ")
                if let lastDay = days.last {
                    Text("\(lastDay, formatter: DateFormatter.dayAndMonth)")
                        .font(.system(size: 16, weight: .bold))
                } else {
                    Text("")
                }
            }.foregroundColor(.gray)
            GeometryReader { geometry in
                ZStack {
                    VStack {
                        Rectangle()
                            .fill(Color(UIColor.systemGray5))
                            .frame(height: 1)
                            .edgesIgnoringSafeArea(.horizontal)
                        Spacer()
                            .frame(height:  geometry.size.height * 0.72 / 2 * (CGFloat(dailygoal?.goal ?? 1) / max(CGFloat(biggestValue), CGFloat(dailygoal?.goal ?? 1))))
                        Rectangle()
                            .fill(Color.gray)
                            .frame(height: 1)
                            .edgesIgnoringSafeArea(.horizontal)
                        Spacer()
                            .frame(height:  geometry.size.height * 0.72 / 2 *
                                    (CGFloat(dailygoal?.goal ?? 1)
                                        / max(CGFloat(biggestValue), CGFloat(dailygoal?.goal ?? 1))))
                        
                        Rectangle()
                            .fill(Color(UIColor.systemGray5))
                            .frame(height: 1)
                            .edgesIgnoringSafeArea(.horizontal)
                        
                    }
                    VStack {
                        Spacer()
                        HStack {
                            Spacer()
                            ForEach(self.days, id: \.self) { date in
                                HStack(spacing: 0) {
                                    SinglePill(date: date,
                                               geometry: geometry,
                                               week: week,
                                               dailyGoal: viewModel.getDailyGoal(for: type, on: date, adding: false),
                                               biggestValue: $biggestValue)
                                    Spacer()
                                }
                            }
                        }
                        Spacer()
                    }
                }
            }
        }.onAppear {
            var values: [Int] = []
            days.forEach {
                values.append(viewModel.getDailyGoal(for: type, on: $0, adding: false)?.counter ?? 0)
            }
            self.biggestValue = values.max() ?? 0
        }
    }
}

struct SinglePill: View {
    
    @Environment(\.calendar) var calendar
    
    var date: Date
    var geometry: GeometryProxy
    let week: Date
    let dailyGoal: DailyGoal?
    @Binding var biggestValue: Int
    
    @State var progress: CGFloat = 0.0
    
    var body: some View {
        VStack {
            Text("\(dailyGoal?.counter ?? 0)")
                .foregroundColor(dailyGoal?.type.getColor() ?? Color.gray)
                .font(.system(size: 12, design: .rounded))
                .frame(height: 20)
            ZStack {
                RoundedRectangle(cornerRadius: 20)
                    .fill(dailyGoal?.type.getColor() ?? (date > Date() ? Color.white.opacity(0.8) : Color.gray))
                    .frame(width: geometry.size.width / 7 / 2,
                           height: geometry.size.height * 0.72 * progress)
                    .padding(3)
                    .background(((dailyGoal?.counter ?? 0) / (dailyGoal?.goal ?? 1) >= 1) ? Color.yellow :
                                    (calendar.isDateInToday(date) ? Color.white : Color(UIColor.systemGray4)))
                    .cornerRadius(90)
            }
            VStack(spacing: 2) {
                Text("\(date.dayOfWeek() ?? "")")
                    .font(.system(size: 12))
                    .foregroundColor(Color.gray)
                Circle()
                    .fill(Color.white)
                    .opacity(calendar.isDateInToday(date) ? 1 : 0)
                    .frame(width: 4, height: 4)
            }.frame(height: 20)
        }
        .onAppear {
            self.progress = CGFloat(dailyGoal?.counter ?? 0) /
                (max(CGFloat(biggestValue), CGFloat(dailyGoal?.goal ?? 1)))
        }
        .onDisappear {
            self.progress = 0
        }
        .animation(.spring())
    }
}

// MARK: - ViewModel

extension DataPillsView {
    class ViewModel: ObservableObject {
        
        // State
        @Published var dailyGoals: [DailyGoal]
        @Published var historicDailyGoals: [HistoricDailyGoal]
        
        // Misc
        let container: DIContainer
        private var cancelBag = CancelBag()
        
        init(container: DIContainer) {
            self.container = container
            let appState = container.appState
            
            _dailyGoals = .init(initialValue: appState[\.statistics.dailyGoals])
            _historicDailyGoals = .init(initialValue: appState[\.statistics.historicDailyGoals])
            
            cancelBag.collect {
                $dailyGoals
                    .sink { appState[\.statistics.dailyGoals] = $0 }
                appState.map(\.statistics.dailyGoals)
                    .removeDuplicates()
                    .assign(to: \.dailyGoals, on: self)
                
                appState.map(\.statistics.historicDailyGoals)
                    .removeDuplicates()
                    .assign(to: \.historicDailyGoals, on: self)
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
        
        func getDailyGoal(for type: GoalType, on date: Date, adding: Bool = true) -> DailyGoal? {
            if Calendar.current.isDateInToday(date) {
                return getDailyGoal(for: type)
            }
            guard let dailyGoal = historicDailyGoals.first(where: { Calendar.current.isDate($0.date, inSameDayAs: date) })?
                    .dailyGoals.first(where: { $0.type == type }) else {
                return nil
            }
            return dailyGoal
        }
    }
}


// MARK: - Preview

#if DEBUG
struct DataPillsView_Previews: PreviewProvider {
    static var previews: some View {
        DataPillsView(viewModel: .init(container: .preview), week: Date(), type: .steps)
    }
}
#endif
