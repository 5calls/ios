//
//  IssueDetail.swift
//  FiveCalls
//
//  Created by Nick O'Neill on 8/11/23.
//  Copyright © 2023 5calls. All rights reserved.
//

import SwiftUI
import MarkdownUI

struct IssueDetail: View {
    @EnvironmentObject var store: Store
    
    let issue: Issue
    
    @State var showLocationSheet = false
    @State private var forceRefreshID = UUID()
    
    var targetedContacts: [Contact] { issue.contactsForIssue(allContacts: store.state.contacts) }
    
    // reps that we want to show, but not direct calls to
    var irrelevantContacts: [Contact] { issue.irrelevantContacts(allContacts: store.state.contacts) }
    
    // vacancies for both targeted and irrelevant contacts
    var vacantAreas: [String] {
        store.state.missingReps.filter { issue.contactAreas.contains($0) || $0 == issue.irrelevantContactArea() }
    }

    var hasStateReps: Bool {
        return IssueDetailWarningLogic.hasStateReps(in: issue.contactAreas)
    }

    // Testable function for warning display logic
    func shouldShowWarning() -> Bool {
        return IssueDetailWarningLogic.shouldShowWarning(
            contactsLowAccuracy: store.state.contactsLowAccuracy,
            issueContactAreas: issue.contactAreas
        )
    }

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 0) {
                Text(issue.name)
                    .font(.title2)
                    .fontWeight(.medium)
                    .padding(.top, 1)
                    .padding(.bottom, 8)
                Markdown(issue.reason)
                    .padding(.bottom, 16)
                    .accentColor(.fivecallsDarkBlueText)
                if store.state.location != nil {
                    Text(R.string.localizableR.repsListHeader())
                        .font(.caption)
                        .foregroundColor(.secondary)
                        .padding(.bottom, 2)
                        .padding(.leading, 6)
                        .accessibilityAddTraits(.isHeader)
                    VStack(spacing: 0) {
                        targetedRepsList
                        
                        if !irrelevantContacts.isEmpty {
                            Divider()
                        }
                        
                        irrelevantRepsList
                        
                        if !vacantAreas.isEmpty {
                            Divider()
                        }
                        
                        vacantRepsList
                    }
                    .background {
                        RoundedRectangle(cornerRadius: 10)
                            .foregroundColor(Color.fivecallsLightBG)
                    }
                    .padding(.bottom, 16)

                    if shouldShowWarning() {
                        Text(
                            "Warning: your location is set to a zip code or other approximate location, please enter an address or zip+4 for accurate state level reps.",
                            comment: "IssueDetail warning for imprecise location"
                        )
                            .font(.callout)
                            .fontWeight(.medium)
                            .foregroundColor(.red)
                            .padding(.horizontal, 12)
                            .padding(.bottom, 16)
                    }

                    if !targetedContacts.isEmpty {
                        NavigationLink(value: IssueDetailNavModel(issue: issue, contacts: targetedContacts)) {
                            PrimaryButton(
                                title: LocalizedStringResource(
                                    "See your script",
                                    comment: "navigation link button to see the script"
                                ),
                                systemImageName: "megaphone.fill"
                            )
                        }
                    }
                } else {
                    Text(R.string.localizableR.setLocationHeader())
                        .font(.caption)
                        .foregroundColor(.secondary)
                        .padding(.bottom, 2)
                        .padding(.leading, 6)
                    Button(
                        action: {
                            showLocationSheet.toggle()
                        },
                        label: {
                            PrimaryButton(
                                title: LocalizedStringResource(
                                    "Set your location",
                                    comment: "IssueDetail button prompt to set location"
                                ),
                                systemImageName: "location.circle.fill"
                            )
                        }
                    )
                }
            }
            .padding(.horizontal)
        }
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                ShareLink(item: issue.shareURL) {
                    HStack(spacing: 4) {
                        Text("Share", comment: "Share toolbar button text")
                            .fontWeight(.medium)
                        Image(systemName: "square.and.arrow.up")
                            .font(.body)
                            .offset(y: -1)
                    }
                }
            }
        }
        .sheet(isPresented: $showLocationSheet) {
            LocationSheet()
                .presentationDetents([.medium])
                .presentationDragIndicator(.visible)
                .padding(.top, 40)
            Spacer()
        }
        .onAppear {
            // Force refresh id so that async images can load. See https://github.com/5calls/ios/issues/465
            forceRefreshID = UUID()
            
            AnalyticsManager.shared.trackPageview(path: "/issue/\(issue.slug)/")
            store.dispatch(action: .FetchCustomizedScripts(issue.id, targetedContacts.map(\.id)))
        }
    }
    
    private var targetedRepsList: some View {
        ForEach(targetedContacts.numbered(), id: \.element.id) { contact in
            NavigationLink(value: IssueDetailNavModel(issue: issue, contacts: Array(targetedContacts[contact.number..<targetedContacts.endIndex]))) {
                ContactListItem(contact: contact.element, showComplete: store.state.issueCalledOn(issueID: issue.id, contactID: contact.id))
                    .id(forceRefreshID)
            }
            
            if contact.number < targetedContacts.count - 1 {
                Divider()
            }
        }
    }
    
    private var irrelevantRepsList: some View {
        ForEach(irrelevantContacts, id: \.self) { contact in
            ContactListItem(
                contact: contact,
                showComplete: store.state.issueCalledOn(issueID: issue.id, contactID: contact.id),
                contactNote: LocalizedStringResource(
                    "This representative is not currently relevant to this issue.",
                    comment: "Contact list item note for an irrelevant contact"
                )
            )
            .opacity(0.4)
            .id(forceRefreshID)
            
            if contact != irrelevantContacts.last {
                Divider()
            }
        }
    }
    
    private var vacantRepsList: some View {
        ForEach(vacantAreas.numbered(), id: \.element) { contact in
            let area = contact.element
            let contactItem = Contact(
                area: area,
                name: String(
                    localized: "Vacant Seat",
                    comment: "Vacant seat contact name"
                )
            )
            let note = LocalizedStringResource("This \(area) seat is currently vacant.")

            ContactListItem(contact: contactItem, contactNote: note)
                .opacity(0.4)
            
            if contact.number < vacantAreas.count - 1 {
                Divider()
            }
        }
    }
}

#Preview {
    let store: Store = {
        let state = AppState()
        state.contacts = [.housePreviewContact, .senatePreviewContact1, .senatePreviewContact2, .unknownMayorPreviewContact]
        return Store(state: state)
    }()
    
    return IssueDetail(issue: .houseOnlyPreviewIssue)
        .environmentObject(store)
}

struct IssueDetailNavModel {
    var issue: Issue
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

// MARK: - Testable Warning Logic

struct IssueDetailWarningLogic {
    static func shouldShowWarning(contactsLowAccuracy: Bool, issueContactAreas: [String]) -> Bool {
        return contactsLowAccuracy && IssueDetailWarningLogic
            .hasStateReps(in: issueContactAreas)
    }

    static func hasStateReps(in issueContactAreas: [String]) -> Bool {
        return issueContactAreas.contains { area in
            area == "StateUpper" || area == "StateLower"
        }
    }
}
