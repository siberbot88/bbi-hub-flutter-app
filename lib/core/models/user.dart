import 'package:bengkel_online_flutter/core/models/employment.dart';
import 'package:bengkel_online_flutter/core/models/workshop.dart';

class User {
  final String id;
  final String name;
  final String username;
  final String email;
  final String? photo;
  final String role;
  final List<Workshop>? workshops;
  final Employment? employment;
  final bool mustChangePassword;

  User({
    required this.id,
    required this.name,
    required this.username,
    required this.email,
    this.photo,
    required this.role,
    this.workshops,
    this.employment,
    this.mustChangePassword = false,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    String userRole = 'user';
    if (json['roles'] is List && (json['roles'] as List).isNotEmpty) {
      final first = (json['roles'] as List).first;
      if (first is Map && first['name'] is String) {
        userRole = first['name'] as String;
      }
    }

    // Parsing workshops
    List<Workshop>? parsedWorkshops;
    if (json['workshops'] is List) {
      try {
        parsedWorkshops = (json['workshops'] as List)
            .whereType<Map<String, dynamic>>()
            .map(Workshop.fromJson)
            .toList();
      } catch (_) {
        parsedWorkshops = null;
      }
    } else if (json['workshops'] == null) {
      parsedWorkshops = null;
    }

    // Parsing employment
    Employment? parsedEmployment;
    if (json['employment'] is Map<String, dynamic>) {
      try {
        parsedEmployment =
            Employment.fromJson(json['employment'] as Map<String, dynamic>);
      } catch (_) {
        parsedEmployment = null;
      }
    }

    // Parse must_change_password dengan aman dari beberapa kemungkinan tipe
    bool _parseMustChange(dynamic v) {
      if (v is bool) return v;
      if (v is num) return v == 1;
      if (v is String) {
        final s = v.trim().toLowerCase();
        return s == '1' || s == 'true' || s == 'yes';
      }
      return false;
    }

    return User(
      id: (json['id'] ?? '').toString(),
      name: (json['name'] ?? '').toString(),
      username: (json['username'] ?? '').toString(),
      email: (json['email'] ?? '').toString(),
      photo: json['photo']?.toString(),
      role: userRole,
      workshops: parsedWorkshops,
      employment: parsedEmployment,
      mustChangePassword:
      _parseMustChange(json['must_change_password'] ?? json['mustChangePassword']),
    );
  }

  bool hasRole(String roleName) => role == roleName;
}
