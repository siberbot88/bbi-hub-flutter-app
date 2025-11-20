class Vehicle {
  final String id;
  final String? plateNumber;
  final String? brand;
  final String? model;
  final String? name;
  final int? year;
  final String? color;
  final int? odometer;

  Vehicle({
    required this.id,
    this.plateNumber,
    this.brand,
    this.model,
    this.name,
    this.year,
    this.color,
    this.odometer,
  });

  factory Vehicle.fromJson(Map<String, dynamic> json) {
    int? _int(dynamic v) {
      if (v == null) return null;
      if (v is int) return v;
      if (v is double) return v.toInt();
      return int.tryParse(v.toString());
    }

    return Vehicle(
      id: (json['id'] ?? '').toString(),
      plateNumber: json['plate_number']?.toString(),
      brand: json['brand']?.toString(),
      model: json['model']?.toString(),
      name: json['name']?.toString(),
      year: _int(json['year']),
      color: json['color']?.toString(),
      odometer: _int(json['odometer']),
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    if (plateNumber != null) 'plate_number': plateNumber,
    if (brand != null) 'brand': brand,
    if (model != null) 'model': model,
    if (name != null) 'name': name,
    if (year != null) 'year': year,
    if (color != null) 'color': color,
    if (odometer != null) 'odometer': odometer,
  };
}
