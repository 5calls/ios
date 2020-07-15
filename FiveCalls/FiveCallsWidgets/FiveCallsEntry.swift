//
//  FiveCallsEntry.swift
//  FiveCalls
//
//  Created by Ben Scheirman on 7/7/20.
//  Copyright © 2020 5calls. All rights reserved.
//

import Foundation
import WidgetKit

struct FiveCallsEntry: TimelineEntry {
    let date: Date
    let callCounts: CallCounts
    let topIssues: [IssueSummary]
    let reps: [String]
    
    struct CallCounts {
        let total: Int
        let lastMonth: Int
    }
    
    struct IssueSummary {
        let id: Int64
        let name: String
        let hasCalled: Bool
        let url: URL
    }
}

extension FiveCallsEntry {
    static var sample: FiveCallsEntry {
        FiveCallsEntry(date: Date(), callCounts: .init(total: 87, lastMonth: 6),
                       topIssues: Issue.sampleIssues.enumerated().map { (offset, issue) in
                        IssueSummary(id: issue.id, name: issue.name, hasCalled: offset == 0, url: URL(string: "fivecalls://issue/0")!)
                       },
                       reps: [])
    }
}

extension Issue {
    
    static var sampleIssues: [Issue] {
        [
            Issue(id: 0, meta: "sample1", name: "Support the ratification of the Ben McOniell Decree, which grants new hardware to developers of cool projects.", slug: "sample1", reason: "", script: "", categories: [], active: true, outcomeModels: [], contactType: "", contactAreas: [], createdAt: Date()),
            Issue(id: 1, meta: "sample2", name: "Stop the use of ketchup on eggs. C'mon, it's just gross.", slug: "sample2", reason: "", script: "", categories: [], active: true, outcomeModels: [], contactType: "", contactAreas: [], createdAt: Date()),
            
        ]
    }
}

