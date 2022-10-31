//
//  Preferences.swift
//  tum-health-nav
//
//  Created by Nikolai Madlener on 13.02.21.
//  Copyright © 2021 TUM. All rights reserved.
//

import Foundation

protocol Preference: Identifiable, Codable, Equatable { }

struct ModePreference: Preference {
    var id: UUID
    var value: Bool
    let mode: OTPRequestMode
    
    init(value: Bool, mode: OTPRequestMode) {
        self.id = UUID()
        self.value = value
        self.mode = mode
    }
    
    // MARK: - Codable
    enum CodingKeys: String, CodingKey {
        case value
        case mode
    }

    // MARK: - Codable
    init(from decoder: Decoder) throws {
        self.id = UUID()
        let values = try decoder.container(keyedBy: CodingKeys.self)
        value = try values.decode(Bool.self, forKey: .value)
        mode = try values.decode(OTPRequestMode.self, forKey: .mode)
    }

    // MARK: - Encodable
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(value, forKey: .value)
        try container.encode(mode, forKey: .mode)
    }
}

struct DistanceConstraintPreference: Preference {
    var id: UUID
    var value: Double
    var mode: OTPRequestMode
    let conditionOperator: OTPRequestConditionOperator
     
    init(value: Double, mode: OTPRequestMode, conditionOperator: OTPRequestConditionOperator) {
        self.id = UUID()
        self.value = value
        self.mode = mode
        self.conditionOperator = conditionOperator
    }
    
    // MARK: - Codable
    enum CodingKeys: String, CodingKey {
        case value
        case mode
        case conditionOperator
    }

    // MARK: - Codable
    init(from decoder: Decoder) throws {
        self.id = UUID()
        let values = try decoder.container(keyedBy: CodingKeys.self)
        value = try values.decode(Double.self, forKey: .value)
        mode = try values.decode(OTPRequestMode.self, forKey: .mode)
        conditionOperator = try values.decode(OTPRequestConditionOperator.self, forKey: .conditionOperator)
    }

    // MARK: - Encodable
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(value, forKey: .value)
        try container.encode(mode, forKey: .mode)
        try container.encode(conditionOperator, forKey: .conditionOperator)
    }
    
    func getValueAsString(endless: Bool) -> String {
        if !endless {
            return "\(String(format: "%.1f", value / 1000)) km"
        }
        return "\u{221e}"
    }
    
    func getOTPRequestConstraint() -> FinalOTPRequestConstraint {
        FinalOTPRequestConstraint(
            constraintType: .hard,
            context: OTPRequestContext(
                transportationMode: mode,
                location: nil,
                timeInterval: nil
            ),
            condition: OTPRequestCondition(
                valueType: .distance,
                value: value,
                operator: conditionOperator
            )
        )
    }
}

struct RangeDistanceConstraintPreference: Preference {
    var id: UUID
    var lowerBound: DistanceConstraintPreference
    var upperBound: DistanceConstraintPreference
    let maxValue: Double
    var active = true
    
    var range: ClosedRange<Double> {
        get {
            ClosedRange(uncheckedBounds: (lowerBound.value / maxValue, upperBound.value / maxValue))
        }
        set {
            lowerBound.value = newValue.lowerBound * maxValue
            upperBound.value = newValue.upperBound * maxValue
        }
    }
    
    var stringforRange: String {
        "\(lowerBound.getValueAsString(endless: false)) - \(upperBound.getValueAsString(endless: range.upperBound == 1))"
    }
    
    init(lowerBound: DistanceConstraintPreference, upperBound: DistanceConstraintPreference, maxValue: Double) {
        self.id = UUID()
        self.lowerBound = lowerBound
        self.upperBound = upperBound
        self.maxValue = maxValue
        range = (lowerBound.value / maxValue)...(upperBound.value / maxValue)
    }
    
    // MARK: - Codable
    enum CodingKeys: String, CodingKey {
        case lowerBound
        case upperBound
        case maxValue
        case range
        case active
    }

    // MARK: - Codable
    init(from decoder: Decoder) throws {
        self.id = UUID()
        let values = try decoder.container(keyedBy: CodingKeys.self)
        lowerBound = try values.decode(DistanceConstraintPreference.self, forKey: .lowerBound)
        upperBound = try values.decode(DistanceConstraintPreference.self, forKey: .upperBound)
        maxValue = try values.decode(Double.self, forKey: .maxValue)
        range = try values.decode(ClosedRange<Double>.self, forKey: .range)
        active = try values.decode(Bool.self, forKey: .active)
    }

    // MARK: - Encodable
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(lowerBound, forKey: .lowerBound)
        try container.encode(upperBound, forKey: .upperBound)
        try container.encode(maxValue, forKey: .maxValue)
        try container.encode(range, forKey: .range)
        try container.encode(active, forKey: .active)
    }
    
    func getOTPRequestConstraints() -> [FinalOTPRequestConstraint] {
        var otpConstraints = [FinalOTPRequestConstraint]()
        if range.lowerBound != 0 {
            otpConstraints.append(lowerBound.getOTPRequestConstraint())
        }
        if range.upperBound != 1 {
            otpConstraints.append(upperBound.getOTPRequestConstraint())
        }
        return otpConstraints
    }
}
