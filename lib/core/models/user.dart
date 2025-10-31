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

  User({
    required this.id,
    required this.name,
    required this.username,
    required this.email,
    this.photo,
    required this.role,
    this.workshops,
    this.employment,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    // Ambil role
    String userRole = 'user';
    if (json['roles'] != null &&
        json['roles'] is List &&
        (json['roles'] as List).isNotEmpty) {
      userRole = json['roles'][0]['name'] ?? 'user';
    }

    // Parsing workshops
    List<Workshop>? parsedWorkshops;
    if (json['workshops'] != null && json['workshops'] is List) {
      var workshopsList = json['workshops'] as List;

      print('--- DEBUG User.fromJson ---');
      print('Ditemukan ${workshopsList.length} workshops di JSON.');
      print('Data mentah workshops: ${json['workshops']}');

      if (workshopsList.isNotEmpty) {
        try {
          parsedWorkshops = workshopsList.map((item) {
            print('Parsing workshop item: $item');
            return Workshop.fromJson(item as Map<String, dynamic>);
          }).toList();

          print('Berhasil mem-parsing ${parsedWorkshops.length} workshops.');
        } catch (e, stack) {
          print('ERROR parsing workshops in User.fromJson: $e');
          print('Stack trace: $stack');
          parsedWorkshops = null;
        }
      } else {
        parsedWorkshops = [];
      }
    } else {
      print('json["workshops"] tidak ditemukan atau bukan List');
    }

    // Parsing employment
    Employment? parsedEmployment;
    if (json['employment'] != null && json['employment'] is Map) {
      try {
        parsedEmployment =
            Employment.fromJson(json['employment'] as Map<String, dynamic>);
      } catch (e) {
        print('Error parsing employment in User.fromJson: $e');
        parsedEmployment = null;
      }
    }

    return User(
      id: json['id'] ?? 'unknown_id',
      name: json['name'] ?? 'Unknown Name',
      username: json['username'] ?? 'unknown_user',
      email: json['email'] ?? 'unknown@mail.com',
      photo: json['photo'],
      role: userRole,
      workshops: parsedWorkshops,
      employment: parsedEmployment,
    );
  }

  bool hasRole(String roleName) {
    return role == roleName;
  }
}
