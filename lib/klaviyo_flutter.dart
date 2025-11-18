library klaviyo_flutter;

import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:klaviyo_flutter/src/klaviyo_flutter_platform_interface.dart';
import 'package:klaviyo_flutter/src/klaviyo_profile.dart';

export 'klaviyo_flutter.dart';
export 'src/klaviyo_profile.dart';

class Klaviyo {
  /// private constructor to not allow the object creation from outside.
  Klaviyo._();

  static final Klaviyo _instance = Klaviyo._();

  bool _initialized = false;

  /// get the instance of the [Klaviyo].
  static Klaviyo get instance => _instance;

  /// Function to initialize the Klaviyo SDK.
  ///
  /// First, you'll need to get your Klaviyo [apiKey] public API key for your Klaviyo account.
  ///
  /// You can get these from Klaviyo settings:
  /// * [public API key](https://www.klaviyo.com/settings/account/api-keys)
  ///
  /// Then, initialize Klaviyo in main method.
  Future<void> initialize(String apiKey) async {
    if (apiKey.trim().isEmpty) {
      throw ArgumentError.value(apiKey, 'apiKey', 'must not be empty');
    }
    await KlaviyoFlutterPlatform.instance.initialize(apiKey);
    _initialized = true;
  }

  /// To log events in Klaviyo that record what users do in your app and when they do it.
  /// For example, you can record when user opened a specific screen in your app.
  /// You can also pass [metaData] about the event.
  Future<String> logEvent(String name, [Map<String, dynamic>? metaData]) {
    return KlaviyoFlutterPlatform.instance.logEvent(name, metaData);
  }

  /// The [token] to send to the Klaviyo to receive the notifications.
  ///
  /// For the Android, this [token] must be a FCM (Firebase cloud messaging) token.
  /// For the iOS, this [token] must be a APNS token.
  Future<void> sendTokenToKlaviyo(String token) {
    return KlaviyoFlutterPlatform.instance.sendTokenToKlaviyo(token);
  }

  /// Assign new identifiers and attributes to the currently tracked profile.
  /// If a profile has already been identified it will be overwritten by calling [resetProfile].
  ///
  /// The SDK keeps track of current profile details to
  /// build analytics requests with profile identifiers
  ///
  /// @param [profileMap] A map-like object representing properties of the new user
  /// @return Returns Future<String> success when called on Android or iOS
  ///
  /// All profile attributes recognized by the Klaviyo APIs [com.klaviyo.analytics.model.ProfileKey]
  Future<String> updateProfile(KlaviyoProfile profileModel) async {
    return KlaviyoFlutterPlatform.instance.updateProfile(profileModel);
  }

  /// Check if the push [message] is for Klaviyo and handle that push.
  Future<bool> handlePush(Map<String, dynamic> message) async {
    return KlaviyoFlutterPlatform.instance.handlePush(message);
  }

  /// Check if the Klaviyo already initialized
  bool get isInitialized => _initialized;

  /// Check if the push [message] is for Klaviyo
  bool isKlaviyoPush(Map<String, dynamic> message) => message.containsKey('_k');

  /// {@macro klaviyo_flutter_platform.setExternalId}
  Future<void> setExternalId(String id) =>
      KlaviyoFlutterPlatform.instance.setExternalId(id);

  /// @return The external ID of the currently tracked profile, if set
  Future<String?> getExternalId() =>
      KlaviyoFlutterPlatform.instance.getExternalId();

  /// Clears all stored profile identifiers (e.g. email or phone) and starts a new tracked profile
  ///
  /// NOTE: if a push token was registered to the current profile, you will need to
  /// call `setPushToken` again to associate this device to a new profile
  ///
  /// This should be called whenever an active user in your app is removed
  /// (e.g. after a logout)
  Future<void> resetProfile() => KlaviyoFlutterPlatform.instance.resetProfile();

  /// Assigns an email address to the currently tracked Klaviyo profile
  ///
  /// The SDK keeps track of current profile details to
  /// build analytics requests with profile identifiers
  ///
  /// This should be called whenever the active user in your app changes
  /// (e.g. after a fresh login)
  ///
  /// @param [email] Email address for active user
  Future<void> setEmail(String email) =>
      KlaviyoFlutterPlatform.instance.setEmail(email);

