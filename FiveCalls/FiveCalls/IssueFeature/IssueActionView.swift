// Copyright 5calls. All rights reserved. See LICENSE for details.

import MarkdownUI
import SwiftUI

struct IssueActionView: View {
    @Environment(\.openURL) private var openURL

    let action: IssueAction

    var body: some View {
        switch action.type {
        case .freeform:
            freeformView
        case .donate:
            donateView
        case .unknown:
            EmptyView()
        }
    }

    @ViewBuilder
    private var freeformView: some View {
        if let title = action.title,
           let body = action.body,
           let buttonText = action.buttonText,
           let buttonURLString = action.buttonURL,
           let buttonURL = URL(string: buttonURLString.replacingOccurrences(of: "%cid%", with: AnalyticsManager.shared.callerID)) {
            Text(title)
                .font(.caption).fontWeight(.bold)
                .padding(.top, 16)
                .padding(.bottom, 6)
                .accessibilityAddTraits(.isHeader)
            Markdown(body)
                .markdownTextStyle(\.text) {
                    FontSize(.em(1.15))
                }
            Button(action: {
                openURL(buttonURL)
            }) {
                PrimaryButton(
                    title: LocalizedStringResource(stringLiteral: buttonText),
                    systemImageName: "hand.thumbsup.circle.fill"
                )
            }
            .padding(.bottom, 16)
        }
    }

    private var donateView: some View {
        Group {
            Text("Support 5 Calls", comment: "Support 5 Calls header text")
                .font(.caption).fontWeight(.bold)
                .accessibilityAddTraits(.isHeader)
            HStack {
                Text("Keep 5 Calls free and up-to-date", comment: "Support 5 Calls subtitle text")
                Button(action: {
                    openURL(donateURL)
                }) {
                    PrimaryButton(
                        title: LocalizedStringResource(
                            "Donate today",
                            comment: "Donate today button title"
                        ),
                        systemImageName: "hand.thumbsup.circle.fill",
                        bgColor: .fivecallsRed
                    )
                }
            }
            .padding(.bottom, 16)
        }
    }

    private var donateURL: URL {
        URL(string: "https://secure.actblue.com/donate/5calls-donate?refcode=ios&refcode2=\(AnalyticsManager.shared.callerID)")!
    }
}

#Preview("Freeform") {
    VStack(alignment: .leading) {
        IssueActionView(action: IssueAction(
            type: .freeform,
            title: "Participate in a survey?",
            body: "Would you like to participate in a survey about contacting your representatives?",
            buttonText: "Sign up",
            buttonURL: "https://example.com?caller=%cid%"
        ))
    }
    .padding(.horizontal)
}

#Preview("Freeform — long body") {
    VStack(alignment: .leading) {
        IssueActionView(action: IssueAction(
            type: .freeform,
            title: "Help us improve",
            body: "We're running a research study on civic engagement habits. Participants who complete the **20-minute survey** will be entered to win one of ten $50 gift cards. [Learn more](https://example.com).",
            buttonText: "Take the survey",
            buttonURL: "https://example.com?caller=%cid%"
        ))
    }
    .padding(.horizontal)
}

#Preview("Donate") {
    VStack(alignment: .leading) {
        IssueActionView(action: IssueAction(type: .donate))
    }
    .padding(.horizontal)
}

#Preview("Unknown type") {
    VStack(alignment: .leading) {
        Text("Nothing should render below:")
        IssueActionView(action: IssueAction(type: .unknown("future-type")))
    }
    .padding(.horizontal)
}
