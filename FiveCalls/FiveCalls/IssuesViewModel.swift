// Copyright 5calls. All rights reserved. See LICENSE for details.

import Foundation

protocol IssuesViewModel {
    var issues: [Issue] { get }

    init(issues: [Issue])
    func numberOfSections() -> Int
    func numberOfRowsInSection(section: Int) -> Int
    func hasNoData() -> Bool
    func issueForIndexPath(indexPath: IndexPath) -> Issue
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
        categorizedIssues.count
    }

    func numberOfRowsInSection(section: Int) -> Int {
        categorizedIssues[section].issues.count
    }

    func hasNoData() -> Bool {
        categorizedIssues.count == 0
    }

    func issueForIndexPath(indexPath: IndexPath) -> Issue {
        categorizedIssues[indexPath.section].issues[indexPath.row]
    }

    func titleForHeaderInSection(section: Int) -> String {
        // Category name as section header.
        categorizedIssues[section].name
    }
}

// Shows only the active issues.
struct ActiveIssuesViewModel: IssuesViewModel {
    private let activeIssues: [Issue]
    let issues: [Issue]

    init(issues: [Issue]) {
        self.issues = issues
        activeIssues = issues.filter(\.active)
    }

    func numberOfSections() -> Int {
        1
    }

    func numberOfRowsInSection(section _: Int) -> Int {
        activeIssues.count
    }

    func hasNoData() -> Bool {
        activeIssues.count == 0
    }

    func issueForIndexPath(indexPath: IndexPath) -> Issue {
        activeIssues[indexPath.row]
    }

    func titleForHeaderInSection(section _: Int) -> String {
        String(localized: "What's important to you?", comment: "ActiveIssuesViewModel Section header")
    }
}
