class Invoice {
  final String? id;
  final String userId;
  final String? contractId;
  final String invoiceNumber;
  final double amount;
  final DateTime dueDate;
  final String status;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  Invoice({
    this.id,
    required this.userId,
    this.contractId,
    required this.invoiceNumber,
    required this.amount,
    required this.dueDate,
    this.status = 'unpaid',
    this.createdAt,
    this.updatedAt,
  });

  factory Invoice.fromJson(Map<String, dynamic> json) {
    return Invoice(
      id: json['id'],
      userId: json['user_id'],
      contractId: json['contract_id'],
      invoiceNumber: json['invoice_number'],
      amount: (json['amount'] is int)
          ? (json['amount'] as int).toDouble()
          : json['amount'],
      dueDate: DateTime.parse(json['due_date']),
      status: json['status'] ?? 'unpaid',
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
      if (contractId != null) 'contract_id': contractId,
      'invoice_number': invoiceNumber,
      'amount': amount,
      'due_date': dueDate.toIso8601String().split('T').first,
      'status': status,
      if (createdAt != null) 'created_at': createdAt!.toIso8601String(),
      'updated_at': DateTime.now().toIso8601String(),
    };
  }

  Invoice copyWith({
    String? id,
    String? userId,
    String? contractId,
    String? invoiceNumber,
    double? amount,
    DateTime? dueDate,
    String? status,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return Invoice(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      contractId: contractId ?? this.contractId,
      invoiceNumber: invoiceNumber ?? this.invoiceNumber,
      amount: amount ?? this.amount,
      dueDate: dueDate ?? this.dueDate,
      status: status ?? this.status,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
} 