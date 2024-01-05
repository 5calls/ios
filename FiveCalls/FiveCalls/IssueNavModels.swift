//
//  IssueNavModels.swift
//  FiveCalls
//
//  Created by Heather Haindel on 1/4/24.
//  Copyright © 2024 5calls. All rights reserved.
//

protocol IssueNavModel: Hashable {
    var issue: Issue { get set }
}

struct IssueDetailNavModel: IssueNavModel {
    var issue: Issue
    let contacts: [Contact]
}

struct IssueDoneNavModel: IssueNavModel {
    var issue: Issue
    let type: String
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

extension IssueDoneNavModel: Equatable, Hashable {
    static func == (lhs: IssueDoneNavModel, rhs: IssueDoneNavModel) -> Bool {
        return lhs.issue.id == rhs.issue.id && lhs.type == rhs.type
    }

    func hash(into hasher: inout Hasher) {
        hasher.combine(issue.id)
        hasher.combine(type)
    }
}
