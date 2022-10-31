//
//  OTPRequest.swift
//  tum-health-nav
//
//  Created by Sven Andabaka on 12.06.20.
//  Copyright © 2020 TUM. All rights reserved.
//

import Foundation
import CoreLocation

struct OTPRequest {
    let date: Date
    let fromPlace: CLLocationCoordinate2D
    let toPlace: CLLocationCoordinate2D
    let modes: [OTPRequestMode]
    let bikeLocation: CLLocationCoordinate2D?
    let constraints: OTPRequestConstraintWrapper?
    
    func getDate() -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "MM-dd-yyyy"
        return formatter.string(from: date)
    }
    
    func getTime() -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "hh:mma"
        return formatter.string(from: date)
    }
    
    func getStringForPlace(place: CLLocationCoordinate2D) -> String {
        "\(place.latitude.description),\(place.longitude.description)"
    }
    
    func getMode() -> String {
        var ret = ""
        
        for mode in modes {
            ret = "\(ret)\(mode.OTPString)"
            if mode != modes.last {
                ret = "\(ret), "
            }
        }
        
        return ret
    }
    
    func getBikeLocation() -> String {
        ""
    }
    
    func getConstraints() -> String {
        guard let constraints = constraints else {
            return ""
        }
        
        let jsonEncoder = JSONEncoder()
        do {
            let jsonData = try jsonEncoder.encode(constraints)
            let jsonString = String(data: jsonData, encoding: .utf8) ?? ""
            print("JsonConstraint: " + jsonString)
            return jsonString
        } catch {
            print("Encoding Constraints failed.")
        }
        return ""
    }
}
