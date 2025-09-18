//
//  App.swift
//  FiveCalls
//
//  Created by Nick O'Neill on 6/28/23.
//  Copyright © 2023 5calls. All rights reserved.
//

import SwiftUI
import UIKit
import Foundation

@main
struct FiveCallsApp: App {
    @StateObject var store: Store = Store(state: AppState(), middlewares: [appMiddleware()])
    @UIApplicationDelegateAdaptor(AppDelegate.self) var appDelegate
    
    @Environment(\.scenePhase) private var scenePhase
            
    @AppStorage(UserDefaultsKey.hasShownWelcomeScreen.rawValue) var hasShownWelcomeScreen = false

    var body: some Scene {
        WindowGroup {
            IssueSplitView()
                .environmentObject(store)
                .sheet(isPresented: $store.state.showWelcomeScreen) {
                    Welcome().environmentObject(store)
                }
                .onAppear {
                    appDelegate.app = self
                    if !hasShownWelcomeScreen {
                        store.dispatch(action: .ShowWelcomeScreen)
                    }
                }
                .onChange(of: scenePhase) { newPhase in
                    if newPhase == .active {
                        if store.state.needsIssueRefresh {
                            store.dispatch(action: .FetchIssues)
                        }
                    }
                }
        }
    }
}

// MARK: - Bundle Extensions for Type-Safe String Access

extension Bundle {
    enum Strings {
        // Dashboard
        static let menuName: String = validated("menu-name")
        static let menuScheduledReminders: String = validated("menu-scheduled-reminders")
        static let menuYourImpact: String = validated("menu-your-impact")
        static let menuAbout: String = validated("menu-about")
        static let moreIssuesTitle: String = validated("more-issues-title")
        static let lessIssuesTitle: String = validated("less-issues-title")
        static let searchIssues: String = validated("search-issues")
        static let searchNoResultsTitle: String = validated("search-no-results-title")
        static let searchNoResultsMessage: String = validated("search-no-results-message")
        static let whatsImportantTitle: String = validated("whats-important-title")

        // Office holder descriptions
        static let usHouse: String = validated("us-house")
        static let usSenate: String = validated("us-senate")
        static let stateRep: String = validated("state-rep")
        static let governor: String = validated("governor")
        static let attorneyGeneral: String = validated("attorney-general")
        static let secretaryOfState: String = validated("secretary-of-state")

        // Office holder grouping descriptions
        static let groupingUsHouse: String = validated("grouping-us-house")
        static let groupingUsSenate: String = validated("grouping-us-senate")
        static let groupingStateRep: String = validated("grouping-state-rep")
        static let groupingGovernor: String = validated("grouping-governor")
        static let groupingAttorneyGeneral: String = validated("grouping-attorney-general")
        static let groupingSecretaryOfState: String = validated("grouping-secretary-of-state")

        // Office holder titles
        static let titleUsHouse: String = validated("title-us-house")
        static let titleUsSenate: String = validated("title-us-senate")
        static let titleStateRep: String = validated("title-state-rep")
        static let titleGovernor: String = validated("title-governor")
        static let titleAttorneyGeneral: String = validated("title-attorney-general")
        static let titleSecretaryOfState: String = validated("title-secretary-of-state")

        // Issue detail screen
        static let noContacts: String = validated("no-contacts")
        static let seeScript: String = validated("see-script")
        static let repsListHeader: String = validated("reps-list-header")
        static let setLocationHeader: String = validated("set-location-header")
        static let setLocationButton: String = validated("set-location-button")
        static let share: String = validated("share")
        static let chooseIssuePlaceholder: String = validated("choose-issue-placeholder")
        static let chooseIssueSubheading: String = validated("choose-issue-subheading")
        static let tabTopics: String = validated("tab-topics")
        static let tabReps: String = validated("tab-reps")
        static let irrelevantContactMessage: String = validated("irrelevant-contact-message")
        static let vacantSeatTitle: String = validated("vacant-seat-title")

        // Location detection
        static let locatingTemp: String = validated("locating-temp")
        static let yourLocationIs: String = validated("your-location-is")
        static let setYourLocation: String = validated("set-your-location")
        static let unknownLocation: String = validated("unknown-location")
        static let locationSplitDistrict: String = validated("location-split-district")
        static let enterLocation: String = validated("enter-location")
        static let detectLocation: String = validated("detect-location")
        static let searchLocation: String = validated("search-location")
        static let locationInstructions: String = validated("location-instructions")
        static let locationErrorOff: String = validated("location-error-off")
        static let locationErrorDefault: String = validated("location-error-default")
        static let locationOr: String = validated("location-or")
        static let fallbackUserLocationDesc: String = validated("fallback-user-location-desc")
        static let locationPermissionDeniedTitle: String = validated("location-permission-denied-title")
        static let locationPermissionDeniedMessage: String = validated("location-permission-denied-message")

