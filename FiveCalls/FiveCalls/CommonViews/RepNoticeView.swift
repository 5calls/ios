// Copyright 5calls. All rights reserved. See LICENSE for details.

import SwiftUI

/// The server's notice above the caller's reps, styled like the warning box on the website.
struct RepNoticeView: View {
    let notice: RepNotice

    var body: some View {
        HStack(alignment: .firstTextBaseline, spacing: 8) {
            Image(systemName: "exclamationmark.triangle.fill")
                .foregroundColor(.fivecallsNoticeAccent)
                .accessibilityHidden(true)
            Text(notice.text)
                .font(.callout)
                .foregroundColor(.primary)
                .fixedSize(horizontal: false, vertical: true)
            Spacer(minLength: 0)
        }
        .padding(.vertical, 10)
        .padding(.horizontal, 12)
        .background(Color.fivecallsNoticeBG)
        .overlay(alignment: .leading) {
            Rectangle()
                .fill(Color.fivecallsNoticeAccent)
                .frame(width: 3)
        }
        .clipShape(RoundedRectangle(cornerRadius: 6))
        .accessibilityElement(children: .combine)
        .accessibilityIdentifier("repNotice")
    }
}

#Preview {
    RepNoticeView(notice: RepNotice(
        id: 1,
        text: "New members of Congress take office in January 2027. Until then, these are your current representatives.",
        expiresAt: nil
    ))
    .padding()
}
