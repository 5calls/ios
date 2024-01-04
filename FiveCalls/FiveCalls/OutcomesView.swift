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

//                NavigationLink(value: IssueDetailNavModel(issue: issue, contacts: contacts)) {
//                    PrimaryButton(title: R.string.localizable.seeScript(), systemImageName: "megaphone.fill")
//                }



                NavigationLink(value: value) {
                    PrimaryButton(title: outcome.label.capitalized,
                                  systemImageName: "megaphone.fill")

                    // TODO: .onTap and .simultaneous not being triggered with voiceover?
//                    .accessibilityAddTraits(.isButton)
//                    .simultaneousGesture(TapGesture().onEnded {
//                        print("tapped button for \(outcome.label)")
//                        report(outcome)
//                    })
                    .onTapGesture {
                        print("tapped button for \(outcome.label)")
                        report(outcome)
                    }
                }
            }
        }

    }
}

#Preview {
    OutcomesView(value: IssueDetailNavModel(issue: .basicPreviewIssue, contacts: [.housePreviewContact, .senatePreviewContact1, .senatePreviewContact2]), outcomes: [Outcome(label: "OK", status: "ok"),Outcome(label: "No", status: "no"),Outcome(label: "Maybe", status: "maybe")], report: { _ in })
//        .padding()
}
