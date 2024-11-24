//
//  NewsletterSignup.swift
//  FiveCalls
//
//  Created by Nick O'Neill on 11/21/24.
//  Copyright © 2024 5calls. All rights reserved.
//

import SwiftUI
import Combine

struct NewsletterSignup: View {
    @State var email: String = ""
    @State var errorString: String?
    var onDismiss: () -> Void
    var onSubmit: (String) -> Void
    
    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(R.string.localizable.newsletterHeader)
                .font(.headline)
                .foregroundStyle(.white)
            if errorString != nil {
                Text(errorString!)
                    .font(.caption)
                    .fontWeight(.semibold)
                    .foregroundStyle(.red)
                    .padding(.bottom, 4)
            } else {
                Text(R.string.localizable.newsletterSubhead())
                    .font(.caption)
                    .foregroundStyle(.white)
                    .padding(.bottom, 4)
            }
            TextField(
                "",
                text: $email,
                prompt: Text(R.string.localizable.newsletterEmailPlaceholder())
                    .foregroundColor(.fivecallsDarkGray)
            )
                .font(.headline)
                .padding(.horizontal, 4)
                .padding(.vertical, 8)
                .foregroundColor(.black)
                .background(.white)
                .clipShape(RoundedRectangle(cornerRadius: 4))
                .keyboardType(.emailAddress)
                .autocorrectionDisabled()
                .textInputAutocapitalization(.never)
                .onChange(of: email) { newValue in
                    // reset the error state when the user starts typing again
                    errorString = nil
                }
            HStack {
                Button(action: onDismiss,
                    label: {
                        Label(
                            R.string.localizable.newsletterDismiss(),
                            systemImage: "nosign"
                        )
                        .padding(.vertical, 6)
                        .frame(maxWidth: .infinity)
                }).background(.white).clipShape(
                    RoundedRectangle(cornerRadius: 8)
                )
                Button(action: {
                    if !isValidEmail(email) {
                        errorString = R.string.localizable
                            .newsletterInvalidEmail()
                    } else {
                        onSubmit(email)
                    }
                }, label: {
                    Label(
                        R.string.localizable.newsletterSubscribe(),
                        systemImage: "paperplane"
                    ).padding(.vertical, 6)
                     .frame(maxWidth: .infinity)
                }).background(.white).clipShape(
                    RoundedRectangle(cornerRadius: 8)
                )
            }.padding(.top, 6)
        }.padding()
        .background(.fivecallsDarkBlue)
        .clipShape(RoundedRectangle(cornerRadius: 10))
        .padding()
    }
}

func isValidEmail(_ email: String) -> Bool {
    let emailRegex = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,64}"
    let emailPredicate = NSPredicate(format: "SELF MATCHES %@", emailRegex)
    return emailPredicate.evaluate(with: email)
}

#Preview {
    NewsletterSignup(onDismiss: {}, onSubmit: { _ in })
    NewsletterSignup(email: "some@email.com", onDismiss: {}, onSubmit: { _ in })
    NewsletterSignup(errorString: "Invalid email", onDismiss: {}, onSubmit: { _ in })
}

#Preview {
    NewsletterSignup(onDismiss: {}, onSubmit: { _ in }).preferredColorScheme(.dark)
    NewsletterSignup(email: "some@email.com", onDismiss: {}, onSubmit: { _ in })
}
