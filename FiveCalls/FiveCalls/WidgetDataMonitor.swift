//
//  WidgetSupport.swift
//  FiveCalls
//
//  Created by Ben Scheirman on 7/5/20.
//  Copyright © 2020 5calls. All rights reserved.
//

import Foundation
import WidgetKit

/// Listens for changes to data that affect the widget and requests a reload
/// of the Widget timeline
class WidgetDataMonitor {
    private var observers: [NSObjectProtocol] = []
    
    init() {
        observers.append(
            NotificationCenter.default.addObserver(forName: .locationChanged, object: nil, queue: nil) { _ in
                WidgetCenter.shared.reloadAllTimelines()
            }
        )
        
        observers.append(
            NotificationCenter.default.addObserver(forName: .callMade, object: nil, queue: nil, using: { notification in
                WidgetCenter.shared.reloadAllTimelines()
            })
        )
    }
}
