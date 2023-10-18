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
    
    @State private var userStats: UserStats?
    @State private var totalCalls: Int = 0
    
    var weeklyStreekMessage: String {
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
    
    var showSubheading: Bool {
        userStats?.totalCalls() ?? 0 != 0
    }
    
    var communityCallsMessage: String {
        let statsVm = StatsViewModel(numberOfCalls: totalCalls)
        return R.string.localizable.communityCalls(statsVm.formattedNumberOfCalls)
    }
            
    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                VStack(alignment: .leading, spacing: 15) {
                    Text(weeklyStreekMessage)
                        .foregroundStyle(.fivecallsRed)
                        .font(.system(size: 18, weight: .semibold))
                        .frame(maxWidth: .infinity, alignment: .leading)
                    Text(totalImpactMessage)
                        .foregroundStyle(.fiveCallsDarkGreenText)
                        .font(.system(size: 18, weight: .semibold))
                        .frame(maxWidth: .infinity, alignment: .leading)
                    if showSubheading {
                        Text(R.string.localizable.subheadingMessage())
                            .font(.system(size: 17))
                    }
                }
                .padding(.top, 16)
                .padding(.horizontal, 16)
                
                
                List {
                    Section(header: Spacer(minLength: 0),
                            footer: HStack {
                        Text(totalCalls > 0 ? communityCallsMessage : "")
                    }) {
                        ImpactListItem(title: R.string.localizable.madeContact(), count: userStats?.contact ?? 0)
                        ImpactListItem(title: R.string.localizable.leftVoicemail(), count: userStats?.voicemail ?? 0)
                        ImpactListItem(title: R.string.localizable.unavailable(), count: userStats?.unavailable ?? 0)
                    }
                }
                .scrollContentBackground(.hidden)
                .listStyle(.grouped)
            }
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
            fetchTotalStats()
            fetchUserStats()
        }
        .accentColor(.white)
    }
    
    private func fetchTotalStats() {
        let totalCallsOp = FetchStatsOperation()
        totalCallsOp.completionBlock = {
            self.totalCalls = totalCallsOp.numberOfCalls ?? 0
        }
        
        OperationQueue.main.addOperation(totalCallsOp)
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
        NavigationView {
            YourImpact()
        }
    }
}

struct ImpactListItem: View {
    var title: String
    var count: Int
    
    var body: some View {
        HStack {
            Text(title)
            Spacer()
            Text(timesString(count: count))
        }
    }
    
    private func timesString(count: Int) -> String {
        guard count != 1 else { return R.string.localizable.calledSingle(count) }
        return R.string.localizable.calledMultiple(count)
    }
}
