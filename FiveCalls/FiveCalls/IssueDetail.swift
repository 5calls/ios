//
//  IssueDetail.swift
//  FiveCalls
//
//  Created by Nick O'Neill on 8/11/23.
//  Copyright © 2023 5calls. All rights reserved.
//

import SwiftUI

struct IssueDetail: View {
    @EnvironmentObject var store: Store

    let issue: Issue
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 0) {
                IssueNavigationHeader()
                    .padding(.bottom, 8)
                Text(issue.name)
                    .font(.title2)
                    .fontWeight(.medium)
                    .padding(.bottom, 8)
                Text(issue.markdownIssueReason)
                    .padding(.bottom, 16)
                Text("Relevant representatives for this issue:")
                    .font(.caption)
                    .foregroundColor(.secondary)
                    .padding(.bottom, 2)
                    .padding(.leading, 6)
                VStack(spacing: 0) {
                    ForEach(issue.contactsForIssue(allContacts: store.state.contacts).numbered(), id: \.element.id) { contact in
                        ContactListItem(contact: contact.element)
                        if contact.number < 2 { Divider().padding(0) } else { EmptyView() }
                    }
                }.background {
                    RoundedRectangle(cornerRadius: 10)
                        .foregroundColor(Color(red: 0.85, green: 0.85, blue: 0.85))
                }.padding(.bottom, 16)
                NavigationLink(value: IssueDetailNavModel(issue: issue, contacts: issue.contactsForIssue(allContacts: store.state.contacts))) {
                    PrimaryButton(title: R.string.localizable.seeScript(), systemImageName: "megaphone.fill")
                }
            }.padding(.horizontal)
        }
.navigationBarHidden(true)
        .clipped()
    }
}

struct IssueDetail_Previews: PreviewProvider {
    static var previews: some View {
        IssueDetail(issue: Issue.multilinePreviewIssue)
            .environmentObject(Store(state: AppState()))
    }
}
