//
//  OnboardingView.swift
//  tum-health-nav
//
//  Created by Nikolai Madlener on 15.05.21.
//  Copyright © 2021 TUM. All rights reserved.
//

import SwiftUI

// MARK: - View

struct OnboardingView: View {
    
    @ObservedObject var viewModel: ViewModel
    
    var body: some View {
        NavigationView {
            VStack(spacing: 0) {
                VStack(spacing: 16) {
                    Spacer().frame(height: 80)
                    Text("Welcome")
                        .font(.system(size: 32, weight: .bold))
                        .multilineTextAlignment(.center)
                    HStack(alignment: .center) {
                        Text("Your navigation just got healthier.")
                            .fixedSize(horizontal: false, vertical: true)
                            .font(.callout)
                            .multilineTextAlignment(.center)
                    }
                    Spacer()
                    NavigationLink(destination: OnboardingFitnessTest(viewModel: .init(container: viewModel.container))) {
                        Text("Next").modifier(ButtonHeavyModifier(isDisabled: false, backgroundColor: Color.blue, foregroundColor: Color.white))
                    }
                }.padding()
            }
            .background(
                Image("onboarding")
                    .resizable()
                    .scaledToFill()
                    .blur(radius: 8)
                    .overlay(LinearGradient(
                        gradient: .init(colors: [.clear, Color(UIColor.secondarySystemBackground)]),
                        startPoint: .top,
                        endPoint: .bottom
                    ))
                    .edgesIgnoringSafeArea(.all)
            )
        }
        .navigationBarHidden(true)
        .navigationBarTitle("")
    }
}

// MARK: - ViewModel

extension OnboardingView {
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
struct OnboardingView_Previews: PreviewProvider {
    static var previews: some View {
        OnboardingView(viewModel: .init(container: .preview))
    }
}
#endif
