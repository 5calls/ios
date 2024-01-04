//
//  OutcomesView.swift
//  FiveCalls
//
//  Created by Nick O'Neill on 10/12/23.
//  Copyright © 2023 5calls. All rights reserved.
//

import SwiftUI

struct OutcomesView: View {
    let outcomes: [Outcome]
    let navModel: AnyHashable
    let report: (Outcome) -> ()
    
    var body: some View {
        LazyVGrid(columns: [GridItem(.flexible()),GridItem(.flexible())]) {
            ForEach(outcomes) { outcome in
                NavigationLink(value: navModel) {
                    PrimaryButton(title: outcome.label.capitalized,
                                  systemImageName: "megaphone.fill")
                    .onTapGesture {
                        report(outcome)
                    }
                }
            }
        }
    }
}

#Preview {
    OutcomesView(outcomes: [Outcome(label: "OK", status: "ok"),Outcome(label: "No", status: "no"),Outcome(label: "Maybe", status: "maybe")], navModel: IssueNavModel(issue: .basicPreviewIssue, type: "mock"), report: { _ in })
        .padding()
}
