//
//  FiveCallsWidgets.swift
//  FiveCallsWidgets
//
//  Created by Ben Scheirman on 7/3/20.
//  Copyright © 2020 5calls. All rights reserved.
//

import WidgetKit
import SwiftUI
import Intents

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
                let topIssues = Array(issues.prefix(3).map { $0.name })
                completion(FiveCallsEntry(date: Date(timeIntervalSinceNow: optimalRefreshInterval), callCount: 12, topIssues: topIssues, reps: []))
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
                let topIssues = Array(issues.prefix(3).map { $0.name })
                entries = [FiveCallsEntry(date: Date(timeIntervalSinceNow: optimalRefreshInterval), callCount: 12, topIssues: topIssues, reps: [])]
            }
            
            completion(Timeline(entries: entries, policy: .after(Date())))
        }
    }
    
    private func fetchCallCount() -> Int {
        return 0
    }
}

struct FiveCallsEntry: TimelineEntry {
    let date: Date
    let callCount: Int
    let topIssues: [String]
    let reps: [String]
}

extension FiveCallsEntry {
    static var sample: FiveCallsEntry {
        FiveCallsEntry(date: Date(), callCount: 87, topIssues: [], reps: [])
    }
}

struct PlaceholderView: View {
    var body: some View {
        Rectangle().fill(Color.blue)
    }
}

struct EntryView: View {
    
    let entry: FiveCallsEntry
    
    var body: some View {
        ZStack {
            Rectangle().fill(Color.blue)
            
            VStack {
                Text("Calls Made: \(entry.callCount)")
                
                if let issue = entry.topIssues.first {
                    Text("Issue: \(issue)")
                }
            }
        }
    }
}

@main
struct FiveCallsWidget: Widget {
    let kind = "FiveCallsWidget"
    
    var body: some WidgetConfiguration {
        StaticConfiguration(kind: kind, provider: Provider(),
                            placeholder: PlaceholderView(),
                            content: { entry in
                                EntryView(entry: entry)
                            })
            .supportedFamilies([.systemSmall, .systemMedium, .systemLarge])
            .description("Shows the call count")
            .configurationDisplayName("Five Calls")
    }
}

struct FiveCallsWidgets_Previews: PreviewProvider {
    static var previews: some View {
        /*@START_MENU_TOKEN@*/Text("Hello, World!")/*@END_MENU_TOKEN@*/
    }
}
