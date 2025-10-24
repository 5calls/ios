// Copyright 5calls. All rights reserved. See LICENSE for details.

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

    func updateUIViewController(_: MFMailComposeViewController,
                                context _: Context) {}

    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }

    class Coordinator: NSObject, MFMailComposeViewControllerDelegate {
        var parent: EmailComposerView

        init(_ parent: EmailComposerView) {
            self.parent = parent
        }

        func mailComposeController(_: MFMailComposeViewController, didFinishWith result: MFMailComposeResult, error: Error?) {
            if let error {
                parent.result(.failure(error))
                return
            }

            parent.result(.success(result))

            parent.presentationMode.wrappedValue.dismiss()
        }
    }
}
