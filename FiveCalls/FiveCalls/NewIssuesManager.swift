//
//  NewIssuesManager.swift
//  FiveCalls
//
//  Created by Nick O'Neill on 7/24/23.
//  Copyright © 2023 5calls. All rights reserved.
//

import Foundation
import UIKit

class NewIssuesManager {
    private let queue: OperationQueue
    
    init() {
        queue = .main
    }
    
    func fetchIssues(completion: @escaping (LoadResult) -> Void) {
        let operation = FetchIssuesOperation()
        operation.completionBlock = { [weak operation] in
            if let issues = operation?.issuesList {
                DispatchQueue.main.async {
                    (UIApplication.shared.delegate as! AppDelegate).appState.issues = issues
                    completion(.success)
                }
            } else {
                let error = operation?.error
                print("Could not load issues: \(error?.localizedDescription ?? "<unknown>")..")
                
                DispatchQueue.main.async {
                    if let e = error {
                        print(e.localizedDescription)
                        
                        if e.isOfflineError() {
                            completion(.offline)
                        } else {
                            completion(.serverError(e))
                        }
                        
                    } else {
                        // souldn't happen, but let's just assume connection error
                        completion(.offline)
                    }
                }
            }
        }
        queue.addOperation(operation)
    }
}
