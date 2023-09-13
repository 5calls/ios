//
//  MultipleDayPicker.swift
//  FiveCalls
//
//  Created by Christopher Selin on 9/13/23.
//  Copyright © 2023 5calls. All rights reserved.
//

import SwiftUI

enum Day: String, CaseIterable {
    case Sun, Mon, Tues, Wed, Thur, Fri, Sat
}

struct MultipleDayPicker: View {
    @Binding var selectedDays: [Day]
    var borderColor: Color { selectedDays.isEmpty ? Color(R.color.red()!) : Color(R.color.darkBlue()!)
    }
    
    var body: some View {
        HStack(spacing: 0) {
            ForEach(Day.allCases, id: \.self) { day in
                Text(String(day.rawValue))
                    .foregroundColor(isDaySelected(day) ? Color(R.color.lightBlue()!) : Color(R.color.mediumDarkGray()!))
                    .padding(5)
                    .frame(maxWidth: .infinity)
                    .frame(height: 50)
                    .background(isDaySelected(day) ? Color(R.color.darkBlue()!) : Color(.systemBackground))
                    .border(Color(R.color.darkBlue()!), width: 0.5)
                    .aspectRatio(1.0, contentMode: .fit)
                    .onTapGesture {
                        if self.isDaySelected(day) {
                            selectedDays.removeAll(where: {$0 == day})
                        } else {
                            selectedDays.append(day)
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
    
    private func isDaySelected(_ day: Day) -> Bool {
        return selectedDays.contains(day)
    }
}

struct MultipleDayPicker_Previews: PreviewProvider {
    static var previews: some View {
        @State var selectedDays: [Day] = []
        MultipleDayPicker(selectedDays: $selectedDays)
    }
}
