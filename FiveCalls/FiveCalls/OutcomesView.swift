//
//  OutcomesView.swift
//  FiveCalls
//
//  Created by Nick O'Neill on 10/12/23.
//  Copyright © 2023 5calls. All rights reserved.
//

import SwiftUI

struct OutcomesView<T: IssueNavModel>: View {
    let value: T
    let outcomes: [Outcome]
    let report: (Outcome) -> ()
    
    var body: some View {
        LazyVGrid(columns: [GridItem(.flexible()),GridItem(.flexible())]) {
            ForEach(outcomes) { outcome in
                PrimaryButton(title: outcome.label.capitalized,
                                  systemImageName: "megaphone.fill")
                .accessibilityAddTraits(.isButton)
                .onTapGesture {
                    report(outcome)
                }
            }
        }
    }
}

#Preview {
    OutcomesView(value: IssueDetailNavModel(issue: .basicPreviewIssue, contacts: [.housePreviewContact, .senatePreviewContact1, .senatePreviewContact2]), outcomes: [Outcome(label: "OK", status: "ok"),Outcome(label: "No", status: "no"),Outcome(label: "Maybe", status: "maybe")], report: { _ in })
}
