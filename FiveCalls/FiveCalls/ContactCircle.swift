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
        if contact.photoURL != nil {
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
        Image(uiImage: defaultImage(forContact: contact))
            .resizable()
            .mask {
                Circle()
            }
    }
}

struct ContactCircle_Previews: PreviewProvider {
    static var previews: some View {
        HStack {
            ContactCircle(contact: Contact.housePreviewContact)
                .frame(width: 40, height: 40)
            ContactCircle(contact: Contact.senatePreviewContact1)
                .frame(width: 40)
            ContactCircle(contact: Contact.weirdShapeImagePreviewContact)
                .frame(width: 40, height: 40)
            Circle()
                .frame(width: 40, height: 40)
        }
    }
}
