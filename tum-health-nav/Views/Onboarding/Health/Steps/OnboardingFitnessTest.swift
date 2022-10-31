//
//  OnboardingFitnessTest.swift
//  tum-health-nav
//
//  Created by Nikolai Madlener on 19.01.22.
//  Copyright © 2022 TUM. All rights reserved.
//

import SwiftUI

// MARK: - View

struct OnboardingFitnessTest: View {
    
    @ObservedObject var viewModel: ViewModel
    
    var body: some View {
        VStack(spacing: 0) {
            ModeratePaceView(viewModel: .init(container: viewModel.container)).offset(y: 80)
            Spacer()
            NavigationLink(destination: OnboardingHealthPoints(viewModel: .init(container: viewModel.container))) {
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

extension OnboardingFitnessTest {
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
struct OnboardingFitnessTest_Previews: PreviewProvider {
    static var previews: some View {
        NavigationView {
            OnboardingFitnessTest(viewModel: .init(container: .preview))
        }
    }
}
#endif
