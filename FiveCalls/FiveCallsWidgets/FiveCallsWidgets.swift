//
//  FiveCallsWidgets.swift
//  FiveCallsWidgets
//
//  Created by Ben Scheirman on 7/3/20.
//  Copyright © 2020 5calls. All rights reserved.
//

import WidgetKit
import SwiftUI
import Intents


@main
struct FiveCallsWidgets: WidgetBundle {
    @WidgetBundleBuilder
    var body: some Widget {
        SmallCallsWidget()
        IssuesWidget()
    }
}
