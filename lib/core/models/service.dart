// core/models/service.dart
import 'customer.dart';
import 'vehicle.dart';
import 'transaction_item.dart';

/// Reference to a mechanic (provided by backend in `mechanic` field)
class MechanicRef {
  final String id;
  final String? name;

  MechanicRef({required this.id, this.name});

  factory MechanicRef.fromJson(Map<String, dynamic> json) {
    return MechanicRef(
      id: (json['id'] ?? '').toString(),
      name: json['name']?.toString(),
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        if (name != null) 'name': name,
      };
}

class ServiceModel {
  final String id;
  final String code;
  final String name;
  final String? description;
  final num? price;

  // Booking / schedule date
  final DateTime? scheduledDate;
  // Estimated completion time (optional)
  final DateTime? estimatedTime;

  // Main status of the service: pending/accept/in_progress/completed/cancelled
  final String status;
  // Service type: booking / on_site
  final String? type;

  // Acceptance status (optional, from `acceptance_status` column)
  final String? acceptanceStatus;
  final DateTime? acceptedAt;
  final DateTime? completedAt;

  // Optional foreign keys
  final String? customerUuid;
  final String? workshopUuid;
  final String? vehicleId;
  final String? mechanicUuid;
  final String? transactionUuid;

  // Relations
  final Customer? customer;
  final Vehicle? vehicle;
  final String? workshopName;
  final MechanicRef? mechanic;
  final List<TransactionItem>? items;
  final String? note;
  final String? categoryName; // `category_service`
  final String? reason;
  final String? reasonDescription;
  final String? feedbackMechanic;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  ServiceModel({
    required this.id,
    required this.code,
    required this.name,
    this.description,
    this.price,
    this.scheduledDate,
    this.estimatedTime,
    required this.status,
    this.type,
    this.acceptanceStatus,
    this.acceptedAt,
    this.completedAt,
    this.customerUuid,
    this.workshopUuid,
    this.vehicleId,
    this.mechanicUuid,
    this.transactionUuid,
    this.customer,
    this.vehicle,
    this.workshopName,
    this.mechanic,
    this.items,
    this.note,
    this.categoryName,
    this.reason,
    this.reasonDescription,
    this.feedbackMechanic,
    this.createdAt,
    this.updatedAt,
  });

  // ---------- UI helper getters ----------
  String get displayCustomerName => customer?.name ?? '-';
  String get displayVehicleName => vehicle?.name ?? displayVehicleModel;
  String get displayVehiclePlate => vehicle?.plateNumber ?? '-';
  String get displayVehicleBrand => vehicle?.brand ?? '-';
  String get displayVehicleModel => vehicle?.model ?? '-';
  String get mechanicName => mechanic?.name ?? '-';
  String? get complaint => description; // Alias
  String? get request => description; // Alias

  // Combined search string for efficient searching (lowercase)
  String get searchKeywords {
    final parts = <String>[
      code,
      name,
      description ?? '',
      customer?.name ?? '',
      vehicle?.plateNumber ?? '',
      vehicle?.brand ?? '',
      vehicle?.model ?? '',
      vehicle?.name ?? '',
      workshopName ?? '',
    ];
    return parts.where((e) => e.isNotEmpty).join(' | ').toLowerCase();
  }

  // ---------- JSON (de)serialization ----------
  static DateTime? _parseDT(dynamic v) {
    if (v == null) return null;
    if (v is DateTime) return v;
    if (v is String && v.isNotEmpty) return DateTime.tryParse(v);
    return null;
  }

