//
//  ScheduleRemindersController.swift
//  FiveCalls
//
//  Created by Christopher Brandow on 2/8/17.
//  Copyright © 2017 5calls. All rights reserved.
//

import UIKit
import UserNotifications

class ScheduleRemindersController: UIViewController {

    @IBOutlet weak var timePicker: UIDatePicker!
    @IBOutlet weak var daysOfWeekSelector: MultipleSelectionControl!
    @IBOutlet weak var noDaysWarningLabel: UILabel!

    lazy private var overlay: UIView = {
        let overlay = UIView()
        if #available(iOS 13, *) {
            overlay.backgroundColor = .systemBackground
        } else {
            overlay.backgroundColor = .white
        }
        overlay.translatesAutoresizingMaskIntoConstraints = false
        
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.textColor = R.color.darkGray()
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
                onRemindersEnabled()
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
    
    private func onRemindersEnabled() {
        UNUserNotificationCenter.current().getNotificationSettings() { [weak self] settings in
            if settings.authorizationStatus == .notDetermined {
                self?.requestNotificationAccess()
            } else if settings.authorizationStatus == .denied {
                DispatchQueue.main.async {
                    self?.showNotificationSettingsAlert()
                }
            }
        }
    }

    private func requestNotificationAccess() {
        let options: UNAuthorizationOptions = [.alert, .sound, .badge];
        UNUserNotificationCenter.current().requestAuthorization(options: options) { (success, error) in
            AnalyticsManager.shared.trackEventOld(withName: "Notification Access", andProperties: ["success": "\(success)"])
        }
    }
    
    private func showNotificationSettingsAlert() {
        let alertController = UIAlertController.settingsAlertView(
            title: R.string.localizable.notificationsDeniedAlertTitle(),
            message: R.string.localizable.notificationsDeniedAlertBody())
        present(alertController, animated: true, completion: nil)
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
                self.daysOfWeekSelector.setSelectedButtons(at: UNNotificationRequest.indices(from: notificationRequests, zeroBased: true))
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
        if remindersEnabled {
            self.onRemindersEnabled()
        }

        if #available(iOS 13.4, *) {
            timePicker.preferredDatePickerStyle = .wheels
        }

        timePicker.setValue(R.color.fivecallsDarkBlue(), forKey: "textColor")
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        daysOfWeekSelector.warningBorderColor = R.color.fivecallsRed()!.cgColor
        noDaysWarningLabel.textColor = R.color.fivecallsRed()
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        guard notificationsChanged == true && remindersEnabled else { return }

        clearNotifications()
        for index in daysOfWeekSelector.selectedIndices {
            let notificationContent = UNMutableNotificationContent.notificationContent()
            let notificationTrigger = UNCalendarNotificationTrigger.notificationTrigger(date: timePicker.date, dayIndex: index, fromZeroBased: true)
            let request = UNNotificationRequest(identifier: "5calls-reminder-\(index)", content: notificationContent, trigger: notificationTrigger)
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
            daysOfWeekSelector.warningBorderColor = R.color.fivecallsRed()!.cgColor
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
        let animation = CASpringAnimation(keyPath: "position")

        animation.damping = 1
        animation.mass = 0.1
        animation.stiffness = 100
        animation.duration = animation.settlingDuration
        animation.fromValue = CGPoint(x: self.daysOfWeekSelector.center.x - 18, y: self.daysOfWeekSelector.center.y)
        animation.toValue = CGPoint(x: self.daysOfWeekSelector.center.x, y: self.daysOfWeekSelector.center.y)

        daysOfWeekSelector.layer.add(animation, forKey: "shakeIt")
    }
}
