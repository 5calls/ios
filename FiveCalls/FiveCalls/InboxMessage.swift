//
//  InboxMessage.swift
//  FiveCalls
//
//  Created by Nick O'Neill on 3/16/24.
//  Copyright © 2024 5calls. All rights reserved.
//

import Foundation

struct InboxMessage: Decodable, Identifiable {
    let id: Int
    
    // the title of the message, usually the rep's name and what they voted for or against
    let title: String
    // a slightly longer description of what the legislation does
    let description: String
    // the date and time this legislation was voted on, used for ordering
    let voteDate: Date
    // if this is a vote from a rep that we get back from the reps endpoint, the ID will be the same here,
    // usually a bioguide id for House and Senate. nil when we pass an override rep image url and name
    let repID: String?
    // an override rep image url that we can pass for non-reps endpoint votes
    let repImageURL: URL?
    // an indication that this was a vote for or against the position taken by 5 Calls, for styling
    let positive: Bool
}
