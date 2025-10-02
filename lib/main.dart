import 'package:flutter/material.dart';
import 'package:bengkel_online_flutter/screens/landingpage.dart';
import 'package:bengkel_online_flutter/screens/registeruser.dart';
import 'package:bengkel_online_flutter/screens/homepage.dart' as home;
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

      initialRoute: "/landingPage",

      // 🔹 daftar route
      routes: {
        "/landingPage": (context) => LandingPage(),
        "/login": (context) => const LoginPage(),
        "/home": (context) => const home.HomePage(),
        "/register": (context) => const RegisterRoleScreen(),
        "/registerBengkel": (context) => const RegisterBengkelScreen(),
        "/registerUser": (context) => const RegisterScreen(),
        "/changePassword": (context) => const ChangePasswordPage(),
      },
    );
  }
}
