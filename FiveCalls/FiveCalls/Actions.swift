//
//  Action.swift
//  FiveCalls
//
//  Created by Christopher Selin on 9/22/23.
//  Copyright © 2023 5calls. All rights reserved.
//
import Foundation

protocol Action { }

struct FetchIssuesAction: Action {}

struct SetIssuesAction: Action {
    let issues: [Issue]
}

struct FetchContactsAction: Action {
    let location: NewUserLocation
}

struct SetContactsAction: Action {
    let contacts: [Contact]
}

struct SetLocationAction: Action {
    let location: NewUserLocation
}

struct SetFetchingContactsAction: Action {
    let fetching: Bool
}

struct SetIssueErrorAction: Action {
    let error: Error
}

struct SetContactsErrorAction: Action {
    let error: Error
}

