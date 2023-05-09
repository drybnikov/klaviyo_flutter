# klaviyo_flutter

[![Pub](https://img.shields.io/pub/v/klaviyo_flutter.svg)](https://pub.dev/packages/klaviyo_flutter)
![CI](https://github.com/drybnikov/klaviyo_flutter/workflows/CI/badge.svg)

Flutter wrapper for Klaviyo [Android](https://github.com/klaviyo/klaviyo-android-sdk),
and [iOS](https://github.com/klaviyo/klaviyo-swift-sdk) projects.

- Uses Klaviyo Android SDK Version `1.0.0`.
- The minimum Android SDK `minSdkVersion` required is 23.
- Uses Klaviyo iOS SDK Version `2.0.1`.
- The minimum iOS target version required is 13.

## Usage

Import `package:klaviyo_flutter/klaviyo_flutter.dart` and use the methods in `Klaviyo` class.

Example:

```dart
import 'package:flutter/material.dart';
import 'package:klaviyo_flutter/klaviyo_flutter.dart';

void main() async {
  // initialize the flutter binding.
  WidgetsFlutterBinding.ensureInitialized();
  // initialize the Klaviyo.
  // make sure to add key from your Klaviyo account public API.
  await await Klaviyo.instance.initialize('apiKeyHere');
  runApp(App());
}

class App extends StatelessWidget {

  @override
  Widget build(BuildContext context) {
    return FlatButton(
      child: Text('Send Klaviyo SUCCESSFUL_PAYMENT event'),
      onPressed: () async {
        await Klaviyo.instance.logEvent(
          '\$successful_payment',
          {'\$value': 'paymentValue'},
        );
      },
    );
  }
}

```

See
Klaviyo [Android](https://help.klaviyo.com/hc/en-us/articles/14750928993307)
and [iOS](https://help.klaviyo.com/hc/en-us/articles/360023213971) package
documentation for more information.

### Android

Permissions:

```xml

<uses-permission android:name="android.permission.INTERNET" />
```

Optional permissions:

```xml

<uses-permission android:name="android.permission.READ_EXTERNAL_STORAGE" /><uses-permission
android:name="android.permission.VIBRATE" /><uses-permission
android:name="android.permission.POST_NOTIFICATIONS" />
```

Enable AndroidX + Jetifier support in your android/gradle.properties file (see example app):

```
android.useAndroidX=true
android.enableJetifier=true
```

### iOS

Make sure that you have a `NSPhotoLibraryUsageDescription` entry in your `Info.plist`.

### Push notifications setup

This plugin works in combination with
the [`firebase_messaging`](https://pub.dev/packages/firebase_messaging) plugin to receive Push
Notifications.

### Prerequisites:

- Firebase account
- Familiarity with [Firebase](https://firebase.google.com/docs/cloud-messaging/android/client)
  documentation.

### KlaviyoPushService

[//]: # (TODO Document firebase setup, google services JSON etc)
The Klaviyo Push SDK for Android works as a wrapper around `FirebaseMessagingService` so the
setup process is very similar to the Firebase client documentation linked above.
You should follow all other setup recommendations from the FCM documentation.
To specify a notification icon, add the following metadata to your app manifest.
Absent this, the application's launcher icon will be used.

```xml
<meta-data android:name="com.klaviyo.push.default_notification_icon"
    android:resource="{YOUR_ICON_RESOURCE}" />
```

```dart

final firebaseMessaging = FirebaseMessaging.instance;
final token = Platform.isIOS
    ? await firebaseMessaging.getAPNSToken(): await
firebaseMessaging.getToken
();

if
(
token != null && token.isNotEmpty) {
Klaviyo.instance.sendTokenToKlaviyo(token);
}
```

Now, if either Firebase direct (e.g. by your own backend server) or Klaviyo sends you a message, it
will be delivered to your app.