//
//  Provider.swift
//  FiveCalls
//
//  Created by Ben Scheirman on 7/5/20.
//  Copyright © 2020 5calls. All rights reserved.
//

import Foundation
import WidgetKit

struct Provider: TimelineProvider {
    
    typealias Entry = FiveCallsEntry
    
    let operationQueue = OperationQueue()
    
    // request refresh every day
    let optimalRefreshInterval: TimeInterval = 60 * 60 * 24
    
    func fetchIssues(completion: @escaping (Result<[Issue], Error>) -> Void) {
        let fetchOp = FetchIssuesOperation()
        fetchOp.completionBlock = { [weak fetchOp] in
            guard let op = fetchOp else { return }
            DispatchQueue.main.async {
                if let error = op.error {
                    completion(.failure(error))
                } else {
                    completion(.success(op.issuesList ?? []))
                }
            }
        }
        operationQueue.addOperation(fetchOp)
    }
    
    func snapshot(with context: Context, completion: @escaping (FiveCallsEntry) -> ()) {
        guard !context.isPreview else {
            completion(.sample)
            return
        }
        
        fetchIssues { (result) in
            switch result {
            case .failure(_):
                completion(.sample)
            case .success(let issues):
                let topIssues = Array(issues.prefix(3))
                completion(FiveCallsEntry(date: Date(timeIntervalSinceNow: optimalRefreshInterval),
                                          callCounts: fetchCallCounts(),
                                          topIssues: topIssues.map { FiveCallsEntry.IssueSummary(id: $0.id, name: $0.name, hasCalled: false) },
                                          reps: []))
            }
        }
    }
    
    func timeline(with context: Context, completion: @escaping (Timeline<FiveCallsEntry>) -> ()) {
        fetchIssues { (result) in
            let entries: [FiveCallsEntry]
            switch result {
            case .failure(_):
                entries = [.sample]
                
            case .success(let issues):
                let topIssues = Array(issues.prefix(3))
                entries = [FiveCallsEntry(date: Date(timeIntervalSinceNow: optimalRefreshInterval),
                                          callCounts: fetchCallCounts(),
                                          topIssues: topIssues.map { FiveCallsEntry.IssueSummary(id: $0.id, name: $0.name, hasCalled: false) },
                                          reps: [])]
            }
            
            completion(Timeline(entries: entries, policy: .after(Date(timeIntervalSinceNow: optimalRefreshInterval))))
        }
    }
    
    private func fetchCallCounts() -> FiveCallsEntry.CallCounts {
        let logs = Current.contactLogs.load()
        
        let lastMonthDate = Date(timeIntervalSinceNow: 60 * 60 * 24 * 30)
        return .init(total: logs.all.count,
                     lastMonth: logs.since(date: lastMonthDate).count)
        
    }
}
