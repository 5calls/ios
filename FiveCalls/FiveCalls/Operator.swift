//
//  Operator.swift
//  FiveCalls
//
//  Created by Nick O'Neill on 8/2/23.
//  Copyright © 2023 5calls. All rights reserved.
//

import Foundation

enum OperationResult {
    case success
    case serverError(Error)
    case offline
}

// Operator is responsible for running any of our operation classes and managing the results. Since we store the state in AppState
// rather than some other manager instance, we don't need some intermediary state holder
class Operator {
    private let queue: OperationQueue
    
    init() {
        queue = .main
    }

    func fetchIssues(setIssues: @MainActor @escaping ([Issue]) -> ()) {
        let operation = FetchIssuesOperation()
        operation.completionBlock = { [weak operation] in
            if let issues = operation?.issuesList {
                DispatchQueue.main.async {
                    setIssues(issues)
                }
            } else if let error = operation?.error {
                print("Could not load issues: \(error.localizedDescription)..")
                
                // TODO(nickoneill): do we need to return an error? does it make more sense to have a function that sets an error in app state? or make this async with a completion so state in the component can handle the error?
//                DispatchQueue.main.async {
//                    print(error.localizedDescription)
//                    
//                    if error.isOfflineError() {
//                        completion(.offline)
//                    } else {
//                        completion(.serverError(error))
//                    }
//                }
            } else {
                fatalError("unknown issue fetching issues")
            }
        }
        queue.addOperation(operation)
    }
    
    func fetchContacts(location: NewUserLocation, fetching: @MainActor @escaping (Bool) -> (), setContacts: @MainActor @escaping ([Contact]) -> ()) {
        DispatchQueue.main.async {
            fetching(true)
        }
        
        let operation = FetchContactsOperation(location: location)
        operation.completionBlock = { [weak operation] in
            DispatchQueue.main.async {
                fetching(false)
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
                DispatchQueue.main.async {
                    setContacts(contacts)
                }

                // TODO(nickoneill): do we need to return an error? does it make more sense to have a function that sets an error in app state? or make this async with a completion so state in the component can handle the error?
//                DispatchQueue.main.async {
//                    completion(.success)
//                }
            } else if let error = operation?.error {
//                DispatchQueue.main.async {
//                    print(error.localizedDescription)
//                    
//                    if error.isOfflineError() {
//                        return .failure(OperationResult.offline)
//                    } else {
//                        return .failure(.serverError(error))
//                    }
//                }
            } else {
                fatalError("unknown issue fetching contacts")
            }
        }
        queue.addOperation(operation)
    }
}
