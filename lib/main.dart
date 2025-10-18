import 'package:bengkel_online_flutter/core/screens/registers/registerOwner.dart';
import 'package:bengkel_online_flutter/feature/owner/screens/reportPages.dart';
import 'package:bengkel_online_flutter/feature/owner/screens/staffManagement.dart';
import 'package:flutter/material.dart';
import 'feature/admin/screens/profilpage.dart';
import 'feature/owner/widgets/bottom_nav_owner.dart';
import 'feature/owner/screens/homepageOwner.dart';
import 'feature/admin/screens/dashboard.dart';
import 'core/screens/login.dart'as login_screen;
import 'feature/admin/screens/change_password.dart' as change_screen;
import 'feature/admin/screens/service_page.dart';
import 'feature/owner/screens/onBoarding.dart';

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
        ).apply(bodyColor: Colors.black, displayColor: Colors.black),
      ),
      // 🔹 halaman pertama aplikasi
      initialRoute: "/onboarding",

      // 🔹 daftar route
      routes: {
        "/onboarding": (context) => const OnboardingScreen(),
        "/login": (context) => const login_screen.LoginPage(),
        "/register": (context) => const RegisterFlowPage(),
        "/home": (context) => const DashboardScreen(),
        "/main": (context) => const MainPage(),
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
    DashboardScreen(),
    ManajemenKaryawanPage(),
    ReportPage(),
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
