//
//  ReportUserStatsOperation.swift
//  FiveCalls
//
//  Created by Mel Stanley on 1/31/18.
//  Copyright © 2018 5calls. All rights reserved.
//

import Foundation

class ReportUserStatsOperation : BaseOperation {
    
    var httpResponse: HTTPURLResponse?
    var error: Error?
    var logs: ContactLogs
    
    init(logs: ContactLogs) {
        self.logs = logs
    }

    override func execute() {
        
        // We'll need the user's access token to authenticate the request
        SessionManager.shared.credentialsManager.credentials {
            guard $0 == nil else {
                self.error = $0
                self.finish()
                return
            }
            
            let credentials = $1
            if let idToken = credentials?.idToken {
                
                let config = URLSessionConfiguration.default
                let session = URLSessionProvider.buildSession(configuration: config)
                let url = URL(string: "https://api.5calls.org/v1/users/stats")!
                var request = URLRequest(url: url)
                request.setValue("Bearer " + idToken, forHTTPHeaderField:"Authorization")
                request.setValue("application/json", forHTTPHeaderField: "Content-Type")
                request.httpMethod = "POST"
 
                var stats: [Dictionary<String,Any>] = []
                let unreportedLogs = self.logs.unreported()
                for entry in unreportedLogs {
                    stats.append([
                        "issueID": entry.issueId,
                        "contactID": entry.contactId,
                        "result": entry.outcome,
                        "time": String(Int(exactly: entry.date.timeIntervalSince1970) ?? 0)
                    ])
                }
                
                // The API expects our stats to be wrapped like this:
                // { stats: [ ... ] }
                let wrapper = [ "stats": stats ]
                
                request.httpBody = try! JSONSerialization.data(withJSONObject: wrapper, options: [])
                
                let task = session.dataTask(with: request) { (data, response, error) in
                    if let e = error {
                        self.error = e
                    } else {
                        self.httpResponse = response as? HTTPURLResponse
                        if let status = self.httpResponse?.statusCode, status >= 200, status <= 299 {
                            // Mark all unreported stats as reported, now that we've submitted them all
                            unreportedLogs.forEach() { log in
                                self.logs.markReported(log)
                            }
                            self.logs.save()
                        }
                    }
                    self.finish()
                }
                task.resume()
            }
        }
    }
    
}
