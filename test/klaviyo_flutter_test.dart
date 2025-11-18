import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:klaviyo_flutter/klaviyo_flutter.dart';
import 'package:klaviyo_flutter/src/klaviyo_flutter_platform_interface.dart';

void main() {
  final realPlatform = KlaviyoFlutterPlatform.instance;
  late _RecordingPlatform platform;

  setUp(() {
    platform = _RecordingPlatform();
    KlaviyoFlutterPlatform.instance = platform;
    Klaviyo.instance.debugReset();
  });

  tearDown(() {
    KlaviyoFlutterPlatform.instance = realPlatform;
  });

  group('Initialization', () {
    test('initialize with valid API key delegates to platform', () async {
      await Klaviyo.instance.initialize('public-key');

      expect(platform.calls.single.method, 'initialize');
      expect(platform.calls.single.arguments, {'apiKey': 'public-key'});
      expect(Klaviyo.instance.isInitialized, isTrue);
    });

    test('initialize with empty API key throws', () async {
      expect(() => Klaviyo.instance.initialize('   '), throwsArgumentError);
      expect(platform.calls, isEmpty);
      expect(Klaviyo.instance.isInitialized, isFalse);
    });
  });

  group('Event logging', () {
    test('logEvent with name only', () async {
      await Klaviyo.instance.logEvent('purchase');

      final call = platform.calls.single;
      expect(call.method, 'logEvent');
      expect(call.arguments, {'name': 'purchase', 'metaData': null});
    });

    test('logEvent with metadata map', () async {
      await Klaviyo.instance.logEvent('purchase', {
        '\$value': 15.5,
        'success': true,
        'items': ['sku'],
      });

      final call = platform.calls.single;
      expect(call.method, 'logEvent');
      expect(call.arguments, {
        'name': 'purchase',
        'metaData': {
          '\$value': 15.5,
          'success': true,
          'items': ['sku'],
        }
      });
    });

    test('logEvent with empty metadata map', () async {
      await Klaviyo.instance.logEvent('purchase', {});

      final call = platform.calls.single;
      expect(call.method, 'logEvent');
      expect(call.arguments, {
        'name': 'purchase',
        'metaData': <String, dynamic>{},
      });
    });
  });

  group('Profile updates', () {
    test('updateProfile forwards payload map', () async {
      final profile = KlaviyoProfile(
        id: '1',
        email: 'user@example.com',
        phoneNumber: '+123456789',
        city: 'Berlin',
        latitude: 1.1,
        longitude: 2.2,
        properties: {'tier': 'gold'},
      );

      await Klaviyo.instance.updateProfile(profile);

      final call = platform.calls.single;
      expect(call.method, 'updateProfile');
      expect(call.arguments, profile.toJson());
    });

    test('updateProfile returns platform response', () async {
      platform.setResponse('updateProfile', 'updated');
      final result = await Klaviyo.instance
          .updateProfile(const KlaviyoProfile(email: 'someone@example.com'));

      expect(result, 'updated');
    });
  });

  group('Individual setters', () {
    Future<void> expectSetter(
      String method,
      Map<String, dynamic> args,
      Future<void> Function() action,
    ) async {
      await action();
      final call = platform.calls.single;
      expect(call.method, method);
      expect(call.arguments, args);
    }

    test('setters delegate to platform', () async {
      await expectSetter('setExternalId', {'id': '42'},
          () => Klaviyo.instance.setExternalId('42'));
      platform.clear();

      await expectSetter('setEmail', {'email': 'user@example.com'},
          () => Klaviyo.instance.setEmail('user@example.com'));
      platform.clear();

      await expectSetter('setPhoneNumber', {'phoneNumber': '+1'},
          () => Klaviyo.instance.setPhoneNumber('+1'));
      platform.clear();

      await expectSetter('setFirstName', {'firstName': 'First'},
          () => Klaviyo.instance.setFirstName('First'));
      platform.clear();

      await expectSetter('setLastName', {'lastName': 'Last'},
          () => Klaviyo.instance.setLastName('Last'));
      platform.clear();

      await expectSetter('setOrganization', {'organization': 'Org'},
          () => Klaviyo.instance.setOrganization('Org'));
      platform.clear();

      await expectSetter('setTitle', {'title': 'Title'},
          () => Klaviyo.instance.setTitle('Title'));
      platform.clear();

      await expectSetter('setImage', {'image': 'https://example.com'},
          () => Klaviyo.instance.setImage('https://example.com'));
      platform.clear();

      await expectSetter('setAddress1', {'address': 'Line1'},
          () => Klaviyo.instance.setAddress1('Line1'));
      platform.clear();

      await expectSetter('setAddress2', {'address': 'Line2'},
          () => Klaviyo.instance.setAddress2('Line2'));
      platform.clear();

      await expectSetter(
          'setCity', {'city': 'City'}, () => Klaviyo.instance.setCity('City'));
      platform.clear();

      await expectSetter('setCountry', {'country': 'Country'},
          () => Klaviyo.instance.setCountry('Country'));
      platform.clear();

      await expectSetter('setRegion', {'region': 'Region'},
          () => Klaviyo.instance.setRegion('Region'));
      platform.clear();

      await expectSetter(
          'setZip', {'zip': '12345'}, () => Klaviyo.instance.setZip('12345'));
      platform.clear();

      await expectSetter('setTimezone', {'timezone': 'Europe/Tallinn'},
          () => Klaviyo.instance.setTimezone('Europe/Tallinn'));
      platform.clear();

      await expectSetter('setLatitude', {'latitude': 1.2},
          () => Klaviyo.instance.setLatitude(1.2));
      platform.clear();

      await expectSetter('setLongitude', {'longitude': 3.4},
          () => Klaviyo.instance.setLongitude(3.4));
      platform.clear();

      await expectSetter(
        'setCustomAttribute',
        {'key': 'tier', 'value': 'gold'},
        () => Klaviyo.instance.setCustomAttribute('tier', 'gold'),
      );
      platform.clear();

      await expectSetter('setBadgeCount', {'count': 5},
          () => Klaviyo.instance.setBadgeCount(5));
    });
  });

  group('Getters', () {
    test('getters return platform responses', () async {
      platform
        ..setResponse('getExternalId', '42')
        ..setResponse('getEmail', 'user@example.com')
        ..setResponse('getPhoneNumber', '+1');

      expect(await Klaviyo.instance.getExternalId(), '42');
      expect(await Klaviyo.instance.getEmail(), 'user@example.com');
      expect(await Klaviyo.instance.getPhoneNumber(), '+1');
    });
  });

  group('Push handling', () {
    test('sendTokenToKlaviyo forwards token', () async {
      await Klaviyo.instance.sendTokenToKlaviyo('token');
      final call = platform.calls.single;
      expect(call.method, 'sendTokenToKlaviyo');
      expect(call.arguments, {'token': 'token'});
    });

    test('handlePush returns platform value', () async {
      platform.setResponse('handlePush', true);
      final result = await Klaviyo.instance.handlePush({'_k': '1'});

      expect(result, isTrue);
      final call = platform.calls.single;
      expect(call.method, 'handlePush');
      expect(call.arguments, {
        'message': {'_k': '1'},
      });
    });

    test('handlePush surfaces underlying errors', () async {
      platform.setError('handlePush', PlatformException(code: 'error'));

      expect(
        () => Klaviyo.instance.handlePush(const {}),
        throwsA(isA<PlatformException>()),
      );
    });

    test('isKlaviyoPush identifies Klaviyo payloads', () {
      expect(Klaviyo.instance.isKlaviyoPush({'_k': 'value'}), isTrue);
      expect(Klaviyo.instance.isKlaviyoPush({'body': 'value'}), isFalse);
    });
  });

  group('Profile reset', () {
    test('resetProfile delegates to platform', () async {
      await Klaviyo.instance.resetProfile();
      final call = platform.calls.single;
      expect(call.method, 'resetProfile');
    });
  });
}

