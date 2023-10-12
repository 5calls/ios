//
//  IssueDone.swift
//  FiveCalls
//
//  Created by Nick O'Neill on 10/2/23.
//  Copyright © 2023 5calls. All rights reserved.
//

import SwiftUI

struct IssueDone: View {
    @EnvironmentObject var router: Router
    
    let issue: Issue
    
    var body: some View {
        ScrollView {
            VStack {
                Text("Issue \(issue.name) done page")
                Button(action: {
                    router.backToRoot()
                }, label: {
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

struct IssueNavModel {
    let issue: Issue
    let type: String
}

extension IssueNavModel: Equatable, Hashable {
    static func == (lhs: IssueNavModel, rhs: IssueNavModel) -> Bool {
        return lhs.issue.id == rhs.issue.id && lhs.type == rhs.type
    }
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(issue.id)
        hasher.combine(type)
    }
}
