# 5Calls iOS App

This is the repository for the iOS app for [5Calls.org](https://5calls.org).

[![BuddyBuild](https://dashboard.buddybuild.com/api/statusImage?appID=5897bfe9e9a832010023be69&branch=master&build=latest)](https://dashboard.buddybuild.com/apps/5897bfe9e9a832010023be69/build/latest?branch=master)

## Requirements

- Xcode 8
- iOS 10

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

- [Ben Scheirman](https://github.com/subdigital)
- [Chris Brandow](https://github.com/chrisbrandow)
- [Patrick McCarron](https://github.com/mccarron)
- [BJ Titus](https://github.com/bjtitus)
- [All Contributors](https://github.com/5calls/ios/graphs/contributors)

## Acknowledgments

Thanks to [Nick O'Neill](https://github.com/nickoneill) for organizing the 5calls project.
