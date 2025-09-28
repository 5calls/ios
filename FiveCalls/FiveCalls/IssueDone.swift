//
//  IssueDone.swift
//  FiveCalls
//
//  Created by Nick O'Neill on 10/2/23.
//  Copyright © 2023 5calls. All rights reserved.
//

import SwiftUI
import StoreKit
import OneSignal

struct IssueDone: View {
    @EnvironmentObject var store: Store
    @Environment(\.openURL) private var openURL
    
    @State var showNotificationAlert = false
    
    let issue: Issue

    init(issue: Issue) {
        self.issue = issue

        if let titleString = try? AttributedString(
            markdown:  String(
                localized: "You called on \(issue.name)",
                comment: "Issue done title string markdown text"
            )
        ) {
            self.markdownTitle = titleString
        } else {
            self.markdownTitle = AttributedString(
                String(
                    localized: "Nice work!",
                    comment: "Fallback issue done title markdown text"
                )
            )
        }
    }

    let donateURL = URL(string: "https://secure.actblue.com/donate/5calls-donate?refcode=ios&refcode2=\(AnalyticsManager.shared.callerID)")!
    var markdownTitle: AttributedString!

    func latestOutcomeForContact(contact: Contact, issueCompletions: [String]) -> String {
        if let contactOutcome = issueCompletions.last(where: { 
            let parts = $0.split(separator: "-")
            guard parts.count > 1 else { return false }
            let contactId = parts.dropLast().joined(separator: "-")
            return contactId == contact.id
        }) {
            let parts = contactOutcome.split(separator: "-")
            if parts.count > 1 {
                return ContactLog.localizedOutcomeForStatus(status: String(parts.last!))
            }
        }

        return String(localized: "Skip", comment: "Contact Log Outcome")
    }

    func shouldShowImage(latestOutcomeForContact: String) -> Bool {
        return latestOutcomeForContact != "Skip"
    }

