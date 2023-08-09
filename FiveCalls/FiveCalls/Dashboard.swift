//
//  Dashboard.swift
//  FiveCalls
//
//  Created by Nick O'Neill on 6/28/23.
//  Copyright © 2023 5calls. All rights reserved.
//

import SwiftUI

struct Dashboard: View {
    @EnvironmentObject var appState: AppState
    
    @State var showLocationSheet = false
    
    let op = Operator()
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 10) {
                LocationHeader(location: appState.location)
                    .padding(.bottom, 10)
                    .onTapGesture {
                        showLocationSheet.toggle()
                    }
                    .sheet(isPresented: $showLocationSheet) {
                        LocationSheet(location: appState.location, delegate: (UIApplication.shared.delegate as! AppDelegate))
                            .presentationDetents([.medium])
                            .presentationDragIndicator(.visible)
                            .padding(.top, 40)
                        Spacer()
                    }
                Text("What’s important to you?")
                    .font(.system(size: 20))
                    .fontWeight(.semibold)
                ForEach(appState.issues) { issue in
                    IssueListItem(issue: issue, contacts: appState.contacts)
                }
            }.padding(.horizontal, 10)
        }.onAppear {
            // TODO: refresh if issues are old too?
            if appState.issues.isEmpty {
                op.fetchIssues(delegate: (UIApplication.shared.delegate as! AppDelegate), completion: { result in
                    if case let .serverError(error) = result {
                        print("issues error: \(error)")
                    }
                    if case .offline = result {
                        print("issues offline")
                    }
                })
            }
            
            if appState.contacts.isEmpty && appState.location != nil {
                op.fetchContacts(location: appState.location!, delegate: (UIApplication.shared.delegate as! AppDelegate)) { result in
                    if case let .serverError(error) = result {
                        print("contacts error: \(error)")
                    }
                    if case .offline = result {
                        print("contacts offline")
                    }

                }
            }
        }
    }
}

struct Dashboard_Previews: PreviewProvider {
    static let previewState = {
        var state = AppState()
        state.issues = [
            Issue.basicPreviewIssue,
            Issue.multilinePreviewIssue
        ]
        state.contacts = [
            Contact.housePreviewContact,
            Contact.senatePreviewContact1,
            Contact.senatePreviewContact2
        ]
        return state
    }()
    
    static var previews: some View {
        Dashboard().environmentObject(previewState)
    }
}
