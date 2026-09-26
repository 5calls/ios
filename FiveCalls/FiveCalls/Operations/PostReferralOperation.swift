// Copyright 5calls. All rights reserved. See LICENSE for details.

import Foundation

class PostReferralOperation: BaseOperation, @unchecked Sendable {
    var ref: String
    var path: String

    var httpResponse: HTTPURLResponse?
    var error: Error?

    init(ref: String, path: String) {
        self.ref = ref
        self.path = path
    }

    /// Builds a referral post for a universal link with a non-empty `ref`
    /// query item, like the web does, or nil if there's nothing to report.
    static func forLink(_ url: URL) -> PostReferralOperation? {
        guard let components = URLComponents(url: url, resolvingAgainstBaseURL: false),
              let ref = components.queryItems?.first(where: { $0.name == "ref" })?.value,
              !ref.isEmpty else {
            return nil
        }

        return PostReferralOperation(ref: ref, path: url.path)
    }

    var url: URL {
        URL(string: "https://api.5calls.org/v1/users/refs")!
    }

    override func execute() {
        var request = buildRequest(forURL: url)
        request.httpMethod = "POST"
        request.setValue("application/x-www-form-urlencoded", forHTTPHeaderField: "Content-Type")

        var components = URLComponents()
        components.queryItems = [
            URLQueryItem(name: "ref", value: ref),
            URLQueryItem(name: "meta", value: ""),
            URLQueryItem(name: "path", value: path),
            URLQueryItem(name: "cid", value: AnalyticsManager.shared.callerID),
        ]
        request.httpBody = components.percentEncodedQuery?.data(using: .utf8)

        let task = session.dataTask(with: request) { _, response, error in
            if let e = error {
                self.error = e
                print("Error posting referral: \(e)")
            } else if let http = response as? HTTPURLResponse {
                self.httpResponse = http
                if http.statusCode == 200 {
                    print("Referral posted successfully")
                } else {
                    print("Referral post failed with status: \(http.statusCode)")
                }
            }
            self.finish()
        }
        task.resume()
    }
}
