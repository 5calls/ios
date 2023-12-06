//
//  Action.swift
//  FiveCalls
//
//  Created by Christopher Selin on 9/22/23.
//  Copyright © 2023 5calls. All rights reserved.
//
import Foundation

enum Action {
    case FetchStats(Int?)
    case SetGlobalCallCount(Int)
    case SetIssueCallCount(Int,Int)
    case SetIssueContactCompletion(Int,String)
    case SetDonateOn(Bool)
    case FetchIssues
    case SetIssues([Issue])
    case FetchContacts(NewUserLocation)
    case SetContacts([Contact])
    case SetLocation(NewUserLocation)
    case ReportOutcome(Issue, ContactLog, Outcome)
    case SetFetchingContacts(Bool)
    case SetLoadingStatsError(Error)
    case SetLoadingIssuesError(Error)
    case SetLoadingContactsError(Error)
}
