//
//  RResource+Extension.swift
//  FiveCalls
//
//  Created by Christopher Selin on 9/15/23.
//  Copyright © 2023 5calls. All rights reserved.
//
//  Source: https://medium.com/tbc-engineering/r-swift-swiftui-802acb5560ff

import SwiftUI
import Rswift

// MARK: - ImageResource
extension ImageResource {
    var image: Image {
        Image(name)
    }
}

// MARK: - ColorResource
extension ColorResource {
    var color: Color {
        Color(name)
    }
}

// MARK: - FontResource
extension FontResource {
    func font(size: CGFloat) -> Font {
        Font.custom(fontName, size: size)
    }
}
