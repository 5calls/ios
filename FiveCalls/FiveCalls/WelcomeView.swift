//
//  WelcomeView.swift
//  FiveCalls
//
//  Created by Christopher Selin on 9/26/23.
//  Copyright © 2023 5calls. All rights reserved.
//

import SwiftUI

struct WelcomeView: UIViewControllerRepresentable {
    func makeUIViewController(context: Context) -> some UIViewController {
        return R.storyboard.welcome.welcomeViewController()!
    }
    
    func updateUIViewController(_ uiViewController: UIViewControllerType, context: Context) { }
}
