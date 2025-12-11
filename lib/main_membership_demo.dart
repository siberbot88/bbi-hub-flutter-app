import 'package:flutter/material.dart';
import 'theme/app_theme.dart';
import 'features/membership/presentation/premium_membership_screen.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'BBI HUB Plus - Premium Membership',
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: ThemeMode.system, // Bisa diganti ke light/dark untuk testing
      home: PremiumMembershipScreen(
        onViewMembershipPackages: () {
          // TODO: Navigasi ke halaman daftar paket membership
          // Contoh:
          // Navigator.push(
          //   context,
          //   MaterialPageRoute(
          //     builder: (context) => MembershipPackagesScreen(),
          //   ),
          // );
          debugPrint('🎯 Navigate to Membership Packages');
        },
        onContinueFreeVersion: () {
          // TODO: Navigasi ke halaman utama aplikasi (home/dashboard)
          // Contoh:
          // Navigator.pushReplacementNamed(context, '/home');
          debugPrint('✨ Continue with free version');
        },
      ),
    );
  }
}