class _Invocation {
  _Invocation(this.method, this.arguments);

  final String method;
  final Map<String, dynamic>? arguments;
}

class _RecordingPlatform extends KlaviyoFlutterPlatform {
  final List<_Invocation> calls = [];
  final Map<String, dynamic> _responses = {
    'logEvent': 'ok',
    'updateProfile': 'updated',
    'handlePush': false,
  };
  final Map<String, Object> _errors = {};

  void setResponse(String method, dynamic value) {
    _responses[method] = value;
  }

  void setError(String method, Object error) {
    _errors[method] = error;
  }

  void clear() => calls.clear();

  Future<T?> _record<T>(String method, Map<String, dynamic>? args) async {
    calls.add(_Invocation(method, args));
    final error = _errors[method];
    if (error != null) {
      if (error is Exception) throw error;
      throw Exception(error.toString());
    }
    return _responses[method] as T?;
  }

  @override
  Future<void> initialize(String apiKey) async {
    await _record<void>('initialize', {'apiKey': apiKey});
  }

  @override
  Future<void> sendTokenToKlaviyo(String token) async {
    await _record<void>('sendTokenToKlaviyo', {'token': token});
  }

  @override
  Future<String> logEvent(String name, [Map<String, dynamic>? metaData]) async {
    return (await _record<String>('logEvent', {
          'name': name,
          'metaData': metaData,
        })) ??
        'ok';
  }

