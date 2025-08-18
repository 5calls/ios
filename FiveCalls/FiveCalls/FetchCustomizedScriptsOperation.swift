//
//  FetchCustomizedScriptsOperation.swift
//  FiveCalls
//
//  Created by Samuel Ray on 8/18/25.
//  Copyright © 2025 5calls. All rights reserved.
//

import Foundation

class FetchCustomizedScriptsOperation: BaseOperation, @unchecked Sendable {
    
    // Input properties
    var issueID: Int
    var contactIDs: [String]
    var location: String
    var callerName: String?
    
    // Output properties
    var httpResponse: HTTPURLResponse?
    var error: Error?
    var scripts: [CustomizedContactScript]?
    
    init(issueID: Int, contactIDs: [String], location: String, callerName: String? = nil, config: URLSessionConfiguration? = nil) {
        self.issueID = issueID
        self.contactIDs = contactIDs
        self.location = location
        self.callerName = callerName
        
        super.init()
        if let config {
            self.session = URLSession(configuration: config)
        }
    }
    
    var url: URL {
        var urlComponents = URLComponents(string: "https://api.5calls.org/v1/issue/\(issueID)/script")!
        
        
        var queryItems: [URLQueryItem] = [
            URLQueryItem(name: "contact_ids", value: contactIDs.joined(separator: ",")),
            URLQueryItem(name: "location", value: location),
        ]
        
        if let callerName {
            queryItems.append(URLQueryItem(name: "name", value: callerName))
        }
        
        urlComponents.queryItems = queryItems
        return urlComponents.url!
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
                self.scripts = try parseScripts(data: data)
            } catch let e {
                print("Error parsing scripts: \(e.localizedDescription)")
            }
        } else {
            print("Received HTTP \(http.statusCode)")
        }
    }
    
    private func parseScripts(data: Data) throws -> [CustomizedContactScript] {
        let dict = try JSONDecoder().decode([String: String].self, from: data)
        return dict.map { CustomizedContactScript(id: $0.key, script: $0.value) }
    }
}
