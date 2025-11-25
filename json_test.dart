import 'dart:convert';
import 'package:bengkel_online_flutter/core/models/user.dart'; // Pastikan path ini sesuai

void main() {
  const rawJson = '''
  {
    "id": "90f13117-6cd3-4725-a4f7-f95795d115a7",
    "name": "Imam Subarja",
    "username": "Boss Imam",
    "email": "imam@gmail.com",
    "email_verified_at": null,
    "photo": "https://placehold.co/400x400/000000/FFFFFF?text=Im",
    "created_at": "2025-10-29T04:13:27.000000Z",
    "updated_at": "2025-10-29T04:13:27.000000Z",
    "roles": [
        {
            "name": "owner",
            "pivot": {
                "model_type": "App\\\\Models\\\\User",
                "model_id": "90f13117-6cd3-4725-a4f7-f95795d115a7",
                "role_id": 1
            }
        }
    ],
    "workshops": [
        {
            "id": "019a2e2e-a425-720d-8c18-242e6581d48d",
            "user_uuid": "90f13117-6cd3-4725-a4f7-f95795d115a7",
            "code": "BKL-A9NGKSKK",
            "name": "Bengkel Mobil Sejahtera",
            "description": "Bengkel spesialis perawatan dan perbaikan mobil segala merek dengan layanan cepat, jujur, dan bergaransi. Menyediakan juga jasa tune-up, spooring balancing, serta ganti oli dan aki.",
            "address": "Jl. Raya Cibubur No. 88, Kel. Cibubur, Kec. Ciracas",
            "phone": "021-87912345",
            "email": "info@bengkelmobilsejahtera.co.id",
            "photo": "https://placehold.co/600x400/D72B1C/FFFFFF?text=Bengkel Mobil Sejahtera",
            "city": "Jakarta Timur",
            "province": "DKI Jakarta",
            "country": "Indonesia",
            "postal_code": "13720",
            "latitude": "-6.35387900",
            "longitude": "106.87592300",
            "maps_url": "https://maps.google.com/?q=-6.353879,106.875923",
            "opening_time": "08:00:00",
            "closing_time": "17:00:00",
            "operational_days": "Senin - Sabtu",
            "is_active": 1,
            "created_at": "2025-10-29T04:16:39.000000Z",
            "updated_at": "2025-10-29T04:16:39.000000Z"
        }
    ]
  }
  ''';

  final jsonMap = jsonDecode(rawJson);
  try {
    final user = User.fromJson(jsonMap);
    print("✅ Parsing sukses!");
    print("Nama: ${user.name}");
    print("Jumlah workshop: ${user.workshops?.length ?? 0}");
    print("Nama workshop pertama: ${user.workshops?.first.name}");
  } catch (e, stack) {
    print("❌ Gagal parsing:");
    print(e);
    print(stack);
  }
}
