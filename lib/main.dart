import 'package:flutter/material.dart';
import 'package:bengkel_online_flutter/screens/register.dart';
import 'package:bengkel_online_flutter/screens/login.dart';
import 'package:bengkel_online_flutter/screens/service_page.dart';
import 'package:bengkel_online_flutter/widgets/bottom_nav.dart';
import 'package:bengkel_online_flutter/screens/homepage.dart';

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

/// ini class baru, posisinya di luar MyApp
class MainPage extends StatefulWidget {
  const MainPage({super.key});

  @override
  State<MainPage> createState() => _MainPageState();
}

class _MainPageState extends State<MainPage> {
  int _selectedIndex = 0;

  final List<Widget> _pages = [
    const HomePage(),
    const ServicePage(),
    // const DashboardPage(), // tambahkan halaman Dashboard
    // const ProfilePage(),   // tambahkan halaman Profile
    Container(
      color: Colors.blue,
      child: const Center(child: Text('Dashboard Page')),
    ), // Placeholder for Dashboard
    Container(
      color: Colors.green,
      child: const Center(child: Text('Profile Page')),
    ), // Placeholder for Profile
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(index: _selectedIndex, children: _pages),
      bottomNavigationBar: CustomBottomNavBar(
        selectedIndex: _selectedIndex,
        onTap: _onItemTapped,
      ),
    );
  }
}
