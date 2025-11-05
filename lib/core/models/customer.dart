class Customer {
  final String id;
  final String name;
  final String? email;
  final String? phone;

  Customer({
    required this.id,
    required this.name,
    this.email,
    this.phone,
  });

  factory Customer.fromJson(Map<String, dynamic> json) {
    return Customer(
      id: (json['id'] ?? '').toString(),
      name: (json['name'] ?? '').toString(),
      email: json['email']?.toString(),
      phone: json['phone']?.toString(),
    );
  }
}
