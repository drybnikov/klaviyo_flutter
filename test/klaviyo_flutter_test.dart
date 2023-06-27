import 'package:flutter_test/flutter_test.dart';
import 'package:klaviyo_flutter/klaviyo_flutter.dart';

import 'test_method_channel.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('Klaviyo', () {
    setUp(() {
      setUpTestMethodChannel('com.rightbite.denisr/klaviyo');
    });

    test('initialize', () {
      final apiKey = 'mock';

      Klaviyo.instance.initialize(apiKey);

      expectMethodCall('initialize', arguments: {
        'apiKey': apiKey,
      });
    });

    test('updateUser', () {
      Klaviyo.instance.updateProfile(
        KlaviyoProfile(
          id: '1',
          email: 'test@example.com',
          phoneNumber: '+37256123456',
          firstName: 'John Doe',
          lastName: 'Doe',
          organization: 'Organization',
          title: 'title',
          image: 'http://someurl.com/image.png',
          address1: 'Some street 1',
          address2: 'Some steet 2',
          region: 'Tallinn',
          latitude: '59.436962',
          longitude: '24.753574',
          properties: {
            'app_version': 321,
          },
        ),
      );
      expectMethodCall(
        'updateProfile',
        arguments: {
          'external_id': '1',
          'email': 'test@example.com',
          'phone_number': '+37256123456',
          'first_name': 'John Doe',
          'last_name': 'Doe',
          'organization': 'Organization',
          'title': 'title',
          'image': 'http://someurl.com/image.png',
          'address1': 'Some street 1',
          'address2': 'Some steet 2',
          'region': 'Tallinn',
          'latitude': '59.436962',
          'longitude': '24.753574',
          'properties': {
            'app_version': 321,
          }
        },
      );
    });

    test('resetProfile', () {
      Klaviyo.instance.resetProfile();

      expectMethodCall('resetProfile');
    });
  });

  group('logEvent', () {
    test('withoutMetaData', () {
      Klaviyo.instance.logEvent('TEST');
      expectMethodCall('logEvent', arguments: {
        'name': 'TEST',
        'metaData': null,
      });
    });

    test('withMetaData', () {
      Klaviyo.instance.logEvent(
        'TEST',
        {'string': 'A string', 'number': 10, 'bool': true},
      );
      expectMethodCall('logEvent', arguments: {
        'name': 'TEST',
        'metaData': {'string': 'A string', 'number': 10, 'bool': true},
      });
    });
  });
}
