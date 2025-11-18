import 'package:equatable/equatable.dart';

/// Immutable representation of the profile data that can be sent to Klaviyo.
///
/// Every field is optional so that apps can submit partial updates without
/// rebuilding the entire profile. When a value is omitted Klaviyo keeps the
/// previously stored value (if any).
class KlaviyoProfile extends Equatable {
  static const _unset = Object();

  final String? id;
  final String? email;
  final String? phoneNumber;
  final String? firstName;
  final String? lastName;
  final String? organization;
  final String? title;
  final String? image;
  final String? address1;
  final String? address2;
  final String? city;
  final String? country;
  final String? region;
  final String? zip;
  final String? timezone;
  final double? latitude;
  final double? longitude;
  final Map<String, dynamic>? properties;

  const KlaviyoProfile({
    this.id,
    this.email,
    this.phoneNumber,
    this.firstName,
    this.lastName,
    this.organization,
    this.title,
    this.image,
    this.address1,
    this.address2,
    this.city,
    this.country,
    this.region,
    this.zip,
    this.timezone,
    this.latitude,
    this.longitude,
    this.properties,
  });

  /// Creates a profile from a JSON structure.
  factory KlaviyoProfile.fromJson(Map<String, dynamic> json) {
    return KlaviyoProfile(
      id: json['external_id'] as String?,
      email: json['email'] as String?,
      phoneNumber: json['phone_number'] as String?,
      firstName: json['first_name'] as String?,
      lastName: json['last_name'] as String?,
      organization: json['organization'] as String?,
      title: json['title'] as String?,
      image: json['image'] as String?,
      address1: json['address1'] as String?,
      address2: json['address2'] as String?,
      city: json['city'] as String?,
      country: json['country'] as String?,
      region: json['region'] as String?,
      zip: json['zip'] as String?,
      timezone: json['timezone'] as String?,
      latitude: (json['latitude'] as num?)?.toDouble(),
      longitude: (json['longitude'] as num?)?.toDouble(),
      properties: json['properties'] as Map<String, dynamic>?,
    );
  }

  /// Returns a new instance with the provided overrides.
  ///
  /// **Note:** This method cannot clear individual profile fields. To clear fields,
  /// use `Klaviyo.resetProfile()` to clear all data, then call `updateProfile()`
  /// with only the fields you want to keep.
  KlaviyoProfile copyWith({
    Object? id = _unset,
    Object? email = _unset,
    Object? phoneNumber = _unset,
    Object? firstName = _unset,
    Object? lastName = _unset,
    Object? organization = _unset,
    Object? title = _unset,
    Object? image = _unset,
    Object? address1 = _unset,
    Object? address2 = _unset,
    Object? city = _unset,
    Object? country = _unset,
    Object? region = _unset,
    Object? zip = _unset,
    Object? timezone = _unset,
    Object? latitude = _unset,
    Object? longitude = _unset,
    Object? properties = _unset,
  }) {
    return KlaviyoProfile(
      id: _resolve(id, this.id),
      email: _resolve(email, this.email),
      phoneNumber: _resolve(phoneNumber, this.phoneNumber),
      firstName: _resolve(firstName, this.firstName),
      lastName: _resolve(lastName, this.lastName),
      organization: _resolve(organization, this.organization),
      title: _resolve(title, this.title),
      image: _resolve(image, this.image),
      address1: _resolve(address1, this.address1),
      address2: _resolve(address2, this.address2),
      city: _resolve(city, this.city),
      country: _resolve(country, this.country),
      region: _resolve(region, this.region),
      zip: _resolve(zip, this.zip),
      timezone: _resolve(timezone, this.timezone),
      latitude: _resolveDouble(latitude, this.latitude, 'latitude'),
      longitude: _resolveDouble(longitude, this.longitude, 'longitude'),
      properties: _resolve(properties, this.properties),
    );
  }

  static T? _resolve<T>(Object? candidate, T? fallback) {
    // Treat both _unset and null as "keep the old value"
    // This prevents clearing individual fields via copyWith(field: null)
    return identical(candidate, _unset) || candidate == null
        ? fallback
        : candidate as T?;
  }

  static double? _resolveDouble(
    Object? candidate,
    double? fallback,
    String fieldName,
  ) {
    if (identical(candidate, _unset) || candidate == null) {
      return fallback;
    }
    if (candidate is num) {
      return candidate.toDouble();
    }
    throw ArgumentError.value(
      candidate,
      fieldName,
      'must be a numeric value',
    );
  }

  @override
  List<Object?> get props => [
        id,
        email,
        phoneNumber,
        firstName,
        lastName,
        organization,
        title,
        image,
        address1,
        address2,
        city,
        country,
        region,
        zip,
        timezone,
        latitude,
        longitude,
        properties,
      ];

  @override
  String toString() {
    final payload = toJson().toString();
    return 'KlaviyoProfile(${payload.substring(1, payload.length - 1)})';
  }

  Map<String, dynamic> toJson() => {
        'external_id': id,
        'email': email,
        'phone_number': phoneNumber,
        'first_name': firstName,
        'last_name': lastName,
        'organization': organization,
        'title': title,
        'image': image,
        'address1': address1,
        'address2': address2,
        'city': city,
        'country': country,
        'region': region,
        'zip': zip,
        'timezone': timezone,
        'latitude': latitude,
        'longitude': longitude,
        'properties': properties,
      };
}
