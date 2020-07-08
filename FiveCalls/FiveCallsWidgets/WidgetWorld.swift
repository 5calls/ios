//
//  WidgetWorld.swift
//  FiveCalls
//
//  Created by Ben Scheirman on 7/5/20.
//  Copyright © 2020 5calls. All rights reserved.
//

// Initialize a set of dependencies that is appropriate for use in the Widget.
var Current = World(
    analytics: EmptyAnalytics(),
    defaults: .fiveCalls,
    contactLogs: ContactLogsLoader.self
    )
