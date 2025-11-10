class TransactionItem {
  final String id;
  final String? name;               // optional: kalau backend kirim 'name'
  final String? serviceTypeName;    // fallback dari relasi service_type
  final num? price;
  final int? quantity;
  final num? subtotal;

  TransactionItem({
    required this.id,
    this.name,
    this.serviceTypeName,
    this.price,
    this.quantity,
    this.subtotal,
  });

  factory TransactionItem.fromJson(Map<String, dynamic> j) {
    return TransactionItem(
      id: (j['id'] ?? '').toString(),
      name: j['name']?.toString(),
      serviceTypeName: j['service_type'] is Map
          ? j['service_type']['name']?.toString()
          : j['service_type_name']?.toString(),
      price: j['price'] is num ? j['price'] : num.tryParse('${j['price']}'),
      quantity: j['quantity'] is int ? j['quantity'] : int.tryParse('${j['quantity']}'),
      subtotal: j['subtotal'] is num ? j['subtotal'] : num.tryParse('${j['subtotal']}'),
    );
  }
}
