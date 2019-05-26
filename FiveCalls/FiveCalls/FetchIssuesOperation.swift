//
//  FetchIssuesOperation.swift
//  FiveCalls
//
//  Created by Ben Scheirman on 1/31/17.
//  Copyright © 2017 5calls. All rights reserved.
//

import Foundation

class FetchIssuesOperation : BaseOperation {

    // Output properties.
    // Once the job has finished consumers can check one or more of these for values.
    var httpResponse: HTTPURLResponse?
    var error: Error?
    var issuesList: [Issue]?

    lazy var sessionConfiguration = URLSessionConfiguration.default
    lazy var session: URLSession = {
        return URLSessionProvider.buildSession(configuration: self.sessionConfiguration)
    }()
    
    func buildIssuesURL() -> URL {
        return URL(string: "https://api.5calls.org/v1/issues")!
    }

    override func execute() {
        let url = buildIssuesURL()
        let task = session.dataTask(with: url) { (data, response, error) in
            if let e = error {
                print("Error fetching issues: \(e.localizedDescription)")
                self.error = e
            } else {
                self.handleResponse(data: data, response: response)
            }
            
            self.finish()
        }
        
        
        print("Fetching issues... \(url)")

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
        
        print("HTTP \(http.statusCode)")
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
