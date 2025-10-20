// Copyright 5calls. All rights reserved. See LICENSE for details.

import Foundation
import UIKit

extension UILabel {
    // A variable to be used as a UIAppearance proxy to combine a font descriptor with the system provied font traits
    var substituteFontDescriptor: UIFontDescriptor {
        get { font.fontDescriptor }
        set {
            var symbolicTraits = font.fontDescriptor.symbolicTraits

            symbolicTraits.insert(newValue.symbolicTraits)

            if let descriptor = UIFontDescriptor(fontAttributes: newValue.fontAttributes).withSymbolicTraits(symbolicTraits) {
                font = UIFont(descriptor: descriptor, size: font.pointSize)
            } else {
                // Fixes issue with iOS 9 not getting the custom font but may lose traits this way
                font = UIFont(descriptor: newValue, size: font.pointSize)
            }
        }
    }
}
