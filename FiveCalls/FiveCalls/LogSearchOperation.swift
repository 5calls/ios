//
//  LogSearchOperation.swift
//  FiveCalls
//
//  Created by Nick O'Neill on 6/22/25.
//  Copyright © 2025 5calls. All rights reserved.
//

import Foundation

class LogSearchOperation: BaseOperation, @unchecked Sendable {
    var searchQuery: String
    
    var httpResponse: HTTPURLResponse?
    var error: Error?
    
    init(searchQuery: String) {
        self.searchQuery = searchQuery
    }
    
    var url: URL {
        return URL(string: "https://api.5calls.org/v1/users/search")!
    }

    override func execute() {
        let config = URLSessionConfiguration.default
        let session = URLSession(configuration: config)

        var request = buildRequest(forURL: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")

        let requestBody: [String: Any] = [
            "query": searchQuery
        ]
                
        do {
            let jsonData = try JSONSerialization.data(withJSONObject: requestBody, options: [])
            request.httpBody = jsonData
        } catch {
            print("Error creating JSON body for search log: \(error)")
            self.error = error
            self.finish()
            return
        }
        
        let task = session.dataTask(with: request) { (data, response, error) in
            if let e = error {
                self.error = e
                print("Error logging search query: \(e)")
            } else {
                let http = response as! HTTPURLResponse
                self.httpResponse = http
                if http.statusCode == 200 {
                    print("Search query logged successfully")
                } else {
                    print("Search query logging failed with status: \(http.statusCode)")
                }
            }
            self.finish()
        }
        task.resume()
    }
}
