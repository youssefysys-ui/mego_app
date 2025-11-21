class RideRequestModel {
  final String id;
  final String userId;
  final double pickupLat;
  final double pickupLng;
  final double dropoffLat;
  final double dropoffLng;
  final double estimatedPrice;
  final int estimatedTime;
  final String status;
  final DateTime createdAt;

  RideRequestModel({
    required this.id,
    required this.userId,
    required this.pickupLat,
    required this.pickupLng,
    required this.dropoffLat,
    required this.dropoffLng,
    required this.estimatedPrice,
    required this.estimatedTime,
    required this.status,
    required this.createdAt,
  });

  factory RideRequestModel.fromJson(Map<String, dynamic> json) {
    return RideRequestModel(
      id: json['id']?.toString() ?? '',
      userId: json['user_id']?.toString() ?? '',
      pickupLat: _parseDouble(json['pickup_lat']),
      pickupLng: _parseDouble(json['pickup_lng']),
      dropoffLat: _parseDouble(json['dropoff_lat']),
      dropoffLng: _parseDouble(json['dropoff_lng']),
      estimatedPrice: _parseDouble(json['estimated_price']),
      estimatedTime: _parseInt(json['estimated_time']),
      status: json['status']?.toString() ?? 'pending',
      createdAt: json['created_at'] != null 
          ? DateTime.parse(json['created_at'].toString())
          : DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'user_id': userId,
      'pickup_lat': pickupLat,
      'pickup_lng': pickupLng,
      'dropoff_lat': dropoffLat,
      'dropoff_lng': dropoffLng,
      'estimated_price': estimatedPrice,
      'estimated_time': estimatedTime,
      'status': status,
      'created_at': createdAt.toIso8601String(),
    };
  }

  RideRequestModel copyWith({
    String? id,
    String? userId,
    double? pickupLat,
    double? pickupLng,
    double? dropoffLat,
    double? dropoffLng,
    double? estimatedPrice,
    int? estimatedTime,
    String? status,
    DateTime? createdAt,
  }) {
    return RideRequestModel(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      pickupLat: pickupLat ?? this.pickupLat,
      pickupLng: pickupLng ?? this.pickupLng,
      dropoffLat: dropoffLat ?? this.dropoffLat,
      dropoffLng: dropoffLng ?? this.dropoffLng,
      estimatedPrice: estimatedPrice ?? this.estimatedPrice,
      estimatedTime: estimatedTime ?? this.estimatedTime,
      status: status ?? this.status,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  // Status constants
  static const String statusPending = 'pending';
  static const String statusAccepted = 'accepted';
  static const String statusInProgress = 'in_progress';
  static const String statusCompleted = 'completed';
  static const String statusCancelled = 'cancelled';

  // Status helpers
  bool get isPending => status == statusPending;
  bool get isAccepted => status == statusAccepted;
  bool get isInProgress => status == statusInProgress;
  bool get isCompleted => status == statusCompleted;
  bool get isCancelled => status == statusCancelled;
  bool get isActive => isPending || isAccepted || isInProgress;

  // Formatted getters
  String get formattedPrice => '€${estimatedPrice.toStringAsFixed(2)}';
  String get formattedTime => '${estimatedTime} mins';
  
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
  String toString() => 'RideRequestModel(id: $id, status: $status, price: $formattedPrice)';

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is RideRequestModel && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;
}