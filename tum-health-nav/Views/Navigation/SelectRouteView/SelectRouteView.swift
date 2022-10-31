//
//  SelectRouteViewNew.swift
//  tum-health-nav
//
//  Created by Nikolai Madlener on 19.02.21.
//  Copyright © 2021 TUM. All rights reserved.
//

import SwiftUI

// MARK: - View

struct SelectRouteView: View {
    @ObservedObject var viewModel: ViewModel
    @State var trackUser = false
    let inspection = Inspection<Self>()
    
    var body: some View {
        content
            .onReceive(inspection.notice) { self.inspection.visit(self, $0) }
            .navigationBarTitle("Select Route", displayMode: .inline)
            .navigationBarBackButtonHidden(true)
            .navigationBarItems(leading: customBackButton)
    }
    
    private var content: AnyView {
        switch viewModel.otpPlan {
        case .notRequested: return AnyView(notRequestedView)
        case .isLoading: return AnyView(loadingView)
        case let .loaded(otpPlan): return AnyView(loadedView(otpPlan))
        case let .failed(error): return AnyView(failedView(error))
        }
    }
}

// MARK: - Content

private extension SelectRouteView {
    var notRequestedView: some View {
        Text("").onAppear {
            self.viewModel.setNavigationBarHidden(to: false)
            self.viewModel.initOTPPlan()
        }
    }
    
    var loadingView: some View {
        VStack {
            ActivityIndicator(style: .large)
            Text("Calculating your personal route ...")
        }
        .frame(width: 256, height: 128)
        .padding(20)
        .background(Color(red: 100 / 255, green: 100 / 255, blue: 100 / 255, opacity: 0.6 ))
        .cornerRadius(25)
    }
    
    func failedView(_ error: Error) -> some View {
        VStack {
            Text("No Route could be found").bold()
            Spacer()
            Text("Check you internet connection or loose the constraints.").multilineTextAlignment(.center)
            Spacer()
            Divider().edgesIgnoringSafeArea(.all)
            Button(action: { self.viewModel.setPopToRoot(to: false) }) {
                Text("Go Back!")
            }
        }
        .frame(width: 256, height: 128)
        .padding(20)
        .background(Color(red: 100 / 255, green: 100 / 255, blue: 100 / 255, opacity: 0.6 ))
        .cornerRadius(25)
    }
    
    func loadedView(_ otpPlan: OTPPlan) -> some View {
        let mapViewWrapper = MapViewWrapper(trackUser: $trackUser, viewModel: .init(container: viewModel.container, otpPlan: otpPlan))
        return ZStack(alignment: .bottom) {
            mapViewWrapper.edgesIgnoringSafeArea(.all)
            RouteInformation(viewModel: .init(container: viewModel.container, otpPlan: viewModel.otpPlan.value),
                             carouselViewModel: CarouselViewModel(container: viewModel.container))
                .frame(height: 160, alignment: .bottom)
        }
    }
    
    var customBackButton: some View {
        Button(action: {
            self.viewModel.setPopToRoot(to: false)
            self.viewModel.otpPlan.cancelLoading()
        }) {
            Image(systemName: "chevron.backward").font(.headline)
        }
    }
}

// MARK: - ViewModel

extension SelectRouteView {
    class ViewModel: ObservableObject {
        
        // State
        @Published var otpPlan: Loadable<OTPPlan>
        @Published var navigationBarHidden: Bool
        @Published var alert: Bool
        
        // Misc
        let container: DIContainer
        private var cancelBag = CancelBag()
        
        init(container: DIContainer) {
            self.container = container
            let appState = container.appState
            
            _otpPlan = .init(wrappedValue: .notRequested)
            _navigationBarHidden = .init(wrappedValue: appState.value.general.navigationBarHidden)
            _alert = .init(wrappedValue: false)
            
            cancelBag.collect {
                appState.map(\.general.navigationBarHidden)
                    .removeDuplicates()
                    .assign(to: \.navigationBarHidden, on: self)
            }
        }
        
        func setNavigationBarHidden(to navigationBarHidden: Bool) {
            container.services.generalSerive.setNavigationBarHidden(to: navigationBarHidden)
        }
        
        func setActiveCard(index: Int) {
            container.services.generalSerive.setActiveCard(index: index)
        }
        
        func setPopToRoot(to popToRoot: Bool) {
            container.services.generalSerive.setPopToRoot(to: popToRoot)
        }
        
        func initOTPPlan() {
            container.services.tripService.initOTPPlan(otpPlan: loadableSubject(\.otpPlan))
        }
    }
}

// MARK: - Preview

#if DEBUG
struct SelectRouteView_Previews: PreviewProvider {
    static var previews: some View {
        SelectRouteView(viewModel: .init(container: .preview))
    }
}
#endif
