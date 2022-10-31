//
//  SnapCarouselView.swift
//  tum-health-nav
//
//  Created by Nikolai Madlener on 08.01.21.
//  Copyright © 2021 TUM. All rights reserved.
//

import SwiftUI

// MARK: - View

struct RouteInformation: View {
    @ObservedObject var viewModel: ViewModel
    @ObservedObject var carouselViewModel: CarouselViewModel
    
    var body: some View {
        let spacing: CGFloat = 16
        let widthOfHiddenCards: CGFloat = 32
        let cardHeight: CGFloat = 360
        let itineraries = viewModel.otpPlan?.itineraries ?? []
        
        return Canvas {
            Carousel(
                numberOfItems: CGFloat(itineraries.count),
                spacing: spacing,
                widthOfHiddenCards: widthOfHiddenCards,
                viewModel: carouselViewModel
            ) {
                ForEach(itineraries, id: \.self.id) { itinerary in
                    Item(viewModel: carouselViewModel,
                         contentId: Int(itinerary.id),
                         spacing: spacing,
                         widthOfHiddenCards: widthOfHiddenCards,
                         cardHeight: cardHeight
                    ) {
                        NavigationLink(destination: RoutingView(viewModel: .init(container: viewModel.container, otpPlan: viewModel.otpPlan),
                                                                itinerary: itinerary)) {
                            RouteInformationCell(
                                viewModel: .init(container: viewModel.container),
                                healthPoints: 15,
                                time: itinerary.duration,
                                bikeDistance: itinerary.getDistance(for: .bicycle),
                                walkDistance: Int(itinerary.getDistance(for: .walk)),
                                recommended: self.viewModel.otpPlan?.itineraries.first == itinerary
                            ).padding(4)
                        }.isDetailLink(false)
                    }
                    .transition(AnyTransition.slide)
                    .simultaneousGesture(TapGesture().onEnded { self.viewModel.updateTripStartDate(date: Date()) })
                }
            }.padding(.bottom)
        }
    }
}

// MARK: - ViewModel

extension RouteInformation {
    class ViewModel: ObservableObject {
        
        // State
        @Published var otpPlan: OTPPlan?
        
        // Misc
        let container: DIContainer
        private var cancelBag = CancelBag()
        
        
        init(container: DIContainer, otpPlan: OTPPlan?) {
            self.container = container
            
            _otpPlan = .init(wrappedValue: otpPlan)
        }
        
        func updateTripStartDate(date: Date) {
            container.services.tripService.updateTripStartDate(date: date)
        }
    }
}

// MARK: - Preview

#if DEBUG
struct SnapCarousel_Previews: PreviewProvider {
    static var previews: some View {
        RouteInformation(viewModel: .init(container: .preview, otpPlan: nil),
                         carouselViewModel: CarouselViewModel(container: .preview))
    }
}
#endif
