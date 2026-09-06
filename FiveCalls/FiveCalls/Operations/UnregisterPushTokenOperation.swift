// Copyright 5calls. All rights reserved. See LICENSE for details.

import Foundation

/// Removes this device's APNs token from the 5calls API when someone turns
/// notifications off. The API only deletes tokens belonging to the calling
/// user, so this can't unsubscribe anybody else.
class UnregisterPushTokenOperation: BaseOperation, @unchecked Sendable {
    // Input properties
    var token: String

    // Output properties
    var httpResponse: HTTPURLResponse?
    var error: Error?

    init(token: String) {
        self.token = token
    }

    var url: URL {
        URL(string: "https://api.5calls.org/v1/push/register")!
    }

    private struct Body: Encodable {
        let token: String
    }

    override func execute() {
        var request = buildRequest(forURL: url)
        request.httpMethod = "DELETE"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")

        do {
            request.httpBody = try JSONEncoder().encode(Body(token: token))
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
                    print("push token removal failed with \(http.statusCode)")
                }
            }

            self.finish()
        }

        task.resume()
    }
}
