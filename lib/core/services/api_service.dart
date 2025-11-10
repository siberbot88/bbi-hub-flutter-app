import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

import 'package:bengkel_online_flutter/core/models/employment.dart';
import 'package:bengkel_online_flutter/core/models/user.dart';
import 'package:bengkel_online_flutter/core/models/workshop.dart';
import 'package:bengkel_online_flutter/core/models/workshop_document.dart';
import 'package:bengkel_online_flutter/core/models/service.dart';

class ApiService {
  static const String _baseUrl = 'http://10.0.2.2:8000/api/v1/';
  final _storage = const FlutterSecureStorage();

  /* ===================== Common helpers ===================== */
  Future<String?> _getToken() async => _storage.read(key: 'auth_token');

  Future<Map<String, String>> _getAuthHeaders() async {
    final token = await _getToken();
    if (token == null) throw Exception('Token not found. Please login again.');
    return {
      'Content-Type': 'application/json; charset=UTF-8',
      'Accept': 'application/json',
      'Authorization': 'Bearer $token',
    };
  }

  Map<String, String> _getJsonHeaders() => {
    'Content-Type': 'application/json; charset=UTF-8',
    'Accept': 'application/json',
  };

  bool _isJsonResponse(http.Response r) =>
      (r.headers['content-type'] ?? '').toLowerCase().contains('application/json');

  dynamic _tryDecodeJson(String body) {
    if (body.isEmpty) return null;
    try {
      return jsonDecode(body);
    } catch (_) {
      return null;
    }
  }

  String _firstChars(String s, [int max = 200]) =>
      s.length <= max ? s : '${s.substring(0, max)}...';

  String _sanitize(String input) => input
      .replaceAll(RegExp(r'[\u0000-\u001F\u007F]'), '')
      .replaceAll('\r', ' ')
      .replaceAll('\n', ' ')
      .replaceAll('"', "'")
      .trim();

  void _debugRequest(String label, Uri uri, Map<String, String> headers, String? body) {
    // ignore: avoid_print
    print('[$label] ${uri.toString()}');
    // ignore: avoid_print
    print('[$label] headers: $headers');
    if (body != null) {
      // ignore: avoid_print
      print('[$label] body: ${_firstChars(body)}');
    }
  }

  void _debugResponse(String label, http.Response response) {
    // ignore: avoid_print
    print('[$label] status: ${response.statusCode}');
    // ignore: avoid_print
    print('[$label] content-type: ${response.headers['content-type']}');
    // ignore: avoid_print
    print('[$label] body: ${_firstChars(response.body)}');
  }

  /* ========================= AUTH ========================= */
  Future<Map<String, dynamic>> login(String email, String password) async {
    try {
      final uri = Uri.parse('${_baseUrl}auth/login');
      final headers = _getJsonHeaders();
      final body = jsonEncode({'email': email, 'password': password});
      _debugRequest('LOGIN', uri, headers, body);
      final res = await http.post(uri, headers: headers, body: body);
      _debugResponse('LOGIN', res);

      if (res.statusCode == 200) {
        final json = _tryDecodeJson(res.body);
        if (json is Map<String, dynamic>) return json;
        throw Exception('Respon login bukan JSON.');
      }
      final json = _tryDecodeJson(res.body);
      if (json is Map && json['message'] != null) throw Exception(json['message']);
      throw Exception('Login gagal (HTTP ${res.statusCode}).');
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
      final body = jsonEncode({
        'name': name,
        'username': username,
        'email': email,
        'password': password,
        'password_confirmation': passwordConfirmation,
      });
      _debugRequest('REGISTER', uri, headers, body);
      final res = await http.post(uri, headers: headers, body: body);
      _debugResponse('REGISTER', res);

      if (res.statusCode == 201) {
        final json = _tryDecodeJson(res.body);
        if (json is Map<String, dynamic>) return json;
        throw Exception('Respon registrasi bukan JSON.');
      }
      final json = _tryDecodeJson(res.body);
      if (json is Map && json['errors'] != null) {
        final firstError = (json['errors'] as Map).values.first[0];
        throw Exception(firstError);
      }
      if (json is Map && json['message'] != null) throw Exception(json['message']);
      throw Exception('Registrasi gagal (HTTP ${res.statusCode}).');
    } catch (e) {
      throw Exception('Gagal registrasi: ${e.toString()}');
    }
  }

