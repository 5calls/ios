//
//  BackgroundGradient.swift
//  FiveCalls
//
//  Created by Ben Scheirman on 7/7/20.
//  Copyright © 2020 5calls. All rights reserved.
//

import SwiftUI
import WidgetKit

struct BackgroundGradient: View {
    var body: some View {
        LinearGradient(
            gradient: Gradient(
                colors: [
                    Color.blue,
                    Color(.sRGB, red: 0.02, green: 0.16, blue: 0.30, opacity: 1.0)
        ]),
            startPoint: .top,
            endPoint: .bottom)
        .overlay(
            Image("5calls-stars")
                .resizable()
                .aspectRatio(contentMode: .fit)
                .frame(height: 40)
                .padding(8)
                .opacity(1.0),
            alignment: .bottomTrailing
        )
    }
}

struct BackgroundGradient_Previews: PreviewProvider {
    static var previews: some View {
        BackgroundGradient()
            .previewContext(WidgetPreviewContext(family: .systemSmall))
    }
}
