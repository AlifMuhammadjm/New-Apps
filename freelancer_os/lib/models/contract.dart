class Contract {
  final String? id;
  final String userId;
  final String clientName;
  final String projectName;
  final double projectValue;
  final DateTime startDate;
  final DateTime endDate;
  final String status;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  Contract({
    this.id,
    required this.userId,
    required this.clientName,
    required this.projectName,
    required this.projectValue,
    required this.startDate,
    required this.endDate,
    this.status = 'draft',
    this.createdAt,
    this.updatedAt,
  });

  factory Contract.fromJson(Map<String, dynamic> json) {
    return Contract(
      id: json['id'],
      userId: json['user_id'],
      clientName: json['client_name'],
      projectName: json['project_name'],
      projectValue: (json['project_value'] is int)
          ? (json['project_value'] as int).toDouble()
          : json['project_value'],
      startDate: DateTime.parse(json['start_date']),
      endDate: DateTime.parse(json['end_date']),
      status: json['status'] ?? 'draft',
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
      'client_name': clientName,
      'project_name': projectName,
      'project_value': projectValue,
      'start_date': startDate.toIso8601String().split('T').first,
      'end_date': endDate.toIso8601String().split('T').first,
      'status': status,
      if (createdAt != null) 'created_at': createdAt!.toIso8601String(),
      'updated_at': DateTime.now().toIso8601String(),
    };
  }

  Contract copyWith({
    String? id,
    String? userId,
    String? clientName,
    String? projectName,
    double? projectValue,
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
      projectName: projectName ?? this.projectName,
      projectValue: projectValue ?? this.projectValue,
      startDate: startDate ?? this.startDate,
      endDate: endDate ?? this.endDate,
      status: status ?? this.status,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
} 