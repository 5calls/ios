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
struct Category : Decodable {
    let name: String
}

extension Category : Equatable, Hashable, Comparable {
    static func < (lhs: Category, rhs: Category) -> Bool {
        return lhs.name < rhs.name
    }
}
