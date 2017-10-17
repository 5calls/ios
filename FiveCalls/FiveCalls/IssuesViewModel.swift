//
//  IssuesViewModel.swift
//  FiveCalls
//
//  Created by Indrajit on 17/10/17.
//  Copyright © 2017 5calls. All rights reserved.
//

import Foundation

struct IssuesViewModel {
    private let categories:[Category]
    private let showAll: Bool
    private let activeIssues: [Issue]

    init(categories:[Category], showAll: Bool) {
        self.categories = categories
        self.showAll = showAll
        var activeIssues: [Issue] = []
        if !showAll {
            categories.forEach { (category) in
                activeIssues.append(contentsOf: category.issues.filter({ $0.inactive == false }))
            }
        }
        self.activeIssues = activeIssues
    }

    func numberOfSections() -> Int {
        if showAll {
            return categories.count
        }
        return 1
    }

    func numberOfRowsInSection(section: Int) -> Int {
        if showAll {
            return categories[section].issues.count
        }
        return activeIssues.count
    }

    func hasNoData() -> Bool {
        return categories.count == 0
    }

    func issueForIndexPath(indexPath: IndexPath) -> Issue {
        if showAll {
            return categories[indexPath.section].issues[indexPath.row]
        }
        return activeIssues[indexPath.row]
    }

    func titleForHeaderInSection(section: Int) -> String? {
        if showAll {
            return categories[section].name
        }
        else if (section == 0) {
            return R.string.localizable.whatsImportantTitle()
        }
        return nil
    }
}
