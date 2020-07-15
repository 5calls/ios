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
            WidgetBackground()
            
            VStack(alignment: .leading) {
                ForEach(entry.topIssues, id: \.id) { issue in
                    IssueRow(issue: issue)
                        IssueRow(issue: issue)
                }
                if entry.topIssues.isEmpty {
                    Text("No issues were loaded...")
                        .opacity(0.7)
                }
            }
            .padding(.horizontal)
            .foregroundColor(.white)
        }
    }
}

struct IssueRow: View {
    
    let issue: FiveCallsEntry.IssueSummary
    
    var body: some View {
        HStack(alignment: .firstTextBaseline, spacing: 10) {
            Image(systemName: issue.hasCalled ? "checkmark.circle.fill" : "circle")
                .blendMode(.overlay)
            
            Text(issue.name)
                .strikethrough(issue.hasCalled)
                .lineLimit(nil)
                .layoutPriority(1)
        }
    }
}

struct IssuesPlaceholder: View {
    var body: some View {
        WidgetBackground()
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