  Future<void> logout() async {
    try {
      final uri = Uri.parse('${_baseUrl}auth/logout');
      final headers = await _getAuthHeaders();
      _debugRequest('LOGOUT', uri, headers, null);
      final res = await http.post(uri, headers: headers);
      _debugResponse('LOGOUT', res);
      if (res.statusCode != 200) {
        // ignore: avoid_print
        print('Server logout failed with status: ${res.statusCode}');
      }
    } catch (e) {
      // ignore: avoid_print
      print('Error calling API logout: $e');
    }
  }

  Future<User> fetchUser() async {
    try {
      final uri = Uri.parse('${_baseUrl}auth/user');
      final headers = await _getAuthHeaders();
      _debugRequest('FETCH_USER', uri, headers, null);
      final res = await http.get(uri, headers: headers);
      _debugResponse('FETCH_USER', res);

      if (res.statusCode == 200 && _isJsonResponse(res)) {
        final json = _tryDecodeJson(res.body);
        if (json is Map<String, dynamic>) return User.fromJson(json);
        throw Exception('Respon user bukan JSON.');
      } else if (res.statusCode == 401) {
        throw Exception('Unauthorized');
      }
      throw Exception('Gagal mengambil data user. Status: ${res.statusCode}');
    } catch (e) {
      throw Exception('Gagal mengambil data user: ${e.toString()}');
    }
  }

  /* ======================= WORKSHOP ======================= */
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
      final body = jsonEncode({
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
      final res = await http.post(uri, headers: headers, body: body);
      _debugResponse('CREATE_WORKSHOP', res);

      if (res.statusCode == 201 && _isJsonResponse(res)) {
        final json = _tryDecodeJson(res.body);
        if (json is Map<String, dynamic>) return Workshop.fromJson(json);
        throw Exception('Respon create workshop bukan JSON.');
      }
      final json = _tryDecodeJson(res.body);
      if (json is Map && json['errors'] != null) {
        final firstError = (json['errors'] as Map).values.first[0];
        throw Exception(firstError);
      }
      if (json is Map && json['message'] != null) throw Exception(json['message']);
      throw Exception('Gagal membuat bengkel (HTTP ${res.statusCode}).');
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
      final body = jsonEncode({'workshop_uuid': workshopUuid, 'nib': nib, 'npwp': npwp});
      _debugRequest('CREATE_DOCUMENT', uri, headers, body);
      final res = await http.post(uri, headers: headers, body: body);
      _debugResponse('CREATE_DOCUMENT', res);

      if (res.statusCode == 201 && _isJsonResponse(res)) {
        final json = _tryDecodeJson(res.body);
        if (json is Map<String, dynamic>) return WorkshopDocument.fromJson(json);
        throw Exception('Respon create document bukan JSON.');
      }
      final json = _tryDecodeJson(res.body);
      if (json is Map && json['errors'] != null) {
        final firstError = (json['errors'] as Map).values.first[0];
        throw Exception(firstError);
      }
      if (json is Map && json['message'] != null) throw Exception(json['message']);
      throw Exception('Gagal menyimpan dokumen (HTTP ${res.statusCode}).');
    } catch (e) {
      throw Exception('Gagal menyimpan dokumen: ${e.toString().replaceFirst("Exception: ", "")}');
    }
  }

  /* ======================= EMPLOYEE ======================= */
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

      final bodyMap = <String, dynamic>{
        'name': name.trim(),
        'username': username.trim(),
        'email': email.trim(),
        'password': password,
        'password_confirmation': passwordConfirmation,
        'role': role,
        'workshop_uuid': workshopUuid,
        if (specialist != null && specialist.trim().isNotEmpty) 'specialist': _sanitize(specialist),
        if (jobdesk != null && jobdesk.trim().isNotEmpty) 'jobdesk': _sanitize(jobdesk),
      };
      final body = jsonEncode(bodyMap);

