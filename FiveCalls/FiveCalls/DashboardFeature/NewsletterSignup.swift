// Copyright 5calls. All rights reserved. See LICENSE for details.

import Combine
import SwiftUI

struct NewsletterSignup: View {
    @State var email: String = ""
    @State var errorString: String?
    var onDismiss: () -> Void
    var onSubmit: (String) -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(
                "The easy way to keep up with Congress",
                comment: "Newsletter signup header text"
            )
            .font(.headline)
            .foregroundStyle(.white)
            if errorString != nil {
                Text(errorString!)
                    .font(.caption)
                    .fontWeight(.semibold)
                    .foregroundStyle(.red)
                    .padding(.bottom, 4)
            } else {
                Text(
                    "Sign up for our newsletter, just one email a week",
                    comment: "Newsletter signup subheader text"
                )
                .font(.caption)
                .foregroundStyle(.white)
                .padding(.bottom, 4)
            }
            TextField(
                "",
                text: $email,
                prompt: Text(
                    "Enter your email",
                    comment: "Newsletter email placeholder text"
                )
                .foregroundColor(
                    .fivecallsDarkGray
                )
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
            .onChange(of: email) { _ in
                // reset the error state when the user starts typing again
                errorString = nil
            }
            HStack {
                Button(action: onDismiss,
                       label: {
                           Label(
                               String(localized: "No thanks", comment: "Newslitter signup decline button text"),
                               systemImage: "nosign"
                           )
                           .padding(.vertical, 6)
                           .frame(maxWidth: .infinity)
                       }).background(.white).clipShape(
                    RoundedRectangle(cornerRadius: 8)
                )
                Button(action: {
                    if !isValidEmail(email) {
                        errorString = String(localized: "This doesn't look like an email", comment: "Newsletter signup invalid email error message")
                    } else {
                        onSubmit(email)
                    }
                }, label: {
                    Label(
                        String(localized: "Sign me up", comment: "Newsletter signup submit button text"),
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
