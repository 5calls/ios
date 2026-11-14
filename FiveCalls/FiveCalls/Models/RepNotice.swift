// Copyright 5calls. All rights reserved. See LICENSE for details.

import Foundation

/// A server-controlled message shown above the caller's reps, e.g. explaining that new members of
/// Congress don't take office until January. The API only sends a notice while it's live.
struct RepNotice: Decodable, Equatable {
    let id: Int
    let text: String
    let expiresAt: Date?

    init(id: Int, text: String, expiresAt: Date?) {
        self.id = id
        self.text = text
        self.expiresAt = expiresAt
    }

    private enum CodingKeys: String, CodingKey {
        case id, text, expiresAt
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        id = try container.decode(Int.self, forKey: .id)
        text = try container.decode(String.self, forKey: .text).trimmingCharacters(in: .whitespacesAndNewlines)
        // decoded by hand so an unexpected timestamp format can't fail the whole reps response
        let expiresString = try? container.decodeIfPresent(String.self, forKey: .expiresAt)
        expiresAt = expiresString.flatMap(RepNotice.parseTimestamp)
    }

    /// The API stops sending a notice once it expires, but the app can sit open longer than that.
    func isActive(now: Date = Date()) -> Bool {
        guard !text.isEmpty else { return false }
        guard let expiresAt else { return true }
        return now < expiresAt
    }

    /// RFC 3339 as the API writes it, with or without fractional seconds.
    static func parseTimestamp(_ value: String) -> Date? {
        let formatter = ISO8601DateFormatter()
        if let date = formatter.date(from: value) {
            return date
        }
        formatter.formatOptions = [.withInternetDateTime, .withFractionalSeconds]
        return formatter.date(from: value)
    }
}
