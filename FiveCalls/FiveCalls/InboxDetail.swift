//
//  InboxDetail.swift
//  FiveCalls
//
//  Created by Nick O'Neill on 6/3/24.
//  Copyright © 2024 5calls. All rights reserved.
//

import SwiftUI

struct InboxDetail: View {
    @EnvironmentObject var store: Store
    @Environment(\.dismiss) var dismiss

    var message: InboxMessage
    var contactForMessage: Contact? {
        return store.state.contacts.filter({ $0.id == message.repID}).first
    }

    var body: some View {
        VStack {
            HStack {
                if let contact = contactForMessage {
                    ContactListItem(contact: contact, showComplete: false)
                } else if let imageURL = message.imageURL, let contactName = message.contactName, let contactTitle = message.contactTitle {
                    HStack {
                        AsyncImage(url: imageURL, content: { image in
                            image.resizable()
                                .aspectRatio(contentMode: .fill)
                                .mask {
                                    Circle()
                                }
                        }) {
                            placeholder
                        }
                        .frame(width: 45, height: 45)
                        .padding(.vertical, 8)
                        .padding(.leading, 8)
                        .padding(.trailing, 0)
                        VStack(alignment: .leading) {
                            Text(contactName)
                                .font(.title3)
                                .fontWeight(.semibold)
                                .foregroundStyle(Color.primary)
                            Text(contactTitle)
                                .font(.footnote)
                                .foregroundStyle(Color.primary)
                            
                        }
                        .accessibilityElement(children: .combine)
                        Spacer()
                    }
                    .padding(2)
                    .accessibilityElement(children: .combine)
                }
                Button("", systemImage: "xmark") {
                    self.dismiss()
                }
            }
            HStack {
                Text(message.title)
                    .font(.title3)
                    .fontWeight(.medium)
                    .padding(.bottom, 4)
                Spacer()
            }
            HStack {
                Spacer()
                Text(message.date.formatted(date: .complete, time: .omitted))
                    .font(.footnote)
                    .foregroundStyle(.secondary)
            }.padding(.bottom, 0)
            Text(message.description)
                .padding(.bottom, 4)
            if let moreInfoURL =  message.moreInfoURL {
                Link(Bundle.Strings.inboxDetailReadmore, destination: moreInfoURL)
                    .fontWeight(.medium)
            }
            Spacer()
        }
        .padding(.horizontal, 10)
    }
        
    var placeholder: some View {
        Image(systemName: "person.crop.circle")
            .resizable()
            .mask {
                Circle()
            }
    }
}

#Preview {
    let preview1State = {
        let state = AppState()
        state.contacts = [
            Contact.housePreviewContact,
            Contact.senatePreviewContact1,
            Contact.senatePreviewContact2
        ]
        state.inboxRouter.selectedMessage = .houseMessage
        return state
    }()
    let store1 = Store(state: preview1State, middlewares: [appMiddleware()])

    return Rectangle().sheet(isPresented: .constant(true)) {
        InboxDetail(message: .houseMessage).environmentObject(store1)
            .padding(.top, 20)
            .padding(.horizontal, 10)
    }
}

#Preview {
    let preview2State = {
        let state = AppState()
        state.contacts = [
            Contact.housePreviewContact,
            Contact.senatePreviewContact1,
            Contact.senatePreviewContact2
        ]
        state.inboxRouter.selectedMessage = .whMessage
        return state
    }()
    let store2 = Store(state: preview2State, middlewares: [appMiddleware()])

    return Rectangle().sheet(isPresented: .constant(true)) {
        InboxDetail(message: .whMessage).environmentObject(store2)
            .padding(.top, 20)
            .padding(.horizontal, 10)
    }
}
