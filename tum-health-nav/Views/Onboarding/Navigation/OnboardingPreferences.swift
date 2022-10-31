//
//  OnboardingConstraints.swift
//  tum-health-nav
//
//  Created by Nikolai Madlener on 15.05.21.
//  Copyright © 2021 TUM. All rights reserved.
//

import SwiftUI

// MARK: - View
// swiftlint:disable all
struct OnboardingPreferences: View {
    
    @ObservedObject var viewModel: ViewModel
    
    var body: some View {
            VStack(spacing: 0) {
                Spacer().frame(height: 80)
                VStack(spacing: 16) {
                    Image(systemName: "slider.horizontal.3")
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(width: 40, height: 40)
                    Text("Preferences")
                        .font(.system(size: 32, weight: .bold))
                        .multilineTextAlignment(.center)
                    
                    HStack {
                        Text("1").font(.system(size: 50, weight: .bold)).padding(.trailing, 10)
                        Spacer()
                        Text("Choose your prefered transportation modes for your first route.")
                            .fixedSize(horizontal: false, vertical: true)
                            .font(.callout)
                            .multilineTextAlignment(.leading)
                        Spacer()
                    }.padding(.horizontal)
                    
                    ModePreferencesView(viewModel: .init(container: viewModel.container))
                    Spacer().frame(height: 20)
                    
                    HStack {
                        Text("2").font(.system(size: 50, weight: .bold)).padding(.trailing, 10)
                        Spacer()
                        Text("Specify walk and bike consraints or let me decide what fits you best.")
                            .fixedSize(horizontal: false, vertical: true)
                            .font(.callout)
                            .multilineTextAlignment(.leading)
                        Spacer()
                    }.padding(.horizontal)
                    
                    ScrollView {
                        ConstraintPreferencesView(viewModel: .init(container: viewModel.container), disabledOpacity: 0)
                    }

//                    NavigationLink(destination: OnboardingLocation(viewModel: .init(container: viewModel.container))) {
//                        Text("Next")
//                            .modifier(ButtonHeavyModifier(isDisabled: false, backgroundColor: Color.blue, foregroundColor: Color.white))
//                    }
                    Button(action: {
                        viewModel.setOnboarded()
                    }) {
                        Text("Let's Go")
                            .modifier(ButtonHeavyModifier(isDisabled: false, backgroundColor: Color.blue, foregroundColor: Color.white))
                    }
                
                }
                .padding()
                .background(Color(UIColor.secondarySystemBackground).edgesIgnoringSafeArea(.all))
                .onAppear{
                    viewModel.initModePreferences()
                    viewModel.initConstraintPreferences()
                }
            }
            .edgesIgnoringSafeArea(.top)
            .background(Color(UIColor.secondarySystemBackground).edgesIgnoringSafeArea(.all))
        
    }
}

// MARK: - ViewModel

extension OnboardingPreferences {
    class ViewModel: ObservableObject {
        
        // Misc
        let container: DIContainer
        
        init(container: DIContainer) {
            self.container = container
        }
        
        func initModePreferences() {
            container.services.navigationConstraintService.initModePreferences()
        }
        
        func initConstraintPreferences() {
            container.services.navigationConstraintService.initConstraintPreferences()
        }
        
        func setOnboarded() {
            container.services.generalSerive.setOnboarded()
        }
    }
}

// MARK: - Preview

#if DEBUG
struct OnboardingPreferences_Previews: PreviewProvider {
    static var previews: some View {
        OnboardingPreferences(viewModel: .init(container: .preview))
    }
}
#endif

