//
//  Middlewares.swift
//  FiveCalls
//
//  Created by Christopher Selin on 9/22/23.
//  Copyright © 2023 5calls. All rights reserved.
//

import Foundation

//enum OperationResult {
//    case success
//    case serverError(Error)
//    case offline
//}

func appMiddleware() -> Middleware<AppState> {
    return { state, action, dispatch in
        switch action {
        case _ as FetchIssuesAction:
            fetchIssues(dispatch: dispatch)
        case let action as FetchContactsAction:
            fetchContacts(action: action, dispatch: dispatch)
        default:
            break
        }
    }
}

private func fetchIssues(dispatch: @escaping Dispatcher) {
    let queue = OperationQueue.main
    let operation = FetchIssuesOperation()
    operation.completionBlock = { [weak operation] in
        if let issues = operation?.issuesList {
            DispatchQueue.main.async {
                dispatch(SetIssuesAction(issues: issues))
            }
        } else if let error = operation?.error {
            print("Could not load issues: \(error.localizedDescription)..")
            
            DispatchQueue.main.async {
                print(error.localizedDescription)
                
//                    if error.isOfflineError() {
//                        completion(.offline)
//                    } else {
//                        completion(.serverError(error))
//                    }
            }
        } else {
            fatalError("unknown issue fetching issues")
        }
    }
    queue.addOperation(operation)
}

private func fetchContacts(action: FetchContactsAction, dispatch: @escaping Dispatcher) {
    dispatch(SetFetchingContactsAction(fetching: true))

    let queue = OperationQueue.main
    let operation = FetchContactsOperation(location: action.location)
    operation.completionBlock = { [weak operation] in
        dispatch(SetFetchingContactsAction(fetching: false))
        
        if var contacts = operation?.contacts, !contacts.isEmpty {
            // if we get more than one house rep here, select the first one.
            // this is a split district situation and we should let the user
            // pick which one is correct in the future
            let houseReps = contacts.filter({ $0.area == "US House" })
            if houseReps.count > 1 {
                contacts = contacts.filter({ $0.area != "US House" })
                contacts.append(houseReps[0])
            }

            dispatch(SetContactsAction(contacts: contacts))
        } else if let error = operation?.error {
            DispatchQueue.main.async {
                print(error.localizedDescription)
                
//                    if error.isOfflineError() {
//                        completion(.offline)
//                    } else {
//                        completion(.serverError(error))
//                    }
            }
        } else {
            fatalError("unknown issue fetching contacts")
        }
    }
    queue.addOperation(operation)
}

