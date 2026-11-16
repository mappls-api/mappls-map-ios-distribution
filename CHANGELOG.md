# Changelog for Mappls Map SDK for iOS

## 7.0.1

### 🐞 Bug fixes

- Fixed map labels in regional languages, such as Hindi, being shown on a single line. Long
  labels in these languages now wrap onto several lines, like labels in English.

## 7.0.0

### 💥 Breaking changes

- **`MapplsAPICore` and `MapplsAPIKit` are no longer installed automatically.** The
  `MapplsMap` package now contains only the `MapplsMap` binary. Add the two packages to
  your app yourself, otherwise the app crashes at launch with
  `dyld: Library not loaded: @rpath/MapplsAPICore.framework/MapplsAPICore`:
  - `https://github.com/mappls-api/mappls-api-core-ios-distribution`, 2.1.6 or later
  - `https://github.com/mappls-api/mappls-api-kit-ios-distribution`, 3.0.10 or later

  If you used an "Up to Next Major Version" rule from 6.x, change it to 7.0.0: Xcode does
  not move to a new major version on its own.
- **Objective-C: import the module instead of `MapplsMap.h`.** The framework no longer
  contains `MapplsMap.h`. Replace `#import <MapplsMap/MapplsMap.h>` with
  `@import MapplsMap;`. Swift is unaffected: keep using `import MapplsMap`.
- **The framework's minimum iOS version is now 13.0** (6.1.5 declared 12.0).

### ✨ Improvements

- Updated the map rendering engine, with performance improvements and bug fixes.
- Supports iOS 13.0 and later. On iOS 13, where precise/approximate location does not
  exist, the SDK behaves as if the user granted full accuracy:
  - the precise user location puck is always shown,
  - `requestTemporaryFullAccuracyAuthorization(withPurposeKey:)` does nothing,
  - `mapView(_:didChangeLocationManagerAuthorization:)` is only called on iOS 14 and later.
- Added log messages to the Mappls authorization, style loading, Mappls Pin, annotation,
  indoor and traffic code. They go through `MGLLoggingConfiguration`, so you can see them
  by setting `MGLLoggingConfiguration.shared.loggingLevel = .verbose` (Swift) or
  `[MGLLoggingConfiguration sharedConfiguration].loggingLevel = MGLLoggingLevelVerbose`
  (Objective-C). Errors are reported for Mappls Pins that cannot be resolved or that
  return invalid coordinates, and for authorization failures.
