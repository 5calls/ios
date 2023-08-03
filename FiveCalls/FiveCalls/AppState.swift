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
    
    init() {
        // I guess we could load cached items here
    }
}

protocol AppStateDelegate {
    func setIssues(issues: [Issue])
}
