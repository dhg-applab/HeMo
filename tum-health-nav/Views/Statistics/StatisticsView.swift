//
//  StatisticsView.swift
//  tum-health-nav
//
//  Created by Sven Andabaka on 07.06.20.
//  Copyright © 2020 TUM. All rights reserved.
//

import SwiftUI
import HealthKit

// MARK: - View

struct StatisticsView: View {
    
    @ObservedObject var viewModel: ViewModel
    @State var showPreferences = false
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(alignment: .center, spacing: 10) {
                    NavigationLink(destination: StatisticsDetailView(viewModel: .init(container: viewModel.container), type: .met)) {
                        getStatisticsHeaderView()
                    }
                    Group {
                        ForEach(viewModel.dailyGoals) { dailyGoal in
                            if dailyGoal.type != .met {
                                NavigationLink(destination: StatisticsDetailView(viewModel: .init(container: viewModel.container),
                                                                                 type: dailyGoal.type)) {
                                    StatisticsCell(dailyGoal: dailyGoal)
                                }
                            }
                        }
                    }
                }
                .padding()
                .navigationBarTitle("Statistics")
                .navigationBarItems(trailing:
                                        Button(action: { self.showPreferences = true
                                        }) {
                                            Image(systemName: "person.crop.circle").resizable().frame(width: 30, height: 30).foregroundColor(.white)
                                        }
                )
                .sheet(isPresented: $showPreferences) {
                    BiometricalProfileView(viewModel: .init(container: viewModel.container)).modifier(SheetModifier())
                }
            }
        }
    }
    
    func getStatisticsHeaderView() -> AnyView {
        let metGoal = viewModel.getDailyGoal(for: .met)
        
        return AnyView(
            VStack(alignment: .center) {
                ZStack {
                    CircularProgressBar(dailyGoal: metGoal)
                    VStack {
                        VStack {
                            Image(systemName: "heart.fill").foregroundColor(metGoal.type.getColor())
                            Text(metGoal.type.rawValue)
                                .font(.system(size: 16, weight: .bold))
                                .foregroundColor(metGoal.type.getColor())
                        }
                        Text("\(metGoal.counter)/\(metGoal.goal)")
                            .font(.system(size: 28, weight: .bold, design: .rounded))
                            .foregroundColor(Color.white)
                    }
                }
                .frame(height: 150)
                .padding()
            }
        )
    }
}

// MARK: - ViewModel

extension StatisticsView {
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
    }
}

// MARK: - Preview

#if DEBUG
struct StatisticsView_Previews: PreviewProvider {
    static var previews: some View {
        StatisticsView(viewModel: .init(container: .preview))
    }
}
#endif
