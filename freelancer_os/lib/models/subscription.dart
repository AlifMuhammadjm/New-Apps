class Subscription {
  final String? id;
  final String userId;
  final String planType;
  final String status;
  final DateTime startDate;
  final DateTime endDate;
  final String paymentProvider;
  final String? paymentId;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  Subscription({
    this.id,
    required this.userId,
    required this.planType,
    required this.status,
    required this.startDate,
    required this.endDate,
    required this.paymentProvider,
    this.paymentId,
    this.createdAt,
    this.updatedAt,
  });

  factory Subscription.fromJson(Map<String, dynamic> json) {
    return Subscription(
      id: json['id'],
      userId: json['user_id'],
      planType: json['plan_type'],
      status: json['status'],
      startDate: DateTime.parse(json['start_date']),
      endDate: DateTime.parse(json['end_date']),
      paymentProvider: json['payment_provider'],
      paymentId: json['payment_id'],
      createdAt: json['created_at'] != null
          ? DateTime.parse(json['created_at'])
          : null,
      updatedAt: json['updated_at'] != null
          ? DateTime.parse(json['updated_at'])
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      if (id != null) 'id': id,
      'user_id': userId,
      'plan_type': planType,
      'status': status,
      'start_date': startDate.toIso8601String(),
      'end_date': endDate.toIso8601String(),
      'payment_provider': paymentProvider,
      if (paymentId != null) 'payment_id': paymentId,
      if (createdAt != null) 'created_at': createdAt!.toIso8601String(),
      'updated_at': DateTime.now().toIso8601String(),
    };
  }

  Subscription copyWith({
    String? id,
    String? userId,
    String? planType,
    String? status,
    DateTime? startDate,
    DateTime? endDate,
    String? paymentProvider,
    String? paymentId,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return Subscription(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      planType: planType ?? this.planType,
      status: status ?? this.status,
      startDate: startDate ?? this.startDate,
      endDate: endDate ?? this.endDate,
      paymentProvider: paymentProvider ?? this.paymentProvider,
      paymentId: paymentId ?? this.paymentId,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  bool get isActive => status == 'active' && endDate.isAfter(DateTime.now());
} 