//
//  InboxView.swift
//  FiveCalls
//
//  Created by Nick O'Neill on 2/25/24.
//  Copyright © 2024 5calls. All rights reserved.
//

import SwiftUI
import OneSignal

struct InboxView: View {
    @EnvironmentObject var store: Store
    @State private var detailPresented: Bool = false
    @State private var showPushPrompt: Bool = true
    @State private var showContactAlert: Bool = false

    var contacts: [Contact] {
        return store.state.contacts.filter({ $0.area == "US House" || $0.area == "US Senate" })
    }
    
    func contactForID(contactId: String) -> Contact? {
        return store.state.contacts.filter({ $0.id == contactId}).first
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
                        Text(Bundle.Strings.inboxEmptyState)
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
                        Text(Bundle.Strings.inboxRepsHeader)
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
                            ContactListItem(contact: Contact(name: Bundle.Strings.vacantSeatTitle), contactNote: Bundle.Strings.vacantSeatMessage(missingRepArea))
                                .opacity(0.5)
                        }
                    }

                    if false { // remove this until we can update it regularly
                        HStack {
                            Text(Bundle.Strings.inboxVotesHeader)
                                .font(.body)
                                .fontWeight(.bold)
                                .accessibilityAddTraits(.isHeader)
                            Spacer()
                        }.padding(.top, 10)

                        if showPushPrompt {
                            VStack {
                                PrimaryButton(title: Bundle.Strings.inboxPushButton)
                                    .onTapGesture {
                                        OneSignal.promptForPushNotifications { success in
                                            Task {
                                                await updateNotificationStatus()
                                            }
                                        }
                                    }
                                Text(Bundle.Strings.inboxPushDetail)
                                    .font(.caption)
                                    .fontWeight(.medium)
                                    .multilineTextAlignment(.center)
                                    .frame(maxWidth: .infinity, alignment: .center)
                            }.padding(.vertical, 10)
                        }
                        
                        VStack {
                            ForEach(store.state.repMessages) { message in
                                if let repID = message.repID, let contact = self.contactForID(contactId: repID) {
                                    ContactInboxVote(contact: contact, message: message)
                                        .padding(.bottom, 6)
                                        .onTapGesture{
                                            store.dispatch(action: .SelectMessage(message))
                                        }
                                } else if let _ = message.imageURL {
                                    GenericInboxVote(message: message)
                                        .onTapGesture{
                                            store.dispatch(action: .SelectMessage(message))
                                        }
                                }
                            }
                        }.padding(4)
                    }
                }.padding(.horizontal, 16)
                .scrollIndicators(.hidden)
            }
        }.alert(Bundle.Strings.inboxContactAlert, isPresented: $showContactAlert) {
            Button(Bundle.Strings.okButtonTitle, role: .cancel) { }
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
            .onChange(of: store.state.inboxRouter.selectedMessage, perform: { message in
                if message != nil {
                    detailPresented = true
                } else {
                    detailPresented = false
                }
            })
    }
}

#Preview {
    let previewState = {
        let state = AppState()
        state.contacts = [
            Contact.housePreviewContact,
            Contact.senatePreviewContact1,
            Contact.senatePreviewContact2
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
