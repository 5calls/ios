//
//  ReportOutcomeOperation.swift
//  FiveCalls
//
//  Created by Ben Scheirman on 2/4/17.
//  Copyright © 2017 5calls. All rights reserved.
//

import Foundation

class ReportOutcomeOperation: BaseOperation, @unchecked Sendable {
    
    //Input properties
    var log: ContactLog
    var outcome: Outcome
    
    //Output properties
    var httpResponse: HTTPURLResponse?
    var error: Error?
    
    init(log: ContactLog, outcome: Outcome) {
        self.log = log
        self.outcome = outcome
    }
    
    var url: URL {
        return URL(string: "https://api.5calls.org/v1/report")!
    }

    override func execute() {
        let config = URLSessionConfiguration.default
        let session = URLSession(configuration: config)

        // rather than avoiding network calls during debug,
        // indicate they shouldn't be included in counts
        let via: String
        #if DEBUG
            via = "test"
        #else
            via = "ios"
        #endif

        var request = buildRequest(forURL: url)
        request.httpMethod = "POST"
        request.setValue("application/x-www-form-urlencoded", forHTTPHeaderField: "Content-Type")

        var queryParams = [
            "result": outcome.label,
            "contactid": log.contactId,
            "issueid": log.issueId,
            "phone": log.phone,
            "via": via,
            "callerid": AnalyticsManager.shared.callerID
        ]
        
        // Add calling group if it exists
        if let callingGroup = UserDefaults.standard.string(forKey: UserDefaultsKey.callingGroup.rawValue),
           !callingGroup.isEmpty {
            queryParams["group"] = callingGroup
        }
        
        let query = queryParams.map { "\($0)=\($1)" }.joined(separator: "&")
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
                    var logs = ContactLogs.load()
                    logs.markReported(self.log)
                    logs.save()
                }
            }
            self.finish()
        }
        task.resume()
    }
}
