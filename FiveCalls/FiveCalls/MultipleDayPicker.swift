//
//  MultipleDayPicker.swift
//  FiveCalls
//
//  Created by Christopher Selin on 9/13/23.
//  Copyright © 2023 5calls. All rights reserved.
//

import SwiftUI

struct Day: Hashable {
    let index: Int
    let abbr: String
    let name: String
}

let days = [
    Day(index: 1, abbr: Bundle.Strings.dayPickerSundayAbbr, name: Bundle.Strings.dayPickerSunday),
    Day(index: 2, abbr: Bundle.Strings.dayPickerMondayAbbr, name: Bundle.Strings.dayPickerMonday),
    Day(index: 3, abbr: Bundle.Strings.dayPickerTuesdayAbbr, name: Bundle.Strings.dayPickerTuesday),
    Day(index: 4, abbr: Bundle.Strings.dayPickerWednesdayAbbr, name: Bundle.Strings.dayPickerWednesday),
    Day(index: 5, abbr: Bundle.Strings.dayPickerThursdayAbbr, name: Bundle.Strings.dayPickerThursday),
    Day(index: 6, abbr: Bundle.Strings.dayPickerFridayAbbr, name: Bundle.Strings.dayPickerFriday),
    Day(index: 7, abbr: Bundle.Strings.dayPickerSaturdayAbbr, name: Bundle.Strings.dayPickerSaturday)
]

struct MultipleDayPicker: View {
    @Binding var selectedDayIndices: [Int]

    var borderColor: Color { selectedDayIndices.isEmpty ? Color.fivecallsRedText : Color.fivecallsDarkBlue
    }
    
    var body: some View {
        DaysFlowLayout(spacing: -1) {
            ForEach(days, id: \.self) { day in
                DayView(text: day.abbr)
                    .background(isIndexSelected(day.index) ? Color.fivecallsDarkBlue : Color(.systemBackground))
                    .foregroundColor(isIndexSelected(day.index) ? Color.fivecallsLightBlue : Color.fivecallsMediumDarkGray)
                    .border(borderColor)
                    .accessibilityLabel(Text("\(String(day.name)) \(isIndexSelected(day.index) ? Bundle.Strings.scheduledRemindersDaySelected : Bundle.Strings.scheduledRemindersDayNotSelected)"))
                    .accessibilityAddTraits(.isButton)
                .onTapGesture {
                    if isIndexSelected(day.index) {
                        selectedDayIndices.removeAll(where: {$0 == day.index})
                    } else {
                        selectedDayIndices.append(day.index)
                    }
                }
            }
            }
            .overlay(
                RoundedRectangle(cornerRadius: 4)
                    .strokeBorder(borderColor, lineWidth: 1)
            )
            .clipShape(RoundedRectangle(cornerRadius: 4))
    }
    
    private func isIndexSelected(_ index: Int) -> Bool {
        return selectedDayIndices.contains(index)
    }
}

struct MultipleDayPicker_Previews: PreviewProvider {
    static var previews: some View {
        @State var selectedDayIndices: [Int] = []
        MultipleDayPicker(selectedDayIndices: $selectedDayIndices)
    }
}

struct DaysFlowLayout: Layout {
    var spacing: CGFloat? = nil

    struct Cache {
        var sizes: [CGSize] = []
        var spacing: [CGFloat] = []
    }

    func makeCache(subviews: Subviews) -> Cache {
        let sizes = subviews.map { $0.sizeThatFits(.unspecified) }
        let spacing: [CGFloat] = subviews.indices.map { index in
            guard index != subviews.count - 1 else {
                return 0
            }

            return subviews[index].spacing.distance(
                to: subviews[index+1].spacing,
                along: .horizontal
            )
        }

        return Cache(sizes: sizes, spacing: spacing)
    }


    func sizeThatFits(proposal: ProposedViewSize, subviews: Subviews, cache: inout Cache) -> CGSize {
        let standardizedWidth = cache.sizes.max(by: { $0.width < $1.width })?.width ?? 0
        let standardizedHeight = standardizedWidth

        var totalHeight: CGFloat = 0
        var totalWidth: CGFloat = 0

        var lineWidth: CGFloat = 0
        var lineHeight: CGFloat = 0

            for index in subviews.indices {
            if lineWidth + standardizedWidth > proposal.width ?? 0 {
                totalHeight += lineHeight + (spacing ?? cache.spacing[index])
                lineWidth = standardizedWidth
                lineHeight = standardizedHeight
            } else {
                lineWidth += standardizedWidth + (spacing ?? cache.spacing[index])
                lineHeight = max(lineHeight, standardizedHeight)
            }

            totalWidth = max(totalWidth, lineWidth)
        }

        totalHeight += lineHeight

        return .init(width: totalWidth, height: totalHeight)
    }

    func placeSubviews(in bounds: CGRect, proposal: ProposedViewSize, subviews: Subviews, cache: inout Cache) {
        let standardizedWidth = cache.sizes.max(by: { $0.width < $1.width })?.width ?? 0
        let standarddizedHeight = standardizedWidth

        var lineX = bounds.minX
        var lineY = bounds.minY
        var lineHeight: CGFloat = 0

        for index in subviews.indices {
            if lineX + standardizedWidth > (proposal.width ?? 0) {
                lineY += lineHeight + (spacing ?? cache.spacing[index])
                lineHeight = 0
                lineX = bounds.minX
            }

            let position = CGPoint(
                x: lineX + standardizedWidth / 2,
                y: lineY + standarddizedHeight / 2
            )

            lineHeight = max(lineHeight, standarddizedHeight)
            lineX += standardizedWidth + (spacing ?? cache.spacing[index])

            subviews[index].place(
                at: position,
                anchor: .center,
                proposal: ProposedViewSize(width: standardizedWidth, height: standarddizedHeight)
            )
        }
    }
}

struct DayView: View {
    let text: String

    var body: some View {
        ZStack {
            Color.clear

            Text(text)
                .font(.title3)
                .padding(5)
        }
    }
}
