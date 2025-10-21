// Copyright 5calls. All rights reserved. See LICENSE for details.

import Foundation

class ProtocolMock: URLProtocol {
    override class func canInit(with _: URLRequest) -> Bool {
        true
    }

    override class func canonicalRequest(for request: URLRequest) -> URLRequest {
        request
    }

    override func startLoading() {
        let key = "\(request.httpMethod!):\(request.url!.path)"

        if let fixturePath = ProcessInfo.processInfo.environment[key] ?? UserDefaults.standard.string(forKey: "mock-\(key)") {
            let responseData = loadJSONFixtureData(path: fixturePath)

            client?.urlProtocol(self, didLoad: responseData)
            client?.urlProtocol(self, didReceive: HTTPURLResponse(url: request.url!, statusCode: 200, httpVersion: nil, headerFields: nil)!, cacheStoragePolicy: .notAllowed)
        } else {
            client?.urlProtocol(self, didFailWithError: ProtocolMockError.noFixtureForRequest)
        }

        client?.urlProtocolDidFinishLoading(self)
    }

    override func stopLoading() {}

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
