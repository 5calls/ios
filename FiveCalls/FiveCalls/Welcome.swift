// Copyright 5calls. All rights reserved. See LICENSE for details.

import SwiftUI

struct Welcome: View {
    @AppStorage(UserDefaultsKey.hasShownWelcomeScreen.rawValue) var hasShownWelcomeScreen = false

    @Environment(\.dismiss) var dismiss
    @EnvironmentObject var store: Store

    var onContinue: (() -> Void)?

    var subMessage: String {
        guard store.state.globalCallCount > 0,
              let numberOfCalls = StatsViewModel(numberOfCalls: store.state.globalCallCount).formattedNumberOfCalls
        else {
            return ""
        }

        return String(
            localized: "Together we've made\n\(numberOfCalls) calls",
            comment: "Welcome number of calls display text"
        )
    }

    var subMessageOpacity: Double {
        store.state.globalCallCount > 0 ? 1 : 0
    }

    var body: some View {
        ScrollView {
            Grid(verticalSpacing: 30) {
                Image(.fivecallsLogotype)
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(width: 292)
                    .padding(.vertical, 24)
                    .accessibilityHidden(true)
                GridRow {
                    Image(systemName: "phone.badge.waveform")
                        .symbolRenderingMode(.palette)
                        .foregroundStyle(.red, .blue)
                        .font(.title)
                        .accessibilityHidden(true)
                    VStack(alignment: .leading) {
                        Text("Make your voice heard", comment: "Welcome section 1 title")
                            .fontWeight(.heavy)
                        Text(
                            "Turn your passive participation into active resistance. Facebook likes and Twitter retweets can’t create the change you want to see. Calling your Government on the phone can.",
                            comment: "Welcome section 1 message"
                        )
                    }
                    .accessibilityElement(children: .combine)
                }
                GridRow {
                    Image(systemName: "goforward.5")
                        .foregroundStyle(.blue)
                        .font(.title)
                        .accessibilityHidden(true)
                    VStack(alignment: .leading) {
                        Text(
                            "Spend 5 minutes, make 5 calls",
                            comment: "Welcome section 2 title"
                        )
                        .fontWeight(.heavy)
                        Text(
                            "Calling is the most effective way to influence your representative.",
                            comment: "Welcome section 2 message"
                        )
                    }
                    .accessibilityElement(children: .combine)
                }
                GridRow {
                    Image(systemName: "person.2")
                        .opacity(subMessageOpacity)
                        .symbolRenderingMode(.palette)
                        .foregroundStyle(.blue, .red)
                        .font(.title)
                        .accessibilityHidden(true)
                    Text(subMessage)
                        .fontWeight(.heavy)
                        .opacity(subMessageOpacity)
                        .gridColumnAlignment(.leading)
                }
                Spacer()
                Spacer()
                Button(action: {
                    onContinue?()
                    dismiss()
                }) {
                    Text("Get Started", comment: "Welcome button title")
                        .foregroundColor(.white)
                        .padding()
                        .frame(maxWidth: .infinity)
                        .background {
                            RoundedRectangle(cornerRadius: 6)
                                .foregroundColor(.blue)
                        }
                }
            }
            .onAppear {
                hasShownWelcomeScreen = true
                if store.state.globalCallCount == 0 {
                    store.dispatch(action: .FetchStats(nil))
                }
            }
            .frame(maxWidth: .infinity)
            .padding(30)
        }
    }
}

#Preview {
    let previewState = {
        let state = AppState()
        state.globalCallCount = 12345
        return state
    }()

    let previewStore = Store(state: previewState, middlewares: [appMiddleware()])

    Welcome().environmentObject(previewStore)
}
