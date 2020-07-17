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
import UIKit

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
    
    private func repsPublisher() -> AnyPublisher<[CombinedRepsEntry.Rep], Error> {
        guard UserLocation.current.isPresent else {
            return Just([]).setFailureType(to: Error.self).eraseToAnyPublisher()
        }

        return Future<[Contact], Error> { promise in
            let fetchOp = FetchContactsOperation(location: UserLocation.current)
            fetchOp.completionBlock = { [weak fetchOp] in
                guard let op = fetchOp else { return }
                if let error = op.error {
                    promise(.failure(error))
                } else {
                    let contacts: [Contact] = op.contacts ?? []
                    promise(.success(contacts))
                }
            }
            self.operationQueue.addOperation(fetchOp)
        }
        .flatMap { self.contactsToReps($0) }
        .eraseToAnyPublisher()
    }
    
    private func contactsToReps(_ contacts: [Contact]) -> AnyPublisher<[CombinedRepsEntry.Rep], Error> {
        let publishers = contacts.map { self.contactToRep($0) }
        return Publishers.MergeMany(publishers)
            .collect()
            .eraseToAnyPublisher()
    }
    
    private func contactToRep(_ contact: Contact) -> AnyPublisher<CombinedRepsEntry.Rep, Error> {
        contactImagePublisher(contact)
            .map { image in
                CombinedRepsEntry.Rep(name: contact.name, party: contact.party, area: contact.area, photo: image)
            }
            .eraseToAnyPublisher()
    }
    
    private func contactImagePublisher(_ contact: Contact) -> AnyPublisher<UIImage?, Error> {
        guard let photoURL = contact.photoURL else {
            return Just(nil)
                .setFailureType(to: Error.self)
                .eraseToAnyPublisher()
        }
        
        return URLSession.shared.dataTaskPublisher(for: photoURL)
            .map { $0.data }
            .map { (data: Data) in UIImage(data: data) }
            .mapError { $0 as Error }
            .eraseToAnyPublisher()
    }
    
}

extension Sequence where Element == CombinedRepsEntry.Rep {
    static var sample: [CombinedRepsEntry.Rep] {
        [
            CombinedRepsEntry.Rep(name: "Ted Cruz", party: "republican", area: "US Senate", photo: loadPreviewContentImage("ted-cruz")),
            CombinedRepsEntry.Rep(name: "John Cornyn", party: "republican", area: "US Senate", photo: loadPreviewContentImage("john-cornyn")),
            CombinedRepsEntry.Rep(name: "Michael McCaul", party: "republican", area: "US House", photo: loadPreviewContentImage("michael-mccaul"))
        ]
    }
    
    private static func loadPreviewContentImage(_ name: String) -> UIImage {
        let url = Bundle.main.url(forResource: name, withExtension: "jpg")!
        let data = try! Data(contentsOf: url)
        return UIImage(data: data)!
    }
}
