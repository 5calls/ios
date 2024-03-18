//
//  FetchMessagesOperation.swift
//  FiveCalls
//
//  Created by Nick O'Neill on 3/17/24.
//  Copyright © 2024 5calls. All rights reserved.
//

import Foundation

class FetchMessagesOperation: BaseOperation {
    var district: String
    
    var error: Error?
    var httpResponse: HTTPURLResponse?
    var messages: [InboxMessage]?

    init(district: String, config: URLSessionConfiguration? = nil) {
        self.district = district

        super.init()
        if let config {
            self.session = URLSession(configuration: config)
        }
    }
    
    var url: URL {
        var components = URLComponents(string: "https://api.5calls.org/v1/users/inbox")
        let districtQueryParam = URLQueryItem(name: "district", value: district)
        components?.queryItems = [districtQueryParam]
        return components!.url!
    }
    
    override func execute() {
        let request = buildRequest(forURL: url)
        
        let task = session.dataTask(with: request) { data, response, error in
            if let e = error {
               self.error = e
            } else {
                self.handleResponse(data: data, response: response)
            }
            self.finish()
        }
        task.resume()
    }
    
    private func handleResponse(data: Data?, response: URLResponse?) {
        guard let data = data else { return }
        guard let http = response as? HTTPURLResponse else { return }
        
        httpResponse = http
        
        if http.statusCode == 200 {
            do {
                self.messages = try parseMessages(data: data)
            } catch let e {
                print("Error parsing messages: \(e.localizedDescription)")
            }
        } else {
            print("Received HTTP \(http.statusCode)")
        }
    }
    
    private func parseMessages(data: Data) throws -> [InboxMessage] {
        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .iso8601
        let messages = try decoder.decode([InboxMessage].self, from: data)

        return messages
    }
}
