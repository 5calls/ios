// Copyright 5calls. All rights reserved. See LICENSE for details.

import SwiftUI

struct Day: Hashable {
    let index: Int
    let abbr: String
    let name: String
}

let days = [
    Day(index: 1, abbr: String(
        localized: "Sun",
        comment: "Abbreviated day name"
    ), name: String(
        localized: "Sunday",
        comment: "Day name"
    )),
    Day(index: 1, abbr: String(
        localized: "Mon",
        comment: "Abbreviated day name"
    ), name: String(
        localized: "Monday",
        comment: "Day name"
    )),
    Day(index: 1, abbr: String(
        localized: "Tue",
        comment: "Abbreviated day name"
    ), name: String(
        localized: "Tuesday",
        comment: "Day name"
    )),
    Day(index: 1, abbr: String(
        localized: "Wed",
        comment: "Abbreviated day name"
    ), name: String(
        localized: "Wednesday",
        comment: "Day name"
    )),
    Day(index: 1, abbr: String(
        localized: "Thu",
        comment: "Abbreviated day name"
    ), name: String(
        localized: "Thursday",
        comment: "Day name"
    )),
    Day(index: 1, abbr: String(
        localized: "Fri",
        comment: "Abbreviated day name"
    ), name: String(
        localized: "Friday",
        comment: "Day name"
    )),
    Day(index: 1, abbr: String(
        localized: "Sat",
        comment: "Abbreviated day name"
    ), name: String(
        localized: "Saturday",
        comment: "Day name"
    )),
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
                    .accessibilityLabel(Text(accessibilityLabelText(day: day)))
                    .accessibilityAddTraits(.isButton)
                    .onTapGesture {
                        if isIndexSelected(day.index) {
                            selectedDayIndices.removeAll(where: { $0 == day.index })
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
        selectedDayIndices.contains(index)
    }

    private func accessibilityLabelText(day: Day) -> String {
        let name = day.name
        let selected = String(localized: " selected", comment: "MultipleDayPicker AccessibiltyLabel text")
        let notSelected = String(localized: " not selected", comment: "MultipleDayPicker AccessibilityLabel text")

        return isIndexSelected(day.index) ? "\(name)\(selected)" : "\(name)\(notSelected)"
    }
}

struct DaysFlowLayout: Layout {
    var spacing: CGFloat?

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
                to: subviews[index + 1].spacing,
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

// Not translated to #Preview macro, @Previewable is not available
struct MultipleDayPicker_Previews: PreviewProvider {
    static var previews: some View {
        @State var selectedDayIndices: [Int] = []
        MultipleDayPicker(selectedDayIndices: $selectedDayIndices)
    }
}
