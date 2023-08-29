//
//  IssueDetail.swift
//  FiveCalls
//
//  Created by Nick O'Neill on 8/11/23.
//  Copyright © 2023 5calls. All rights reserved.
//

import SwiftUI

struct IssueDetail: View {
    let issue: Issue
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 0) {
//                Text(issue.name)
//                    .font(.title2)
//                    .fontWeight(.medium)
//                    .padding(.bottom, 16)
                Text(issue.markdownIssueReason)
                    .padding(.bottom, 16)
                Text("Relevant representatives for this issue:")
                    .font(.caption)
                    .foregroundColor(.secondary)
                    .padding(.bottom, 2)
                    .padding(.leading, 6)
                VStack(spacing: 0) {
                    ForEach(0..<3, id: \.self) { count in
                        ContactListItem(contact: .housePreviewContact)
                        if count < 2 { Divider().padding(0) } else { EmptyView() }
                    }
                }.background {
                    RoundedRectangle(cornerRadius: 10)
                        .foregroundColor(Color(red: 0.85, green: 0.85, blue: 0.85))
                }.padding(.bottom, 16)
                NavigationLink(destination: IssueContactDetail(issue: issue, contact: .housePreviewContact)) {
                    PrimaryButton(title: "See your script", systemImageName: "megaphone.fill")
                        .navigationTitle(issue.name)
                        .navigationBarTitleDisplayMode(.large)
                }
            }.padding(.horizontal)
        }
    }
}

struct IssueDetail_Previews: PreviewProvider {
    static var previews: some View {
        IssueDetail(issue: Issue.multilinePreviewIssue)
    }
}
