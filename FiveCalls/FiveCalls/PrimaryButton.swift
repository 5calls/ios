//
//  PrimaryButton.swift
//  FiveCalls
//
//  Created by Nick O'Neill on 8/28/23.
//  Copyright © 2023 5calls. All rights reserved.
//

import SwiftUI

struct PrimaryButton: View {
    let title: String
    var systemImageName: String? = ""
    
    var bgColor: Color = .fivecallsDarkBlue
        
    var body: some View {
        HStack {
            Text(title)
                .font(.title3)
                .fontWeight(.semibold)
                .foregroundColor(.white)
                .lineLimit(1)
            if let systemImageName {
                Image(systemName: systemImageName)
                    .foregroundColor(.white)
            }
        }
        .accessibilityElement(children: .combine)
        .padding(.vertical)
        .frame(maxWidth: .infinity)
        .background {
            RoundedRectangle(cornerRadius: 6)
                .foregroundColor(bgColor)
        }
    }
}

#Preview {
    VStack {
        PrimaryButton(title: "See your script", systemImageName: "megaphone.fill")
                .padding()
        PrimaryButton(title: "See your script")
            .padding(.horizontal, 100)
    }
}
