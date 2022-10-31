//
//  BiometricalProfileView.swift
//  tum-health-nav
//
//  Created by Sven Andabaka on 07.06.20.
//  Copyright © 2020 TUM. All rights reserved.
//

import SwiftUI
import HealthKit

// MARK: - View

struct BiometricalProfileView: View {
    
    @ObservedObject var viewModel: ViewModel

    // swiftlint:disable closure_body_length
    var body: some View {
        VStack(alignment: .leading) {
            Form {
                Section {
                    HStack {
                        Text("First Name")
                        Spacer()
                        TextField("First Name", text: $viewModel.firstName).multilineTextAlignment(.trailing)
                    }
                    HStack {
                        Text("Last Name")
                        Spacer()
                        TextField("Last Name", text: $viewModel.lastName).multilineTextAlignment(.trailing)
                    }
                }
                Section(footer: getBirthdayAndSexWarning()) {
                    HStack {
                        Text("Birthday")
                        Spacer()
                        Text("\(viewModel.birthday?.shortDate ?? "...")")
                    }
                    HStack {
                        Text("Sex")
                        Spacer()
                        Text("\(viewModel.sex ?? "...")")
                    }
                }
                Section(footer: getHeightandWeightWarning()) {
                    HStack {
                        Text("Height")
                        Spacer()
                        Text("\(viewModel.height ?? 0) \(preferredUnit(for: HKQuantityTypeIdentifier.height)?.unitString ?? "kg")")
                    }
                    HStack {
                        Text("Weight")
                        Spacer()
                        Text("\(String(format: "%.1f", viewModel.weight ?? 0.0)) \(preferredUnit(for: HKQuantityTypeIdentifier.bodyMass)?.unitString ?? "kg")")
                    }
                    HStack {
                        Text("BMI")
                        Spacer()
                        Text("\(String(format: "%.1f", viewModel.bmi ?? 0.0))")
                    }
                }
            }
            Spacer()
        }
        .onAppear {
            self.viewModel.updateFromHealthKit()
        }
    }
    
    func getHeightandWeightWarning() -> AnyView {
        var string = ""
        if viewModel.height == nil && viewModel.weight == nil {
            string = "Height and Weight"
        } else if viewModel.height == nil {
            string = "Height"
        } else if viewModel.weight == nil {
            string = "Weight"
        }
        if viewModel.height == nil || viewModel.weight == nil {
            return AnyView(
                Text("Please set your \(string) in your Apple Health Profile and allow the access.")
                    .foregroundColor(Color.red)
            )
        }
        return AnyView(EmptyView())
    }
    
    func getBirthdayAndSexWarning() -> AnyView {
        var string = ""
        if viewModel.sex == nil && viewModel.birthday == nil {
            string = "Birthday and Sex"
        } else if viewModel.birthday == nil {
            string = "Birthday"
        } else if viewModel.sex == nil {
            string = "Sex"
        }
        if viewModel.sex == nil || viewModel.birthday == nil {
            return AnyView(
                Text("Please set your \(string) in your Apple Health Profile and allow the access.")
                    .foregroundColor(Color.red)
            )
        }
        return AnyView(EmptyView())
    }
}

// MARK: - ViewModel
extension BiometricalProfileView {
    class ViewModel: ObservableObject {
        
        // State
        @Published var firstName: String
        @Published var lastName: String
        @Published var weight: Double?
        @Published var height: Int?
        @Published var birthday: Date?
        @Published var sex: String?
        var bmi: Double? {
            guard let height = height,
                  let weight = weight else {
                return nil
            }

            return weight / ((Double(height) / 100) * (Double(height) / 100))
        }
        
        // Misc
        let container: DIContainer
        private var cancelBag = CancelBag()
        
        init(container: DIContainer) {
            self.container = container
            let appState = container.appState
            _firstName = .init(wrappedValue: appState.value.profile.firstName)
            _lastName = .init(wrappedValue: appState.value.profile.lastName)
            _weight = .init(wrappedValue: appState.value.profile.weight)
            _height = .init(wrappedValue: appState.value.profile.height)
            _birthday = .init(wrappedValue: appState.value.profile.birthday)
            _sex = .init(wrappedValue: appState.value.profile.sex)
            
            cancelBag.collect {
                $firstName
                    .sink { appState[\.profile.firstName] = $0 }
                appState.map(\.profile.firstName)
                    .removeDuplicates()
                    .assign(to: \.firstName, on: self)
                
                $lastName
                    .sink { appState[\.profile.lastName] = $0 }
                appState.map(\.profile.lastName)
                    .removeDuplicates()
                    .assign(to: \.lastName, on: self)
                
                appState.map(\.profile.weight)
                    .removeDuplicates()
                    .assign(to: \.weight, on: self)
                
                appState.map(\.profile.height)
                    .removeDuplicates()
                    .assign(to: \.height, on: self)
                
                appState.map(\.profile.birthday)
                    .removeDuplicates()
                    .assign(to: \.birthday, on: self)
                
                appState.map(\.profile.sex)
                    .removeDuplicates()
                    .assign(to: \.sex, on: self)
            }
        }
        
        func updateFromHealthKit() {
            updateHeightFromHealthKit()
            updateWeightFromHealthKit()
            getBirthdayFromHealthKit()
            getSexFromHealthKit()
        }
        
        private func updateWeightFromHealthKit() {
            container.services.profileService.updateWeightFromHealthKit()
        }
        
        private func updateHeightFromHealthKit() {
            container.services.profileService.updateHeightFromHealthKit()
        }
   
        private func getBirthdayFromHealthKit() {
            container.services.profileService.updateBirthdayFromHealthKit()
        }
        
        private func getSexFromHealthKit() {
            container.services.profileService.updateSexFromHealthKit()
        }
    }
}

// MARK: - Preview

#if DEBUG
struct BiometricalProfileView_Previews: PreviewProvider {
    static var previews: some View {
        BiometricalProfileView(viewModel: .init(container: .preview))
    }
}
#endif
