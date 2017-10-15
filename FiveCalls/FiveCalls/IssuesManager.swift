//
//  IssuesManager.swift
//  FiveCalls
//
//  Created by Ben Scheirman on 2/2/17.
//  Copyright © 2017 5calls. All rights reserved.
//

import Foundation

enum IssuesLoadResult {
    case success
    case serverError(Error)
    case offline
}

class IssuesManager {

    // Read-only for users of this class.
    private(set) var categories: [Category] = []
    
    private var issuesList: IssuesList? {
        didSet {
            // Once we have all the issues downloaded, create the category->[issues] relationship.
            // This code runs on BG thread (and it should).

            // Group issues by categories - this creates a dictionary in which the
            // key is the Category object and the value is an array of all issues that belong
            // in that category.
            let issuesByCategory = Dictionary(grouping: issues) { (issue) -> Category in
                if let category = issue.category {
                    return category
                }
                // If an issue does not belong to any category, we categories the
                // issue as 'uncategorized' (similar to what the web app does)
                return Category(name: R.string.localizable.uncategorizedIssues())
            }
            var categories = Array<Category>()
            // Finally by going over each of the keys (categories) in the dictionary
            // create a new Category object which will contain the issues that belong
            // to that Category object.
            issuesByCategory.forEach { (category, issues) in
                categories.append(Category(name: category.name, issues: issues))
            }
            // Sort categories alphabetically
            categories = categories.sorted();
            self.categories = categories
        }
    }
    
    private var issues: [Issue] {
        return issuesList?.issues ?? []
    }

    var isSplitDistrict: Bool { return self.issuesList?.splitDistrict == true }
    
    func issue(withId id: String) -> Issue? {
        return issuesList?.issues.filter { $0.id == id }.first
    }
    
    func fetchIssues(location: UserLocation?, completion: @escaping (IssuesLoadResult) -> Void) {
        
        let operation = FetchIssuesOperation(location: location)
        
        operation.completionBlock = { [weak self, weak operation] in
            if let issuesList = operation?.issuesList {
                self?.issuesList = issuesList
                // notification!
                DispatchQueue.main.async {
                    completion(.success)
                }
            } else {
                let error = operation?.error
                print("Could not load issues..")
                
                DispatchQueue.main.async {
                    if let e = error {
                        print(e.localizedDescription)
                        
                        if self?.isOfflineError(error: e) == true {
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
        OperationQueue.main.addOperation(operation)
    }
    
    private func isOfflineError(error: Error) -> Bool {
        let e = error as NSError
        guard e.domain == NSURLErrorDomain else { return false }
        
        return e.code == NSURLErrorNetworkConnectionLost ||
            e.code == NSURLErrorNotConnectedToInternet ||
            e.code == NSURLErrorSecureConnectionFailed
    }
}
