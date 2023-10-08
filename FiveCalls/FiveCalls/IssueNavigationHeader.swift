//
//  IssueNavigationHeader.swift
//  FiveCalls
//
//  Created by Nick O'Neill on 10/8/23.
//  Copyright © 2023 5calls. All rights reserved.
//

import SwiftUI

struct IssueNavigationHeader: View {
    @Environment(\.dismiss) var dismiss
    
    var body: some View {
        HStack(alignment: .top) {
            Button {
                dismiss()
            } label: {
                HStack(spacing: 4) {
                    Image(systemName: "chevron.backward.circle")
                        .font(.title2)
                    Text("Back")
                        .fontWeight(.medium)
                }
            }
            Spacer()
            Button {
                
            } label: {
                HStack(spacing: 4) {
                    Text("Share")
                        .fontWeight(.medium)
                    Image(systemName: "square.and.arrow.up.circle")
                        .font(.title2)
                }
            }
        }
    }
}

#Preview {
    IssueNavigationHeader()
}
