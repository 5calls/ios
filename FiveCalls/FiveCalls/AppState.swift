//
//  AppState.swift
//  FiveCalls
//
//  Created by Nick O'Neill on 7/24/23.
//  Copyright © 2023 5calls. All rights reserved.
//

import Foundation
import CoreLocation
import os

class AppState: ObservableObject, ReduxState {
    @Published var showWelcomeScreen = false
    @Published var selectedTab = "topics"
    @Published var globalCallCount: Int = 0
    @Published var issueCallCounts: [Int: Int] = [:]
    // issueCompletion is a local cache of completed calls: an array of contact id and outcomes (B0001234-contact) keyed by an issue id
    @Published var issueCompletion: [Int: [String]] = [:] {
        didSet {
            // NSNumber (bridged automatically from Int) is not supported as a key in a plist dictionary, so we stringify and unstringify
            let plistSupportableIssueCache: [String: [String]] = Dictionary(uniqueKeysWithValues: issueCompletion.map { key, value in
                (String(key), value)
            })
            UserDefaults.standard.set(plistSupportableIssueCache, forKey: UserDefaultsKey.issueCompletionCache.rawValue)
        }
    }
    @Published var repMessages: [InboxMessage] = []
    @Published var donateOn = false
    @Published var issues: [Issue] = []
    @Published var issueFetchTime: Date? = nil
    @Published var contacts: [Contact] = []
    @Published var district: String? = nil
    @Published var isSplitDistrict: Bool = false
    @Published var missingReps: [String] = []
    @Published var location: UserLocation? {
        didSet {
            guard let location = self.location else { return }
            let defaults = UserDefaults.standard
            defaults.set(location.locationType.rawValue, forKey: UserDefaultsKey.locationType.rawValue)
            defaults.set(location.locationValue, forKey: UserDefaultsKey.locationValue.rawValue)
            defaults.set(location.locationDisplay, forKey: UserDefaultsKey.locationDisplay.rawValue)
            Logger().info("saved cached location as \(location)")
        }
    }
    @Published var fetchingContacts = false
    // if we don't have any loaded messages, this is set to a message id we expect to receive for immediate navigation,
    // i.e. we've tapped on a push notification about a message
    var wantedMessageID: Int?
    // TODO: display this error on welcome screen and anywhere else that uses stats
    @Published var statsLoadingError: Error? = nil
    // TODO: display this error on the dashboard issue list (and the More page when it exists)
    @Published var issueLoadingError: Error? = nil
    // TODO: display this error on the dashboard (and location sheet?)
    @Published var contactsLoadingError: Error? = nil
    
    @Published var issueRouter: IssueRouter = IssueRouter()
    @Published var inboxRouter: InboxRouter = InboxRouter()

    init() {
        // load user location cache
        if let locationType = UserDefaults.standard.string(forKey: UserDefaultsKey.locationType.rawValue),
            let locationValue = UserDefaults.standard.string(forKey: UserDefaultsKey.locationValue.rawValue) {
            let locationDisplay = UserDefaults.standard.string(forKey: UserDefaultsKey.locationDisplay.rawValue)
            Logger().info("loading cached location: \(locationType) \(locationValue) \(locationDisplay ?? "")")
            
            switch locationType {
            case "address", "zipCode":
                self.location = UserLocation(address: locationValue, display: locationDisplay)
            case "coordinates":
                let locValues = locationValue.split(separator: ",")
                if locValues.count != 2 { return }
                guard let lat = Double(locValues[0]), let lng = Double(locValues[1]) else { return }
                
                self.location = UserLocation(location: CLLocation(latitude: lat, longitude: lng), display: locationDisplay)
            default:
                Logger().warning("unknown stored location type data: \(locationType)")
            }
        }
        
        // load the issue completion cache
        if let plistSupportableIssueCache = UserDefaults.standard.object(forKey: UserDefaultsKey.issueCompletionCache.rawValue) as? [String: [String]] {
            self.issueCompletion = Dictionary(uniqueKeysWithValues: plistSupportableIssueCache.compactMap({ key, value in
                if let intKey = Int(key) {
                    return (intKey, value)
                }
                return nil
            }))
        }
    }
}

extension AppState {
    func issueCalledOn(issueID: Int, contactID: String) -> Bool {
        // a contact outcome is a contactid concatenated with an outcome (B0001234-contact)
        let contactOutcomesForIssue = self.issueCompletion[issueID] ?? []
        
        let contactIDs = contactOutcomesForIssue.map { contactOutcome in
            // Split from the right to handle contact IDs that contain hyphens
            if let lastHyphenIndex = contactOutcome.lastIndex(of: "-") {
                return String(contactOutcome[..<lastHyphenIndex])
            }
            return contactOutcome
        }

        return contactIDs.contains(contactID)
    }
    
    var needsIssueRefresh: Bool {
        guard let issueFetchTime else {
            return true
        }
        
        if issueFetchTime < Date().addingTimeInterval(-1 * 60) {
            return true
        } else {
            return false
        }
    }
}
