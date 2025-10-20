// Copyright 5calls. All rights reserved. See LICENSE for details.

import MarkdownUI
import SwiftUI

struct IssueContactDetail: View {
    @EnvironmentObject var store: Store

    let issue: Issue
    let remainingContacts: [Contact]

    var currentContact: Contact {
        remainingContacts.first!
    }

    var nextContacts: [Contact] {
        Array(remainingContacts.dropFirst())
    }

    var issueMarkdown: String {
        if let customizedScript = store.state.customizedScript(issueID: issue.id, contactID: currentContact.id) {
            ScriptReplacements
                .replacing(
                    script: customizedScript,
                    contact: currentContact,
                    location: store.state.location
                )
        } else {
            ScriptReplacements
                .replacing(
                    script: issue.script,
                    contact: currentContact,
                    location: store.state.location
                )
        }
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
                            Text("Copied\n\(copiedPhoneNumber)!", comment: "Copied phone number message")
                                .bold()
                                .font(.footnote)
                                .multilineTextAlignment(.center)
                                .accessibilityFocused($isCopiedPhoneNumberFocused)
                                .accessibilityLabel(
                                    String(
                                        localized: "Copied phone number",
                                        comment: "Copied phone number accessibility label"
                                    )
                                )
                            Spacer()
                        }

                        Text(currentContact.phone)
                            .font(.title)
                            .fontWeight(.semibold)
                            .foregroundColor(Color.fivecallsDarkBlueText)
                            .onTapGesture {
                                call(phoneNumber: currentContact.phone)
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
                            .accessibilityHint(
                                String(
                                    localized: "Triple tap to copy",
                                    comment: "Copy phone number accissibility hint"
                                )
                            )

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

                Markdown(issueMarkdown)
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
            call(office.phone)
        } label: {
            if dynamicTypeSize >= .accessibility1 {
                Text("Call \(office.city) \(office.phone)", comment: "Call phone numbers text")
            } else {
                Image(systemName: "phone")
                Text(office.city)
            }
        }
        .accessibilityLabel(
            String(
                localized: "Call \(office.city) \(office.phone)",
                comment: "Call phone numbers accessibility label"
            )
        )
        .accessibilityHint(
            String(
                localized: "Double tap to call",
                comment: "Call phone numbers accessibility hint"
            )
        )

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
                    Text("Copy \(office.city) \(office.phone)", comment: "Copy phone numbers text")
                } else {
                    Image(systemName: "doc.on.doc")
                    Text("Copy", comment: "Copy phone number short text")
                }
            }
            .accessibilityLabel(
                String(
                    localized: "Copy \(office.city) \(office.phone)",
                    comment: "Copy phone numbers accessibility label"
                )
            )
            .accessibilityHint(
                String(
                    localized: "Triple tap to copy",
                    comment: "Copy phone number accissibility hint"
                )
            )
        }
    }
}

#Preview {
    IssueContactDetail(issue: Issue.basicPreviewIssue, remainingContacts: [Contact.housePreviewContact, Contact.senatePreviewContact1])
        .environmentObject(Store(state: AppState()))
}
