class WalletModel {
  final int id;
  final String userId;
  final double total;

  WalletModel({
    required this.id,
    required this.userId,
    required this.total,
  });

  // Factory constructor for creating from JSON
  factory WalletModel.fromJson(Map<String, dynamic> json) {
    return WalletModel(
      id: json['id'] as int,
      userId: json['user_id'] as String,
      total: (json['total'] as num).toDouble(),
    );
  }

  // Convert to JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'user_id': userId,
      'total': total,
    };
  }

  // Copy with method
  WalletModel copyWith({
    int? id,
    String? userId,
    double? total,
  }) {
    return WalletModel(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      total: total ?? this.total,
    );
  }

  @override
  String toString() {
    return 'WalletModel(id: $id, userId: $userId, total: $total EUR)';
  }
}

// Transaction Model for wallet transactions
class WalletTransactionModel {
  final String id;
  final String walletId;
  final String type; // 'credit', 'debit'
  final double amount;
  final String description;
  final String? referenceId; // ride_id or order_id
  final DateTime createdAt;

  WalletTransactionModel({
    required this.id,
    required this.walletId,
    required this.type,
    required this.amount,
    required this.description,
    this.referenceId,
    required this.createdAt,
  });

  factory WalletTransactionModel.fromJson(Map<String, dynamic> json) {
    return WalletTransactionModel(
      id: json['id'] as String,
      walletId: json['wallet_id'] as String,
      type: json['type'] as String,
      amount: (json['amount'] as num).toDouble(),
      description: json['description'] as String,
      referenceId: json['reference_id'] as String?,
      createdAt: DateTime.parse(json['created_at'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'wallet_id': walletId,
      'type': type,
      'amount': amount,
      'description': description,
      'reference_id': referenceId,
      'created_at': createdAt.toIso8601String(),
    };
  }

  bool get isCredit => type == 'credit';
  bool get isDebit => type == 'debit';
}
