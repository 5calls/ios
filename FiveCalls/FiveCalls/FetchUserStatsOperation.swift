//
//  FetchUserStatsOperation.swift
//  FiveCalls
//
//  Created by Mel Stanley on 1/31/18.
//  Copyright © 2018 5calls. All rights reserved.
//

import Foundation

class FetchUserStatsOperation : BaseOperation {
    
    var userStats: UserStats?
    var httpResponse: HTTPURLResponse?
    var error: Error?
    
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
                                print("Error parsing user stats: \(e.localizedDescription)")
                            }
                        }
                    }
                    
                    self.finish()
                }
                task.resume()
            }
        }
    }
    
    private func parseResponse(data: Data) throws {
        // We expect the response to look like this:
        // { stats: {
        //    "contact": 221,
        //    "voicemail": 158,
        //    "unavailable": 32
        // } }
        guard let wrapper = try JSONSerialization.jsonObject(with: data, options: []) as? [String:AnyObject] else {
            print("Couldn't parse JSON data.")
            return
        }

        if let stats = wrapper["stats"] as? JSONDictionary {
            userStats = UserStats(contact: stats["contact"] as? Int,
                                  voicemail: stats["voicemail"] as? Int,
                                  unavailable: stats["unavailable"] as? Int)
        }
    }
}

