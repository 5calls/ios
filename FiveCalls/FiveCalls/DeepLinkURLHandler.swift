//
//  DeepLinkURLHandler.swift
//  FiveCalls
//
//  Created by Ben Scheirman on 7/15/20.
//  Copyright © 2020 5calls. All rights reserved.
//

import UIKit

// url resembles fivecalls://issue/123-issue-slug
struct DeepLinkURLHandler: AppURLHandler {
    func canHandle(url: URL) -> Bool {
        url.scheme == "fivecalls" && url.host == "issue"
    }
    
    func handle(url: URL, options: [UIApplication.OpenURLOptionsKey : Any]) -> Bool {
        // remove preceding slash character to get the slug
        let issuesSlug = url.path.replacingOccurrences(of: "/", with: "")
        Current.defaults.set(issuesSlug, forKey: UserDefaultsKey.selectIssuePath.rawValue)
        return true
    }
}
