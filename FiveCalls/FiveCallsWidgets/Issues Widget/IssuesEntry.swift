//
//  IssuesEntry.swift
//  FiveCalls
//
//  Created by Ben Scheirman on 7/15/20.
//  Copyright © 2020 5calls. All rights reserved.
//

import Foundation
import WidgetKit

struct IssuesEntry: TimelineEntry {
    let date: Date
    let issues: [IssueSummary]
    
    struct IssueSummary {
        let id: Int64
        let name: String
        let hasCalled: Bool
        let url: URL
    }
}
