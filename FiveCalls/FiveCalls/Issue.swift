//
//  Issue.swift
//  FiveCalls
//
//  Created by Ben Scheirman on 1/31/17.
//  Copyright © 2017 5calls. All rights reserved.
//

import Foundation
import Rswift

struct Issue : Decodable {
    let id: Int64
    let name: String
    let slug: String
    let reason: String
    let script: String
//    let category: [Category]
    let active: Bool
//    let outcomes: [Outcome]
    let contactType: String
    let contactAreas: [String]
    let createdAt: Date
    
    static var style: String {        
        if let bytes = try? Data(resource: R.file.issuesStyleCss)  {
            return String(decoding: bytes, as: UTF8.self)
        }
        return ""
    }
    
    // REMOVE ME
    var category: Category? {
        return nil
    }
    
    var outcomes: [Outcome] {
        return []
    }
    
    var order: Int {
        return 0
    }
}
