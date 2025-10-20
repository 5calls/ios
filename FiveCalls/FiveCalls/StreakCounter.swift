// Copyright 5calls. All rights reserved. See LICENSE for details.

import Foundation

struct StreakCounter {
    enum IntervalType {
        case Daily
        case Weekly
    }

    let dates: [Date]
    let referenceDate: Date

    init(dates: [Date], referenceDate: Date) {
        self.dates = dates
        self.referenceDate = referenceDate
    }

    var daily: Int {
        getStreakFor(intervalType: .Daily)
    }

    var weekly: Int {
        getStreakFor(intervalType: .Weekly)
    }

    func getStreakFor(intervalType: IntervalType) -> Int {
        var count = 0

        // No events
        if dates.count == 0 {
            return count
        }

        var intervalsApart: (Date, Date) -> Int? = switch intervalType {
        case .Daily:
            StreakCounter.daysApart
        case .Weekly:
            StreakCounter.weeksApart
        }

        let datesDescending = dates.sorted(by: { d1, d2 -> Bool in
            return d1 > d2
        })

        let latestDate = datesDescending[0]
        guard let intervals = intervalsApart(latestDate, referenceDate) else {
            return count
        }

        // An event hasn't occurred in this interval or the last interval
        if intervals > 1 {
            return count
        }

        count += 1
        if dates.count == 1 {
            return count
        }

        var prevDate = latestDate
        for nextDate in datesDescending[1 ... (datesDescending.count - 1)] {
            if let intervals = intervalsApart(nextDate, prevDate), intervals <= 1 {
                if intervals == 1 {
                    count += 1
                }
                prevDate = nextDate
                continue
            }

            break
        }

        return count
    }

    static func daysApart(from: Date, to: Date) -> Int? {
        let calendar = Calendar.current
        let fromDate = calendar.startOfDay(for: from)
        let toDate = calendar.startOfDay(for: to)
        let dateComponents = calendar.dateComponents([.day], from: fromDate, to: toDate)
        guard let days = dateComponents.day else {
            return nil
        }

        return abs(days)
    }

    static func weeksApart(from: Date, to: Date) -> Int? {
        var calendar = Calendar.current
        // Start weeks on Mondays
        calendar.firstWeekday = 2
        let calComponents: Set<Calendar.Component> = [.weekOfYear, .yearForWeekOfYear]
        guard let fromDate = calendar.date(from: calendar.dateComponents(calComponents, from: from)) else {
            return nil
        }
        guard let toDate = calendar.date(from: calendar.dateComponents(calComponents, from: to)) else {
            return nil
        }

        let dateComponents = calendar.dateComponents([.weekOfYear], from: fromDate, to: toDate)
        guard let weeks = dateComponents.weekOfYear else {
            return nil
        }

        return abs(weeks)
    }
}
