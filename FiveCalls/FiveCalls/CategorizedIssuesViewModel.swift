//
//  CategorizedIssuesViewModel.swift
//  FiveCalls
//
//  Created by Ben Scheirman on 1/29/19.
//  Copyright © 2019 5calls. All rights reserved.
//

import Foundation

class CategorizedIssuesViewModel {
    let category: Category
    var issues: [Issue]

    var name: String {
        return category.name
    }

    init(category: Category, issues: [Issue]) {
        self.category = category
        self.issues = issues
    }
}

extension CategorizedIssuesViewModel : Hashable {
    static func == (lhs: CategorizedIssuesViewModel, rhs: CategorizedIssuesViewModel) -> Bool {
        return lhs.category == rhs.category
    }
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(self.category)
    }
}
