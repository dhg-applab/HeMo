//
//  OTPRequestModels.swift
//  tum-health-nav
//
//  Created by Sven Andabaka on 06.07.20.
//  Copyright © 2020 TUM. All rights reserved.
//

import Foundation
import SwiftUI

// for more information see: http://dev.opentripplanner.org/apidoc/0.15.0/ns0_TraverseMode.html
enum OTPRequestMode: String, Codable {
    
    case transit = "PUBLIC_TRANSPORT"
    case bicycle = "BIKE"
    case walk = "WALK"
    case car = "CAR"
    
    var OTPString: String {
        switch self {
        case .transit:
            return "TRANSIT"
        case .bicycle:
            return "BICYCLE"
        case .walk:
            return "WALK"
        case .car:
            return "CAR"
        }
    }
}

struct OTPRequestConstraintWrapper: Codable {
    var constraints: [NestedOTPRequestConstraint]
}

protocol OTPRequestConstraint: Codable {
    var constraintType: OTPRequestContraintType { get }
}

class NestedOTPRequestConstraint: OTPRequestConstraint, Codable {
    let constraintType = OTPRequestContraintType.nested
    
    let constraints: [FinalOTPRequestConstraint]
    let isOperatorAnd: Bool
    
    init(constraints: [FinalOTPRequestConstraint], isOperatorAnd: Bool) {
        self.constraints = constraints
        self.isOperatorAnd = isOperatorAnd
    }
}

class FinalOTPRequestConstraint: OTPRequestConstraint, Codable {
    var constraintType: OTPRequestContraintType
    
    let penalty: Int?
    let context: OTPRequestContext
    let condition: OTPRequestCondition
    
    internal init(constraintType: OTPRequestContraintType, penalty: Int? = nil, context: OTPRequestContext, condition: OTPRequestCondition) {
        self.constraintType = constraintType
        self.penalty = penalty
        self.context = context
        self.condition = condition
    }
}

struct OTPRequestCondition: Codable {
    let conditionType = OTPRequestConditionType.value
    let valueType: OTPRequestConditionValueType
    let value: Double
    let `operator`: OTPRequestConditionOperator
}

struct OTPRequestContext: Codable {
    let transportationMode: OTPRequestMode
    let location: OTPRequestContextLocation?
    let timeInterval: OTPRequestContextTimeInterval?
}

struct OTPRequestContextLocation: Codable {
    let coordinates: OTPRequestContextLocationCoordinates
}

struct OTPRequestContextLocationCoordinates: Codable {
    let lat: Double
    let lon: Double
}

struct OTPRequestContextTimeInterval: Codable {
    let start: TimeInterval
    let end: TimeInterval
}

enum OTPRequestContraintType: String, Codable {
    case soft
    case hard
    case nested
}

enum OTPRequestConditionType: String, Codable {
    case value
}

enum OTPRequestConditionValueType: String, Codable {
    case distance = "DISTANCE"
    case travelTime = "TRAVEL_TIME"
    case lineChanges = "LINE_CHANGES"
    case modeOccurrences = "MODE_OCCURRENCES"
}

enum OTPRequestConditionOperator: String, Codable {
    case minimumValue = "MinimumValue"
    case maximumValue = "MaximumValue"
    case exactValue = "ExactValue"
}

extension OTPRequestMode {
    var color: Color {
        switch self {
        case .bicycle:
            return Config.bikeColor
        case .walk:
            return Config.walkColor
        case .transit:
            return Config.transitColor
        case .car:
            return Config.carColor
        }
    }
}

extension OTPRequestMode {
    var image: String {
        switch self {
        case .bicycle:
            return "bicycle"
        case .walk:
            return "figure.walk"
        case .car:
            return "car.fill"
        case .transit:
            return "tram.fill"
        }
    }
}
