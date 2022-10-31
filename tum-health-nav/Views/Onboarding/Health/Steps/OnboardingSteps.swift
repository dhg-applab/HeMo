//
//  OnboardingSteps.swift
//  tum-health-nav
//
//  Created by Nikolai Madlener on 30.05.21.
//  Copyright © 2021 TUM. All rights reserved.
//

import SwiftUI

// MARK: - View

struct OnboardingSteps: View {
    
    @ObservedObject var viewModel: ViewModel
    
    var body: some View {
        VStack(spacing: 0) {
            OnboardingHealthView(viewModel: .init(container: viewModel.container, type: .steps)).offset(y: 80)
            Spacer()
            NavigationLink(destination: OnboardingBikeDistance(viewModel: .init(container: viewModel.container))) {
                Text("Next")
                    .modifier(ButtonHeavyModifier(isDisabled: false, backgroundColor: Color.blue, foregroundColor: Color.white))
            }
        }
        .padding()
        .edgesIgnoringSafeArea(.top)
        .background(Color(UIColor.secondarySystemBackground).edgesIgnoringSafeArea(.all))
        .navigationBarTitle("")
    }
}

// MARK: - ViewModel

extension OnboardingSteps {
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
struct OnboardingSteps_Previews: PreviewProvider {
    static var previews: some View {
        OnboardingSteps(viewModel: .init(container: .preview))
    }
}
#endif
