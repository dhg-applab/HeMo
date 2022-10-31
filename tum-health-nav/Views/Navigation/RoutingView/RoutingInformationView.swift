//
//  RoutingInformationView.swift
//  tum-health-nav
//
//  Created by Sven Andabaka on 22.06.20.
//  Copyright © 2020 TUM. All rights reserved.
//

import SwiftUI

// MARK: - View

struct RoutingInformationView: View {
    
    var itinerary: Itinerary
    
    var body: some View {
        ScrollView(.horizontal) {
            HStack {
                ForEach(itinerary.legs, id: \.id) { leg in
                    LegInformationCell(leg: leg)
                }
            }.padding(4)
        }
    }
}

// MARK: - Preview

#if DEBUG
struct RoutingInformationView_Previews: PreviewProvider {
    static var previews: some View {
        // swiftlint:disable force_unwrapping
        RoutingInformationView(itinerary: OTPPlan.mock.itineraries.first!)
    }
}
#endif
