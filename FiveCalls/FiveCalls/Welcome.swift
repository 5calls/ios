//
//  Welcome.swift
//  FiveCalls
//
//  Created by Christopher Selin on 10/21/23.
//  Copyright © 2023 5calls. All rights reserved.
//

import SwiftUI

struct Welcome: View {
    @Environment(\.dismiss) var dismiss
    @EnvironmentObject var store: Store

    var onContinue: (() -> Void)?

    struct CustomLabel: LabelStyle {
        var spacing: Double = 0.0

        func makeBody(configuration: Configuration) -> some View {
            HStack(spacing: spacing) {
                configuration.icon
                configuration.title
            }
        }
    }

    var subMessage: String {
        guard store.state.globalCallCount > 0 else {
            return ""
        }

        return String(format: R.string.localizable.welcomePage2Calls(
            StatsViewModel(numberOfCalls: store.state.globalCallCount).formattedNumberOfCalls)
        )
    }

    var subMessageOpacity: Double {
        store.state.globalCallCount > 0 ? 1 : 0
    }

    var body: some View {
        ScrollView {
            VStack {
                Image(decorative: R.image.fivecallsLogotype)
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(width: 292)
                    .padding(.vertical, 24)

                VStack(alignment: .leading, spacing: 30) {
                    Label {
                        VStack(alignment: .leading) {
                            Text(R.string.localizable.welcomePage1Title())
                                .fontWeight(.heavy)
                                .multilineTextAlignment(.leading)
                            Text(R.string.localizable.welcomePage1Message())
                                .multilineTextAlignment(.leading)
                        }
                        .accessibilityElement(children: .combine)
                    } icon: {
                        Image(systemName: "phone.badge.waveform")
                            .symbolRenderingMode(.palette)
                            .foregroundStyle(.fivecallsRed, .fivecallsDarkBlue)
                    }
                    .labelStyle(CustomLabel(spacing: 20))

                    Label {
                        VStack(alignment: .leading) {
                            Text(R.string.localizable.welcomePage2Title())
                                .fontWeight(.heavy)
                            Text(R.string.localizable.welcomePage2Message())
                        }
                        .accessibilityElement(children: .combine)
                    } icon: {
                        Image(systemName: "goforward.5")
                            .foregroundStyle(.fivecallsDarkBlue)
                    }
                    .labelStyle(CustomLabel(spacing: 20))

                    Label {
                        VStack(alignment: .leading) {
                            Text(subMessage)
                                .fontWeight(.heavy)
                                .opacity(subMessageOpacity)
                        }
                        .accessibilityElement(children: .combine)
                    } icon: {
                        Image(systemName: "person.2")
                            .opacity(subMessageOpacity)
                            .symbolRenderingMode(.palette)
                            .foregroundStyle(.fivecallsGreen, .fivecallsDarkBlue)
                    }
                    .labelStyle(CustomLabel(spacing: 12))
                    Spacer()
                    Button(action: {
                        onContinue?()
                        dismiss()
                    }) {
                        // TODO: update string if needed
                        //          Text(R.string.localizable.welcomePage2ButtonTitle())
                        Text("Continue")
                            .foregroundColor(.white)
                    }
                    .padding()
                    .frame(maxWidth: .infinity)
                    .background {
                        RoundedRectangle(cornerRadius: 6)
                            .foregroundColor(.fivecallsDarkBlue)
                    }
                }
                .padding(30)
            }
            .onAppear() {
                if store.state.globalCallCount == 0 {
                    store.dispatch(action: .FetchStats(nil))
                }
            }
        }
    }
}

struct Welcome_Previews: PreviewProvider {
    static let previewState = {
        var state = AppState()
        state.globalCallCount = 12345
        return state
    }()

    static let previewStore = Store(state: previewState, middlewares: [appMiddleware()])

    static var previews: some View {
        Welcome().environmentObject(previewStore)
    }
}
