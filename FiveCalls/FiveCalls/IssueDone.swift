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
    @EnvironmentObject var router: IssueRouter
    @Environment(\.openURL) private var openURL

    @State var showNotificationAlert = false

    let issue: Issue

    init(issue: Issue) {
        self.issue = issue

        if let titleString = try? AttributedString(markdown:  R.string.localizable.doneTitle(issue.name)) {
            self.markdownTitle = titleString
        } else {
            self.markdownTitle = AttributedString(R.string.localizable.doneScreenTitle())
        }
    }

    let donateURL = URL(string: "https://secure.actblue.com/donate/5calls-donate?refcode=ios&refcode2=\(AnalyticsManager.shared.callerID)")!
    var markdownTitle: AttributedString!

    func latestOutcomeForContact(contact: Contact, issueCompletions: [String]) -> String {
        // TODO: This isn't working properly... seeing a lot of skips when I don't expect it
        // The code below is expecting issueCompletions to be a different format than the state code actually creates
        if let contactOutcome = issueCompletions.last(where: { $0.split(separator: "-")[0] == contact.id }) {
            if contactOutcome.split(separator: "-").count > 1 {
                return ContactLog.localizedOutcomeForStatus(status: String(contactOutcome.split(separator: "-")[1]))
            }
        }

        return R.string.localizable.outcomesSkip()
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
                    CountingView(title: R.string.localizable.totalCalls(), count: store.state.globalCallCount)
                        .padding(.bottom, 14)
                    if let issueCalls = store.state.issueCallCounts[issue.id] {
                        CountingView(title: R.string.localizable.totalIssueCalls(), count: issueCalls)
                            .padding(.bottom, 14)
                    }
                }
                .padding(.bottom, 16)

                Text(R.string.localizable.contactSummaryHeader())
                    .font(.caption).fontWeight(.bold)
                    .accessibilityAddTraits(.isHeader)
                ForEach(issue.contactsForIssue(allContacts: store.state.contacts)) { contact in
                    let issueCompletions = store.state.issueCompletion[issue.id] ?? []
                    let latestContactCompletion = latestOutcomeForContact(contact: contact, issueCompletions: issueCompletions)
                    ContactListItem(contact: contact, showComplete: shouldShowImage(latestOutcomeForContact: latestContactCompletion), contactNote: latestContactCompletion, listType: .compact)
                }
                if store.state.donateOn {
                    Text(R.string.localizable.support5calls())
                        .font(.caption).fontWeight(.bold)
                        .accessibilityAddTraits(.isHeader)
                    HStack {
                        Text(R.string.localizable.support5callsSub())
                        Button(action: {
                            openURL(donateURL)
                        }) {
                            PrimaryButton(title: R.string.localizable.donateToday(), systemImageName: "hand.thumbsup.circle.fill", bgColor: .fivecallsRed)
                        }
                    }
                    .padding(.bottom, 16)
                }

                Text(R.string.localizable.shareThisTopic())
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
                .accessibilityLabel(Text("\(R.string.localizable.shareThisTopic()): \(issue.name)"))

                Button(action: {
                    router.backToRoot()
                }, label: {
                    PrimaryButton(title: R.string.localizable.doneScreenButton(), systemImageName: "flag.checkered")
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
        }
        .alert(R.string.localizable.notificationTitle(), isPresented: $showNotificationAlert) {
            Button {
                // we don't really care which issue they were on when they subbed, just that it was a done page
                OneSignal.promptForPushNotifications(userResponse: { success in
                    if success {
                        AnalyticsManager.shared.trackEvent(name: "push-subscribe", path: "/issue/x/done/")
                    }
                })
            } label: {
                Text(R.string.localizable.notificationImportant())
            }
            Button {
                let key = UserDefaultsKey.lastAskedForNotificationPermission.rawValue
                UserDefaults.standard.set(Date(), forKey: key)
            } label: {
                Text(R.string.localizable.notificationNone())
            }
        } message: {
            Text(R.string.localizable.notificationAsk())
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

struct CountingView: View {
    let title: String
    let count: Int

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            Text(title)
                .font(.title3)
                .fontWeight(.medium)
                .padding(.bottom, 4)
            ZStack(alignment: .leading) {
                Canvas { context, size in
                    let drawRect = CGRect(origin: .zero, size: size)

                    context.fill(Rectangle().size(size).path(in: drawRect), with: .color(.fivecallsLightBG))
                    context.fill(Rectangle().size(width: progressWidth(size: size), height: size.height).path(in: drawRect), with: .color(.fivecallsDarkBlue))
                }
                .clipShape(RoundedRectangle(cornerRadius: 5.0))
                Text("\(count)")
                    .foregroundStyle(.white)
                    // yes, blue background may be redundant, but it ensures that the white text can always be read, even with very large fonts
                    .background(.fivecallsDarkBlue)
                    .padding(.vertical, 2)
                    .padding(.horizontal, 6)
            }
        }
        .accessibilityElement(children: .combine)
    }

    func progressWidth(size: CGSize) -> CGFloat {
        return size.width * (CGFloat(count) / nextMilestone)
    }

    var nextMilestone: CGFloat {
        if count < 80 {
            return 100
        } else if count < 450 {
            return 500
        } else if count < 900 {
            return 1000
        } else if count < 4500 {
            return 5000
        } else if count < 9000 {
            return 10000
        } else if count < 45000 {
            return 50000
        } else if count < 90000 {
            return 100000
        } else if count < 450000 {
            return 500000
        } else if count < 900000 {
            return 1000000
        } else if count < 1500000 {
            return 2000000
        } else if count < 4500000 {
            return 5000000
        }

        return 0
    }
}

#Preview {
    let previewState = {
        let state = AppState()
            state.issues = [
                Issue.basicPreviewIssue,
                Issue.multilinePreviewIssue
            ]
        state.contacts = [.housePreviewContact, .senatePreviewContact1, .senatePreviewContact2]
        state.issueCompletion[Issue.basicPreviewIssue.id] = ["\(Contact.housePreviewContact.id)-voicemail","\(Contact.senatePreviewContact1.id)-contact"]
        return state
    }()

    return IssueDone(issue: .basicPreviewIssue)
        .environmentObject(Store(state: previewState, middlewares: [appMiddleware()]))
}

struct IssueDoneNavModel {
    var issue: Issue
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
