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
        image = defaultImage
        currentTask?.cancel()
        currentTask = session.dataTask(with: url, completionHandler: { (data, response, error) in
            if let e = error as? NSError {
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
