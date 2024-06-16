//
//  InboxView.swift
//  FiveCalls
//
//  Created by Nick O'Neill on 2/25/24.
//  Copyright © 2024 5calls. All rights reserved.
//

import SwiftUI

struct InboxView: View {
    @EnvironmentObject var store: Store
    @State private var detailPresented: Bool = false

    var contacts: [Contact] {
        return store.state.contacts.filter({ $0.area == "US House" || $0.area == "US Senate" })
    }
    
    func contactForID(contactId: String) -> Contact? {
        return store.state.contacts.filter({ $0.id == contactId}).first
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            MainHeader()
                .padding(.horizontal, 10)
                .padding(.bottom, 10)

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
//                        HStack {
//                            Text("View all Representatives")
//                                .fontWeight(.medium)
//                                .padding(.vertical, 20)
//                            Spacer()
//                        }
                }

                HStack {
                    Text("Recent votes")
                        .font(.body)
                        .fontWeight(.medium)
                        .foregroundStyle(.secondary)
                    Spacer()
                }.padding(.top, 10)

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
            }.scrollIndicators(.hidden)

//                if store.state.votesSignedup {
//
//                } else {
//                    VStack {
//                        HStack {
//                            Text("Get notified when your rep votes on important issues")
//                                .font(.caption)
//                                .foregroundColor(.secondary)
//                                .padding(.bottom, 2)
//                                .padding(.leading, 6)
//                                .accessibilityAddTraits(.isHeader)
//                            Spacer()
//                        }
//
//                        PrimaryButton(title: "Send me my votes")
//                    }.padding(.horizontal, 20)
//                        .padding(.top, 20)
//
//                }
        }.padding(.horizontal, 16)
            .sheet(isPresented: $detailPresented) {
                InboxDetail()
            }
    }
}

#Preview {
    let previewState = {
        var state = AppState()
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
