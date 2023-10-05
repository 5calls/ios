//
//  EmailComposerView.swift
//  FiveCalls
//
//  Created by Christopher Selin on 9/26/23.
//  Copyright © 2023 5calls. All rights reserved.
//

import MessageUI
import SwiftUI

struct EmailComposerView: UIViewControllerRepresentable {
    @Environment(\.presentationMode) private var presentationMode
    var result: (Result<MFMailComposeResult, Error>) -> Void
    
    static func canSendEmail() -> Bool {
        MFMailComposeViewController.canSendMail()
    }
    
    func makeUIViewController(context: Context) -> MFMailComposeViewController {
        let emailComposer = MFMailComposeViewController()
        emailComposer.mailComposeDelegate = context.coordinator
        emailComposer.setToRecipients(["hello@5calls.org"])
        emailComposer.setMessageBody("", isHTML: true)
        return emailComposer
    }
    
    func updateUIViewController(_ uiViewController: MFMailComposeViewController,
                                context: Context) { }
    
    func makeCoordinator() -> Coordinator {
         Coordinator(self)
     }
    
    class Coordinator: NSObject, MFMailComposeViewControllerDelegate {
        var parent: EmailComposerView
        
        init(_ parent: EmailComposerView) {
            self.parent = parent
        }
        
        func mailComposeController(_ controller: MFMailComposeViewController, didFinishWith result: MFMailComposeResult, error: Error?) {
                
                if let error = error {
                    parent.result(.failure(error))
                    return
                }
                
                parent.result(.success(result))
                
                parent.presentationMode.wrappedValue.dismiss()
            }
    }
}
