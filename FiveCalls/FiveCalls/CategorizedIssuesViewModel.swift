// Copyright 5calls. All rights reserved. See LICENSE for details.

import Foundation

class CategorizedIssuesViewModel: Identifiable {
    let category: Category
    var issues: [Issue]

    var name: String {
        category.name
    }

    var id: Int {
        name.hashValue
    }

    init(category: Category, issues: [Issue]) {
        self.category = category
        self.issues = issues
    }
}

extension CategorizedIssuesViewModel: Hashable {
    static func == (lhs: CategorizedIssuesViewModel, rhs: CategorizedIssuesViewModel) -> Bool {
        lhs.category == rhs.category
    }

    func hash(into hasher: inout Hasher) {
        hasher.combine(category)
    }
}
