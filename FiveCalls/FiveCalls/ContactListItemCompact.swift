//
//  ContactListItemCompact.swift
//  FiveCalls
//
//  Created by Nick O'Neill on 12/3/23.
//  Copyright © 2023 5calls. All rights reserved.
//

import SwiftUI

struct ContactListItemCompact: View {
    let contact: Contact
    let issueCompletions: [String]
    
    var body: some View {
        HStack {
            ContactCircle(contact: contact)
                .frame(width: 25, height: 25)
                .padding(.vertical, 4)
                .padding(.trailing, 4)
                .overlay {
                    if latestOutcomeForContact(contactID: contact.id, issueCompletions: issueCompletions) != "Skip" {
                        Image(systemName: "checkmark.circle.fill")
                            .frame(width: 10, height: 10)
                            .foregroundColor(.fivecallsGreen)
                            .background {
                                Circle().foregroundColor(.white)
                            }
                            .offset(x: 7, y: 7)
                    }
                }
            VStack(alignment: .leading) {
                Text(contact.name)
                    .fontWeight(.semibold)
                Text(latestOutcomeForContact(contactID: contact.id, issueCompletions: issueCompletions))
                    .font(.caption)
            }
        }
    }
    
    func latestOutcomeForContact(contactID: String, issueCompletions: [String]) -> String {
        if let contactOutcome = issueCompletions.last(where: { $0.split(separator: "-")[0] == contactID }) {
            if contactOutcome.split(separator: "-").count > 1 {
                return ContactLog.localizedOutcomeForStatus(status: String(contactOutcome.split(separator: "-")[1]))
            }
        }
        
        return R.string.localizable.outcomesSkip()
    }

}

#Preview {
    VStack {
        ContactListItemCompact(contact: .housePreviewContact, issueCompletions: ["\(Contact.housePreviewContact.id)-vm"])
        ContactListItemCompact(contact: .housePreviewContact, issueCompletions: ["B0001234-vm"])
    }
}
