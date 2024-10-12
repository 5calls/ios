//
//  FetchIssuesOperation.swift
//  FiveCalls
//
//  Created by Ben Scheirman on 1/31/17.
//  Copyright © 2017 5calls. All rights reserved.
//

import Foundation

class FetchIssuesOperation: BaseOperation, @unchecked Sendable {

    // Output properties.
    // Once the job has finished consumers can check one or more of these for values.
    var httpResponse: HTTPURLResponse?
    var error: Error?
    var issuesList: [Issue]?
    
    init(config: URLSessionConfiguration? = nil) {
        super.init()
        
        if let config {
            self.session = URLSession(configuration: config)
        }
    }
    
    var url: URL {
        return URL(string: "https://api.5calls.org/v1/issues?includeHidden=true")!
    }

    override func execute() {
        let request = buildRequest(forURL: url)
        
        let task = session.dataTask(with: request) { (data, response, error) in
            if let e = error {
                print("Error fetching issues: \(e.localizedDescription)")
                self.error = e
            } else {
                self.handleResponse(data: data, response: response)
            }
            
            self.finish()
        }

        task.resume()
    }
    
    private func handleResponse(data: Data?, response: URLResponse?) {
        guard let data = data else {
            print("data was nil, ignoring response")
            return
        }
        guard let http = response as? HTTPURLResponse else {
            print("Response was not an HTTP URL response (or was nil), ignoring")
            return
        }
        
        httpResponse = http
        
        if http.statusCode == 200 {
            do {
                self.issuesList = try parseIssues(data: data)
            } catch let e {
                print("Error parsing issues: \(e.localizedDescription)")
            }
        } else {
            print("Received HTTP \(http.statusCode)")
        }
    }
    
    private func parseIssues(data: Data) throws -> [Issue] {
        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .iso8601
        return try decoder.decode([Issue].self, from: data)
    }
}
