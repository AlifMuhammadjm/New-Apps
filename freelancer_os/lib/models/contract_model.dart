class Contract {
  final String? id;
  final String userId;
  final String clientName;
  final double projectValue;
  final String? description;
  final DateTime? startDate;
  final DateTime? endDate;
  final String status;
  final DateTime createdAt;
  final DateTime? updatedAt;

  Contract({
    this.id,
    required this.userId,
    required this.clientName,
    required this.projectValue,
    this.description,
    this.startDate,
    this.endDate,
    this.status = 'aktif',
    required this.createdAt,
    this.updatedAt,
  });

  // Membuat objek Contract dari Map
  factory Contract.fromMap(Map<String, dynamic> map) {
    return Contract(
      id: map['id'],
      userId: map['user_id'],
      clientName: map['client_name'],
      projectValue: map['project_value'],
      description: map['description'],
      startDate: map['start_date'] != null ? DateTime.parse(map['start_date']) : null,
      endDate: map['end_date'] != null ? DateTime.parse(map['end_date']) : null,
      status: map['status'] ?? 'aktif',
      createdAt: DateTime.parse(map['created_at']),
      updatedAt: map['updated_at'] != null ? DateTime.parse(map['updated_at']) : null,
    );
  }

  // Konversi Contract menjadi Map
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'user_id': userId,
      'client_name': clientName,
      'project_value': projectValue,
      'description': description,
      'start_date': startDate?.toIso8601String(),
      'end_date': endDate?.toIso8601String(),
      'status': status,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt?.toIso8601String(),
    };
  }

  // Membuat salinan Contract dengan beberapa nilai yang diubah
  Contract copyWith({
    String? id,
    String? userId,
    String? clientName,
    double? projectValue,
    String? description,
    DateTime? startDate,
    DateTime? endDate,
    String? status,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return Contract(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      clientName: clientName ?? this.clientName,
      projectValue: projectValue ?? this.projectValue,
      description: description ?? this.description,
      startDate: startDate ?? this.startDate,
      endDate: endDate ?? this.endDate,
      status: status ?? this.status,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
} 