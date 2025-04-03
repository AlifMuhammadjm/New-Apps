class Contract {
  final String id;
  final String userId;
  final String clientName;
  final double projectValue;
  final DateTime createdAt;

  Contract({
    required this.id,
    required this.userId,
    required this.clientName,
    required this.projectValue,
    required this.createdAt,
  });

  factory Contract.fromJson(Map<String, dynamic> json) {
    return Contract(
      id: json['id'],
      userId: json['user_id'],
      clientName: json['client_name'],
      projectValue: json['project_value'].toDouble(),
      createdAt: DateTime.parse(json['created_at']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'user_id': userId,
      'client_name': clientName,
      'project_value': projectValue,
      'created_at': createdAt.toIso8601String(),
    };
  }
} 