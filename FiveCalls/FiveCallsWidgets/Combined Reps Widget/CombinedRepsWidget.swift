//
//  CombinedRepsWidget.swift
//  FiveCallsWidgetsExtension
//
//  Created by Ben Scheirman on 7/15/20.
//  Copyright © 2020 5calls. All rights reserved.
//

import SwiftUI
import WidgetKit

struct CombinedRepsWidget: Widget {
    let kind = "CombinedReps"
    
    var body: some WidgetConfiguration {
        StaticConfiguration(kind: kind, provider: CombinedRepsTimelineProvider(), placeholder: CombinedRepsPlaceHolder()) { entry in
                CombinedRepsEntryView(entry: entry)
        }
        .supportedFamilies([.systemMedium, .systemLarge])
        .configurationDisplayName("Your Reps")
        .description("Shows your reps and some call stats")
    }
}
