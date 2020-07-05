//
//  World.swift
//  FiveCalls
//
//  Created by Ben Scheirman on 7/5/20.
//  Copyright © 2020 5calls. All rights reserved.
//

import Foundation

/// An app-wide container for dependencies.
/// Inspired by https://www.pointfree.co/blog/posts/21-how-to-control-the-world
struct World {
    let analytics: Analytics
    let defaults: UserDefaults
    let contactLogs: ContactLogsAccess.Type
}
