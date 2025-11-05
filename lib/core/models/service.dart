import 'customer.dart';
import 'vehicle.dart';

class ServiceModel {
  final String id;
  final String code;
  final String name;
  final String? description;
  final num? price;
  final DateTime? scheduledDate;
  final DateTime? estimatedTime;
  final String status;
  final String? customerUuid;
  final String? workshopUuid;
  final String? vehicleId;

  final Customer? customer;
  final Vehicle? vehicle;
  final String? workshopName;

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
  });

  factory ServiceModel.fromJson(Map<String, dynamic> json) {
    DateTime? _parseDT(dynamic v) {
      if (v == null) return null;
      if (v is String) return DateTime.tryParse(v);
      return null;
    }

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
      vehicleId: json['vehicle_id']?.toString(),
      customer: (json['customer'] is Map) ? Customer.fromJson(json['customer']) : null,
      vehicle: (json['vehicle'] is Map) ? Vehicle.fromJson(json['vehicle']) : null,
      workshopName: json['workshop'] is Map ? (json['workshop']['name']?.toString()) : null,
    );
  }
}
