//
//  config.swift
//  tum-health-nav
//
//  Created by Sven Andabaka on 12.06.20.
//  Copyright © 2020 TUM. All rights reserved.
//

import Foundation
import SwiftUI

enum Config {
    
    // Static keys for host
    static let scheme = "http"
    
    static var host: String {
        let host = UserDefaults.shared.string(forKey: "hosturl") ?? "tumhealthynavigation.health.in.tum.de"
        return host
    }
    
    static var hasTopNotch: Bool {
        if #available(iOS 13.0, *) {
            return UIApplication.shared.windows.first(where: { $0.isKeyWindow })?.safeAreaInsets.top ?? 0 > 20
        } else {
            return UIApplication.shared.delegate?.window??.safeAreaInsets.top ?? 0 > 20
        }
    }
    
    static let port = 5000
    static let path = "/api/route"
    
    // Static keys for parameters
    static let dateParam = "date"
    static let timeParam = "time"
    static let fromParam = "fromPlace"
    static let toParam = "toPlace"
    static let modeParam = "mode"
    static let bikeLocationParam = "bikeLocation"
    static let constraintsParam = "constraint"

    
    static let walkColor = Color(red: 165 / 255, green: 255 / 255, blue: 3 / 255)
    static let bikeColor = Color(red: 44 / 255, green: 143 / 255, blue: 255 / 255)
    static let transitColor = Color(red: 255 / 255, green: 149 / 255, blue: 0 / 255)
    static let carColor = Color(red: 255 / 255, green: 44 / 255, blue: 85 / 255)
    
    static let secondaryBikeColor = Color(red: 133 / 255, green: 162 / 255, blue: 171 / 255)
    static let secondaryWalkColor = Color(red: 141 / 255, green: 156 / 255, blue: 140 / 255)
    static let secondaryTransitColor = Color(red: 148 / 255, green: 138 / 255, blue: 111 / 255)
    static let secondaryCarColor = Color(red: 212 / 255, green: 182 / 255, blue: 182 / 255)
    
    static let recommendationColor = Color(red: 157 / 255, green: 243 / 255, blue: 100 / 255)
    
    // Statistics Colors
    static let metColor = Color.pink
    static let stepColor = Color(red: 165 / 255, green: 255 / 255, blue: 3 / 255)
    static let caloriesColor = Color.yellow
    static let walkDistanceColor = Color(red: 165 / 255, green: 255 / 255, blue: 3 / 255)
    static let bikeDistanceColor = Color.blue
    
    static let top = UIScreen.main.bounds.height * 0.05
    static let bottom = hasTopNotch ? (UIScreen.main.bounds.height - 200) : (UIScreen.main.bounds.height - 140)
}

extension UserDefaults {
    static var shared: UserDefaults = {
        guard let appGroupUserDefaults = UserDefaults(suiteName: "group.com.nikolaimadlener.tum-health-nav") else {
            fatalError("Could not get UserDefaults suite for app group identifier")
        }
        return appGroupUserDefaults
    }()
}
