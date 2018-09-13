//
//  FetchUserStatsOperation.swift
//  FiveCalls
//
//  Created by Mel Stanley on 1/31/18.
//  Copyright © 2018 5calls. All rights reserved.
//

import Foundation

class FetchUserStatsOperation : BaseOperation {
    
    class TokenExpiredError : Error { }
    
    var userStats: UserStats?
    var firstCallTime: Date?
    var httpResponse: HTTPURLResponse?
    var error: Error?
    
    private var retryCount = 0
    
    override func execute() {
        
        // We'll need the user's access token to authenticate the request
        SessionManager.shared.credentialsManager.credentials { error, creds in
            guard error == nil else {
                self.error = error
                self.finish()
                return
            }

            creds?.idToken.flatMap(self.fetchStats)
        }
    }
    
    private func fetchStats(withToken idToken: String) {
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
                guard let data = data else { return }
                
                switch http.statusCode {
                case 200:
                    do {
                        try self.parseResponse(data: data)
                    } catch let e as NSError {
                        // log an continue, not worth crashing over
                        print("Error parsing user stats: \(e.localizedDescription)")
                    }
                    self.finish()
                case 401:
                    if self.retryCount >= 2 {
                        self.error = TokenExpiredError()
                        self.finish()
                    } else {
                        self.retryCount += 1
                        self.refreshToken()
                    }
                    
                default:
                    print("Received HTTP \(http.statusCode) while fetching stats")
                    self.finish()
                }
            }
        }
        task.resume()
    }
    
    private func refreshToken() {
        print("Token is invalid or expired, try to refresh...")
        _ = SessionManager.shared.refreshToken().done { _ in
            self.execute()
        }
    }
    
    private func parseResponse(data: Data) throws {
        // We expect the response to look like this:
        // { stats: {
        //    "contact": 221,
        //    "voicemail": 158,
        //    "unavailable": 32
        //   },
        //   weeklyStreak: 10,
        //   firstCallTime: 1487959763
        // }
        guard let wrapper = try JSONSerialization.jsonObject(with: data, options: []) as? [String:AnyObject] else {
            print("Couldn't parse JSON data.")
            return
        }

        if let statsDictionary = wrapper as? JSONDictionary {
            userStats = UserStats(dictionary: statsDictionary)
        }

        if let firstCallUnixSeconds = wrapper["firstCallTime"] as? Double {
            firstCallTime = Date(timeIntervalSince1970: firstCallUnixSeconds)
        }
    }
}

