//
//  PreviewContacts.swift
//  FiveCalls
//
//  Created by Nick O'Neill on 8/2/23.
//  Copyright © 2023 5calls. All rights reserved.
//

import Foundation

extension Contact {
    static let housePreviewContact = Contact(id: "1234", area: "US House", name: "Housy McHouseface", party: "Democrat", phone: "4155551212", photoURL: URL(string: "https://images.5calls.org/senate/256/S001227.jpg")!)
    static let senatePreviewContact1 = Contact(id: "12345", area: "US Senate", name: "Senatey McDefinitelyOld", party: "Democrat", phone: "4155551212")
    static let senatePreviewContact2 = Contact(id: "12346", area: "US Senate", name: "Senatey McShouldHaveRetired", party: "Democrat", phone: "4155551212")
}
