//
//  Store.swift
//  FiveCalls
//
//  Created by Christopher Selin on 9/22/23.
//  Copyright © 2023 5calls. All rights reserved.
//
import Foundation
import SwiftUI

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
        let state = oldState
        switch action {
        case .ShowWelcomeScreen:
            state.showWelcomeScreen = true
        case let .SetGlobalCallCount(globalCallCount):
            state.globalCallCount = globalCallCount
        case let .SetIssueCallCount(issueID, count):
            state.issueCallCounts[issueID] = count
        case let .SetDonateOn(donateOn):
            state.donateOn = donateOn
        case let .SetIssueContactCompletion(issueID, contactOutcome):
            var existingCompletions = state.issueCompletion[issueID] ?? []
            existingCompletions.append(contactOutcome)
            state.issueCompletion[issueID] = existingCompletions
        case let .SetFetchingContacts(fetching):
            state.fetchingContacts = fetching
        case let .SetIssues(issues):
            state.issues = issues
        case let .SetContacts(contacts):
            state.contacts = contacts
        case let .SetLocation(location):
            state.location = location
        case let .SetLoadingStatsError(error):
            state.statsLoadingError = error
        case let .SetLoadingIssuesError(error):
            state.issueLoadingError = error
        case let .SetLoadingContactsError(error):
            state.contactsLoadingError = error
        case .GoBack:
            if state.issueRouter.path.isEmpty {
                state.issueRouter.selectedIssue = nil
            } else {
                state.issueRouter.path.removeLast()
            }
        case .GoToRoot:
            state.issueRouter.selectedIssue = nil
            state.issueRouter.path = NavigationPath()
        case let .GoToNext(issue, nextContacts):
            if nextContacts.count > 1 {
                state.issueRouter.path.append(IssueDetailNavModel(issue: issue, contacts: nextContacts))
            } else {
                state.issueRouter.path.append(IssueNavModel(issue: issue, type: "done"))
            }
        case .FetchStats, .FetchIssues, .FetchContacts(_), .ReportOutcome(_, _, _):
            // handled in middleware
            break
        }
        return state
    }

}
