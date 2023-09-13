//
//  ScheduleReminders.swift
//  FiveCalls
//
//  Created by Christopher Selin on 9/8/23.
//  Copyright © 2023 5calls. All rights reserved.
//

import SwiftUI

let USE_SHEET = false

struct ScheduleReminders: View {
    @AppStorage("reminderEnabled") var remindersEnabled = false
    @Environment(\.dismiss) var dismiss

    @State var selectedTime = Date()
    @State var selectedDays = [Day]()
    @State var shouldShake = false
    
    var body: some View {
        if !USE_SHEET {
            ZStack {
                DayAndTimePickers(remindersEnabled: $remindersEnabled,
                                  selectedDays: $selectedDays,
                                  shouldShake: $shouldShake)
                RemindersDisabledView(remindersEnabled: $remindersEnabled)
                Spacer()
            }
            //                        .toolbarBackground(Color(R.color.darkBlue()!, for: .navigationBar))
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
        } else {
            VStack {
                ZStack {
                    HStack {
                        Button(R.string.localizable.doneButtonTitle()) {
                            self.onDismiss()
                        }
                        Spacer()
                        Toggle(isOn: $remindersEnabled,
                               label: {
                            Text("")
                        }).toggleStyle(.switch)
                            .layoutPriority(-1)
                    }
                    
                    Text(R.string.localizable.scheduledRemindersTitle())
                        .font(Font(UIFont.fvc_header))
                        .bold()
                }
                .padding()

                ZStack {
                    DayAndTimePickers(remindersEnabled: $remindersEnabled,
                                      selectedDays: $selectedDays,
                                      shouldShake: $shouldShake)
                    RemindersDisabledView(remindersEnabled: $remindersEnabled)
                    Spacer()
                }
                .animation(.easeInOut, value: self.remindersEnabled)
                .task {
                    let notificationRequests = await UNUserNotificationCenter.current().pendingNotificationRequests()
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
        let cannotDismiss = selectedDays.isEmpty && remindersEnabled
        if cannotDismiss {
            self.shouldShake = true
        } else {
            self.dismiss()
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
    @Binding var selectedDays: [Day]
    @Binding var shouldShake: Bool
    
    var body: some View {
        VStack {
            Text(R.string.localizable.scheduledRemindersTimeLabel())
                .font(.system(size: 20))
                .foregroundColor(Color(R.color.darkBlue()!))
                .multilineTextAlignment(.center)
                .padding(20)
            DatePicker("", selection: .constant(Date()), displayedComponents: .hourAndMinute)
                .labelsHidden()
                .datePickerStyle(WheelDatePickerStyle())
                .padding(.horizontal, 20)
            Spacer()
            Text(R.string.localizable.scheduledRemindersDayLabel())
                .font(.system(size: 20))
                .foregroundColor(Color(R.color.darkBlue()!))
                .multilineTextAlignment(.center)
                .padding(20)
            MultipleDayPicker(selectedDays: $selectedDays)
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
                .opacity(selectedDays.isEmpty ? 1 : 0)
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
