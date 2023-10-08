//
//  IssueDone.swift
//  FiveCalls
//
//  Created by Nick O'Neill on 10/2/23.
//  Copyright © 2023 5calls. All rights reserved.
//

import SwiftUI

struct IssueDone: View {
    let issue: Issue
    
    var body: some View {
        ScrollView {
            VStack {
                Text("Issue \(issue.name) done page")
                Button(action: {}, label: {
                    Text("Back to dashboard")
                })
            }
        }.navigationBarHidden(true)
        .clipped()
    }
}

#Preview {
    IssueDone(issue: .basicPreviewIssue)
}
