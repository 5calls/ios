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
                        Image(systemName: "arrowshape.up.circle")
                            .font(.title)
                            .foregroundColor(.secondary)
                            .padding(.trailing, 4)
                        Text("Set your location\rto see your reps")
                            .font(.title2)
                            .lineLimit(2)
                            .foregroundColor(.secondary)
                        Spacer()
                    }
                    Spacer()
                }
            } else {
                ScrollView {
                    HStack {
                        Text("Your National Reps")
                            .font(.body)
                            .fontWeight(.medium)
                            .foregroundStyle(.secondary)
                        Spacer()
                    }
                    
                    VStack(spacing: 0) {
                        ForEach(contacts.numbered(), id: \.element.id) { contact in
                            ContactListItem(contact: contact.element, showComplete: false)
                        }
                    }

                    HStack {
                        Text("Recent votes")
                            .font(.body)
                            .fontWeight(.medium)
                            .foregroundStyle(.secondary)
                        Spacer()
                    }.padding(.top, 10)

                    if showPushPrompt {
                        VStack {
                            PrimaryButton(title: "Send me important votes")
                                .onTapGesture {
                                    OneSignal.promptForPushNotifications { success in
                                        Task {
                                            await updateNotificationStatus()
                                        }
                                    }
                                }
                            Text("Get notified how your rep votes on important issues")
                                .font(.caption)
                                .fontWeight(.medium)
                                .frame(maxWidth: .infinity, alignment: .center)
                        }.padding(.vertical, 10)
                    }
                    
                    VStack {
                        ForEach(store.state.repMessages, id: \.id) { message in
                            if let repID = message.repID, let contact = self.contactForID(contactId: repID) {
                                ContactInboxVote(contact: contact, message: message)
                                    .padding(.bottom, 6)
                                    .onTapGesture{
                                        store.dispatch(action: .SelectMessage(message))
                                        detailPresented = true
                                    }
                            } else if let _ = message.imageURL {
                                GenericInboxVote(message: message)
                                    .onTapGesture{
                                        store.dispatch(action: .SelectMessage(message))
                                        detailPresented = true
                                    }
                            }
                        }
                    }.padding(4)
                }.scrollIndicators(.hidden)
            }
        }.padding(.horizontal, 16)
            .sheet(isPresented: $detailPresented) {
                InboxDetail()
            }
            .onAppear {
                Task {
                    await updateNotificationStatus()
                }
            }
    }
}

#Preview {
    let previewState = {
        let state = AppState()
        state.contacts = [
//            Contact.housePreviewContact,
//            Contact.senatePreviewContact1,
//            Contact.senatePreviewContact2
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
