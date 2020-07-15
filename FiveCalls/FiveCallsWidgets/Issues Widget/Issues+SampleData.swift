//
//  Issues+SampleData.swift
//  FiveCalls
//
//  Created by Ben Scheirman on 7/15/20.
//  Copyright © 2020 5calls. All rights reserved.
//

import Foundation

extension Issue {
    static var sampleIssues: [Issue] {
        [
            Issue(id: 0, meta: "sample1", name: "Support the ratification of the Ben McOniell Decree, which grants new hardware to developers of cool projects.", slug: "sample1", reason: "", script: "", categories: [], active: true, outcomeModels: [], contactType: "", contactAreas: [], createdAt: Date()),
            Issue(id: 1, meta: "sample2", name: "Stop the use of ketchup on eggs. C'mon, it's just gross.", slug: "sample2", reason: "", script: "", categories: [], active: true, outcomeModels: [], contactType: "", contactAreas: [], createdAt: Date()),
            
        ]
    }
}
