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

    @State private var copiedPhoneNumber: String?
    @AccessibilityFocusState private var isCopiedPhoneNumberFocused: Bool

    
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
                        
                        if let copiedPhoneNumber {
                            Text(R.string.localizable.copiedPhone(copiedPhoneNumber))
                                .bold()
                                .font(.footnote)
                                .multilineTextAlignment(.center)
                                .accessibilityFocused($isCopiedPhoneNumberFocused)
                                .accessibilityLabel(R.string.localizable.a11yCopiedPhoneNumber())
                            Spacer()
                        }
                        
                        Text(currentContact.phone)
                            .font(.title)
                            .fontWeight(.semibold)
                            .foregroundColor(Color.fivecallsDarkBlueText)
                            .onTapGesture {
                                self.call(phoneNumber: currentContact.phone)
                            }
                            .onLongPressGesture(minimumDuration: 1.0) {
                                UIPasteboard.general.string = currentContact.phone
                                
                                withAnimation {
                                    copiedPhoneNumber = currentContact.phone
                                    if UIAccessibility.isVoiceOverRunning {
                                        DispatchQueue.main.asyncAfter(wallDeadline: .now() + 0.5) {
                                            isCopiedPhoneNumberFocused = true
                                        }
                                    }
                                }
                                
                                DispatchQueue.main.asyncAfter(wallDeadline: .now() + 3) {
                                    withAnimation {
                                        isCopiedPhoneNumberFocused = false
                                        copiedPhoneNumber = nil
                                    }
                                }
                            }
                            .accessibilityAddTraits(.isButton)
                            .accessibilityHint(R.string.localizable.a11yPhoneCallCopyHint())
                        
                        if currentContact.fieldOffices.count > 1 {
                            Menu {
                                ForEach(currentContact.fieldOffices) { office in
                                    Section {
                                        Text(office.city)
                                    }
                                    
                                    ControlGroup {
                                        Button {
                                            self.call(phoneNumber: office.phone)
                                        } label: {
                                            HStack {
                                                Image(systemName: "phone")
                                                Text(office.phone)
                                            }
                                        }
                                        .accessibilityLabel(R.string.localizable.a11yCallPhoneNumber(office.phone))
                                        .accessibilityHint(R.string.localizable.a11yPhoneCallHint())
                                        
                                        Button {
                                            UIPasteboard.general.string = office.phone
                                            withAnimation {
                                                copiedPhoneNumber = office.phone
                                                if UIAccessibility.isVoiceOverRunning {
                                                    isCopiedPhoneNumberFocused = true
                                                }
                                            }
                                            
                                            DispatchQueue.main.asyncAfter(wallDeadline: .now() + 3) {
                                                withAnimation {
                                                    isCopiedPhoneNumberFocused = false
                                                    copiedPhoneNumber = nil
                                                }
                                            }
                                        } label: {
                                            HStack {
                                                Image(systemName: "doc.on.doc")
                                                Text(R.string.localizable.copy())
                                            }
                                        }
                                        .accessibilityLabel(R.string.localizable.a11yCopyPhoneNumber(office.phone))
                                        .accessibilityHint(R.string.localizable.a11yPhoneCopyHint())
                                    }
                                }
                            } label: {
                                Image(systemName: "ellipsis.circle")
                                    .font(.title2)
                                    .foregroundColor(Color.fivecallsDarkBlue)
                                    .padding(.leading, 4)
                            }
                        }
                    }
                }.padding(.bottom)
                
                Text(issueMarkdown)
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
    
    private func call(phoneNumber: String) {
        let telephone = "tel://"
        let formattedString = telephone + phoneNumber
        guard let url = URL(string: formattedString) else { return }
        UIApplication.shared.open(url)
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
