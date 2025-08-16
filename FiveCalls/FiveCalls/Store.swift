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
            state.issueFetchTime = Date()
            state.issues = issues
        case let .SetContacts(contacts):
            state.contacts = contacts
        case let .SetDistrict(district):
            let oldDistrict = state.district
            state.district = district

            if oldDistrict != district {
                dispatch(action: .FetchMessages)
            }
        case let .SetSplitDistrict(splitDistrict):
            state.isSplitDistrict = splitDistrict
        case let .SetStateAbbr(stateAbbr):
            state.stateAbbreviation = stateAbbr
        case let .SetMissingReps(missingReps):
            state.missingReps = missingReps
        case let .SetLocation(location):
            state.location = location
        case let .SetMessages(messages):
            state.repMessages = messages
            if state.wantedMessageID != nil {
                if let selectedMessage = state.repMessages.first(where: { $0.id == state.wantedMessageID }) {
                    dispatch(action: .SelectMessage(selectedMessage))
                }
                
                // reset the wanted message id to nil any time we process it, regardless of success
                state.wantedMessageID = nil
            }
        case let .SelectMessage(message):
            state.selectedTab = "inbox"
            state.inboxRouter.selectedMessage = message
        case let .SelectMessageIDWhenLoaded(messageID):
            state.wantedMessageID = messageID
        case let .SetLoadingStatsError(error):
            state.statsLoadingError = error
        case let .SetLoadingIssuesError(error):
            state.issueLoadingError = error
        case let .SetLoadingContactsError(error):
            state.contactsLoadingError = error
        case let .SetNavigateToInboxMessage(messageid):
            guard let messageIntID = Int(messageid) else {
                break
            }
            
            // three cases that need to be handled here as we jump into the app from a push:
            // * no messages loaded: likely app launched fresh and racing the messages response
            // * have messages, but nothing matched the id: app in background but with stale messages
            // * have messages with a match: app is in background or foreground with up-to-date messages
            if state.repMessages.isEmpty {
                // no messages, set the future message selection id but don't refresh messages, they're probably already being refreshed
                dispatch(action: .SelectMessageIDWhenLoaded(messageIntID))
            } else if let selectedMessage = state.repMessages.first(where: { $0.id == messageIntID }) {
                // have messages and a match, so just navigate (this works even if we're on the issue list tab)
                dispatch(action: .SelectMessage(selectedMessage))
            } else {
                // have messages but no match, set the future message selection id and refresh messages
                dispatch(action: .SelectMessageIDWhenLoaded(messageIntID))
                dispatch(action: .FetchMessages)
            }
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
           if nextContacts.count >= 1 {
               state.issueRouter.path.append(IssueDetailNavModel(issue: issue, contacts: nextContacts))
           } else {
               state.issueRouter.path.append(IssueDoneNavModel(issue: issue, type: "done"))
           }
        case let .SetCustomizedScripts(issueID, scripts):
            state.scriptsByIssue[issueID] = scripts
        case let .SetLoadingScriptsError(issueID, error):
            state.scriptsLoadingErrorByIssue[issueID] = error
        case .FetchStats, .FetchIssues,
                .FetchContacts(_), .FetchMessages,
                .ReportOutcome(_, _, _),
                .LogSearch(_),
                .FetchCustomizedScripts(_, _):
            // handled in middleware
            break
        }
        return state
    }

}
