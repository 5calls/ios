//
//  StatsViewModel.swift
//  FiveCalls
//
//  Created by Ben Scheirman on 1/30/17.
//  Copyright © 2017 5calls. All rights reserved.
//

import Foundation

struct StatsViewModel {
    let numberOfCalls: Int
    
    var formattedNumberOfCalls: String! {
        let numberFormatter = NumberFormatter()
        
        numberFormatter.formatterBehavior = .behavior10_4
        numberFormatter.numberStyle = .decimal
        
        return numberFormatter.string(from: NSNumber(integerLiteral: numberOfCalls))
    }
}
