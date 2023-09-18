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
    @AppStorage(UserDefaultsKey.reminderEnabled.rawValue) var remindersEnabled = false
    @Environment(\.dismiss) var dismiss

    @State var existingSelectedTime = Date.distantPast
    @State var selectedTime = Date.distantPast
    @State var existingSelectedDayIndices = [Int]()
    @State var selectedDayIndices = [Int]()
    @State var shouldShake = false
    @State var presentNotificationSettingsAlert = false
    
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
                        onDismiss()
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
            .animation(.easeInOut, value: remindersEnabled)
            .task {
                if remindersEnabled {
                    onRemindersEnabled()
                }
                
                let notificationRequests = await UNUserNotificationCenter.current().pendingNotificationRequests()
                let indices = UNNotificationRequest.indices(from: notificationRequests)
                existingSelectedDayIndices = indices
                selectedDayIndices = indices
                if let trigger = notificationRequests.first?.trigger as? UNCalendarNotificationTrigger, let triggerDate = trigger.nextTriggerDate() {
                    existingSelectedTime = triggerDate
                    selectedTime = triggerDate
                }
            }
            .onChange(of: remindersEnabled) { newValue in
                if newValue {
                    onRemindersEnabled()
                }
            }
            .alert(Text(R.string.localizable.notificationsDeniedAlertTitle()),
                   isPresented: $presentNotificationSettingsAlert,
                   actions: {
                    Button(R.string.localizable.dismissTitle()) { }
                    Button(R.string.localizable.openSettingsTitle()) {
                        guard let url = URL(string: UIApplication.openSettingsURLString) else { return }
                            UIApplication.shared.open(url)
                    }.keyboardShortcut(.defaultAction)
                   },
                   message: {
                    Text(R.string.localizable.notificationsDeniedAlertBody())
                   })
        } else {
            VStack(spacing: .zero) {
                ZStack {
                    Rectangle()
                        .foregroundColor(Color.fivecallsDarkBlue)
                        .frame(height: 56)
                    HStack {
                        Button(action: {
                            onDismiss()
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
                .animation(.easeInOut, value: remindersEnabled)
                .task {
                    if remindersEnabled {
                        onRemindersEnabled()
                    }
                    
                    let notificationRequests = await UNUserNotificationCenter.current().pendingNotificationRequests()
                    let indices = UNNotificationRequest.indices(from: notificationRequests)
                    existingSelectedDayIndices = indices
                    selectedDayIndices = indices
                    if let trigger = notificationRequests.first?.trigger as? UNCalendarNotificationTrigger, let triggerDate = trigger.nextTriggerDate() {
                        existingSelectedTime = triggerDate
                        selectedTime = triggerDate
                    }
                }
                .onChange(of: remindersEnabled) { newValue in
                    if newValue {
                        onRemindersEnabled()
                    }
                }
                .alert(Text(R.string.localizable.notificationsDeniedAlertTitle()),
                       isPresented: $presentNotificationSettingsAlert,
                       actions: {
                        Button(R.string.localizable.dismissTitle()) { }
                        Button(R.string.localizable.openSettingsTitle()) {
                            guard let url = URL(string: UIApplication.openSettingsURLString) else { return }
                                UIApplication.shared.open(url)
                        }.keyboardShortcut(.defaultAction)
                       },
                       message: {
                        Text(R.string.localizable.notificationsDeniedAlertBody())
                       })
            }
        }
    }
    
    private func onRemindersEnabled() {
         UNUserNotificationCenter.current().getNotificationSettings() { settings in
             if settings.authorizationStatus == .notDetermined {
                 requestNotificationAccess()
             } else if settings.authorizationStatus == .denied {
                    presentNotificationSettingsAlert = true
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
            shouldShake = true
        } else if existingSelectedTime == selectedTime &&
                    existingSelectedDayIndices == selectedDayIndices && remindersEnabled {
            dismiss()
        } else {
            clearNotifications()
            if remindersEnabled {
                for index in selectedDayIndices {
                    let notificationContent = UNMutableNotificationContent.notificationContent()
                    let notificationTrigger = UNCalendarNotificationTrigger.notificationTrigger(date: selectedTime, dayIndex: index)
                    let request = UNNotificationRequest(identifier: "5calls-reminder-\(index)", content: notificationContent, trigger: notificationTrigger)
                    UNUserNotificationCenter.current().add(request)
                }
            }

            dismiss()
        }
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
                .foregroundColor(Color.fivecallsDarkBlue)
                .multilineTextAlignment(.center)
                .padding(20)
            DatePicker("", selection: $selectedTime, displayedComponents: .hourAndMinute)
                .labelsHidden()
                .datePickerStyle(WheelDatePickerStyle())
                .colorInvert() // TODO: this won't work in dark mode
                .colorMultiply(Color.fivecallsDarkBlue)
                .padding(.horizontal, 20)
            Spacer()
            Text(R.string.localizable.scheduledRemindersDayLabel())
                .font(.system(size: 20))
                .foregroundColor(Color.fivecallsDarkBlue)
                .multilineTextAlignment(.center)
                .padding(.horizontal, 20)
            MultipleDayPicker(selectedDayIndices: $selectedDayIndices)
                .offset(x: shouldShake ? -18 : 0)
                .animation(.interpolatingSpring(mass: 0.1, stiffness: 100, damping: 1), value: shouldShake)
                .onChange(of: shouldShake) { _ in
                    DispatchQueue.main.asyncAfter(deadline: .now()) {
                        shouldShake = false
                    }
                }
            Text(R.string.localizable.scheduledRemindersNoDaysWarning())
                .font(.system(size: 12))
                .foregroundColor(Color.fivecallsRed)
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
                        .opacity(remindersEnabled ? 0 : 1)
                    Spacer()
                }
                Spacer()
            }
        }
    }
}
