# Changelog

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
