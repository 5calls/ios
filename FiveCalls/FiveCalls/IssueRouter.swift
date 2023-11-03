//
//  IssueRouter.swift
//  FiveCalls
//
//  Created by Nick O'Neill on 10/8/23.
//  Copyright © 2023 5calls. All rights reserved.
//

import SwiftUI

class IssueRouter: ObservableObject {
    @Published var path = NavigationPath()
    @Published var selectedIssue: Issue?
    
    func back() {
        if path.isEmpty {
            selectedIssue = nil
        } else {
            path.removeLast()
        }
    }
    
    func backToRoot() {
        path = NavigationPath()
        selectedIssue = nil
    }
}
