import 'dart:developer';

import 'package:flutter/services.dart';

import 'klaviyo_flutter_platform_interface.dart';
import 'klaviyo_profile.dart';

const MethodChannel _channel = MethodChannel('com.rightbite.denisr/klaviyo');

/// An implementation of [KlaviyoFlutterPlatform] that uses method channels.
class MethodChannelKlaviyoFlutter extends KlaviyoFlutterPlatform {
  @override
  Future<void> initialize(String apiKey) async {
    await _channel.invokeMethod('initialize', {
      'apiKey': apiKey,
    });
  }

  /// Assign new identifiers and attributes to the currently tracked profile once.
  @override
  Future<String> updateProfile(KlaviyoProfile profileModel) async {
    final resultMap = await _channel.invokeMethod<String>(
      'updateProfile',
      profileModel.toJson(),
    );

    return resultMap.toString();
  }

  @override
  Future<String> logEvent(String name, [Map<String, dynamic>? metaData]) async {
    final resultMap = await _channel
        .invokeMethod('logEvent', {'name': name, 'metaData': metaData});
    log('logEvent result: $resultMap');

    return resultMap.toString();
  }

  @override
  Future<void> sendTokenToKlaviyo(String token) async {
    assert(token.isNotEmpty);
    log('Start sending token to Klaviyo');
    await _channel.invokeMethod('sendTokenToKlaviyo', {'token': token});
  }

  @override
  Future<bool> handlePush(Map<String, dynamic> message) async {
    if (!message.values.every((item) => item is String)) {
      throw new ArgumentError(
          'Klaviyo push messages can only have string values');
    }

    final result =
        await _channel.invokeMethod<bool>('handlePush', {'message': message});
    return result ?? false;
  }

  @override
  Future<void> setExternalId(String id) {
    return _channel.invokeMethod('setExternalId', {'id': id});
  }

  @override
  Future<String?> getExternalId() {
    return _channel.invokeMethod('getExternalId');
  }

  @override
  Future<void> resetProfile() => _channel.invokeMethod('resetProfile');

  @override
  Future<void> setEmail(String email) =>
      _channel.invokeMethod('setEmail', {'email': email});

  @override
  Future<String?> getEmail() => _channel.invokeMethod('getEmail');

  @override
  Future<void> setPhoneNumber(String phoneNumber) =>
      _channel.invokeMethod('setPhoneNumber', {'phoneNumber': phoneNumber});

  @override
  Future<String?> getPhoneNumber() => _channel.invokeMethod('getPhoneNumber');

  @override
  Future<void> setFirstName(String firstName) =>
      _channel.invokeMethod('setFirstName', {'firstName': firstName});

  @override
  Future<void> setLastName(String lastName) =>
      _channel.invokeMethod('setLastName', {'lastName': lastName});

  @override
  Future<void> setTitle(String title) =>
      _channel.invokeMethod('setTitle', {'title': title});

  @override
  Future<void> setOrganization(String organization) =>
      _channel.invokeMethod('setOrganization', {'organization': organization});

  @override
  Future<void> setImage(String image) =>
      _channel.invokeMethod('setImage', {'image': image});

  @override
  Future<void> setAddress1(String address1) =>
      _channel.invokeMethod('setAddress1', {'address': address1});

  @override
  Future<void> setAddress2(String address2) =>
      _channel.invokeMethod('setAddress2', {'address': address2});

  @override
  Future<void> setCity(String city) =>
      _channel.invokeMethod('setCity', {'city': city});

  @override
  Future<void> setCountry(String country) =>
      _channel.invokeMethod('setCountry', {'country': country});

  @override
  Future<void> setLatitude(double latitude) =>
      _channel.invokeMethod('setLatitude', {'latitude': latitude});

  @override
  Future<void> setLongitude(double longitude) =>
      _channel.invokeMethod('setLongitude', {'longitude': longitude});

  @override
  Future<void> setRegion(String region) =>
      _channel.invokeMethod('setRegion', {'region': region});

  @override
  Future<void> setZip(String zip) =>
      _channel.invokeMethod('setZip', {'zip': zip});

  @override
  Future<void> setTimezone(String timezone) =>
      _channel.invokeMethod('setTimezone', {'timezone': timezone});

  @override
  Future<void> setCustomAttribute(String key, String value) =>
      _channel.invokeMethod('setCustomAttribute', {'key': key, 'value': value});
}
