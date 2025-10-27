class User {
  final String id;
  final String name;
  final String username;
  final String email;
  final String role;

  User({
    required this.id,
    required this.name,
    required this.username,
    required this.email,
    required this.role,
  });

  factory User.fromJson(Map<String, dynamic> json) {

    String userRole = 'user';
    if (json['roles'] != null && (json['roles'] as List).isNotEmpty) {
      userRole = json['roles'][0]['name'];
    }

    return User(
      id: json['id'],
      name: json['name'],
      username: json['username'],
      email: json['email'],
      role: userRole,
    );
  }
}