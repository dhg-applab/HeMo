//
//  OTPPlan+Equotable.swift
//  tum-health-nav
//
//  Created by Nikolai Madlener on 31.01.21.
//  Copyright © 2021 TUM. All rights reserved.
//

import MapKit

extension OTPPlan: Equatable { }

func == (lhs: OTPPlan, rhs: OTPPlan) -> Bool {
    lhs.itineraries == rhs.itineraries && lhs.itineraries == rhs.itineraries
}
