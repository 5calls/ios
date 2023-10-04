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
    let name: String
}

let days = [
    Day(index: 1, name: R.string.localizable.dayPickerSunday()),
    Day(index: 2, name: R.string.localizable.dayPickerMonday()),
    Day(index: 3, name: R.string.localizable.dayPickerTuesday()),
    Day(index: 4, name: R.string.localizable.dayPickerWednesday()),
    Day(index: 5, name: R.string.localizable.dayPickerThursday()),
    Day(index: 6, name: R.string.localizable.dayPickerFriday()),
    Day(index: 7, name: R.string.localizable.dayPickerSaturday())
]

struct MultipleDayPicker: View {
    @Binding var selectedDayIndices: [Int]

    var borderColor: Color { selectedDayIndices.isEmpty ? Color.fivecallsRed : Color.fivecallsDarkBlue
    }
    
    var body: some View {
        HStack(spacing: 0) {
            ForEach(days, id: \.self) { day in
                Text(String(day.name))
                    .foregroundColor(isIndexSelected(day.index) ? Color.fivecallsLightBlue : Color.fivecallsMediumDarkGray)
                    .padding(5)
                    .frame(maxWidth: .infinity)
                    .frame(height: 50)
                    .background(isIndexSelected(day.index) ? Color.fivecallsDarkBlue : Color(.systemBackground))
                    .border(Color.fivecallsDarkBlue, width: 0.5)
                    .aspectRatio(1.0, contentMode: .fit)
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
        .padding(16)
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
