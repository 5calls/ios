# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Common Development Commands

### Building and Testing
- **Run tests**: `fastlane test` or `xcodebuild test -project FiveCalls/FiveCalls.xcodeproj -scheme FiveCalls -destination 'platform=iOS Simulator,name=iPhone 17 Pro' -skipPackagePluginValidation` (use any simulator from `xcrun simctl list devices available`)
- **Run coverage**: `fastlane coverage` (requires running tests first, minimum coverage 25%)
- **Build project**: Open `FiveCalls/FiveCalls.xcodeproj` in Xcode or use `xcodebuild build -project FiveCalls/FiveCalls.xcodeproj -scheme FiveCalls`
- **Run single test**: Use Xcode test navigator or `xcodebuild test -project FiveCalls/FiveCalls.xcodeproj -scheme FiveCalls -only-testing:FiveCallsTests/TestClassName/testMethodName`

### Deployment
- **TestFlight beta**: `fastlane beta` (requires Apple Developer credentials in `.env`: APPLE_ID, TEAM_ID, ITUNES_CONNECT_TEAM_ID, FASTLANE_APPLE_APP_SPECIFIC_PASSWORD)
- **App Store release**: `fastlane release`
- **Take screenshots**: `fastlane snapshots` (uses SnapshotHelper.swift)
- **Increment build**: `fastlane increment_build`
- **Get app version**: `fastlane app_version`

### Dependencies
- **Install Ruby dependencies**: `bundle install`
- **Swift Package Dependencies**: PlausibleSwift, AcknowList, MarkdownUI (managed via Xcode)

## Architecture Overview

### Redux-Style State Management
The app uses a Redux-inspired architecture centered around:
- **Store**: Central state container (`Store.swift`) - ObservableObject that holds AppState
- **AppState**: Global application state (`AppState.swift`) - Contains @Published properties for UI binding
- **Actions**: Defined in `Actions.swift` enum - All possible state changes (~30 actions)
- **Middleware**: Handles side effects in `Middleware.swift` - Async operations like API calls
- **Dispatcher**: Type alias for `(Action) -> Void` - Function to dispatch actions
- **Reducer**: Pure functions that update state based on actions

State flow: UI → Action → Store.dispatch → Reducer (sync state update) → Middleware (async side effects) → UI updates via @Published

### Core Components
- **SwiftUI**: Primary UI framework with environmentObject for Store injection
- **Navigation**: Uses `NavigationPath` for programmatic navigation
  - `IssueRouter`: Simple router with NavigationPath and selectedIssue
  - `InboxRouter`: Manages inbox message navigation
- **App Entry**: `App.swift` sets up Store with AppState and middleware array

### Data Models and API Integration
- **Issue**: Legislative issues with call scripts, contacts, and completion tracking
- **Contact**: Representatives with area offices, phone numbers, and call tracking
- **UserLocation**: Manages location (address/zip/coords) with automatic UserDefaults persistence
- **InboxMessage**: Messages from representatives (currently disabled in middleware)
- **ContactLog**: Tracks call outcomes per contact per issue
- **Outcome**: Call result status (contacted, unavailable, skip, etc.)

### Network Operations (BaseOperation subclasses)
- **FetchIssuesOperation**: Loads current legislative issues from API
- **FetchContactsOperation**: Gets user's representatives based on location
- **FetchMessagesOperation**: Inbox messages (currently unused)
- **FetchStatsOperation**: Global and per-issue call statistics
- **ReportOutcomeOperation**: Reports call completion to API
- **LogSearchOperation**: Tracks search queries for analytics
- **RegisterPushTokenOperation / UnregisterPushTokenOperation**: Add or remove this device's APNs token (with district) at `/v1/push/register`

### Key Features
- **Issue Tracking**: Users call representatives about legislative issues
- **Contact Management**: Location-based representative lookup and caching
- **Call Completion**: Persistent tracking via issueCompletion dictionary in AppState
- **Location Services**: Determines representatives based on address, zip, or coordinates
- **Push Notifications**: Plain APNs, no vendor SDK. `PushRegistration` requests permission, sends the device token and district to the 5calls API, and removes the token if notifications are turned off in Settings. `AppDelegate` syncs on every launch
- **Analytics**: PlausibleSwift for privacy-focused tracking

### Testing Strategy
- **XCTest**: Unit tests in `FiveCallsTests/` covering parsing, state, and business logic
- **UI Tests**: `FiveCallsUITests/` with mock JSON responses for API calls
- **Preview Data**: `PreviewContacts.swift`, `PreviewIssues.swift` for SwiftUI previews
- **Mock Support**: `ProtocolMock.swift` for test doubles
- **System APIs**: Logic that depends on things tests can't control (notification permission, dates) is pulled into pure static functions and tested directly, e.g. `IssueDone.shouldPromptForNotifications` and `PushRegistration.syncAction`
- **New test files**: The test target lists files explicitly, so new test files must be added to `project.pbxproj`

### State Persistence and Caching
- **UserDefaults**: User location, completion cache, app preferences
- **Issue Completion Cache**: Stringified dictionary `[String: [String]]` for plist compatibility
- **Location Caching**: Automatic save on UserLocation changes with logging
- **App State Restoration**: Location and preferences restored on app launch

### Important Patterns
- **Action Dispatch**: `store.dispatch(action: .ActionName(params))` from UI
- **State Observation**: SwiftUI views observe Store via `@EnvironmentObject`
- **Async Operations**: Middleware pattern for side effects (API calls, analytics)
- **Resource Management**: `Localizable.xcstrings` string catalog with `String(localized:)`, and Xcode-generated asset symbols (e.g. `.fivecallsDarkBlue`)
- **Navigation**: Centralized routers manage NavigationPath for deep linking support