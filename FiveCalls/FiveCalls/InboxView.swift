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
    
    var contacts: [Contact] {
        // TODO: restrict this to main reps only
        return store.state.contacts.filter({ $0.area == "US House" || $0.area == "US Senate" })
    }

    var body: some View {
        NavigationStack {
            VStack(alignment: .leading, spacing: 10) {
                MainHeader()
                    .padding(.horizontal, 10)
                    .padding(.bottom, 10)

                ScrollView {
                    Text("Your national Reps")
                        .font(.title2)
                        .fontWeight(.medium)
                        .padding(.horizontal, 10)
                    
                    VStack(spacing: 0) {
                        ForEach(contacts.numbered(), id: \.element.id) { contact in
                                ContactListItem(contact: contact.element, showComplete: false)
                                Divider()
                        }
                        HStack {
                            Text("View all Representatives")
                                .fontWeight(.medium)
                                .padding(.vertical, 15)
                                .padding(.leading, 10)
                            Spacer()
                        }
                    }.padding(.horizontal, 10)

                    Text("Recent votes")
                        .font(.title2)
                        .fontWeight(.medium)
                        .padding(.horizontal, 10)

                    ForEach(store.state.repMessages, id: \.id) { message in
                        Text(message.name)
                    }
                }

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
            }
        }.navigationBarHidden(true)
    }
}

#Preview {
    let previewState = {
        var state = AppState()
//        state.repMessages = [
//        ]
        state.contacts = [
            Contact.housePreviewContact,
            Contact.senatePreviewContact1,
            Contact.senatePreviewContact2
        ]
        return state
    }()

    let store = Store(state: previewState, middlewares: [appMiddleware()])

    return InboxView().environmentObject(store)
}
