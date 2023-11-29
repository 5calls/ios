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
        VStack {
            HStack {
                VStack(alignment: .leading) {
                    Text(issue.name)
                        .font(.title3)
                        .fontWeight(.semibold)                        
                        .foregroundColor(Color.fivecallsDarkBlueText)
                    Spacer()
                    HStack(spacing: 0) {
                        let contactsForIssue = contacts.isEmpty ? issue.contactAreas.flatMap({ area in
                            Contact.placeholderContact(for: area)
                        }) : issue.contactsForIssue(allContacts: contacts)
                        ForEach(contactsForIssue.numbered()) { numberedContact in
                            ContactCircle(contact: numberedContact.element, issueID: issue.id)
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
                .padding(.vertical, 10)
            }
        }
    }
    
    var repText: String {
        if issue.contactAreas.count == 0 {
            // we should never ship an issue with no contact areas, but handle the state anyway
            return "No contacts"
        } else {
            let areas = issue.contactAreas.map({ a in AreaToNiceString(area: a) }).joined(separator: ", ")
            return "Call \(areas)"
        }
    }
}

struct IssueListItem_Previews: PreviewProvider {
    static let previewState = {
        var state = AppState()
        state.issues = [
            Issue.basicPreviewIssue,
            Issue.multilinePreviewIssue
        ]
        state.contacts = [
            Contact.housePreviewContact,
            Contact.senatePreviewContact1,
            Contact.senatePreviewContact2
        ]
        return state
    }()

    static let store = Store(state: previewState, middlewares: [appMiddleware()])


    static var previews: some View {
        ScrollView {
            IssueListItem(issue: Issue.basicPreviewIssue, contacts: [Contact.housePreviewContact, Contact.senatePreviewContact1, Contact.senatePreviewContact2])
                .padding(.horizontal, 10)
            IssueListItem(issue: Issue.multilinePreviewIssue, contacts: [Contact.housePreviewContact, Contact.senatePreviewContact1])
                .padding(.horizontal, 10)
            IssueListItem(issue: Issue.extraLongPreviewIssue, contacts: [Contact.housePreviewContact])
                .padding(.horizontal, 10)
            IssueListItem(issue: Issue.multilinePreviewIssue, contacts: [])
                .padding(.horizontal, 10)
        }
        .environmentObject(store)
    }
}

