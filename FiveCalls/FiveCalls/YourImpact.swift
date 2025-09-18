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
            return Bundle.Strings.yourWeeklyStreakZero(weeklyStreakCount)
        case 1:
            return Bundle.Strings.yourWeeklyStreakSingle()
        default:
            return Bundle.Strings.yourWeeklyStreakMultiple(weeklyStreakCount)
        }
    }
    
    var totalImpactMessage: String {
        let numberOfCalls = userStats?.totalCalls() ?? 0
        switch numberOfCalls {
        case 0:
            return Bundle.Strings.yourImpactZero(numberOfCalls)
        case 1:
            return Bundle.Strings.yourImpactSingle(numberOfCalls)
        default:
            return Bundle.Strings.yourImpactMultiple(numberOfCalls)
        }
    }
    
    var showImpactList: Bool {
        userStats?.totalCalls() ?? 0 != 0
    }
    
    var communityCallsMessage: String {
        let statsVm = StatsViewModel(numberOfCalls: store.state.globalCallCount)
        return Bundle.Strings.communityCalls(statsVm.formattedNumberOfCalls)
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
                    Text(Bundle.Strings.impactListMessage)

                    ImpactListItem(title: Bundle.Strings.madeContact, count: userStats?.contact ?? 0)
                    ImpactListItem(title: Bundle.Strings.leftVoicemail, count: userStats?.voicemail ?? 0)
                    ImpactListItem(title: Bundle.Strings.unavailable, count: userStats?.unavailable ?? 0)
                }
                Section {

                } footer: {
                        Text(store.state.globalCallCount > 0 ? communityCallsMessage : "")
                        .font(.footnote)
                }
            }
            .padding(.vertical)
            .listStyle(.plain)
            .navigationTitle(Bundle.Strings.yourImpactTitle)
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
                        Text(Bundle.Strings.doneButtonTitle)
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
    var title: String
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
        guard count != 1 else { return Bundle.Strings.calledSingle(count) }
        return Bundle.Strings.calledMultiple(count)
    }
}
