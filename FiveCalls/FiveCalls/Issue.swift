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
    
    var shareURL: URL {
        return URL(string: String(format: "https://shareimages.5calls.org/%d.png",self.id))!
    }
}

extension Issue: Equatable {
    static func == (lhs: Issue, rhs: Issue) -> Bool {
        return lhs.id == rhs.id
    }
}
