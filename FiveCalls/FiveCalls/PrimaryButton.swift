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
    let systemImageName: String
    
    var body: some View {
        HStack {
            Text(title)
                .font(.title3)
                .fontWeight(.semibold)
                .foregroundColor(.white)
            Image(systemName: systemImageName)
                .foregroundColor(.white)
        }
            .padding()
            .frame(maxWidth: .infinity)
            .background {
                RoundedRectangle(cornerRadius: 6)
                    .foregroundColor(Color.FiveCallsDarkBlue)
            }

    }
}

struct PrimaryButton_Previews: PreviewProvider {
    static var previews: some View {
        PrimaryButton(title: "See your script", systemImageName: "megaphone.fill")
            .padding()
    }
}
