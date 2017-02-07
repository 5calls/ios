//
//  ReportOutcomeOperation.swift
//  FiveCalls
//
//  Created by Ben Scheirman on 2/4/17.
//  Copyright © 2017 5calls. All rights reserved.
//

import Foundation

class ReportOutcomeOperation : BaseOperation {
    
    //Input properties
    var log: ContactLog
    
    //Output properties
    var httpResponse: HTTPURLResponse?
    var error: Error?
    
    init(log: ContactLog) {
        self.log = log
    }
    
    override func execute() {
        let config = URLSessionConfiguration.default
        let session = URLSession(configuration: config)
        let url = URL(string: "https://5calls.org/report")!
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/x-www-form-urlencoded", forHTTPHeaderField: "Content-Type")
        let query = "result=\(log.outcome)&contactid=\(log.contactId)&issueid=\(log.issueId)&phone=\(log.phone)"
        guard let data = query.data(using: .utf8) else {
            print("error creating HTTP POST body")
            return
        }
        request.httpBody = data
        let task = session.dataTask(with: request) { (data, response, error) in
            if let e = error {
                self.error = e
            } else {
                let http = response as! HTTPURLResponse
                self.httpResponse = http
                if let _ = data, http.statusCode == 200 {
                    print("sent report successfully")
                }
            }
            self.finish()
        }
        task.resume()
    }
}
