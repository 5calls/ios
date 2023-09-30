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
         case .FetchIssues:
             fetchIssues(dispatch: dispatch)
         case let .FetchContacts(location):
             fetchContacts(location: location, dispatch: dispatch)
         case let .SetLocation(location):
             fetchContacts(location: location, dispatch: dispatch)
         case .SetContacts, .SetFetchingContacts, .SetIssues, .SetLoadingIssuesError, .SetLoadingContactsError:
             // no middleware actions for these, including for completeness
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

 private func fetchContacts(location: NewUserLocation, dispatch: @escaping Dispatcher) {
     dispatch(.SetFetchingContacts(true))

     let queue = OperationQueue.main
     let operation = FetchContactsOperation(location: location)
     operation.completionBlock = { [weak operation] in
         dispatch(.SetFetchingContacts(false))

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

enum MiddlewareError: Error {
    case UnknownError
}
