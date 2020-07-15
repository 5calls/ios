//
//  IssuesEntry.swift
//  FiveCalls
//
//  Created by Ben Scheirman on 7/15/20.
//  Copyright © 2020 5calls. All rights reserved.
//

import Foundation
import WidgetKit

extension IssuesEntry {
    static var sample: IssuesEntry {
        IssuesEntry(
            date: Date(),
            issues: Issue.sampleIssues.enumerated().map { (offset, issue) in
                IssuesEntry.IssueSummary(id: issue.id, name: issue.name, hasCalled: offset == 0, url: URL(string: "fivecalls://issue/0")!)
            })
    }
}
