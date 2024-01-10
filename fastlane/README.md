fastlane documentation
----

# Installation

Make sure you have the latest version of the Xcode command line tools installed:

```sh
xcode-select --install
```

For _fastlane_ installation instructions, see [Installing _fastlane_](https://docs.fastlane.tools/#installing-fastlane)

# Available Actions

## iOS

### ios test

```sh
[bundle exec] fastlane ios test
```

Runs all the tests

### ios coverage

```sh
[bundle exec] fastlane ios coverage
```

Runs code coverage

### ios increment_build

```sh
[bundle exec] fastlane ios increment_build
```

Increments build number

### ios app_version

```sh
[bundle exec] fastlane ios app_version
```



### ios beta

```sh
[bundle exec] fastlane ios beta
```

Submit a new Beta Build to Apple TestFlight

This will also make sure the profile is up to date

### ios release

```sh
[bundle exec] fastlane ios release
```

Deploy a new version to the App Store

### ios snapshots

```sh
[bundle exec] fastlane ios snapshots
```



----

This README.md is auto-generated and will be re-generated every time [_fastlane_](https://fastlane.tools) is run.

More information about _fastlane_ can be found on [fastlane.tools](https://fastlane.tools).

The documentation of _fastlane_ can be found on [docs.fastlane.tools](https://docs.fastlane.tools).
