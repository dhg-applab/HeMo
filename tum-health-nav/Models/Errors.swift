//
//  Error.swift
//  tum-health-nav
//
//  Created by Sven Andabaka on 12.06.20.
//  Copyright © 2020 TUM. All rights reserved.
//

import Foundation

public enum Errors: Error {
    case requestURLWrong
    case otpRequestFailed
}

extension Errors: CustomStringConvertible {
    public var description: String {
        switch self {
        case .requestURLWrong:
            return "The request URL for OTP is wrong."
        case .otpRequestFailed:
            return "The request failed."
        }
    }
}