  /// @return The email of the currently tracked profile, if set
  Future<String?> getEmail() => KlaviyoFlutterPlatform.instance.getEmail();

  /// Assigns a phone number to the currently tracked Klaviyo profile
  ///
  /// NOTE: Phone number format is not validated, but should conform to Klaviyo formatting
  /// see (documentation)[https://help.klaviyo.com/hc/en-us/articles/360046055671-Accepted-phone-number-formats-for-SMS-in-Klaviyo]
  ///
  /// The SDK keeps track of current profile details to
  /// build analytics requests with profile identifiers
  ///
  /// This should be called whenever the active user in your app changes
  /// (e.g. after a fresh login)
  ///
  /// @param [phoneNumber] Phone number for active user
  Future<void> setPhoneNumber(String phoneNumber) =>
      KlaviyoFlutterPlatform.instance.setPhoneNumber(phoneNumber);

  /// @return The phone number of the currently tracked profile, if set
  Future<String?> getPhoneNumber() =>
      KlaviyoFlutterPlatform.instance.getPhoneNumber();

  /// {@macro klaviyo_flutter_platform.setFirstName}
  Future<void> setFirstName(String firstName) =>
      KlaviyoFlutterPlatform.instance.setFirstName(firstName);

  /// {@macro klaviyo_flutter_platform.setLastName}
  Future<void> setLastName(String lastName) =>
      KlaviyoFlutterPlatform.instance.setLastName(lastName);

  /// {@macro klaviyo_flutter_platform.setOrganization}
  Future<void> setOrganization(String organization) =>
      KlaviyoFlutterPlatform.instance.setOrganization(organization);

  /// {@macro klaviyo_flutter_platform.setTitle}
  Future<void> setTitle(String title) =>
      KlaviyoFlutterPlatform.instance.setTitle(title);

  /// {@macro klaviyo_flutter_platform.setImage}
  Future<void> setImage(String image) =>
      KlaviyoFlutterPlatform.instance.setImage(image);

  /// {@macro klaviyo_flutter_platform.setAddress1}
  Future<void> setAddress1(String address) =>
      KlaviyoFlutterPlatform.instance.setAddress1(address);

  /// {@macro klaviyo_flutter_platform.setAddress2}
  Future<void> setAddress2(String address) =>
      KlaviyoFlutterPlatform.instance.setAddress2(address);

  /// {@macro klaviyo_flutter_platform.setCity}
  Future<void> setCity(String city) =>
      KlaviyoFlutterPlatform.instance.setCity(city);

  /// {@macro klaviyo_flutter_platform.setCountry}
  Future<void> setCountry(String country) =>
      KlaviyoFlutterPlatform.instance.setCountry(country);

  /// {@macro klaviyo_flutter_platform.setLatitude}
  Future<void> setLatitude(double latitude) =>
      KlaviyoFlutterPlatform.instance.setLatitude(latitude);

  /// {@macro klaviyo_flutter_platform.setLongitude}
  Future<void> setLongitude(double longitude) =>
      KlaviyoFlutterPlatform.instance.setLongitude(longitude);

  /// {@macro klaviyo_flutter_platform.setRegion}
  Future<void> setRegion(String region) =>
      KlaviyoFlutterPlatform.instance.setRegion(region);

  /// {@macro klaviyo_flutter_platform.setZip}
  Future<void> setZip(String zip) =>
      KlaviyoFlutterPlatform.instance.setZip(zip);

  /// {@macro klaviyo_flutter_platform.setTimezone}
  Future<void> setTimezone(String timezone) =>
      KlaviyoFlutterPlatform.instance.setTimezone(timezone);

  /// {@macro klaviyo_flutter_platform.setCustomAttribute}
  Future<void> setCustomAttribute(String key, String value) =>
      KlaviyoFlutterPlatform.instance.setCustomAttribute(key, value);

  /// {@macro klaviyo_flutter_platform.setBadgeCount}
  Future<void> setBadgeCount(int count) =>
      KlaviyoFlutterPlatform.instance.setBadgeCount(count);

  @visibleForTesting
  void debugReset() {
    _initialized = false;
  }
}
