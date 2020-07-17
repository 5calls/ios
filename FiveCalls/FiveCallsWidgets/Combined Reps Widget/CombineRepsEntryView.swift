//
//  CombineRepsEntryView.swift
//  FiveCalls
//
//  Created by Ben Scheirman on 7/15/20.
//  Copyright © 2020 5calls. All rights reserved.
//

import SwiftUI
import WidgetKit
import Combine

struct CombinedRepsPlaceHolder: View {
    @Environment(\.widgetFamily) var family
    
    var body: some View {
        ZStack {
            WidgetBackground()
            VStack {
                RepView(rep: .init(name: "---", party: "", area: "", photo: nil))
                RepView(rep: .init(name: "---", party: "", area: "", photo: nil))
            }
        }
    }
}

struct CombinedRepsEntryView: View {
    let entry: CombinedRepsEntry
    
    @Environment(\.widgetFamily) var family
    
    var numberOfRepsToShow: Int {
        if family == .systemMedium {
            return 2
        }
        return 4
    }
    
    var body: some View {
        ZStack {
            WidgetBackground()
            
            if entry.hasLocation {
                
                VStack(alignment: .leading, spacing: 10) {
                    ForEach(entry.reps.prefix(numberOfRepsToShow), id: \.name) { rep in
                        RepView(rep: rep)
                    }
                }
                .colorScheme(.dark)
                .padding()
                
            } else {
                Text("Please launch the app and set your location in order to show your reps.")
                    .font(.headline)
                    .foregroundColor(.white)
                    .opacity(0.8)
                    .lineLimit(nil)
                    .padding()
            }
        }
    }
}

struct RepView: View {
    let rep: CombinedRepsEntry.Rep
    let photoSize: CGFloat = 50
    
    var body: some View {
        HStack {
            
            if let image = rep.photo {
                Image(uiImage: image)
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .clipShape(Circle())
                    .frame(width: photoSize)
                    .padding(2)
                    .background(
                        Circle().fill(rep.accentColor)
                    )
            } else {
                Circle()
                    .fill(Color.white)
                    .blendMode(.overlay)
                    .frame(width: photoSize)
            }
            
            VStack(alignment: .leading) {
                HStack {
                    Text(rep.name)
                        .font(.headline)
                    
                    Text(rep.party.uppercased())
                        .font(Font.caption.bold())
                        .padding(.horizontal, 3)
                        .padding(.vertical, 2)
                        .foregroundColor(Color.black.opacity(0.5))
                        .background(RoundedRectangle(cornerRadius: 3, style: .continuous).fill(rep.accentColor))
                }
                
                Text(rep.area)
                    .font(.subheadline)
                    .foregroundColor(Color(.secondaryLabel))
                    .blendMode(.overlay)
            }
        }
    }
}

struct CombineRepsEntryView_Previews: PreviewProvider {
    static var previews: some View {
        Group {
            CombinedRepsEntryView(entry: .init(date: Date(), reps: .sample, hasLocation: true))
                .previewContext(WidgetPreviewContext(family: .systemMedium))
                .previewDisplayName("Medium Reps Widget")
            
            CombinedRepsEntryView(entry: .init(date: Date(), reps: .sample, hasLocation: true))
                .previewContext(WidgetPreviewContext(family: .systemLarge))
                .previewDisplayName("Large Reps Widget")
            
            CombinedRepsEntryView(entry: .init(date: Date(), reps: [], hasLocation: false))
                .previewContext(WidgetPreviewContext(family: .systemMedium))
                .previewDisplayName("Medium Reps Widget (No location)")
            
            CombinedRepsEntryView(entry: .init(date: Date(), reps: [], hasLocation: false))
                .previewContext(WidgetPreviewContext(family: .systemLarge))
                .previewDisplayName("Large Reps Widget (No location)")
        }
    }
}