      _debugRequest('CREATE_EMPLOYEE', uri, headers, body);
      final res = await http.post(uri, headers: headers, body: body);
      _debugResponse('CREATE_EMPLOYEE', res);

      final ok = res.statusCode == 200 || res.statusCode == 201;
      if (!ok) {
        if (_isJsonResponse(res)) {
          final j = _tryDecodeJson(res.body);
          if (j is Map && j['errors'] != null) {
            final firstError = (j['errors'] as Map).values.first[0];
            throw Exception(firstError);
          }
          if (j is Map && j['message'] != null) throw Exception(j['message']);
        }
        throw Exception('Gagal membuat karyawan (HTTP ${res.statusCode}). Body: ${_firstChars(res.body)}');
      }

      if (!_isJsonResponse(res)) throw Exception('Server mengembalikan non-JSON.');
      final decoded = _tryDecodeJson(res.body);

      final map = (decoded is Map<String, dynamic> && decoded['data'] is Map<String, dynamic>)
          ? decoded['data'] as Map<String, dynamic>
          : decoded as Map<String, dynamic>;

      return Employment.fromJson(map);
    } catch (e) {
      throw Exception('Gagal membuat karyawan: ${e.toString().replaceFirst("Exception: ", "")}');
    }
  }

  Future<List<Employment>> fetchOwnerEmployees() async {
    try {
      final uri = Uri.parse('${_baseUrl}owners/employee');
      final headers = await _getAuthHeaders();
      _debugRequest('FETCH_EMPLOYEES', uri, headers, null);

      final res = await http.get(uri, headers: headers);
      _debugResponse('FETCH_EMPLOYEES', res);

      if (res.statusCode == 401) {
        throw Exception('Akses ditolak. Silakan login kembali.');
      }
      final ok = res.statusCode == 200 || res.statusCode == 201;
      if (!ok) throw Exception('Gagal mengambil data employee. Status: ${res.statusCode}');
      if (!_isJsonResponse(res)) throw Exception('Respon bukan JSON.');

      final decoded = _tryDecodeJson(res.body);

      final listJson = decoded is List
          ? decoded
          : (decoded is Map<String, dynamic> ? (decoded['data'] ?? []) : []);

      if (listJson is! List) return <Employment>[];

      return listJson.whereType<Map<String, dynamic>>().map((e) => Employment.fromJson(e)).toList();
    } catch (e) {
      throw Exception('Gagal mengambil data employee: ${e.toString().replaceFirst("Exception: ", "")}');
    }
  }

  Future<Employment> updateEmployee(
      String id, {
        String? name,
        String? username,
        String? email,
        String? password,
        String? passwordConfirmation,
        String? role,
        String? specialist,
        String? jobdesk,
        String? status, // 'active' / 'inactive'
      }) async {
    try {
      final uri = Uri.parse('${_baseUrl}owners/employee/$id');
      final headers = await _getAuthHeaders();

      final map = <String, dynamic>{};
      if (name != null) map['name'] = name;
      if (username != null) map['username'] = username;
      if (email != null) map['email'] = email;
      if (password != null) map['password'] = password;
      if (passwordConfirmation != null) map['password_confirmation'] = passwordConfirmation;
      if (role != null) map['role'] = role;
      if (specialist != null) map['specialist'] = _sanitize(specialist);
      if (jobdesk != null) map['jobdesk'] = _sanitize(jobdesk);
      if (status != null) map['status'] = status;

      final body = jsonEncode(map);

      _debugRequest('UPDATE_EMPLOYEE', uri, headers, body);
      final res = await http.put(uri, headers: headers, body: body);
      _debugResponse('UPDATE_EMPLOYEE', res);

      if (!(res.statusCode == 200 || res.statusCode == 201)) {
        final j = _tryDecodeJson(res.body);
        if (j is Map && j['errors'] != null) {
          final firstError = (j['errors'] as Map).values.first[0];
          throw Exception(firstError);
        }
        if (j is Map && j['message'] != null) throw Exception(j['message']);
        throw Exception('Gagal update karyawan (HTTP ${res.statusCode}).');
      }
      if (!_isJsonResponse(res)) throw Exception('Respon update bukan JSON.');
      final j = _tryDecodeJson(res.body);
      if (j is! Map<String, dynamic>) throw Exception('Respon update bukan objek JSON.');
      return Employment.fromJson(j);
    } catch (e) {
      throw Exception('Gagal update karyawan: ${e.toString().replaceFirst("Exception: ", "")}');
    }
  }

  Future<void> updateEmployeeStatus(String id, String status) async {
    try {
      final uri = Uri.parse('${_baseUrl}owners/employee/$id/status');
      final headers = await _getAuthHeaders();
      final body = jsonEncode({'status': status});
      _debugRequest('UPDATE_EMP_STATUS', uri, headers, body);
      final res = await http.patch(uri, headers: headers, body: body);
      _debugResponse('UPDATE_EMP_STATUS', res);

      if (!(res.statusCode == 200 || res.statusCode == 204)) {
        final j = _tryDecodeJson(res.body);
        if (j is Map && j['message'] != null) throw Exception(j['message']);
        throw Exception('Gagal mengubah status (HTTP ${res.statusCode}).');
      }
    } catch (e) {
      throw Exception('Gagal mengubah status: ${e.toString().replaceFirst("Exception: ", "")}');
    }
  }

  Future<void> deleteEmployee(String id) async {
    try {
      final uri = Uri.parse('${_baseUrl}owners/employee/$id');
      final headers = await _getAuthHeaders();
      _debugRequest('DELETE_EMPLOYEE', uri, headers, null);
      final res = await http.delete(uri, headers: headers);
      _debugResponse('DELETE_EMPLOYEE', res);

      if (res.statusCode != 204) {
        final j = _tryDecodeJson(res.body);
        if (j is Map && j['message'] != null) throw Exception(j['message']);
        throw Exception('Gagal menghapus karyawan (HTTP ${res.statusCode}).');
      }
    } catch (e) {
      throw Exception('Gagal menghapus karyawan: ${e.toString().replaceFirst("Exception: ", "")}');
    }
  }

  /* ======================== SERVICES ======================= */

  /// GET /services  (support query status, include extras)
  Future<List<ServiceModel>> fetchServices({
    String? status,             // 'pending' | 'accept' | 'in progress' | 'completed' | 'cancelled'
    bool includeExtras = true,  // minta backend kirim relasi (customer/vehicle/workshop)
    String? workshopUuid,
    String? code,
    String? dateFrom,           // 'YYYY-MM-DD'
    String? dateTo,             // 'YYYY-MM-DD'
  }) async {
    try {
      final params = <String, String>{};
      if (includeExtras) params['include'] = 'extras';
      if (status != null && status.isNotEmpty) params['status'] = status;
      if (workshopUuid != null && workshopUuid.isNotEmpty) params['workshop_uuid'] = workshopUuid;
      if (code != null && code.isNotEmpty) params['code'] = code;
      if (dateFrom != null && dateFrom.isNotEmpty) params['date_from'] = dateFrom;
      if (dateTo != null && dateTo.isNotEmpty) params['date_to'] = dateTo;

      final uri = Uri.parse('${_baseUrl}owners/services').replace(queryParameters: params);
      final headers = await _getAuthHeaders();

      _debugRequest('FETCH_SERVICES', uri, headers, null);
      final res = await http.get(uri, headers: headers);
      _debugResponse('FETCH_SERVICES', res);

      if (!(res.statusCode == 200 || res.statusCode == 201)) {
        final j = _tryDecodeJson(res.body);
        if (j is Map && j['message'] != null) throw Exception(j['message']);
        throw Exception('Gagal mengambil data service (HTTP ${res.statusCode}).');
      }
      if (!_isJsonResponse(res)) throw Exception('Respon bukan JSON.');

      final j = _tryDecodeJson(res.body);

      // backend kamu kadang return {data: [...]} atau langsung [...], cover dua-duanya
      final list = (j is Map && j['data'] is List)
          ? (j['data'] as List)
          : (j is List ? j : const []);

      return list.whereType<Map<String, dynamic>>().map(ServiceModel.fromJson).toList();
    } catch (e) {
      throw Exception('Gagal mengambil data service: ${e.toString().replaceFirst("Exception: ", "")}');
    }
  }

  /// GET /services/{id}
  Future<ServiceModel> fetchServiceDetail(String id) async {
    try {
      final uri = Uri.parse('${_baseUrl}owners/services/$id');
      final headers = await _getAuthHeaders();

      _debugRequest('SERVICE_DETAIL', uri, headers, null);
      final res = await http.get(uri, headers: headers);
      _debugResponse('SERVICE_DETAIL', res);

      if (!(res.statusCode == 200 || res.statusCode == 201)) {
        final j = _tryDecodeJson(res.body);
        if (j is Map && j['message'] != null) throw Exception(j['message']);
        throw Exception('Gagal mengambil detail service (HTTP ${res.statusCode}).');
      }
      if (!_isJsonResponse(res)) throw Exception('Respon bukan JSON.');

      final j = _tryDecodeJson(res.body);
      final map = (j is Map && j['data'] is Map)
          ? Map<String, dynamic>.from(j['data'])
          : Map<String, dynamic>.from(j as Map);

      return ServiceModel.fromJson(map);
    } catch (e) {
      throw Exception('Gagal mengambil detail service: ${e.toString().replaceFirst("Exception: ", "")}');
    }
  }

  /// PATCH /services/{id}  body: { status: '...' }
  Future<void> updateServiceStatus(String id, String status) async {
    try {
      final uri = Uri.parse('${_baseUrl}owners/services/$id');
      final headers = await _getAuthHeaders();
      final body = jsonEncode({'status': status});

      _debugRequest('UPDATE_SERVICE', uri, headers, body);
      final res = await http.patch(uri, headers: headers, body: body);
      _debugResponse('UPDATE_SERVICE', res);

      if (!(res.statusCode == 200 || res.statusCode == 204)) {
        final j = _tryDecodeJson(res.body);
        if (j is Map && j['message'] != null) throw Exception(j['message']);
        throw Exception('Gagal update status (HTTP ${res.statusCode}).');
      }
    } catch (e) {
      throw Exception('Gagal update status: ${e.toString().replaceFirst("Exception: ", "")}');
    }
  }

  /// POST /services  (dummy)
  Future<ServiceModel> createServiceDummy({
    required String workshopUuid,
    String? customerUuid,
    String? vehicleUuid,            // <— sesuai backend: vehicle_uuid
    required String name,
    String? description,
    num? price,
    required DateTime scheduledDate,
    DateTime? estimatedTime,
    String status = 'pending',
  }) async {
    try {
      final uri = Uri.parse('${_baseUrl}owners/services');
      final headers = await _getAuthHeaders();
      final body = jsonEncode({
        'workshop_uuid': workshopUuid,
        if (customerUuid != null) 'customer_uuid': customerUuid,
        if (vehicleUuid != null) 'vehicle_uuid': vehicleUuid,
        'name': name,
        'description': description,
        'price': price,
        'scheduled_date': scheduledDate.toIso8601String(),
        if (estimatedTime != null) 'estimated_time': estimatedTime.toIso8601String(),
        'status': status,
      });

      _debugRequest('CREATE_SERVICE', uri, headers, body);
      final res = await http.post(uri, headers: headers, body: body);
      _debugResponse('CREATE_SERVICE', res);

      if (!(res.statusCode == 200 || res.statusCode == 201)) {
        final j = _tryDecodeJson(res.body);
        if (j is Map && j['errors'] != null) {
          final firstError = (j['errors'] as Map).values.first[0];
          throw Exception(firstError);
        }
        if (j is Map && j['message'] != null) throw Exception(j['message']);
        throw Exception('Gagal membuat service (HTTP ${res.statusCode}).');
      }

      if (!_isJsonResponse(res)) throw Exception('Respon bukan JSON.');
      final j = _tryDecodeJson(res.body);
      final map = (j is Map && j['data'] is Map)
          ? j['data'] as Map<String, dynamic>
          : j as Map<String, dynamic>;

      return ServiceModel.fromJson(map);
    } catch (e) {
      throw Exception('Gagal membuat service: ${e.toString().replaceFirst("Exception: ", "")}');
    }
  }
}
