//
//  Welcome.swift
//  FiveCalls
//
//  Created by Christopher Selin on 10/21/23.
//  Copyright © 2023 5calls. All rights reserved.
//

import SwiftUI

struct Welcome: View {
    var body: some View {
        VStack {
            Image(.fivecallsLogotype)
                .resizable()
                .aspectRatio(contentMode: .fit)
                .frame(width: 292)
                .padding(.vertical, 24)
            TabView {
                Page1()
                Page2()
            }
            .tabViewStyle(.page)
        }
    }
}

#Preview {
    Welcome()
}

struct Page1: View {
    var body: some View {
        VStack(alignment: .leading, spacing: 20) {
            Text("MAKE YOUR VOICE HEARD")
                .font(.title)
                .foregroundStyle(.fivecallsDarkBlueText)
            Text("Turn your passive participation into active resistance. Facebook likes and Twitter retweets can’t create the change you want to see. Calling your Government on the phone can.")
                .font(.headline)
                .foregroundStyle(.fivecallsDarkBlueText)
            Spacer()
        }
        .padding(EdgeInsets(top: 24, leading: 24, bottom: 20, trailing: 24))
    }
}

struct Page2: View {
    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text("Spend 5 minutes, make 5 calls.")
                .font(.title)
                .foregroundStyle(.fivecallsDarkBlueText)
            Text("Calling is the most effective way to influence your representative.")
                .font(.headline)
                .foregroundStyle(.fivecallsDarkBlueText)
            Text("TOGETHER WE'VE MADE\n... CALLS")
                .font(.headline)
                .foregroundStyle(.fivecallsDarkBlueText)
            Spacer()
            Button(action: {}) {
                Text("Get Started")
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
    }
}
