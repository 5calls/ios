//
//  Store.swift
//  FiveCalls
//
//  Created by Christopher Selin on 9/22/23.
//  Copyright © 2023 5calls. All rights reserved.
//
import Foundation

typealias Dispatcher = (Action) -> Void

typealias Reducer<State: ReduxState> = (_ state: State, _ action: Action) -> State
typealias Middleware<StoreState: ReduxState> = (StoreState, Action, @escaping Dispatcher) -> Void

protocol ReduxState { }

class Store: ObservableObject {
    @Published var state: AppState
    var middlewares: [Middleware<AppState>]

    init(state: AppState, middlewares: [Middleware<AppState>] = []) {
        self.state = state
        self.middlewares = middlewares
    }

    func dispatch(action: Action) {
        DispatchQueue.main.async {
            self.state = self.reduce(self.state, action)
        }

        // run all middlewares
        middlewares.forEach { middleware in
            middleware(state, action, dispatch)
        }
    }
    
    func reduce(_ oldState: AppState, _ action: Action) -> AppState {
        var state = oldState
        switch action {
        case let action as SetFetchingContactsAction:
            state.fetchingContacts = action.fetching
        case let action as SetIssuesAction:
            state.issues = action.issues
        case let action as SetContactsAction:
            state.contacts = action.contacts
        case let action as SetLocationAction:
            state.location = action.location
            self.dispatch(action: FetchContactsAction(location: action.location))
        case let action as SetIssueErrorAction:
            state.issueLoadingError = action.error
        case let action as SetContactsErrorAction:
            state.contactsLoadingError = action.error
        default:
            break
        }
        return state
    }

}
