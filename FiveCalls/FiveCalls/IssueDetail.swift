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
    let contacts: [Contact]
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 0) {
                IssueNavigationHeader(showBackButton: UIDevice.current.userInterfaceIdiom == .phone)
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
                    ForEach(contacts.numbered(), id: \.element.id) { contact in
                        ContactListItem(contact: contact.element)
                        if contact.number < 2 { Divider().padding(0) } else { EmptyView() }
                    }
                }.background {
                    RoundedRectangle(cornerRadius: 10)
                        .foregroundColor(Color(red: 0.85, green: 0.85, blue: 0.85))
                }.padding(.bottom, 16)
                NavigationLink(value: IssueDetailNavModel(issue: issue, contacts: contacts)) {
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
        IssueDetail(issue: Issue.multilinePreviewIssue, contacts: [.housePreviewContact,.senatePreviewContact1,.senatePreviewContact2])
            .environmentObject(Store(state: AppState()))
    }
}

struct IssueDetailNavModel {
    let issue: Issue
    let contacts: [Contact]
}

extension IssueDetailNavModel: Equatable, Hashable {
    static func == (lhs: IssueDetailNavModel, rhs: IssueDetailNavModel) -> Bool {
        return lhs.issue.id == rhs.issue.id && lhs.contacts.elementsEqual(rhs.contacts)
    }
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(issue.id)
        hasher.combine(contacts.compactMap({$0.id}).joined())
    }
}
