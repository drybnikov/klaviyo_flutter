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
  Future<String?> getExternalId() {
    return _channel.invokeMethod('getExternalId');
  }

  Future<void> resetProfile() => _channel.invokeMethod('resetProfile');

  Future<void> setEmail(String email) =>
      _channel.invokeMethod('setEmail', {'email': email});

  Future<String?> getEmail() => _channel.invokeMethod('getEmail');

  Future<void> setPhoneNumber(String phoneNumber) =>
      _channel.invokeMethod('setPhoneNumber', {'phoneNumber': phoneNumber});

  Future<String?> getPhoneNumber() => _channel.invokeMethod('getPhoneNumber');
}
