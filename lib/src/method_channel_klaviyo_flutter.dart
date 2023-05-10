import 'dart:developer';

import 'package:flutter/services.dart';

import 'klaviyo_flutter_platform_interface.dart';
import 'klaviyo_profile_model.dart';

const MethodChannel _channel = MethodChannel('com.rightbite.denisr/klaviyo');

/// An implementation of [KlaviyoFlutterPlatform] that uses method channels.
class MethodChannelKlaviyoFlutter extends KlaviyoFlutterPlatform {
  String userId = '';

  @override
  Future<void> initialize(String apiKey) async {
    await _channel.invokeMethod('initialize', {
      'apiKey': apiKey,
    });
  }

  /// Assign new identifiers and attributes to the currently tracked profile once.
  @override
  Future<String> updateProfile(KlaviyoProfileModel profileModel) async {
    /// If the user is not identified, we will update the profile with the external_id
    if (userId.isEmpty) {
      userId = profileModel.id;

      final resultMap = await _channel.invokeMethod<String>(
        'updateProfile',
        profileModel.toJson(),
      );

      return resultMap.toString();
    } else {
      return 'user[$userId] already updated';
    }
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
}