  factory ServiceModel.fromJson(Map<String, dynamic> json) {
    // Helper to resolve vehicle id from various possible fields
    String? _vehicleId() {
      if (json['vehicle_uuid'] != null) return json['vehicle_uuid'].toString();
      if (json['vehicle_id'] != null) return json['vehicle_id'].toString();
      if (json['vehicleId'] != null) return json['vehicleId'].toString();
      final v = json['vehicle'];
      if (v is Map && v['id'] != null) return v['id'].toString();
      return null;
    }

    // Helper to extract workshop name from relation
    String? _workshopName() {
      final w = json['workshop'];
      if (w is Map && w['name'] is String && (w['name'] as String).isNotEmpty) {
        return w['name'] as String;
      }
      return null;
    }

    // Helper to build MechanicRef from relation
    MechanicRef? _mechanic() {
      final m = json['mechanic'];
      if (m is Map) return MechanicRef.fromJson(Map<String, dynamic>.from(m));
      return null;
    }

    final itemsJson = json['items'] is List ? json['items'] as List : const [];

    return ServiceModel(
      id: (json['id'] ?? '').toString(),
      code: (json['code'] ?? '').toString(),
      name: (json['name'] ?? '').toString(),
      description: json['description']?.toString(),
      price: json['price'] is num ? json['price'] : num.tryParse('${json['price']}'),
      scheduledDate: _parseDT(json['scheduled_date']),
      estimatedTime: _parseDT(json['estimated_time']),
      status: (json['status'] ?? '').toString(),
      type: json['type']?.toString(),
      acceptanceStatus: json['acceptance_status']?.toString(),
      acceptedAt: _parseDT(json['accepted_at']),
      completedAt: _parseDT(json['completed_at']),
      customerUuid: json['customer_uuid']?.toString(),
      workshopUuid: json['workshop_uuid']?.toString(),
      vehicleId: _vehicleId(),
      mechanicUuid: json['mechanic_uuid']?.toString(),
      transactionUuid: json['transaction_uuid']?.toString() ?? json['transaction_id']?.toString(),
      customer: json['customer'] is Map ? Customer.fromJson(Map<String, dynamic>.from(json['customer'] as Map)) : null,
      vehicle: json['vehicle'] is Map ? Vehicle.fromJson(Map<String, dynamic>.from(json['vehicle'] as Map)) : null,
      workshopName: _workshopName(),
      mechanic: _mechanic(),
      items: itemsJson.whereType<Map<String, dynamic>>().map((e) => TransactionItem.fromJson(e)).toList(),
      note: json['note']?.toString(),
      categoryName: (json['category_service'] ?? json['category_name'])?.toString(),
      reason: json['reason']?.toString(),
      reasonDescription: json['reason_description']?.toString(),
      feedbackMechanic: json['feedback_mechanic']?.toString(),
      createdAt: _parseDT(json['created_at']),
      updatedAt: _parseDT(json['updated_at']),
    );
  }

  // Helper for optional relation serialization
  Map<String, dynamic>? _customerJson() {
    if (customer == null) return null;
    return {
      'id': customer!.id?.toString(),
      'name': customer!.name?.toString(),
    };
  }

  Map<String, dynamic>? _vehicleJson() {
    if (vehicle == null) return null;
    return {
      'id': vehicle!.id?.toString(),
      'plate_number': vehicle!.plateNumber?.toString(),
      'brand': vehicle!.brand?.toString(),
      'model': vehicle!.model?.toString(),
      'name': vehicle!.name?.toString(),
    };
  }

  List<Map<String, dynamic>>? _itemsJson() {
    if (items == null) return null;
    final out = <Map<String, dynamic>>[];
    for (final it in items!) {
      try {
        out.add({
          'id': it.id?.toString(),
          'name': it.name?.toString(),
          'qty': it.qty ?? it.quantity,
          'price': it.price,
          'total': it.total ?? it.subtotal,
        });
      } catch (_) {}
    }
    return out.isEmpty ? null : out;
  }

  Map<String, dynamic> toJson({bool includeRelations = false}) {
    return {
      'id': id,
      'code': code,
      'name': name,
      if (description != null) 'description': description,
      if (price != null) 'price': price,
      if (scheduledDate != null) 'scheduled_date': scheduledDate!.toIso8601String(),
      if (estimatedTime != null) 'estimated_time': estimatedTime!.toIso8601String(),
      'status': status,
      if (type != null) 'type': type,
      if (acceptanceStatus != null) 'acceptance_status': acceptanceStatus,
      if (acceptedAt != null) 'accepted_at': acceptedAt!.toIso8601String(),
      if (completedAt != null) 'completed_at': completedAt!.toIso8601String(),
      if (customerUuid != null) 'customer_uuid': customerUuid,
      if (workshopUuid != null) 'workshop_uuid': workshopUuid,
      if (vehicleId != null) 'vehicle_id': vehicleId,
      if (mechanicUuid != null) 'mechanic_uuid': mechanicUuid,
      if (transactionUuid != null) 'transaction_uuid': transactionUuid,
      if (includeRelations && workshopName != null) 'workshop': {'name': workshopName},
      if (mechanic != null) 'mechanic': mechanic!.toJson(),
      if (includeRelations && _customerJson() != null) 'customer': _customerJson(),
      if (includeRelations && _vehicleJson() != null) 'vehicle': _vehicleJson(),
      if (includeRelations && _itemsJson() != null) 'items': _itemsJson(),
      if (note != null) 'note': note,
      if (categoryName != null) 'category_service': categoryName,
      if (reason != null) 'reason': reason,
      if (reasonDescription != null) 'reason_description': reasonDescription,
      if (feedbackMechanic != null) 'feedback_mechanic': feedbackMechanic,
      if (createdAt != null) 'created_at': createdAt!.toIso8601String(),
      if (updatedAt != null) 'updated_at': updatedAt!.toIso8601String(),
    };
  }
}
