class Invoice {
  final String? id;
  final String userId;
  final String contractId;
  final String? clientName;
  final double amount;
  final String status; // pending, paid, cancelled
  final DateTime dueDate;
  final DateTime createdAt;
  final DateTime? updatedAt;

  Invoice({
    this.id,
    required this.userId,
    required this.contractId,
    this.clientName,
    required this.amount,
    this.status = 'pending',
    required this.dueDate,
    required this.createdAt,
    this.updatedAt,
  });

  // Membuat objek Invoice dari Map
  factory Invoice.fromMap(Map<String, dynamic> map) {
    return Invoice(
      id: map['id'],
      userId: map['user_id'],
      contractId: map['contract_id'],
      clientName: map['client_name'],
      amount: map['amount'].toDouble(),
      status: map['status'] ?? 'pending',
      dueDate: DateTime.parse(map['due_date']),
      createdAt: DateTime.parse(map['created_at']),
      updatedAt: map['updated_at'] != null ? DateTime.parse(map['updated_at']) : null,
    );
  }

  // Konversi Invoice menjadi Map
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'user_id': userId,
      'contract_id': contractId,
      'client_name': clientName,
      'amount': amount,
      'status': status,
      'due_date': dueDate.toIso8601String(),
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt?.toIso8601String(),
    };
  }

  // Membuat salinan Invoice dengan beberapa nilai yang diubah
  Invoice copyWith({
    String? id,
    String? userId,
    String? contractId,
    String? clientName,
    double? amount,
    String? status,
    DateTime? dueDate,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return Invoice(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      contractId: contractId ?? this.contractId,
      clientName: clientName ?? this.clientName,
      amount: amount ?? this.amount,
      status: status ?? this.status,
      dueDate: dueDate ?? this.dueDate,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  // Memeriksa status invoice
  bool get isPending => status == 'pending';
  bool get isPaid => status == 'paid';
  bool get isCancelled => status == 'cancelled';
  bool get isOverdue => dueDate.isBefore(DateTime.now()) && status == 'pending';
} 
 