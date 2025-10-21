// Copyright 5calls. All rights reserved. See LICENSE for details.

import Foundation

func isUITesting() -> Bool {
    ProcessInfo.processInfo.environment["UI_TESTING"] == "1"
}
