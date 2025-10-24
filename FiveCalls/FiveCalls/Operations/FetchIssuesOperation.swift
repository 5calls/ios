// Copyright 5calls. All rights reserved. See LICENSE for details.

import Foundation

class FetchIssuesOperation: BaseOperation, @unchecked Sendable {
    // Output properties.
    // Once the job has finished consumers can check one or more of these for values.
    var httpResponse: HTTPURLResponse?
    var error: Error?
    var issuesList: [Issue]?
    var stateAbbr: String?

    init(stateAbbr: String? = nil, config: URLSessionConfiguration? = nil) {
        self.stateAbbr = stateAbbr
        super.init()

        if let config {
            session = URLSession(configuration: config)
        }
    }

    var url: URL {
        var urlComponents = URLComponents(string: "https://api.5calls.org/v1/issues")!
        var queryItems: [URLQueryItem] = []

        // Add state parameter if available
        if let stateAbbr, !stateAbbr.isEmpty {
            queryItems.append(URLQueryItem(name: "state", value: stateAbbr))
        }

        // Add calling group if it exists
        if let callingGroup = UserDefaults.standard.string(forKey: UserDefaultsKey.callingGroup.rawValue),
           !callingGroup.isEmpty
        {
            queryItems.append(URLQueryItem(name: "group", value: callingGroup))
        }

        urlComponents.queryItems = queryItems
        return urlComponents.url!
    }

    override func execute() {
        let request = buildRequest(forURL: url)

        let task = session.dataTask(with: request) { data, response, error in
            if let e = error {
                print("Error fetching issues: \(e.localizedDescription)")
                self.error = e
            } else {
                self.handleResponse(data: data, response: response)
            }

            self.finish()
        }

        task.resume()
    }

    private func handleResponse(data: Data?, response: URLResponse?) {
        guard let data else {
            print("data was nil, ignoring response")
            return
        }
        guard let http = response as? HTTPURLResponse else {
            print("Response was not an HTTP URL response (or was nil), ignoring")
            return
        }

        httpResponse = http

        if http.statusCode == 200 {
            do {
                issuesList = try parseIssues(data: data)
            } catch let e {
                print("Error parsing issues: \(e.localizedDescription)")
            }
        } else {
            print("Received HTTP \(http.statusCode)")
        }
    }

    private func parseIssues(data: Data) throws -> [Issue] {
        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .iso8601
        return try decoder.decode([Issue].self, from: data)
    }
}
