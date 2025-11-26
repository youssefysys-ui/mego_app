
class UserRideData {
  final String userId;
  final double latFrom;
  final double latTo;
  final double lngFrom;
  final double lngTo;
  final String placeFrom;
  final int est_time;
  final double est_price;
  final String placeTo;
  final String? rideRequestId; // Optional, will be set after ride request creation
  final String? couponId; // Coupon ID if applied
  final double? originalPrice; // Price before discount
  final double? discountAmount; // Discount amount

  UserRideData({
    required this.userId,
    required this.latFrom,
    required this.latTo,
    required this.est_price,
    required this.est_time,
    required this.lngFrom,
    required this.lngTo,
    required this.placeFrom,
    required this.placeTo,
    this.rideRequestId,
    this.couponId,
    this.originalPrice,
    this.discountAmount,
  });

  // Factory constructor for creating from JSON
  factory UserRideData.fromJson(Map<String, dynamic> json) {
    return UserRideData(
      userId: json['user_id'] as String,
      latFrom: (json['lat_from'] as num).toDouble(),
      est_price: (json['est_price'] as num).toDouble(),
      est_time: (json['est_time'] as num).toInt(),
      latTo: (json['lat_to'] as num).toDouble(),
      lngFrom: (json['lng_from'] as num).toDouble(),
      lngTo: (json['lng_to'] as num).toDouble(),
      placeFrom: json['place_from'] as String,
      placeTo: json['place_to'] as String,
      rideRequestId: json['ride_request_id'] as String?,
    );
  }

  // Convert to JSON
  Map<String, dynamic> toJson() {
    return {
      'user_id': userId,
      'lat_from': latFrom,
      'lat_to': latTo,
      'lng_from': lngFrom,
      'lng_to': lngTo,
       'est_price': est_price,
       'est_time': est_time,
      'place_from': placeFrom,
      'place_to': placeTo,
      'ride_request_id': rideRequestId,
    };
  }

  // Copy with method for immutability
  UserRideData copyWith({
    String? userId,
    double? latFrom,
    double? latTo,
    double? lngFrom,
    double? lngTo,
    int? est_time,
    double? est_price,
    String? placeFrom,
    String? placeTo,
    String? rideRequestId,
  }) {
    return UserRideData(
      userId: userId ?? this.userId,
      latFrom: latFrom ?? this.latFrom,
      latTo: latTo ?? this.latTo,
      lngFrom: lngFrom ?? this.lngFrom,
      lngTo: lngTo ?? this.lngTo,
      est_time: est_time ?? this.est_time,
      est_price: est_price ?? this.est_price,
      placeFrom: placeFrom ?? this.placeFrom,
      placeTo: placeTo ?? this.placeTo,
      rideRequestId: rideRequestId ?? this.rideRequestId,
    );
  }

  @override
  String toString() {
    return 'UserRideData(userId: $userId, latFrom: $latFrom, latTo: $latTo, lngFrom: $lngFrom, lngTo: $lngTo, placeFrom: $placeFrom, placeTo: $placeTo, rideRequestId: $rideRequestId)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is UserRideData &&
        other.userId == userId &&
        other.latFrom == latFrom &&
        other.latTo == latTo &&
        other.lngFrom == lngFrom &&
        other.lngTo == lngTo &&
        other.placeFrom == placeFrom &&
        other.placeTo == placeTo &&
        other.rideRequestId == rideRequestId;
  }

  @override
  int get hashCode {
    return userId.hashCode ^
        latFrom.hashCode ^
        latTo.hashCode ^
        lngFrom.hashCode ^
        lngTo.hashCode ^
        placeFrom.hashCode ^
        placeTo.hashCode ^
        rideRequestId.hashCode;
  }
}
