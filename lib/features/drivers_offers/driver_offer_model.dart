import 'package:mego_app/core/shared_models/driver_model.dart';

class DriverOfferModel {
  final String id;
  final String rideRequestId;
  final String driverId;
  final double offeredPrice;
  final int estimatedTime;
  final String status;
  final DateTime offerExpiresAt;
  final DateTime createdAt;
  // Driver model containing all driver information
  final DriverModel? driver;
  // Additional fields for backward compatibility
  final String? driverName;
  final double? driverRating;
  final String? carModel;
  final int? reviewsCount;
  final String? profileImage;

  DriverOfferModel({
    required this.id,
    required this.rideRequestId,
    required this.driverId,
    required this.offeredPrice,
    required this.estimatedTime,
    required this.status,
    required this.offerExpiresAt,
    required this.createdAt,
    this.driver,
    this.driverName,
    this.driverRating,
    this.carModel,
    this.reviewsCount,
    this.profileImage,
  });

  factory DriverOfferModel.fromJson(Map<String, dynamic> json) {
    // Parse driver data if available (from joins or separate data)
    DriverModel? driver;
    if (json['driver'] != null) {
      driver = DriverModel.fromJson(json['driver'] as Map<String, dynamic>);
    } else if (json['drivers'] != null) {
      // Handle Supabase join format
      driver = DriverModel.fromJson(json['drivers'] as Map<String, dynamic>);
    }

    return DriverOfferModel(
      id: json['id']?.toString() ?? '',
      rideRequestId: json['ride_request_id']?.toString() ?? '',
      driverId: json['driver_id']?.toString() ?? '',
      offeredPrice: _parseDouble(json['offered_price']),
      estimatedTime: _parseInt(json['estimated_time']),
      status: json['status']?.toString() ?? 'pending',
      offerExpiresAt: json['offer_expires_at'] != null
          ? DateTime.parse(json['offer_expires_at'].toString())
          : DateTime.now().add(const Duration(seconds: 40)),
      createdAt: json['created_at'] != null
          ? DateTime.parse(json['created_at'].toString())
          : DateTime.now(),
      driver: driver,
      driverName: json['driver_name']?.toString(),
      driverRating: _parseDouble(json['driver_rating']),
      carModel: json['car_model']?.toString(),
      reviewsCount: _parseInt(json['reviews_count']),
      profileImage: json['profile_image']?.toString(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'ride_request_id': rideRequestId,
      'driver_id': driverId,
      'offered_price': offeredPrice,
      'estimated_time': estimatedTime,
      'status': status,
      'offer_expires_at': offerExpiresAt.toIso8601String(),
      'created_at': createdAt.toIso8601String(),
      'driver_name': driverName,
      'driver_rating': driverRating,
      'car_model': carModel,
      'reviews_count': reviewsCount,
      'profile_image': profileImage,
    };
  }

  DriverOfferModel copyWith({
    String? id,
    String? rideRequestId,
    String? driverId,
    double? offeredPrice,
    int? estimatedTime,
    String? status,
    DateTime? offerExpiresAt,
    DateTime? createdAt,
    DriverModel? driver,
    String? driverName,
    double? driverRating,
    String? carModel,
    int? reviewsCount,
    String? profileImage,
  }) {
    return DriverOfferModel(
      id: id ?? this.id,
      rideRequestId: rideRequestId ?? this.rideRequestId,
      driverId: driverId ?? this.driverId,
      offeredPrice: offeredPrice ?? this.offeredPrice,
      estimatedTime: estimatedTime ?? this.estimatedTime,
      status: status ?? this.status,
      offerExpiresAt: offerExpiresAt ?? this.offerExpiresAt,
      createdAt: createdAt ?? this.createdAt,
      driver: driver ?? this.driver,
      driverName: driverName ?? this.driverName,
      driverRating: driverRating ?? this.driverRating,
      carModel: carModel ?? this.carModel,
      reviewsCount: reviewsCount ?? this.reviewsCount,
      profileImage: profileImage ?? this.profileImage,
    );
  }

  // Status constants
  static const String statusPending = 'pending';
  static const String statusAccepted = 'accepted';
  static const String statusRejected = 'rejected';
  static const String statusExpired = 'expired';

  // Status helpers
  bool get isPending => status == statusPending;
  bool get isAccepted => status == statusAccepted;
  bool get isRejected => status == statusRejected;
  bool get isExpired => status == statusExpired || DateTime.now().isAfter(offerExpiresAt);
  bool get isActive => isPending && !isExpired;

  // Formatted getters
  String get formattedPrice => offeredPrice.toInt().toString();
  String get formattedTime => '${estimatedTime} mins';

  // UI display getters - prioritize DriverModel data
  String get displayName {
    if (driver?.name != null) return driver!.name;
    if (driverName != null) return driverName!;
    return 'Driver ${driverId.split('_').first}';
  }

  String get displayRating {
    if (driver?.rate != null) return driver!.rate!.toStringAsFixed(1);
    if (driverRating != null) return driverRating!.toStringAsFixed(1);
    return '4.8';
  }

  String get displayReviews => reviewsCount != null ? '($reviewsCount reviews)' : '(531 reviews)';

  String get displayCar {
    if (driver?.carInfo?['model'] != null) {
      final carModel = driver!.carInfo!['model'];
      final carColor = driver!.carInfo?['color'] ?? '';
      return carColor.isNotEmpty ? '$carModel • $carColor' : carModel;
    }
    if (carModel != null) return carModel!;
    return 'Chevrolet Laceti';
  }

  String get displayPhone => driver?.phone ?? '+20 100 123 4567';

  String get displayProfileImage {
    if (driver?.profileImage != null) return driver!.profileImage!;
    if (profileImage != null) return profileImage!;
    return 'https://i.pravatar.cc/150?u=$driverId';
  }

  String get displayPlateNumber {
    if (driver?.carInfo?['plate_number'] != null) {
      return driver!.carInfo!['plate_number'];
    }
    // Generate a default plate number based on driver ID
    final hash = driverId.hashCode.abs();
    return 'AAH ${hash.toString().padLeft(4, '0').substring(0, 4)}';
  }

  Duration get timeUntilExpiry => offerExpiresAt.difference(DateTime.now());
  String get formattedTimeUntilExpiry {
    final duration = timeUntilExpiry;
    if (duration.isNegative) return 'Expired';
    if (duration.inMinutes < 1) return '${duration.inSeconds}s';
    return '${duration.inMinutes}m ${duration.inSeconds % 60}s';
  }

  static double _parseDouble(dynamic value) {
    if (value == null) return 0.0;
    if (value is double) return value;
    if (value is int) return value.toDouble();
    return double.tryParse(value.toString()) ?? 0.0;
  }

  static int _parseInt(dynamic value) {
    if (value == null) return 0;
    if (value is int) return value;
    if (value is double) return value.round();
    return int.tryParse(value.toString()) ?? 0;
  }

  @override
  String toString() => 'DriverOfferModel(id: $id, price: $formattedPrice, status: $status)';

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is DriverOfferModel && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;
}