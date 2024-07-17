//
//  InboxVote.swift
//  FiveCalls
//
//  Created by Nick O'Neill on 5/26/24.
//  Copyright © 2024 5calls. All rights reserved.
//

import SwiftUI

struct ContactInboxVote: View {
    var contact: Contact
    var message: InboxMessage
    
    var body: some View {
        HStack(alignment: .top) {
            ContactCircle(contact: contact)
                .frame(width: 20, height: 20)
                .padding(.top, 1)
            VStack(alignment: .leading) {
                Text(message.title)
                    .font(.body)
                    .fontWeight(.medium)
                Text(message.date.formatted(date: .abbreviated, time: .omitted))
                    .font(.footnote)
                    .foregroundStyle(.secondary)
            }
            Spacer()
            Image(systemName: "chevron.right")
                .foregroundColor(.secondary)
                .accessibilityHidden(true)
                .padding(.top, 10)
        }.frame(minHeight: 40)
    }
}

struct GenericInboxVote: View {
    var message: InboxMessage
    
    var body: some View {
        HStack(alignment: .top) {
            AsyncImage(url: message.imageURL, content: { image in
                image.resizable()
                    .aspectRatio(contentMode: .fill)
                    .mask {
                        Circle()
                    }
            }) {
                placeholder
            }
                .frame(width: 20, height: 20)
                .padding(.top, 1)
            VStack(alignment: .leading) {
                Text(message.title)
                    .font(.body)
                    .fontWeight(.medium)
                Text(message.date.formatted(date: .abbreviated, time: .omitted))
                    .font(.footnote)
                    .foregroundStyle(.secondary)
            }
            Spacer()
            Image(systemName: "chevron.right")
                .foregroundColor(.secondary)
                .accessibilityHidden(true)
                .padding(.top, 10)
        }.frame(minHeight: 40)

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
    VStack(spacing: 10) {
        ContactInboxVote(contact: .housePreviewContact, message: .houseMessage)
    //        .background(.gray)
        GenericInboxVote(message: .whMessage)
    }.padding(.horizontal, 10)
}
