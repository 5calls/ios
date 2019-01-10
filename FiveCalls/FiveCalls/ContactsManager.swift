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
    
    var contacts: [Contact]?
    
    init() {
        queue = .main
    }
    
    func fetchContacts(location: UserLocation, completion: @escaping (ContactLoadResult) -> Void) {
        let operation = FetchContactsOperation(location: location)
        
        operation.completionBlock = { [weak self, weak operation] in
            
            if let contacts = operation?.contacts {
                self?.contacts = contacts
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
