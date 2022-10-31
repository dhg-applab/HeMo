//
//  Date+Extension.swift
//  tum-health-nav
//
//  Created by Sven Andabaka on 13.06.20.
//  Copyright © 2020 TUM. All rights reserved.
//

import Foundation

extension Date {
    var arriveByTime: String {
        "leave by: \(self.time)"
    }
    
    var time: String {
        let dateformatter = DateFormatter()
        dateformatter.dateFormat = "HH:mm"
        return "\(dateformatter.string(from: self))"
    }
}

extension Date {
    func dayOfWeek() -> String? {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "EE"
        return dateFormatter.string(from: self).capitalized
        // or use capitalized(with: locale) if you want
    }
}

extension Date {
    func get(_ component: Calendar.Component, calendar: Calendar = Calendar.current) -> Int {
        return calendar.component(component, from: self)
    }
}
 
extension DateFormatter {
    static var month: DateFormatter {
        let formatter = DateFormatter()
        formatter.dateFormat = "MMMM"
        return formatter
    }

    static var monthAndYear: DateFormatter {
        let formatter = DateFormatter()
        formatter.dateFormat = "MMMM yyyy"
        return formatter
    }
    
    static var dayAndMonth: DateFormatter {
        let formatter = DateFormatter()
        formatter.dateFormat = "dd. MMM."
        return formatter
    }
}

extension Calendar {
    func generateDates(
        inside interval: DateInterval,
        matching components: DateComponents
    ) -> [Date] {
        var dates: [Date] = []
        dates.append(interval.start)

        enumerateDates(
            startingAfter: interval.start,
            matching: components,
            matchingPolicy: .nextTime
        ) { date, _, stop in
            if let date = date {
                if date < interval.end {
                    dates.append(date)
                } else {
                    stop = true
                }
            }
        }

        return dates
    }
}

extension Date {
    static var yesterday: Date { Date().dayBefore }
    static var tomorrow: Date { Date().dayAfter }
    var dayBefore: Date {
        Calendar.current.date(byAdding: .day, value: -1, to: noon)!
    }
    var dayAfter: Date {
        Calendar.current.date(byAdding: .day, value: 1, to: noon)!
    }
    var noon: Date {
        Calendar.current.date(bySettingHour: 12, minute: 0, second: 0, of: self)!
    }
    var month: Int {
        Calendar.current.component(.month, from: self)
    }
    var isLastDayOfMonth: Bool {
        dayAfter.month != month
    }
}

extension TimeZone {
    static let gmt = TimeZone(secondsFromGMT: 0)!
}
extension Formatter {
    static let date = DateFormatter()
}

extension Date {
    func localizedDescription(dateStyle: DateFormatter.Style = .medium,
                              timeStyle: DateFormatter.Style = .medium,
                              in timeZone: TimeZone = .current,
                              locale: Locale = .current) -> String {
        Formatter.date.locale = locale
        Formatter.date.timeZone = timeZone
        Formatter.date.dateStyle = dateStyle
        Formatter.date.timeStyle = timeStyle
        return Formatter.date.string(from: self)
    }
    var localizedDescription: String { localizedDescription() }
    
    var shortDate: String { localizedDescription(dateStyle: .short, timeStyle: .none) }
}

extension Date {
    func localDate() -> Date {
        let nowUTC = Date()
        let timeZoneOffset = Double(TimeZone.current.secondsFromGMT(for: nowUTC))
        guard let localDate = Calendar.current.date(byAdding: .second, value: Int(timeZoneOffset), to: nowUTC) else {
            return Date()
        }

        return localDate
    }
}

extension Calendar {
    func startOfMonth(_ date: Date) -> Date {
        self.date(from: self.dateComponents([.year, .month], from: date))!
    }
}
