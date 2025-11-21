class RideModel {
  final String id;
  final String rideRequestId;
  final String driverId;
  final String riderId;
  final DateTime startTime;
  final DateTime? endTime;
  final double totalPrice;
  final String status;
  final double? currentDriverLat;
  final double? currentDriverLng;
  final DateTime createdAt;

  RideModel({
    required this.id,
    required this.rideRequestId,
    required this.driverId,
    required this.riderId,
    required this.startTime,
    this.endTime,
    required this.totalPrice,
    required this.status,
    this.currentDriverLat,
    this.currentDriverLng,
    required this.createdAt,
  });

  factory RideModel.fromJson(Map<String, dynamic> json) {
    return RideModel(
      id: json['id']?.toString() ?? '',
      rideRequestId: json['ride_request_id']?.toString() ?? '',
      driverId: json['driver_id']?.toString() ?? '',
      riderId: json['rider_id']?.toString() ?? '',
      startTime: json['start_time'] != null 
          ? DateTime.parse(json['start_time'].toString())
          : DateTime.now(),
      endTime: json['end_time'] != null 
          ? DateTime.parse(json['end_time'].toString())
          : null,
      totalPrice: _parseDouble(json['total_price']),
      status: json['status']?.toString() ?? 'started',
      currentDriverLat: json['current_driver_lat'] != null 
          ? _parseDouble(json['current_driver_lat'])
          : null,
      currentDriverLng: json['current_driver_lng'] != null 
          ? _parseDouble(json['current_driver_lng'])
          : null,
      createdAt: json['created_at'] != null 
          ? DateTime.parse(json['created_at'].toString())
          : DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'ride_request_id': rideRequestId,
      'driver_id': driverId,
      'rider_id': riderId,
      'start_time': startTime.toIso8601String(),
      'end_time': endTime?.toIso8601String(),
      'total_price': totalPrice,
      'status': status,
      'current_driver_lat': currentDriverLat,
      'current_driver_lng': currentDriverLng,
      'created_at': createdAt.toIso8601String(),
    };
  }

  RideModel copyWith({
    String? id,
    String? rideRequestId,
    String? driverId,
    String? riderId,
    DateTime? startTime,
    DateTime? endTime,
    double? totalPrice,
    String? status,
    double? currentDriverLat,
    double? currentDriverLng,
    DateTime? createdAt,
  }) {
    return RideModel(
      id: id ?? this.id,
      rideRequestId: rideRequestId ?? this.rideRequestId,
      driverId: driverId ?? this.driverId,
      riderId: riderId ?? this.riderId,
      startTime: startTime ?? this.startTime,
      endTime: endTime ?? this.endTime,
      totalPrice: totalPrice ?? this.totalPrice,
      status: status ?? this.status,
      currentDriverLat: currentDriverLat ?? this.currentDriverLat,
      currentDriverLng: currentDriverLng ?? this.currentDriverLng,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  // Status constants
  static const String statusStarted = 'started';
  static const String statusInProgress = 'in_progress';
  static const String statusCompleted = 'completed';
  static const String statusCancelled = 'cancelled';

  // Status helpers
  bool get isStarted => status == statusStarted;
  bool get isInProgress => status == statusInProgress;
  bool get isCompleted => status == statusCompleted;
  bool get isCancelled => status == statusCancelled;
  bool get isActive => isStarted || isInProgress;
  bool get isFinished => isCompleted || isCancelled;

  // Formatted getters
  String get formattedPrice => '€${totalPrice.toStringAsFixed(2)}';
  
  Duration? get rideDuration {
    if (endTime == null) return null;
    return endTime!.difference(startTime);
  }

  String get formattedDuration {
    final duration = rideDuration;
    if (duration == null) return 'Ongoing';
    
    final hours = duration.inHours;
    final minutes = duration.inMinutes % 60;
    
    if (hours > 0) {
      return '${hours}h ${minutes}m';
    } else {
      return '${minutes}m';
    }
  }

  Duration get currentDuration => DateTime.now().difference(startTime);
  
  String get formattedCurrentDuration {
    final duration = currentDuration;
    final hours = duration.inHours;
    final minutes = duration.inMinutes % 60;
    
    if (hours > 0) {
      return '${hours}h ${minutes}m';
    } else {
      return '${minutes}m';
    }
  }

  bool get hasDriverLocation => currentDriverLat != null && currentDriverLng != null;

  static double _parseDouble(dynamic value) {
    if (value == null) return 0.0;
    if (value is double) return value;
    if (value is int) return value.toDouble();
    return double.tryParse(value.toString()) ?? 0.0;
  }

  @override
  String toString() => 'RideModel(id: $id, status: $status, price: $formattedPrice)';

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is RideModel && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;
}