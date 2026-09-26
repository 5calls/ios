// Copyright 5calls. All rights reserved. See LICENSE for details.

import Foundation

/// Tells the 5calls API about this device's APNs token so it can send us
/// notifications directly. The API upserts on the token, so calling this on
/// every launch is cheap and is how a token stays fresh.
class RegisterPushTokenOperation: BaseOperation, @unchecked Sendable {
    // Input properties
    var token: String
    var district: String?

    // Output properties
    var httpResponse: HTTPURLResponse?
    var error: Error?

    init(token: String, district: String?) {
        self.token = token
        self.district = district
    }

    var url: URL {
        URL(string: "https://api.5calls.org/v1/push/register")!
    }

    private struct Body: Encodable {
        let token: String
        let platform: String
        let district: String
    }

    override func execute() {
        var request = buildRequest(forURL: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")

        // the API drops a district it can't parse rather than rejecting the
        // registration, so sending an empty one is fine
        let body = Body(token: token, platform: "ios", district: district ?? "")

        do {
            request.httpBody = try JSONEncoder().encode(body)
        } catch {
            self.error = error
            finish()
            return
        }

        let task = session.dataTask(with: request) { _, response, error in
            if let error {
                self.error = error
            } else if let http = response as? HTTPURLResponse {
                self.httpResponse = http
                if http.statusCode != 200 {
                    print("push token registration failed with \(http.statusCode)")
                }
            }

            self.finish()
        }

        task.resume()
    }
}
