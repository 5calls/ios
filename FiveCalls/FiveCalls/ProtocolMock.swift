//
//  ProtocolMock.swift
//  FiveCallsUITests
//
//  Created by Nick O'Neill on 12/19/23.
//  Copyright © 2023 5calls. All rights reserved.
//

import Foundation

class ProtocolMock: URLProtocol {
    override class func canInit(with request: URLRequest) -> Bool {
        return true
    }
    
    override class func canonicalRequest(for request: URLRequest) -> URLRequest {
        return request
    }
    
    override func startLoading() {
        let key = "\(request.httpMethod!):\(request.url!.path)"

        if let fixturePath = ProcessInfo.processInfo.environment[key] ?? UserDefaults.standard.string(forKey: "mock-\(key)") {
            let responseData = loadJSONFixtureData(path: fixturePath)

            self.client?.urlProtocol(self, didLoad: responseData)
            self.client?.urlProtocol(self, didReceive: HTTPURLResponse(url: request.url!, statusCode: 200, httpVersion: nil, headerFields: nil)!, cacheStoragePolicy: .notAllowed)
        } else {
            self.client?.urlProtocol(self, didFailWithError: ProtocolMockError.noFixtureForRequest)
        }

        self.client?.urlProtocolDidFinishLoading(self)
    }

    override func stopLoading() { }

    private func loadJSONFixtureData(path: String) -> Data {
        guard FileManager.default.fileExists(atPath: path) else {
            fatalError("JSON Fixture not found at path: \(path)")
        }

        return try! Data(contentsOf: URL(fileURLWithPath: path))
    }
}

enum ProtocolMockError: Error {
    case noFixtureForRequest
}
