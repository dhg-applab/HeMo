//
//  TimeInterval+Extension.swift
//  tum-health-nav
//
//  Created by Sven Andabaka on 22.06.20.
//  Copyright © 2020 TUM. All rights reserved.
//

import Foundation

extension TimeInterval {
    
    var timeString: String {
        let time = Int(self)
        if time < 60 {
            return "\(time)s"
        }
        let timeInMinutes = time / 60
        if timeInMinutes < 60 {
            return "\(timeInMinutes)min"
        }
        let minutesOfHours = timeInMinutes % 60
        let minutesOfHoursString = minutesOfHours == 0 ? "" : (minutesOfHours < 10 ? ":0\(minutesOfHours)" : ":\(minutesOfHours)")
        return "\(timeInMinutes / 60)" + minutesOfHoursString + "h"
    }
}
