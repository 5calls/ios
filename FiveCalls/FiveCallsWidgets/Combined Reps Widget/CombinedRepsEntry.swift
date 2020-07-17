//
//  CombinedRepsEntry.swift
//  FiveCalls
//
//  Created by Ben Scheirman on 7/15/20.
//  Copyright © 2020 5calls. All rights reserved.
//

import Foundation
import WidgetKit
import SwiftUI

struct CombinedRepsEntry: TimelineEntry {
    let date: Date
    let reps: [Rep]
    let hasLocation: Bool
    
    struct Rep {
        let name: String
        let party: String
        let area: String
        let photo: UIImage?
        
        var accentColor: Color {
            switch party {
            case "democratic": return Color.blue
            case "republican": return Color.red
            default: return Color.white
            }
        }
    }
}
