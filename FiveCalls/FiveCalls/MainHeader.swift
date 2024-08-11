//
//  MainHeader.swift
//  FiveCalls
//
//  Created by Nick O'Neill on 3/16/24.
//  Copyright © 2024 5calls. All rights reserved.
//

import SwiftUI

struct MainHeader: View {
    @EnvironmentObject var store: Store

    @State var showLocationSheet = false

    var body: some View {
        HStack {
            MenuView(showingWelcomeScreen: store.state.showWelcomeScreen)

            LocationHeader(location: store.state.location, fetchingContacts: store.state.fetchingContacts)
                .padding(.bottom, 10)
                .onTapGesture {
                    showLocationSheet.toggle()
                }
                .sheet(isPresented: $showLocationSheet) {
                    LocationSheet()
                        .presentationDetents([.medium])
                        .presentationDragIndicator(.visible)
                        .padding(.top, 40)
                    Spacer()
                }

            Image(.fivecallsStars)
                .accessibilityHidden(true)
        }
    }
}

#Preview {
    MainHeader()
}
