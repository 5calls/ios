//
//  FetchIssuesOperation.swift
//  FiveCalls
//
//  Created by Ben Scheirman on 1/31/17.
//  Copyright © 2017 5calls. All rights reserved.
//

import Foundation

class FetchIssuesOperation : BaseOperation {
    
    let location: UserLocation?
    
    // Output properties.
    // Once the job has finished consumers can check one or more of these for values.
    var httpResponse: HTTPURLResponse?
    var error: Error?
    var issuesList: IssuesList?

    init(location: UserLocation?) {
        self.location = location
    }
    
    lazy var sessionConfiguration = URLSessionConfiguration.default
    lazy var session: URLSession = {
        return URLSessionProvider.buildSession(configuration: self.sessionConfiguration)
    }()
    
    func buildIssuesURL() -> URL {
        var urlComponents = URLComponents()
        urlComponents.scheme = "https"
        urlComponents.host = "5calls.org"
        urlComponents.path = "/issues/"
        
        if let query = addressQueryString() {
            urlComponents.query = query
        }
        
        return urlComponents.url!
    }
    
    func addressQueryString() -> String? {
        guard let location = self.location,
              let value = location.locationValue
            else { return nil }
        
        return "address=\(value)"
    }
    
    override func execute() {
        let url = buildIssuesURL()

        let task = session.dataTask(with: url) { (data, response, error) in
            if let e = error {
                print("Error fetching issues: \(e.localizedDescription)")
            } else {
                let http = response as! HTTPURLResponse
                print("HTTP \(http.statusCode)")
                self.httpResponse = http
                if http.statusCode == 200 {
                    do {
                        try self.parseIssues(data: data!)
                        print("Returned \(self.issuesList!.issues.count) issues with normalized location: \(self.issuesList!.normalizedLocation)")
                    } catch let e {
                        print("Error parsing issues: \(e.localizedDescription)")
                    }
                } else {
                    print("Received HTTP \(http.statusCode)")
                }
            }
            
            self.finish()
        }
        
        
        print("Fetching issues... \(url)")
        task.resume()
    }
    
    private func parseIssues(data: Data) throws {
        let json = try JSONSerialization.jsonObject(with: data, options: []) as! JSONDictionary
        issuesList = IssuesList(dictionary: json)
    }
}
