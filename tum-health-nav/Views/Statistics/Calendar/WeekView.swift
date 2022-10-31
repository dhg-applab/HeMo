//
//  WeekView.swift
//  tum-health-nav
//
//  Created by Sven Andabaka on 25.07.20.
//  Copyright © 2020 TUM. All rights reserved.
//

import SwiftUI

// MARK: - View

struct WeekView<DateView>: View where DateView: View {
    @Environment(\.calendar) var calendar

    let week: Date
    let content: (Date) -> DateView

    init(
        week: Date,
        @ViewBuilder content: @escaping (Date) -> DateView
    ) {
        self.week = week
        self.content = content
    }

    private var days: [Date] {
        guard
            let weekInterval = calendar.dateInterval(of: .weekOfYear, for: week)
            else { return [] }
        return calendar.generateDates(
            inside: weekInterval,
            matching: DateComponents(hour: 0, minute: 0, second: 0)
        )
    }

    var body: some View {
        HStack(spacing: 5) {
            ForEach(days, id: \.self) { date in
                HStack(spacing: 0) {
                if self.calendar.isDate(self.week, equalTo: date, toGranularity: .month) {
                    self.content(date)
                } else {
                    self.content(date).hidden()
                }
                }
            }
        }
    }
}

// MARK: - Preview

#if DEBUG
struct WeekView_Previews: PreviewProvider {
    static var previews: some View {
        Text("")
    }
}
#endif
