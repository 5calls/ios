// Copyright 5calls. All rights reserved. See LICENSE for details.

import Foundation

struct InboxMessage: Decodable, Identifiable, Equatable {
    let id: Int

    // the title of the message, usually the rep's name and what they voted for or against
    let title: String
    // a slightly longer description of what the legislation does
    let description: String
    // the date and time for this message, typically a vote date or a message date, used for ordering
    let date: Date
    // if this is a vote from a rep that we get back from the reps endpoint, the ID will be the same here,
    // usually a bioguide id for House and Senate. nil when we pass an override rep image url and name
    let repID: String?
    // an override message image url that we can pass for non-reps endpoint votes
    let imageURL: URL?
    // an override contact name for non-standard rep
    let contactName: String?
    // an override contact title for non-standard rep
    let contactTitle: String?
    // an indication that this was a vote for or against the position taken by 5 Calls, for styling
    let positive: Bool
    // an optional link where we can direct the user for learning more
    let moreInfoURL: URL?
}
