enum PaymentStatus {
  pending,
  completed,
  failed
}

enum PaymentProvider {
  paypal,
  stripe,
  razorpay,
  other
}

class Payment {
  final String id;
  final String userId;
  final double amount;
  final PaymentProvider provider;
  final PaymentStatus status;
  final DateTime createdAt;

  Payment({
    required this.id,
    required this.userId,
    required this.amount,
    required this.provider,
    required this.status,
    required this.createdAt,
  });

  factory Payment.fromJson(Map<String, dynamic> json) {
    return Payment(
      id: json['id'],
      userId: json['user_id'],
      amount: json['amount'].toDouble(),
      provider: _providerFromString(json['provider']),
      status: _statusFromString(json['status']),
      createdAt: DateTime.parse(json['created_at']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'user_id': userId,
      'amount': amount,
      'provider': provider.toString().split('.').last,
      'status': status.toString().split('.').last,
      'created_at': createdAt.toIso8601String(),
    };
  }

  static PaymentProvider _providerFromString(String value) {
    return PaymentProvider.values.firstWhere(
      (e) => e.toString().split('.').last == value,
      orElse: () => PaymentProvider.other,
    );
  }

  static PaymentStatus _statusFromString(String value) {
    return PaymentStatus.values.firstWhere(
      (e) => e.toString().split('.').last == value,
      orElse: () => PaymentStatus.pending,
    );
  }
} 