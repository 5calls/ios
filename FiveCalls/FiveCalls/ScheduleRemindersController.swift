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

    lazy private var overlay: UIView = {
        let overlay = UIVisualEffectView()
        overlay.backgroundColor = .white
        overlay.translatesAutoresizingMaskIntoConstraints = false
        
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.textColor = UIColor.fvc_lightGray
        label.font = Appearance.instance.bodyFont
        label.numberOfLines = 0
        label.text = R.string.localizable.scheduledRemindersDescription()
        label.textAlignment = .center
        overlay.addSubview(label)
        
        NSLayoutConstraint.activate([
            label.widthAnchor.constraint(lessThanOrEqualTo: overlay.widthAnchor, multiplier: 0.8),
            label.centerXAnchor.constraint(equalTo: overlay.centerXAnchor),
            label.centerYAnchor.constraint(equalTo: overlay.centerYAnchor),
        ])
        
        return overlay
    }()
    
    private var remindersEnabled: Bool {
        get { return UserDefaults.standard.bool(forKey: UserDefaultsKeys.reminderEnabled.rawValue) }
        set {
            UserDefaults.standard.set(newValue, forKey: UserDefaultsKeys.reminderEnabled.rawValue)
            if newValue {
                requestNotificationAccess()
            } else {
                clearNotifications()
            }
        }
    }
    
    private var notificationsChanged = true

    private func switchButton(on: Bool) -> UIBarButtonItem {
        let switchControl = UISwitch()
        switchControl.isOn = on
        switchControl.addTarget(self, action: #selector(ScheduleRemindersController.switchValueChanged), for: .valueChanged)
        let barButtonItem = UIBarButtonItem(customView: switchControl)
        return barButtonItem
    }

    func switchValueChanged(_ sender: UISwitch) {
        remindersEnabled = sender.isOn
        setOverlay(visible: !sender.isOn, animated: true)
    }

    private func requestNotificationAccess() {
        UIApplication.shared.registerUserNotificationSettings(
            UIUserNotificationSettings(types: [.alert, .badge],
                                       categories: nil)
        )
    }

    func setOverlay(visible: Bool, animated: Bool) {
        let duration = animated ? 0.3 : 0

        if visible {
            view.addSubview(overlay)
            overlay.alpha = 0

            NSLayoutConstraint.activate([
                overlay.leftAnchor.constraint(equalTo: view.leftAnchor),
                overlay.rightAnchor.constraint(equalTo: view.rightAnchor),
                overlay.topAnchor.constraint(equalTo: view.topAnchor),
                overlay.bottomAnchor.constraint(equalTo: view.bottomAnchor)
                ])

            UIView.animate(withDuration: duration) {
                self.overlay.alpha = 1.0
            }
        } else {
            UIView.animate(withDuration: duration, animations: {
                self.overlay.alpha = 0
            }) { _ in
                self.overlay.removeFromSuperview()
            }
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        
        if let notifications = UIApplication.shared.scheduledLocalNotifications {
            daysOfWeekSelector.setSelectedButtons(at: indices(from: notifications))
            if let date = notifications.first?.fireDate {
                timePicker.setDate(date, animated: true)
            }
        }

        navigationItem.rightBarButtonItem = switchButton(on: remindersEnabled)
        setOverlay(visible: !remindersEnabled, animated: false)


        timePicker.setValue(UIColor.fvc_darkBlue, forKey: "textColor")
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        guard notificationsChanged == true && remindersEnabled else { return }

        clearNotifications()
        for selectorIndex in daysOfWeekSelector.selectedIndices {
            let localNotif = createNotification(with: selectorIndex, chosenTime: timePicker.date)
            UIApplication.shared.scheduleLocalNotification(localNotif)
        }
    }

    private func clearNotifications() {
        UIApplication.shared.cancelAllLocalNotifications()
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
        localNotif.alertTitle = R.string.localizable.scheduledReminderAlertTitle()
        localNotif.alertBody = R.string.localizable.scheduledReminderAlertBody()
        localNotif.repeatInterval = .weekOfYear
        localNotif.alertAction = R.string.localizable.okButtonTitle()
        localNotif.timeZone = TimeZone(identifier: "default")
        localNotif.applicationIconBadgeNumber = UIApplication.shared.applicationIconBadgeNumber + 1
        return localNotif
    }


}
