//
//  Validatable.swift
//  R.swift.Library
//
//  Created by Mathijs Kadijk on 17-12-15.
//  From: https://github.com/mac-cain13/R.swift.Library
//  License: MIT License
//

import Foundation

/// Error thrown during validation
public struct ValidationError: Error, CustomStringConvertible {
  /// Human readable description
  public let description: String

  public init(description: String) {
    self.description = description
  }
}

public protocol Validatable {
  /**
   Validates this entity and throws if it encounters a invalid situation, a validatable should also validate it sub-validatables if it has any.

   - throws: If there the configuration error a ValidationError is thrown
   */
  static func validate() throws
}

extension Validatable {
  /**
   Validates this entity and asserts if it encounters a invalid situation, a validatable should also validate it sub-validatables if it has any. In -O builds (the default for Xcode's Release configuration), validation is not evaluated, and there are no effects.
   */
  @available(*, deprecated, message: "Use validate() instead, preferably from a testcase.")
  public static func assertValid() {
    assert( theRealAssert() )
  }

  fileprivate static func theRealAssert() -> Bool {
    do {
      try validate()
    } catch {
      assertionFailure("Validation of \(type(of: self)) failed with error: \(error)")
    }

    return true
  }
}
