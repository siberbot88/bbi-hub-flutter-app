import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:bengkel_online_flutter/core/models/user.dart';
import 'package:bengkel_online_flutter/core/models/workshop.dart';
import 'package:bengkel_online_flutter/core/models/workshop_document.dart';

class ApiService {
  static const String _baseUrl = 'http://10.0.2.2:8000/api/v1/';
  final _storage = const FlutterSecureStorage();

  Future<String?> _getToken() async {
    return await _storage.read(key: 'auth_token');
  }

  Future<Map<String, String>> _getAuthHeaders() async {
    String? token = await _getToken();
    if (token == null) {
      throw Exception('Token not found. Please login again.');
    }
    return {
      'Content-Type': 'application/json; charset=UTF-8',
      'Accept': 'application/json',
      'Authorization': 'Bearer $token',
    };
  }

  Map<String, String> _getJsonHeaders() {
    return {
      'Content-Type': 'application/json; charset=UTF-8',
      'Accept': 'application/json',
    };
  }

  // --- Fungsi Autentikasi ---
  Future<Map<String, dynamic>> login(String email, String password) async {
    try {
      final response = await http.post(
        Uri.parse('${_baseUrl}auth/login'),
        headers: _getJsonHeaders(),
        body: jsonEncode(<String, String>{
          'email': email,
          'password': password,
        }),
      );

      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        final error = jsonDecode(response.body);
        throw Exception(error['message'] ?? 'Login gagal');
      }
    } catch (e) {
      throw Exception('Gagal login: ${e.toString()}');
    }
  }

  Future<Map<String, dynamic>> register({
    required String name,
    required String username,
    required String email,
    required String password,
    required String passwordConfirmation,
  }) async {
    try {
      final response = await http.post(
        Uri.parse('${_baseUrl}auth/register'),
        headers: _getJsonHeaders(),
        body: jsonEncode(<String, String>{
          'name': name,
          'username': username,
          'email': email,
          'password': password,
          'password_confirmation': passwordConfirmation,
        }),
      );

      if (response.statusCode == 201) {
        return jsonDecode(response.body);
      } else {
        final error = jsonDecode(response.body);
        // Menangani error validasi spesifik
        if (error['errors'] != null) {
          String firstError = (error['errors'] as Map).values.first[0];
          throw Exception(firstError);
        }
        throw Exception(error['message'] ?? 'Registrasi gagal');
      }
    } catch (e) {
      throw Exception('Gagal registrasi: ${e.toString()}');
    }
  }

  Future<void> logout() async {
    try {
      final response = await http.post(
        Uri.parse('${_baseUrl}auth/logout'),
        headers: await _getAuthHeaders(),
      );

      if (response.statusCode != 200) {
        print('Server logout failed with status: ${response.statusCode}');
      }
    } catch (e) {
      print('Error calling API logout: $e');
    }
  }

  Future<User> fetchUser() async {
    try {
      final response = await http.get(
        Uri.parse('${_baseUrl}auth/user'),
        headers: await _getAuthHeaders(),
      );

      if (response.statusCode == 200) {
        return User.fromJson(jsonDecode(response.body));
      } else if (response.statusCode == 401) {
        throw Exception('Unauthorized');
      } else {
        throw Exception(
            'Gagal mengambil data user. Status: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Gagal mengambil data user: ${e.toString()}');
    }
  }

  // --- Fungsi Registrasi Multi-Step ---

  Future<Workshop> createWorkshop({
    required String name,
    required String description,
    required String address,
    required String phone,
    required String email,
    required String city,
    required String province,
    required String country,
    required String postalCode,
    required double latitude,
    required double longitude,
    required String mapsUrl,
    required String openingTime,
    required String closingTime,
    required String operationalDays,
  }) async {
    try {
      final response = await http.post(
        Uri.parse('${_baseUrl}owners/workshops'),
        headers: await _getAuthHeaders(), // Perlu token
        body: jsonEncode(<String, dynamic>{
          'name': name,
          'description': description,
          'address': address,
          'phone': phone,
          'email': email,
          'city': city,
          'province': province,
          'country': country,
          'postal_code': postalCode,
          'latitude': latitude,
          'longitude': longitude,
          'maps_url': mapsUrl,
          'opening_time': openingTime,
          'closing_time': closingTime,
          'operational_days': operationalDays,
        }),
      );

      if (response.statusCode == 201) {
        return Workshop.fromJson(jsonDecode(response.body));
      } else {
        final error = jsonDecode(response.body);
        if (error['errors'] != null) {
          String firstError = (error['errors'] as Map).values.first[0];
          throw Exception(firstError);
        }
        throw Exception(error['message'] ?? 'Gagal membuat bengkel');
      }
    } catch (e) {
      throw Exception('Gagal membuat bengkel: ${e.toString()}');
    }
  }

  Future<WorkshopDocument> createDocument({
    required String workshopUuid,
    required String nib,
    required String npwp,
  }) async {
    Map<String, String> headers;
    try {

      headers = await _getAuthHeaders();

      final body = jsonEncode(<String, String>{
        'workshop_uuid': workshopUuid,
        'nib': nib,
        'npwp': npwp,
      });

      final response = await http.post(
        Uri.parse('${_baseUrl}owners/documents'),
        headers: headers,
        body: body,
      );

      if (response.statusCode == 201) {
        return WorkshopDocument.fromJson(jsonDecode(response.body));
      } else {
        final error = jsonDecode(response.body);
        if (error['errors'] != null) {
          String firstError = (error['errors'] as Map).values.first[0];
          throw Exception(firstError);
        }
        throw Exception(error['message'] ?? 'Gagal menyimpan dokumen');
      }
    } catch (e) {

      throw Exception('Gagal menyimpan dokumen: ${e.toString().replaceFirst("Exception: ", "")}');
    }
  }

  Future<List<dynamic>> fetchOwnerEmployees() async {
    try {
      final response = await http.get(
        Uri.parse('${_baseUrl}owners/employee'),
        headers: await _getAuthHeaders(),
      );

      if (response.statusCode == 200) {
        return jsonDecode(response.body) as List;
      } else if (response.statusCode == 401) {
        throw Exception('Akses ditolak. Silakan login kembali.');
      } else {
        throw Exception('Gagal mengambil data employee. Status: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Gagal mengambil data employee: ${e.toString()}');
    }
  }
}

