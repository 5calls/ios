// Copyright 5calls. All rights reserved. See LICENSE for details.

import SwiftUI

struct OutcomesView: View {
    let outcomes: [Outcome]
    let report: (Outcome) -> Void

    var body: some View {
        LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())]) {
            ForEach(outcomes) { outcome in
                PrimaryButton(title: ContactLog.localizedOutcomeForStatus(status: outcome.status))
                    .accessibilityAddTraits(.isButton)
                    .onTapGesture {
                        report(outcome)
                    }
            }
        }
    }
}

#Preview {
    OutcomesView(
        outcomes: [
            Outcome(
                label: "Left Voicemail",
                status: "vm"
            ),
            Outcome(
                label: "No",
                status: "no"
            ),
            Outcome(
                label: "Maybe",
                status: "maybe"
            ),
        ],
        report: {
            _ in
        }
    )
    .padding()
}
