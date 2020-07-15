//
//  CallCountsEntry.swift
//  FiveCalls
//
//  Created by Ben Scheirman on 7/15/20.
//  Copyright © 2020 5calls. All rights reserved.
//

import Foundation
import WidgetKit

struct CallCountsEntry: TimelineEntry {
    let date: Date    
    let callCounts: CallCounts
    
    struct CallCounts {
        let total: Int
        let lastMonth: Int
    }
}
