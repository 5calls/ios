//
//  IssueDone.swift
//  FiveCalls
//
//  Created by Nick O'Neill on 10/2/23.
//  Copyright © 2023 5calls. All rights reserved.
//

import SwiftUI

struct IssueDone: View {
    @EnvironmentObject var router: IssueRouter
    
    let issue: Issue
    
    var totalCalls: Int?
    var issueCalls: Int?
    var showDonate: Bool?
    
    // "nice work!"
    // reps called
    // total calls
    // issue calls
    // donate
    // share image
    // done
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading) {
                Text("Issue \(issue.name) done page")
                if let totalCalls {
                    CountingView(title: "Total calls", count: totalCalls)
                }
                if let issueCalls {
                    CountingView(title: "Calls on this topic", count: issueCalls)
                }
                Button(action: {
                    router.backToRoot()
                }, label: {
                    Text("Back to dashboard")
                })
            }
            .padding(.horizontal)
        }.navigationBarHidden(true)
        .clipped()
        .onAppear() {
            loadStats()
        }
    }
        
    func loadStats() {
        
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
            ZStack(alignment: Alignment(horizontal: .leading, vertical: .center)) {
                RoundedRectangle(cornerSize: CGSize(width: 5, height: 5))
                    .foregroundColor(.fivecallsLightBG)
                RoundedRectangle(cornerSize: CGSize(width: 5, height: 5))
                    .foregroundColor(.fivecallsDarkBlue)
                    .frame(width: 100)
                Text("\(count)")
                    .foregroundStyle(.white)
                    .padding(.vertical, 2)
                    .padding(.horizontal, 6)
            }
        }
    }
}

#Preview {
    IssueDone(issue: .basicPreviewIssue, totalCalls: 1000000, issueCalls: 12345, showDonate: true)
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