    var body: some View {
        ScrollView {
            VStack(alignment: .leading) {
                HStack {
                    Spacer()
                    Text(markdownTitle)
                        .font(.title2)
                    Spacer()
                }.padding(.vertical, 16)
                VStack {
                    CountingView(title: "Total calls", count: store.state.globalCallCount)
                        .padding(.bottom, 14)
                    if let issueCalls = store.state.issueCallCounts[issue.id] {
                        CountingView(title: "Calls on this topic", count: issueCalls)
                            .padding(.bottom, 14)
                    }
                }
                .padding(.bottom, 16)

                Text("Contacts", comment: "Contact Summary header text")
                    .font(.caption).fontWeight(.bold)
                    .accessibilityAddTraits(.isHeader)
                ForEach(issue.contactsForIssue(allContacts: store.state.contacts)) { contact in
                    let issueCompletions = store.state.issueCompletion[issue.id] ?? []
                    let latestContactCompletion = latestOutcomeForContact(contact: contact, issueCompletions: issueCompletions)
                    ContactListItem(contact: contact, showComplete: shouldShowImage(latestOutcomeForContact: latestContactCompletion), contactNote: latestContactCompletion, listType: .compact)
                }
                if store.state.donateOn {
                    Text("Support 5 Calls", comment: "Support 5 Calls header text")
                        .font(.caption).fontWeight(.bold)
                        .accessibilityAddTraits(.isHeader)
                    HStack {
                        Text("Keep 5 Calls free and up-to-date", comment: "Support 5 Calls subtitle text")
                        Button(action: {
                            openURL(donateURL)
                        }) {
                            PrimaryButton(
                                title: String(localized: "Donate today", comment: "Donate today button title"),
                                systemImageName: "hand.thumbsup.circle.fill",
                                bgColor: .fivecallsRed
                            )
                        }
                    }
                    .padding(.bottom, 16)
                }

                Text("Share this topic", comment: "Issue Done share link text")
                    .font(.caption).fontWeight(.bold)
                    .accessibilityAddTraits(.isHeader)

                ShareLink(item: issue.shareURL) {
                    ZStack {
                        // make the share link show up for VoiceOver
                        Text("")
                        AsyncImage(url: issue.shareImageURL,
                                   content: { image in
                            image.resizable()
                                .aspectRatio(contentMode: .fill)
                        }, placeholder: { EmptyView() })
                    }
                }
                .padding(.bottom, 16)
                .accessibilityElement(children: .ignore)
                .accessibilityAddTraits(.isButton)
                .accessibilityLabel(
                    Text(
                        "Share this topic \(issue.name)",
                        comment: "Accessibility label for share link in IssueDone"
                    )
                )

                Button(action: {
                    store.dispatch(action: .GoToRoot)
                }, label: {
                    PrimaryButton(title: "Done", systemImageName: "flag.checkered")
                })
            }
            .padding(.horizontal)
        }
        .navigationBarHidden(true)
        .clipped()
        .frame(maxWidth: 500)
        .onAppear() {
            AnalyticsManager.shared.trackPageview(path: "/issue/\(issue.slug)/done/")

            store.dispatch(action: .FetchStats(issue.id))
          
            // will prompt for a rating after hitting done 5 times
            RatingPromptCounter.increment {
                guard let currentScene = UIApplication.shared.connectedScenes.first as? UIWindowScene else {
                    return
                }
                
                SKStoreReviewController.requestReview(in: currentScene)
            }
            
            // unlikely to occur at the same time as the rating prompt counter
            checkForNotifications()
        }.alert(R.string.localizableR.notificationTitle(), isPresented: $showNotificationAlert) {
            Button {
                // we don't really care which issue they were on when they subbed, just that it was a done page
                OneSignal.promptForPushNotifications(userResponse: { success in
                    if success {
                        AnalyticsManager.shared.trackEvent(name: "push-subscribe", path: "/issue/x/done/")
                    }
                })
            } label: {
                Text(R.string.localizableR.notificationImportant())
            }
            Button {
                let key = UserDefaultsKey.lastAskedForNotificationPermission.rawValue
                UserDefaults.standard.set(Date(), forKey: key)
            } label: {
                Text(R.string.localizableR.notificationNone())
            }
        } message: {
            Text(R.string.localizableR.notificationAsk())
        }

    }
}

extension IssueDone {
    func checkForNotifications() {
            let deviceState = OneSignal.getDeviceState()
            let nextPrompt = nextNotificationPromptDate() ?? Date()

            if deviceState?.hasNotificationPermission == false && nextPrompt <= Date() {
                showNotificationAlert = true
            }
        }
    func nextNotificationPromptDate() -> Date? {
        let key = UserDefaultsKey.lastAskedForNotificationPermission.rawValue
        guard let lastPrompt = UserDefaults.standard.object(forKey: key) as? Date else { return nil }

        return Calendar.current.date(byAdding: .month, value: 1, to: lastPrompt)
    }
}



#Preview {
    let previewState = {
        let state = AppState()
        state.contacts = [.housePreviewContact, .senatePreviewContact1, .senatePreviewContact2]
        state.issueCompletion[Issue.basicPreviewIssue.id] = ["\(Contact.housePreviewContact.id)-voicemail","\(Contact.senatePreviewContact1.id)-contact"]
        return state
    }()

    return IssueDone(issue: .basicPreviewIssue)

        .environmentObject(Store(state: previewState, middlewares: [appMiddleware()]))
}

struct IssueDoneNavModel {
    let issue: Issue
    let type: String
}

extension IssueDoneNavModel: Equatable, Hashable {
    static func == (lhs: IssueDoneNavModel, rhs: IssueDoneNavModel) -> Bool {
        return lhs.issue.id == rhs.issue.id && lhs.type == rhs.type
    }

    func hash(into hasher: inout Hasher) {
        hasher.combine(issue.id)
        hasher.combine(type)
    }
}
