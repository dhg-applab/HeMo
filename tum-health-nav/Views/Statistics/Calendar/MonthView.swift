//
//  MonthView.swift
//  tum-health-nav
//
//  Created by Sven Andabaka on 25.07.20.
//  Copyright © 2020 TUM. All rights reserved.
//

import SwiftUI

// MARK: - View

struct MonthView<DateView>: View where DateView: View {
    @Environment(\.calendar) var calendar

    let month: Date
    let content: (Date) -> DateView

    init(
        month: Date,
        @ViewBuilder content: @escaping (Date) -> DateView
    ) {
        self.month = month
        self.content = content
    }

    private var weeks: [Date] {
        guard
            let monthInterval = calendar.dateInterval(of: .month, for: month)
            else { return [] }
        return calendar.generateDates(
            inside: monthInterval,
            matching: DateComponents(hour: 0, minute: 0, second: 0, weekday: Calendar.current.firstWeekday)
        )
    }

    var body: some View {
        VStack(spacing: 5) {
            Divider()
            ForEach(weeks, id: \.self) { week in
                WeekView(week: week, content: self.content)
                Divider()
            }
        }
    }
}

// MARK: - Preview

#if DEBUG
struct MonthView_Previews: PreviewProvider {
    static var previews: some View {
//        MonthView()
        Text("TODO")
    }
}
#endif
