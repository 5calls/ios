//
//  FetchCallsOperation.swift
//  FiveCalls
//
//  Created by Ben Scheirman on 1/30/17.
//  Copyright © 2017 5calls. All rights reserved.
//

import Foundation

class FetchStatsOperation: BaseOperation, @unchecked Sendable {
    
    var numberOfCalls: Int?
    var numberOfIssueCalls: Int?
    var donateOn: Bool?
    var issueID: String?
    var httpResponse: HTTPURLResponse?
    var error: Error?
    
    init(config: URLSessionConfiguration? = nil) {
        super.init()
        
        if let config {
            self.session = URLSession(configuration: config)
        }
    }
    
    var url: URL {
        var urlComponents = URLComponents(url: URL(string: "https://api.5calls.org/v1/report")!, resolvingAgainstBaseURL: false)!
        var queryItems: [URLQueryItem] = []
        
        if let issueID = self.issueID {
            queryItems.append(URLQueryItem(name: "issueID", value: issueID))
        }
        
        // Add calling group if it exists
        if let callingGroup = UserDefaults.standard.string(forKey: UserDefaultsKey.callingGroup.rawValue),
           !callingGroup.isEmpty {
            queryItems.append(URLQueryItem(name: "group", value: callingGroup))
        }
        
        if !queryItems.isEmpty {
            urlComponents.queryItems = queryItems
        }
        
        return urlComponents.url!
    }

    override func execute() {
        let request = buildRequest(forURL: url)
        
        let task = session.dataTask(with: request) { (data, response, error) in
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
                
        if let count = json["count"] as? Int {
            self.numberOfCalls = count
        } else if let countString = json["count"] as? String {
            if let number = NumberFormatter().number(from: countString) {
                self.numberOfCalls = number.intValue
            }
        }
        
        if let issueCount = json["issueCount"] as? Int {
            self.numberOfIssueCalls = issueCount
        }
        
        if let donateOn = json["donateOn"] as? Bool {
            self.donateOn = donateOn
        }
    }
}
