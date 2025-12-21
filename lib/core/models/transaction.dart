import 'package:bengkel_online_flutter/core/models/invoice.dart';
import 'package:bengkel_online_flutter/core/models/service.dart';
import 'package:bengkel_online_flutter/core/models/customer.dart';
import 'package:bengkel_online_flutter/core/models/vehicle.dart';

/// Model for Transaction Item (sparepart/jasa)
class TransactionItemModel {
  final String id;
  final String? transactionUuid;
  final String? name;
  final String? type; // 'jasa', 'sparepart', 'biaya_tambahan', 'lainnya'
  final int quantity;
  final num price;
  final num? subtotal;

  TransactionItemModel({
    required this.id,
    this.transactionUuid,
    this.name,
    this.type,
    this.quantity = 1,
    required this.price,
    this.subtotal,
  });

  factory TransactionItemModel.fromJson(Map<String, dynamic> json) {
    return TransactionItemModel(
      id: (json['id'] ?? '').toString(),
      transactionUuid: json['transaction_uuid']?.toString(),
      name: json['name']?.toString(),
      type: json['type']?.toString(),
      quantity: (json['quantity'] is int) ? json['quantity'] : int.tryParse('${json['quantity']}') ?? 1,
      price: (json['price'] is num) ? json['price'] : num.tryParse('${json['price']}') ?? 0,
      subtotal: json['subtotal'] is num ? json['subtotal'] : num.tryParse('${json['subtotal']}'),
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    if (transactionUuid != null) 'transaction_uuid': transactionUuid,
    if (name != null) 'name': name,
    if (type != null) 'type': type,
    'quantity': quantity,
    'price': price,
    if (subtotal != null) 'subtotal': subtotal,
  };
}

/// Model for Transaction
class TransactionModel {
  final String id;
  final String? code;
  final String? serviceUuid;
  final String? customerUuid;
  final String? workshopUuid;
  final String? mechanicUuid;
  final String? status; // 'draft', 'pending', 'paid', 'cancelled'
  final num? totalAmount;
  final num? discount;
  final num? tax;
  final num? grandTotal;
  final String? notes;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  // Relations
  final ServiceModel? service;
  final Customer? customer;
  final Vehicle? vehicle;
  final InvoiceModel? invoice;
  final List<TransactionItemModel>? items;

  TransactionModel({
    required this.id,
    this.code,
    this.serviceUuid,
    this.customerUuid,
    this.workshopUuid,
    this.mechanicUuid,
    this.status,
    this.totalAmount,
    this.discount,
    this.tax,
    this.grandTotal,
    this.notes,
    this.createdAt,
    this.updatedAt,
    this.service,
    this.customer,
    this.vehicle,
    this.invoice,
    this.items,
  });

  factory TransactionModel.fromJson(Map<String, dynamic> json) {
    DateTime? parseDT(dynamic v) {
      if (v == null) return null;
      if (v is DateTime) return v;
      if (v is String && v.isNotEmpty) return DateTime.tryParse(v);
      return null;
    }

    final itemsJson = json['items'] is List ? json['items'] as List : const [];

    return TransactionModel(
      id: (json['id'] ?? '').toString(),
      code: json['code']?.toString(),
      serviceUuid: json['service_uuid']?.toString(),
      customerUuid: json['customer_uuid']?.toString(),
      workshopUuid: json['workshop_uuid']?.toString(),
      mechanicUuid: json['mechanic_uuid']?.toString(),
      status: json['status']?.toString(),
      totalAmount: json['total_amount'] is num ? json['total_amount'] : num.tryParse('${json['total_amount']}'),
      discount: json['discount'] is num ? json['discount'] : num.tryParse('${json['discount']}'),
      tax: json['tax'] is num ? json['tax'] : num.tryParse('${json['tax']}'),
      grandTotal: json['grand_total'] is num ? json['grand_total'] : num.tryParse('${json['grand_total']}'),
      notes: json['notes']?.toString(),
      createdAt: parseDT(json['created_at']),
      updatedAt: parseDT(json['updated_at']),
      service: json['service'] is Map 
          ? ServiceModel.fromJson(Map<String, dynamic>.from(json['service']))
          : null,
      customer: json['customer'] is Map
          ? Customer.fromJson(Map<String, dynamic>.from(json['customer']))
          : null,
      vehicle: json['vehicle'] is Map
          ? Vehicle.fromJson(Map<String, dynamic>.from(json['vehicle']))
          : null,
      invoice: json['invoice'] is Map
          ? InvoiceModel.fromJson(Map<String, dynamic>.from(json['invoice']))
          : null,
      items: itemsJson
          .whereType<Map>()
          .map((e) => TransactionItemModel.fromJson(Map<String, dynamic>.from(e)))
          .toList(),
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    if (code != null) 'code': code,
    if (serviceUuid != null) 'service_uuid': serviceUuid,
    if (customerUuid != null) 'customer_uuid': customerUuid,
    if (workshopUuid != null) 'workshop_uuid': workshopUuid,
    if (mechanicUuid != null) 'mechanic_uuid': mechanicUuid,
    if (status != null) 'status': status,
    if (totalAmount != null) 'total_amount': totalAmount,
    if (discount != null) 'discount': discount,
    if (tax != null) 'tax': tax,
    if (grandTotal != null) 'grand_total': grandTotal,
    if (notes != null) 'notes': notes,
    if (createdAt != null) 'created_at': createdAt!.toIso8601String(),
    if (updatedAt != null) 'updated_at': updatedAt!.toIso8601String(),
  };

  // Getters for UI
  String get displayStatus => status?.toUpperCase() ?? 'DRAFT';
  String get displayCode => code ?? '-';
  String get displayTotal => 'Rp ${grandTotal?.toStringAsFixed(0) ?? '0'}';
}
