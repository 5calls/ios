//
 //  Middlewares.swift
 //  FiveCalls
 //
 //  Created by Christopher Selin on 9/22/23.
 //  Copyright © 2023 5calls. All rights reserved.
 //
 import Foundation

func appMiddleware() -> Middleware<AppState> {
    return { state, action, dispatch in
        switch action {
        case let .FetchStats(issueID):
            fetchStats(issueID: issueID, dispatch: dispatch)
        case .FetchIssues:
            fetchIssues(dispatch: dispatch)
        case let .FetchContacts(location):
            fetchContacts(state: state, location: location, dispatch: dispatch)
        case let .SetLocation(location):
            fetchContacts(state: state, location: location, dispatch: dispatch)
        case .FetchMessages:
            fetchMessages(state: state, dispatch: dispatch)
        case let .ReportOutcome(issue, contactLog, outcome):
            // TODO: migrate ContactLog issueId to Int after UIKit is gone
            // this is always generated in swiftUI from an int so it should always succeed
            if let issueId = Int(contactLog.issueId), outcome.status != "skip" {
                dispatch(.SetIssueContactCompletion(issueId, "\(contactLog.contactId)-\(outcome.status)"))
            }
            AnalyticsManager.shared.trackEvent(name: "Outcome-\(outcome.status)", path: "/issues/\(issue.slug)/")
            reportOutcome(log: contactLog, outcome: outcome)
        case .SetGlobalCallCount, .SetIssueCallCount, .SetDonateOn, .SetIssueContactCompletion, .SetContacts, 
                .SetFetchingContacts, .SetIssues, .SetLoadingStatsError, .SetLoadingIssuesError, .SetLoadingContactsError,
                .GoBack, .GoToRoot, .GoToNext, .ShowWelcomeScreen, .SetDistrict, .SetMessages:
            // no middleware actions for these, including for completeness
            break
        }
    }
}

private func fetchStats(issueID: Int?, dispatch: @escaping Dispatcher) {
    let queue = OperationQueue.main
    let operation = FetchStatsOperation()
    if let issueID {
        operation.issueID = "\(issueID)"
    }
    operation.completionBlock = { [weak operation] in
        if let globalCallCount = operation?.numberOfCalls {
            DispatchQueue.main.async {
                dispatch(.SetGlobalCallCount(globalCallCount))
            }
        }
        if  let issueID, let issueCallCount = operation?.numberOfIssueCalls {
            DispatchQueue.main.async {
                dispatch(.SetIssueCallCount(issueID, issueCallCount))
            }
        }
        if let donateOn = operation?.donateOn {
            DispatchQueue.main.async {
                dispatch(.SetDonateOn(donateOn))
            }
        }

        
        if let error = operation?.error {
            print("Could not load stats: \(error.localizedDescription)..")

            DispatchQueue.main.async {
                dispatch(.SetLoadingStatsError(error))
            }
        }
    }
    queue.addOperation(operation)
}

private func fetchIssues(dispatch: @escaping Dispatcher) {
    let queue = OperationQueue.main
    let operation = FetchIssuesOperation()
    operation.completionBlock = { [weak operation] in
        if let issues = operation?.issuesList {
            DispatchQueue.main.async {
                dispatch(.SetIssues(issues))
            }
        } else if let error = operation?.error {
            print("Could not load issues: \(error.localizedDescription)..")

            DispatchQueue.main.async {
                dispatch(.SetLoadingIssuesError(error))
            }
        } else {
            // we don't really return errors from this endpoint so not much use in doing more parsing
            DispatchQueue.main.async {
                dispatch(.SetLoadingContactsError(MiddlewareError.UnknownError))
            }
        }
    }
    queue.addOperation(operation)
}

private func fetchContacts(state: AppState, location: UserLocation, dispatch: @escaping Dispatcher) {
    dispatch(.SetFetchingContacts(true))

    let queue = OperationQueue.main
    let operation = FetchContactsOperation(location: location)
    operation.completionBlock = { [weak operation] in
        dispatch(.SetFetchingContacts(false))
        
        if let district = operation?.district {
            // any time the district changes, fetch messages as well
            if state.district != district {
                // TODO: if we just dispatch twice this does not run in order so... this is a hack
                dispatch(.SetDistrict(district))
                DispatchQueue.main.async {
                    dispatch(.FetchMessages)
                }
            }
        }

        if var contacts = operation?.contacts, !contacts.isEmpty {
            // if we get more than one house rep here, select the first one.
            // this is a split district situation and we should let the user
            // pick which one is correct in the future
            let houseReps = contacts.filter({ $0.area == "US House" })
            if houseReps.count > 1 {
                contacts = contacts.filter({ $0.area != "US House" })
                contacts.append(houseReps[0])
            }

            dispatch(.SetContacts(contacts))
        } else if let error = operation?.error {
            DispatchQueue.main.async {
                dispatch(.SetLoadingContactsError(error))
            }
        } else {
            // TODO: parse error messages from the backend and return specifics
            DispatchQueue.main.async {
                dispatch(.SetLoadingContactsError(MiddlewareError.UnknownError))
            }
        }
    }
    queue.addOperation(operation)
}

private func fetchMessages(state: AppState, dispatch: @escaping Dispatcher) {
    print("🤖 checkooooo \(state.district)")
    guard let district = state.district else {
        return
    }
    
    print("🤖 fetching messages...")
    
    let queue = OperationQueue.main
    let operation = FetchMessagesOperation(district: district)
    operation.completionBlock = { [weak operation] in
        if let messages = operation?.messages {
            print("🤖 got some messages:\(messages)")
            DispatchQueue.main.async {
                dispatch(.SetMessages(messages))
            }
        }
    }
    queue.addOperation(operation)
}

private func reportOutcome(log: ContactLog, outcome: Outcome) {
    // we don't actually care about the result of this so no need to set the callback
    OperationQueue.main.addOperation(ReportOutcomeOperation(log: log, outcome: outcome))
}

enum MiddlewareError: Error {
   case UnknownError
}
