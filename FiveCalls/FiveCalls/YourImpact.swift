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
            return R.string.localizable.yourWeeklyStreakZero(weeklyStreakCount)
        case 1:
            return R.string.localizable.yourWeeklyStreakSingle()
        default:
            return R.string.localizable.yourWeeklyStreakMultiple(weeklyStreakCount)
        }
    }
    
    var totalImpactMessage: String {
        let numberOfCalls = userStats?.totalCalls() ?? 0
        switch numberOfCalls {
        case 0:
            return R.string.localizable.yourImpactZero(numberOfCalls)
        case 1:
            return R.string.localizable.yourImpactSingle(numberOfCalls)
        default:
            return R.string.localizable.yourImpactMultiple(numberOfCalls)
        }
    }
    
    var showImpactList: Bool {
        userStats?.totalCalls() ?? 0 != 0
    }
    
    var communityCallsMessage: String {
        let statsVm = StatsViewModel(numberOfCalls: store.state.globalCallCount)
        return R.string.localizable.communityCalls(statsVm.formattedNumberOfCalls)
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
                    Text(R.string.localizable.impactListMessage())

                    ImpactListItem(title: R.string.localizable.madeContact(), count: userStats?.contact ?? 0)
                    ImpactListItem(title: R.string.localizable.leftVoicemail(), count: userStats?.voicemail ?? 0)
                    ImpactListItem(title: R.string.localizable.unavailable(), count: userStats?.unavailable ?? 0)
                }
                Section {

                } footer: {
                        Text(store.state.globalCallCount > 0 ? communityCallsMessage : "")
                        .font(.footnote)
                }
            }
            .padding(.vertical)
            .listStyle(.plain)
            .navigationTitle(R.string.localizable.yourImpactTitle())
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
                        Text(R.string.localizable.doneButtonTitle())
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
        guard count != 1 else { return R.string.localizable.calledSingle(count) }
        return R.string.localizable.calledMultiple(count)
    }
}
