//
//  Issue.swift
//  FiveCalls
//
//  Created by Ben Scheirman on 1/31/17.
//  Copyright © 2017 5calls. All rights reserved.
//

import Foundation

struct Issue : Decodable, Hashable {
    let id: Int64
    let meta: String
    let name: String
    let slug: String
    let reason: String
    let script: String
    let categories: [Category]
    let active: Bool
    let outcomeModels: [Outcome]
    let contactType: String
    let contactAreas: [String]
    let createdAt: Date
}

extension Issue {
    var shareURL: URL {
        return URL(string: String(format: "https://shareimages.5calls.org/%d.png", self.id))!
    }
    
    var deepLinkURL: URL {
        guard
            let encodedSlug = slug.addingPercentEncoding(withAllowedCharacters: .urlPathAllowed),
            let url = URL(string: "fivecalls://issue/\(encodedSlug)") else {
            
            // if we can't form a valid URL, just open the main app
            return URL(string: "fivecalls://app")!
        }
        
        return url
    }
}

extension Issue: Equatable {
    static func == (lhs: Issue, rhs: Issue) -> Bool {
        return lhs.id == rhs.id
    }
}
