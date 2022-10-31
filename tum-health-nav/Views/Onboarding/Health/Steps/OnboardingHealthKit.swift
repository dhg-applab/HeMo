//
//  OnboardingHealthKit.swift
//  tum-health-nav
//
//  Created by Nikolai Madlener on 15.05.21.
//  Copyright © 2021 TUM. All rights reserved.
//

import SwiftUI

// MARK: - View

struct OnboardingHealthKit: View {
    
    @ObservedObject var viewModel: ViewModel
    @State var permissionsButtonPressed = false
    
    var body: some View {
            VStack(spacing: 0) {
                VStack(spacing: 16) {
                    Spacer().frame(height: 60)
                    Image(systemName: "waveform.path.ecg")
                        .resizable()
                        .frame(width: 40, height: 40)
                    Text("HealthKit")
                        .font(.system(size: 32, weight: .bold))
                        .multilineTextAlignment(.center)
                    HStack {
                        Spacer()
                        // swiftlint:disable line_length
                        Text("TUM Healthy Navigation needs access to Apple HealthKit to suggest you tailored routes that support you reaching your activity goals. No health data will leave your phone at any time.")
                            .fixedSize(horizontal: false, vertical: true)
                            .font(.callout)
                            .multilineTextAlignment(.center)
                        Spacer()
                    }
                    Spacer()
                    getButton()
                }
                .padding()
            }
            .edgesIgnoringSafeArea(.top)
            .background(Color(UIColor.secondarySystemBackground).edgesIgnoringSafeArea(.all))
    }
    
    func getButton() -> AnyView {
        if permissionsButtonPressed {
            return AnyView(
                NavigationLink(destination: OnboardingPreferences(viewModel: .init(container: viewModel.container))) {
                Text("Next")
                    .modifier(ButtonHeavyModifier(isDisabled: false, backgroundColor: Color.blue, foregroundColor: Color.white))
                }
            )
        } else {
            return AnyView(
                Button(action: { viewModel.requestAllHealthKitPermissions()
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

extension OnboardingHealthKit {
    class ViewModel: ObservableObject {
        
        // Misc
        let container: DIContainer
        
        init(container: DIContainer) {
            self.container = container
        }
        
        func requestAllHealthKitPermissions() {
            container.services.statisticService.requestAllHealthDataTypes()
        }
    }
}

// MARK: - Preview

#if DEBUG
struct OnboardingHealthKit_Previews: PreviewProvider {
    static var previews: some View {
        OnboardingHealthKit(viewModel: .init(container: .preview))
    }
}
#endif
