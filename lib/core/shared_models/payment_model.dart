class PaymentModel {
  final String id;
  final String rideId;
  final double amount;
  final String paymentMethod;
  final String status;
  final DateTime createdAt;

  PaymentModel({
    required this.id,
    required this.rideId,
    required this.amount,
    required this.paymentMethod,
    required this.status,
    required this.createdAt,
  });

  factory PaymentModel.fromJson(Map<String, dynamic> json) {
    return PaymentModel(
      id: json['id']?.toString() ?? '',
      rideId: json['ride_id']?.toString() ?? '',
      amount: _parseDouble(json['amount']),
      paymentMethod: json['payment_method']?.toString() ?? 'cash',
      status: json['status']?.toString() ?? 'pending',
      createdAt: json['created_at'] != null 
          ? DateTime.parse(json['created_at'].toString())
          : DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'ride_id': rideId,
      'amount': amount,
      'payment_method': paymentMethod,
      'status': status,
      'created_at': createdAt.toIso8601String(),
    };
  }

  PaymentModel copyWith({
    String? id,
    String? rideId,
    double? amount,
    String? paymentMethod,
    String? status,
    DateTime? createdAt,
  }) {
    return PaymentModel(
      id: id ?? this.id,
      rideId: rideId ?? this.rideId,
      amount: amount ?? this.amount,
      paymentMethod: paymentMethod ?? this.paymentMethod,
      status: status ?? this.status,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  // Payment method constants
  static const String methodCash = 'cash';
  static const String methodCard = 'card';
  static const String methodDigitalWallet = 'digital_wallet';
  static const String methodBankTransfer = 'bank_transfer';

  // Status constants
  static const String statusPending = 'pending';
  static const String statusProcessing = 'processing';
  static const String statusCompleted = 'completed';
  static const String statusFailed = 'failed';
  static const String statusRefunded = 'refunded';

  // Status helpers
  bool get isPending => status == statusPending;
  bool get isProcessing => status == statusProcessing;
  bool get isCompleted => status == statusCompleted;
  bool get isFailed => status == statusFailed;
  bool get isRefunded => status == statusRefunded;
  bool get isSuccessful => isCompleted;
  bool get isInProgress => isPending || isProcessing;

  // Payment method helpers
  bool get isCash => paymentMethod == methodCash;
  bool get isCard => paymentMethod == methodCard;
  bool get isDigitalWallet => paymentMethod == methodDigitalWallet;
  bool get isBankTransfer => paymentMethod == methodBankTransfer;
  bool get isElectronic => !isCash;

  // Formatted getters
  String get formattedAmount => '€${amount.toStringAsFixed(2)}';
  
  String get paymentMethodDisplay {
    switch (paymentMethod) {
      case methodCash:
        return 'Cash';
      case methodCard:
        return 'Credit/Debit Card';
      case methodDigitalWallet:
        return 'Digital Wallet';
      case methodBankTransfer:
        return 'Bank Transfer';
      default:
        return paymentMethod.replaceAll('_', ' ').toUpperCase();
    }
  }

  String get statusDisplay {
    switch (status) {
      case statusPending:
        return 'Pending';
      case statusProcessing:
        return 'Processing';
      case statusCompleted:
        return 'Completed';
      case statusFailed:
        return 'Failed';
      case statusRefunded:
        return 'Refunded';
      default:
        return status.replaceAll('_', ' ').toUpperCase();
    }
  }

  String get formattedDate {
    return '${createdAt.day}/${createdAt.month}/${createdAt.year} ${createdAt.hour}:${createdAt.minute.toString().padLeft(2, '0')}';
  }

  static double _parseDouble(dynamic value) {
    if (value == null) return 0.0;
    if (value is double) return value;
    if (value is int) return value.toDouble();
    return double.tryParse(value.toString()) ?? 0.0;
  }

  @override
  String toString() => 'PaymentModel(id: $id, amount: $formattedAmount, method: $paymentMethod, status: $status)';

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is PaymentModel && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;
}