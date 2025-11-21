class OrderModel {
  final String id;
  final String userId;
  final String fromName;
  final String toName;
  final double latFrom;
  final double lngFrom;
  final double latTo;
  final double lngTo;
  final double estimatedPrice;
  final int estimatedTime;
  final String status;
  final DateTime createdAt;
  final DateTime? completedAt;

  OrderModel({
    required this.id,
    required this.userId,
    required this.fromName,
    required this.toName,
    required this.latFrom,
    required this.lngFrom,
    required this.latTo,
    required this.lngTo,
    required this.estimatedPrice,
    required this.estimatedTime,
    required this.status,
    required this.createdAt,
    this.completedAt,
  });

  factory OrderModel.fromJson(Map<String, dynamic> json) {
    return OrderModel(
      id: json['id']?.toString() ?? '',
      userId: json['user_id']?.toString() ?? '',
      fromName: json['from_name']?.toString() ?? '',
      toName: json['to_name']?.toString() ?? '',
      latFrom: _parseDouble(json['lat_from']),
      lngFrom: _parseDouble(json['lng_from']),
      latTo: _parseDouble(json['lat_to']),
      lngTo: _parseDouble(json['lng_to']),
      estimatedPrice: _parseDouble(json['estimated_price']),
      estimatedTime: _parseInt(json['estimated_time']),
      status: json['status']?.toString() ?? 'pending',
      createdAt: json['created_at'] != null 
          ? DateTime.parse(json['created_at'].toString())
          : DateTime.now(),
      completedAt: json['completed_at'] != null 
          ? DateTime.parse(json['completed_at'].toString())
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'user_id': userId,
      'from_name': fromName,
      'to_name': toName,
      'lat_from': latFrom,
      'lng_from': lngFrom,
      'lat_to': latTo,
      'lng_to': lngTo,
      'estimated_price': estimatedPrice,
      'estimated_time': estimatedTime,
      'status': status,
      'created_at': createdAt.toIso8601String(),
      'completed_at': completedAt?.toIso8601String(),
    };
  }

  OrderModel copyWith({
    String? id,
    String? userId,
    String? fromName,
    String? toName,
    double? latFrom,
    double? lngFrom,
    double? latTo,
    double? lngTo,
    double? estimatedPrice,
    int? estimatedTime,
    String? status,
    DateTime? createdAt,
    DateTime? completedAt,
  }) {
    return OrderModel(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      fromName: fromName ?? this.fromName,
      toName: toName ?? this.toName,
      latFrom: latFrom ?? this.latFrom,
      lngFrom: lngFrom ?? this.lngFrom,
      latTo: latTo ?? this.latTo,
      lngTo: lngTo ?? this.lngTo,
      estimatedPrice: estimatedPrice ?? this.estimatedPrice,
      estimatedTime: estimatedTime ?? this.estimatedTime,
      status: status ?? this.status,
      createdAt: createdAt ?? this.createdAt,
      completedAt: completedAt ?? this.completedAt,
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
  bool get isFinished => isCompleted || isCancelled;

  // Formatted getters
  String get formattedPrice => '€${estimatedPrice.toStringAsFixed(2)}';
  String get formattedTime => '${estimatedTime} mins';
  
  String get route => '$fromName → $toName';
  String get shortRoute {
    final from = fromName.length > 20 ? '${fromName.substring(0, 20)}...' : fromName;
    final to = toName.length > 20 ? '${toName.substring(0, 20)}...' : toName;
    return '$from → $to';
  }

  Duration? get orderDuration {
    if (completedAt == null) return null;
    return completedAt!.difference(createdAt);
  }

  String get formattedDuration {
    final duration = orderDuration;
    if (duration == null) return 'Ongoing';
    
    final hours = duration.inHours;
    final minutes = duration.inMinutes % 60;
    
    if (hours > 0) {
      return '${hours}h ${minutes}m';
    } else {
      return '${minutes}m';
    }
  }

  String get formattedCreatedAt {
    return '${createdAt.day}/${createdAt.month}/${createdAt.year} ${createdAt.hour}:${createdAt.minute.toString().padLeft(2, '0')}';
  }

  String get formattedCompletedAt {
    if (completedAt == null) return 'Not completed';
    return '${completedAt!.day}/${completedAt!.month}/${completedAt!.year} ${completedAt!.hour}:${completedAt!.minute.toString().padLeft(2, '0')}';
  }

  // Location helpers
  String get pickupCoordinates => '${latFrom.toStringAsFixed(6)}, ${lngFrom.toStringAsFixed(6)}';
  String get dropoffCoordinates => '${latTo.toStringAsFixed(6)}, ${lngTo.toStringAsFixed(6)}';

  bool get hasValidCoordinates => 
      latFrom != 0.0 && lngFrom != 0.0 && latTo != 0.0 && lngTo != 0.0;

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
  String toString() => 'OrderModel(id: $id, route: $shortRoute, status: $status, price: $formattedPrice)';

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is OrderModel && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;
}
