//
//  MainView.swift
//  tum-health-nav
//
//  Created by Sven Andabaka on 07.06.20.
//  Copyright © 2020 TUM. All rights reserved.
//

import SwiftUI

// MARK: - View

struct MainView: View {
    
    @ObservedObject private(set) var viewModel: ViewModel
    
    var modalManager = ModalManager()
    @State var selection = 1
    
    var body: some View {
        if !viewModel.onboarded {
            OnboardingView(viewModel: .init(container: viewModel.container))
        .onAppear {
            viewModel.initDailyGoals()
        }
        } else {
        
        TabView(selection: $selection) {
            MapView(viewModel: .init(container: viewModel.container))
                .tabItem {
                    Image(systemName: "map.fill").imageScale(.large)
                    Text("Navigation")
                }
                .environmentObject(modalManager)
                .tag(1)
            StatisticsView(viewModel: .init(container: viewModel.container))
                .tabItem {
                    Image(systemName: "chart.pie.fill").imageScale(.large)
                    Text("Statistics")
                }
                .tag(2)
        }.onAppear {
            print("MainView")
            viewModel.initModePreferences()
            viewModel.initConstraintPreferences()
            viewModel.initDailyGoals()
            viewModel.initTripActivities()
            viewModel.updateDailyCounters()
            viewModel.updateHistoricCounters()
        }
        }
    }
}

// MARK: - ViewModel

extension MainView {
    class ViewModel: ObservableObject {
        
        // State
        @Published var onboarded: Bool
        
        // Misc
        let container: DIContainer
        private var cancelBag = CancelBag()
        
        init(container: DIContainer) {
            self.container = container
            let appState = container.appState
            _onboarded = .init(wrappedValue: appState.value.general.onboarded)
            
            cancelBag.collect {
                appState.map(\.general.onboarded)
                    .removeDuplicates()
                    .assign(to: \.onboarded, on: self)
            }
        }
        
        func initModePreferences() {
            container.services.navigationConstraintService.initModePreferences()
        }
        
        func initConstraintPreferences() {
            container.services.navigationConstraintService.initConstraintPreferences()
        }
        
        func initDailyGoals() {
            container.services.statisticService.initDailyGoals()
        }
        
        func initTripActivities() {
            container.services.statisticService.initTripActivities()
        }
        
        func updateDailyCounters() {
            GoalType.allCases.forEach {
                container.services.statisticService.updateDailyCounter(for: $0)
            }
        }
        
        func updateHistoricCounters() {
            GoalType.allCases.forEach {
                container.services.statisticService.updateHistoricCounters(for: $0)
            }
        }
    }
}

// MARK: - Preview

#if DEBUG
struct MainView_Previews: PreviewProvider {
    static var previews: some View {
        MainView(viewModel: .init(container: .preview))
    }
}
#endif
