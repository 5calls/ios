//
//  CombinedRepsTimeline.swift
//  FiveCalls
//
//  Created by Ben Scheirman on 7/15/20.
//  Copyright © 2020 5calls. All rights reserved.
//

import Foundation
import WidgetKit
import Combine

class CombinedRepsTimelineProvider: TimelineProvider {
    
    private var cancellables: Set<AnyCancellable> = []
    private var operationQueue = OperationQueue()
    
    func snapshot(with context: Context, completion: @escaping (CombinedRepsEntry) -> ()) {
        if context.isPreview {
            completion(CombinedRepsEntry(date: Date(), reps: .sample, hasLocation: true))
            return
        }
        
        repsPublisher()
            .replaceError(with: [])
            .map { reps in
                guard !reps.isEmpty else {
                    return CombinedRepsEntry(date: Date(), reps: [], hasLocation: false)
                }
                
                return CombinedRepsEntry(date: Date(), reps: reps, hasLocation: true)
            }
            .sink {
                completion($0)
            }
            .store(in: &cancellables)
    }
    
    func timeline(with context: Context, completion: @escaping (Timeline<CombinedRepsEntry>) -> ()) {
        repsPublisher()
            .replaceError(with: [])
            .map { reps in
                guard !reps.isEmpty else {
                    return CombinedRepsEntry(date: Date(), reps: [], hasLocation: false)
                }
                
                return CombinedRepsEntry(date: Date(), reps: reps, hasLocation: true)
            }
            .sink {
                completion(Timeline(entries: [$0], policy: .after(Date().adding(1, .days))))
            }
            .store(in: &cancellables)
    }
    
    private func repsPublisher() -> AnyPublisher<[Contact], Error> {
        guard UserLocation.current.isPresent else {
            return Just([]).setFailureType(to: Error.self).eraseToAnyPublisher()
        }
        
        return Future { promise in
            let fetchOp = FetchContactsOperation(location: UserLocation.current)
            fetchOp.completionBlock = { [weak fetchOp] in
                guard let op = fetchOp else { return }
                if let error = op.error {
                    promise(.failure(error))
                } else {
                    promise(.success(op.contacts ?? []))
                }
            }
            self.operationQueue.addOperation(fetchOp)
        }.eraseToAnyPublisher()
    }
}

extension Sequence where Element == Contact {
    static var sample: [Contact] {
        [
            Contact(id: "1", area: "US Senate", name: "Ted Cruz", party: "republican", phone: "123-123-1233"),
            Contact(id: "2", area: "US Senate", name: "John Cornyn", party: "republican", phone: "123-123-1233"),
            Contact(id: "3", area: "US House", name: "Michael McCaul", party: "republican", phone: "123-123-1233")
        ]
    }
}
