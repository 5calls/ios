// Copyright 5calls. All rights reserved. See LICENSE for details.

import Foundation

enum IssueActionType: Hashable {
    case freeform
    case donate
    case unknown(String)

    init(rawValue: String) {
        switch rawValue {
        case "freeform": self = .freeform
        case "donate": self = .donate
        default: self = .unknown(rawValue)
        }
    }
}

struct IssueAction: Decodable, Hashable {
    let type: IssueActionType
    let title: String?
    let body: String?
    let buttonText: String?
    let buttonURL: String?

    private enum CodingKeys: String, CodingKey {
        case type, title, body, buttonText, buttonURL
    }

    init(type: IssueActionType, title: String? = nil, body: String? = nil, buttonText: String? = nil, buttonURL: String? = nil) {
        self.type = type
        self.title = title
        self.body = body
        self.buttonText = buttonText
        self.buttonURL = buttonURL
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        type = IssueActionType(rawValue: try container.decode(String.self, forKey: .type))
        title = try container.decodeIfPresent(String.self, forKey: .title)
        body = try container.decodeIfPresent(String.self, forKey: .body)
        buttonText = try container.decodeIfPresent(String.self, forKey: .buttonText)
        buttonURL = try container.decodeIfPresent(String.self, forKey: .buttonURL)
    }
}
