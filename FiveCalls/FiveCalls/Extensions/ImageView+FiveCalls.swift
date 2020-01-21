//
//  ImageView+FiveCalls.swift
//  FiveCalls
//
//  Created by Nick O'Neill on 1/21/20.
//  Copyright © 2020 5calls. All rights reserved.
//

import UIKit

extension UIImageView {
    static let imageCache = Cache<URL, Data>()
    
    func setImageFromURL(_ url: URL) {
        self.urlProperty = url
        
        if let imageData = UIImageView.imageCache.value(forKey: url),
            let image = UIImage(data: imageData) {
            DispatchQueue.main.async {
                self.image = image
            }
            return
        }
        
        URLSession.shared.dataTask(with: url) { (data, response, error) in
            guard let data = data, error == nil else { return }
            guard let image = UIImage(data: data) else { return }

            UIImageView.imageCache.insert(data, forKey: url)

            // make sure the url is still the same on this object from when we requested it
            guard url == self.urlProperty else { print("not the right thing"); return }
            
            DispatchQueue.main.async {
                self.image = image
            }
        }.resume()
    }
}

extension UIImageView {
    private struct AssociatedKey {
        static var imageURLExtension = "imageURLExtension"
    }
    
    var urlProperty: URL {
        get {
            return objc_getAssociatedObject(self, &AssociatedKey.imageURLExtension) as! URL
        }
        set {
            objc_setAssociatedObject(self, &AssociatedKey.imageURLExtension, newValue, objc_AssociationPolicy.OBJC_ASSOCIATION_RETAIN_NONATOMIC)
        }
    }
}

// Just Enough Cache, a subset of Sundell's cache: https://www.swiftbysundell.com/articles/caching-in-swift/
final class Cache<Key: Hashable, Value> {
    private let wrapped = NSCache<WrappedKey, Entry>()
   
    func insert(_ value: Value, forKey key: Key) {
        let entry = Entry(value: value)
        wrapped.setObject(entry, forKey: WrappedKey(key))
    }

    func value(forKey key: Key) -> Value? {
        let entry = wrapped.object(forKey: WrappedKey(key))
        return entry?.value
    }
    
    final class WrappedKey: NSObject {
        let key: Key

        init(_ key: Key) { self.key = key }

        override var hash: Int { return key.hashValue }

        override func isEqual(_ object: Any?) -> Bool {
            guard let value = object as? WrappedKey else {
                return false
            }

            return value.key == key
        }
    }
    
    final class Entry {
        let value: Value

        init(value: Value) {
            self.value = value
        }
    }
}
