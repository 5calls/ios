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
struct Outcome {
    let label: String
    let status: String
}

extension Outcome : JSONSerializable {
    init?(dictionary: JSONDictionary) {
        guard let label = dictionary["label"] as? String,
            let status = dictionary["status"] as? String
        else {
            print("Unable to parse JSON as Outcome: \(dictionary)")
            return nil
        }

        self.init(label: label, status: status)
    }
}
