//
//  OTPResponse.swift
//  tum-health-nav
//
//  Created by Sven Andabaka on 12.06.20.
//  Copyright © 2020 TUM. All rights reserved.
//

import Foundation
import CoreLocation
import Polyline
import Combine

enum RouteMode: String, Decodable {
    case walk = "WALK"
    case bicycle = "BICYCLE"
    case car = "CAR"
    case tram = "TRAM"
    case subway = "SUBWAY"
    case rail = "RAIL"
    case bus = "BUS"
    case transit = "TRANSIT"
}

struct Place: Decodable {
    let name: String
    let lon: Double
    let lat: Double
    let departure: Date?
    let arrival: Date?
    
    var coordinate: CLLocationCoordinate2D {
        CLLocationCoordinate2D(latitude: lat, longitude: lon)
    }
}

struct Leg: Decodable {
    let startTime: Date
    let endTime: Date
    let distance: Double
    let mode: RouteMode
    let fromPlace: Place
    let toPlace: Place
    let geometry: String
    let duration: Double
    
    func getPolyline() -> [CLLocationCoordinate2D] {
        decodePolyline(geometry) ?? []
    }
    
    var id: String {
        "\(startTime)-\(endTime)-\(mode)-\(fromPlace)-\(toPlace)"
    }
}

struct Itinerary: Decodable, Identifiable, Equatable {
    
    static func == (lhs: Itinerary, rhs: Itinerary) -> Bool {
        lhs.duration == rhs.duration
            && lhs.startTime == rhs.startTime
            && lhs.endTime == rhs.endTime
            && lhs.walkTime == rhs.walkTime
            && lhs.walkDistance == rhs.walkDistance
            && lhs.transitTime == rhs.transitTime
            && lhs.waitingTime == rhs.waitingTime
            && lhs.evelationGained == rhs.evelationGained
            && rhs.transfers == lhs.transfers
    }
    
    let duration: TimeInterval
    let startTime: Date
    let endTime: Date
    let walkTime: TimeInterval
    let walkDistance: Double
    let transitTime: TimeInterval
    let waitingTime: TimeInterval
    let evelationGained: Double?
    let transfers: Int
    let legs: [Leg]
    
    var id: Double {
        duration + walkTime + transitTime + startTime.timeIntervalSince1970
    }
    
    func getPolyline() -> [CLLocationCoordinate2D] {
        legs.reduce(into: []) { decodedCoordinates, leg in
            decodedCoordinates.append(contentsOf: decodePolyline(leg.geometry) ?? [])
        }
    }
    
    func getDistance(for mode: RouteMode) -> Int {
        Int(
            legs.filter {
                $0.mode == mode
            }
            .reduce(0.0) { result, leg in
                result + leg.distance
            }
        )
    }
}

struct OTPPlan: Decodable {
    let date: Date
    let fromPlace: Place
    let toPlace: Place
    let itineraries: [Itinerary]
    
    var polylineCoordinates: [[CLLocationCoordinate2D]] {
        var decodedCoordinates: [[CLLocationCoordinate2D]] = []
        
        itineraries.forEach { itinerary in
            decodedCoordinates.append(itinerary.getPolyline())
        }
        
        return decodedCoordinates
    }
}


#if DEBUG

extension OTPPlan {
    private static var otpRequest: OTPRequest {
        OTPRequest(
            date: Date(),
            fromPlace: CLLocationCoordinate2D(latitude: 49.44198, longitude: 11.08456),
            toPlace: CLLocationCoordinate2D(latitude: 49.45803, longitude: 11.07310),
            modes: [OTPRequestMode.transit, OTPRequestMode.bicycle],
            bikeLocation: CLLocationCoordinate2D(latitude: 0, longitude: 0),
            constraints: nil
        )
    }
    
    public static var mock: OTPPlan {
        let itinerary = Itinerary(
                          duration: 24,
                          startTime: Date(),
                          endTime: Date(),
                          walkTime: 24,
                          walkDistance: 22.0,
                          transitTime: 0,
                          waitingTime: 0,
                          evelationGained: nil,
                          transfers: 0,
                          legs: []
                        )
        
        return OTPPlan(date: Date(),
                       fromPlace: Place(name: "Start", lon: 11.08456, lat: 49.44198, departure: nil, arrival: nil),
                       toPlace: Place(name: "End", lon: 11.07310, lat: 49.45803, departure: nil, arrival: nil),
                       itineraries: [itinerary, itinerary, itinerary])
    }
}

#endif
