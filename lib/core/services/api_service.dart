import 'package:bengkel_online_flutter/core/models/employment.dart';
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

  // ---------- Helpers ----------
  bool _isJsonResponse(http.Response response) {
    final ct = response.headers['content-type'] ?? '';
    return ct.toLowerCase().contains('application/json');
  }

  dynamic _tryDecodeJson(String body) {
    if (body.isEmpty) return null;
    try {
      return jsonDecode(body);
    } catch (_) {
      return null;
    }
  }

  String _firstChars(String s, [int max = 200]) {
    if (s.length <= max) return s;
    return s.substring(0, max) + '...';
  }

  String _sanitize(String input) {
    return input
        .replaceAll(RegExp(r'[\u0000-\u001F\u007F]'), '') // control chars
        .replaceAll('\r', ' ')
        .replaceAll('\n', ' ')
        .replaceAll('"', "'")
        .trim();
  }

  void _debugRequest(String label, Uri uri, Map<String, String> headers, String? body) {
    // Akan terlihat di Run/Debug console Android Studio
    print('[$label] ${uri.toString()}');
    print('[$label] headers: $headers');
    if (body != null) print('[$label] body: ${_firstChars(body)}');
  }

  void _debugResponse(String label, http.Response response) {
    print('[$label] status: ${response.statusCode}');
    print('[$label] content-type: ${response.headers['content-type']}');
    print('[$label] body: ${_firstChars(response.body)}');
  }

  // ---------- Auth ----------
  Future<Map<String, dynamic>> login(String email, String password) async {
    try {
      final uri = Uri.parse('${_baseUrl}auth/login');
      final headers = _getJsonHeaders();
      final body = jsonEncode(<String, String>{
        'email': email,
        'password': password,
      });

      _debugRequest('LOGIN', uri, headers, body);

      final response = await http.post(uri, headers: headers, body: body);

      _debugResponse('LOGIN', response);

      if (response.statusCode == 200) {
        final json = _tryDecodeJson(response.body);
        if (json is Map<String, dynamic>) return json;
        throw Exception('Respon login bukan JSON.');
      } else {
        final json = _tryDecodeJson(response.body);
        if (json is Map && json['message'] != null) {
          throw Exception(json['message']);
        }
        throw Exception('Login gagal (HTTP ${response.statusCode}).');
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
      final uri = Uri.parse('${_baseUrl}auth/register');
      final headers = _getJsonHeaders();
      final body = jsonEncode(<String, String>{
        'name': name,
        'username': username,
        'email': email,
        'password': password,
        'password_confirmation': passwordConfirmation,
      });

      _debugRequest('REGISTER', uri, headers, body);

      final response = await http.post(uri, headers: headers, body: body);

      _debugResponse('REGISTER', response);

      if (response.statusCode == 201) {
        final json = _tryDecodeJson(response.body);
        if (json is Map<String, dynamic>) return json;
        throw Exception('Respon registrasi bukan JSON.');
      } else {
        final json = _tryDecodeJson(response.body);
        if (json is Map && json['errors'] != null) {
          String firstError = (json['errors'] as Map).values.first[0];
          throw Exception(firstError);
        }
        if (json is Map && json['message'] != null) {
          throw Exception(json['message']);
        }
        throw Exception('Registrasi gagal (HTTP ${response.statusCode}).');
      }
    } catch (e) {
      throw Exception('Gagal registrasi: ${e.toString()}');
    }
  }

  Future<void> logout() async {
    try {
      final uri = Uri.parse('${_baseUrl}auth/logout');
      final headers = await _getAuthHeaders();

      _debugRequest('LOGOUT', uri, headers, null);

      final response = await http.post(uri, headers: headers);

      _debugResponse('LOGOUT', response);

      if (response.statusCode != 200) {
        print('Server logout failed with status: ${response.statusCode}');
      }
    } catch (e) {
      print('Error calling API logout: $e');
    }
  }

  Future<User> fetchUser() async {
    try {
      final uri = Uri.parse('${_baseUrl}auth/user');
      final headers = await _getAuthHeaders();

      _debugRequest('FETCH_USER', uri, headers, null);

      final response = await http.get(uri, headers: headers);

      _debugResponse('FETCH_USER', response);

      if (response.statusCode == 200 && _isJsonResponse(response)) {
        final json = _tryDecodeJson(response.body);
        if (json is Map<String, dynamic>) {
          return User.fromJson(json);
        }
        throw Exception('Respon user bukan JSON.');
      } else if (response.statusCode == 401) {
        throw Exception('Unauthorized');
      } else {
        throw Exception('Gagal mengambil data user. Status: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Gagal mengambil data user: ${e.toString()}');
    }
  }

  // ---------- Workshop ----------
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
      final uri = Uri.parse('${_baseUrl}owners/workshops');
      final headers = await _getAuthHeaders();
      final body = jsonEncode(<String, dynamic>{
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
      });

      _debugRequest('CREATE_WORKSHOP', uri, headers, body);

      final response = await http.post(uri, headers: headers, body: body);

      _debugResponse('CREATE_WORKSHOP', response);

      if (response.statusCode == 201 && _isJsonResponse(response)) {
        final json = _tryDecodeJson(response.body);
        if (json is Map<String, dynamic>) return Workshop.fromJson(json);
        throw Exception('Respon create workshop bukan JSON.');
      } else {
        final json = _tryDecodeJson(response.body);
        if (json is Map && json['errors'] != null) {
          String firstError = (json['errors'] as Map).values.first[0];
          throw Exception(firstError);
        }
        if (json is Map && json['message'] != null) {
          throw Exception(json['message']);
        }
        throw Exception('Gagal membuat bengkel (HTTP ${response.statusCode}).');
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
    try {
      final uri = Uri.parse('${_baseUrl}owners/documents');
      final headers = await _getAuthHeaders();
      final body = jsonEncode(<String, String>{
        'workshop_uuid': workshopUuid,
        'nib': nib,
        'npwp': npwp,
      });

      _debugRequest('CREATE_DOCUMENT', uri, headers, body);

      final response = await http.post(uri, headers: headers, body: body);

      _debugResponse('CREATE_DOCUMENT', response);

      if (response.statusCode == 201 && _isJsonResponse(response)) {
        final json = _tryDecodeJson(response.body);
        if (json is Map<String, dynamic>) {
          return WorkshopDocument.fromJson(json);
        }
        throw Exception('Respon create document bukan JSON.');
      } else {
        final json = _tryDecodeJson(response.body);
        if (json is Map && json['errors'] != null) {
          String firstError = (json['errors'] as Map).values.first[0];
          throw Exception(firstError);
        }
        if (json is Map && json['message'] != null) {
          throw Exception(json['message']);
        }
        throw Exception('Gagal menyimpan dokumen (HTTP ${response.statusCode}).');
      }
    } catch (e) {
      throw Exception('Gagal menyimpan dokumen: ${e.toString().replaceFirst("Exception: ", "")}');
    }
  }

  // ---------- Employee ----------
  Future<Employment> createEmployee({
    required String name,
    required String username,
    required String email,
    required String password,
    required String passwordConfirmation,
    required String role,
    required String workshopUuid,
    String? specialist,
    String? jobdesk,
  }) async {
    try {
      final uri = Uri.parse('${_baseUrl}owners/employee');
      final headers = await _getAuthHeaders();

      final Map<String, dynamic> bodyMap = {
        'name': name.trim(),
        'username': username.trim(),
        'email': email.trim(),
        'password': password,
        'password_confirmation': passwordConfirmation,
        'role': role,
        'workshop_uuid': workshopUuid,
      };

      if (specialist != null && specialist.trim().isNotEmpty) {
        bodyMap['specialist'] = _sanitize(specialist);
      }
      if (jobdesk != null && jobdesk.trim().isNotEmpty) {
        bodyMap['jobdesk'] = _sanitize(jobdesk);
      }

      final body = jsonEncode(bodyMap);

      _debugRequest('CREATE_EMPLOYEE', uri, headers, body);

      final response = await http.post(uri, headers: headers, body: body);

      _debugResponse('CREATE_EMPLOYEE', response);

      if (response.statusCode == 201) {
        if (!_isJsonResponse(response)) {
          throw Exception('Server mengembalikan non-JSON pada 201.');
        }
        final json = _tryDecodeJson(response.body);
        if (json is Map<String, dynamic>) {
          // Pastikan bentuk JSON dari backend cocok dengan Employment.fromJson
          return Employment.fromJson(json);
        } else {
          throw Exception('Respon 201 bukan objek JSON.');
        }
      } else {
        // Jangan paksa decode JSON kalau bukan JSON
        if (_isJsonResponse(response)) {
          final json = _tryDecodeJson(response.body);
          if (json is Map && json['errors'] != null) {
            String firstError = (json['errors'] as Map).values.first[0];
            throw Exception(firstError);
          }
          if (json is Map && json['message'] != null) {
            throw Exception(json['message']);
          }
        }
        throw Exception('Gagal membuat karyawan (HTTP ${response.statusCode}). Body: ${_firstChars(response.body)}');
      }
    } catch (e) {
      throw Exception('Gagal membuat karyawan: ${e.toString().replaceFirst("Exception: ", "")}');
    }
  }

  Future<List<dynamic>> fetchOwnerEmployees() async {
    try {
      final uri = Uri.parse('${_baseUrl}owners/employee');
      final headers = await _getAuthHeaders();

      _debugRequest('FETCH_EMPLOYEES', uri, headers, null);

      final response = await http.get(uri, headers: headers);

      _debugResponse('FETCH_EMPLOYEES', response);

      if (response.statusCode == 200 && _isJsonResponse(response)) {
        final json = _tryDecodeJson(response.body);
        if (json is List) {
          return json.map((e) => Employment.fromJson(e as Map<String, dynamic>)).toList();
        }
        throw Exception('Respon list employee bukan JSON array.');
      } else if (response.statusCode == 401) {
        throw Exception('Akses ditolak. Silakan login kembali.');
      } else {
        throw Exception('Gagal mengambil data employee. Status: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Gagal mengambil data employee: ${e.toString().replaceFirst("Exception: ", "")}');
    }
  }
}
