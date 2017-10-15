//
//  Category.swift
//  FiveCalls
//
//  Created by Indrajit on 10/13/17.
//  Copyright © 2017 5calls. All rights reserved.
//

/*
 "categories": [{
          "name": "Woman's Rights"
      }],
 */

// Category to which an issue may belong.
struct Category {
    let name: String
    let issues: [Issue]

    init(name: String) {
        self.name = name
        issues = [];
    }

    init(name: String, issues: [Issue]) {
        self.name = name
        self.issues = issues;
    }
}

extension Category : JSONSerializable {
    init?(dictionary: JSONDictionary) {
        guard let name = dictionary["name"] as? String
            else {
                print("Unable to parse JSON as Category: \(dictionary)")
                return nil
        }

        self.init(name: name)
    }
}

extension Category: Equatable {
    static func == (lhs: Category, rhs: Category) -> Bool {
        return lhs.name == rhs.name
    }
}

extension Category: Hashable {
    var hashValue: Int {
        return name.hashValue
    }
}

extension Category: Comparable {
    static func < (lhs: Category, rhs: Category) -> Bool {
        let uncategorized = R.string.localizable.uncategorizedIssues()
        // Uncategorized issue should always be the 'last' element of the group
        if lhs.name == uncategorized && rhs.name != uncategorized  {
            return false
        }
        else if lhs.name != uncategorized && rhs.name == uncategorized  {
            return true
        }
        return lhs.name < rhs.name
    }
}
