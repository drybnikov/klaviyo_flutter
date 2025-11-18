“This project is based on code originally developed by Denisr under the BSD 3-Clause License.”

# klaviyo_flutter

[![Pub](https://img.shields.io/pub/v/klaviyo_flutter.svg)](https://pub.dev/packages/klaviyo_flutter)
![CI](https://github.com/drybnikov/klaviyo_flutter/workflows/CI/badge.svg)
![](https://img.shields.io/coderabbit/prs/github/drybnikov/klaviyo_flutter?label=CodeRabbit)

A comprehensive Flutter wrapper for Klaviyo's [Android SDK](https://github.com/klaviyo/klaviyo-android-sdk) and [iOS SDK](https://github.com/klaviyo/klaviyo-swift-sdk). Track events, manage user profiles, and handle push notifications with ease.

## Features

- **Event Tracking**: Log custom events with optional metadata
- **Profile Management**: Create and update user profiles with identifiers and attributes
- **Push Notifications**: Full support for Firebase Cloud Messaging (Android) and APNs (iOS)
- **Type Safety**: Strongly-typed API with null safety support
- **Cross-Platform**: Unified API for both iOS and Android

## Requirements

- **Android**: Minimum SDK version 23+, uses Klaviyo Android SDK v3.3.1
- **iOS**: iOS 13.0+, uses Klaviyo Swift SDK v4.2.1
- **Dart**: SDK 2.18.0 or higher
- **Flutter**: 2.0.0 or higher

## Installation

Add `klaviyo_flutter` to your `pubspec.yaml`:

```yaml
dependencies:
  klaviyo_flutter: ^0.3.0
```

Then run:

```bash
flutter pub get
```

## Quick Start

```dart
import 'package:flutter/material.dart';
import 'package:klaviyo_flutter/klaviyo_flutter.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize with your Klaviyo public API key
  await Klaviyo.instance.initialize('YOUR_PUBLIC_API_KEY');

  runApp(MyApp());
}
```

Get your public API key from [Klaviyo Account Settings](https://www.klaviyo.com/settings/account/api-keys).

## Usage Guide

### 1. Initialization

Initialize Klaviyo before using any other methods, typically in your `main()` function:

```dart
await Klaviyo.instance.initialize('YOUR_PUBLIC_API_KEY');

// Check if already initialized
if (Klaviyo.instance.isInitialized) {
  print('Klaviyo is ready!');
}
```

### 2. Event Tracking

Track user actions and behaviors in your app:

#### Basic Event

```dart
await Klaviyo.instance.logEvent('Viewed Product');
```

#### Event with Metadata

```dart
await Klaviyo.instance.logEvent(
  'Added to Cart',
  {
    'product_id': '12345',
    'product_name': 'Blue T-Shirt',
    'price': 29.99,
    'quantity': 2,
  },
);
```

#### E-commerce Events

Klaviyo supports special e-commerce events with the `$` prefix:

```dart
// Track a purchase
await Klaviyo.instance.logEvent(
  '\$successful_payment',
  {
    '\$value': 149.99,
    'order_id': 'ORD-789',
    'items': ['item1', 'item2'],
  },
);

// Track product views
await Klaviyo.instance.logEvent(
  'Viewed Product',
  {
    '\$product_id': 'SKU-123',
    '\$product_name': 'Wireless Headphones',
    '\$value': 79.99,
  },
);
```

### 3. Profile Management

#### Update Profile with KlaviyoProfile (Recommended)

Use `KlaviyoProfile` for bulk updates with all fields optional:

```dart
await Klaviyo.instance.updateProfile(
  KlaviyoProfile(
    id: 'customer-42',                    // External ID
    email: 'user@example.com',
    phoneNumber: '+15555551212',
    firstName: 'Jane',
    lastName: 'Doe',
    organization: 'Acme Corp',
    title: 'Product Manager',
    image: 'https://example.com/avatar.jpg',
    address1: '123 Main St',
    address2: 'Apt 4B',
    city: 'San Francisco',
    country: 'United States',
    region: 'CA',
    zip: '94102',
    timezone: 'America/Los_Angeles',
    latitude: 37.7749,
    longitude: -122.4194,
    properties: {
      'app_version': '2.0.5',
      'premium_member': true,
      'loyalty_points': 1250,
    },
  ),
);
```

#### Individual Profile Methods

Set profile attributes one at a time:

```dart
// Set identifiers
await Klaviyo.instance.setExternalId('customer-123');
await Klaviyo.instance.setEmail('user@example.com');
await Klaviyo.instance.setPhoneNumber('+15555551212');

// Set name fields
await Klaviyo.instance.setFirstName('Jane');
await Klaviyo.instance.setLastName('Doe');

// Set organization info
await Klaviyo.instance.setOrganization('Acme Corp');
await Klaviyo.instance.setTitle('Product Manager');
await Klaviyo.instance.setImage('https://example.com/avatar.jpg');

// Set address fields
await Klaviyo.instance.setAddress1('123 Main St');
await Klaviyo.instance.setAddress2('Apt 4B');
await Klaviyo.instance.setCity('San Francisco');
await Klaviyo.instance.setCountry('United States');
await Klaviyo.instance.setRegion('CA');
await Klaviyo.instance.setZip('94102');
await Klaviyo.instance.setTimezone('America/Los_Angeles');

// Set location coordinates
await Klaviyo.instance.setLatitude(37.7749);
await Klaviyo.instance.setLongitude(-122.4194);

// Set custom attributes
await Klaviyo.instance.setCustomAttribute('favorite_color', 'blue');
await Klaviyo.instance.setCustomAttribute('membership_level', 'gold');
```

#### Get Profile Information

Retrieve current profile identifiers:

```dart
String? externalId = await Klaviyo.instance.getExternalId();
String? email = await Klaviyo.instance.getEmail();
String? phoneNumber = await Klaviyo.instance.getPhoneNumber();

print('Current user: $email (ID: $externalId)');
```

#### Reset Profile

Clear all profile data (e.g., on user logout):

```dart
await Klaviyo.instance.resetProfile();
```

**Note**: After resetting, you'll need to call `sendTokenToKlaviyo()` again to associate the device with a new profile.

### 4. Working with KlaviyoProfile

The `KlaviyoProfile` class provides convenient methods for profile manipulation:

#### Create from JSON

```dart
final profile = KlaviyoProfile.fromJson({
  'external_id': 'user-123',
  'email': 'user@example.com',
  'first_name': 'Jane',
  'latitude': 37.7749,
  'properties': {'app_version': '1.0.0'},
});
```

#### Copy with Changes

Create a modified copy while preserving other fields:

```dart
final updatedProfile = profile.copyWith(
  city: 'New York',
  zip: '10001',
  properties: {'app_version': '1.1.0'},
);
```

#### Convert to JSON

```dart
Map<String, dynamic> json = profile.toJson();
```

### 5. Push Notifications

#### Setup Overview

1. Configure Firebase Cloud Messaging for both platforms
2. Forward device tokens to Klaviyo
3. Handle incoming push notifications
4. Track push opens for analytics

#### Firebase Prerequisites

- Create a Firebase project and add your Android/iOS apps
- Download `google-services.json` (Android) and `GoogleService-Info.plist` (iOS)
- Enable Firebase Cloud Messaging
- Copy the FCM server key to Klaviyo Dashboard (**Account > Settings > Push**)

#### Android Configuration

1. **Add Google Services Plugin**

   Place `google-services.json` in `android/app/` and update `android/app/build.gradle`:

   ```gradle
   dependencies {
       classpath 'com.google.gms:google-services:4.3.15'
   }

   // At the bottom of the file
   apply plugin: 'com.google.gms.google-services'
   ```

2. **Register KlaviyoPushService**

   Add to `android/app/src/main/AndroidManifest.xml`:

   ```xml
   <service
       android:name="com.klaviyo.pushFcm.KlaviyoPushService"
       android:exported="false">
     <intent-filter>
       <action android:name="com.google.firebase.MESSAGING_EVENT" />
     </intent-filter>
   </service>
   ```

3. **Add Permissions**

   ```xml
   <uses-permission android:name="android.permission.INTERNET" />
   <uses-permission android:name="android.permission.POST_NOTIFICATIONS" />
   ```

4. **Optional: Custom Notification Icon**

   ```xml
   <meta-data
       android:name="com.klaviyo.push.default_notification_icon"
       android:resource="@drawable/ic_notification" />
   ```

5. **Enable AndroidX**

   In `android/gradle.properties`:

   ```properties
   android.useAndroidX=true
   android.enableJetifier=true
   ```

#### iOS Configuration

1. **Add GoogleService-Info.plist**

   Drag the file into the Runner target in Xcode.

2. **Enable Capabilities**

   In Xcode, enable:

   - Push Notifications
   - Background Modes > Remote notifications

3. **Update Info.plist**

   ```xml
   <key>NSPhotoLibraryUsageDescription</key>
   <string>We need access to your photo library</string>
   ```

4. **Set Minimum Deployment Target**

   In `ios/Runner.xcodeproj/project.pbxproj`:

   ```
   IPHONEOS_DEPLOYMENT_TARGET = 13.0;
   ```

#### Requesting Push Permissions

```dart
import 'package:firebase_messaging/firebase_messaging.dart';

// Request permission (iOS prompts user, Android auto-grants on API 33+)
NotificationSettings settings = await FirebaseMessaging.instance.requestPermission(
  alert: true,
  badge: true,
  sound: true,
);

if (settings.authorizationStatus == AuthorizationStatus.authorized) {
  print('User granted permission');

  // Get the FCM/APNs token
  String? token = await FirebaseMessaging.instance.getToken();

  if (token != null) {
    // Send token to Klaviyo
    await Klaviyo.instance.sendTokenToKlaviyo(token);
    print('Token registered with Klaviyo');
  }
}
```

#### Handling Push Notifications

```dart
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';

// Top-level function for background messages
@pragma('vm:entry-point')
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  await Firebase.initializeApp();

  // Let Klaviyo handle its push notifications
  await Klaviyo.instance.handlePush(message.data);

  print('Background message handled: ${message.messageId}');
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  await Klaviyo.instance.initialize('YOUR_API_KEY');

  // Register background handler
  FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);

  runApp(MyApp());
}

class MyApp extends StatefulWidget {
  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  @override
  void initState() {
    super.initState();
    _setupPushHandling();
  }

  void _setupPushHandling() {
    // Handle foreground messages
    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      print('Foreground message: ${message.notification?.title}');
      Klaviyo.instance.handlePush(message.data);
    });

    // Handle notification taps (app opened from background)
    FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
      print('Notification opened app: ${message.notification?.title}');
      Klaviyo.instance.handlePush(message.data);
    });

    // Check for initial notification (app opened from terminated state)
    FirebaseMessaging.instance.getInitialMessage().then((RemoteMessage? message) {
      if (message != null) {
        print('App opened from notification: ${message.notification?.title}');
        Klaviyo.instance.handlePush(message.data);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(home: HomeScreen());
  }
}
```

#### Check if Push is from Klaviyo

```dart
if (Klaviyo.instance.isKlaviyoPush(message.data)) {
  await Klaviyo.instance.handlePush(message.data);
}
```

#### Update Badge Count (iOS Only)

```dart
// Set badge count on app icon
await Klaviyo.instance.setBadgeCount(5);

// Clear badge
await Klaviyo.instance.setBadgeCount(0);
```

**Note**: `setBadgeCount()` only works on iOS. On Android, it's a no-op because badge behavior varies by manufacturer.

#### Listen for Token Refreshes

```dart
FirebaseMessaging.instance.onTokenRefresh.listen((newToken) {
  Klaviyo.instance.sendTokenToKlaviyo(newToken);
});
```

### 6. Complete Example

Here's a full example demonstrating all major features:

```dart
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:klaviyo_flutter/klaviyo_flutter.dart';

@pragma('vm:entry-point')
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  await Firebase.initializeApp();
  await Klaviyo.instance.handlePush(message.data);
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  await Klaviyo.instance.initialize('YOUR_PUBLIC_API_KEY');

  FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);

  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: KlaviyoDemo(),
    );
  }
}

class KlaviyoDemo extends StatefulWidget {
  @override
  State<KlaviyoDemo> createState() => _KlaviyoDemoState();
}

class _KlaviyoDemoState extends State<KlaviyoDemo> {
  String _status = 'Ready';

  @override
  void initState() {
    super.initState();
    _setupPushNotifications();
  }

  Future<void> _setupPushNotifications() async {
    // Request permission
    NotificationSettings settings = await FirebaseMessaging.instance.requestPermission();

    if (settings.authorizationStatus == AuthorizationStatus.authorized) {
      // Get and send token
      String? token = await FirebaseMessaging.instance.getToken();
      if (token != null) {
        await Klaviyo.instance.sendTokenToKlaviyo(token);
        setState(() => _status = 'Push notifications enabled');
      }
    }

    // Handle foreground messages
    FirebaseMessaging.onMessage.listen((message) {
      Klaviyo.instance.handlePush(message.data);
    });

    // Handle notification taps
    FirebaseMessaging.onMessageOpenedApp.listen((message) {
      Klaviyo.instance.handlePush(message.data);
    });
  }

  Future<void> _identifyUser() async {
    try {
      await Klaviyo.instance.updateProfile(
        KlaviyoProfile(
          id: 'user-12345',
          email: 'demo@example.com',
          firstName: 'Demo',
          lastName: 'User',
          phoneNumber: '+15555551212',
          city: 'San Francisco',
          country: 'United States',
          properties: {
            'app_version': '1.0.0',
            'platform': 'flutter',
          },
        ),
      );
      setState(() => _status = 'User identified');
    } catch (e) {
      setState(() => _status = 'Error: $e');
    }
  }

  Future<void> _trackEvent() async {
    try {
      await Klaviyo.instance.logEvent(
        'Button Clicked',
        {
          'button_name': 'Track Event',
          'timestamp': DateTime.now().toIso8601String(),
        },
      );
      setState(() => _status = 'Event tracked');
    } catch (e) {
      setState(() => _status = 'Error: $e');
    }
  }

  Future<void> _trackPurchase() async {
    try {
      await Klaviyo.instance.logEvent(
        '\$successful_payment',
        {
          '\$value': 99.99,
          'order_id': 'ORD-${DateTime.now().millisecondsSinceEpoch}',
          'item_count': 3,
        },
      );
      setState(() => _status = 'Purchase tracked');
    } catch (e) {
      setState(() => _status = 'Error: $e');
    }
  }

  Future<void> _logout() async {
    try {
      await Klaviyo.instance.resetProfile();
      setState(() => _status = 'Logged out');
    } catch (e) {
      setState(() => _status = 'Error: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Klaviyo Flutter Demo'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              'Status: $_status',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 40),
            ElevatedButton(
              onPressed: _identifyUser,
              child: Text('Identify User'),
            ),
            SizedBox(height: 16),
            ElevatedButton(
              onPressed: _trackEvent,
              child: Text('Track Event'),
            ),
            SizedBox(height: 16),
            ElevatedButton(
              onPressed: _trackPurchase,
              child: Text('Track Purchase'),
            ),
            SizedBox(height: 16),
            ElevatedButton(
              onPressed: _logout,
              style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
              child: Text('Logout'),
            ),
          ],
        ),
      ),
    );
  }
}
```

## API Reference

### Klaviyo Class

| Method                 | Parameters                                      | Returns           | Description                                 |
| ---------------------- | ----------------------------------------------- | ----------------- | ------------------------------------------- |
| `initialize()`         | `String apiKey`                                 | `Future<void>`    | Initialize the SDK with your public API key |
| `logEvent()`           | `String name, [Map<String, dynamic>? metaData]` | `Future<String>`  | Log a custom event with optional metadata   |
| `updateProfile()`      | `KlaviyoProfile profile`                        | `Future<String>`  | Update profile with bulk attributes         |
| `setExternalId()`      | `String id`                                     | `Future<void>`    | Set external identifier                     |
| `getExternalId()`      | -                                               | `Future<String?>` | Get current external ID                     |
| `setEmail()`           | `String email`                                  | `Future<void>`    | Set email address                           |
| `getEmail()`           | -                                               | `Future<String?>` | Get current email                           |
| `setPhoneNumber()`     | `String phoneNumber`                            | `Future<void>`    | Set phone number                            |
| `getPhoneNumber()`     | -                                               | `Future<String?>` | Get current phone number                    |
| `setFirstName()`       | `String firstName`                              | `Future<void>`    | Set first name                              |
| `setLastName()`        | `String lastName`                               | `Future<void>`    | Set last name                               |
| `setOrganization()`    | `String organization`                           | `Future<void>`    | Set organization                            |
| `setTitle()`           | `String title`                                  | `Future<void>`    | Set job title                               |
| `setImage()`           | `String image`                                  | `Future<void>`    | Set profile image URL                       |
| `setAddress1()`        | `String address`                                | `Future<void>`    | Set address line 1                          |
| `setAddress2()`        | `String address`                                | `Future<void>`    | Set address line 2                          |
| `setCity()`            | `String city`                                   | `Future<void>`    | Set city                                    |
| `setCountry()`         | `String country`                                | `Future<void>`    | Set country                                 |
| `setRegion()`          | `String region`                                 | `Future<void>`    | Set region/state                            |
| `setZip()`             | `String zip`                                    | `Future<void>`    | Set postal code                             |
| `setTimezone()`        | `String timezone`                               | `Future<void>`    | Set timezone                                |
| `setLatitude()`        | `double latitude`                               | `Future<void>`    | Set latitude coordinate                     |
| `setLongitude()`       | `double longitude`                              | `Future<void>`    | Set longitude coordinate                    |
| `setCustomAttribute()` | `String key, String value`                      | `Future<void>`    | Set custom profile attribute                |
| `resetProfile()`       | -                                               | `Future<void>`    | Clear all profile data                      |
| `sendTokenToKlaviyo()` | `String token`                                  | `Future<void>`    | Register device token for push              |
| `handlePush()`         | `Map<String, dynamic> message`                  | `Future<bool>`    | Handle incoming push notification           |
| `isKlaviyoPush()`      | `Map<String, dynamic> message`                  | `bool`            | Check if push is from Klaviyo               |
| `setBadgeCount()`      | `int count`                                     | `Future<void>`    | Set app badge count (iOS only)              |
| `isInitialized`        | -                                               | `bool`            | Check if SDK is initialized                 |

### KlaviyoProfile Class

| Property       | Type                    | Description                                                                            |
| -------------- | ----------------------- | -------------------------------------------------------------------------------------- |
| `id`           | `String?`               | External user identifier                                                               |
| `email`        | `String?`               | Email address                                                                          |
| `phoneNumber`  | `String?`               | Phone number ([format guide](https://help.klaviyo.com/hc/en-us/articles/360046055671)) |
| `firstName`    | `String?`               | First name                                                                             |
| `lastName`     | `String?`               | Last name                                                                              |
| `organization` | `String?`               | Company/organization name                                                              |
| `title`        | `String?`               | Job title                                                                              |
| `image`        | `String?`               | Profile image URL                                                                      |
| `address1`     | `String?`               | Address line 1                                                                         |
| `address2`     | `String?`               | Address line 2                                                                         |
| `city`         | `String?`               | City                                                                                   |
| `country`      | `String?`               | Country                                                                                |
| `region`       | `String?`               | State/province/region                                                                  |
| `zip`          | `String?`               | Postal/ZIP code                                                                        |
| `timezone`     | `String?`               | Timezone (e.g., 'America/New_York')                                                    |
| `latitude`     | `double?`               | Latitude coordinate                                                                    |
| `longitude`    | `double?`               | Longitude coordinate                                                                   |
| `properties`   | `Map<String, dynamic>?` | Custom properties                                                                      |

## Known Limitations

### Clearing Individual Profile Fields

This plugin does not support clearing individual profile fields (e.g., setting a field to `null`). This is due to the underlying Klaviyo API behavior where omitting a field leaves it unchanged, and null values are not processed.

**To clear profile fields:** Use `Klaviyo.resetProfile()` to clear all profile data, then call `updateProfile()` with only the fields you want to keep:

```dart
// Clear all profile data
await Klaviyo.instance.resetProfile();

// Set only the fields you want to keep
await Klaviyo.instance.updateProfile(
  KlaviyoProfile(
    email: 'user@example.com',
    firstName: 'Jane',
    // All other fields are now cleared
  ),
);
```

## Troubleshooting

### Android Issues

**Build fails with "Duplicate class" errors**

Enable Jetifier in `android/gradle.properties`:

```properties
android.enableJetifier=true
```

**Push notifications not received**

- Verify `google-services.json` is in `android/app/`
- Check that `KlaviyoPushService` is registered in `AndroidManifest.xml`
- Confirm FCM server key is added to Klaviyo dashboard

### iOS Issues

**Build fails with deployment target error**

Set minimum deployment target in `ios/Runner.xcodeproj/project.pbxproj`:

```
IPHONEOS_DEPLOYMENT_TARGET = 13.0;
```

**Push notifications not received**

- Verify Push Notifications capability is enabled
- Check that APNs certificates are configured in Apple Developer Portal
- Ensure device token is being sent to Klaviyo

### General Issues

**"API key must not be empty" error**

Make sure you're using your **public** API key, not the private key.

**Events not appearing in Klaviyo**

- Check that `initialize()` was called before logging events
- Verify API key is correct
- Events may take a few minutes to appear in the dashboard

## Resources

- [Klaviyo Help Center](https://help.klaviyo.com/)
- [Android SDK Documentation](https://help.klaviyo.com/hc/en-us/articles/14750928993307)
- [iOS SDK Documentation](https://help.klaviyo.com/hc/en-us/articles/360023213971)
- [Push Notification Setup Guide](https://help.klaviyo.com/hc/en-us/articles/360023213971)
- [Sending Push Campaigns](https://help.klaviyo.com/hc/en-us/articles/360006653972)
- [Adding Push to Flows](https://help.klaviyo.com/hc/en-us/articles/12932504108571)

## Contributing

Contributions are welcome! Please feel free to submit a Pull Request.

## License

See the [LICENSE](LICENSE) file for details.

## Changelog

See [CHANGELOG.md](CHANGELOG.md) for version history.
