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
        case let .SetFetchingContacts(fetching):
            state.fetchingContacts = fetching
        case let .SetIssues(issues):
            state.issues = issues
        case let .SetContacts(contacts):
            state.contacts = contacts
        case let .SetLocation(location):
            state.location = location
            self.dispatch(action: .FetchContacts(location))
        case let .SetLoadingIssuesError(error):
            state.issueLoadingError = error
        case let .SetLoadingContactsError(error):
            state.contactsLoadingError = error
        case .FetchIssues, .FetchContacts(_), .ReportOutcome(_, _):
            // handled in middleware
            break
        }
        return state
    }

}
