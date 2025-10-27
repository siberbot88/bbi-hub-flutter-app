class Workshop {
  final String id;
  final String userUuid;
  final String code;
  final String name;
  final String description;
  final String address;
  final String phone;
  final String email;
  final String? photo;
  final String city;
  final String province;
  final String country;
  final String postalCode;
  final double latitude;
  final double longitude;
  final String? mapsUrl;
  final String openingTime;
  final String closingTime;
  final String operationalDays;
  final bool isActive;
  final DateTime createdAt;
  final DateTime updatedAt;

  Workshop({
    required this.id,
    required this.userUuid,
    required this.code,
    required this.name,
    required this.description,
    required this.address,
    required this.phone,
    required this.email,
    this.photo,
    required this.city,
    required this.province,
    required this.country,
    required this.postalCode,
    required this.latitude,
    required this.longitude,
    this.mapsUrl,
    required this.openingTime,
    required this.closingTime,
    required this.operationalDays,
    required this.isActive,
    required this.createdAt,
    required this.updatedAt,
  });

  factory Workshop.fromJson(Map<String, dynamic> json) {
    return Workshop(
      id: json['id'],
      userUuid: json['user_uuid'],
      code: json['code'],
      name: json['name'],
      description: json['description'],
      address: json['address'],
      phone: json['phone'],
      email: json['email'],
      photo: json['photo'],
      city: json['city'],
      province: json['province'],
      country: json['country'],
      postalCode: json['postal_code'],
      latitude: double.tryParse(json['latitude'].toString()) ?? 0.0,
      longitude: double.tryParse(json['longitude'].toString()) ?? 0.0,
      mapsUrl: json['maps_url'],
      openingTime: json['opening_time'],
      closingTime: json['closing_time'],
      operationalDays: json['operational_days'],
      isActive: json['is_active'] == 1 || json['is_active'] == true,
      createdAt: DateTime.parse(json['created_at']),
      updatedAt: DateTime.parse(json['updated_at']),
    );
  }
}
