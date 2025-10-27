import 'package:bengkel_online_flutter/core/services/auth_provider.dart';
import 'package:provider/provider.dart';
import 'package:bengkel_online_flutter/core/screens/registers/registerOwner.dart';
import 'package:bengkel_online_flutter/feature/owner/screens/listWork.dart';
import 'package:bengkel_online_flutter/feature/owner/screens/reportPages.dart';
import 'package:bengkel_online_flutter/feature/owner/screens/staffManagement.dart';
import 'package:flutter/material.dart';
import 'feature/admin/screens/profilpage.dart';
import 'feature/owner/widgets/bottom_nav_owner.dart';
import 'feature/owner/screens/homepageOwner.dart';
import 'feature/admin/screens/dashboard.dart';
import 'core/screens/login.dart' as login_screen;
import 'feature/admin/screens/change_password.dart' as change_screen;
import 'feature/admin/screens/profilpage.dart' as admin_profil;
import 'feature/admin/widgets/bottom_nav.dart';
import 'feature/admin/screens/homepage.dart';
import 'feature/admin/screens/service_page.dart' as admin;
import 'feature/owner/screens/onBoarding.dart';
import 'feature/owner/screens/profilpage_owner.dart' as owner_profil;
import 'feature/mechanic/screens/service_pagemechanic.dart' as mechanic;
import 'feature/mechanic/screens/homepageMechanic.dart';
import 'feature/mechanic/widgets/bottom_navbar.dart';
import 'feature/mechanic/screens/profil_page.dart' as mechanic_profil;
import 'package:bengkel_online_flutter/core/screens/registeruser.dart';
import 'package:bengkel_online_flutter/core/screens/register.dart';
import 'package:bengkel_online_flutter/core/screens/registerBengkel.dart';

void main() {
  runApp(
    ChangeNotifierProvider(
      create: (context) => AuthProvider(),
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    const String currentRole = "owner"; // admin | owner | mechanic

    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'BBI HUB PLUS',
      theme: ThemeData(
        primarySwatch: Colors.red,
        fontFamily: 'Poppins',
        textTheme: const TextTheme(
          bodyLarge: TextStyle(),
          bodyMedium: TextStyle(),
          displayLarge: TextStyle(),
          displayMedium: TextStyle(),
          displaySmall: TextStyle(),
        ).apply(bodyColor: Colors.black, displayColor: Colors.black),
      ),

      initialRoute: "/onboarding",

      routes: {
        "/onboarding": (context) => const OnboardingScreen(),
        "/login": (context) => const login_screen.LoginPage(),
        "/home": (context) => const DashboardScreen(),
        "/main": (context) =>
        const MainPage(role: currentRole),
        "/list": (context) => const ListWorkPage(),
        "/changePassword": (context) => const change_screen.ChangePasswordPage(),
        "/register/owner/bengkel": (context) => RegisterBengkelScreen(),
        "/register/user": (context) => RegisterScreen(),
        "/dashboard": (context) => const DashboardPage(),
        "/register/owner": (context) => const RegisterFlowPage(),
      },
    );
  }
}

/// Halaman utama dengan BottomNavigation + IndexedStack
class MainPage extends StatefulWidget {
  final String role; // 🔹 tambahkan parameter role
  const MainPage({super.key, required this.role});

  @override
  State<MainPage> createState() => _MainPageState();
}

class _MainPageState extends State<MainPage> {
  int _selectedIndex = 0;

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    // 🔸 Pilih halaman sesuai role
    late final List<Widget> pages;
    switch (widget.role) {
      case "owner":
        pages = [
          DashboardScreen(),
          ManajemenKaryawanPage(),
          ReportPage(),
          owner_profil.ProfilePageOwner(),
        ];
        break;

      case "mechanic":
        pages = [
          HomePageMechanic(),
          mechanic.ServicePageMechanic(), // TaskPage()
          mechanic_profil.ProfilePageMechanic(), // ProfileMechanicPage()
        ];
        break;

      default: // admin
        pages = [
          HomePage(),
          admin.ServicePageAdmin(),
          DashboardPage(),
          admin_profil.ProfilePageAdmin(),
        ];
    }

    // 🔸 Bottom Navigation Bar sesuai role
    Widget bottomNavBar;
    switch (widget.role) {
      case "owner":
        bottomNavBar = CustomBottomNavBarOwner(
          selectedIndex: _selectedIndex,
          onTap: _onItemTapped,
        );
        break;
      case "admin":
        bottomNavBar = CustomBottomNavBarAdmin(
          selectedIndex: _selectedIndex,
          onTap: _onItemTapped,
        );
        break;
      case "mechanic":
        bottomNavBar = CustomBottomNavBarMechanic(
          selectedIndex: _selectedIndex,
          onTap: _onItemTapped,
        );
        break;
      default:
        bottomNavBar = CustomBottomNavBarAdmin(
          selectedIndex: _selectedIndex,
          onTap: _onItemTapped,
        );
    }

    // 🔸 Scaffold utama
    return Scaffold(
      body: IndexedStack(
        index: _selectedIndex,
        children: pages,
      ),
      bottomNavigationBar: bottomNavBar,
    );
  }
}

