//
//  PreferencesView.swift
//  tum-health-nav
//
//  Created by Sven Andabaka on 07.06.20.
//  Copyright © 2020 TUM. All rights reserved.
//

import SwiftUI

// MARK: - View

struct PreferencesView: View {
    
    @ObservedObject var viewModel: ViewModel
    
    var body: some View {
        VStack {
            Spacer().frame(height: 40)
            ModePreferencesView(viewModel: .init(container: viewModel.container))
            Spacer().frame(height: 40)
            Divider()
            Spacer().frame(height: 20)
            ConstraintPreferencesView(viewModel: .init(container: viewModel.container), disabledOpacity: 0.5)
            Spacer()
        }
        .background(Color(UIColor.systemGray6))
        .onTapGesture { UIApplication.shared.endEditing() }
    }
}

// MARK: - ViewModel

extension PreferencesView {
    class ViewModel: ObservableObject {
        
        // Misc
        let container: DIContainer
        
        init(container: DIContainer) {
            self.container = container
        }
    }
}

// MARK: - Preview

#if DEBUG
struct PreferencesView_Previews: PreviewProvider {
    static var previews: some View {
        PreferencesView(viewModel: .init(container: .preview))
    }
}
#endif
