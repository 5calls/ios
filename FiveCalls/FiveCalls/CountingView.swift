//
//  CountingView.swift
//  FiveCalls
//
//  Created by Abizer Nasir on 28/09/2025.
//  Copyright © 2025 5calls. All rights reserved.
//


import SwiftUI
import StoreKit
import OneSignal

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
        return size.width * (CGFloat(count) / nextMilestone)
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
            return 100000
        } else if count < 450000 {
            return 500000
        } else if count < 900000 {
            return 1000000
        } else if count < 1500000 {
            return 2000000
        } else if count < 4500000 {
            return 5000000
        } else if count < 9500000 {
            return 10000000
        } else if count < 12500000 {
            return 13000000
        } else if count < 14500000 {
            return 15000000
        }

        return 0
    }
}

#Preview {
    CountingView(title: "Calls on this topic", count: 20)
        .frame(height: 50)
        .padding()
}
