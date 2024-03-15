//
//  InboxView.swift
//  FiveCalls
//
//  Created by Nick O'Neill on 2/25/24.
//  Copyright © 2024 5calls. All rights reserved.
//

import SwiftUI

struct InboxView: View {
    @Environment(\.dismiss) var dismiss

    var body: some View {
        NavigationStack {
            Text("Reps + Inbox")
        }.navigationBarHidden(true)
    }
}

#Preview {
    InboxView()
}
