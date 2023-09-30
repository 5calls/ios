//
//  IssueListItem.swift
//  FiveCalls
//
//  Created by Nick O'Neill on 6/28/23.
//  Copyright © 2023 5calls. All rights reserved.
//

import SwiftUI

struct IssueListItem: View {
    let issue: Issue
    let contacts: [Contact]
    
    var body: some View {
        ZStack(alignment: .leading) {
            RoundedRectangle(cornerRadius: 10, style: .continuous)
                .fill(Color(.secondarySystemBackground))
                .clipped()
            VStack {
                HStack {
                    VStack(alignment: .leading) {
                        Text(issue.name)
                            .font(.system(size: 20, weight: .semibold))
                            .foregroundColor(Color.fivecallsDarkBlueText)
                            .lineLimit(2)
                            .multilineTextAlignment(.leading)
                        Spacer()
                        HStack(spacing: 0) {
                            let contactsForIssue = issue.contactsForIssue(allContacts: contacts)
                            ForEach(contactsForIssue.numbered()) { numberedContact in
                                ContactCircle(contact: numberedContact.element)
                                    .frame(width: 20, height: 20)
                                    .offset(x: -10 * CGFloat(numberedContact.number), y:0)
                            }
                            Text(repText)
                                .font(.footnote)
                                .foregroundColor(.primary)
                                .offset(x: contactsForIssue.isEmpty ? 0 : 16 + (-10 * CGFloat(contactsForIssue.count)), y: 0)
                            Spacer()
                        }
                    }
                    .padding(.leading, 10)
                    .padding(.vertical, 10)
                    Spacer()
                    Image(systemName: "chevron.right.circle.fill")
                        .imageScale(.large)
                        .symbolRenderingMode(.monochrome)
                        .padding(.trailing, 10)
                        .font(.system(size: 14, weight: .bold))
                        .foregroundColor(Color.fivecallsDarkBlue)
                }
            }
        }
        .clipped()
    }
    
    var repText: String {
        if issue.contactAreas.count == 0 {
            // we should never ship an issue with no contacts, right?
            return "No contacts"
        } else {
            let areas = issue.contactAreas.map({ a in AreaToNiceString(area: a) }).joined(separator: ", ")
            return "Call \(areas)"
        }
    }
}

struct IssueListItem_Previews: PreviewProvider {
    static var previews: some View {
        ScrollView {
            IssueListItem(issue: Issue.basicPreviewIssue, contacts: [Contact.housePreviewContact, Contact.senatePreviewContact1, Contact.senatePreviewContact2])
                .padding(.horizontal, 10)
            IssueListItem(issue: Issue.multilinePreviewIssue, contacts: [Contact.housePreviewContact, Contact.senatePreviewContact1])
                .padding(.horizontal, 10)
            IssueListItem(issue: Issue.multilinePreviewIssue, contacts: [Contact.housePreviewContact])
                .padding(.horizontal, 10)
            IssueListItem(issue: Issue.multilinePreviewIssue, contacts: [])
                .padding(.horizontal, 10)
        }
    }
}
