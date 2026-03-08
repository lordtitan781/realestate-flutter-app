class Eoi {
  final int? id;
  final int investorId;
  final int projectId;
  final String status;
  final DateTime? submissionDate;

  Eoi({
    this.id,
    required this.investorId,
    required this.projectId,
    this.status = 'SUBMITTED',
    this.submissionDate,
  });

  factory Eoi.fromJson(Map<String, dynamic> json) {
    return Eoi(
      id: json['id'],
      investorId: json['investorId'],
      projectId: json['projectId'],
      status: json['status'] ?? 'SUBMITTED',
      submissionDate: json['submissionDate'] != null 
          ? DateTime.parse(json['submissionDate']) 
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      if (id != null) 'id': id,
      'investorId': investorId,
      'projectId': projectId,
      'status': status,
    };
  }
}
