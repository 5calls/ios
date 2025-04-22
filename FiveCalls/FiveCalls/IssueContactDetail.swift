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

                        if currentContact.fieldOffices.count >= 1 {
                            Menu {
                                ForEach(currentContact.fieldOffices) { office in
                                    // ControlGroup doesn't render < 16.4 (https://github.com/5calls/ios/pull/446)
                                    if #available(iOS 16.4, *) {
                                        ControlGroup {
                                            MenuButtonsView(office: office, copiedPhoneNumber: $copiedPhoneNumber,
                                                            isCopiedPhoneNumberFocused: _isCopiedPhoneNumberFocused, call: call)
                                        }
                                    } else {
                                        MenuButtonsView(office: office, copiedPhoneNumber: $copiedPhoneNumber,
                                                        isCopiedPhoneNumberFocused: _isCopiedPhoneNumberFocused, call: call)
                                    }
                                }
                            } label: {
                                Image(systemName: "ellipsis.circle")
                                    .font(.title2)
                                    .foregroundColor(Color.fivecallsDarkBlue)
                                    .padding(.leading, 4)
                            }
                            .accessibilityIdentifier("localNumbers")
                        }
                    }
                }.padding(.bottom)
                
                Text(issueMarkdown)
                    .padding(.bottom)
                
                OutcomesView(outcomes: issue.outcomeModels, report: { outcome in
                    let log = ContactLog(issueId: String(issue.id), contactId: currentContact.id, phone: "", outcome: outcome.status, date: Date(), reported: true)
                    store.dispatch(action: .ReportOutcome(issue, log, outcome))
                    store.dispatch(action: .GoToNext(issue, nextContacts))
                })
                Spacer()
            }.padding(.horizontal)
        }
        .clipped()
    }

    private func call(phoneNumber: String) {
        let telephone = "tel://"
        let formattedString = telephone + phoneNumber
        guard let url = URL(string: formattedString) else { return }
        UIApplication.shared.open(url)
    }
}

struct MenuButtonsView: View {
    @Environment(\.dynamicTypeSize) private var dynamicTypeSize
    let office: AreaOffice
    @Binding var copiedPhoneNumber: String?
    @AccessibilityFocusState var isCopiedPhoneNumberFocused: Bool
    let call: (String) -> Void

    var body: some View {
        Button {
            self.call(office.phone)
        } label: {
            if dynamicTypeSize >= .accessibility1 {
                Text(R.string.localizable.a11yOfficeCallPhoneNumber(office.city, office.phone))
            } else {
                Image(systemName: "phone")
                Text(office.city)
            }
        }
        .accessibilityLabel(R.string.localizable.a11yOfficeCallPhoneNumber(office.city, office.phone))
        .accessibilityHint(R.string.localizable.a11yPhoneCallHint())

        // disable copy < 16.4 for rationale see https://github.com/5calls/ios/pull/446
        if #available(iOS 16.4, *) {
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
                if dynamicTypeSize >= .accessibility1 {
                    Text(R.string.localizable.a11yOfficeCopyPhoneNumber(office.city, office.phone))
                } else {
                    Image(systemName: "doc.on.doc")
                    Text(R.string.localizable.copy())
                }
            }
            .accessibilityLabel(R.string.localizable.a11yOfficeCopyPhoneNumber(office.city, office.phone))
            .accessibilityHint(R.string.localizable.a11yPhoneCopyHint())
        }
    }
}

#Preview {
    IssueContactDetail(issue: Issue.basicPreviewIssue, remainingContacts: [Contact.housePreviewContact, Contact.senatePreviewContact1])
        .environmentObject(Store(state: AppState()))
}
