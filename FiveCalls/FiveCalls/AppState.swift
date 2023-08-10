//
//  AppState.swift
//  FiveCalls
//
//  Created by Nick O'Neill on 7/24/23.
//  Copyright © 2023 5calls. All rights reserved.
//

import Foundation

class AppState: ObservableObject {
    @Published var issues: [Issue] = []
    @Published var contacts: [Contact] = []
    @Published var fetchingContacts = false
    @Published var location: UserLocation?
    
    init() {
        // I guess we could load cached items here
    }
}

protocol AppStateDelegate {
    func setIssues(issues: [Issue])
    func setContacts(contacts: [Contact])
    func setFetchingContacts(fetching: Bool)
    func setLocation(location: UserLocation)
}
