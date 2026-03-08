class ProjectMilestone {
  final int? id;
  final int projectId;
  final String milestone;
  final String? description;
  final String? date; // yyyy-MM-dd
  final String status; // PENDING, COMPLETED, CANCELLED

  ProjectMilestone({this.id, required this.projectId, required this.milestone, this.description, this.date, required this.status});

  factory ProjectMilestone.fromJson(Map<String, dynamic> json) => ProjectMilestone(
        id: json['id'] as int?,
        projectId: json['projectId'] ?? json['project_id'],
        milestone: json['milestone'] as String,
        description: json['description'] as String?,
        date: json['date'] as String?,
        status: json['status']?.toString() ?? 'PENDING',
      );

  Map<String, dynamic> toJson() => {
        if (id != null) 'id': id,
        'projectId': projectId,
        'milestone': milestone,
        if (description != null) 'description': description,
        if (date != null) 'date': date,
        'status': status,
      };
}
