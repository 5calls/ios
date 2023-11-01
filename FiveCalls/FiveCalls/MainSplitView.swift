//
//  MainSplitView.swift
//  FiveCalls
//
//  Created by Christopher Selin on 11/1/23.
//  Copyright © 2023 5calls. All rights reserved.
//

import SwiftUI

struct MainSplitView: View {
    @EnvironmentObject var store: Store
    @EnvironmentObject var router: Router
    
    var body: some View {
        NavigationSplitView(sidebar: {
            Dashboard().environmentObject(router)
        }, detail: {
//            if selectedIssue == nil {
                Text("Please select an issue")
//            }
        })
        .navigationSplitViewStyle(.balanced)
        .onChange(of: router.path) { change in
            print("router.path changed: \(change)")
        }
    }
}

#Preview {
    MainSplitView()
}
