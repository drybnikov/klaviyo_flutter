library klaviyo_flutter;

import 'dart:async';

import 'package:klaviyo_flutter/src/klaviyo_flutter_platform_interface.dart';
import 'package:klaviyo_flutter/src/klaviyo_profile_model.dart';

export 'klaviyo_flutter.dart';
export 'src/klaviyo_profile_model.dart';

class Klaviyo {
  /// private constructor to not allow the object creation from outside.
  Klaviyo._();

  static final Klaviyo _instance = Klaviyo._();

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
  Future<void> initialize(String apiKey) {
    return KlaviyoFlutterPlatform.instance.initialize(apiKey);
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
  /// All profile attributes recognised by the Klaviyo APIs [com.klaviyo.analytics.model.ProfileKey]
  Future<String> updateProfile(KlaviyoProfileModel profileModel) async {
    return KlaviyoFlutterPlatform.instance.updateProfile(profileModel);
  }
}
