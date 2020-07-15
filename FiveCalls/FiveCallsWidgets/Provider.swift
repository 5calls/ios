//
//  Provider.swift
//  FiveCalls
//
//  Created by Ben Scheirman on 7/5/20.
//  Copyright © 2020 5calls. All rights reserved.
//

import Foundation
import WidgetKit
import Combine

class Provider: TimelineProvider {
    
    typealias Entry = FiveCallsEntry
    
    private let operationQueue = OperationQueue()
    
    // request refresh every day
    private let optimalRefreshInterval: TimeInterval = 60 * 60 * 24
    
    private var cancellables: Set<AnyCancellable> = []
    
    init() {
    }
    
    deinit {
        print("DEINIT!!!!")
    }
    
    private func fetchTimelineEntries() -> AnyPublisher<FiveCallsEntry, Error> {
        issuesPublisher
            .map { issues in
                let contactLogs = Current.contactLogs.load()
                let lastMonthDate = Date(timeIntervalSinceNow: 60 * 60 * 24 * 30)
                
                let callCounts = FiveCallsEntry.CallCounts(
                    total: contactLogs.all.count,
                    lastMonth: contactLogs.since(date: lastMonthDate).count)
                
                let issuesSummaries = issues.prefix(2).map { issue in
                    self.issueSummary(issue, contactLogs: contactLogs)
                }
                
                return FiveCallsEntry(
                    date: Date(),
                    callCounts: callCounts,
                    topIssues: issuesSummaries,
                    reps: [])
            }
            .eraseToAnyPublisher()
    }
    
    private func issueSummary(_ issue: Issue, contactLogs: ContactLogs) -> FiveCallsEntry.IssueSummary {
        FiveCallsEntry.IssueSummary(id: issue.id,
                                    name: issue.name,
                                    hasCalled: contactLogs.hasContactAnyContact(forIssue: issue),
                                    url: issue.deepLinkURL)
    }

    private var issuesPublisher: AnyPublisher<[Issue], Error> {
        Future { promise in
            let fetchOp = FetchIssuesOperation()
            fetchOp.completionBlock = { [weak fetchOp] in
                guard let op = fetchOp else { return }
                if let error = op.error {
                    promise(.failure(error))
                } else {
                    promise(.success(op.issuesList ?? []))
                }
            }
            self.operationQueue.addOperation(fetchOp)
        }.eraseToAnyPublisher()
    }
    
    func snapshot(with context: Context, completion: @escaping (FiveCallsEntry) -> ()) {
        guard !context.isPreview else {
            completion(.sample)
            return
        }
        
        var snapshotCancellable: AnyCancellable? = nil
        snapshotCancellable = fetchTimelineEntries()
            .sink(receiveCompletion: { result in
                print("Fetched timeline entries: \(result)")
                if case .failure(let error) = result {
                    print("Error fetching issues for snapshot: \(error)")
                    completion(.sample)
                }
                
                // prevent unhelpful Swift warning saying this variable is never read
                if snapshotCancellable != nil {
                    snapshotCancellable = nil
                }
            }) { entries in
                completion(entries)
            }
        snapshotCancellable?.store(in: &cancellables)
    }
    
    func timeline(with context: Context, completion: @escaping (Timeline<FiveCallsEntry>) -> ()) {
        var timelineCancellable: AnyCancellable? = nil
        timelineCancellable = fetchTimelineEntries()
            .sink(receiveCompletion: { result in
                print("Fetched timeline entries: \(result)")
                if case .failure(let error) = result {
                    print("Error fetching issues for timeline: \(error)")
                    
                }
                
                // prevent unhelpful Swift warning saying this variable is never read
                if timelineCancellable != nil {
                    timelineCancellable = nil
                }
            }) { entries in
                completion(Timeline(entries: [entries], policy: .after(Date(timeIntervalSinceNow: self.optimalRefreshInterval))))
            }
        timelineCancellable?.store(in: &cancellables)
    }
}
