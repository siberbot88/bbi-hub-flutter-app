// Cleaned main.dart without merge conflict markers
import 'dart:async';
import 'package:intl/date_symbol_data_local.dart'; // ✅ Import intl
import 'package:app_links/app_links.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

// Core screens
import 'package:bengkel_online_flutter/core/screens/loading_gate.dart';
import 'package:bengkel_online_flutter/core/screens/login.dart' as login_screen;
import 'package:bengkel_online_flutter/core/screens/registers/register.dart';
import 'package:bengkel_online_flutter/core/screens/splash_screen.dart';
import 'package:bengkel_online_flutter/core/services/auth_provider.dart';
import 'package:bengkel_online_flutter/core/widgets/connectivity_wrapper.dart';

// Auth related screens
import 'package:bengkel_online_flutter/feature/auth/screens/forgot_password_page.dart' as forgot_pass;
import 'package:bengkel_online_flutter/feature/auth/screens/reset_password_page.dart' as reset_pass;
import 'package:bengkel_online_flutter/feature/auth/screens/verify_email_page.dart';
import 'package:bengkel_online_flutter/feature/auth/screens/workshop_waiting_page.dart';

// Admin screens & widgets
import 'package:bengkel_online_flutter/feature/admin/screens/dashboard.dart';
import 'package:bengkel_online_flutter/feature/admin/screens/profil_page.dart' as admin_profil;
import 'package:bengkel_online_flutter/feature/admin/screens/homepage.dart';
import 'package:bengkel_online_flutter/feature/admin/screens/service_page.dart';
import 'package:bengkel_online_flutter/feature/admin/widgets/bottom_nav.dart';
import 'package:bengkel_online_flutter/core/screens/registers/change_password.dart' as change_screen;
import 'package:bengkel_online_flutter/feature/admin/providers/admin_service_provider.dart';

// Owner screens & providers
import 'package:bengkel_online_flutter/feature/owner/providers/employee_provider.dart';
import 'package:bengkel_online_flutter/core/providers/service_provider.dart';
import 'package:bengkel_online_flutter/feature/owner/screens/homepage_owner.dart';
import 'package:bengkel_online_flutter/feature/owner/screens/list_work.dart';
import 'package:bengkel_online_flutter/feature/owner/screens/on_boarding.dart';
import 'package:bengkel_online_flutter/feature/owner/screens/profil_page_owner.dart' as owner_profil;
import 'package:bengkel_online_flutter/feature/owner/screens/report_pages.dart';
import 'package:bengkel_online_flutter/feature/owner/screens/staff_management.dart';
import 'package:bengkel_online_flutter/feature/owner/widgets/bottom_nav_owner.dart';
import 'package:bengkel_online_flutter/feature/owner/screens/voucher_page.dart';
import 'package:bengkel_online_flutter/feature/owner/screens/list_voucher_page.dart';
import 'package:bengkel_online_flutter/core/services/notification_provider.dart';
import 'package:bengkel_online_flutter/feature/owner/screens/notification_page.dart';

final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  // ✅ Initialize date formatting (important for Voucher)
  await initializeDateFormatting('id_ID', null);
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthProvider()),
        ChangeNotifierProvider(create: (_) => EmployeeProvider()),
        ChangeNotifierProvider(create: (_) => ServiceProvider()),
        ChangeNotifierProvider(create: (_) => AdminServiceProvider()),
        ChangeNotifierProxyProvider<AuthProvider, NotificationProvider>(
          create: (context) => NotificationProvider(context.read<AuthProvider>()),
          update: (context, auth, previous) => NotificationProvider(auth),
        ),
      ],
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  late final AppLinks _appLinks;
  StreamSubscription<Uri>? _linkSub;

  @override
  void initState() {
    super.initState();
    _initDeepLinks();
  }

  @override
  void dispose() {
    _linkSub?.cancel();
    super.dispose();
  }

  Future<void> _initDeepLinks() async {
    _appLinks = AppLinks();
    try {
      final initial = await _appLinks.getInitialAppLink();
      if (initial != null) _handleUri(initial);
    } catch (_) {}
    _linkSub = _appLinks.uriLinkStream.listen(
      (uri) {
        if (uri != null) _handleUri(uri);
      },
      onError: (_) {},
    );
  }

  void _handleUri(Uri uri) {
    String target = uri.host;
    if (target.isEmpty && uri.pathSegments.isNotEmpty) {
      target = uri.pathSegments.first;
    }
    if (target == 'login') {
      final email = uri.queryParameters['email'];
      navigatorKey.currentState?.pushNamed('/login', arguments: {'email': email});
      return;
    }
    if (target == 'set-password') {
      final token = uri.queryParameters['token'];
      navigatorKey.currentState?.pushNamed('/changePassword', arguments: {'token': token});
      return;
    }
  }

  @override
  Widget build(BuildContext context) {
    return ConnectivityWrapper(
      navigatorKey: navigatorKey,
      child: MaterialApp(
        navigatorKey: navigatorKey,
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
          "/splash": (_) => const SplashScreen(),
          "/onboarding": (_) => const OnboardingScreen(),
          "/login": (_) => const login_screen.LoginPage(),
          "/gate": (_) => const LoadingGate(),
          // RoleEntry will handle navbar index
          "/main": (_) => const RoleEntry(),
          "/verify-email": (_) => const VerifyEmailPage(),
          "/workshop-waiting": (_) => const WorkshopWaitingPage(),
          // Owner & Admin routes
          "/home": (_) => const DashboardScreen(),
          "/changePassword": (_) => const change_screen.UbahPasswordPage(),
          "/list": (_) => const ListWorkPage(),
          "/register/owner/bengkel": (_) => const RegisterFlowPage(),
          "/register/user": (_) => const RegisterFlowPage(),
          "/dashboard": (_) => const DashboardPage(),
          "/register/owner": (_) => const RegisterFlowPage(),
          "/owner/profile": (_) => owner_profil.ProfilePageOwner(),
          "/voucher": (_) => const VoucherPage(),
          "/voucher/list": (_) => const ListVoucherPage(),
          "/forgot-password": (_) => const forgot_pass.ForgotPasswordPage(),
          "/reset-password": (_) => const reset_pass.ResetPasswordPage(),
          "/notifications": (_) => const NotificationPage(),
        },
        onGenerateRoute: (settings) {
          if (settings.name == '/list') {
            final args = (settings.arguments ?? {}) as Map?;
            final providedWs = args?['workshopUuid'] as String?;
            final auth = navigatorKey.currentContext != null
                ? Provider.of<AuthProvider>(navigatorKey.currentContext!, listen: false)
                : null;
            final derivedWs = _pickWorkshopUuid(auth?.user);
            final ws = providedWs ?? derivedWs;
            return MaterialPageRoute(
              builder: (_) => ListWorkPage(workshopUuid: ws),
              settings: settings,
            );
          }
          return null;
        },
        onUnknownRoute: (_) => MaterialPageRoute(builder: (_) => const SplashScreen()),
      ),
    );
  }
}

