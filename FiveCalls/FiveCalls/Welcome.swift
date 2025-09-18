//
//  Welcome.swift
//  FiveCalls
//
//  Created by Christopher Selin on 10/21/23.
//  Copyright © 2023 5calls. All rights reserved.
//

import SwiftUI

struct Welcome: View {
    @AppStorage(UserDefaultsKey.hasShownWelcomeScreen.rawValue) var hasShownWelcomeScreen = false

    @Environment(\.dismiss) var dismiss
    @EnvironmentObject var store: Store

    var onContinue: (() -> Void)?

    var subMessage: String {
        guard store.state.globalCallCount > 0 else {
            return ""
        }

        return String(format: Bundle.Strings.welcomeSection3Calls(
            StatsViewModel(numberOfCalls: store.state.globalCallCount).formattedNumberOfCalls)
        )
    }

    var subMessageOpacity: Double {
        store.state.globalCallCount > 0 ? 1 : 0
    }

    var body: some View {
        ScrollView {
            Grid(verticalSpacing: 30) {
                Image("fivecalls-logotype")
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(width: 292)
                    .padding(.vertical, 24)
                GridRow() {
                    Image(systemName: "phone.badge.waveform")
                        .symbolRenderingMode(.palette)
                        .foregroundStyle(.red, .blue)
                        .font(.title)
                        .accessibilityHidden(true)
                    VStack(alignment: .leading) {
                        Text(Bundle.Strings.welcomeSection1Title)
                            .fontWeight(.heavy)
                        Text(Bundle.Strings.welcomeSection1Message)
                    }
                    .accessibilityElement(children: .combine)
                }
                GridRow() {
                    Image(systemName: "goforward.5")
                        .foregroundStyle(.blue)
                        .font(.title)
                        .accessibilityHidden(true)
                    VStack(alignment: .leading) {
                        Text(Bundle.Strings.welcomeSection2Title)
                            .fontWeight(.heavy)
                        Text(Bundle.Strings.welcomeSection2Message)
                    }
                    .accessibilityElement(children: .combine)
                }
                GridRow() {
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
                    Text(Bundle.Strings.welcomeButtonTitle)
                        .foregroundColor(.white)
                        .padding()
                        .frame(maxWidth: .infinity)
                        .background {
                            RoundedRectangle(cornerRadius: 6)
                                .foregroundColor(.blue)
                        }
                }
            }
            .onAppear() {
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
