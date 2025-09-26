import 'package:bengkel_online_flutter/screens/homepage.dart';
import 'package:flutter/material.dart';

// 🔹 Import screens
import 'package:bengkel_online_flutter/screens/login.dart';
import 'package:bengkel_online_flutter/screens/register.dart';
import 'package:bengkel_online_flutter/screens/registerBengkel.dart';
import 'package:bengkel_online_flutter/screens/change_password.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'BBI HUB PLUS',
      theme: ThemeData(
        primarySwatch: Colors.red,
      ),
      // 🔹 halaman pertama aplikasi
      initialRoute: "/login",

      // 🔹 daftar route
      routes: {
        "/login": (context) => const LoginPage(),
        "/home": (context) =>
            const HomePage(), // Ganti dengan HomeScreen jika ada
        "/register": (context) => const RegisterRoleScreen(),
        "/registerBengkel": (context) => const RegisterBengkelScreen(),
        "/changePassword": (context) => const ChangePasswordPage(),
      },
    );
  }
}
