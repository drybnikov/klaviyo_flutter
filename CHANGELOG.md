# Changelog

## 0.3.0 (Unreleased)

* Guard `Klaviyo.initialize` against empty API keys and expose a `debugReset()`
  helper for tests.
* Make `logEvent` metadata optional across Dart and Android, rebuild profile
  mapping to use Klaviyo's native keys, and align latitude/longitude with double
  precision values on every platform.
* Expand `KlaviyoProfile` with city/country/zip/timezone fields plus
  `copyWith`/`fromJson`, and add a dedicated Dart test suite that exercises the
  full public API surface (`test/klaviyo_flutter_test.dart`,
  `test/klaviyo_profile_test.dart`).
* Modernize the example app to demonstrate initialization, profile updates,
  event logging, push token registration, push handling, badge management, and
  profile reset flows (`example/lib/main.dart`).
* Introduce Android JVM tests for the plugin bridge and ship a Gradle wrapper so
  plugin builds run in isolation (`android/src/test`, `android/gradlew`).

## 0.2.0

* Add individual set profile attributes methods, thanks @Lo4D
* Critical Fix: Resolve Klaviyo All Events Failure for Arabic Language, thanks @Musharaf13
* Add `setBadgeCount()` to iOS and update `KlaviyoSwift` dependency, thanks @Lo4D 
* Add individual set profile attributes methods
* Updated Android SDK to 3.3.1, Updated iOS SDK to 4.2.1

## 0.1.4

* Update project to support Android SDK 35 and tooling, thanks @sn1cka

## 0.1.3

* Added Namespace declaration for Android Gradle Plugin compatibility, thanks @Codel1417

## 0.1.2

* Updated Android SDK to 3.0.0, Updated iOS SDK to 4.0.0

## 0.1.1

* Use correct Klaviyo notification key for Android

## 0.1.0

* Updated Android SDK to 2.2.1, Updated iOS SDK to 3.0.4

## 0.0.4+1

* Improved sending events in Android and iOS

## 0.0.3+1

* Updated Android SDK to 1.3.4, Updated iOS SDK to 2.2.1

## 0.0.2+3

* Fix for option properties in Android, Updated Android SDK to 1.1.1

## 0.0.2+2

* Fix for sending properties to Klaviyo API via Android

## 0.0.2+1

* Fix for sending properties to Klaviyo API, empty string in phone number caused an issue
* Added missing properties: `organization`, `title`, `image` and `properties`

## 0.0.1+7

* Updated Android SDK to 1.1.0, null checks

## 0.0.1+6

* Implemented `setEmail`, `getEmail`, `setPhoneNumber`, `getPhoneNumber` on both Android and iOS

## 0.0.1+5

* Added iOS extension to tracking push notifications to fixed issue #1

## 0.0.1+4

* Implemented `getExternalId`, `resetProfile` on both Android and iOS

## 0.0.1+3

* Implemented `isInitialized`, `isKlaviyoPush`
* Updated Android SDK to 1.0.1

## 0.0.1+2

* Implemented `handlePush` on both Android and iOS
* Updated `updateProfile` on iOS

## 0.0.1+1

* Implemented `updateProfile`, `initialize`, `sendTokenToKlaviyo`, `logEvent` on both Android and iOS
