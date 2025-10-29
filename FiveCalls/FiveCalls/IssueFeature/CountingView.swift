// Copyright 5calls. All rights reserved. See LICENSE for details.

import OneSignal
import StoreKit
import SwiftUI

struct CountingView: View {
    let title: LocalizedStringResource
    let count: Int

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            Text(title)
                .font(.title3)
                .fontWeight(.medium)
                .padding(.bottom, 4)
            ZStack(alignment: .leading) {
                Canvas { context, size in
                    let drawRect = CGRect(origin: .zero, size: size)

                    context.fill(Rectangle().size(size).path(in: drawRect), with: .color(.fivecallsLightBG))
                    context.fill(Rectangle().size(width: progressWidth(size: size), height: size.height).path(in: drawRect), with: .color(.fivecallsDarkBlue))
                }
                .clipShape(RoundedRectangle(cornerRadius: 5.0))
                Text(verbatim: "\(count)")
                    .foregroundStyle(.white)
                    // yes, blue background may be redundant, but it ensures that the white text can always be read, even with very large fonts
                    .background(.fivecallsDarkBlue)
                    .padding(.vertical, 2)
                    .padding(.horizontal, 6)
            }
        }
        .accessibilityElement(children: .combine)
    }

    func progressWidth(size: CGSize) -> CGFloat {
        size.width * (CGFloat(count) / nextMilestone)
    }

    var nextMilestone: CGFloat {
        if count < 80 {
            return 100
        } else if count < 450 {
            return 500
        } else if count < 900 {
            return 1000
        } else if count < 4500 {
            return 5000
        } else if count < 9000 {
            return 10000
        } else if count < 45000 {
            return 50000
        } else if count < 90000 {
            return 100_000
        } else if count < 450_000 {
            return 500_000
        } else if count < 900_000 {
            return 1_000_000
        } else if count < 1_500_000 {
            return 2_000_000
        } else if count < 4_500_000 {
            return 5_000_000
        } else if count < 9_500_000 {
            return 10_000_000
        } else if count < 12_500_000 {
            return 13_000_000
        } else if count < 14_500_000 {
            return 15_000_000
        }

        return 0
    }
}

#Preview {
    CountingView(title: "Calls on this topic", count: 20)
        .frame(height: 50)
        .padding()
}
