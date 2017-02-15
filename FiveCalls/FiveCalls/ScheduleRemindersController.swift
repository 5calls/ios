//
//  ScheduleRemindersController.swift
//  FiveCalls
//
//  Created by Christopher Brandow on 2/8/17.
//  Copyright © 2017 5calls. All rights reserved.
//

import Foundation

class ScheduleRemindersController: UIViewController {

    @IBOutlet weak var timePicker: UIDatePicker!
    @IBOutlet weak var daysOfWeekSelector: MultipleSelectionControl!

    var notificationsChanged: Bool?

    override func viewDidLoad() {
        notificationsChanged = false
        if let notifications = UIApplication.shared.scheduledLocalNotifications {
            daysOfWeekSelector.setSelectedButtons(at: indices(from: notifications))
            if let date = notifications.first?.fireDate {
                timePicker.setDate(date, animated: true)
            }
        }
        timePicker.setValue(UIColor(red:0.12, green:0.47, blue:0.81, alpha:1.00), forKey: "textColor")
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        guard let changed = notificationsChanged, changed == true else { return }

        UIApplication.shared.cancelAllLocalNotifications()
        for selectorIndex in daysOfWeekSelector.selectedIndices {
            let localNotif = createNotification(with: selectorIndex, chosenTime: timePicker.date)
            UIApplication.shared.scheduleLocalNotification(localNotif)
        }
    }

    @IBAction func timePickerChanged(_ sender: UIDatePicker) {
        notificationsChanged = true
    }

    @IBAction func dayPickerAction(_ sender: MultipleSelectionControl) {
        notificationsChanged = true
    }

    private func indices(from notifications: [UILocalNotification]) -> [Int] {
        let calendar = Calendar(identifier: .gregorian)
        return notifications.flatMap({ return calendar.component(.weekday, from: ($0.fireDate)!) - 2})
    }

    private func fireDate(for index: Int, date: Date) -> Date? {
        let calendar = Calendar(identifier: .gregorian)
        let currentDate = Date()
        var dateComponents = DateComponents()
        dateComponents.calendar = calendar
        dateComponents.hour = calendar.component(.hour, from: date)
        dateComponents.minute = calendar.component(.minute, from: date)
        dateComponents.weekOfYear = calendar.component(.weekOfYear, from: currentDate)
        dateComponents.year = calendar.component(.year, from: currentDate)
        dateComponents.weekday = index + 2
        return calendar.date(from: dateComponents)
    }

    private func createNotification(with index: Int, chosenTime: Date) -> UILocalNotification {
        let localNotif = UILocalNotification()
        localNotif.fireDate = fireDate(for: index, date: chosenTime)
        localNotif.alertBody = "Tap here to open 5 Calls and get started"
        localNotif.repeatInterval = .weekOfYear
        localNotif.alertTitle = "Time to Make Some Calls"
        localNotif.alertAction = "OK"
        localNotif.timeZone = TimeZone(identifier: "default")
        localNotif.applicationIconBadgeNumber = UIApplication.shared.applicationIconBadgeNumber + 1
        return localNotif
    }


}
