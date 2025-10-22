import 'core/screens/registeruser.dart';
import 'package:flutter/material.dart';
import 'feature/admin/screens/profilpage.dart';
import 'feature/admin/widgets/bottom_nav.dart';
import 'feature/admin/screens/homepage.dart';
import 'feature/admin/screens/dashboard.dart';
import 'core/screens/login.dart'as login_screen;
import 'core/screens/register.dart';
import 'core/screens/registerBengkel.dart';
import 'feature/admin/screens/change_password.dart' as change_screen;
import 'feature/admin/screens/service_page.dart';
import 'feature/mechanic/screens/homepageMechanic.dart';
import 'feature/owner/screens/homepageOwner.dart';


void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {

    // sementara: simulasi role user
    const String currentRole = "admin"; // admin | owner | mechanic

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
      routes: {
        "/login": (context) => const login_screen.LoginPage(),
        "/home": (context) =>
            const MainPage(role:currentRole), //
        "/register": (context) => const RegisterRoleScreen(),
        "/registerBengkel": (context) => const RegisterBengkelScreen(),
        "/registeruser": (context) => const RegisterScreen(),
        "/dashboard": (context) => const DashboardPage(),
        "/changePassword": (context) => const change_screen.ChangePasswordPage(),

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
    // 🔸 Pilih halaman sesuai role
    late final List<Widget> pages;
    switch (widget.role) {
      case "owner":
        pages = [
           HomePageOwner(),
           Placeholder(), // nanti ganti OrderPage()
           Placeholder(), // ProfileOwnerPage()
        ];
        break;

      case "mechanic":
        pages = [
           HomePageMechanic(),
           Placeholder(), // TaskPage()
           Placeholder(), // ProfileMechanicPage()
        ];
        break;

      default: // admin
        pages = [
          const HomePage(),
          const ServicePage(),
          const DashboardPage(),
          const ProfilePage(),
        ];
    }

    // 🔸 Bottom Navigation Bar sesuai role
    Widget bottomNavBar;
    switch (widget.role) {
      case "owner":
        bottomNavBar = CustomBottomNavBar(
          selectedIndex: _selectedIndex,
          onTap: _onItemTapped,
        );
        break;
      case "mechanic":
        bottomNavBar = CustomBottomNavBar(
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
      // case "mechanic":
      //   bottomNavBar = CustomBottomNavBar(
      //     selectedIndex: _selectedIndex,
      //     onTap: _onItemTapped,
      //   );
      //   break;
      default:
        bottomNavBar = CustomBottomNavBar(
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

  // @override
  // Widget build(BuildContext context) {
  //   return Scaffold(
  //     body: IndexedStack(
  //       index: _selectedIndex,
  //       children: _pages,
  //     ),
  //     bottomNavigationBar: CustomBottomNavBar(
  //       selectedIndex: _selectedIndex,
  //       onTap: _onItemTapped,
  //     ),
  //   );
  // }

