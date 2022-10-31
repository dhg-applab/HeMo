//
//  LegInformationCell.swift
//  tum-health-nav
//
//  Created by Sven Andabaka on 22.06.20.
//  Copyright © 2020 TUM. All rights reserved.
//

import SwiftUI

// MARK: - View

struct LegInformationCell: View {
    
    var leg: Leg
    
    var headerText: String {
        "\(leg.mode) \(getDistanceString(distance: Int(leg.distance))) to \(leg.toPlace.name)"
    }
    
    var timeText: String {
        "\(leg.startTime.time) - \(leg.endTime.time)"
    }
    
    var distanceText: String {
        "\(getDistanceString(distance: Int(leg.distance)))"
    }
    
    var body: some View {
        VStack {
            Text(headerText).bold()
            HStack {
                Text(timeText)
                Text(distanceText)
            }.padding(.horizontal, 30)
        }
        .frame(width: 250, height: 100, alignment: .center)
        .foregroundColor(Color.white)
        .background(Color(UIColor.systemGray4))
        .cornerRadius(20)
    }
    
    private func getDistanceString(distance: Int) -> String {
        if distance < 1000 {
            return "\(distance) m"
        }
        return "\(String(format: "%.1f", Double(distance) / 1000)) km"
    }
}

// MARK: - Preview

#if DEBUG
// swiftlint:disable force_unwrapping
struct LegInformationCell_Previews: PreviewProvider {
    static var previews: some View {
        LegInformationCell(leg: OTPPlan.mock.itineraries.first!.legs.first!)
    }
}
#endif
