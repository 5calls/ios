//
//  ProtocolMock.swift
//  FiveCallsUITests
//
//  Created by Nick O'Neill on 12/19/23.
//  Copyright © 2023 5calls. All rights reserved.
//

import Foundation

class ProtocolMock: URLProtocol {
    let testData: [URL: Data]

    override init(request: URLRequest, cachedResponse: CachedURLResponse?, client: URLProtocolClient?) {
        let bundle = Bundle(for: ProtocolMock.self)
        
        testData = [
            URL(string: "https://api.5calls.org/v1/issues")!: try! Data(contentsOf: URL(fileURLWithPath: bundle.path(forResource: "GET-v1-issues", ofType: "json")!)),
            URL(string: "https://api.5calls.org/v1/reps")!: try! Data(contentsOf: URL(fileURLWithPath: bundle.path(forResource: "GET-v1-reps", ofType: "json")!)),
            URL(string: "https://api.5calls.org/v1/report")!: try! Data(contentsOf: URL(fileURLWithPath: bundle.path(forResource: "GET-v1-report", ofType: "json")!))
        ]

        super.init(request: request, cachedResponse: cachedResponse, client: client)
    }
    
    override class func canInit(with request: URLRequest) -> Bool {
        return true
    }
    
    override class func canonicalRequest(for request: URLRequest) -> URLRequest {
        return request
    }
    
    override func startLoading() {
        if let url = request.url {
            // remove query strings from urls because they shouldn't change the shape of the response
            var trimmedURL = URLComponents(url: url, resolvingAgainstBaseURL: false)!
            trimmedURL.query = nil
            if let data = testData[trimmedURL.url!] {
                self.client?.urlProtocol(self, didLoad: data)
            }
            
            self.client?.urlProtocol(self, didReceive: HTTPURLResponse(url: url, statusCode: 200, httpVersion: nil, headerFields: nil)!, cacheStoragePolicy: .notAllowed)
        }

        self.client?.urlProtocolDidFinishLoading(self)
    }

    override func stopLoading() { }
}
