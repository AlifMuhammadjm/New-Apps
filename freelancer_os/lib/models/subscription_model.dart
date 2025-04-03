class Subscription {
  final int? id;
  final String userId;
  final String plan;
  final String status;
  final DateTime startDate;
  final DateTime? endDate;
  final DateTime createdAt;
  final DateTime? updatedAt;

  Subscription({
    this.id,
    required this.userId,
    required this.plan,
    required this.status,
    required this.startDate,
    this.endDate,
    required this.createdAt,
    this.updatedAt,
  });

  // Membuat objek Subscription dari Map
  factory Subscription.fromMap(Map<String, dynamic> map) {
    return Subscription(
      id: map['id'],
      userId: map['user_id'],
      plan: map['plan'],
      status: map['status'],
      startDate: DateTime.parse(map['start_date']),
      endDate: map['end_date'] != null ? DateTime.parse(map['end_date']) : null,
      createdAt: DateTime.parse(map['created_at']),
      updatedAt: map['updated_at'] != null ? DateTime.parse(map['updated_at']) : null,
    );
  }

  // Konversi Subscription menjadi Map
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'user_id': userId,
      'plan': plan,
      'status': status,
      'start_date': startDate.toIso8601String(),
      'end_date': endDate?.toIso8601String(),
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt?.toIso8601String(),
    };
  }

  // Membuat salinan Subscription dengan beberapa nilai yang diubah
  Subscription copyWith({
    int? id,
    String? userId,
    String? plan,
    String? status,
    DateTime? startDate,
    DateTime? endDate,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return Subscription(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      plan: plan ?? this.plan,
      status: status ?? this.status,
      startDate: startDate ?? this.startDate,
      endDate: endDate ?? this.endDate,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  // Memeriksa apakah langganan masih aktif
  bool get isActive => status == 'active' && (endDate == null || endDate!.isAfter(DateTime.now()));

  // Memeriksa level langganan
  bool get isPro => plan == 'pro';
  bool get isPremium => plan == 'premium';
  bool get isFree => plan == 'free';
}