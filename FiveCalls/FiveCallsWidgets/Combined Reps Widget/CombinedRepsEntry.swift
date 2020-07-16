//
//  CombinedRepsEntry.swift
//  FiveCalls
//
//  Created by Ben Scheirman on 7/15/20.
//  Copyright © 2020 5calls. All rights reserved.
//

import Foundation
import WidgetKit

struct CombinedRepsEntry: TimelineEntry {
    let date: Date
    let reps: [Contact]
    let hasLocation: Bool
}
