//
//  WelcomeView.swift
//  FiveCalls
//
//  Created by Christopher Selin on 9/26/23.
//  Copyright © 2023 5calls. All rights reserved.
//

import SwiftUI

struct WelcomeView: UIViewControllerRepresentable {
    @Environment(\.dismiss) var dismiss

    func makeUIViewController(context: Context) -> some UIViewController {
        let welcomeVC = R.storyboard.welcome.welcomeViewController()!
        welcomeVC.completionBlock = {
            self.dismiss()
        }
        return welcomeVC
    }
    
    func updateUIViewController(_ uiViewController: UIViewControllerType, context: Context) { }
}
