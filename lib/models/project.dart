class Project {
  final int? id;
  final int? landId;
  final String projectName;
  final String location;
  final double landSize;
  final double investmentRequired;
  final double expectedROI;
  final double expectedIRR;
  final String stage;

  Project({
    this.id,
    this.landId,
    required this.projectName,
    required this.location,
    this.landSize = 0.0,
    this.investmentRequired = 0.0,
    this.expectedROI = 0.0,
    this.expectedIRR = 0.0,
    this.stage = 'LAND_APPROVED',
  });

  // backward-compatible getter used across the UI
  String get title => projectName;

  factory Project.fromJson(Map<String, dynamic> json) {
    // Accept both old and new field names
    final projectName = (json['projectName'] ?? json['title'] ?? '') as String;
    final location = (json['location'] ?? '') as String;

    double parseDouble(dynamic v) {
      if (v == null) return 0.0;
      if (v is num) return v.toDouble();
      return double.tryParse(v.toString()) ?? 0.0;
    }

    return Project(
      id: json['id'],
      landId: json['landId'] ?? json['land_id'],
      projectName: projectName,
      location: location,
      landSize: parseDouble(json['landSize'] ?? json['land_size']),
      investmentRequired: parseDouble(json['investmentRequired'] ?? json['capitalRequired'] ?? json['capital_required']),
      expectedROI: parseDouble(json['expectedROI'] ?? json['projectedGrowth'] ?? json['expected_roi']),
      expectedIRR: parseDouble(json['expectedIRR'] ?? json['irr'] ?? json['expected_irr']),
      stage: (json['stage'] ?? 'LAND_APPROVED') as String,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      if (id != null) 'id': id,
      if (landId != null) 'landId': landId,
      'projectName': projectName,
      'location': location,
      'landSize': landSize,
      'investmentRequired': investmentRequired,
      'expectedROI': expectedROI,
      'expectedIRR': expectedIRR,
      'stage': stage,
    };
  }

  // Backwards-compatible getters for existing UI
  String get theme => 'General';
  String get description => '';
  String? get imageUrl => null;
  double get projectedGrowth => expectedROI;
  int get demandIndex => 5;
  String get riskProfile => 'Medium';
  double get irr => expectedIRR;
  double get capitalRequired => investmentRequired;
  double get capitalRaised => 0.0;
}
