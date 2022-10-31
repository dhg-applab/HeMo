//
//  CLLocationCoordinate2d+Equotable.swift
//  tum-health-nav
//
//  Created by Nikolai Madlener on 30.01.21.
//  Copyright © 2021 TUM. All rights reserved.
//

import MapKit

extension CLLocationCoordinate2D: Equatable { }

public func == (lhs: CLLocationCoordinate2D, rhs: CLLocationCoordinate2D) -> Bool {
    lhs.latitude == rhs.latitude && lhs.longitude == rhs.longitude
}
