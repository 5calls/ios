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
            return UserDefaults.standard.getValue(forKey: .zipCode)
        }
        set {
            UserDefaults.standard.setValue(newValue, forKey: UserDefaultsKeys.zipCode.rawValue)
            if newValue != nil {
                locationInfo = nil
            }
        }
    }
    
    var locationInfo: [String : Any]? {
        get {
            return UserDefaults.standard.object(forKey: UserDefaultsKeys.locationInfo.rawValue) as? [String : Any]
        }
        set {
            UserDefaults.standard.setValue(newValue, forKey: UserDefaultsKeys.locationInfo.rawValue)
            if newValue != nil {
                zipCode = nil
            }
        }
    }
    
    var issues: [Issue] {
        return issuesList?.issues ?? []
    }
    
    func issue(withId id: String) -> Issue? {
        return issuesList?.issues.filter { $0.id == id }.first
    }
    
    func fetchIssues(completion: @escaping (Void) -> Void) {
        
        let operation: FetchIssuesOperation
        if let location = locationInfo,
            let lat = location["latitude"],
            let long = location["longitude"] {
            operation = FetchIssuesOperation(latLong: "\(lat),\(long)")
        } else {
            operation = FetchIssuesOperation(zipCode: zipCode)
        }
        
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
