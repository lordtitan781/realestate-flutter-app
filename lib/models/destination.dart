class Destination {
  final int? id;
  final String name;
  final int touristsPerYear;
  final double hotelOccupancy;
  final double growthRate;

  Destination({this.id, required this.name, required this.touristsPerYear, required this.hotelOccupancy, required this.growthRate});

  factory Destination.fromJson(Map<String, dynamic> json) {
    return Destination(
      id: json['id'],
      name: json['name'] ?? '',
      touristsPerYear: (json['touristsPerYear'] as num?)?.toInt() ?? 0,
      hotelOccupancy: (json['hotelOccupancy'] as num?)?.toDouble() ?? 0.0,
      growthRate: (json['growthRate'] as num?)?.toDouble() ?? 0.0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      if (id != null) 'id': id,
      'name': name,
      'touristsPerYear': touristsPerYear,
      'hotelOccupancy': hotelOccupancy,
      'growthRate': growthRate,
    };
  }
}
