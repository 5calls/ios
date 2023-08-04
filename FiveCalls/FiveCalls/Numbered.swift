//
//  Numbered.swift
//  FiveCalls
//
//  Created by Nick O'Neill on 8/3/23.
//  Copyright © 2023 5calls. All rights reserved.
//

import Foundation

// from Ole Begemann
// https://oleb.net/2020/foreach-enumerated/
// we use this to get an index as well as a value in a ForEach loop in SwiftUI

@dynamicMemberLookup
struct Numbered<Element> {
  var number: Int
  var element: Element

  subscript<T>(dynamicMember keyPath: WritableKeyPath<Element, T>) -> T {
    get { element[keyPath: keyPath] }
    set { element[keyPath: keyPath] = newValue }
  }
}

extension Numbered: Identifiable where Element: Identifiable {
  var id: Element.ID { element.id }
}

extension Sequence {
  func numbered(startingAt start: Int = 0) -> [Numbered<Element>] {
    zip(start..., self)
      .map { Numbered(number: $0.0, element: $0.1) }
  }
}
