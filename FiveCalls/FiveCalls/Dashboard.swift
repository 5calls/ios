//
//  Dashboard.swift
//  FiveCalls
//
//  Created by Nick O'Neill on 6/28/23.
//  Copyright © 2023 5calls. All rights reserved.
//

import SwiftUI

struct Dashboard: View {
    @EnvironmentObject var appState: AppState
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 10) {
                Text("What’s important to you?")
                    .font(.system(size: 20))
                    .fontWeight(.semibold)
                ForEach(appState.issues) { issue in
                    IssueListItem(issue: issue)
                }
            }.padding(.horizontal, 10)
        }.onAppear {
            NewIssuesManager().fetchIssues(completion: { result in
            if case let .serverError(error) = result {
                print("error")
            }
            if case let .offline = result {
                print("offline")
            }
            })
        }
    }
}

struct Dashboard_Previews: PreviewProvider {
    static let previewState = {
        var state = AppState()
        state.issues = [
            Issue.basicPreviewIssue,
            Issue.multilinePreviewIssue
        ]
        return state
    }()
    
    static var previews: some View {
        Dashboard().environmentObject(previewState)
    }
}
