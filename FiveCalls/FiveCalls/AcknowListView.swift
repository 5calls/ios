//
//  AcknowListView.swift
//  FiveCalls
//
//  Created by Christopher Selin on 1/3/24.
//  Copyright © 2024 5calls. All rights reserved.
//

import AcknowList
import SwiftUI

struct AcknowListView: UIViewControllerRepresentable {
    func makeUIViewController(context: Context) -> AcknowListViewController {
        return AcknowListViewController()
    }
    
    func updateUIViewController(_ uiViewController: AcknowListViewController, context: Context) { }
}
