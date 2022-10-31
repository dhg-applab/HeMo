//
//  ContraintPreferencesView.swift
//  tum-health-nav
//
//  Created by Nikolai Madlener on 29.05.21.
//  Copyright © 2021 TUM. All rights reserved.
//

import SwiftUI

// MARK: - View

struct ConstraintPreferencesView: View {

    @ObservedObject var viewModel: ViewModel
    var disabledOpacity: Double
    
    var body: some View {
        Group {
            Toggle("Set Constraints Automatically", isOn: $viewModel.calculatePreferencesAutomatically)
//                Picker("What mode do you prefer", selection: $viewModel.preferedMode) {
//                    Text(OTPRequestMode.walk.OTPString).tag(OTPRequestMode.walk)
//                    Text(OTPRequestMode.bicycle.OTPString).tag(OTPRequestMode.bicycle)
//                }
//                .opacity(viewModel.calculatePreferencesAutomatically ? 1 : 0)
//                .disabled(!viewModel.calculatePreferencesAutomatically)
//                .pickerStyle(SegmentedPickerStyle())
        }.padding(.horizontal)
        
        ForEach(viewModel.constraintPreferences) { constraint in
            ConstraintCell(viewModel: .init(container: viewModel.container, constraint: constraint))
                .padding([.top, .horizontal])
                .opacity(constraint.active ? (viewModel.calculatePreferencesAutomatically ? disabledOpacity : 1) : 0)
                .disabled(!constraint.active || viewModel.calculatePreferencesAutomatically)
                .animation(viewModel.calculatePreferencesAutomatically ? .default : .none)
        }
    }
}

// MARK: - ViewModel

extension ConstraintPreferencesView {
    class ViewModel: ObservableObject {
        
        // State
        @Published var constraintPreferences: [RangeDistanceConstraintPreference]
        @Published var calculatePreferencesAutomatically: Bool {
            didSet {
                calculateOptimalConstraints()
            }
        }
        @Published var preferedMode: OTPRequestMode
        
        // Misc
        let container: DIContainer
        private var cancelBag = CancelBag()
        
        init(container: DIContainer) {
            self.container = container
            let appState = container.appState
            
            _constraintPreferences = .init(wrappedValue: appState.value.navigationConstraints.constraintPreferences)
            _calculatePreferencesAutomatically = .init(initialValue: appState.value.navigationConstraints.calculatePreferencesAutomatically)
            _preferedMode = .init(initialValue: appState.value.navigationConstraints.preferedMode)
            
            cancelBag.collect {
                
                appState.map(\.navigationConstraints.constraintPreferences)
                    .removeDuplicates()
                    .assign(to: \.constraintPreferences, on: self)
                
                $calculatePreferencesAutomatically
                    .sink { appState[\.navigationConstraints.calculatePreferencesAutomatically] = $0 }
                appState.map(\.navigationConstraints.calculatePreferencesAutomatically)
                    .removeDuplicates()
                    .assign(to: \.calculatePreferencesAutomatically, on: self)

                appState.map(\.navigationConstraints.preferedMode)
                    .removeDuplicates()
                    .assign(to: \.preferedMode, on: self)
            }
        }
        
        func calculateOptimalConstraints() {
            if !calculatePreferencesAutomatically {
                return
            }
            container.services.navigationConstraintService.calculateOptimalConstraints()
        }
    }
}

// MARK: - Preview

#if DEBUG

struct ConstraintPreferencesView_Previews: PreviewProvider {
    static var previews: some View {
        ConstraintPreferencesView(viewModel: .init(container: .preview), disabledOpacity: 0.5)
    }
}
#endif
