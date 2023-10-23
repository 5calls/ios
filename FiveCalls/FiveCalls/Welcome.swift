//
//  Welcome.swift
//  FiveCalls
//
//  Created by Christopher Selin on 10/21/23.
//  Copyright © 2023 5calls. All rights reserved.
//

import SwiftUI

struct Welcome: View {
    @EnvironmentObject var store: Store
    
    var onContinue: (() -> Void)?
    
    var body: some View {
        VStack {
            Image(.fivecallsLogotype)
                .resizable()
                .aspectRatio(contentMode: .fit)
                .frame(width: 292)
                .padding(.vertical, 24)
            TabView {
                Page1()
                Page2(onContinue: onContinue)
            }
            .tabViewStyle(.page)
        }
    }
}

struct Welcome_Previews: PreviewProvider {
    static let previewState = {
        var state = AppState()
        state.numberOfCalls = 12345
        return state
    }()

    static let previewStore = Store(state: previewState, middlewares: [appMiddleware()])
   
    static var previews: some View {
        Welcome().environmentObject(previewStore)
    }
}

struct Page1: View {
    var body: some View {
        VStack(alignment: .leading, spacing: 20) {
            Text(R.string.localizable.welcomePage1Title())
                .font(.title)
                .foregroundStyle(.fivecallsDarkBlueText)
            Text(R.string.localizable.welcomePage1Message())
                .font(.headline)
                .foregroundStyle(.fivecallsDarkBlueText)
            Spacer()
        }
        .padding(EdgeInsets(top: 24, leading: 24, bottom: 20, trailing: 24))
    }
}

struct Page2: View {
    @Environment(\.dismiss) var dismiss
    @EnvironmentObject var store: Store
    
    var onContinue: (() -> Void)?
    
    var subMessage: String {
        guard store.state.numberOfCalls > 0 else {
            return ""
        }
        
        return String(format: R.string.localizable.welcomePage2Calls(StatsViewModel(numberOfCalls: store.state.numberOfCalls).formattedNumberOfCalls))
    }
    
    var subMessageOpacity: Double {
        store.state.numberOfCalls > 0 ? 1 : 0
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text(R.string.localizable.welcomePage2Title())
                .font(.title)
                .foregroundStyle(.fivecallsDarkBlueText)
            Text(R.string.localizable.welcomePage2Message())
                .font(.headline)
                .foregroundStyle(.fivecallsDarkBlueText)
            Text(subMessage)
                .font(.headline)
                .foregroundStyle(.fivecallsDarkBlueText)
                .opacity(subMessageOpacity)
                .animation(.easeIn, value: subMessageOpacity)
            Spacer()
            Button(action: {
                onContinue?()
                dismiss()
            }) {
                Text(R.string.localizable.welcomePage2ButtonTitle())
                    .fontWeight(.semibold)
                    .foregroundColor(.white)
                    .font(.system(size: 30))
            }
            .padding()
            .frame(maxWidth: .infinity, minHeight: 73)
            .background {
                RoundedRectangle(cornerRadius: 6)
                    .foregroundColor(Color.fivecallsDarkBlue)
            }
        }
        .padding(EdgeInsets(top: 24, leading: 24, bottom: 48, trailing: 24))
        .onAppear() {
            if store.state.numberOfCalls == 0 {
                store.dispatch(action: .FetchStats)
            }
        }
    }
}
