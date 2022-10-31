//
//  StatisticsDetailView.swift
//  tum-health-nav
//
//  Created by Sven Andabaka on 24.07.20.
//  Copyright © 2020 TUM. All rights reserved.
//

import SwiftUI

// MARK: - View
// swiftlint:disable all

struct StatisticsDetailView: View {
    
    @ObservedObject var viewModel: ViewModel
    @Environment(\.calendar) var calendar
    
    @State var showPreferences = false
    let type: GoalType
    
    var body: some View {
        let dailyGoal = viewModel.getDailyGoal(for: type)
        
        return ScrollView {
            VStack(alignment: .leading, spacing: 10) {
                HStack(spacing: 20) {
                    ZStack {
                        getGoalTypeIcon(for: dailyGoal.type)
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                            .frame(width: 20, height: 20)
                            .foregroundColor(dailyGoal.type.getColor())
                        
                        CircularProgressBar(dailyGoal: dailyGoal, width: 15).frame(width: 70, height: 70)
                    }
                    
                    Text("\(dailyGoal.counter) /\(dailyGoal.goal)")
                        .font(.system(size: 30, weight: .bold, design: .rounded))
                        .foregroundColor(type.getColor())
                    
                }.padding(10)
                VStack {
                    Picker("Time", selection: $viewModel.timespan) {
                        Text("Week").tag(0)
                        Text("Month").tag(1)
                    }
                    .pickerStyle(SegmentedPickerStyle())
                    .padding(.top, 8)
                    
                    getStatisticsView()
                    
                }
                .frame(height: 400)
                .padding(.horizontal)
                .background(Color(UIColor.systemGray6))
                .cornerRadius(25)
                getSummaryCell()
            }
            .padding()
            .navigationBarTitle("\(dailyGoal.type.rawValue)", displayMode: .inline)
            .navigationBarItems(trailing:
                                    Button(action: { self.showPreferences = true
            }) {
                Image(systemName: "gearshape").resizable().frame(width: 25, height: 25).foregroundColor(.white)
            }
            )
            .sheet(isPresented: self.$showPreferences) {
                OnboardingHealthView(viewModel: .init(container: viewModel.container, type: self.type))
                    .padding()
                    .modifier(SheetModifier())
            }
            
        }
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
    
    func getStatisticsView() -> AnyView {
        if viewModel.timespan == 0 {
            return AnyView(DataPillsView(viewModel: .init(container: viewModel.container), week: Date(), type: type))
        } else {
            return getCalendarView()
        }
    }
    
    func getCalendarView() -> AnyView {
        AnyView(
            VStack {
                HStack {
                    Text("\(self.calendar.monthSymbols[self.calendar.component(.month, from: Date()) - 1])")
                        .font(.headline)
                        .foregroundColor(.gray)
                }.padding(5)
                Spacer()
                MonthView(month: Date()) { date in
                    self.getCalendarCircle(date: date)
                }
                Spacer()
            }
        )
    }
    
    func getCalendarCircle(date: Date) -> AnyView {
        guard let dailyGoal = self.viewModel.getDailyGoal(for: type, on: date, adding: false) else {
            if date > Date() {
                return getCalendarCircle(backgroundColor: Color(UIColor.systemGray5), foregroundColor: Color.white, date: date, opacity: 0)
            }
            return getCalendarCircle(backgroundColor: Color.gray, date: date)
        }
        return AnyView(
            getCalendarCircle(wasReached: viewModel.wasReached(dailyGoal: dailyGoal),
                              backgroundColor: type.getColor(),
                              date: date,
                              opacity: viewModel.calcOpacity(dailyGoal: dailyGoal))
        )
    }
    
    func getCalendarCircle(wasReached: Bool = false,
                           backgroundColor: Color,
                           foregroundColor: Color = Color.white,
                           date: Date,
                           opacity: Double = 0) -> AnyView {
        AnyView(
            ZStack {
                Circle()
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                    .aspectRatio(1, contentMode: .fit)
                    .overlay(
                        RoundedRectangle(cornerRadius: 90)
                            .stroke(wasReached ? Color.yellow:
                                        (calendar.isDateInToday(date) ? Color.white : Color(UIColor.systemGray4)), lineWidth: 5)
                    )
                    .cornerRadius(90)
                    .foregroundColor(backgroundColor.opacity(opacity))
                    .cornerRadius(90)
                Text(String(self.calendar.component(.day, from: date)))
                Circle()
                    .frame(width: 4)
                    .foregroundColor(Color.white)
                    .opacity(calendar.isDateInToday(date) ? 1 : 0)
                    .padding(.top, 25)
            }
        )
    }
    
    func getSummaryCell() -> AnyView {
        AnyView(
            HStack {
                VStack(alignment: .leading, spacing: 2) {
                    Text("This Month")
                        .font(.headline)
                        .foregroundColor(Color.white)
                    
                    HStack(alignment: .bottom, spacing: 0) {
                        Text("\(viewModel.getMonthlyCounter(for: type, of: Date()))")
                            .padding(.horizontal, 5)
                            .font(.system(size: 30, weight: .bold, design: .rounded))
                            .foregroundColor(type.getColor())
                        Text("\(type.getUnit()) total")
                            .padding(.bottom, 4)
                            .font(.system(size: 16, weight: .bold))
                            .foregroundColor(Color.gray)
                        Spacer()
                        
                    }
                    HStack(alignment: .bottom, spacing: 0) {
                        Text("\(String(viewModel.getAverageStepsPerDay(for: type, of: Date())))")
                            .padding(.horizontal, 5)
                            .font(.system(size: 30, weight: .bold, design: .rounded))
                            .foregroundColor(type.getColor())
                        Text("\u{00D8}-" + "\(type.getUnit())/day")
                            .padding(.bottom, 4)
                            .font(.system(size: 16, weight: .bold))
                            .foregroundColor(Color.gray)
                        Spacer()
                        
                    }
                }
            }
                .padding()
                .background(Color(UIColor.systemGray6))
                .cornerRadius(25)
        )
    }
}

// MARK: - ViewModel

extension StatisticsDetailView {
    class ViewModel: ObservableObject {
        
