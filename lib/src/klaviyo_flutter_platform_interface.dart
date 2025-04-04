import 'package:klaviyo_flutter/src/klaviyo_profile.dart';
import 'package:klaviyo_flutter/src/method_channel_klaviyo_flutter.dart';
import 'package:plugin_platform_interface/plugin_platform_interface.dart';

abstract class KlaviyoFlutterPlatform extends PlatformInterface {
  /// Constructs a KlaviyoFlutterPlatform.
  KlaviyoFlutterPlatform() : super(token: _token);

  static final Object _token = Object();

  /// The default instance of [KlaviyoFlutterPlatform] to use.
  static KlaviyoFlutterPlatform _instance = MethodChannelKlaviyoFlutter();

  /// Defaults to [KlaviyoFlutterPlatform].
  static KlaviyoFlutterPlatform get instance => _instance;

  /// Platform-specific plugins should set this with their own platform-specific
  /// class that extends [KlaviyoFlutterPlatform] when they register themselves.
  static set instance(KlaviyoFlutterPlatform instance) {
    PlatformInterface.verifyToken(instance, _token);
    _instance = instance;
  }

  /// Function to initialize the Klaviyo SDK.
  ///
  /// First, you'll need to get your Klaviyo [apiKey] public API key for your Klaviyo account.
  ///
  /// You can get these from Klaviyo settings:
  /// * [public API key](https://www.klaviyo.com/settings/account/api-keys)
  ///
  /// Then, initialize Klaviyo in main method.
  Future<void> initialize(String apiKey) {
    throw UnimplementedError('initialize() has not been implemented.');
  }

  /// The [token] to send to the Klaviyo to receive the notifications.
  ///
  /// For the Android, this [token] must be a FCM (Firebase cloud messaging) token.
  /// For the iOS, this [token] must be a APNS token.
  Future<void> sendTokenToKlaviyo(String token) {
    throw UnimplementedError('sendTokenToKlaviyo() has not been implemented.');
  }

