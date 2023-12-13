//
//  IssueContactDetail.swift
//  FiveCalls
//
//  Created by Nick O'Neill on 8/11/23.
//  Copyright © 2023 5calls. All rights reserved.
//

import SwiftUI

struct IssueContactDetail: View {
    @EnvironmentObject var store: Store
    @EnvironmentObject var router: IssueRouter

    let issue: Issue
    let remainingContacts: [Contact]
    
    var currentContact: Contact {
        return remainingContacts.first!
    }
    
    var nextContacts: [Contact] {
        return Array(remainingContacts.dropFirst())
    }
    
    var issueMarkdown: AttributedString {
        return issue.markdownIssueScript(contact: currentContact, location: store.state.location)
    }

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 0) {
                IssueNavigationHeader(issue: issue)
                    .padding(.bottom, 8)
                Text(issue.name)
                    .font(.title2)
                    .fontWeight(.medium)
                    .padding(.bottom, 16)
                ContactListItem(contact: currentContact)
                    .background {
                        RoundedRectangle(cornerRadius: 10)
                            .foregroundColor(Color.fivecallsLightBG)
                    }
                    .padding(.bottom)
                VStack(alignment: .trailing) {
                    HStack {
                        Spacer()
                        Text(currentContact.phone)
                            .font(.title)
                            .fontWeight(.semibold)
                            .foregroundColor(Color.fivecallsDarkBlueText)
                        Menu {
                            ForEach(currentContact.fieldOffices) { office in
                                Section(office.city) {
                                    Button{ } label: {
                                        VStack {
                                            Text(office.phone)
                                        }
                                    }
                                }
                            }
                        } label: {
                            Image(systemName: "ellipsis.circle")
                                .font(.title2)
                                .foregroundColor(Color.fivecallsDarkBlue)
                                .padding(.leading, 4)
                        }
                    }
                }.padding(.bottom)
<<<<<<< HEAD
<<<<<<< HEAD
                Text(issueMarkdown)
=======
                    .confirmationDialog("", isPresented: $showPhoneConfirmation, titleVisibility: .hidden) {
                        Button("Call \(currentPhoneNumber ?? "")") {
                            if let currentPhoneNumber,
                               let url = URL(string: "tel://\(currentPhoneNumber)") {
                                UIApplication.shared.open(url)
                            }
                        }
                        Button("Copy \(currentPhoneNumber ?? "")") {
                            UIPasteboard.general.string = currentPhoneNumber
                        }
                        Button("Cancel", role: .cancel) { }
                    }
=======
>>>>>>> 6133b17 (Revert "use confirmation dialog")
                Text(issue.markdownIssueScript)
>>>>>>> 4298a5e (use confirmation dialog)
                    .padding(.bottom)
                if remainingContacts.count > 1 {
                    NavigationLink(value: IssueDetailNavModel(issue: issue, contacts: nextContacts)) {
                        OutcomesView(outcomes: issue.outcomeModels, report: { outcome in
                            let log = ContactLog(issueId: String(issue.id), contactId: currentContact.id, phone: "", outcome: outcome.status, date: Date(), reported: true)
                            store.dispatch(action: .ReportOutcome(issue, log, outcome))
                            router.path.append(IssueDetailNavModel(issue: issue, contacts: nextContacts))
                        })
                    }
                } else {
                    NavigationLink(value: IssueNavModel(issue: issue, type: "done")) {
                        OutcomesView(outcomes: issue.outcomeModels, report:
                            { outcome in
                            let log = ContactLog(issueId: String(issue.id), contactId: currentContact.id, phone: "", outcome: outcome.status, date: Date(), reported: true)
                            store.dispatch(action: .ReportOutcome(issue, log, outcome))
                            router.path.append(IssueNavModel(issue: issue, type: "done"))
                        })
                    }
                }
                Spacer()
            }.padding(.horizontal)
        }.navigationBarHidden(true)
        .clipped()
    }
}

#Preview {
    let previewState = {
        let state = AppState()
        state.location = NewUserLocation(address: "3400 24th St, San Francisco, CA 94114", display: "San Francisco")
        return state
    }()

    return IssueContactDetail(issue: Issue.basicPreviewIssue, remainingContacts: [Contact.housePreviewContact])
        .environmentObject(Store(state: previewState))
}
