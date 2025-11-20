class TransactionItem {
  final String id;
  final String? name;
  final String? serviceTypeName;
  final num price;
  final int quantity;
  final num subtotal;

  TransactionItem({
    required this.id,
    this.name,
    this.serviceTypeName,
    required this.price,
    required this.quantity,
    required this.subtotal,
  });

  factory TransactionItem.fromJson(Map<String, dynamic> j) {
    num _num(dynamic v) {
      if (v is num) return v;
      if (v is String) return num.tryParse(v) ?? 0;
      return 0;
    }

    int _int(dynamic v) {
      if (v is int) return v;
      if (v is double) return v.toInt();
      if (v is String) return int.tryParse(v) ?? 0;
      return 0;
    }

    String? _serviceTypeName() {
      final st = j['service_type'];
      if (st is Map && st['name'] != null) {
        return st['name'].toString();
      }
      if (j['service_type_name'] != null) {
        return j['service_type_name'].toString();
      }
      return null;
    }

    return TransactionItem(
      id: (j['id'] ?? '').toString(),
      name: j['name']?.toString(),
      serviceTypeName: _serviceTypeName(),
      price: _num(j['price']),
      quantity: _int(j['quantity'] ?? j['qty']),
      subtotal: _num(j['subtotal'] ?? j['total']),
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    if (name != null) 'name': name,
    if (serviceTypeName != null) 'service_type_name': serviceTypeName,
    'price': price,
    'quantity': quantity,
    'subtotal': subtotal,
  };

  int get qty => quantity;
  num get total => subtotal;
}
