/// Model for Invoice
class InvoiceModel {
  final String id;
  final String? code;
  final String? transactionUuid;
  final String? status; // 'unpaid', 'paid', 'cancelled'
  final num? totalAmount;
  final DateTime? dueDate;
  final DateTime? paidAt;
  final String? paymentMethod;
  final String? notes;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  InvoiceModel({
    required this.id,
    this.code,
    this.transactionUuid,
    this.status,
    this.totalAmount,
    this.dueDate,
    this.paidAt,
    this.paymentMethod,
    this.notes,
    this.createdAt,
    this.updatedAt,
  });

  factory InvoiceModel.fromJson(Map<String, dynamic> json) {
    DateTime? parseDT(dynamic v) {
      if (v == null) return null;
      if (v is DateTime) return v;
      if (v is String && v.isNotEmpty) return DateTime.tryParse(v);
      return null;
    }

    return InvoiceModel(
      id: (json['id'] ?? '').toString(),
      code: json['code']?.toString(),
      transactionUuid: json['transaction_uuid']?.toString(),
      status: json['status']?.toString(),
      totalAmount: json['total_amount'] is num 
          ? json['total_amount'] 
          : num.tryParse('${json['total_amount']}'),
      dueDate: parseDT(json['due_date']),
      paidAt: parseDT(json['paid_at']),
      paymentMethod: json['payment_method']?.toString(),
      notes: json['notes']?.toString(),
      createdAt: parseDT(json['created_at']),
      updatedAt: parseDT(json['updated_at']),
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    if (code != null) 'code': code,
    if (transactionUuid != null) 'transaction_uuid': transactionUuid,
    if (status != null) 'status': status,
    if (totalAmount != null) 'total_amount': totalAmount,
    if (dueDate != null) 'due_date': dueDate!.toIso8601String(),
    if (paidAt != null) 'paid_at': paidAt!.toIso8601String(),
    if (paymentMethod != null) 'payment_method': paymentMethod,
    if (notes != null) 'notes': notes,
    if (createdAt != null) 'created_at': createdAt!.toIso8601String(),
    if (updatedAt != null) 'updated_at': updatedAt!.toIso8601String(),
  };

  // Getters for UI
  bool get isPaid => status?.toLowerCase() == 'paid';
  String get displayStatus => status?.toUpperCase() ?? 'UNPAID';
  String get displayCode => code ?? '-';
  String get displayTotal => 'Rp ${totalAmount?.toStringAsFixed(0) ?? '0'}';
}
