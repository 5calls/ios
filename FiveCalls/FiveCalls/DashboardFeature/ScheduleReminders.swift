// Copyright 5calls. All rights reserved. See LICENSE for details.

import SwiftUI

struct ScheduleReminders: View {
    @AppStorage(UserDefaultsKey.reminderEnabled.rawValue) var remindersEnabled = false
    @Environment(\.dismiss) var dismiss
    @Environment(\.accessibilityVoiceOverEnabled) private var voiceOverEnabled
    @Environment(\.accessibilityReduceMotion) private var reduceMotionEnabled
    @Environment(\.accessibilityDifferentiateWithoutColor) private var differentiateWithoutColorEnabled

    @State var existingSelectedTime = Date.distantPast
    @State var selectedTime = Date.distantPast
    @State var existingSelectedDayIndices = [Int]()
    @State var selectedDayIndices = [Int]()
    @State var shouldShake = false
    @State var presentNotificationSettingsAlert = false
    @State var presentDaysOfWeekNotSetAlert = false

    var body: some View {
        NavigationStack {
            VStack(spacing: .zero) {
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
                .onChange(of: remindersEnabled) {
                    if remindersEnabled {
                        onRemindersEnabled()
                    }
                }
                .alert(
                    Text("Notifications permissions denied.", comment: "Notifications denied alert title"),
                    isPresented: $presentNotificationSettingsAlert,
                    actions: {
                        Button(String(localized: "Dismiss", comment: "Standard Dismiss Button text")) {}
                        Button(String(localized: "Open Settings", comment: "Open Settings button title")) {
                            guard let url = URL(string: UIApplication.openSettingsURLString) else { return }
                            UIApplication.shared.open(url)
                        }.keyboardShortcut(.defaultAction)
                    },
                    message: {
                        Text(
                            "To use reminders please change notifications permissions in the Settings app and try again.",
                            comment: "Notifications denied alert message"
                        )
                    }
                )
                .alert(isPresented: $presentDaysOfWeekNotSetAlert) {
                    Alert(
                        title: Text(
                            "Please select days of the week",
                            comment: "Scheduled reminders no days selected alert title"
                        )
                    )
                }
            }
            .navigationTitle(
                String(
                    localized: "Enable reminder",
                    comment: "ScheduleReminders navigation title"
                )
            )
            .navigationBarTitleDisplayMode(.inline)
            .navigationBarBackButtonHidden()
            .toolbarBackground(.visible)
            .toolbarBackground(Color.fivecallsDarkBlue)
            .toolbarColorScheme(.dark, for: .navigationBar)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button(action: {
                        onDismiss()
                    }) {
                        Text("Done", comment: "Standard Done Button text")
                            .bold()
                    }
                }
                ToolbarItem(placement: .navigationBarTrailing) {
                    Toggle(isOn: $remindersEnabled,
                           label: {
                               Text("")
                           }).toggleStyle(.switch)
                        .accessibilityLabel(
                            Text(
                                "Enable reminder",
                                comment: "Accessibility label for the switch to enable reminders"
                            )
                        )
                }
            }
        }
        .accentColor(.white)
    }

    private func onRemindersEnabled() {
        UNUserNotificationCenter.current().getNotificationSettings { settings in
            if settings.authorizationStatus == .notDetermined {
                requestNotificationAccess()
            } else if settings.authorizationStatus == .denied {
                presentNotificationSettingsAlert = true
            }
        }
    }

    private func requestNotificationAccess() {
        let options: UNAuthorizationOptions = [.alert, .sound, .badge]
        UNUserNotificationCenter.current().requestAuthorization(options: options) { success, _ in
            if success {
                AnalyticsManager.shared.trackEvent(name: "push-subscribe", path: "/reminders/")
            }
        }
    }

    private func clearNotifications() {
        UNUserNotificationCenter.current().removeAllPendingNotificationRequests()
    }

    private func onDismiss() {
        let cannotDismiss = selectedDayIndices.isEmpty && remindersEnabled
        if cannotDismiss {
            if !reduceMotionEnabled {
                shouldShake = true
            }
            if voiceOverEnabled || reduceMotionEnabled || differentiateWithoutColorEnabled {
                presentDaysOfWeekNotSetAlert = true
            }
        } else if existingSelectedTime == selectedTime,
                  existingSelectedDayIndices == selectedDayIndices, remindersEnabled
        {
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

struct DayAndTimePickers: View {
    @Binding var remindersEnabled: Bool
    @Binding var selectedTime: Date
    @Binding var selectedDayIndices: [Int]
    @Binding var shouldShake: Bool
    @Environment(\.colorScheme) private var colorScheme

    var body: some View {
        ScrollView {
            VStack(spacing: 0) {
                Text(
                    "Select what time of day you'd like to be reminded to make calls:",
                    comment: "Scheduled Reminders time label"
                )
                .font(.title3)
                .foregroundColor(Color.fivecallsDarkBlue)
                .multilineTextAlignment(.center)
                .padding(20)
                DatePicker("", selection: $selectedTime, displayedComponents: .hourAndMinute)
                    .labelsHidden()
                    .datePickerStyle(WheelDatePickerStyle())
                    .padding(.horizontal, 20)
                Spacer()
                Spacer()
                Text(
                    "Which days of the week?",
                    comment: "ScheduledReminderds day label"
                )
                .font(.title3)
                .foregroundColor(Color.fivecallsDarkBlue)
                .padding(.horizontal, 20)
                .accessibilityAddTraits(.isHeader)
                MultipleDayPicker(selectedDayIndices: $selectedDayIndices)
                    .offset(x: shouldShake ? -18 : 0)
                    .animation(.interpolatingSpring(mass: 0.1, stiffness: 100, damping: 1), value: shouldShake)
                    .onChange(of: shouldShake) {
                        DispatchQueue.main.asyncAfter(deadline: .now()) {
                            shouldShake = false
                        }
                    }
                    .padding(.vertical, 5)
                Text(
                    "No days selected yet",
                    comment: "ScheduledReminders no days warning"
                )
                .foregroundColor(colorScheme == .light ? Color.fivecallsRed : Color.primary)
                .multilineTextAlignment(.center)
                .padding(.horizontal, 20)
                .opacity(selectedDayIndices.isEmpty ? 1 : 0)
            }
            .opacity(remindersEnabled ? 1 : 0)
        }
    }
}

struct RemindersDisabledView: View {
    @Environment(\.dismiss) var dismiss
    @Binding var remindersEnabled: Bool

    var body: some View {
        VStack {
            Text(
                "Turn these on to get a quick local reminder to make your 5 calls.",
                comment: "RemindersDisabledView text"
            )
            .foregroundColor(Color(.fivecallsDarkGray))
            .multilineTextAlignment(.center)
            .opacity(remindersEnabled ? 0 : 1)
        }
        .padding()
    }
}

#Preview {
    NavigationView {
        ScheduleReminders()
    }
}
