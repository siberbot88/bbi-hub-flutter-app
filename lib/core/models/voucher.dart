import 'package:intl/intl.dart';

class Voucher {
  final String id;
  final String workshopUuid;
  final String codeVoucher;
  final String title;
  final double discountValue;
  final int quota;
  final double minTransaction;
  final DateTime validFrom;
  final DateTime validUntil;
  final bool isActive;
  final String? imageUrl;

  Voucher({
    required this.id,
    required this.workshopUuid,
    required this.codeVoucher,
    required this.title,
    required this.discountValue,
    required this.quota,
    required this.minTransaction,
    required this.validFrom,
    required this.validUntil,
    required this.isActive,
    this.imageUrl,
  });

  factory Voucher.fromJson(Map<String, dynamic> json) {
    return Voucher(
      id: json['id'],
      workshopUuid: json['workshop_uuid'],
      codeVoucher: json['code_voucher'],
      title: json['title'],
      // Handle dynamic types from JSON (int/double/string)
      discountValue: double.parse(json['discount_value'].toString()),
      quota: int.parse(json['quota'].toString()),
      minTransaction: double.parse(json['min_transaction'].toString()),
      validFrom: DateTime.parse(json['valid_from']),
      validUntil: DateTime.parse(json['valid_until']),
      isActive: json['is_active'] == 1 || json['is_active'] == true,
      imageUrl: json['image_url'],
    );
  }

  String get formattedValidDate {
    final formatter = DateFormat('d MMMM yyyy', 'id_ID'); // Pastikan initializeDateFormatting sudah dipanggil di main.dart
    return "${formatter.format(validFrom)} - ${formatter.format(validUntil)}";
  }

  String get formattedUntilDate {
    final formatter = DateFormat('d MMMM yyyy', 'id_ID');
    return formatter.format(validUntil);
  }

  bool get isExpired => DateTime.now().isAfter(validUntil);
}