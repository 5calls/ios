//
//  SmallCallsWidget.swift
//  FiveCalls
//
//  Created by Ben Scheirman on 7/7/20.
//  Copyright © 2020 5calls. All rights reserved.
//

import SwiftUI
import WidgetKit

struct CallsPlaceholderView: View {
    var body: some View {
        ZStack {
            WidgetBackground()
            
            VStack {
                StatLine(stat: "--", label: "lifetime calls")
                StatLine(stat: "--", label: "last 30 days")
            }
            .padding(.leading)
        }
    }
}

struct CallsEntryView: View {
    let entry: FiveCallsEntry
    
    var body: some View {
        GeometryReader { proxy in
            ZStack {
                WidgetBackground()
                    
                VStack(spacing: 8) {
                    StatLine(stat: String(entry.callCounts.total), label: "all time calls")
                    
                    StatLine(stat: String(entry.callCounts.lastMonth), label: "last 30 days")
                    
                }
                .padding(.leading)
            }
        }
    }
}

struct StatLine: View {
    let stat: String
    let label: String
    
    var body: some View {
        VStack(alignment: .leading) {
            Text(stat)
                .font(Font.largeTitle.bold())
            
            HStack {
                Text(label)
                    .font(.subheadline)
                    .opacity(0.7)
                    .blendMode(.overlay)
                
                Spacer()
            }
        }
        .foregroundColor(.white)
    }
}


struct SmallCallsWidget: Widget {
    let kind = "SmallCallsWidget"
    
    var body: some WidgetConfiguration {
        StaticConfiguration(kind: kind, provider: Provider(),
                            placeholder: CallsPlaceholderView(),
                            content: { entry in
                                CallsEntryView(entry: entry)
                            })
            .supportedFamilies([.systemSmall])
            .description("Shows the lifetime and past 30 days call counts")
            .configurationDisplayName("Five Calls")
    }
}

struct SmallCallsWidget_Previews: PreviewProvider {
    static var previews: some View {
        
        Group {
            CallsPlaceholderView()
                .previewContext(WidgetPreviewContext(family: .systemSmall))
                .previewDisplayName("Placeholder")
            
            CallsEntryView(entry: .sample)
                .previewContext(WidgetPreviewContext(family: .systemSmall))
                .previewDisplayName("Live Widget")
            
            CallsEntryView(entry: .sample)
                .environment(\.colorScheme, .dark)
                .previewDisplayName("Dark mode")
                .previewContext(WidgetPreviewContext(family: .systemSmall))
      
        }
    }
}
