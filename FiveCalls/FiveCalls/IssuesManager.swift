//
//  IssuesManager.swift
//  FiveCalls
//
//  Created by Ben Scheirman on 2/2/17.
//  Copyright © 2017 5calls. All rights reserved.
//

import Foundation

enum LoadResult {
    case success
    case serverError(Error)
    case offline
}

class IssuesManager {

    private let queue: OperationQueue
    
    public var issues: [Issue] = []
    
    init() {
        queue = .main
    }

    func issue(withId id: Int64) -> Issue? {
        return issues.first(where: { $0.id == id })
    }
    
    func fetchIssues(completion: @escaping (LoadResult) -> Void) {
        let operation = FetchIssuesOperation()
        operation.completionBlock = { [weak self, weak operation] in
            if let issues = operation?.issuesList {
                self?.issues = issues
                DispatchQueue.main.async {
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
    
    public func issue(withSlug slug: String) -> Issue? {
        return issues.first(where: {$0.slug == slug})
    }
}
