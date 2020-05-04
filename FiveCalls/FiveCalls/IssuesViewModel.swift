//
//  IssuesViewModel.swift
//  FiveCalls
//
//  Created by Indrajit on 17/10/17.
//  Copyright © 2017 5calls. All rights reserved.
//

import Foundation

protocol IssuesViewModel {

    var issues: [Issue] { get }

    init(issues:[Issue])
    func numberOfSections() -> Int
    func numberOfRowsInSection(section: Int) -> Int
    func hasNoData() -> Bool
    func issueForIndexPath(indexPath: IndexPath) -> Issue
    func indexOfIssueWithID(id: Int64) -> Int?
    func titleForHeaderInSection(section: Int) -> String
}

extension IssuesViewModel {
    var categorizedIssues: [CategorizedIssuesViewModel] {
        var categoryViewModels = Set<CategorizedIssuesViewModel>()
        for issue in issues {
            for category in issue.categories {

                if let categorized = categoryViewModels.first(where: { $0.category == category }) {
                    categorized.issues.append(issue)
                } else {
                    categoryViewModels.insert(CategorizedIssuesViewModel(category: category, issues: [issue]))
                }
            }
        }
        return Array(categoryViewModels).sorted(by: { $0.category < $1.category })
    }
}

// Shows all issues - grouped by categories.
struct AllIssuesViewModel: IssuesViewModel {
    let issues: [Issue]

    init(issues: [Issue]) {
        self.issues = issues
    }

    func numberOfSections() -> Int {
        // As many section as there are unique categories.
        return categorizedIssues.count
    }

    func numberOfRowsInSection(section: Int) -> Int {
        return categorizedIssues[section].issues.count
    }

    func hasNoData() -> Bool {
        return categorizedIssues.count == 0
    }

    func issueForIndexPath(indexPath: IndexPath) -> Issue {
        return categorizedIssues[indexPath.section].issues[indexPath.row]
    }

    func titleForHeaderInSection(section: Int) -> String {
        // Category name as section header.
        return categorizedIssues[section].name
    }

    func indexOfIssueWithID(id: Int64) -> Int? {
        return issues.firstIndex(where: { $0.id == id })
    }
}

// Shows only the active issues.
struct ActiveIssuesViewModel: IssuesViewModel {
    private let activeIssues: [Issue]
    let issues: [Issue]

    init(issues: [Issue]) {
        self.issues = issues
        activeIssues = issues.filter { $0.active }
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

    func indexOfIssueWithID(id: Int64) -> Int? {
        return activeIssues.firstIndex(where: { $0.id == id })
    }
}