        // State
        @Published var dailyGoals: [DailyGoal]
        @Published var historicDailyGoals: [HistoricDailyGoal]
        @Published var timespan: Int
        
        // Misc
        let container: DIContainer
        private var cancelBag = CancelBag()
        
        init(container: DIContainer) {
            self.container = container
            let appState = container.appState
            
            _dailyGoals = .init(initialValue: appState.value.statistics.dailyGoals)
            _historicDailyGoals = .init(initialValue: appState.value.statistics.historicDailyGoals)
            _timespan = .init(initialValue: 0)
            
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
        
        func getMonthlyCounter(for type: GoalType, of date: Date) -> Int {
            historicDailyGoals
                .filter{ $0.date.month == date.month }
                .reduce(0) { result, historicDailyGoal in
                    result + (historicDailyGoal.dailyGoals.first(where: { $0.type == type })?.counter ?? 0)
                } + getDailyGoal(for: type).counter
        }
        
        func getAverageStepsPerDay(for type: GoalType, of date: Date) -> Int {
            Int(getMonthlyCounter(for: type, of: date)/date.get(.day))
            
        }
        
        func wasReached(dailyGoal: DailyGoal) -> Bool {
            dailyGoal.counter / dailyGoal.goal >= 1
        }
        
        func calcOpacity(dailyGoal: DailyGoal) -> Double {
            Double(dailyGoal.counter) / Double(dailyGoal.goal)
        }
    }
}

// MARK: - Preview

#if DEBUG
struct StatisticsDetailView_Previews: PreviewProvider {
    static var previews: some View {
        StatisticsDetailView(viewModel: .init(container: .preview), type: .steps)
    }
}
#endif