  /// To log events in Klaviyo that record what users do in your app and when they do it.
  /// For example, you can record when user opened a specific screen in your app.
  /// You can also pass [metaData] about the event.
  Future<String> logEvent(String name, [Map<String, dynamic>? metaData]) {
    throw UnimplementedError('logEvent() has not been implemented.');
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
  //     object EXTERNAL_ID : ProfileKey("external_id")
  //     object EMAIL : ProfileKey("email")
  //     object PHONE_NUMBER : ProfileKey("phone_number")
  //     internal object ANONYMOUS_ID : ProfileKey("anonymous_id")
  //
  //     // Personal information
  //     object FIRST_NAME : ProfileKey("first_name")
  //     object LAST_NAME : ProfileKey("last_name")
  //     object ORGANIZATION : ProfileKey("organization")
  //     object TITLE : ProfileKey("title")
  //     object IMAGE : ProfileKey("image")
  //
  //     object ADDRESS1 : ProfileKey("address1")
  //     object ADDRESS2 : ProfileKey("address2")
  //     object CITY : ProfileKey("city")
  //     object COUNTRY : ProfileKey("country")
  //     object LATITUDE : ProfileKey("latitude")
  //     object LONGITUDE : ProfileKey("longitude")
  //     object REGION : ProfileKey("region")
  //     object ZIP : ProfileKey("zip")
  //     object TIMEZONE : ProfileKey("timezone")
  Future<String> updateProfile(KlaviyoProfile profileModel) async {
    throw UnimplementedError('updateProfile() has not been implemented.');
  }

  /// Check if the push [message] is for Klaviyo and handle that push.
  Future<bool> handlePush(Map<String, dynamic> message) async {
    throw UnimplementedError('handlePush() has not been implemented.');
  }

  /// {@template klaviyo_flutter_platform.setExternalId}
  /// Set the external ID of the currently tracked profile.
  ///
  /// Usually should be called on the user authorization and accept your
  /// system's user ID
  /// {@endtemplate}
  Future<void> setExternalId(String id) async {
    throw UnimplementedError('setExternalId() has not been implemented');
  }

  /// @return The external ID of the currently tracked profile, if set
  Future<String?> getExternalId() async {
    throw UnimplementedError('getExternalId() has not been implemented.');
  }

  Future<void> resetProfile() async {
    throw UnimplementedError('resetProfile() has not been implemented.');
  }

  /// Assigns an email address to the currently tracked Klaviyo profile
  ///
  /// The SDK keeps track of current profile details to
  /// build analytics requests with profile identifiers
  ///
  /// This should be called whenever the active user in your app changes
  /// (e.g. after a fresh login)
  ///
  /// @param [email] Email address for active user
  Future<void> setEmail(String email) async {
    throw UnimplementedError('setEmail() has not been implemented.');
  }

  /// @return The email of the currently tracked profile, if set
  Future<String?> getEmail() async {
    throw UnimplementedError('getEmail() has not been implemented.');
  }

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
  Future<void> setPhoneNumber(String phoneNumber) async {
    throw UnimplementedError('setPhoneNumber() has not been implemented.');
  }

  /// @return The phone number of the currently tracked profile, if set
  Future<String?> getPhoneNumber() async {
    throw UnimplementedError('getPhoneNumber() has not been implemented.');
  }

  /// {@template klaviyo_flutter_platform.setFirstName}
  /// Assigns a first name to the currently tracked Klaviyo profile
  /// {@endtemplate}
  Future<void> setFirstName(String firstName) async {
    throw UnimplementedError('setFirstName() has not been implemented.');
  }

  /// {@template klaviyo_flutter_platform.setLastName}
  /// Assigns a last name to the currently tracked Klaviyo profile
  /// {@endtemplate}
  Future<void> setLastName(String lastName) async {
    throw UnimplementedError('setLastName() has not been implemented.');
  }

  /// {@template klaviyo_flutter_platform.setTitle}
  /// Assigns a title to the currently tracked Klaviyo profile
  /// {@endtemplate}
  Future<void> setTitle(String title) async {
    throw UnimplementedError('setTitle() has not been implemented.');
  }

  /// {@template klaviyo_flutter_platform.setOrganization}
  /// Assigns an organization to the currently tracked Klaviyo profile
  /// {@endtemplate}
  Future<void> setOrganization(String organization) async {
    throw UnimplementedError('setOrganization() has not been implemented.');
  }

  /// {@template klaviyo_flutter_platform.setImage}
  /// Assigns an image to the currently tracked Klaviyo profile
  /// {@endtemplate}
  Future<void> setImage(String image) async {
    throw UnimplementedError('setImage() has not been implemented.');
  }

  /// {@template klaviyo_flutter_platform.setAddress1}
  /// Assigns an address1 to the currently tracked Klaviyo profile
  /// {@endtemplate}
  Future<void> setAddress1(String address) async {
    throw UnimplementedError('setAddress1() has not been implemented.');
  }

  /// {@template klaviyo_flutter_platform.setAddress2}
  /// Assigns an address2 to the currently tracked Klaviyo profile
  /// {@endtemplate}
  Future<void> setAddress2(String address) async {
    throw UnimplementedError('setAddress2() has not been implemented.');
  }

  /// {@template klaviyo_flutter_platform.setCity}
  /// Assigns a city to the currently tracked Klaviyo profile
  /// {@endtemplate}
  Future<void> setCity(String city) async {
    throw UnimplementedError('setCity() has not been implemented.');
  }

  /// {@template klaviyo_flutter_platform.setCountry}
  /// Assigns a country to the currently tracked Klaviyo profile
  /// {@endtemplate}
  Future<void> setCountry(String country) async {
    throw UnimplementedError('setCountry() has not been implemented.');
  }

  /// {@template klaviyo_flutter_platform.setLatitude}
  /// Assigns a latitude to the currently tracked Klaviyo profile
  /// {@endtemplate}
  Future<void> setLatitude(double latitude) async {
    throw UnimplementedError('setLatitude() has not been implemented.');
  }

  /// {@template klaviyo_flutter_platform.setLongitude}
  /// Assigns a longitude to the currently tracked Klaviyo profile
  /// {@endtemplate}
  Future<void> setLongitude(double longitude) async {
    throw UnimplementedError('setLongitude() has not been implemented.');
  }

  /// {@template klaviyo_flutter_platform.setRegion}
  /// Assigns a region to the currently tracked Klaviyo profile
  /// {@endtemplate}
  Future<void> setRegion(String region) async {
    throw UnimplementedError('setRegion() has not been implemented.');
  }

  /// {@template klaviyo_flutter_platform.setZip}
  /// Assigns a zip to the currently tracked Klaviyo profile
  /// {@endtemplate}
  Future<void> setZip(String zip) async {
    throw UnimplementedError('setZip() has not been implemented.');
  }

  /// {@template klaviyo_flutter_platform.setTimezone}
  /// Assigns a timezone to the currently tracked Klaviyo profile
  /// {@endtemplate}
  Future<void> setTimezone(String timezone) async {
    throw UnimplementedError('setTimezone() has not been implemented.');
  }

  /// {@template klaviyo_flutter_platform.setCustomAttribute}
  /// Assigns a custom attribute to the currently tracked Klaviyo profile
  /// {@endtemplate}
  Future<void> setCustomAttribute(String key, String value) async {
    throw UnimplementedError('setCustomAttribute() has not been implemented.');
  }
}
