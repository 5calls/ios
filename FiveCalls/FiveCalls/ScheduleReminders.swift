//
//  ScheduleReminders.swift
//  FiveCalls
//
//  Created by Christopher Selin on 9/8/23.
//  Copyright © 2023 5calls. All rights reserved.
//

import SwiftUI

let USE_SHEET = true

struct ScheduleReminders: View {
    @AppStorage("reminderEnabled") var remindersEnabled = false
    @Environment(\.dismiss) var dismiss

    @State var selectedTime = Date()
    @State var selectedDayIndices = [Int]()
    @State var shouldShake = false
    
    var body: some View {
        if !USE_SHEET {
            ZStack {
                DayAndTimePickers(remindersEnabled: $remindersEnabled,
                                  selectedTime: $selectedTime,
                                  selectedDayIndices: $selectedDayIndices,
                                  shouldShake: $shouldShake)
                RemindersDisabledView(remindersEnabled: $remindersEnabled)
                Spacer()
            }
            .navigationTitle(R.string.localizable.scheduledRemindersTitle())
            .navigationBarTitleDisplayMode(.inline)
            .navigationBarBackButtonHidden(true)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button(action: {
                        self.onDismiss()
                    }) {
                        Text(R.string.localizable.doneButtonTitle())
                            .bold()
                    }
                }
                ToolbarItem(placement: .navigationBarTrailing) {
                    Toggle(isOn: $remindersEnabled,
                           label: {
                        Text("")
                    }).toggleStyle(.switch)
                }
            }
            .animation(.easeInOut, value: self.remindersEnabled)
            .task {
                let notificationRequests = await UNUserNotificationCenter.current().pendingNotificationRequests()
                self.selectedDayIndices = indices(from: notificationRequests)
                if let trigger = notificationRequests.first?.trigger as? UNCalendarNotificationTrigger, let triggerDate = trigger.nextTriggerDate() {
                    self.selectedTime = triggerDate
                }
            }
            .onChange(of: remindersEnabled) { newValue in
                if newValue {
                    requestNotificationAccess()
                } else {
                    clearNotifications()
                }
            }
            .onChange(of: selectedTime) { _ in
                clearNotifications()
            }
            .onChange(of: selectedDayIndices) { _ in
                clearNotifications()
            }
        } else {
            VStack(spacing: .zero) {
                ZStack {
                    Rectangle()
                        .foregroundColor(Color(R.color.darkBlue()!))
                        .frame(height: 56)
                    HStack {
                        Button(action: {
                            self.onDismiss()
                        }, label: {
                            Text(R.string.localizable.doneButtonTitle())
                                .bold()
                                .foregroundColor(.white)
                        })

                        Spacer()
                        Toggle(isOn: $remindersEnabled,
                               label: {
                            Text("")
                        }).toggleStyle(.switch)
                            .layoutPriority(-1)
                    }
                    .padding(.horizontal)

                    Text(R.string.localizable.scheduledRemindersTitle())
                        .font(Font(UIFont.fvc_header))
                        .bold()
                        .foregroundColor(.white)
                }

                ZStack {
                    DayAndTimePickers(remindersEnabled: $remindersEnabled,
                                      selectedTime: $selectedTime,
                                      selectedDayIndices: $selectedDayIndices,
                                      shouldShake: $shouldShake)
                    RemindersDisabledView(remindersEnabled: $remindersEnabled)
                    Spacer()
                }
                .background()
                .animation(.easeInOut, value: self.remindersEnabled)
                .task {
                    let notificationRequests = await UNUserNotificationCenter.current().pendingNotificationRequests()
                    self.selectedDayIndices = indices(from: notificationRequests)
                    if let trigger = notificationRequests.first?.trigger as? UNCalendarNotificationTrigger, let triggerDate = trigger.nextTriggerDate() {
                        self.selectedTime = triggerDate
                    }
                }
                .onChange(of: remindersEnabled) { newValue in
                    if newValue {
                        requestNotificationAccess()
                    } else {
                        clearNotifications()
                    }
                }
                .onChange(of: selectedTime) { _ in
                    clearNotifications()
                }
                .onChange(of: selectedDayIndices) { _ in
                    clearNotifications()
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
    
    private func clearNotifications() {
        UNUserNotificationCenter.current().removeAllPendingNotificationRequests()
    }
    
    private func onDismiss() {
        let cannotDismiss = selectedDayIndices.isEmpty && remindersEnabled
        if cannotDismiss {
            self.shouldShake = true
        } else {
            for index in selectedDayIndices {
                let notificationContent = self.notificationContent()
                let notificationTrigger = self.notificationTrigger(date: selectedTime, dayIndex: index)
                let request = UNNotificationRequest(identifier: "5calls-reminder-\(index)", content: notificationContent, trigger: notificationTrigger)
                UNUserNotificationCenter.current().add(request)
            }

            self.dismiss()
        }
    }
    
    private func indices(from notifications: [UNNotificationRequest]) -> [Int] {
        let calendar = Calendar(identifier: .gregorian)
        return notifications.compactMap({ notification in
            if let calendarTrigger = notification.trigger as? UNCalendarNotificationTrigger {
                return calendar.component(.weekday, from: (calendarTrigger.nextTriggerDate()!))
            }
            
            return nil
        })
    }
    
    private func notificationContent() -> UNMutableNotificationContent {
        let notificationContent = UNMutableNotificationContent()
        notificationContent.title = R.string.localizable.scheduledReminderAlertTitle()
        notificationContent.body = R.string.localizable.scheduledReminderAlertBody()
        notificationContent.badge = NSNumber(value: UIApplication.shared.applicationIconBadgeNumber + 1)
        return notificationContent
    }
    
    private func notificationTrigger(date: Date, dayIndex: Int) -> UNCalendarNotificationTrigger {
        var components = Calendar.current.dateComponents([.hour,.minute,.second], from: date)
        components.timeZone = TimeZone(identifier: "default")
        components.weekday = dayIndex
        return UNCalendarNotificationTrigger(dateMatching: components, repeats: true)
    }
}

struct ScheduleReminders_Previews: PreviewProvider {
    static var previews: some View {
        NavigationView {
            ScheduleReminders()
        }
    }
}

struct DayAndTimePickers: View {
    @Binding var remindersEnabled: Bool
    @Binding var selectedTime: Date
    @Binding var selectedDayIndices: [Int]
    @Binding var shouldShake: Bool
    
    var body: some View {
        VStack(spacing: 0) {
            Text(R.string.localizable.scheduledRemindersTimeLabel())
                .font(.system(size: 20))
                .foregroundColor(Color(R.color.darkBlue()!))
                .multilineTextAlignment(.center)
                .padding(20)
            DatePicker("", selection: $selectedTime, displayedComponents: .hourAndMinute)
                .labelsHidden()
                .datePickerStyle(WheelDatePickerStyle())
                .colorInvert() // TODO: this won't work in dark mode
                .colorMultiply(Color(R.color.darkBlue()!))
                .padding(.horizontal, 20)
            Spacer()
            Text(R.string.localizable.scheduledRemindersDayLabel())
                .font(.system(size: 20))
                .foregroundColor(Color(R.color.darkBlue()!))
                .multilineTextAlignment(.center)
                .padding(.horizontal, 20)
            MultipleDayPicker(selectedDayIndices: $selectedDayIndices)
                .offset(x: shouldShake ? -18 : 0)
                .animation(.interpolatingSpring(mass: 0.1, stiffness: 100, damping: 1), value: shouldShake)
                .onChange(of: shouldShake) { _ in
                    DispatchQueue.main.asyncAfter(deadline: .now()) {
                        self.shouldShake = false
                    }
                }
            Text(R.string.localizable.scheduledRemindersNoDaysWarning())
                .font(.system(size: 12))
                .foregroundColor(Color(R.color.red()!))
                .multilineTextAlignment(.center)
                .padding(.horizontal, 20)
                .opacity(selectedDayIndices.isEmpty ? 1 : 0)
        }
        .opacity(remindersEnabled ? 1 : 0)
    }
}

struct RemindersDisabledView: View {
    @Environment(\.dismiss) var dismiss
    @Binding var remindersEnabled: Bool
    
    var body: some View {
        GeometryReader { geometry in
            VStack(alignment: .center) {
                Spacer()
                HStack {
                    Spacer()
                    Text(R.string.localizable.scheduledRemindersDescription())
                        .foregroundColor(Color(R.color.darkGray()!))
                        .font(Font(UIFont.fvc_body))
                        .multilineTextAlignment(.center)
                        .frame(width: geometry.size.width * 0.8)
                        .opacity(self.remindersEnabled ? 0 : 1)
                    Spacer()
                }
                Spacer()
            }
        }
    }
}
