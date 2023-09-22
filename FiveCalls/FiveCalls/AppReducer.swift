//
//  Reducer.swift
//  FiveCalls
//
//  Created by Christopher Selin on 9/22/23.
//  Copyright © 2023 5calls. All rights reserved.
//

import Foundation

func appReducer(_ state: AppState, _ action: Action) -> AppState {
    var state = state
    switch action {
    case let action as SetFetchingContactsAction:
        state.fetchingContacts = action.fetching
    case let action as SetIssuesAction:
        state.issues = action.issues
    case let action as SetContactsAction:
        state.contacts = action.contacts
    case let action as SetLocationAction:
        state.location = action.location
    default:
        break
    }
    return state
}
