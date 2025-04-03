enum ProjectStatus {
  draft,
  inProgress,
  onHold,
  completed,
  cancelled
}

class Project {
  final String id;
  final String title;
  final String description;
  final String clientId;
  final DateTime startDate;
  final DateTime? endDate;
  final double hourlyRate;
  final ProjectStatus status;
  final DateTime createdAt;
  final DateTime? updatedAt;

  Project({
    required this.id,
    required this.title,
    required this.description,
    required this.clientId,
    required this.startDate,
    this.endDate,
    required this.hourlyRate,
    required this.status,
    required this.createdAt,
    this.updatedAt,
  });

  factory Project.fromJson(Map<String, dynamic> json) {
    return Project(
      id: json['id'],
      title: json['title'],
      description: json['description'],
      clientId: json['client_id'],
      startDate: DateTime.parse(json['start_date']),
      endDate: json['end_date'] != null ? DateTime.parse(json['end_date']) : null,
      hourlyRate: json['hourly_rate'].toDouble(),
      status: ProjectStatus.values.firstWhere(
          (e) => e.toString().split('.').last == json['status'],
          orElse: () => ProjectStatus.draft),
      createdAt: DateTime.parse(json['created_at']),
      updatedAt: json['updated_at'] != null
          ? DateTime.parse(json['updated_at'])
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'client_id': clientId,
      'start_date': startDate.toIso8601String(),
      'end_date': endDate?.toIso8601String(),
      'hourly_rate': hourlyRate,
      'status': status.toString().split('.').last,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt?.toIso8601String(),
    };
  }
} 