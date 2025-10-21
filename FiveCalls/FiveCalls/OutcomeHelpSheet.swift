// Copyright 5calls. All rights reserved. See LICENSE for details.

import SwiftUI

struct OutcomeHelpSheet: View {
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack {
                    Text("""
                        Not sure how to mark the result of a call? 
                        
                        Choose **Made Contact** if you were able to reach the office.
                        
                        Choose **Left Voicemail** if you left a voicemail.
                        
                        Choose **Unavailable** if your call was not answered and no voicemail was left.
                        
                        Choose **Skip** if you did not attempt to make the call.
                        """,
                         comment: "Outcome help text explaining each option")
                    
                    Spacer()
                }
                .padding()
            }
            .navigationTitle(String(localized: "Outcome Selection Help", comment: "OutcomeHelpSheet navigation title"))
            .navigationBarTitleDisplayMode(.inline)
            .toolbarBackground(.visible)
            .toolbarBackground(Color.fivecallsDarkBlue)
            .toolbarColorScheme(.dark, for: .navigationBar)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button {
                        dismiss()
                    } label: {
                        Text("Done", comment: "Standard Done Button text")
                            .bold()
                    }
                }
            }
        }
    }
}

#Preview {
    OutcomeHelpSheet()
}
