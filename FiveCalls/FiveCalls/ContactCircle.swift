//
//  ContactCircle.swift
//  FiveCalls
//
//  Created by Nick O'Neill on 8/3/23.
//  Copyright © 2023 5calls. All rights reserved.
//

import SwiftUI

struct ContactCircle: View {
    let contact: Contact
    
    var body: some View {
        AsyncImage(url: contact.photoURL, content: { image in
            image.resizable()
                .aspectRatio(contentMode: .fit)
                .mask {
                    Circle()
                }
        }) {
            Circle()
                .fill(.red)
        }
    }
}

struct ContactCircle_Previews: PreviewProvider {
    static var previews: some View {
        ContactCircle(contact: Contact.housePreviewContact)
    }
}
