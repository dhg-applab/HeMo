//
//  UserLocation.swift
//  tum-health-nav
//
//  Created by Sven Andabaka on 28.06.20.
//  Copyright © 2020 TUM. All rights reserved.
//

import Foundation
import CoreLocation

class UserLocation: NSObject, CLLocationManagerDelegate {
    
    let locationManager: CLLocationManager
    var coordinate: CLLocationCoordinate2D?
    
    override init() {
        locationManager = CLLocationManager()
        super.init()
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.requestWhenInUseAuthorization()
        locationManager.requestLocation()
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        coordinate = manager.location?.coordinate
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print("error:: \(error)")
    }
}
