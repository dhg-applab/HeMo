//
//  ModePreferencesView.swift
//  tum-health-nav
//
//  Created by Nikolai Madlener on 29.05.21.
//  Copyright © 2021 TUM. All rights reserved.
//

import SwiftUI

// MARK: - View

struct ModePreferencesView: View {
    
    @ObservedObject var viewModel: ViewModel
    
    var body: some View {
        HStack {
            ForEach(viewModel.modePreferences) { mode in
                Spacer()
                ModeCell(modePreference: mode)
                    .onTapGesture {
                        withAnimation(.easeInOut(duration: 0.25)) {
                            viewModel.toggleMode(for: mode)
                        }
                    }
                Spacer()
            }
        }.padding(.horizontal)
    }
}

// MARK: - ViewModel

extension ModePreferencesView {
    class ViewModel: ObservableObject {
        
        // State
        @Published var modePreferences: [ModePreference]
        
        // Misc
        let container: DIContainer
        private var cancelBag = CancelBag()
        
        init(container: DIContainer) {
            self.container = container
            let appState = container.appState
            
            _modePreferences = .init(initialValue: appState.value.navigationConstraints.modePreferences)
            
            cancelBag.collect {
                appState.map(\.navigationConstraints.modePreferences)
                    .removeDuplicates()
                    .assign(to: \.modePreferences, on: self)
            }
        }
        
        func toggleMode(for modePreference: ModePreference) {
            container.services.navigationConstraintService.toggleMode(for: modePreference)
        }
    }
}


// MARK: - Preview

#if DEBUG
struct ModePreferencesView_Previews: PreviewProvider {
    static var previews: some View {
        ModePreferencesView(viewModel: .init(container: .preview))
    }
}
#endif
