//
//  FetchCallsOperation.swift
//  FiveCalls
//
//  Created by Ben Scheirman on 1/30/17.
//  Copyright © 2017 5calls. All rights reserved.
//

import Foundation

class FetchStatsOperation : BaseOperation {
    
    var numberOfCalls: Int?
    var numberOfIssueCalls: Int?
    var issueID: String?
    var httpResponse: HTTPURLResponse?
    var error: Error?
    
    override func execute() {
        let config = URLSessionConfiguration.default
        let session = URLSessionProvider.buildSession(configuration: config)
        var urlComp = URLComponents(url: URL(string: "https://5calls.org/report")!, resolvingAgainstBaseURL: false)!
        if let issueID = self.issueID {
            let issueIDQuery = URLQueryItem(name: "issueID", value: issueID)
            urlComp.queryItems = [issueIDQuery]
        }
        
        let task = session.dataTask(with: urlComp.url!) { (data, response, error) in
            
            if let e = error {
                self.error = e
            } else {
                let http = response as! HTTPURLResponse
                self.httpResponse = http
                if let data = data, http.statusCode == 200 {
                    do {
                        try self.parseResponse(data: data)
                    } catch let e as NSError {
                        // log an continue, not worth crashing over
                        print("Error parsing count: \(e.localizedDescription)")
                    }
                }
            }
            
            DispatchQueue.main.async {
                self.finish()
            }
        }
        task.resume()
    }
    
    private func parseResponse(data: Data) throws {
        guard let json = try JSONSerialization.jsonObject(with: data, options: []) as? [String:AnyObject] else {
            print("Couldn't parse JSON data.")
            return
        }
        
        print("got back json \(json)")
        
        if let count = json["count"] as? Int {
            numberOfCalls = count
        } else if let countString = json["count"] as? String {
            if let number = NumberFormatter().number(from: countString) {
                numberOfCalls = number.intValue
            }
        }
        
        if let issueCount = json["issueCount"] as? Int {
            numberOfIssueCalls = issueCount
        }
    }
}
