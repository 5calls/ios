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
    let showComplete: Bool
    let contactNote: String
    let listType: ContactListType

    @Environment(\.dynamicTypeSize) private var dynamicTypeSize

    func usingRegularFonts() -> Bool {
        dynamicTypeSize < DynamicTypeSize.accessibility3
    }

    init(contact: Contact, showComplete: Bool = false, contactNote: String = "", listType: ContactListType = .standard) {
        self.contact = contact
        self.showComplete = showComplete
        self.contactNote = contactNote
        self.listType = listType
    }

    var body: some View {
        HStack {
            ContactCircle(contact: contact)
                .frame(width: contactCircleFrameSize, height: contactCircleFrameSize)
                .padding(.vertical, contactCircleVerticalPadding)
                .padding(.leading, contactCircleLeadingPadding)
                .padding(.trailing, contactCircleTrailingPadding)
                .overlay {
                    if showComplete {
                        Image(systemName: "checkmark.circle.fill")
                            .resizable()
                            .frame(width: completedCircleFrameSize, height: completedCircleFrameSize)
                            .foregroundColor(.fivecallsGreen)
                            .background {
                                Circle().foregroundColor(.white)
                            }
                            .offset(x: completedCircleOffset.x, y: completedCircleOffset.y)
                            .accessibilityHidden(true)
                    }
                }
            VStack(alignment: .leading) {
                Text(contact.name)
                    .font(contactFont)
                    .fontWeight(.semibold)
                    .foregroundStyle(Color.primary)
                Text(contactDetailText)
                    .font(.footnote)
                    .foregroundStyle(Color.primary)

            }
            .accessibilityElement(children: .combine)
            Spacer()
        }
        .padding(2)
        .accessibilityElement(children: .combine)
    }

    enum ContactListType {
        case standard
        case compact
    }

    var contactCircleFrameSize: CGFloat {
        var frameSize: CGFloat
        switch listType {
        case .standard:
            frameSize = 45
        case .compact:
            frameSize = 25
        }

        if !usingRegularFonts() {
            frameSize *= 1.5
        }

        return frameSize
    }

    var contactCircleVerticalPadding: CGFloat {
        switch listType {
        case .standard:
            8
        case .compact:
            4
        }
    }

    var contactCircleLeadingPadding: CGFloat {
        switch listType {
        case .standard:
            8
        case .compact:
            0
        }
    }

    var contactCircleTrailingPadding: CGFloat {
        switch listType {
        case .standard:
            0
        case .compact:
            4
        }
    }

    var contactFont: Font {
        switch listType {
        case .standard:
            Font.title3
        case .compact:
            Font.body
        }
    }

    var contactDetailText: String {
        switch listType {
        case .standard:
            contact.officeDescription()
        case .compact:
            contactNote
        }
    }

    var completedCircleFrameSize: CGFloat {
        var frameSize: CGFloat
        switch listType {
        case .standard:
            frameSize = 20
        case .compact:
            frameSize = 10
        }

        if !usingRegularFonts() {
            frameSize *= 1.5
        }

        return frameSize
    }

    var completedCircleOffset: (x: CGFloat, y: CGFloat) {
        var offset: (x: CGFloat, y: CGFloat)
        switch listType {
        case .standard:
            offset = (20, 15)
        case .compact:
            offset = (7, 7)
        }

        if !usingRegularFonts() {
            offset.x *= 1.5
            offset.y *= 1.5
        }

        return offset
    }
}

#Preview {
    VStack {
        ContactListItem(contact: .housePreviewContact)
            .background {
                RoundedRectangle(cornerRadius: 10)
                    .foregroundColor(Color.fivecallsLightBG)
            }
        ContactListItem(contact: .housePreviewContact, showComplete: true)
        ContactListItem(contact: .housePreviewContact, showComplete: true, contactNote: "voicemail", listType: .compact)
        ContactListItem(contact: .housePreviewContact, showComplete: true, contactNote: "vm", listType: .compact)
        ContactListItem(contact: .housePreviewContact, showComplete: false, contactNote: "skip", listType: .compact)
    }
    
//    .padding(.horizontal)
}
