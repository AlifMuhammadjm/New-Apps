class Invoice {
  final String id;
  final String contractId;
  final String clientName;
  final String invoiceNumber;
  final double amount;
  final DateTime issueDate;
  final DateTime dueDate;
  final DateTime? paymentDate;
  final String status; // pending, paid, overdue, cancelled
  final String? paymentMethod;
  final String? notes;
  final String? documentUrl;

  Invoice({
    required this.id,
    required this.contractId,
    required this.clientName,
    required this.invoiceNumber,
    required this.amount,
    required this.issueDate,
    required this.dueDate,
    this.paymentDate,
    required this.status,
    this.paymentMethod,
    this.notes,
    this.documentUrl,
  });

  // Untuk membuat salinan invoice dengan beberapa perubahan
  Invoice copyWith({
    String? id,
    String? contractId,
    String? clientName,
    String? invoiceNumber,
    double? amount,
    DateTime? issueDate,
    DateTime? dueDate,
    DateTime? paymentDate,
    String? status,
    String? paymentMethod,
    String? notes,
    String? documentUrl,
  }) {
    return Invoice(
      id: id ?? this.id,
      contractId: contractId ?? this.contractId,
      clientName: clientName ?? this.clientName,
      invoiceNumber: invoiceNumber ?? this.invoiceNumber,
      amount: amount ?? this.amount,
      issueDate: issueDate ?? this.issueDate,
      dueDate: dueDate ?? this.dueDate,
      paymentDate: paymentDate ?? this.paymentDate,
      status: status ?? this.status,
      paymentMethod: paymentMethod ?? this.paymentMethod,
      notes: notes ?? this.notes,
      documentUrl: documentUrl ?? this.documentUrl,
    );
  }

  // Mengonversi invoice ke Map untuk penyimpanan di database
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'contract_id': contractId,
      'client_name': clientName,
      'invoice_number': invoiceNumber,
      'amount': amount,
      'issue_date': issueDate.toIso8601String(),
      'due_date': dueDate.toIso8601String(),
      'payment_date': paymentDate?.toIso8601String(),
      'status': status,
      'payment_method': paymentMethod,
      'notes': notes,
      'document_url': documentUrl,
    };
  }

  // Membuat invoice dari Map yang diambil dari database
  factory Invoice.fromMap(Map<String, dynamic> map) {
    return Invoice(
      id: map['id'],
      contractId: map['contract_id'],
      clientName: map['client_name'],
      invoiceNumber: map['invoice_number'],
      amount: (map['amount'] as num).toDouble(),
      issueDate: DateTime.parse(map['issue_date']),
      dueDate: DateTime.parse(map['due_date']),
      paymentDate: map['payment_date'] != null ? DateTime.parse(map['payment_date']) : null,
      status: map['status'],
      paymentMethod: map['payment_method'],
      notes: map['notes'],
      documentUrl: map['document_url'],
    );
  }

  // Memeriksa apakah faktur sudah jatuh tempo
  bool get isOverdue {
    final now = DateTime.now();
    return status == 'pending' && dueDate.isBefore(now);
  }

  // Mendapatkan sisa hari hingga jatuh tempo
  int get daysUntilDue {
    final now = DateTime.now();
    return dueDate.difference(now).inDays;
  }

  // Mendapatkan jumlah hari terlambat
  int get daysOverdue {
    final now = DateTime.now();
    if (!isOverdue) return 0;
    return now.difference(dueDate).inDays;
  }
} 