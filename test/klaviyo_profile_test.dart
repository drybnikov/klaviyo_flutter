import 'package:flutter_test/flutter_test.dart';
import 'package:klaviyo_flutter/src/klaviyo_profile.dart';

void main() {
  group('KlaviyoProfile', () {
    test('toJson includes all populated fields', () {
      final profile = KlaviyoProfile(
        id: 'id-1',
        email: 'user@example.com',
        phoneNumber: '+123456789',
        firstName: 'First',
        lastName: 'Last',
        organization: 'Org',
        title: 'Title',
        image: 'https://example.com/avatar.png',
        address1: 'Line 1',
        address2: 'Line 2',
        city: 'City',
        country: 'Country',
        region: 'Region',
        zip: '12345',
        timezone: 'Europe/Tallinn',
        latitude: 10.0,
        longitude: -20.5,
        properties: {'tier': 'gold'},
      );

      expect(profile.toJson(), {
        'external_id': 'id-1',
        'email': 'user@example.com',
        'phone_number': '+123456789',
        'first_name': 'First',
        'last_name': 'Last',
        'organization': 'Org',
        'title': 'Title',
        'image': 'https://example.com/avatar.png',
        'address1': 'Line 1',
        'address2': 'Line 2',
        'city': 'City',
        'country': 'Country',
        'region': 'Region',
        'zip': '12345',
        'timezone': 'Europe/Tallinn',
        'latitude': 10.0,
        'longitude': -20.5,
        'properties': {'tier': 'gold'},
      });
    });

    test('fromJson mirrors toJson', () {
      final json = {
        'external_id': 'id-2',
        'email': 'friend@example.com',
        'city': 'Tallinn',
        'latitude': 1,
        'longitude': -1,
      };

      final profile = KlaviyoProfile.fromJson(json);
      expect(profile.id, 'id-2');
      expect(profile.email, 'friend@example.com');
      expect(profile.city, 'Tallinn');
      expect(profile.latitude, 1);
      expect(profile.longitude, -1);
    });

    test('copyWith overrides values', () {
      final profile = KlaviyoProfile(
        email: 'first@example.com',
        city: 'Berlin',
        latitude: 1,
      );

      final updated = profile.copyWith(
        email: 'second@example.com',
        latitude: 2.5,
      );

      expect(updated.email, 'second@example.com');
      expect(updated.city, 'Berlin'); // unchanged
      expect(updated.latitude, 2.5);
    });

    test('copyWith with null keeps original values', () {
      final profile = KlaviyoProfile(
        email: 'user@example.com',
        city: 'New York',
        firstName: 'John',
      );

      // Passing null should NOT clear the field
      final updated = profile.copyWith(
        city: null,
        firstName: 'Jane',
      );

      expect(updated.email, 'user@example.com'); // unchanged
      expect(updated.city, 'New York'); // unchanged despite null
      expect(updated.firstName, 'Jane'); // updated
    });

    test('copyWith accepts integers for latitude/longitude', () {
      final profile = KlaviyoProfile(
        latitude: 1.5,
        longitude: -1.25,
      );

      final updated = profile.copyWith(
        latitude: 3,
        longitude: -2,
      );

      expect(updated.latitude, 3.0);
      expect(updated.longitude, -2.0);
    });
  });
}
