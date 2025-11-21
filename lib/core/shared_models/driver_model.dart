import 'dart:convert';

class DriverModel {
  final String id;
  final String name;
  final String email;
  final String phone;
  final String? licenceImage;
  final Map<String, dynamic>? licenceData;
  final double? rate;
  final Map<String, dynamic>? carInfo;
  final bool activated;
  final bool online;
  final double? lat;
  final double? lng;
  final String? city;
  final String? profileImage;
  final DateTime? createdAt;

  DriverModel({
    required this.id,
    required this.name,
    required this.email,
    required this.phone,
    this.licenceImage,
    this.licenceData,
    this.rate,
    this.carInfo,
    this.activated = false,
    this.online = false,
    this.lat,
    this.lng,
    this.city,
    this.profileImage,
    this.createdAt,
  });

  /// Factory to create DriverModel from Supabase/JSON map
  factory DriverModel.fromJson(Map<String, dynamic> json) {
    return DriverModel(
      id: json['id'] ?? '',
      name: json['name'] ?? '',
      email: json['email'] ?? '',
      phone: json['phone'] ?? '',
      licenceImage: json['licence_image'],
      licenceData: json['licence_data'] is String
          ? jsonDecode(json['licence_data'])
          : json['licence_data'],
      rate: (json['rate'] != null)
          ? double.tryParse(json['rate'].toString())
          : null,
      carInfo: json['car_info'] is String
          ? jsonDecode(json['car_info'])
          : json['car_info'],
      activated: json['activated'] ?? false,
      online: json['online'] ?? false,
      lat: (json['lat'] != null)
          ? double.tryParse(json['lat'].toString())
          : null,
      lng: (json['lng'] != null)
          ? double.tryParse(json['lng'].toString())
          : null,
      city: json['city'],
      profileImage: json['profile_image'],
      createdAt: json['created_at'] != null
          ? DateTime.tryParse(json['created_at'])
          : null,
    );
  }

  /// Convert model to JSON for inserting/updating in Supabase
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'email': email,
      'phone': phone,
      'licence_image': licenceImage,
      'licence_data': licenceData,
      'rate': rate,
      'car_info': carInfo,
      'activated': activated,
      'online': online,
      'lat': lat,
      'lng': lng,
      'city': city,
      'profile_image': profileImage,
      'created_at': createdAt?.toIso8601String(),
    };
  }

  /// Optional helper: clone with updated fields
  DriverModel copyWith({
    String? id,
    String? name,
    String? email,
    String? phone,
    String? licenceImage,
    Map<String, dynamic>? licenceData,
    double? rate,
    Map<String, dynamic>? carInfo,
    bool? activated,
    bool? online,
    double? lat,
    double? lng,
    String? city,
    String? profileImage,
    DateTime? createdAt,
  }) {
    return DriverModel(
      id: id ?? this.id,
      name: name ?? this.name,
      email: email ?? this.email,
      phone: phone ?? this.phone,
      licenceImage: licenceImage ?? this.licenceImage,
      licenceData: licenceData ?? this.licenceData,
      rate: rate ?? this.rate,
      carInfo: carInfo ?? this.carInfo,
      activated: activated ?? this.activated,
      online: online ?? this.online,
      lat: lat ?? this.lat,
      lng: lng ?? this.lng,
      city: city ?? this.city,
      profileImage: profileImage ?? this.profileImage,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}
