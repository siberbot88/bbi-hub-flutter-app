import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:bengkel_online_flutter/core/models/user.dart';

class ApiService {
  static const String _baseUrl = 'http://10.0.2.2:8000/api/v1/';

  final _storage = const FlutterSecureStorage();

  Future<String?> _getToken() async {
    return await _storage.read(key: 'auth_token');
  }

  Future<Map<String, String>> _getAuthHeaders() async {
    String? token = await _getToken();
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


  Future<Map<String, dynamic>> login(String email, String password) async {
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
      try {
        final error = jsonDecode(response.body);
        throw Exception(error['message'] ?? 'Login gagal');
      } catch (e) {
        throw Exception('Gagal login. Status: ${response.statusCode}');
      }
    }
  }

  Future<Map<String, dynamic>> register({
    required String name,
    required String username,
    required String email,
    required String password,
    required String passwordConfirmation,
  }) async {
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
      throw Exception(error['message'] ?? 'Registrasi gagal');
    }
  }

  Future<void> logout() async {
    try {
      final response = await http.post(
        Uri.parse('${_baseUrl}auth/logout'),
        headers: await _getAuthHeaders(),
      );

      if (response.statusCode != 200) {
        throw Exception('Gagal logout di server');
      }
    } catch (e) {
      print('Error saat logout: $e');
    }
  }


  Future<User> fetchUser() async {
    final response = await http.get(
      Uri.parse('${_baseUrl}auth/user'),
      headers: await _getAuthHeaders(),
    );

    if (response.statusCode == 200) {
      return User.fromJson(jsonDecode(response.body));
    } else if (response.statusCode == 401) {
      throw Exception('Unauthorized');
    } else {
      throw Exception('Gagal mengambil data user');
    }
  }

  Future<List<dynamic>> fetchOwnerEmployees() async {
    final response = await http.get(
      Uri.parse('${_baseUrl}owners/employee'),
      headers: await _getAuthHeaders(),
    );

    if (response.statusCode == 200) {
      return jsonDecode(response.body) as List;
    } else if (response.statusCode == 401) {
      throw Exception('Akses ditolak. Silakan login kembali.');
    } else {
      throw Exception('Gagal mengambil data employee');
    }
  }
}