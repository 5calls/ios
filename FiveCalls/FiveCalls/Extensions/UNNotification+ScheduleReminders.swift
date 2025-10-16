//
//  Notification+Extension.swift
//  FiveCalls
//
//  Created by Christopher Selin on 9/15/23.
//  Copyright © 2023 5calls. All rights reserved.
//

import UserNotifications
import UIKit

extension UNMutableNotificationContent {
    static func notificationContent() -> UNMutableNotificationContent {
        let notificationContent = UNMutableNotificationContent()
        notificationContent.title = String(
            localized: "Time to Make Some Calls",
            comment: "ScheduledReminderNotification Alert title"
        )
        notificationContent.body = String(
            localized: "Tap here to open 5 Calls and get started",
            comment: "ScheduledReminderNotification Alert body"
        )
        notificationContent.badge = NSNumber(value: UIApplication.shared.applicationIconBadgeNumber + 1)
        return notificationContent
    }
}

extension UNCalendarNotificationTrigger {
    static func notificationTrigger(date: Date, dayIndex: Int, fromZeroBased: Bool = false) -> UNCalendarNotificationTrigger {
        var components = Calendar.current.dateComponents([.hour,.minute,.second], from: date)
        components.timeZone = TimeZone(identifier: "default")
        components.weekday = fromZeroBased ? dayIndex + 1 : dayIndex
        return UNCalendarNotificationTrigger(dateMatching: components, repeats: true)
    }
}

extension UNNotificationRequest {
    static func indices(from notifications: [UNNotificationRequest], zeroBased: Bool = false) -> [Int] {
        let calendar = Calendar(identifier: .gregorian)
        return notifications.compactMap({ notification in
            if let calendarTrigger = notification.trigger as? UNCalendarNotificationTrigger {
                return calendar.component(.weekday, from: (calendarTrigger.nextTriggerDate()!)) - (zeroBased ? 1 : 0)
            }
            
            return nil
        })
    }
}
