//
//  File.swift
//  FiveCalls
//
//  Created by Nick O'Neill on 10/8/23.
//  Copyright © 2023 5calls. All rights reserved.
//

import SwiftUI

class Router: ObservableObject {
    @Published var path = NavigationPath()
    
    func back() {
        path.removeLast()
    }
    
    func backToRoot() {
        path = NavigationPath()
    }
}

struct IssueDetailNavModel {
    let issue: Issue
    let contacts: [Contact]
}

extension IssueDetailNavModel: Equatable, Hashable {
    static func == (lhs: IssueDetailNavModel, rhs: IssueDetailNavModel) -> Bool {
        return lhs.issue.id == rhs.issue.id && lhs.contacts.elementsEqual(rhs.contacts)
    }
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(issue.id)
        hasher.combine(contacts.compactMap({$0.id}).joined())
    }
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
