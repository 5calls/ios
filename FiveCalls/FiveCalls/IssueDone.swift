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
        Text("Issue \(issue.name) done page")
    }
}

#Preview {
    IssueDone(issue: .basicPreviewIssue)
}
