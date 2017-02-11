//
//  RemoteImageView.swift
//  FiveCalls
//
//  Created by Ben Scheirman on 2/4/17.
//  Copyright © 2017 5calls. All rights reserved.
//

import UIKit

typealias RemoteImageCallback = (UIImage) -> Void

@IBDesignable
class RemoteImageView : UIImageView {
    
    @IBInspectable
    var defaultImage: UIImage?
    
    lazy var session: URLSession = {
        let session = URLSession(configuration: URLSessionConfiguration.default)
        return session
    }()
    
    var currentTask: URLSessionDataTask?
    private var currentImageURL: URL?
    
    func setRemoteImage(url: URL) {
        setRemoteImage(url: url) { image in
            self.image = image
        }
    }
    
    func setRemoteImage(url: URL, completion: @escaping RemoteImageCallback) {
        setRemoteImage(preferred: defaultImage, url: url, completion: completion)
    }

    func setRemoteImage(preferred preferredImage: UIImage?, url: URL, completion: @escaping RemoteImageCallback) {
        if let cachedImage = ImageCache.shared.image(forKey: url) {
            image = cachedImage
            return
        }
        
        image = preferredImage
        guard preferredImage == nil || preferredImage == defaultImage else {
            return completion(preferredImage!)
        }
        currentTask?.cancel()
        currentTask = session.dataTask(with: url, completionHandler: { (data, response, error) in
            guard self.currentTask!.state != .canceling else { return }
            
            if let e = error as NSError? {
                if e.domain == NSURLErrorDomain && e.code == NSURLErrorCancelled {
                    // ignore cancellation errors
                } else {
                    print("Error loading image: \(e.localizedDescription)")
                }
            } else {
                guard let http = response as? HTTPURLResponse else { return }

                if http.statusCode == 200 {
                    if let data = data, let image = UIImage(data: data) {
                        self.currentImageURL = url
                        ImageCache.shared.set(image: image, forKey: url)
                        DispatchQueue.main.async {
                            completion(image)
                        }
                    }
                } else {
                    print("HTTP \(http.statusCode) received for \(url)")
                }
            }
        })
        currentTask?.resume()
    }
}

private struct ImageCache {
    static var shared = ImageCache()
    
    private let cache: NSCache<NSString, UIImage>
    
    init() {
        cache = NSCache()
    }
    
    func image(forKey key:URL) -> UIImage? {
        return cache.object(forKey: key.absoluteString as NSString)
    }
    
    func set(image: UIImage, forKey key: URL) {
        cache.setObject(image, forKey: key.absoluteString as NSString)
    }
    
    
}
