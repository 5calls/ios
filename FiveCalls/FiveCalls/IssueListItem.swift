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
    @Environment(\.dynamicTypeSize) private var dynamicTypeSize

    func usingRegularFonts() -> Bool {
        dynamicTypeSize < DynamicTypeSize.accessibility3
    }

    var body: some View {
        VStack {
            HStack {
                VStack(alignment: .leading) {
                    Text(issue.name)
                        .font(.title3)
                        .fontWeight(.semibold)                        
                        .foregroundColor(Color.fivecallsDarkBlueText)

                    HStack(spacing: 0) {
                        // State-specific badge on left side
                        if issue.isStateSpecific, let stateName = issue.stateNameFromAbbreviation {
                            HStack(spacing: 4) {
                                Image(systemName: "mappin.and.ellipse")
                                    .font(.caption2)
                                Text(stateName)
                                    .font(.caption)
                                    .fontWeight(.medium)
                            }
                            .foregroundColor(Color.fivecallsRedText)
                            .padding(.horizontal, 8)
                            .padding(.vertical, 3)
                            .background(Color.fivecallsRedText.opacity(0.1))
                            .clipShape(Capsule())
                            .padding(.trailing, 8)
                        }
                        
                        let contactsForIssue = contacts.isEmpty ? issue.contactAreas.flatMap({ area in
                            Contact.placeholderContact(for: area)
                        }) : issue.contactsForIssue(allContacts: contacts)
                        ForEach(contactsForIssue.numbered()) { numberedContact in
                            ContactCircle(contact: numberedContact.element, issueID: issue.id)
                                .frame(width: usingRegularFonts() ? 20 : 40, height: usingRegularFonts() ? 20 : 40)
                                .offset(x: -10 * CGFloat(numberedContact.number), y:0)
                        }
                        Text(localizedRepText)
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
    
    var localizedRepText: LocalizedStringResource {
        let areas = issue.contactAreas

        guard !areas.isEmpty else {
            return LocalizedStringResource(
                "No contacts",
                comment: "Issue list view list item text for no contacts"
            )
        }

        let hasStateUpper = areas.contains("StateUpper")
        let hasStateLower = areas.contains("StateLower")

        let labels: [String] = areas.map { area in
            if (area == "StateUpper" || area == "StateLower") && hasStateUpper && hasStateLower {
                return String(localized: "State Reps", comment: "Localized rep text for multiple reps")
            } else if area == "StateUpper" || area == "StateLower" {
                return String(localized: "State Rep" , comment: "Localized rep text for single rep")
            } else {
                return areaToNiceString(area: area)
            }
        }

        let list = Array(Set(labels)).sorted().joined(separator: ", ")

        return LocalizedStringResource("Call \(list)", comment: "Sorted list of Representative offices")
    }
}

#Preview {
    let previewState = {
        let state = AppState()
        state.location = UserLocation(address: "3400 24th St, San Francisco, CA 94114", display: "San Francisco")
        return state
    }()


    List {
        IssueListItem(
            issue: Issue.basicPreviewIssue,
            contacts: [
                Contact.housePreviewContact,
                Contact.senatePreviewContact1,
                Contact.senatePreviewContact2,
            ]
        )
                .padding(.horizontal, 10)
        IssueListItem(issue: Issue.stateSpecificPreviewIssue, contacts: [Contact.housePreviewContact, Contact.senatePreviewContact1])
                .padding(.horizontal, 10)
            IssueListItem(issue: Issue.multilinePreviewIssue, contacts: [Contact.housePreviewContact, Contact.senatePreviewContact1])
                .padding(.horizontal, 10)
            IssueListItem(issue: Issue.extraLongPreviewIssue, contacts: [Contact.housePreviewContact])
                .padding(.horizontal, 10)
            IssueListItem(issue: Issue.multilinePreviewIssue, contacts: [])
                .padding(.horizontal, 10)
        IssueListItem(issue: Issue.manyContactPreviewIssue, contacts: [
            Contact.housePreviewContact,
            Contact.senatePreviewContact1,
            Contact.senatePreviewContact2,
            Contact.governorPreviewContact,
            Contact.agPreviewContact,
])
            .padding(.horizontal, 10)
        }
        .environmentObject(Store(state: previewState))
}

