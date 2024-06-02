//
//  PreviewMessages.swift
//  FiveCalls
//
//  Created by Nick O'Neill on 5/16/24.
//  Copyright © 2024 5calls. All rights reserved.
//

import Foundation

extension InboxMessage {
    static let houseMessage = InboxMessage(id: 1, title: "Rep McHouseface voted to preserve net neutrality.", description: "H.R 1111 was proposed as a way to preserve net neutrality by requiring the FCC tell all ISPs that they should treat all internet content equally and not provide degraded or preferred service for any particular use or website.", date: Date().addingTimeInterval(-3600), repID: "1234", imageURL: nil, positive: true, moreInfoURL: nil)
    static let senate1Message = InboxMessage(id: 2, title: "Sen. McOldface voted against net neutrality.", description: "H.R 1111 was proposed as a way to preserve net neutrality by requiring the FCC tell all ISPs that they should treat all internet content equally and not provide degraded or preferred service for any particular use or website.", date: Date().addingTimeInterval(-3600), repID: "12345", imageURL: nil, positive: false, moreInfoURL: nil)
    static let senate2Message = InboxMessage(id: 3, title: "Sen. McShouldHaveRetired voted against net neutrality.", description: "H.R 1111 was proposed as a way to preserve net neutrality by requiring the FCC tell all ISPs that they should treat all internet content equally and not provide degraded or preferred service for any particular use or website.", date: Date().addingTimeInterval(-3600), repID: "12346", imageURL: nil, positive: false, moreInfoURL: nil)
    static let whMessage = InboxMessage(id: 4, title: "President Joe Biden signed net neutrality into law", description: "H.R 1111 was proposed as a way to preserve net neutrality by requiring the FCC tell all ISPs that they should treat all internet content equally and not provide degraded or preferred service for any particular use or website.", date: Date().addingTimeInterval(-3600), repID: nil, imageURL: URL(string: "https://images.5calls.org/senate/256/S001227.jpg")!, positive: true, moreInfoURL: nil)
}
