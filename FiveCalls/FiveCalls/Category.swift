// Copyright 5calls. All rights reserved. See LICENSE for details.

/*
 "categories": [{
          "name": "Woman's Rights"
      }],
 */

// Category to which an issue may belong.
struct Category: Decodable {
    let name: String
}

extension Category: Hashable, Comparable {
    static func < (lhs: Category, rhs: Category) -> Bool {
        lhs.name < rhs.name
    }
}
