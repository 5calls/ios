// Copyright 5calls. All rights reserved. See LICENSE for details.

import SwiftUI

struct MainHeader: View {
    @EnvironmentObject var store: Store

    @State var showLocationSheet = false

    var body: some View {
        HStack {
            MenuView(showingWelcomeScreen: store.state.showWelcomeScreen)

            LocationHeader(location: store.state.location,
                           isSplit: store.state.isSplitDistrict,
                           fetchingContacts: store.state.fetchingContacts)
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
