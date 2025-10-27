import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:bengkel_online_flutter/core/services/api_service.dart';
import 'package:bengkel_online_flutter/core/models/user.dart';


class AuthProvider with ChangeNotifier {
  // --- STATE INTERNAL ---
  final ApiService _apiService = ApiService();
  final _storage = const FlutterSecureStorage();

  User? _user;
  String? _token;
  bool _isLoggedIn = false;
  String? _authError;

  // --- GETTERS (Untuk dibaca oleh UI) ---
  User? get user => _user;
  bool get isLoggedIn => _isLoggedIn;
  String? get token => _token;
  String? get authError => _authError;

  Future<bool> register({
    required String name,
    required String username,
    required String email,
    required String password,
    required String passwordConfirmation,
  }) async {
    _authError = null;
    try {
      final response = await _apiService.register(
        name: name,
        username: username,
        email: email,
        password: password,
        passwordConfirmation: passwordConfirmation,
      );

      // Jika register sukses, API Laravel mengembalikan token dan user
      _token = response['access_token'];
      _user = User.fromJson(response['user']);
      _isLoggedIn = true;

      // Simpan token dengan aman
      await _storage.write(key: 'auth_token', value: _token);

      notifyListeners();
      return true;

    } catch (e) {
      _isLoggedIn = false;
      _authError = e.toString().replaceFirst("Exception: ", "");
      notifyListeners();
      throw Exception(_authError);
    }
  }

  Future<bool> login(String email, String password) async {
    _authError = null; // Reset error
    try {
      final response = await _apiService.login(email, password);

      _token = response['access_token'];
      _user = User.fromJson(response['user']);
      _isLoggedIn = true;

      await _storage.write(key: 'auth_token', value: _token);
      notifyListeners();
      return true;

    } catch (e) {
      _isLoggedIn = false;
      _authError = e.toString().replaceFirst("Exception: ", "");
      notifyListeners();
      throw Exception(_authError);
    }
  }

  Future<void> logout() async {
    try {
      if (_token != null) {
        await _apiService.logout();
      }
    } catch (e) {
      print("Error calling API logout (ignored): $e");
    }

    _token = null;
    _user = null;
    _isLoggedIn = false;
    _authError = null;
    await _storage.delete(key: 'auth_token');

    notifyListeners();
  }

  Future<void> checkLoginStatus() async {
    String? storedToken = await _storage.read(key: 'auth_token');

    if (storedToken == null) {
      _isLoggedIn = false;
      notifyListeners();
      return;
    }

    _token = storedToken;
    try {
      final fetchedUser = await _apiService.fetchUser();
      _user = fetchedUser;
      _isLoggedIn = true;
      _authError = null;
      notifyListeners();

    } catch (e) {
      print("checkLoginStatus failed: ${e.toString()}");
      await logout();
    }
  }
}

