//
//  WalkingSpeedService.swift
//  tum-health-nav
//
//  Created by Joe Yu on 19.01.22.
//  Copyright © 2022 TUM. All rights reserved.
//

import Foundation
import CoreLocation

public class WalkingSpeedService: NSObject, CLLocationManagerDelegate {
    
    private let locationManager = CLLocationManager()
    var startLocation: CLLocation?
    var lastLocation: CLLocation?
    var distanceTraveled = 0.0
    var gpsLogs = GPSLog(timestamp: [], latitude: [], longitude: [], altitude: [], locationSpeed: [])

    override init() {
        super.init()
        locationManager.requestAlwaysAuthorization()
        
        if CLLocationManager.locationServicesEnabled(){
            locationManager.delegate = self
            locationManager.desiredAccuracy = kCLLocationAccuracyBest
            locationManager.startUpdatingLocation()
        } else {
            print("Need to Enable Location")
        }
    }
    
    func start() {
        distanceTraveled = 0.0
        startLocation = nil
        lastLocation = nil
        gpsLogs = GPSLog(timestamp: [], latitude: [], longitude: [], altitude: [], locationSpeed: [])
        
        
        locationManager.startUpdatingLocation()
    }
    
    func stop() {
        locationManager.stopUpdatingLocation()
    }
    
    func getWalkingSpeed(distance: Double, start: Date, end: Date) -> Double {
        
        let endSeconds = end.timeIntervalSinceReferenceDate
        let startSeconds = start.timeIntervalSinceReferenceDate
        let minutes = Double(endSeconds - startSeconds)
        print("time\(minutes)")
        
        print("walkingSpeed: \(distance / minutes * 3.6)")
        return (distance / minutes) * 3.6
    }
    
    func getWalkingSpeed(distance: Double, seconds: Double) -> Double {
        
        let minutes = seconds/60
        print("time\(minutes)")
        
        print("walkingSpeed: \(distance / minutes * 3.6)")
        return (distance / minutes) * 3.6
    }
    
    public func dateFormatting(date: Date) -> String {
        let dt = date
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "EEEE dd MMMM yyyy - HH:mm:ss"
        let mydt = dateFormatter.string(from: dt).capitalized

        return "\(mydt)"
    }
    
    public func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        
        if let location = locations.last {
            gpsLogs.timestamp.append(dateFormatting(date: location.timestamp))
            gpsLogs.latitude.append(String(location.coordinate.latitude))
            gpsLogs.longitude.append(String(location.coordinate.longitude))
            gpsLogs.altitude.append(String(location.altitude))
            gpsLogs.locationSpeed.append(String(location.speed))
        }
        
        if startLocation == nil {
            startLocation = locations.first as CLLocation?
        } else {
            
            guard let lastLocation = lastLocation else {
                return
            }
            
            guard let locationsLast = locations.last else {
                return
            }

            let lastDistance = lastLocation.distance(from: locationsLast as CLLocation)
            //in
            distanceTraveled += lastDistance
        }
        
        lastLocation = locations.last as CLLocation?
    }
}
