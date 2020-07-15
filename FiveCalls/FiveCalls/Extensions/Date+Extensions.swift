//
//  Date+Extensions.swift
//  FiveCalls
//
//  Created by Ben Scheirman on 7/15/20.
//  Copyright © 2020 5calls. All rights reserved.
//

import Foundation

/// A collection of helpers for getting relatives dates and times
extension Date {
    
    enum Component {
        case days
        case hours
        case minutes
        
        fileprivate var baseTimeInterval: TimeInterval {
            switch self {
            case .minutes: return 60
            case .hours: return 60 * 60
            case .days: return 60 * 60 * 24
            }
        }
    }
    
    func adding(_ value: Int, _ component: Component) -> Date {
        addingTimeInterval(component.baseTimeInterval * Double(value))
    }
    
    func subtracting(_ value: Int, _ component: Component) -> Date {
        return adding(-value, component)
    }
}
