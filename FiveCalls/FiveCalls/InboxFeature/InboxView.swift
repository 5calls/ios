// Copyright 5calls. All rights reserved. See LICENSE for details.

import OneSignal
import SwiftUI

struct InboxView: View {
    @EnvironmentObject var store: Store
    @State private var detailPresented: Bool = false
    @State private var showPushPrompt: Bool = true
    @State private var showContactAlert: Bool = false

    var contacts: [Contact] {
        store.state.contacts.filter { $0.area == "US House" || $0.area == "US Senate" }
    }

    func contactForID(contactId: String) -> Contact? {
        store.state.contacts.filter { $0.id == contactId }.first
    }

    func updateNotificationStatus() async {
        let settings = await UNUserNotificationCenter.current().notificationSettings()
        if settings.authorizationStatus == .authorized || settings.authorizationStatus == .denied {
            showPushPrompt = false
        }
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            MainHeader()
                .padding(.horizontal, 10)
                .padding(.bottom, 10)

            if store.state.contacts.isEmpty {
                VStack {
                    Spacer()
                    HStack {
                        Spacer()
                        Image(systemName: "arrowshape.up.fill")
                            .font(.title)
                            .foregroundColor(.secondary)
                            .padding(.trailing, 4)
                        Text("Set your location\rto see your reps", comment: "Inbox no contacts suggestion")
                            .font(.title2)
                            .fontWeight(.medium)
                            .lineLimit(2)
                            .foregroundColor(.secondary)
                        Spacer()
                    }.accessibilityElement(children: .combine)
                    Spacer()
                }
            } else {
                ScrollView {
                    HStack {
                        Text("Your National Reps", comment: "Inbox reps header")
                            .font(.body)
                            .fontWeight(.bold)
                            .accessibilityAddTraits(.isHeader)
                        Spacer()
                    }

                    VStack(spacing: 0) {
                        ForEach(contacts.numbered()) { contact in
                            ContactListItem(contact: contact.element, showComplete: false)
                                .onTapGesture {
                                    showContactAlert = true
                                }
                        }

                        ForEach(store.state.missingReps, id: \.self) { missingRepArea in
                            ContactListItem(
                                contact: Contact(name: "Vacant Seat"),
                                contactNote: LocalizedStringResource(
                                    "This \(missingRepArea) seat is currently vacant.",
                                    comment: "ContactListItem note for a vacant seat"
                                )
                            )
                            .opacity(0.5)
                        }
                    }

                    if false { // remove this until we can update it regularly
                        HStack {
                            Text("Recent messages", comment: "Inbox messages header")
                                .font(.body)
                                .fontWeight(.bold)
                                .accessibilityAddTraits(.isHeader)
                            Spacer()
                        }.padding(.top, 10)

                        if showPushPrompt {
                            VStack {
                                PrimaryButton(
                                    title: LocalizedStringResource(
                                        "Send me important votes",
                                        comment: "Prompt for push notifications button title"
                                    )
                                )
                                .onTapGesture {
                                    OneSignal.promptForPushNotifications { _ in
                                        Task {
                                            await updateNotificationStatus()
                                        }
                                    }
                                }
                                Text(
                                    "Get notified how your rep votes on your topics,\r1-2 notifications per month",
                                    comment: "Inbox push notifications prompt"
                                )
                                .font(.caption)
                                .fontWeight(.medium)
                                .multilineTextAlignment(.center)
                                .frame(maxWidth: .infinity, alignment: .center)
                            }.padding(.vertical, 10)
                        }

                        VStack {
                            ForEach(store.state.repMessages) { message in
                                if let repID = message.repID, let contact = contactForID(contactId: repID) {
                                    ContactInboxVote(contact: contact, message: message)
                                        .padding(.bottom, 6)
                                        .onTapGesture {
                                            store.dispatch(action: .SelectMessage(message))
                                        }
                                } else if let _ = message.imageURL {
                                    GenericInboxVote(message: message)
                                        .onTapGesture {
                                            store.dispatch(action: .SelectMessage(message))
                                        }
                                }
                            }
                        }.padding(4)
                    }
                }.padding(.horizontal, 16)
                    .scrollIndicators(.hidden)
            }
        }.alert(
            String(
                localized: "Select an issue on the topics tab to show relevant reps and phone numbers",
                comment: "Inbox Alert title"
            ),
            isPresented: $showContactAlert
        ) {
            Button(String(localized: "OK", comment: "Standard OK Button text"), role: .cancel) {}
        }
        .sheet(isPresented: $detailPresented, onDismiss: {
            store.dispatch(action: .SelectMessage(nil))
        }) {
            if let message = store.state.inboxRouter.selectedMessage {
                InboxDetail(message: message)
                    .padding(.top, 20)
                    .padding(.horizontal, 10)
            }
        }
        .onAppear {
            Task {
                await updateNotificationStatus()
            }
        }
        .onChange(of: store.state.inboxRouter.selectedMessage){
            if store.state.inboxRouter.selectedMessage != nil {
                detailPresented = true
            } else {
                detailPresented = false
            }
        }
    }
}

#Preview {
    let previewState = {
        let state = AppState()
        state.contacts = [
            Contact.housePreviewContact,
            Contact.senatePreviewContact1,
            Contact.senatePreviewContact2,
        ]
        state.repMessages = [
            InboxMessage.houseMessage,
            InboxMessage.senate1Message,
            InboxMessage.senate2Message,
            InboxMessage.whMessage,
            InboxMessage.whMessage,
            InboxMessage.whMessage,
            InboxMessage.whMessage,
            InboxMessage.whMessage,
            InboxMessage.whMessage,
        ]
        return state
    }()

    let store = Store(state: previewState, middlewares: [appMiddleware()])

    return InboxView().environmentObject(store)
}
