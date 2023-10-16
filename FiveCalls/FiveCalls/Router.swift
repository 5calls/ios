//
//  File.swift
//  FiveCalls
//
//  Created by Nick O'Neill on 10/8/23.
//  Copyright © 2023 5calls. All rights reserved.
//

import SwiftUI

class Router: ObservableObject {
    @Published var path = NavigationPath()
    
    func back() {
        path.removeLast()
    }
    
    func backToRoot() {
        path = NavigationPath()
    }
}
