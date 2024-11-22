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
            Text("The easy way to keep up with Congress")
                .font(.headline)
                .foregroundStyle(.white)
            if errorString != nil {
                Text(errorString!)
                    .font(.caption)
                    .fontWeight(.semibold)
                    .foregroundStyle(.red)
                    .padding(.bottom, 4)
            } else {
                Text("Sign up for our newsletter, just one email a week")
                    .font(.caption)
                    .foregroundStyle(.white)
                    .padding(.bottom, 4)
            }
            EmailInput(email: $email)
                .padding(.horizontal, 4)
                .padding(.vertical, 8)
                .foregroundStyle(.white)
                .background(.white)
                .clipShape(RoundedRectangle(cornerRadius: 4))
            HStack {
                Button(action: onDismiss, label: {
                    Label("No thanks", systemImage: "nosign")
                        .padding(.vertical, 6)
                        .frame(maxWidth: .infinity)
                }).background(.white).clipShape(
                    RoundedRectangle(cornerRadius: 8)
                )
                Button(action: { onSubmit(email) }, label: {
                    Label("Sign me up", systemImage: "paperplane")
                        .padding(.vertical, 6)
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

// this view has a textfield for email input and validates the email
struct EmailInput: View {
    var placeHolder: String = "Enter your email"
    @Binding var email: String
    
    var body: some View {
        TextField("Enter your email", text: $email)
            .font(.headline)
            .foregroundStyle(.black)
            .keyboardType(.emailAddress)
            .autocorrectionDisabled()
            .textInputAutocapitalization(.never)
            .onReceive(Just(email)) { newValue in
                email = newValue
//                if !newValue.isValidEmail {
//                    email = ""
//                }
            }
    }
}

#Preview {
    NewsletterSignup(onDismiss: {}, onSubmit: { _ in })
    NewsletterSignup(email: "some@email.com", onDismiss: {}, onSubmit: { _ in })
    NewsletterSignup(errorString: "Invalid email", onDismiss: {}, onSubmit: { _ in })
}
