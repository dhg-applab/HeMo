//
//  DistanceData.swift
//  tum-health-nav
//
//  Created by Yoe Yu on 19.01.22.
//  Copyright © 2022 TUM. All rights reserved.
//

import Foundation

enum IntensityType: String, Codable {
    case slow, moderate, high
}

public struct GPSLog: Codable {
    var timestamp: [String]
    var latitude: [String]
    var longitude: [String]
    var altitude: [String]
    var locationSpeed: [String]
}

public struct DistanceData: Codable {
    let startTime: String
    let endTime: String
    let distanceTravel: Double
    let intensityType: IntensityType
    let walkingSpeed: Double
    let gpsLogs: GPSLog
    
    enum CodingKeys: String, CodingKey {
        case startTime
        case endTime
        case distanceTravel
        case intensityType
        case walkingSpeed
        case gpsLogs
    }
    
    var dictionary: [String: Any] {
        let data = (try? JSONEncoder().encode(self)) ?? Data()
        return (try? JSONSerialization.jsonObject(with: data, options: .mutableContainers) as? [String: Any]) ?? [:]
    }
}
