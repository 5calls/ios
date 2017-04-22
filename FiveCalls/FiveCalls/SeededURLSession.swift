//
//  SeededURLSession.swift
//  FiveCalls
//
//  Created by Ben Scheirman on 2/13/17.
//  Copyright © 2017 5calls. All rights reserved.
//

import Foundation

typealias DataTaskCompletionHandler = (Data?, URLResponse?, Error?) -> Void

class SeededDataTask : URLSessionDataTask {
    private let request: URLRequest
    private let completionHandler: DataTaskCompletionHandler
    
    init(request: URLRequest, completionHandler: @escaping DataTaskCompletionHandler) {
        self.request =  request
        self.completionHandler = completionHandler
    }
    
    override func resume() {
        let key = "\(request.httpMethod!):\(request.url!.path)"
        if let fixturePath = ProcessInfo.processInfo.environment[key] {
            
            let jsonData = loadJSONFixtureData(path: fixturePath)
            let response = HTTPURLResponse(url: request.url!, statusCode: 200, httpVersion: nil, headerFields: nil)
            completionHandler(jsonData, response, nil)
            
        } else {
            fatalError("Fixture file not specified for \(request.url!)")
        }
    }
    
    private func loadJSONFixtureData(path: String) -> Data {
        guard FileManager.default.fileExists(atPath: path) else {
            fatalError("JSON Fixture not found at path: \(path)")
        }
        
        return try! Data(contentsOf: URL(fileURLWithPath: path))
    }
}

class SeededURLSession : URLSession {
    override func dataTask(with url: URL, completionHandler: @escaping (Data?, URLResponse?, Error?) -> Void) -> URLSessionDataTask {
        let request = URLRequest(url: url)
        return dataTask(with: request, completionHandler: completionHandler)
    }
    
    override func dataTask(with request: URLRequest, completionHandler: @escaping (Data?, URLResponse?, Error?) -> Void) -> URLSessionDataTask {
        return SeededDataTask(request: request, completionHandler: completionHandler)
    }
}
