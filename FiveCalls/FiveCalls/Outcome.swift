//
//  Outcome.swift
//  FiveCalls
//
//  Created by Nick O'Neill on 9/17/17.
//  Copyright © 2017 5calls. All rights reserved.
//

import Foundation

// Outcomes are the buttons that a user sees at the end of a call
// we use the label field to display the localized text for the button
// and the status field to add to the impact data
struct Outcome : Decodable {
    let label: String
    let status: String
}

extension Outcome: Equatable, Hashable { }
