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
    let contacts: [Contact]
    
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
                HStack {
                    Spacer()
                    Text("You called on **\(issue.name)**")
                        .font(.title2)
                    Spacer()
                }.padding(.bottom, 16)
                VStack {
                    if let totalCalls {
                        CountingView(title: "Total calls", count: totalCalls)
                            .padding(.bottom, 14)
                    }
                    if let issueCalls {
                        CountingView(title: "Calls on this topic", count: issueCalls)
                            .padding(.bottom, 14)
                    }
                }.padding(.bottom, 16)
                Text("You called these reps")
                    .font(.caption).fontWeight(.medium)
                VStack(spacing: 2) {
                    ForEach(contacts) { contact in
                        ContactListItem(contact: contact)
                    }
                }.padding(.bottom, 16)
                Text("Support 5 Calls")
                    .font(.caption).fontWeight(.medium)
                HStack {
                    Text("Keep 5 Calls free and updated")
                    PrimaryButton(title: "Donate today", systemImageName: "hand.thumbsup.circle.fill", bgColor: .fivecallsRed)
                }.padding(.bottom, 16)
                Text("Share this topic")
                    .font(.caption).fontWeight(.medium)
                AsyncImage(url: issue.shareImageURL,
                           content: { image in
                    image.resizable()
                        .aspectRatio(contentMode: .fill)
                }, placeholder: { EmptyView() })
                Button(action: {
                    router.backToRoot()
                }, label: {
                    PrimaryButton(title: "Done", systemImageName: "flag.checkered")

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
    IssueDone(issue: .basicPreviewIssue, contacts: [.housePreviewContact,.senatePreviewContact1,.senatePreviewContact2], totalCalls: 1000000, issueCalls: 12345, showDonate: true)
}

struct IssueNavModel {
    let issue: Issue
    let contacts: [Contact]
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
