# 5Calls iOS App

This is the repository for the iOS app for [5Calls.org](https://5calls.org).

[![Build Status](https://app.bitrise.io/app/d786d837d94f6410/status.svg?token=BTL78uVY_9iE4XCx-iTekQ&branch=main)](https://app.bitrise.io/app/d786d837d94f6410)

## Requirements

- Xcode 13
- iOS 12

## Getting Started

Install the dependencies:

```
bundle install
```

## Using R.swift

R.swift removes the need to use "stringly typed" resources. Instead, you can reference your app's resources Android-style, which is strongly typed. Benefits are less casting, compile time checking for resources, and a little less code. [See examples for each type here.](https://github.com/mac-cain13/R.swift/blob/master/Documentation/Examples.md)

**Note**: Since 5Calls uses prototype cells instead of cell nibs, this is all you need to dequeue a cell:

```
let cell = tableView.dequeueReusableCell(withIdentifier: R.reuseIdentifier.setLocationCell, for: indexPath)!
```

Vendor the R.swift binary from the latest release (https://github.com/mac-cain13/R.swift/releases) into `vendor/rswift` if you're getting started with this project for the first time.

## Testflight Builds

> _This currently has to be done by Ben_

Install the dependencies:

```
bundle install
```

Make sure you have a `.env` file with the following keys defined:

- `APPLE_ID`
- `TEAM_ID`
- `ITUNES_CONNECT_TEAM_ID`
- `FASTLANE_APPLE_APP_SPECIFIC_PASSWORD`

Update the build number manually (for now).

Then run:

```
fastlane beta
```

## License

This project is released open source under the MIT License. See [LICENSE](https://raw.githubusercontent.com/5calls/ios/master/LICENSE) for more details.

## Contributors

See the complete list of contributors here: https://github.com/5calls/ios/graphs/contributors
