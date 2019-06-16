//
//  ScheduleRemindersController.swift
//  FiveCalls
//
//  Created by Christopher Brandow on 2/8/17.
//  Copyright © 2017 5calls. All rights reserved.
//

import Foundation
import UserNotifications

class ScheduleRemindersController: UIViewController {

    @IBOutlet weak var timePicker: UIDatePicker!
    @IBOutlet weak var daysOfWeekSelector: MultipleSelectionControl!
    @IBOutlet weak var noDaysWarningLabel: UILabel!

    lazy private var overlay: UIView = {
        let overlay = UIView()
        overlay.backgroundColor = .white
        overlay.translatesAutoresizingMaskIntoConstraints = false
        
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.textColor = UIColor.fvc_lightGray
        label.font = .fvc_body
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
        get { return UserDefaults.standard.bool(forKey: UserDefaultsKey.reminderEnabled.rawValue) }
        set {
            UserDefaults.standard.set(newValue, forKey: UserDefaultsKey.reminderEnabled.rawValue)
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

    @objc func switchValueChanged(_ sender: UISwitch) {
        remindersEnabled = sender.isOn
        setOverlay(visible: !sender.isOn, animated: true)
    }

    private func requestNotificationAccess() {
        let options: UNAuthorizationOptions = [.alert, .sound, .badge];
        UNUserNotificationCenter.current().requestAuthorization(options: options) { (success, error) in
            // ok
        }
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
        UNUserNotificationCenter.current().getPendingNotificationRequests { [weak self] (notificationRequests) in
            guard let self = self else { return }
            DispatchQueue.main.async {
                self.daysOfWeekSelector.setSelectedButtons(at: self.indices(from: notificationRequests))
                if let trigger = notificationRequests.first?.trigger as? UNCalendarNotificationTrigger {
                    self.timePicker.setDate(trigger.nextTriggerDate() ?? Date(), animated: true)
                }
                self.updateDaysWarning()
            }
        }

        if navigationController?.viewControllers.first == self {
            let item = UIBarButtonItem(barButtonSystemItem: .done, target: self, action: #selector(dismissAction(_:)))
            item.setTitleTextAttributes([NSAttributedString.Key.foregroundColor: UIColor.white], for: .normal)
            navigationItem.leftBarButtonItem = item
        }
        
        navigationItem.rightBarButtonItem = switchButton(on: remindersEnabled)
        setOverlay(visible: !remindersEnabled, animated: false)

        timePicker.setValue(UIColor.fvc_darkBlue, forKey: "textColor")
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        daysOfWeekSelector.warningBorderColor = UIColor.fvc_red.cgColor
        noDaysWarningLabel.textColor = .fvc_red
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        guard notificationsChanged == true && remindersEnabled else { return }

        clearNotifications()
        for index in daysOfWeekSelector.selectedIndices {
            let notificationContent = createNotification()
            var components = Calendar.current.dateComponents([.hour,.minute,.second], from: timePicker.date)
            components.timeZone = TimeZone(identifier: "default")
            components.weekday = index + 2
            let trigger = UNCalendarNotificationTrigger(dateMatching: components, repeats: true)
            let request = UNNotificationRequest(identifier: "5calls-reminder-\(index)", content: notificationContent, trigger: trigger)
            UNUserNotificationCenter.current().add(request, withCompletionHandler: nil)
        }
    }

    @objc private func dismissAction(_ sender: UIBarButtonItem) {
        let cannotDismiss = noDaysSelected() && remindersEnabled
        if cannotDismiss {
            shakeDays()
        } else {
            dismiss(animated: true, completion: nil)
        }
    }
    
    private func clearNotifications() {
        UNUserNotificationCenter.current().removeAllPendingNotificationRequests()
    }

    @IBAction func timePickerChanged(_ sender: UIDatePicker) {
        notificationsChanged = true
    }

    @IBAction func dayPickerAction(_ sender: MultipleSelectionControl) {
        notificationsChanged = true
        updateDaysWarning()
    }

    func updateDaysWarning() {
        if daysOfWeekSelector.selectedIndices.count == 0 {
            daysOfWeekSelector.warningBorderColor = UIColor.fvc_red.cgColor
            noDaysWarningLabel.isHidden = false
        } else {
            daysOfWeekSelector.warningBorderColor = nil
            noDaysWarningLabel.isHidden = true
        }
    }

    private func noDaysSelected() -> Bool {
        return daysOfWeekSelector.selectedIndices.count == 0
    }

    private func shakeDays() {
        UIView.animate(withDuration: 0.14, animations: {
            self.daysOfWeekSelector.transform = CGAffineTransform(translationX: 10, y: 0)
        }) { (_) in
            UIView.animate(withDuration: 0.22, delay: 0, usingSpringWithDamping: 0.23, initialSpringVelocity: 1.0, options: .curveLinear, animations: {
                self.daysOfWeekSelector.transform = CGAffineTransform(translationX: 0, y: 0)
            }, completion: nil)
        }
    }

    private func indices(from notifications: [UNNotificationRequest]) -> [Int] {
        let calendar = Calendar(identifier: .gregorian)
        return notifications.compactMap({ notification in
            if let calendarTrigger = notification.trigger as? UNCalendarNotificationTrigger {
                return calendar.component(.weekday, from: (calendarTrigger.nextTriggerDate()!)) - 2
            }
            
            return nil
        })
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

    private func createNotification() -> UNMutableNotificationContent {
        let notificationContent = UNMutableNotificationContent()
        notificationContent.title = R.string.localizable.scheduledReminderAlertTitle()
        notificationContent.body = R.string.localizable.scheduledReminderAlertBody()
        notificationContent.badge = NSNumber(value: UIApplication.shared.applicationIconBadgeNumber + 1)
        return notificationContent
        
//        let localNotif = UILocalNotification()
//        • localNotif.fireDate = fireDate(for: index, date: chosenTime)
//         localNotif.alertTitle = R.string.localizable.scheduledReminderAlertTitle()
//        localNotif.alertBody = R.string.localizable.scheduledReminderAlertBody()
//        localNotif.repeatInterval = .weekOfYear
//        localNotif.alertAction = R.string.localizable.okButtonTitle()
//        localNotif.timeZone = TimeZone(identifier: "default")
//        localNotif.applicationIconBadgeNumber = UIApplication.shared.applicationIconBadgeNumber + 1
//        return localNotif
    }


}
