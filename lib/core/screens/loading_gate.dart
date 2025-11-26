import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:bengkel_online_flutter/core/services/auth_provider.dart';

class LoadingGate extends StatefulWidget {
  const LoadingGate({super.key});

  @override
  State<LoadingGate> createState() => _LoadingGateState();
}

class _LoadingGateState extends State<LoadingGate> with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 900),
  )..repeat(reverse: true);

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _bootstrap());
  }

  Future<void> _bootstrap() async {
    final auth = context.read<AuthProvider>();
    await auth.checkLoginStatus();
    if (!mounted) return;

    if (auth.isLoggedIn) {
      // Pastikan route '/main' membaca role dari AuthProvider.user.role
      Navigator.pushNamedAndRemoveUntil(context, '/main', (_) => false);
      // Jika masih butuh kirim role manual:
      // final role = auth.user?.role ?? 'admin';
      // Navigator.pushAndRemoveUntil(context,
      //   MaterialPageRoute(builder: (_) => MainPage(role: role)), (_) => false);
    } else {
      Navigator.pushNamedAndRemoveUntil(context, '/login', (_) => false);
    }
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    const gradStart = Color(0xFF9B0D0D);
    const gradEnd   = Color(0xFFB70F0F);

    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [gradStart, gradEnd],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: Center(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 32),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                ScaleTransition(
                  scale: Tween(begin: .95, end: 1.05).animate(
                    CurvedAnimation(parent: _ctrl, curve: Curves.easeInOut),
                  ),
                  child: Container(
                    width: 84,
                    height: 84,
                    decoration: BoxDecoration(
                      color: Colors.white.withAlpha(38),
                      shape: BoxShape.circle,
                      border: Border.all(color: Colors.white.withAlpha(115)),
                    ),
                    alignment: Alignment.center,
                    child: const Text(
                      'BBI',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 24,
                        fontWeight: FontWeight.w800,
                        letterSpacing: 1.2,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                const Text(
                  'BBI HUB PLUS',
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w700,
                    fontSize: 16,
                  ),
                ),
                const SizedBox(height: 8),
                const Text(
                  'Menyiapkan akun dan data Anda…',
                  style: TextStyle(
                    color: Colors.white70,
                    fontSize: 12,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 24),
                const SizedBox(
                  width: 28,
                  height: 28,
                  child: CircularProgressIndicator(strokeWidth: 2.6, color: Colors.white),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
