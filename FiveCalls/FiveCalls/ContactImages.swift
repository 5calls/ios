//
//  ContactImages.swift
//  FiveCalls
//
//  Created by Nick O'Neill on 8/3/23.
//  Copyright © 2023 5calls. All rights reserved.
//

import UIKit

private let defaultImageCache = NSCache<NSString, UIImage>()

func defaultImage(forContact contact: Contact) -> UIImage {
    if let cachedImage = defaultImageCache.object(forKey: NSString(string: contact.id)) {
        return cachedImage
    }
    
    var finalImage: UIImage
    UIGraphicsBeginImageContext(CGSize(width: 256, height: 256))
    
    let colorIndex = abs(Int(contact.id.hash)) % sampleColors.count
    sampleColors[colorIndex].setFill()
    
    let context = UIGraphicsGetCurrentContext()
    context?.fill([CGRect(origin: .zero, size: CGSize(width: 256, height: 256))])

    finalImage = UIGraphicsGetImageFromCurrentImageContext()!
    UIGraphicsEndImageContext()
    
    defaultImageCache.setObject(finalImage, forKey: NSString(string: contact.id))
    
    return finalImage
}

private let sampleColors: [UIColor] = [
    "#CAD2C5",
    "#84A98C",
    "#52796F",
    "#354F52",
    "#2F3E46",
    "#25283D",
    "#8F3985",
    "#A675A1",
    "#CEA2AC",
    "#EFD9CE",
].map(hexStringToColor)

func hexStringToColor(hexString: String) -> UIColor {
    let scanner = Scanner(string: String(hexString.dropFirst()))
    var hexNumber: UInt64 = 0
    scanner.scanHexInt64(&hexNumber)
    let r = CGFloat((hexNumber & 0xff0000) >> 16) / 255
    let g = CGFloat((hexNumber & 0x00ff00) >> 8) / 255
    let b = CGFloat(hexNumber & 0x0000ff) / 255
    return UIColor(red: r, green: g, blue: b, alpha: 1.0)
}
