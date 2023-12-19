//
//  PreviewContacts.swift
//  FiveCalls
//
//  Created by Nick O'Neill on 8/2/23.
//  Copyright © 2023 5calls. All rights reserved.
//

import Foundation

extension Contact {
    static let housePreviewContact = Contact(id: "1234", area: "US House", name: "Housy McHouseface", party: "Democrat", phone: "415-555-1212", photoURL: URL(string: "https://images.5calls.org/senate/256/S001227.jpg")!, fieldOffices: [AreaOffice(city: "San Francisco", phone: "415-513-1111"),AreaOffice(city: "San Diego", phone: "415-513-2222")])
    static let senatePreviewContact1 = Contact(id: "12345", area: "US Senate", name: "Senatey McDefinitelyOld", party: "Democrat", phone: "415-555-1212")
    static let senatePreviewContact2 = Contact(id: "12346", area: "US Senate", name: "Senatey McShouldHaveRetired", party: "Democrat", phone: "415-555-1212")
    static let weirdShapeImagePreviewContact = Contact(id: "12347", area: "US Senate", name: "Senatey McShouldHaveRetired", party: "Democrat", phone: "415-555-1212", photoURL: URL(string: "https://www.assembly.ca.gov/sites/assembly.ca.gov/files/memberphotos/ad17_haney.jpg")!)
    static let unknownMayorPreviewContact = Contact(id: "1234", area: "Mayor", name: "Mayor McMayorface", party: "Democrat", phone: "415-555-1212", photoURL: URL(string: "https://images.5calls.org/senate/256/S001227.jpg")!, fieldOffices: [AreaOffice(city: "San Francisco", phone: "415-513-1111"),AreaOffice(city: "San Diego", phone: "415-513-2222")])
}
