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
<<<<<<< HEAD
    num _num(dynamic v) {
=======
    num parseNum(dynamic v) {
>>>>>>> f69db6e40e06854413d398fd766130ce19c9aa76
      if (v is num) return v;
      if (v is String) return num.tryParse(v) ?? 0;
      return 0;
    }

<<<<<<< HEAD
    int _int(dynamic v) {
=======
    int parseIntVal(dynamic v) {
>>>>>>> f69db6e40e06854413d398fd766130ce19c9aa76
      if (v is int) return v;
      if (v is double) return v.toInt();
      if (v is String) return int.tryParse(v) ?? 0;
      return 0;
    }

<<<<<<< HEAD
    String? _serviceTypeName() {
=======
    String? serviceTypeName() {
>>>>>>> f69db6e40e06854413d398fd766130ce19c9aa76
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
<<<<<<< HEAD
      serviceTypeName: _serviceTypeName(),
      price: _num(j['price']),
      quantity: _int(j['quantity'] ?? j['qty']),
      subtotal: _num(j['subtotal'] ?? j['total']),
=======
      serviceTypeName: serviceTypeName(),
      price: parseNum(j['price']),
      quantity: parseIntVal(j['quantity'] ?? j['qty']),
      subtotal: parseNum(j['subtotal'] ?? j['total']),
>>>>>>> f69db6e40e06854413d398fd766130ce19c9aa76
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
