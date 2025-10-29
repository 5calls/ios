// Copyright 5calls. All rights reserved. See LICENSE for details.

import SwiftUI

struct ContactCircle: View {
    @EnvironmentObject var store: Store

    let issueID: Int?
    let contact: Contact

    init(contact: Contact, issueID: Int? = nil) {
        self.contact = contact
        self.issueID = issueID
    }

    var body: some View {
        if let issueID, store.state.issueCalledOn(issueID: issueID, contactID: contact.id) {
            Image(systemName: "checkmark.circle.fill")
                .resizable()
                .foregroundColor(.fivecallsGreen)
                .background {
                    Circle().foregroundColor(.white)
                }
        } else if contact.photoURL != nil {
            AsyncImage(url: contact.photoURL, content: { image in
                image.resizable()
                    .aspectRatio(contentMode: .fill)
                    .mask {
                        Circle()
                    }
            }) {
                placeholder
            }
        } else {
            placeholder
        }
    }

    var placeholder: some View {
        GeometryReader { geometry in
            ZStack {
                Circle()
                    .fill(Color(.systemGray5))

                Image(systemName: "star.fill")
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .foregroundColor(.fivecallsDarkBlue.opacity(0.6))
                    .frame(width: geometry.size.width * 0.7, height: geometry.size.height * 0.7)
            }
        }
    }
}

#Preview {
    let storeWithCompletedIssues: Store = {
        let state = AppState()
        state.issueCompletion[123] = ["1234-contact"]
        return Store(state: state)
    }()

    return HStack {
        ContactCircle(contact: Contact.housePreviewContact)
            .frame(width: 40, height: 40)
        ContactCircle(contact: Contact.housePreviewContact, issueID: 123)
            .frame(width: 40, height: 40)
            .environmentObject(storeWithCompletedIssues)
        ContactCircle(contact: Contact.senatePreviewContact1)
            .frame(width: 40)
        ContactCircle(contact: Contact.weirdShapeImagePreviewContact)
            .frame(width: 40, height: 40)
        Circle()
            .frame(width: 40, height: 40)
    }
}
