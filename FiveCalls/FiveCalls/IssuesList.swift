//
//  IssuesList.swift
//  FiveCalls
//
//  Created by Ben Scheirman on 1/31/17.
//  Copyright © 2017 5calls. All rights reserved.
//

import Foundation

struct IssuesList {
    let splitDistrict: Bool
    let normalizedLocation: String
    var issues: [Issue]
}

extension IssuesList : JSONSerializable {
    init?(dictionary: JSONDictionary) {
        guard let splitDistrict = dictionary["splitDistrict"] as? Bool,
            let normalizedLocation = dictionary["normalizedLocation"] as? String,
            let issuesJSON = dictionary["issues"] as? [JSONDictionary] else {
                print("Unable to parse JSON as IssuesResponse: \(dictionary)")
                return nil
        }
        
        let issues = issuesJSON.flatMap(Issue.init)
        self.init(splitDistrict: splitDistrict, normalizedLocation: normalizedLocation, issues: issues)
    }
}
