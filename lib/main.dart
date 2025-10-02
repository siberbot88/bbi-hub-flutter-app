import 'package:flutter/material.dart';
import 'package:bengkel_online_flutter/screens/registeruser.dart';
import 'package:bengkel_online_flutter/screens/registeruser.dart';
import 'package:bengkel_online_flutter/screens/service_page.dart';
import 'package:bengkel_online_flutter/widgets/bottom_nav.dart';
import 'package:bengkel_online_flutter/screens/homepage.dart';
import 'package:bengkel_online_flutter/screens/profilpage.dart';
import 'package:bengkel_online_flutter/screens/dashboard.dart';
import 'package:bengkel_online_flutter/screens/login.dart'as login_screen;
import 'package:bengkel_online_flutter/screens/register.dart';
import 'package:bengkel_online_flutter/screens/registerBengkel.dart';
import 'package:bengkel_online_flutter/screens/change_password.dart' as change_screen;


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
        fontFamily: 'Poppins',
        textTheme: TextTheme(
          bodyLarge: TextStyle(),
          bodyMedium: TextStyle(),
          displayLarge: TextStyle(),
          displayMedium: TextStyle(),
          displaySmall: TextStyle(),
      ).apply(
          bodyColor: Colors.black, displayColor: Colors.black),
      ),
      // 🔹 halaman pertama aplikasi
      initialRoute: "/login",

      // 🔹 daftar route
      title: 'BBI HUB PLUS',
      theme: ThemeData(
        primarySwatch: Colors.red,
      ),
      // 🔹 halaman pertama aplikasi
      initialRoute: "/login",

      // 🔹 daftar route
      title: 'BBI HUB PLUS',
      theme: ThemeData(
        primarySwatch: Colors.red,
      ),
      // 🔹 halaman pertama aplikasi
      initialRoute: "/login",

      // 🔹 daftar route
      routes: {
        "/login": (context) => const login_screen.LoginPage(),
        "/home": (context) =>
            const MainPage(), //
        "/register": (context) => const RegisterRoleScreen(),
        "/registerBengkel": (context) => const RegisterBengkelScreen(),
        "/changePassword": (context) => const change_screen.ChangePasswordPage(),
      },
    );
  }
}

/// Halaman utama dengan BottomNavigation + IndexedStack
class MainPage extends StatefulWidget {
  const MainPage({super.key});

  @override
  State<MainPage> createState() => _MainPageState();
}

class _MainPageState extends State<MainPage> {
  int _selectedIndex = 0;

  // Pastikan urutan sesuai dengan CustomBottomNavBar
  final List<Widget> _pages =  [
    HomePage(),
    ServicePage(),
    DashboardPage(),
    ProfilePage(),
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(
        index: _selectedIndex,
        children: _pages,
      ),
      bottomNavigationBar: CustomBottomNavBar(
        selectedIndex: _selectedIndex,
        onTap: _onItemTapped,
      ),
    );
  }
}
