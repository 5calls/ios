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

class IssuesTimelineProvider: TimelineProvider {
    
    private let operationQueue = OperationQueue()
    
    private var cancellables: Set<AnyCancellable> = []

    private func fetchTimelineEntries() -> AnyPublisher<[IssuesEntry], Error> {
        issuesPublisher
            .map { issues in
                // aggregate the issues into a smaller view model that shows if they have been contacted already
                let contactLogs = Current.contactLogs.load()
                let issueSummaries = issues.map { self.issueSummary($0, contactLogs: contactLogs) }
                
                // split up the issues in groups of 2 and add the issues
                let numberOfIssuesPerEntry = 2
                var entries: [IssuesEntry] = []
                
                let calendar = Calendar.current
                
                // start at 8AM of the current day
                guard var date = calendar.date(bySetting: .hour, value: 8, of: Date()) else {
                    // can't set date to 8am for some reason, just return 1 entry for the current date
                    return [
                        IssuesEntry(date: Date(), issues: Array(issueSummaries.prefix(2)))
                    ]
                }
                
                // create entries every 4 hours starting at 8am
                for index in stride(from: 0, to: issues.count-1, by: numberOfIssuesPerEntry) {
                    let issuesForEntry = issues[index...index+1].map { self.issueSummary($0, contactLogs: contactLogs) }
                    let entry = IssuesEntry(
                        date: date,
                        issues: issuesForEntry)
                    
                    date = date.adding(4, .hours)
                    
                    // make sure that this entry will be visible in the 4 hour window, if it's already passed we don't need to return it
                    if date >= Date() {
                        entries.append(entry)
                    }
                }
                
                return entries
            }
            .eraseToAnyPublisher()
    }
    
    private func issueSummary(_ issue: Issue, contactLogs: ContactLogs) -> IssuesEntry.IssueSummary {
        IssuesEntry.IssueSummary(id: issue.id,
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
    
    func snapshot(with context: Context, completion: @escaping (IssuesEntry) -> ()) {
        guard !context.isPreview else {
            completion(.sample)
            return
        }
        
        fetchTimelineEntries()
            .sink(receiveCompletion: { result in
                print("Fetched timeline entries: \(result)")
                if case .failure(let error) = result {
                    print("Error fetching issues for snapshot: \(error)")
                    completion(.sample)
                }
            }) { entries in
                completion(entries.first ?? .sample)
            }
            .store(in: &cancellables)
    }
    
    func timeline(with context: Context, completion: @escaping (Timeline<IssuesEntry>) -> ()) {
        fetchTimelineEntries()
            .sink(receiveCompletion: { result in
                print("Fetched timeline entries: \(result)")
                if case .failure(let error) = result {
                    print("Error fetching issues for timeline: \(error)")
                    
                }
            }) { entries in
                completion(Timeline(entries: entries, policy: .atEnd))
            }
            .store(in: &cancellables)
    }
}
