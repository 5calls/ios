//
//  ContactListItem.swift
//  FiveCalls
//
//  Created by Nick O'Neill on 8/28/23.
//  Copyright © 2023 5calls. All rights reserved.
//

import SwiftUI

struct ContactListItem: View {
    let issue: Issue?
    let contact: Contact
    let showComplete: Bool
    
    init(contact: Contact, issue: Issue? = nil, showComplete: Bool = false) {
        self.contact = contact
        self.issue = issue
        self.showComplete = showComplete
    }

    var body: some View {
        HStack {
            ContactCircle(contact: contact)
                .frame(width: 45, height: 45)
                .padding(.vertical, 8)
                .padding(.leading, 12)
                .overlay {
                    if showComplete {
                        Image(systemName: "checkmark.circle.fill")
                            .frame(width: 20, height: 20)
                            .foregroundColor(.fivecallsGreen)
                            .background {
                                Circle().foregroundColor(.white)
                            }
                            .offset(x: 20, y: 15)
                    }
                }
            VStack(alignment: .leading) {
                Text(contact.name)
                    .font(.title3)
                    .fontWeight(.medium)
                Text(contact.officeDescription())
                    .font(.subheadline)
                
            }
            Spacer()
        }
    }
}

#Preview {
    VStack {
        ContactListItem(contact: .housePreviewContact)
            .background {
                RoundedRectangle(cornerRadius: 10)
                    .foregroundColor(Color(red: 0.85, green: 0.85, blue: 0.85))
            }
        ContactListItem(contact: .housePreviewContact, showComplete: true)
            .background {
                RoundedRectangle(cornerRadius: 10)
                    .foregroundColor(Color(red: 0.85, green: 0.85, blue: 0.85))
            }
    }.padding(.horizontal)
}
