//
//  FetchIssuesOperation.swift
//  FiveCalls
//
//  Created by Ben Scheirman on 1/31/17.
//  Copyright © 2017 5calls. All rights reserved.
//

import Foundation

class FetchIssuesOperation : BaseOperation {
    let zipCode: String?
    
    var httpResponse: HTTPURLResponse?
    
    var error: Error?

    var issuesList: IssuesList?
    
    init(zipCode: String?) {
        self.zipCode = zipCode
    }
    
    lazy var sessionConfiguration = URLSessionConfiguration.default
    lazy var session: URLSession = { return URLSession(configuration: self.sessionConfiguration) }()
    
    override func execute() {
        let url = URL(string: "https://5calls.org/issues/")!
        let task = session.dataTask(with: url) { (data, response, error) in
            if let e = error {
                print("Error fetching issues: \(e.localizedDescription)")
            } else {
                let http = response as! HTTPURLResponse
                self.httpResponse = http
                if http.statusCode == 200 {
                    do {
                        try self.parseIssues(data: data!)
                    } catch let e {
                        print("Error parsing issues: \(e.localizedDescription)")
                    }
                } else {
                    print("Received HTTP \(http.statusCode)")
                }
            }
            
            self.finish()
        }
        task.resume()
    }
    
    private func parseIssues(data: Data) throws {
        let json = try JSONSerialization.jsonObject(with: data, options: []) as! JSONDictionary
        issuesList = IssuesList(dictionary: json)
    }
}
