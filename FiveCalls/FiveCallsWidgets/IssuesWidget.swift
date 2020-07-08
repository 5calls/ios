//
//  IssuesWidget.swift
//  FiveCalls
//
//  Created by Ben Scheirman on 7/7/20.
//  Copyright © 2020 5calls. All rights reserved.
//

import SwiftUI
import WidgetKit

struct IssuesEntryView: View {
    
    let entry: FiveCallsEntry
    
    var body: some View {
        ZStack {
            BackgroundGradient()
            
            VStack(alignment: .leading) {
                ForEach(entry.topIssues, id: \.id) { issue in
                    IssueRow(issue: issue)
                }
            }
            .padding()
            .foregroundColor(.white)
        }
    }
}

struct IssueRow: View {
    
    let issue: FiveCallsEntry.IssueSummary
    
    var body: some View {
        HStack(alignment: .center, spacing: 10) {
            Image(systemName: issue.hasCalled ? "checkmark.circle.fill" : "circle")
                .blendMode(.overlay)
            
            Text(issue.name)
                .strikethrough(issue.hasCalled)
                .lineLimit(issue.hasCalled ? nil : 2)
        }
    }
}

struct IssuesPlaceholder: View {
    var body: some View {
        BackgroundGradient()
    }
}

struct IssuesWidget: Widget {
    let kind = "IssuesWidget"
    
    var body: some WidgetConfiguration {
        StaticConfiguration(kind: kind,
                            provider: Provider(),
                            placeholder: IssuesPlaceholder()) { entry in
            IssuesEntryView(entry: entry)
        }
        .supportedFamilies([.systemMedium, .systemLarge])
        .description("Shows a few recent issues")
        .configurationDisplayName("Issues")
    }
}

struct IssuesWidget_Previews: PreviewProvider {
    static var previews: some View {
        Group {
//            IssuesPlaceholder()
//                .previewContext(WidgetPreviewContext(family: .systemMedium))
//                .previewDisplayName("Preview (Med)")
//
//            IssuesPlaceholder()
//                .previewContext(WidgetPreviewContext(family: .systemLarge))
//                .previewDisplayName("Preview (Lg)")
            
            IssuesEntryView(entry: .sample)
                .previewContext(WidgetPreviewContext(family: .systemMedium))
                .previewDisplayName("Issues (Med)")
            
        }
    }
}
