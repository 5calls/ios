//
//  IssuesViewModel.swift
//  FiveCalls
//
//  Created by Indrajit on 17/10/17.
//  Copyright © 2017 5calls. All rights reserved.
//

import Foundation

protocol IssuesViewModel {
    init(categories:[Category])
    func numberOfSections() -> Int
    func numberOfRowsInSection(section: Int) -> Int
    func hasNoData() -> Bool
    func issueForIndexPath(indexPath: IndexPath) -> Issue
    func titleForHeaderInSection(section: Int) -> String
}

// Shows all issues - grouped by categories.
struct AllIssuesViewModel: IssuesViewModel {
    private let categories: [Category]

    init(categories:[Category]) {
        self.categories = categories
    }

    func numberOfSections() -> Int {
        // As many section as there are unique categories.
        return categories.count
    }

    func numberOfRowsInSection(section: Int) -> Int {
        return categories[section].issues.count
    }

    func hasNoData() -> Bool {
        return categories.count == 0
    }

    func issueForIndexPath(indexPath: IndexPath) -> Issue {
        return categories[indexPath.section].issues[indexPath.row]
    }

    func titleForHeaderInSection(section: Int) -> String {
        // Category name as section header.
        return categories[section].name
    }
}

// Shows only the active issues.
struct ActiveIssuesViewModel: IssuesViewModel {
    private let activeIssues: [Issue]

    init(categories:[Category]) {
        var activeIssues: [Issue] = []
        // Filter issues to get only the active ones.
        categories.forEach { (category) in
            activeIssues.append(contentsOf: category.issues.filter({ $0.inactive == false }))
        }
        self.activeIssues = activeIssues
    }

    func numberOfSections() -> Int {
        return 1
    }

    func numberOfRowsInSection(section: Int) -> Int {
        return activeIssues.count
    }

    func hasNoData() -> Bool {
        return activeIssues.count == 0
    }

    func issueForIndexPath(indexPath: IndexPath) -> Issue {
        return activeIssues[indexPath.row]
    }

    func titleForHeaderInSection(section: Int) -> String {
        return R.string.localizable.whatsImportantTitle()
    }
}
