//
//  Error+Offline.swift
//  FiveCalls
//
//  Created by Ben Scheirman on 1/9/19.
//  Copyright © 2019 5calls. All rights reserved.
//

import Foundation

extension Error {
    func isOfflineError() -> Bool {
        let e = self as NSError
        guard e.domain == NSURLErrorDomain else { return false }
        
        return e.code == NSURLErrorNetworkConnectionLost ||
            e.code == NSURLErrorNotConnectedToInternet ||
            e.code == NSURLErrorSecureConnectionFailed
    }
}

