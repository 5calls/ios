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
                }.padding(.bottom, 16)
                if store.state.donateOn {
                    Text(R.string.localizable.support5calls())
                        .font(.caption).fontWeight(.bold)
                    HStack {
                        Text(R.string.localizable.support5callsSub())
                        Button(action: {
                            openURL(donateURL)
                        }) {
                            PrimaryButton(title: R.string.localizable.donateToday(), systemImageName: "hand.thumbsup.circle.fill", bgColor: .fivecallsRed)
                        }
                    }.padding(.bottom, 16)
                }
                Text(R.string.localizable.shareThisTopic())
                    .font(.caption).fontWeight(.bold)
                ShareLink(item: issue.shareURL) {
                    AsyncImage(url: issue.shareImageURL,
                               content: { image in
                        image.resizable()
                            .aspectRatio(contentMode: .fill)
                    }, placeholder: { EmptyView() })
                }.padding(.bottom, 16)
                Button(action: {
                    router.backToRoot()
                }, label: {
                    PrimaryButton(title: R.string.localizable.doneScreenButton(), systemImageName: "flag.checkered")

                })
            }
            .padding(.horizontal)
        }.navigationBarHidden(true)
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
        }.alert(R.string.localizable.notificationTitle(), isPresented: $showNotificationAlert) {
            Button {
                // we don't really care which issue they were on when they subbed, just that it was a done page
                AnalyticsManager.shared.trackEvent(name: "push-subscribe", path: "/issue/x/done/")
                OneSignal.promptForPushNotifications(userResponse: { (success) in
                    //
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
            GeometryReader { geometry in
                ZStack(alignment: Alignment(horizontal: .leading, vertical: .center)) {
                    RoundedRectangle(cornerSize: CGSize(width: 5, height: 5))
                        .foregroundColor(.fivecallsLightBG)
                    RoundedRectangle(cornerSize: CGSize(width: 5, height: 5))
                        .foregroundColor(.fivecallsDarkBlue)
                        .frame(width: progressWidth(size: geometry.size))
                    // this formats the int with commas automatically?
                    Text("\(count)")
                        .foregroundStyle(.white)
                        .padding(.vertical, 2)
                        .padding(.horizontal, 6)
                }
            }
        }
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
    IssueDone(issue: .basicPreviewIssue)
}

struct IssueNavModel {
    let issue: Issue
    let type: String
}

extension IssueNavModel: Equatable, Hashable {
    static func == (lhs: IssueNavModel, rhs: IssueNavModel) -> Bool {
        return lhs.issue.id == rhs.issue.id && lhs.type == rhs.type
    }
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(issue.id)
        hasher.combine(type)
    }
}
