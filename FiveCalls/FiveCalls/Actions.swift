//
//  Action.swift
//  FiveCalls
//
//  Created by Christopher Selin on 9/22/23.
//  Copyright © 2023 5calls. All rights reserved.
//
import Foundation

enum Action {
    case FetchIssues
    case SetIssues([Issue])
    case FetchContacts(NewUserLocation)
    case SetContacts([Contact])
    case SetLocation(NewUserLocation)
    case SetFetchingContacts(Bool)
    case SetLoadingIssuesError(Error)
    case SetLoadingContactsError(Error)
}