        // Common buttons
        static let okButtonTitle: String = validated("ok-button-title")
        static let doneButtonTitle: String = validated("done-button-title")
        static let cancelButtonTitle: String = validated("cancel-button-title")
        static let dismissTitle: String = validated("dismiss-title")

        // Scheduled reminders
        static let scheduledReminderAlertTitle: String = validated("scheduled-reminder-alert-title")
        static let scheduledReminderAlertBody: String = validated("scheduled-reminder-alert-body")
        static let scheduledRemindersTitle: String = validated("scheduled-reminders-title")
        static let scheduledRemindersTimeLabel: String = validated("scheduled-reminders-time-label")
        static let scheduledRemindersDayLabel: String = validated("scheduled-reminders-day-label")
        static let scheduledRemindersNoDaysWarning: String = validated("scheduled-reminders-no-days-warning")
        static let scheduledRemindersNoDaysAlert: String = validated("scheduled-reminders-no-days-alert")
        static let scheduledRemindersDescription: String = validated("scheduled-reminders-description")
        static let scheduledRemindersDaySelected: String = validated("scheduled-reminders-day-selected")
        static let scheduledRemindersDayNotSelected: String = validated("scheduled-reminders-day-not-selected")

        // About
        static let aboutTitle: String = validated("about-title")
        static let aboutItemWhyCall: String = validated("about-item-why-call")
        static let aboutItemWhoWeAre: String = validated("about-item-who-we-are")
        static let aboutItemFeedback: String = validated("about-item-feedback")
        static let aboutItemShowWelcome: String = validated("about-item-show-welcome")
        static let aboutItemShare: String = validated("about-item-share")
        static let aboutItemRate: String = validated("about-item-rate")
        static let aboutItemOpenSource: String = validated("about-item-open-source")
        static let aboutSectionHeaderGeneral: String = validated("about-section-header-general")
        static let aboutSectionHeaderSocial: String = validated("about-section-header-social")
        static let aboutSectionFooterSocial: String = validated("about-section-footer-social")
        static let aboutSectionHeaderCredits: String = validated("about-section-header-credits")
        static let aboutCallingGroupHeader: String = validated("about-callingGroup-header")
        static let aboutCallingGroupPlaceholder: String = validated("about-callingGroup-placeholder")
        static let aboutCallingGroupFooter: String = validated("about-callingGroup-footer")
        static let aboutAcknowledgementsTitle: String = validated("about-acknowledgements-title")
        static let aboutWebviewTitleWhyCall: String = validated("about-webview-title-why-call")
        static let aboutWebviewTitleWhoWeAre: String = validated("about-webview-title-who-we-are")
        static let cantSendEmailTitle: String = validated("cant-send-email-title")
        static let cantSendEmailMessage: String = validated("cant-send-email-message")
        static let openSettingsTitle: String = validated("open-settings-title")

        // Welcome
        static let welcomeSection1Title: String = validated("welcome-section-1-title")
        static let welcomeSection1Message: String = validated("welcome-section-1-message")
        static let welcomeSection2Title: String = validated("welcome-section-2-title")
        static let welcomeSection2Message: String = validated("welcome-section-2-message")
        static let welcomeButtonTitle: String = validated("welcome-button-title")

        // Done screen
        static let doneScreenTitle: String = validated("done-screen-title")
        static let doneScreenButton: String = validated("done-screen-button")
        static let totalCalls: String = validated("total-calls")
        static let totalIssueCalls: String = validated("total-issue-calls")
        static let contactSummaryHeader: String = validated("contact-summary-header")
        static let support5calls: String = validated("support-5calls")
        static let support5callsSub: String = validated("support-5calls-sub")
        static let donateToday: String = validated("donate-today")
        static let shareThisTopic: String = validated("share-this-topic")
        static let notificationTitle: String = validated("notification-title")
        static let notificationAsk: String = validated("notification-ask")
        static let notificationImportant: String = validated("notification-important")
        static let notificationNone: String = validated("notification-none")
        static let notificationsDeniedAlertTitle: String = validated("notifications-denied-alert-title")
        static let notificationsDeniedAlertBody: String = validated("notifications-denied-alert-body")

        // Your impact
        static let yourImpactTitle: String = validated("your-impact-title")
        static let impactListMessage: String = validated("impact-list-message")
        static let madeContact: String = validated("made-contact")
        static let leftVoicemail: String = validated("left-voicemail")
        static let unavailable: String = validated("unavailable")

        // Outcomes
        static let outcomesSkip: String = validated("outcomes.skip")
        static let outcomesContact: String = validated("outcomes.contact")
        static let outcomesVoicemail: String = validated("outcomes.voicemail")
        static let outcomesUnavailable: String = validated("outcomes.unavailable")

