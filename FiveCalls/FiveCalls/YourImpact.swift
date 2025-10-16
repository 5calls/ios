//
//  YourImpact.swift
//  FiveCalls
//
//  Created by Christopher Selin on 10/10/23.
//  Copyright © 2023 5calls. All rights reserved.
//

import SwiftUI

struct YourImpact: View {
    @Environment(\.dismiss) var dismiss
    @EnvironmentObject var store: Store

    @State private var userStats: UserStats?
    
    var weeklyStreakMessage: String {
        let weeklyStreakCount = self.userStats?.weeklyStreak ?? 0
        switch weeklyStreakCount {
        case 0:
            return String(
                localized: "Your current weekly call streak is 0.",
                comment: "Weekly streak for zero"
            )
        case 1:
            return String(
                localized: "Your current weekly call streak just started. Keep it going!",
                comment: "Weekly call streak single"
            )
        default:
            return String(
                localized: "Your current weekly call streak is \(weeklyStreakCount) weeks in a row. You're on a roll!",
                comment: "Weekly call streak multiples"
            )
        }
    }
    
    var totalImpactMessage: String {
        let numberOfCalls = userStats?.totalCalls() ?? 0

        return String(
            localized: "Your total impact is \(numberOfCalls) calls.",
            comment: "Pluralized number of calls impact message"
        )
    }
    
    var showImpactList: Bool {
        userStats?.totalCalls() ?? 0 != 0
    }
    
    var communityCallsMessage: String {
        let callCount = StatsViewModel(numberOfCalls: store.state.globalCallCount).formattedNumberOfCalls
        return String(
            localized: "The 5 Calls community has contributed \(callCount ?? "") calls!",
            comment: "Community call count"
        )
    }
            
    var body: some View {
        NavigationStack {
            List {
                VStack(alignment: .leading, spacing: 16) {
                    Text(weeklyStreakMessage)
                        .font(.headline)
                    Text(totalImpactMessage)
                        .font(.headline)
                }
                .accessibilityElement(children: .ignore)
                .accessibilityLabel(Text("\(weeklyStreakMessage) \(totalImpactMessage)"))

                if showImpactList {
                    Text(
                        "You're making a difference! Calling is the most effective way to influence your representatives, and here's what you've achieved:",
                        comment: "ImpactList message"
                    )
                    ImpactListItem(
                        title: LocalizedStringResource(
                            "Made Contact",
                            comment: "ImpactList item title"
                        ),
                        count: userStats?.contact ?? 0
                    )
                    ImpactListItem(
                        title: LocalizedStringResource(
                            "Left Voicemail",
                            comment: "ImpactList item title"
                        ),
                        count: userStats?.voicemail ?? 0
                    )
                    ImpactListItem(
                        title: LocalizedStringResource(
                            "Unavailable",
                            comment: "ImpactList item title"
                        ),
                        count: userStats?.unavailable ?? 0
                    )
                }
                Section {

                } footer: {
                        Text(store.state.globalCallCount > 0 ? communityCallsMessage : "")
                        .font(.footnote)
                }
            }
            .padding(.vertical)
            .listStyle(.plain)
            .navigationTitle(String(localized: "My Impact", comment: "YourImpact Navigation Title"))
            .navigationBarTitleDisplayMode(.inline)
            .navigationBarBackButtonHidden()
            .toolbarBackground(.visible)
            .toolbarBackground(Color.fivecallsDarkBlue)
            .toolbarColorScheme(.dark, for: .navigationBar)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: {
                        self.dismiss()
                    }) {
                        Text("Done", comment: "Standard Done Button text")
                            .bold()
                    }
                }
            }
        }
        .onAppear() {
            if store.state.globalCallCount == 0 {
                store.dispatch(action: .FetchStats(nil))
            }

            fetchUserStats()
        }
        .accentColor(.white)
    }
        
    private func fetchUserStats() {
        let userStatsOp = FetchUserStatsOperation()
        userStatsOp.completionBlock = {
            if let error = userStatsOp.error {
                AnalyticsManager.shared.trackError(error: error)
            }
            
            self.userStats = userStatsOp.userStats
        }
        
        OperationQueue.main.addOperation(userStatsOp)
    }
}

struct YourImpact_Previews: PreviewProvider {
    static var previews: some View {
        let store = Store(state: AppState(), middlewares: [appMiddleware()])
        NavigationView {
            YourImpact().environmentObject(store)
        }
    }
}

struct ImpactListItem: View {
    var title: LocalizedStringResource
    var count: Int
    
    var body: some View {
        HStack {
            Text(title)
                .font(.body)
            Spacer()
            Text(timesString(count: count))
                .font(.body)
        }
        .accessibilityElement(children: .ignore)
        .accessibilityLabel(Text("\(title) \(timesString(count: count))"))
    }
    
    private func timesString(count: Int) -> String {
        String(localized: "\(count) time", comment: "Your impact call count pluralized")
    }
}