  @override
  Future<String> updateProfile(KlaviyoProfile profileModel) async {
    return (await _record<String>('updateProfile', profileModel.toJson())) ??
        'updated';
  }

  @override
  Future<bool> handlePush(Map<String, dynamic> message) async {
    return (await _record<bool>('handlePush', {'message': message})) ?? false;
  }

  @override
  Future<void> setExternalId(String id) async {
    await _record<void>('setExternalId', {'id': id});
  }

  @override
  Future<String?> getExternalId() async {
    return _record<String?>('getExternalId', const <String, dynamic>{});
  }

  @override
  Future<void> resetProfile() async {
    await _record<void>('resetProfile', const <String, dynamic>{});
  }

  @override
  Future<void> setEmail(String email) async {
    await _record<void>('setEmail', {'email': email});
  }

  @override
  Future<String?> getEmail() async {
    return _record<String?>('getEmail', const <String, dynamic>{});
  }

  @override
  Future<void> setPhoneNumber(String phoneNumber) async {
    await _record<void>('setPhoneNumber', {'phoneNumber': phoneNumber});
  }

  @override
  Future<String?> getPhoneNumber() async {
    return _record<String?>('getPhoneNumber', const <String, dynamic>{});
  }

  @override
  Future<void> setFirstName(String firstName) async {
    await _record<void>('setFirstName', {'firstName': firstName});
  }

  @override
  Future<void> setLastName(String lastName) async {
    await _record<void>('setLastName', {'lastName': lastName});
  }

  @override
  Future<void> setTitle(String title) async {
    await _record<void>('setTitle', {'title': title});
  }

  @override
  Future<void> setOrganization(String organization) async {
    await _record<void>('setOrganization', {'organization': organization});
  }

  @override
  Future<void> setImage(String image) async {
    await _record<void>('setImage', {'image': image});
  }

  @override
  Future<void> setAddress1(String address) async {
    await _record<void>('setAddress1', {'address': address});
  }

  @override
  Future<void> setAddress2(String address) async {
    await _record<void>('setAddress2', {'address': address});
  }

  @override
  Future<void> setCity(String city) async {
    await _record<void>('setCity', {'city': city});
  }

  @override
  Future<void> setCountry(String country) async {
    await _record<void>('setCountry', {'country': country});
  }

  @override
  Future<void> setLatitude(double latitude) async {
    await _record<void>('setLatitude', {'latitude': latitude});
  }

  @override
  Future<void> setLongitude(double longitude) async {
    await _record<void>('setLongitude', {'longitude': longitude});
  }

  @override
  Future<void> setRegion(String region) async {
    await _record<void>('setRegion', {'region': region});
  }

  @override
  Future<void> setZip(String zip) async {
    await _record<void>('setZip', {'zip': zip});
  }

  @override
  Future<void> setTimezone(String timezone) async {
    await _record<void>('setTimezone', {'timezone': timezone});
  }

  @override
  Future<void> setCustomAttribute(String key, String value) async {
    await _record<void>('setCustomAttribute', {'key': key, 'value': value});
  }

  @override
  Future<void> setBadgeCount(int count) async {
    await _record<void>('setBadgeCount', {'count': count});
  }
}
