// Copyright 5calls. All rights reserved. See LICENSE for details.

import SwiftUI

struct SearchBar: View {
    @Binding var searchText: String
    @EnvironmentObject var store: Store

    @FocusState private var isSearchFocused: Bool
    @State private var searchWorkItem: DispatchWorkItem?
    @State private var hasLoggedCurrentSearch = false

    var body: some View {
        HStack {
            HStack {
                Image(systemName: "magnifyingglass")
                    .foregroundColor(.secondary)

                TextField(
                    String(
                        localized: "Search all issues...",
                        comment: "SearchBar placeholder text"
                    ),
                    text: $searchText
                )
                .textFieldStyle(PlainTextFieldStyle())
                .focused($isSearchFocused)
                .onChange(of: searchText) {
                    handleSearchTextChange(searchText)
                }
                .onSubmit {}

                if !searchText.isEmpty {
                    Button {
                        clearSearch()
                    } label: {
                        Image(systemName: "xmark.circle.fill")
                            .foregroundColor(.secondary)
                    }
                }
            }
            .padding(.horizontal, 10)
            .padding(.vertical, 8)
            .background(Color(.systemGray6))
            .clipShape(RoundedRectangle(cornerRadius: 10))
        }
        .padding(.horizontal, 16)
        .padding(.bottom, 8)
    }

    private func handleSearchTextChange(_ newValue: String) {
        if newValue.count > 30 {
            searchText = String(newValue.prefix(30))
            return
        }

        // Cancel previous search logging work item
        searchWorkItem?.cancel()

        // Reset logging flag when search is cleared
        if newValue.isEmpty {
            hasLoggedCurrentSearch = false
            return
        }

        // Only log once per search session (until cleared) for searches >= 3 characters
        if newValue.count >= 3, !hasLoggedCurrentSearch {
            let workItem = DispatchWorkItem {
                // Double-check that we haven't logged yet during the delay
                if !hasLoggedCurrentSearch {
                    hasLoggedCurrentSearch = true
                    store.dispatch(action: .LogSearch(newValue))
                }
            }
            searchWorkItem = workItem
            DispatchQueue.main.asyncAfter(deadline: .now() + 1.0, execute: workItem)
        }
    }

    private func clearSearch() {
        searchText = ""
        isSearchFocused = false
        hasLoggedCurrentSearch = false
        searchWorkItem?.cancel()
    }
}
