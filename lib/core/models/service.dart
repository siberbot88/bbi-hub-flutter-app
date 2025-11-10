import 'customer.dart';
import 'vehicle.dart';
import 'transaction_item.dart';

/// Referensi teknisi (disediakan backend pada field `mechanic`)
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
  final DateTime? scheduledDate;
  final DateTime? estimatedTime;
  final String status;

  // referensi id (opsional)
  final String? customerUuid;
  final String? workshopUuid;
  final String? vehicleId;

  // relasi
  final Customer? customer;
  final Vehicle? vehicle;
  final String? workshopName;

  // teknisi (opsional)
  final MechanicRef? mechanic;

  // tambahan opsional
  final List<TransactionItem>? items;
  final String? note;
  final String? categoryName;

  ServiceModel({
    required this.id,
    required this.code,
    required this.name,
    this.description,
    this.price,
    this.scheduledDate,
    this.estimatedTime,
    required this.status,
    this.customerUuid,
    this.workshopUuid,
    this.vehicleId,
    this.customer,
    this.vehicle,
    this.workshopName,
    this.mechanic,
    this.items,
    this.note,
    this.categoryName,
  });

  factory ServiceModel.fromJson(Map<String, dynamic> json) {
    DateTime? _parseDT(dynamic v) {
      if (v == null) return null;
      if (v is String) return DateTime.tryParse(v);
      return null;
    }

    // Vehicle id bisa snake_case atau camelCase
    String? _vehicleId() {
      if (json['vehicle_id'] != null) return json['vehicle_id'].toString();
      if (json['vehicleId'] != null) return json['vehicleId'].toString();
      return null;
    }

    // workshop name dari relasi
    String? _workshopName() {
      final w = json['workshop'];
      if (w is Map && w['name'] is String && (w['name'] as String).isNotEmpty) {
        return w['name'] as String;
      }
      return null;
    }

    // mechanic dari relasi
    MechanicRef? _mechanic() {
      final m = json['mechanic'];
      if (m is Map) {
        return MechanicRef.fromJson(Map<String, dynamic>.from(m));
      }
      return null;
    }

    final itemsJson = (json['items'] is List) ? (json['items'] as List) : const <dynamic>[];

    return ServiceModel(
      id: (json['id'] ?? '').toString(),
      code: (json['code'] ?? '').toString(),
      name: (json['name'] ?? '').toString(),
      description: json['description']?.toString(),
      price: json['price'] is num ? json['price'] : num.tryParse('${json['price']}'),
      scheduledDate: _parseDT(json['scheduled_date']),
      estimatedTime: _parseDT(json['estimated_time']),
      status: (json['status'] ?? '').toString(),
      customerUuid: json['customer_uuid']?.toString(),
      workshopUuid: json['workshop_uuid']?.toString(),
      vehicleId: _vehicleId(),
      customer: (json['customer'] is Map) ? Customer.fromJson(Map<String, dynamic>.from(json['customer'])) : null,
      vehicle: (json['vehicle'] is Map) ? Vehicle.fromJson(Map<String, dynamic>.from(json['vehicle'])) : null,
      workshopName: _workshopName(),
      mechanic: _mechanic(),
      items: itemsJson.whereType<Map>().map((e) => TransactionItem.fromJson(Map<String, dynamic>.from(e))).toList(),
      note: json['note']?.toString(),
      categoryName: json['category_name']?.toString(),
    );
  }

  /// Serialization ringan (tanpa memanggil `toJson()` dari model lain).
  /// `includeRelations` jika ingin ikut menyertakan snapshot relasi sebagai primitive map.
  Map<String, dynamic> toJson({bool includeRelations = false}) {
    Map<String, dynamic>? _customerJson() {
      if (!includeRelations || customer == null) return null;
      try {
        final c = customer as dynamic;
        return {
          'id': c.id?.toString(),
          'name': c.name?.toString(),
        };
      } catch (_) {
        return null;
      }
    }

    Map<String, dynamic>? _vehicleJson() {
      if (!includeRelations || vehicle == null) return null;
      try {
        final v = vehicle as dynamic;
        return {
          'id': v.id?.toString(),
          'plate_number': v.plateNumber?.toString(),
          'brand': v.brand?.toString(),
          'model': v.model?.toString(),
          'name': v.name?.toString(),
        };
      } catch (_) {
        return null;
      }
    }

    List<Map<String, dynamic>>? _itemsJson() {
      if (!includeRelations || items == null) return null;
      final out = <Map<String, dynamic>>[];
      for (final it in items!) {
        try {
          final d = it as dynamic;
          out.add({
            'id': d.id?.toString(),
            'name': d.name?.toString(),
            'qty': d.qty,
            'price': d.price,
            'total': d.total,
          });
        } catch (_) {}
      }
      return out.isEmpty ? null : out;
    }

    return {
      'id': id,
      'code': code,
      'name': name,
      if (description != null) 'description': description,
      if (price != null) 'price': price,
      if (scheduledDate != null) 'scheduled_date': scheduledDate!.toIso8601String(),
      if (estimatedTime != null) 'estimated_time': estimatedTime!.toIso8601String(),
      'status': status,
      if (customerUuid != null) 'customer_uuid': customerUuid,
      if (workshopUuid != null) 'workshop_uuid': workshopUuid,
      if (vehicleId != null) 'vehicle_id': vehicleId,
      if (includeRelations && workshopName != null) 'workshop': {'name': workshopName},
      if (mechanic != null) 'mechanic': mechanic!.toJson(),
      if (includeRelations && _customerJson() != null) 'customer': _customerJson(),
      if (includeRelations && _vehicleJson() != null) 'vehicle': _vehicleJson(),
      if (includeRelations && _itemsJson() != null) 'items': _itemsJson(),
      if (note != null) 'note': note,
      if (categoryName != null) 'category_name': categoryName,
    };
  }

  /// Untuk UI: tampilkan nama teknisi (atau '-')
  String get mechanicName => mechanic?.name ?? '-';
}
