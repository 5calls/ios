//
//  AboutSheet.swift
//  FiveCalls
//
//  Created by Christopher Selin on 9/18/23.
//  Copyright © 2023 5calls. All rights reserved.
//

import SwiftUI
import MessageUI

private let appId = "1202558609"

private let appUrl = URL(string: "https://itunes.apple.com/us/app/myapp/id\(appId)?ls=1&mt=8")

struct AboutSheet: View {
    @Environment(\.dismiss) var dismiss
    
    @State var showEmailComposer = false
    @State var showEmailComposerAlert = false
    
    var body: some View {
        VStack(spacing: .zero) {
            ZStack {
                Rectangle()
                    .foregroundColor(Color.fivecallsDarkBlue)
                    .frame(height: 56)
                HStack {
                    Spacer()
                    Button(action: {
                        dismiss()
                    }, label: {
                        Text(R.string.localizable.doneButtonTitle())
                            .bold()
                            .foregroundColor(.white)
                    })
                }
                .padding(.horizontal)
                
                Text(R.string.localizable.aboutTitle())
                    .font(Font(UIFont.fvc_header))
                    .bold()
                    .foregroundColor(.white)
            }
            
            List {
                Section(header: Text("GENERAL")) {
                    Button("Feedback") {
                        if EmailComposerView.canSendEmail() {
                            showEmailComposer = true
                        } else {
                            showEmailComposerAlert = true
                        }                    }
                    .sheet(isPresented: $showEmailComposer, content: {
                        EmailComposerView() { _ in }
                    })
                    .alert(isPresented: $showEmailComposerAlert) {
                        Alert(title: Text(R.string.localizable.cantSendEmailTitle()),
                              message: Text(R.string.localizable.cantSendEmailMessage()),
                                dismissButton: .default(Text(R.string.localizable.dismissTitle())))
                    }
                }
                
                Section(header: Text("SOCIAL")) {
                    
                }
            }
        }
    }
}

struct AboutSheet_Previews: PreviewProvider {
    static var previews: some View {
        AboutSheet()
    }
}

struct EmailComposerView: UIViewControllerRepresentable {
    @Environment(\.presentationMode) private var presentationMode
    var result: (Result<MFMailComposeResult, Error>) -> Void
    
    static func canSendEmail() -> Bool {
        MFMailComposeViewController.canSendMail()
    }
    
    func makeUIViewController(context: Context) -> MFMailComposeViewController {
        let emailComposer = MFMailComposeViewController()
        emailComposer.mailComposeDelegate = context.coordinator
        emailComposer.setToRecipients(["make5calls@gmail.com"])
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
