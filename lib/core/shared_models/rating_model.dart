class RatingModel {
  final String id;
  final String rideId;
  final String raterId;
  final String rateeId;
  final int ratingValue;
  final String? comment;
  final DateTime createdAt;

  RatingModel({
    required this.id,
    required this.rideId,
    required this.raterId,
    required this.rateeId,
    required this.ratingValue,
    this.comment,
    required this.createdAt,
  });

  factory RatingModel.fromJson(Map<String, dynamic> json) {
    return RatingModel(
      id: json['id']?.toString() ?? '',
      rideId: json['ride_id']?.toString() ?? '',
      raterId: json['rater_id']?.toString() ?? '',
      rateeId: json['ratee_id']?.toString() ?? '',
      ratingValue: _parseInt(json['rating_value']),
      comment: json['comment']?.toString(),
      createdAt: json['created_at'] != null 
          ? DateTime.parse(json['created_at'].toString())
          : DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'ride_id': rideId,
      'rater_id': raterId,
      'ratee_id': rateeId,
      'rating_value': ratingValue,
      'comment': comment,
      'created_at': createdAt.toIso8601String(),
    };
  }

  RatingModel copyWith({
    String? id,
    String? rideId,
    String? raterId,
    String? rateeId,
    int? ratingValue,
    String? comment,
    DateTime? createdAt,
  }) {
    return RatingModel(
      id: id ?? this.id,
      rideId: rideId ?? this.rideId,
      raterId: raterId ?? this.raterId,
      rateeId: rateeId ?? this.rateeId,
      ratingValue: ratingValue ?? this.ratingValue,
      comment: comment ?? this.comment,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  // Rating validation
  bool get isValidRating => ratingValue >= 1 && ratingValue <= 5;

  // Rating quality helpers
  bool get isExcellent => ratingValue == 5;
  bool get isGood => ratingValue == 4;
  bool get isAverage => ratingValue == 3;
  bool get isPoor => ratingValue == 2;
  bool get isTerrible => ratingValue == 1;
  bool get isPositive => ratingValue >= 4;
  bool get isNegative => ratingValue <= 2;

  // Display helpers
  String get ratingDisplay => '$ratingValue/5';
  String get starDisplay => '★' * ratingValue + '☆' * (5 - ratingValue);

  String get qualityDescription {
    switch (ratingValue) {
      case 5:
        return 'Excellent';
      case 4:
        return 'Good';
      case 3:
        return 'Average';
      case 2:
        return 'Poor';
      case 1:
        return 'Terrible';
      default:
        return 'Invalid';
    }
  }

  String get formattedDate {
    return '${createdAt.day}/${createdAt.month}/${createdAt.year}';
  }

  String get formattedDateTime {
    return '${createdAt.day}/${createdAt.month}/${createdAt.year} ${createdAt.hour}:${createdAt.minute.toString().padLeft(2, '0')}';
  }

  bool get hasComment => comment != null && comment!.trim().isNotEmpty;

  String get displayComment => hasComment ? comment! : 'No comment provided';

  // Helper method to create a list of star widgets (for UI)
  List<bool> get starList => List.generate(5, (index) => index < ratingValue);

  static int _parseInt(dynamic value) {
    if (value == null) return 0;
    if (value is int) return value;
    if (value is double) return value.round();
    return int.tryParse(value.toString()) ?? 0;
  }

  // Static helper methods
  static double calculateAverageRating(List<RatingModel> ratings) {
    if (ratings.isEmpty) return 0.0;
    
    final totalRating = ratings.fold<int>(0, (sum, rating) => sum + rating.ratingValue);
    return totalRating / ratings.length;
  }

  static String formatAverageRating(List<RatingModel> ratings) {
    final average = calculateAverageRating(ratings);
    return '${average.toStringAsFixed(1)}/5';
  }

  static Map<int, int> getRatingDistribution(List<RatingModel> ratings) {
    final Map<int, int> distribution = {1: 0, 2: 0, 3: 0, 4: 0, 5: 0};
    
    for (final rating in ratings) {
      if (rating.isValidRating) {
        distribution[rating.ratingValue] = (distribution[rating.ratingValue] ?? 0) + 1;
      }
    }
    
    return distribution;
  }

  @override
  String toString() => 'RatingModel(id: $id, rating: $ratingDisplay, quality: $qualityDescription)';

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is RatingModel && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;
}