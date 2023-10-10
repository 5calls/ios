//
//  YourImpact.swift
//  FiveCalls
//
//  Created by Christopher Selin on 10/10/23.
//  Copyright © 2023 5calls. All rights reserved.
//

import SwiftUI

struct YourImpact: View {
    @Environment(\.dismiss) var dismiss
            
    var body: some View {
        NavigationStack {
            VStack {
            }
                .navigationTitle(R.string.localizable.yourImpactTitle())
                .navigationBarTitleDisplayMode(.inline)
                .navigationBarBackButtonHidden()
                .toolbarBackground(.visible)
                .toolbarBackground(Color.fivecallsDarkBlue)
                .toolbarColorScheme(.dark, for: .navigationBar)
                .toolbar {
                    ToolbarItem(placement: .navigationBarTrailing) {
                        Button(action: {
                            self.dismiss()
                        }) {
                            Text(R.string.localizable.doneButtonTitle())
                                .bold()
                        }
                    }
                }
        }
        .accentColor(.white)
    }
}

struct YourImpact_Previews: PreviewProvider {
    static var previews: some View {
        NavigationView {
            YourImpact()
        }
    }
}