        // Inbox
        static let inboxEmptyState: String = validated("inbox-empty-state")
        static let inboxRepsHeader: String = validated("inbox-reps-header")
        static let inboxVotesHeader: String = validated("inbox-votes-header")
        static let inboxPushButton: String = validated("inbox-push-button")
        static let inboxPushDetail: String = validated("inbox-push-detail")
        static let inboxContactAlert: String = validated("inbox-contact-alert")
        static let inboxDetailReadmore: String = validated("inbox-detail-readmore")

        // Contact details
        static let copy: String = validated("copy")
        static let a11yCopiedPhoneNumber: String = validated("a11y-copied-phone-number")
        static let a11yPhoneCallCopyHint: String = validated("a11y-phone-call-copy-hint")
        static let a11yPhoneCallHint: String = validated("a11y-phone-call-hint")
        static let a11yPhoneCopyHint: String = validated("a11y-phone-copy-hint")

        // Newsletter
        static let newsletterHeader: String = validated("newsletter-header")
        static let newsletterSubhead: String = validated("newsletter-subhead")
        static let newsletterEmailPlaceholder: String = validated("newsletter-email-placeholder")
        static let newsletterDismiss: String = validated("newsletter-dismiss")
        static let newsletterSubscribe: String = validated("newsletter-subscribe")
        static let newsletterInvalidEmail: String = validated("newsletter-invalid-email")

        // Day picker
        static let dayPickerSundayAbbr: String = validated("day-picker-sunday-abbr")
        static let dayPickerMondayAbbr: String = validated("day-picker-monday-abbr")
        static let dayPickerTuesdayAbbr: String = validated("day-picker-tuesday-abbr")
        static let dayPickerWednesdayAbbr: String = validated("day-picker-wednesday-abbr")
        static let dayPickerThursdayAbbr: String = validated("day-picker-thursday-abbr")
        static let dayPickerFridayAbbr: String = validated("day-picker-friday-abbr")
        static let dayPickerSaturdayAbbr: String = validated("day-picker-saturday-abbr")
        static let dayPickerSunday: String = validated("day-picker-sunday")
        static let dayPickerMonday: String = validated("day-picker-monday")
        static let dayPickerTuesday: String = validated("day-picker-tuesday")
        static let dayPickerWednesday: String = validated("day-picker-wednesday")
        static let dayPickerThursday: String = validated("day-picker-thursday")
        static let dayPickerFriday: String = validated("day-picker-friday")
        static let dayPickerSaturday: String = validated("day-picker-saturday")

        // Parameterized strings
        static func callAreas(_ areas: String) -> String {
            return String(format: validated("call-areas"), areas)
        }

        static func vacantSeatMessage(_ area: String) -> String {
            return String(format: validated("vacant-seat-message"), area)
        }

        static func doneTitle(_ issueName: String) -> String {
            return String(format: validated("done-title"), issueName)
        }

        static func copiedPhone(_ phoneNumber: String) -> String {
            return String(format: validated("copied-phone"), phoneNumber)
        }

        static func a11yOfficeCallPhoneNumber(_ city: String, _ phone: String) -> String {
            return String(format: validated("a11y-office-call-phone-number"), city, phone)
        }

        static func a11yOfficeCopyPhoneNumber(_ city: String, _ phone: String) -> String {
            return String(format: validated("a11y-office-copy-phone-number"), city, phone)
        }

        static func welcomeSection3Calls(_ callsString: String) -> String {
            return String(format: validated("welcome-section-3-calls"), callsString)
        }

        static func yourWeeklyStreakZero(_ count: Int) -> String {
            return String(format: validated("your-weekly-streak-zero"), count)
        }

        static func yourWeeklyStreakSingle() -> String {
            return validated("your-weekly-streak-single")
        }

        static func yourWeeklyStreakMultiple(_ count: Int) -> String {
            return String(format: validated("your-weekly-streak-multiple"), count)
        }

        static func yourImpactZero(_ count: Int) -> String {
            return String(format: validated("your-impact-zero"), count)
        }

        static func yourImpactSingle(_ count: Int) -> String {
            return String(format: validated("your-impact-single"), count)
        }

        static func yourImpactMultiple(_ count: Int) -> String {
            return String(format: validated("your-impact-multiple"), count)
        }

        static func communityCalls(_ callsString: String) -> String {
            return String(format: validated("community-calls"), callsString)
        }

        static func calledSingle(_ count: Int) -> String {
            return String(format: validated("called-single"), count)
        }

        static func calledMultiple(_ count: Int) -> String {
            return String(format: validated("called-multiple"), count)
        }

        private static func validated(_ key: String) -> String {
            let value = NSLocalizedString(key, bundle: Bundle.main, comment: "")
            #if DEBUG
            assert(value != key, "Missing localization for key: '\(key)'. Add this key to Localizable.strings")
            #endif
            return value
        }
    }
}
