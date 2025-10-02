import 'package:flutter/material.dart';
import 'package:bengkel_online_flutter/screens/register.dart';
import 'package:bengkel_online_flutter/screens/login.dart';
import 'package:bengkel_online_flutter/screens/service_page.dart';
import 'package:bengkel_online_flutter/widgets/bottom_nav.dart';
import 'package:bengkel_online_flutter/screens/homepage.dart';
import 'package:bengkel_online_flutter/screens/profilpage.dart';
import 'package:bengkel_online_flutter/screens/dashboard.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'BBI HUB PLUS',
      debugShowCheckedModeBanner: false,
      initialRoute: '/login',
      routes: {
        '/register': (context) => const RegisterScreen(),
        '/login': (context) => const LoginScreen(),
        '/home': (context) => const MainPage(), // arahkan ke MainPage
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
  final List<Widget> _pages = const [
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
