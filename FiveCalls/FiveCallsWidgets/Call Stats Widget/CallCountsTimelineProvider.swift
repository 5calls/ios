//
//  CallCountsTimelineProvider.swift
//  FiveCalls
//
//  Created by Ben Scheirman on 7/15/20.
//  Copyright © 2020 5calls. All rights reserved.
//

import Foundation
import WidgetKit

struct CallCountsTimelineProvider: TimelineProvider {
    
    func snapshot(with context: Context, completion: @escaping (CallCountsEntry) -> ()) {
        if context.isPreview {
            completion(.sample)
            return
        }
        
        let counts = loadCallCounts()
        completion(CallCountsEntry(date: Date(), callCounts: counts))
    }
    
    func timeline(with context: Context, completion: @escaping (Timeline<CallCountsEntry>) -> ()) {
        let counts = loadCallCounts()
        let tomorrow = Date().adding(1, .days)
        let entry = CallCountsEntry(date: Date(), callCounts: counts)
        let timeline = Timeline(entries: [entry], policy: .after(tomorrow))
        completion(timeline)
    }
    
    private func loadCallCounts() -> CallCountsEntry.CallCounts {
        let contactLogs = Current.contactLogs.load()
        let lastMonthDate = Date().subtracting(30, .days)
        return CallCountsEntry.CallCounts(
            total: contactLogs.all.count,
            lastMonth: contactLogs.since(date: lastMonthDate).count
        )
    }
}

extension CallCountsEntry {
    static var sample: CallCountsEntry {
        CallCountsEntry(date: Date(), callCounts: .init(total: 45, lastMonth: 12))
    }
}
