//
//  OnboardingLocation.swift
//  tum-health-nav
//
//  Created by Nikolai Madlener on 15.05.21.
//  Copyright © 2021 TUM. All rights reserved.
//

import SwiftUI

// MARK: - View

struct OnboardingLocation: View {
    
    @ObservedObject var viewModel: ViewModel
    @State var permissionsButtonPressed = false
    
    var body: some View {
        VStack(spacing: 0) {
            Spacer().frame(height: 80)
            VStack(spacing: 16) {
                Image(systemName: "location.fill")
                    .resizable()
                    .frame(width: 40, height: 40)
                Text("Location")
                    .font(.system(size: 32, weight: .bold))
                    .multilineTextAlignment(.center)
                HStack(alignment: .center) {
                    Text("TUM Healthy Navigation needs access to your location to navigate you to your destinations.")
                        .fixedSize(horizontal: false, vertical: true)
                        .font(.callout)
                        .multilineTextAlignment(.center)
                }
                Spacer()
                getNextButton()
            }.padding()
        }
        .edgesIgnoringSafeArea(.top)
        .background(Color(UIColor.secondarySystemBackground).edgesIgnoringSafeArea(.all))
    }
    
    func getNextButton() -> AnyView {
        if permissionsButtonPressed {
            return AnyView(
                Button(action: {
                    viewModel.setOnboarded()
                }) {
                    Text("Let's Go")
                        .modifier(ButtonHeavyModifier(isDisabled: false, backgroundColor: Color.blue, foregroundColor: Color.white))
                }
            )
        } else {
            return AnyView(
                Button(action: {
                    viewModel.requestLocationPermission()
                    permissionsButtonPressed.toggle()
                }) {
                    Text("Open Permissions")
                        .modifier(ButtonHeavyModifier(isDisabled: false, backgroundColor: Color.green, foregroundColor: Color.white))
                }
            )
        }
    }
}

// MARK: - ViewModel

extension OnboardingLocation {
    class ViewModel: ObservableObject {
        
        // Misc
        let container: DIContainer
        
        init(container: DIContainer) {
            self.container = container
        }
        
        func requestLocationPermission() {
            UserLocation().locationManager.requestLocation()
        }
        
        func setOnboarded() {
            container.services.generalSerive.setOnboarded()
        }
    }
}

// MARK: - Preview

#if DEBUG
struct OnboardingLocation_Previews: PreviewProvider {
    static var previews: some View {
        OnboardingLocation(viewModel: .init(container: .preview))
    }
}
#endif
