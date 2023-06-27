import 'package:equatable/equatable.dart';

class KlaviyoProfile extends Equatable {
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
  final String? region;
  final String? latitude;
  final String? longitude;
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
    this.region,
    this.latitude,
    this.longitude,
    this.properties,
  });

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
        region,
        latitude,
        longitude,
        properties,
      ];

  @override
  String toString() {
    var properties = toJson().toString();

    var propsWithoutBrackets = properties.substring(1, properties.length - 1);

    return 'KlaviyoProfile($propsWithoutBrackets)';
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
        'region': region,
        'latitude': latitude,
        'longitude': longitude,
        'properties': properties,
      };
}
