//
//  PreviewIssues.swift
//  FiveCalls
//
//  Created by Nick O'Neill on 6/28/23.
//  Copyright © 2023 5calls. All rights reserved.
//

import Foundation

extension Issue {
    static let issueReason = """
    Congress is currently considering [the RESTRICT Act](https://www.warner.senate.gov/public/index.cfm/2023/3/senators-introduce-bipartisan-bill-to-tackle-national-security-threats-from-foreign-tech), [(S.686)](https://www.congress.gov/bill/118th-congress/senate-bill/686) a bill that purports to protect Americans by restricting access to apps and websites that could pose a threat to national security.

    Demand your Senators oppose the RESTRICT Act to ensure a free and fair internet.
    """
    
    static let issueScript = """
    Hi, my name is **[NAME]** and I’m a constituent from [CITY, ZIP].

    I'm calling to demand [REP/SEN NAME] oppose S. 686, the RESTRICT Act. The legislation would do nothing to protect Americans and would give potential future Presidents more tools to abuse their power.

    Thank you for your time and consideration.

    **IF LEAVING VOICEMAIL:** Please leave your full street address to ensure your call is tallied.
    """
    
    static let basicPreviewIssue = Issue(id: 12345, meta: "", name: "Support the Act", slug: "support-act-slug", reason: Issue.issueReason, script: Issue.issueScript, categories: [], active: true, outcomeModels: [Outcome(label: "Contacted", status: "contact"), Outcome(label: "Voicemail", status: "voicemail")], contactType: "reps", contactAreas: ["US House", "US Senate"], createdAt: Date(timeIntervalSince1970: 1688015904))
    static let multilinePreviewIssue = Issue(id: 12346, meta: "", name: "Support the Act whose name is quite long", slug: "support-act-slug2", reason: Issue.issueReason, script: Issue.issueScript, categories: [], active: true, outcomeModels: [Outcome(label: "Contacted", status: "contact"), Outcome(label: "Voicemail", status: "voicemail")], contactType: "reps", contactAreas: ["US House", "US Senate"], createdAt: Date(timeIntervalSince1970: 1688015904))
}
