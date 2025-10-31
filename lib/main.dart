import 'package:bengkel_online_flutter/core/services/auth_provider.dart';
import 'package:bengkel_online_flutter/feature/mechanic/widgets/bottom_navbar.dart';
import 'package:bengkel_online_flutter/feature/owner/providers/employee_provider.dart';
import 'package:provider/provider.dart';
import 'package:flutter/material.dart';

// OWNER
import 'feature/owner/widgets/bottom_nav_owner.dart';
import 'feature/owner/screens/homepageOwner.dart';
import 'feature/owner/screens/staffManagement.dart';
import 'feature/owner/screens/reportPages.dart';
import 'feature/owner/screens/profilpage_owner.dart' as owner_profil;
import 'feature/owner/screens/listWork.dart';

// ADMIN
import 'feature/admin/widgets/bottom_nav.dart';
import 'feature/admin/screens/homepage.dart';
import 'feature/admin/screens/service_page.dart' as admin;
import 'feature/admin/screens/dashboard.dart';
import 'feature/admin/screens/profilpage.dart' as admin_profil;
import 'feature/admin/screens/change_password.dart' as change_screen;

// MECHANIC
import 'feature/mechanic/screens/homepageMechanic.dart';
import 'feature/mechanic/screens/service_pagemechanic.dart' as mechanic;
import 'feature/mechanic/screens/profil_page.dart' as mechanic_profil;

// AUTH / REGISTER
import 'core/screens/login.dart' as login_screen;
import 'core/screens/registers/registerOwner.dart';
import 'core/screens/registeruser.dart';
import 'core/screens/register.dart';
import 'core/screens/registerBengkel.dart';
import 'feature/owner/screens/onBoarding.dart';

// Gates
import 'core/screens/loading_gate.dart';      // /gate
import 'core/screens/splash_screen.dart';     // /splash -> first launch gate

void main() {
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthProvider()),
        ChangeNotifierProvider(create: (_) => EmployeeProvider()),
      ],
      child: const MyApp(),
    ),
  );
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
        textTheme: const TextTheme().apply(
          bodyColor: Colors.black,
          displayColor: Colors.black,
        ),
      ),
      initialRoute: "/splash",
      routes: {
        "/splash": (context) => const SplashScreen(),

        // Onboarding & Auth
        "/onboarding": (context) => const OnboardingScreen(),
        "/login": (context) => const login_screen.LoginPage(),

        // Setelah login/register, masuk ke gate ini
        "/gate": (context) => const LoadingGate(),

        // Role-aware entry
        "/main": (context) => const RoleEntry(),

        // Lainnya
        "/home": (context) => const DashboardScreen(),
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

/// Membaca role dari AuthProvider lalu render MainPage(role)
class RoleEntry extends StatelessWidget {
  const RoleEntry({super.key});

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();
    final role = auth.user?.role ?? 'guest';

    if (!auth.isLoggedIn || role == 'guest') {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (Navigator.canPop(context)) {
          Navigator.popAndPushNamed(context, '/login');
        } else {
          Navigator.pushReplacementNamed(context, '/login');
        }
      });
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }
    return MainPage(role: role);
  }
}

/// Halaman utama sesuai role
class MainPage extends StatefulWidget {
  final String role;
  const MainPage({super.key, required this.role});

  @override
  State<MainPage> createState() => _MainPageState();
}

class _MainPageState extends State<MainPage> {
  int _selectedIndex = 0;
  void _onItemTapped(int index) => setState(() => _selectedIndex = index);

  @override
  Widget build(BuildContext context) {
    late final List<Widget> pages;
    late final Widget bottomNavBar;

    switch (widget.role) {
      case "owner":
        pages = [
          DashboardScreen(),
          const ManajemenKaryawanPage(),
          const ReportPage(),
          owner_profil.ProfilePageOwner(),
        ];
        bottomNavBar = CustomBottomNavBarOwner(
          selectedIndex: _selectedIndex,
          onTap: _onItemTapped,
        );
        break;

      case "mechanic":
        pages = [
          HomePageMechanic(),
          mechanic.ServicePageMechanic(),
          mechanic_profil.ProfilePageMechanic(),
        ];
        bottomNavBar = CustomBottomNavBarMechanic(
          selectedIndex: _selectedIndex,
          onTap: _onItemTapped,
        );
        break;

      case "admin":
        pages = [
          HomePage(),
          admin.ServicePageAdmin(),
          const DashboardPage(),
          admin_profil.ProfilePageAdmin(),
        ];
        bottomNavBar = CustomBottomNavBarAdmin(
          selectedIndex: _selectedIndex,
          onTap: _onItemTapped,
        );
        break;

      default:
        WidgetsBinding.instance.addPostFrameCallback((_) {
          Navigator.pushReplacementNamed(context, '/login');
        });
        return const Scaffold(
          body: Center(child: CircularProgressIndicator()),
        );
    }

    return Scaffold(
      body: IndexedStack(index: _selectedIndex, children: pages),
      bottomNavigationBar: bottomNavBar,
    );
  }
}
