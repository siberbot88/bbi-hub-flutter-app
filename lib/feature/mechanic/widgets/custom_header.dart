import 'package:flutter/material.dart';
import 'package:bengkel_online_flutter/feature/mechanic/widgets/bottom_navbar.dart';
import 'package:bengkel_online_flutter/feature/mechanic/screens/servicePage.dart';
import 'package:bengkel_online_flutter/feature/mechanic/screens/profil_page.dart';
import 'package:bengkel_online_flutter/feature/mechanic/screens/homepageMechanic.dart'; // isi utama halaman Home kamu

class HomePageMechanic extends StatefulWidget {
  const HomePageMechanic({super.key});

  @override
  State<HomePageMechanic> createState() => _HomePageMechanicState();
}

class _HomePageMechanicState extends State<HomePageMechanic> {
  int _selectedIndex = 0;

  // ⬇️ Daftar halaman tanpa AppBar
  final List<Widget> _pages = [
    const HomeScreenWithHeader(), // hanya halaman ini yang punya CustomHeader
    const ServiceLoggingPage_(),
    const ProfilePage(),
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _pages[_selectedIndex],
      bottomNavigationBar: CustomBottomNavBar(
        selectedIndex: _selectedIndex,
        onTap: _onItemTapped,
      ),
    );
  }
}

/// 🏠 Halaman Home dengan CustomHeader di atas
class HomeScreenWithHeader extends StatelessWidget {
  const HomeScreenWithHeader({super.key});

  @override
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Dashboard Mekanik"),
        centerTitle: true,
        automaticallyImplyLeading:
            false, // hilangkan tombol back di halaman utama
      ),
      body: const Center(child: Text('Dashboard Mekanik')),
    );
  }
}
