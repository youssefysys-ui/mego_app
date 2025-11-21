import 'dart:math' as math;

class RideLocationUpdateModel {
  final String id;
  final String rideId;
  final String driverId;
  final double lat;
  final double lng;
  final DateTime recordedAt;

  RideLocationUpdateModel({
    required this.id,
    required this.rideId,
    required this.driverId,
    required this.lat,
    required this.lng,
    required this.recordedAt,
  });

  factory RideLocationUpdateModel.fromJson(Map<String, dynamic> json) {
    return RideLocationUpdateModel(
      id: json['id']?.toString() ?? '',
      rideId: json['ride_id']?.toString() ?? '',
      driverId: json['driver_id']?.toString() ?? '',
      lat: _parseDouble(json['lat']),
      lng: _parseDouble(json['lng']),
      recordedAt: json['recorded_at'] != null 
          ? DateTime.parse(json['recorded_at'].toString())
          : DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'ride_id': rideId,
      'driver_id': driverId,
      'lat': lat,
      'lng': lng,
      'recorded_at': recordedAt.toIso8601String(),
    };
  }

  RideLocationUpdateModel copyWith({
    String? id,
    String? rideId,
    String? driverId,
    double? lat,
    double? lng,
    DateTime? recordedAt,
  }) {
    return RideLocationUpdateModel(
      id: id ?? this.id,
      rideId: rideId ?? this.rideId,
      driverId: driverId ?? this.driverId,
      lat: lat ?? this.lat,
      lng: lng ?? this.lng,
      recordedAt: recordedAt ?? this.recordedAt,
    );
  }

  // Helper methods
  String get coordinates => '${lat.toStringAsFixed(6)}, ${lng.toStringAsFixed(6)}';
  
  String get formattedTime {
    final now = DateTime.now();
    final diff = now.difference(recordedAt);
    
    if (diff.inMinutes < 1) {
      return 'Now';
    } else if (diff.inMinutes < 60) {
      return '${diff.inMinutes}m ago';
    } else if (diff.inHours < 24) {
      return '${diff.inHours}h ago';
    } else {
      return '${recordedAt.day}/${recordedAt.month}/${recordedAt.year}';
    }
  }

  bool get isRecent => DateTime.now().difference(recordedAt).inMinutes < 5;

  // Calculate distance to another point (in meters using Haversine formula)
  double distanceTo(double otherLat, double otherLng) {
    const double earthRadius = 6371000; // Earth's radius in meters
    
    final double lat1Rad = lat * (math.pi / 180);
    final double lat2Rad = otherLat * (math.pi / 180);
    final double deltaLatRad = (otherLat - lat) * (math.pi / 180);
    final double deltaLngRad = (otherLng - lng) * (math.pi / 180);

    final double a = math.sin(deltaLatRad / 2) * math.sin(deltaLatRad / 2) +
        math.cos(lat1Rad) * math.cos(lat2Rad) *
        math.sin(deltaLngRad / 2) * math.sin(deltaLngRad / 2);
    
    final double c = 2 * math.asin(math.sqrt(a));
    
    return earthRadius * c;
  }

  String formattedDistanceTo(double otherLat, double otherLng) {
    final distance = distanceTo(otherLat, otherLng);
    
    if (distance < 1000) {
      return '${distance.round()}m';
    } else {
      return '${(distance / 1000).toStringAsFixed(1)}km';
    }
  }

  static double _parseDouble(dynamic value) {
    if (value == null) return 0.0;
    if (value is double) return value;
    if (value is int) return value.toDouble();
    return double.tryParse(value.toString()) ?? 0.0;
  }

  @override
  String toString() => 'RideLocationUpdateModel(id: $id, coordinates: $coordinates, time: $formattedTime)';

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is RideLocationUpdateModel && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;
}