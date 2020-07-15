//
//  AppURLHandler.swift
//  FiveCalls
//
//  Created by Ben Scheirman on 7/15/20.
//  Copyright © 2020 5calls. All rights reserved.
//

import UIKit

protocol AppURLHandler {
    func canHandle(url: URL) -> Bool
    func handle(url: URL, options: [UIApplication.OpenURLOptionsKey : Any]) -> Bool
}
