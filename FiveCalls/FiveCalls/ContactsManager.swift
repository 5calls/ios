//
//  ContactsManager.swift
//  FiveCalls
//
//  Created by Ben Scheirman on 1/9/19.
//  Copyright © 2019 5calls. All rights reserved.
//

import Foundation

enum ContactLoadResult {
    case success([Contact])
    case failed(Error)
}

class ContactsManager {
    private let queue: OperationQueue
    
    // contactCache stores a list of contacts for a string-serialized location
    private var contactCache: [String: [Contact]]
    
    init() {
        queue = .main
        contactCache = [:]
    }
    
    func fetchContacts(location: UserLocation, completion: @escaping (ContactLoadResult) -> Void) {
        // if we already have contacts for this userlocation, return that
        if let contacts = self.contactCache[location.description] {
            completion(.success(contacts))
            return
        }
        
        let operation = FetchContactsOperation(location: location)
        
        operation.completionBlock = { [weak operation] in            
            if var contacts = operation?.contacts, !contacts.isEmpty {
                // if we get more than one house rep here, select the first one.
                // this is a split district situation and we should let the user
                // pick which one is correct in the future
                let houseReps = contacts.filter({ $0.area == "US House" })
                if houseReps.count > 1 {
                    contacts = contacts.filter({ $0.area != "US House" })
                    contacts.append(houseReps[0])
                }
                self.contactCache[location.description] = contacts
                
                DispatchQueue.main.async {
                    completion(.success(contacts))
                }
            } else if let error = operation?.error {
                DispatchQueue.main.async {
                    completion(.failed(error))
                }
            }
        }
        queue.addOperation(operation)
    }
}
