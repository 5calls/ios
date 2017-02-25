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

    lazy private var blurOverlay: UIView = {
        let blur = UIVisualEffectView()
        blur.backgroundColor = .white
        // blur.effect = UIBlurEffect(style: .dark)
        blur.translatesAutoresizingMaskIntoConstraints = false
        
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.textColor = UIColor.fvc_lightGray
        label.font = Appearance.instance.bodyFont
        label.numberOfLines = 0
        label.text = "Turn these on to get a quick local reminder to make your 5 calls.\n\nYou can pick which days of the week and what time you would like to be notified."
        label.textAlignment = .center
        blur.addSubview(label)
        
        NSLayoutConstraint.activate([
            label.widthAnchor.constraint(lessThanOrEqualTo: blur.widthAnchor, multiplier: 0.8),
            label.centerXAnchor.constraint(equalTo: blur.centerXAnchor),
            label.centerYAnchor.constraint(equalTo: blur.centerYAnchor),
        ])
        
        return blur
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
        setBlur(visible: !sender.isOn, animated: true)
    }

    private func requestNotificationAccess() {
        UIApplication.shared.registerUserNotificationSettings(
            UIUserNotificationSettings(types: [.alert, .badge],
                                       categories: nil)
        )
    }

    func setBlur(visible: Bool, animated: Bool) {
        let duration = animated ? 0.3 : 0

        if visible {
            view.addSubview(blurOverlay)
            blurOverlay.alpha = 0

            NSLayoutConstraint.activate([
                blurOverlay.leftAnchor.constraint(equalTo: view.leftAnchor),
                blurOverlay.rightAnchor.constraint(equalTo: view.rightAnchor),
                blurOverlay.topAnchor.constraint(equalTo: view.topAnchor),
                blurOverlay.bottomAnchor.constraint(equalTo: view.bottomAnchor)
                ])

            UIView.animate(withDuration: duration) {
                self.blurOverlay.alpha = 1.0
            }
        } else {
            UIView.animate(withDuration: duration, animations: {
                self.blurOverlay.alpha = 0
            }) { _ in
                self.blurOverlay.removeFromSuperview()
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
        setBlur(visible: !remindersEnabled, animated: false)


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
        localNotif.alertBody = "Tap here to open 5 Calls and get started"
        localNotif.repeatInterval = .weekOfYear
        localNotif.alertTitle = "Time to Make Some Calls"
        localNotif.alertAction = "OK"
        localNotif.timeZone = TimeZone(identifier: "default")
        localNotif.applicationIconBadgeNumber = UIApplication.shared.applicationIconBadgeNumber + 1
        return localNotif
    }


}
