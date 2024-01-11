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
    
    var url: URL {
        return URL(string: "https://api.5calls.org/v1/users/stats")!
    }
    
    override func execute() {
        let config = URLSessionConfiguration.default
        let session = URLSession(configuration: config)

        let request = buildRequest(forURL: url)
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
                    
                default:
                    print("Received HTTP \(http.statusCode) while fetching stats")
                    self.finish()
                }
            }
        }
        task.resume()
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
        guard let statsDictionary = try JSONSerialization.jsonObject(with: data, options: []) as? [String:AnyObject] else {
            print("Couldn't parse JSON data.")
            return
        }

        userStats = UserStats(dictionary: statsDictionary as JSONDictionary)

        if let firstCallUnixSeconds = statsDictionary["firstCallTime"] as? Double {
            firstCallTime = Date(timeIntervalSince1970: firstCallUnixSeconds)
        }
    }
}

