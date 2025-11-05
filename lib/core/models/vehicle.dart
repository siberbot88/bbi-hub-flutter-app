class Vehicle {
  final String id;
  final String name;
  final String brand;
  final String model;
  final String? plateNumber;

  Vehicle({
    required this.id,
    required this.name,
    required this.brand,
    required this.model,
    this.plateNumber,
  });

  String get plateDisplay => plateNumber ?? '-';

  factory Vehicle.fromJson(Map<String, dynamic> json) {
    return Vehicle(
      id: (json['id'] ?? '').toString(),
      name: (json['name'] ?? '').toString(),
      brand: (json['brand'] ?? '').toString(),
      model: (json['model'] ?? '').toString(),
      plateNumber: json['plate_number']?.toString(),
    );
  }
}