class RoleEntry extends StatelessWidget {
  const RoleEntry({super.key});

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();
    final role = auth.user?.role ?? 'guest';
    final mustChange = auth.mustChangePassword;
    // Capture initial tab index from arguments
    final args = ModalRoute.of(context)?.settings.arguments;
    int initialIndex = 0;
    if (args is int) initialIndex = args;
    if (!auth.isLoggedIn || role == 'guest') {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        Navigator.pushReplacementNamed(context, '/login');
      });
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }
    if (!auth.isEmailVerified) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        Navigator.pushReplacementNamed(context, '/verify-email');
      });
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }
    if (role == 'owner' && !auth.isWorkshopVerified) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        Navigator.pushReplacementNamed(context, '/workshop-waiting');
      });
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }
    if (mustChange && role == 'admin') {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        Navigator.pushReplacementNamed(context, '/changePassword');
      });
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }
    return MainPage(role: role, initialIndex: initialIndex);
  }
}

class MainPage extends StatefulWidget {
  final String role;
  final int initialIndex;
  const MainPage({super.key, required this.role, this.initialIndex = 0});

  @override
  State<MainPage> createState() => _MainPageState();
}

class _MainPageState extends State<MainPage> {
  late int _selectedIndex;
  int? _serviceInitialTab;
  String? _serviceInitialFilter;

  @override
  void initState() {
    super.initState();
    _selectedIndex = widget.initialIndex;
  }

  void _onItemTapped(int index, {int? serviceTab, String? serviceFilter}) {
    setState(() {
      _selectedIndex = index;
      _serviceInitialTab = serviceTab;
      _serviceInitialFilter = serviceFilter;
    });
  }

  @override
  Widget build(BuildContext context) {
    late final List<Widget> pages;
    late final Widget bottomNavBar;
    late final Widget homePage;
    late final Widget servicePage;
    late final Widget dashboardPage;
    late final Widget profilePage;

    switch (widget.role) {
      case "owner":
        pages = [
          const DashboardScreen(),
          const ManajemenKaryawanPage(),
          const ReportPage(),
          owner_profil.ProfilePageOwner(),
        ];
        bottomNavBar = CustomBottomNavBarOwner(
          selectedIndex: _selectedIndex,
          onTap: (index) => _onItemTapped(index),
        );
        break;
      case "admin":
        homePage = HomePage(onTabChange: _onItemTapped);
        servicePage = ServicePageAdmin(
          initialTab: _serviceInitialTab,
          initialFilter: _serviceInitialFilter,
        );
        dashboardPage = const DashboardPage();
        profilePage = const admin_profil.ProfilePageAdmin();
        pages = [homePage, servicePage, dashboardPage, profilePage];
        bottomNavBar = CustomBottomNavBarAdmin(
          selectedIndex: _selectedIndex,
          onTap: (index) => _onItemTapped(index),
        );
        break;
      default:
        WidgetsBinding.instance.addPostFrameCallback((_) {
          Navigator.pushReplacementNamed(context, '/login');
        });
        return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    return Scaffold(
      body: IndexedStack(index: _selectedIndex, children: pages),
      bottomNavigationBar: bottomNavBar,
    );
  }
}

String? _pickWorkshopUuid(dynamic user) {
  if (user == null) return null;
  try {
    final ws = user.workshops as List?;
    if (ws != null && ws.isNotEmpty) {
      final first = ws.first;
      final id = (first.id ?? first['id']) as String?;
      if (id != null && id.isNotEmpty) return id;
    }
  } catch (_) {}
  try {
    final emp = user.employment;
    final w = emp?.workshop ?? emp['workshop'];
    if (w != null) {
      final id = (w.id ?? w['id']) as String?;
      if (id != null && id.isNotEmpty) return id;
    }
  } catch (_) {}
  return null;
}
