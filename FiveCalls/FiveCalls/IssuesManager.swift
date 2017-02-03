//
//  IssuesManager.swift
//  FiveCalls
//
//  Created by Ben Scheirman on 2/2/17.
//  Copyright © 2017 5calls. All rights reserved.
//

import Foundation

class IssuesManager {
    
    var issuesList: IssuesList?
    
    var zipCode: String? {
        get {
            return UserDefaults.standard.string(forKey: UserDefaultsKeys.zipCode.rawValue)
        }
        set {
            UserDefaults.standard.setValue(newValue, forKeyPath: UserDefaultsKeys.zipCode.rawValue)
        }
    }
    
    var issues: [Issue] {
        return issuesList?.issues ?? []
    }
    
    func issue(withId id: String) -> Issue? {
        return issuesList?.issues.filter { $0.id == id }.first
    }
    
    func fetchIssues(completion: @escaping (Void) -> Void) {
        let operation = FetchIssuesOperation(zipCode: zipCode)
        operation.completionBlock = { [weak self] in
            if let issuesList = operation.issuesList {
                self?.issuesList = issuesList
                // notification!
                DispatchQueue.main.async {
                    completion()
                }
            } else {
                print("Could not load issues.. \(operation.error?.localizedDescription)")
            }
        }
        OperationQueue.main.addOperation(operation)
    }
}
