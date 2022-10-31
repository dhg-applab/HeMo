//
//  RoutingSummaryView.swift
//  tum-health-nav
//
//  Created by Sven Andabaka on 26.09.20.
//  Copyright © 2020 TUM. All rights reserved.
//

import SwiftUI
import HealthKit

// MARK: - View

struct RoutingSummaryView: View {
    
    @EnvironmentObject var modalManager: ModalManager
    @ObservedObject var viewModel: ViewModel
    
    @Binding var finished: Bool
    
    var body: some View {
        VStack {
            HStack(alignment: .top) {
                Text("Physical Activity Summary")
                    .font(.title).fontWeight(/*@START_MENU_TOKEN@*/.bold/*@END_MENU_TOKEN@*/)
                
                Spacer()
                Button(action: {
                    self.viewModel.setPopToRoot(to: false)
                    self.finished = false
                    self.modalManager.closeModal()
                    self.viewModel.initTripActivities()
                }) {
                    Text("Finish")
                        .foregroundColor(.red)
                        .font(.headline)
                }
            }.padding()

            ScrollView {
                getSummary(for: .met)
                Divider()
                getSummary(for: .walkDistance)
                Divider()
                getSummary(for: .steps)
                Divider()
                getSummary(for: .bikeDistance)
                Divider()
                getSummary(for: .calories)
            }
            Spacer()
        }
        .foregroundColor(.white)
        .onAppear {
            viewModel.updateTripCounters()
        }
    }
    
    func getSummary(for goalType: GoalType) -> AnyView {
        AnyView(
            HStack {
                VStack(alignment: .leading, spacing: 3) {
                    HStack {
                        getGoalTypeIcon(for: goalType)
                        Text(goalType.rawValue)
                            .font(Font.headline.weight(.medium))
                    }
                    Text("+" + viewModel.getTripActivity(for: goalType).counter.description)
                        .foregroundColor(goalType.getColor())
                        .font(.system(size: 28, weight: .bold, design: .rounded))
                    Text("This is \(calcPercentageTripToGoal(for: goalType))% of your daily goal.")
                        .font(.system(size: 12))
                        .foregroundColor(Color.gray)
                        .multilineTextAlignment(.center)
                }
                Spacer()
                CircularProgressBar(dailyGoal: viewModel.getDailyGoal(for: goalType), width: 12)
                    .frame(width: 60, height: 60)
            }
            .padding(.horizontal, 30)
            .padding(.vertical, 15)
        )
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
    
    func calcPercentageTripToGoal(for goalType: GoalType) -> Int {
        Int(Double(viewModel.getTripActivity(for: goalType).counter) /
                Double(viewModel.getDailyGoal(for: goalType).goal) * 100.0)
    }
}

// MARK: - ViewModel

extension RoutingSummaryView {
    class ViewModel: ObservableObject {
        
        // State
        @Published var tripActivities: [TripActivity]
        @Published var dailyGoals: [DailyGoal]
        @Published var popToRoot: Bool
        
        // Misc
        let container: DIContainer
        private var cancelBag = CancelBag()
        
        init(container: DIContainer) {
            self.container = container
            let appState = container.appState
            
            _tripActivities = .init(wrappedValue: appState.value.statistics.tripActivities)
            _dailyGoals = .init(wrappedValue: appState.value.statistics.dailyGoals)
            _popToRoot = .init(wrappedValue: appState.value.general.popToRoot)
                   
            cancelBag.collect {
                appState.map(\.statistics.tripActivities)
                    .removeDuplicates()
                    .assign(to: \.tripActivities, on: self)
                appState.map(\.statistics.dailyGoals)
                    .removeDuplicates()
                    .assign(to: \.dailyGoals, on: self)
            }
        }
        
        func initTripActivities() {
            container.services.statisticService.initTripActivities()
        }
        
        func updateTripCounters() {
            GoalType.allCases.forEach {
                container.services.statisticService.updateTripCounter(for: $0)
            }
        }

        func getTripActivity(for type: GoalType) -> TripActivity {
            guard let tripActivity = tripActivities.first(where: { $0.type == type }) else {
                print("Couldn't find any tripActivity with this type. Creating new one.")
                let tripActivity = TripActivity(type: type, counter: 0)
                container.services.statisticService.addTripActivity(tripActivity: tripActivity)
                return tripActivity
            }
            return tripActivity
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
        
        func setPopToRoot(to popToRoot: Bool) {
            container.services.generalSerive.setPopToRoot(to: popToRoot)
        }
    }
}


// MARK: - Preview

#if DEBUG
struct RoutingSummaryView_Previews: PreviewProvider {
    static var previews: some View {
        RoutingSummaryView(viewModel: .init(container: .preview),
                           finished: .constant(true))
    }
}
#endif
