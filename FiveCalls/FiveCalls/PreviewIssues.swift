//
//  PreviewIssues.swift
//  FiveCalls
//
//  Created by Nick O'Neill on 6/28/23.
//  Copyright © 2023 5calls. All rights reserved.
//

import Foundation

extension Issue {
    static let basicPreviewIssue = Issue(id: 12345, meta: "", name: "Support the Act", slug: "support-act-slug", reason: "reason text", script: "script text", categories: [], active: true, outcomeModels: [Outcome(label: "Contacted", status: "contact"), Outcome(label: "Voicemail", status: "voicemail")], contactType: "reps", contactAreas: ["US House", "US Senate"], createdAt: Date(timeIntervalSince1970: 1688015904))
    static let multilinePreviewIssue = Issue(id: 12346, meta: "", name: "Support the Act whose name is quite long", slug: "support-act-slug2", reason: "reason text", script: "script text", categories: [], active: true, outcomeModels: [Outcome(label: "Contacted", status: "contact"), Outcome(label: "Voicemail", status: "voicemail")], contactType: "reps", contactAreas: ["US House", "US Senate"], createdAt: Date(timeIntervalSince1970: 1688015904))
}
