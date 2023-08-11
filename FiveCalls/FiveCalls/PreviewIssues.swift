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

    Despite information that has been circulating online, [the bill would not explicitly criminalize using a VPN](https://www.washingtonexaminer.com/policy/technology/americans-tiktok-bills-effects-on-vpns-privacy) but does use overly broad language that gives the President the ability to ban any app deemed a “security risk.” This power [seems ripe for abuse by a President](https://www.aclu.org/press-releases/aclu-raises-concerns-about-senate-bill-aimed-at-banning-tiktok) who seeks to use any available method to punish their political opponents, a situation with which we are unfortunately very familiar.

    Furthermore, the expected result of this legislation would be the executive branch banning TikTok over fears that American’s data is being harvested by the Chinese government. In reality, even though the American company that controls the US version of TikTok [has seen data breaches in the past by China](https://techpolicy.press/transcript-tiktok-ceo-testifies-to-congress/), the data that is available is [akin to products that brokers regularly buy and sell](https://www.theverge.com/23653141/tiktok-ban-bytedance-congress-hearing-first-amendment-open-internet). Banning the social media app would do little to prevent China from getting access to this information on Americans.

    Demand your Senators oppose the RESTRICT Act to ensure a free and fair internet.
    """
    
    static let basicPreviewIssue = Issue(id: 12345, meta: "", name: "Support the Act", slug: "support-act-slug", reason: Issue.issueReason, script: "script text", categories: [], active: true, outcomeModels: [Outcome(label: "Contacted", status: "contact"), Outcome(label: "Voicemail", status: "voicemail")], contactType: "reps", contactAreas: ["US House", "US Senate"], createdAt: Date(timeIntervalSince1970: 1688015904))
    static let multilinePreviewIssue = Issue(id: 12346, meta: "", name: "Support the Act whose name is quite long", slug: "support-act-slug2", reason: Issue.issueReason, script: "script text", categories: [], active: true, outcomeModels: [Outcome(label: "Contacted", status: "contact"), Outcome(label: "Voicemail", status: "voicemail")], contactType: "reps", contactAreas: ["US House", "US Senate"], createdAt: Date(timeIntervalSince1970: 1688015904))
}
