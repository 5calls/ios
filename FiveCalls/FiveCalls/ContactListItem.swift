//
//  ContactListItem.swift
//  FiveCalls
//
//  Created by Nick O'Neill on 8/28/23.
//  Copyright © 2023 5calls. All rights reserved.
//

import SwiftUI

struct ContactListItem: View {
    let contact: Contact

    var body: some View {
        HStack {
            ContactCircle(contact: contact)
                .frame(width: 45, height: 45)
                .padding(.vertical, 8)
                .padding(.leading, 12)
            VStack(alignment: .leading) {
                Text(contact.name)
                    .font(.title3)
                    .fontWeight(.medium)
                Text("US House Rep. District 13")
                    .font(.subheadline)
                
            }
            Spacer()
        }
    }
}

struct ContactListItem_Previews: PreviewProvider {
    static var previews: some View {
        ContactListItem(contact: .housePreviewContact)
            .background {
                RoundedRectangle(cornerRadius: 10)
                    .foregroundColor(Color(red: 0.85, green: 0.85, blue: 0.85))
            }
            .padding()
    }
}
