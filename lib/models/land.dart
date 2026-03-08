class Land {
  final int? id;
  final int? ownerId;
  final String name;
  final String location;
  final double size;
  final String zoning;
  final String stage;
  final String? legalDocuments;
  final List<String>? utilities;
  final String reviewStatus;
  final String? adminNotes;

  Land({
    this.id,
    this.ownerId,
    required this.name,
    required this.location,
    required this.size,
    required this.zoning,
    required this.stage,
    this.legalDocuments,
    this.utilities,
    this.reviewStatus = 'PENDING',
    this.adminNotes,
  });

  factory Land.fromJson(Map<String, dynamic> json) {
    return Land(
      id: json['id'],
      ownerId: json['ownerId'] ?? json['owner_id'],
      name: json['name'] ?? '',
      location: json['location'] ?? '',
      size: (json['size'] as num?)?.toDouble() ?? 0.0,
      zoning: json['zoning'] ?? '',
      stage: json['stage'] ?? '',
      legalDocuments: json['legalDocuments'],
      utilities: json['utilities'] != null ? List<String>.from(json['utilities']) : null,
      reviewStatus: json['reviewStatus'] ?? 'PENDING',
      adminNotes: json['adminNotes'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      if (id != null) 'id': id,
      if (ownerId != null) 'ownerId': ownerId,
      'name': name,
      'location': location,
      'size': size,
      'zoning': zoning,
      'stage': stage,
      'legalDocuments': legalDocuments,
      'utilities': utilities,
      'reviewStatus': reviewStatus,
      'adminNotes': adminNotes,
    };
  }
}
