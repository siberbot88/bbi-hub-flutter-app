// core/models/vehicle.dart

class Vehicle {
  final String id;
<<<<<<< HEAD
  final String? plateNumber;
  final String? brand;
  final String? model;
  final String? name;
  final int? year;
  final String? color;
=======
  final String? customerUuid;
  final String? code;
  final String? name;
  final String? type;
  final String? category;
  final String? brand;
  final String? model;
  final String? year;
  final String? color;
  final String? plateNumber;
>>>>>>> f69db6e40e06854413d398fd766130ce19c9aa76
  final int? odometer;

  Vehicle({
    required this.id,
<<<<<<< HEAD
    this.plateNumber,
    this.brand,
    this.model,
    this.name,
    this.year,
    this.color,
=======
    this.customerUuid,
    this.code,
    this.name,
    this.type,
    this.category,
    this.brand,
    this.model,
    this.year,
    this.color,
    this.plateNumber,
>>>>>>> f69db6e40e06854413d398fd766130ce19c9aa76
    this.odometer,
  });

  factory Vehicle.fromJson(Map<String, dynamic> json) {
<<<<<<< HEAD
    int? _int(dynamic v) {
      if (v == null) return null;
      if (v is int) return v;
      if (v is double) return v.toInt();
      return int.tryParse(v.toString());
=======
    int? toInt(dynamic v) {
      if (v is int) return v;
      if (v is double) return v.toInt();
      if (v is String && v.isNotEmpty) return int.tryParse(v);
      return null;
>>>>>>> f69db6e40e06854413d398fd766130ce19c9aa76
    }

    return Vehicle(
      id: (json['id'] ?? '').toString(),
<<<<<<< HEAD
      plateNumber: json['plate_number']?.toString(),
      brand: json['brand']?.toString(),
      model: json['model']?.toString(),
      name: json['name']?.toString(),
      year: _int(json['year']),
      color: json['color']?.toString(),
      odometer: _int(json['odometer']),
=======
      customerUuid: json['customer_uuid']?.toString(),
      code: json['code']?.toString(),
      name: json['name']?.toString(),
      type: json['type']?.toString(),           // <= penting
      category: json['category']?.toString(),   // <= penting
      brand: json['brand']?.toString(),
      model: json['model']?.toString(),
      year: json['year']?.toString(),           // varchar -> String
      color: json['color']?.toString(),
      plateNumber: json['plate_number']?.toString(),
      odometer: toInt(json['odometer']),
>>>>>>> f69db6e40e06854413d398fd766130ce19c9aa76
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
<<<<<<< HEAD
    if (plateNumber != null) 'plate_number': plateNumber,
    if (brand != null) 'brand': brand,
    if (model != null) 'model': model,
    if (name != null) 'name': name,
    if (year != null) 'year': year,
    if (color != null) 'color': color,
=======
    if (customerUuid != null) 'customer_uuid': customerUuid,
    if (code != null) 'code': code,
    if (name != null) 'name': name,
    if (type != null) 'type': type,
    if (category != null) 'category': category,
    if (brand != null) 'brand': brand,
    if (model != null) 'model': model,
    if (year != null) 'year': year,
    if (color != null) 'color': color,
    if (plateNumber != null) 'plate_number': plateNumber,
>>>>>>> f69db6e40e06854413d398fd766130ce19c9aa76
    if (odometer != null) 'odometer': odometer,
  };
}
