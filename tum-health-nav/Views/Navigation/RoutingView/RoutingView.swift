//
//  NavigationView.swift
//  tum-health-nav
//
//  Created by Sven Andabaka on 19.06.20.
//  Copyright © 2020 TUM. All rights reserved.
//

import SwiftUI

// MARK: - View

struct RoutingView: View {

    @ObservedObject var viewModel: ViewModel
    
    var itinerary: Itinerary
    
    @State var finished = false
    @State var trackUser = false
    
    var body: some View {
        let mapViewWrapper = MapViewWrapper(trackUser: $trackUser, viewModel: .init(container: viewModel.container, otpPlan: viewModel.otpPlan))
        
        ZStack(alignment: .bottom) {
            mapViewWrapper
                .followUserWithCourse()
                .zoomLevel(17.5)
                .edgesIgnoringSafeArea(.all)
            RoutingInformationView(itinerary: itinerary)
                .frame(height: 120, alignment: .bottom)
        }
        .navigationBarItems(trailing: getCancelButton())
        .sheet(isPresented: self.$finished) {
            RoutingSummaryView(viewModel: .init(container: viewModel.container),
                               finished: self.$finished)
        }
    }
    
    func getCancelButton() -> AnyView {
        AnyView(Button(action: {
            self.viewModel.updateTripEndDate(date: Date())
            self.finished = true
        }) {
            Text("Finish").foregroundColor(Color.red)
        })
    }
}

// MARK: - ViewModel

extension RoutingView {
    class ViewModel: ObservableObject {

        // State
        @Published var otpPlan: OTPPlan?
        
        // Misc
        let container: DIContainer
        
        init(container: DIContainer, otpPlan: OTPPlan?) {
            self.container = container
            
            _otpPlan = .init(wrappedValue: otpPlan)
        }
        
        func updateTripEndDate(date: Date) {
            container.services.tripService.updateTripEndDate(date: date)
        }
    }
}


// MARK: - Preview

#if DEBUG
struct RoutingView_Previews: PreviewProvider {
    static var previews: some View {
        // swiftlint:disable force_unwrapping
        RoutingView(viewModel: .init(container: .preview, otpPlan: OTPPlan.mock), itinerary: OTPPlan.mock.itineraries.first!)
    }
}
#endif
