# 5Calls iOS App

This is the repository for the iOS app for [5Calls.org](https://5calls.org).

[![Build Status](https://app.bitrise.io/app/d786d837d94f6410/status.svg?token=BTL78uVY_9iE4XCx-iTekQ&branch=main)](https://app.bitrise.io/app/d786d837d94f6410)

## Requirements

- Xcode 16
- iOS 16

## Getting Started

Clone the repository and resolve the Swift Packages. The gems installed by Bundler are more for distribution.

### Strings

Although not localized yet, the app uses Xcode's String Catalog feature and the project is set up to track strings automatically.

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
