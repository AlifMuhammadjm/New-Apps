class Contract {
  final String id;
  final String clientName;
  final String projectName;
  final double value;
  final DateTime startDate;
  final DateTime endDate;
  final String status; // 'active', 'completed', 'canceled'
  final String description;
  final String? documentUrl;
  final String? userId;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  Contract({
    required this.id,
    required this.clientName,
    required this.projectName,
    required this.value,
    required this.startDate,
    required this.endDate,
    required this.status,
    required this.description,
    this.documentUrl,
    this.userId,
    this.createdAt,
    this.updatedAt,
  });

  // Untuk konversi contract ke Map (untuk penyimpanan)
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'client_name': clientName,
      'project_name': projectName,
      'value': value,
      'start_date': startDate.toIso8601String(),
      'end_date': endDate.toIso8601String(),
      'status': status,
      'description': description,
      'document_url': documentUrl,
      'user_id': userId,
      'created_at': createdAt?.toIso8601String(),
      'updated_at': updatedAt?.toIso8601String(),
    };
  }

  // Untuk membuat Contract dari Map (untuk pembacaan dari penyimpanan)
  factory Contract.fromMap(Map<String, dynamic> map) {
    return Contract(
      id: map['id'],
      clientName: map['client_name'],
      projectName: map['project_name'],
      value: (map['value'] as num).toDouble(),
      startDate: DateTime.parse(map['start_date']),
      endDate: DateTime.parse(map['end_date']),
      status: map['status'],
      description: map['description'],
      documentUrl: map['document_url'],
      userId: map['user_id'],
      createdAt: map['created_at'] != null ? DateTime.parse(map['created_at']) : null,
      updatedAt: map['updated_at'] != null ? DateTime.parse(map['updated_at']) : null,
    );
  }

  // Helper untuk menghasilkan copy dari contract dengan nilai yang diperbarui
  Contract copyWith({
    String? id,
    String? clientName,
    String? projectName,
    double? value,
    DateTime? startDate,
    DateTime? endDate,
    String? status,
    String? description,
    String? documentUrl,
    String? userId,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return Contract(
      id: id ?? this.id,
      clientName: clientName ?? this.clientName,
      projectName: projectName ?? this.projectName,
      value: value ?? this.value,
      startDate: startDate ?? this.startDate,
      endDate: endDate ?? this.endDate,
      status: status ?? this.status,
      description: description ?? this.description,
      documentUrl: documentUrl ?? this.documentUrl,
      userId: userId ?? this.userId,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  // Memeriksa apakah kontrak masih aktif
  bool get isActive => status == 'active';

  // Memeriksa apakah kontrak sudah selesai
  bool get isCompleted => status == 'completed';

  // Memeriksa apakah kontrak dibatalkan
  bool get isCanceled => status == 'canceled';

  // Mendapatkan durasi kontrak dalam hari
  int get durationInDays => endDate.difference(startDate).inDays;

  // Mendapatkan sisa hari kontrak
  int get remainingDays {
    final now = DateTime.now();
    if (now.isAfter(endDate)) return 0;
    return endDate.difference(now).inDays;
  }

  // Mendapatkan persentase waktu yang telah berlalu
  double get progressPercentage {
    final now = DateTime.now();
    if (now.isBefore(startDate)) return 0.0;
    if (now.isAfter(endDate)) return 100.0;
    
    final totalDuration = durationInDays;
    final daysElapsed = now.difference(startDate).inDays;
    
    return (daysElapsed / totalDuration) * 100;
  }
} 