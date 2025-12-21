import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
<<<<<<< HEAD

// (IMPORT LOGIKA GATING)
import 'package:bengkel_online_flutter/core/services/auth_provider.dart';

enum CurtainStyle {
  horizontalSplit,
  verticalSplit,
  circularReveal,
  diamondReveal,
}

class SplashScreen extends StatefulWidget {
  const SplashScreen({
    super.key,
    this.style = CurtainStyle.diamondReveal, // pilih gaya tirai di sini
  });
  // (nextRoute dan holdAfterShow dihapus karena sekarang dinamis)
  final CurtainStyle style;
=======

import 'package:bengkel_online_flutter/core/services/auth_provider.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});
>>>>>>> f69db6e40e06854413d398fd766130ce19c9aa76

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with TickerProviderStateMixin {
<<<<<<< HEAD
  // (Durasi minimal splash screen agar logo + spinner terlihat)
  static const _minHoldDuration = Duration(milliseconds: 2000);

  // (Semua controller animasi Anda tetap sama)
  late final AnimationController _curtainCtrl;
  late final CurvedAnimation _curtainAnim;
  late final AnimationController _logoCtrl;
  late final AnimationController _textFadeCtrl;
  late final AnimationController _loadingFadeCtrl;
  late final AnimationController _closeCtrl;
  late final Animation<double> _closeFade;
  late final Animation<double> _closeScale;
=======
  static const _minDisplayDuration = Duration(milliseconds: 2500);

  late final AnimationController _fadeController;
  late final AnimationController _logoController;
  late final AnimationController _contentController;
  late final AnimationController _loadingController;
  late final AnimationController _exitController;

  late final Animation<double> _fadeAnimation;
  late final Animation<double> _logoScale;
  late final Animation<double> _logoFade;
  late final Animation<Offset> _contentSlide;
  late final Animation<double> _contentFade;
  late final Animation<double> _exitFade;
>>>>>>> f69db6e40e06854413d398fd766130ce19c9aa76

  @override
  void initState() {
    super.initState();

    _fadeController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );

<<<<<<< HEAD
    _logoCtrl = AnimationController(vsync: this, duration: const Duration(milliseconds: 800));
    _textFadeCtrl = AnimationController(vsync: this, duration: const Duration(milliseconds: 300));
    _loadingFadeCtrl = AnimationController(vsync: this, duration: const Duration(milliseconds: 300));
    _closeCtrl = AnimationController(vsync: this, duration: const Duration(milliseconds: 300));

    _closeFade = Tween<double>(begin: 1, end: 0).animate(
      CurvedAnimation(parent: _closeCtrl, curve: Curves.easeInOut),
=======
    _logoController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1000),
>>>>>>> f69db6e40e06854413d398fd766130ce19c9aa76
    );

<<<<<<< HEAD
    // (Panggil sequence baru)
    _runCombinedSequence();
  }

  // --- (LOGIKA INI DI-UPGRADE TOTAL) ---
  Future<void> _runCombinedSequence() async {
    // 1. Mulai logika "gating" DI LATAR BELAKANG.
    //    Ini akan menjalankan checkLoginStatus() dan SharedPreferences.
    final routeFuture = _decideNextRoute();

    // 2. Jalankan animasi visual Anda
    await Future.delayed(const Duration(milliseconds: 800)); // Delay awal
    if (!mounted) return;
    await _curtainCtrl.forward(); // Buka tirai

    // Tampilkan konten (logo, teks, dan spinner)
    _logoCtrl.forward();
    _textFadeCtrl.forward();
    _loadingFadeCtrl.forward(); // <-- Spinner kini berputar selagi logic berjalan

    // 3. Tunggu KEDUA proses selesai
    //    - Animasi harus terlihat minimal 2 detik (_minHoldDuration)
    //    - Logika _decideNextRoute() harus selesai
    final results = await Future.wait([
      Future.delayed(_minHoldDuration),
      routeFuture,
    ]);

    // 4. Ambil rute yang sudah ditentukan
    final String nextRoute = results[1] as String;

    // 5. Tutup animasi dan navigasi
    if (!mounted) return;
    await _closeCtrl.forward(); // Animasi tutup

    if (!mounted) return;
    Navigator.of(context).pushReplacementNamed(nextRoute);
=======
    _contentController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );

    _loadingController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    )..repeat();

    _exitController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 400),
    );

    // Smooth fade in
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _fadeController, curve: Curves.easeOut),
    );

    // Logo smooth scale up
    _logoScale = Tween<double>(begin: 0.8, end: 1.0).animate(
      CurvedAnimation(parent: _logoController, curve: Curves.easeOutCubic),
    );

    _logoFade = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _logoController, curve: Curves.easeIn),
    );

    // Content slide from bottom
    _contentSlide = Tween<Offset>(
      begin: const Offset(0, 0.3),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(parent: _contentController, curve: Curves.easeOutCubic),
    );

    _contentFade = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _contentController, curve: Curves.easeIn),
    );

    // Exit fade
    _exitFade = Tween<double>(begin: 1.0, end: 0.0).animate(
      CurvedAnimation(parent: _exitController, curve: Curves.easeIn),
    );

    _startSplashSequence();
  }

  Future<void> _startSplashSequence() async {
    final routeFuture = _decideNextRoute();

    // Smooth sequential animations
    await Future.delayed(const Duration(milliseconds: 300));
    _fadeController.forward();
    
    await Future.delayed(const Duration(milliseconds: 200));
    _logoController.forward();

    await Future.delayed(const Duration(milliseconds: 400));
    _contentController.forward();

    await Future.wait([
      Future.delayed(_minDisplayDuration),
      routeFuture,
    ]);

    final nextRoute = await routeFuture;
    await _exitController.forward();

    if (!mounted) return;
    Navigator.of(context).pushReplacementNamed(nextRoute);
  }

  Future<String> _decideNextRoute() async {
    try {
      final auth = context.read<AuthProvider>();
      final prefs = await SharedPreferences.getInstance();
      final bool hasSeenOnboarding = prefs.getBool('hasSeenOnboarding') ?? false;

      await auth.checkLoginStatus();

      if (auth.isLoggedIn) {
        return '/gate';
      } else {
        if (hasSeenOnboarding) {
          return '/login';
        } else {
          return '/onboarding';
        }
      }
    } catch (e) {
      return '/login';
    }
>>>>>>> f69db6e40e06854413d398fd766130ce19c9aa76
  }

  // --- (LOGIKA GATING DARI SPLASH SCREEN SEBELUMNYA) ---
  Future<String> _decideNextRoute() async {
    try {
      final auth = context.read<AuthProvider>();
      final prefs = await SharedPreferences.getInstance();
      final bool hasSeenOnboarding = prefs.getBool('hasSeenOnboarding') ?? false;

      // Ini adalah 'pekerjaan' sebenarnya, cek token & ambil data user
      await auth.checkLoginStatus();

      if (auth.isLoggedIn) {
        // KASUS 1: User sudah login
        return '/gate'; // Langsung ke gerbang utama (RoleEntry)
      } else {
        // KASUS 2: User TIDAK login
        if (hasSeenOnboarding) {
          // Pernah lihat onboarding, tapi belum login (atau sudah logout)
          return '/login';
        } else {
          // Belum pernah buka aplikasi sama sekali
          return '/onboarding';
        }
      }
    } catch (e) {
      // Jika gagal (misal: tidak ada internet), arahkan ke login
      return '/login';
    }
  }
  // --- (AKHIR DARI LOGIKA BARU) ---

  @override
  void dispose() {
<<<<<<< HEAD
    _curtainCtrl.dispose();
    _logoCtrl.dispose();
    _textFadeCtrl.dispose();
    _loadingFadeCtrl.dispose();
    _closeCtrl.dispose();
=======
    _fadeController.dispose();
    _logoController.dispose();
    _contentController.dispose();
    _loadingController.dispose();
    _exitController.dispose();
>>>>>>> f69db6e40e06854413d398fd766130ce19c9aa76
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
<<<<<<< HEAD
    // (TAMPILAN BUILD ANDA TIDAK BERUBAH SAMA SEKALI)
    final size = MediaQuery.of(context).size;

    return Scaffold(
      backgroundColor: Colors.white,
      body: AnimatedBuilder(
        animation: Listenable.merge([_curtainCtrl, _closeCtrl]),
        builder: (context, _) {
          final progress = _curtainAnim.value; // 0..1

          return FadeTransition(
            opacity: _closeFade,
            child: ScaleTransition(
              scale: _closeScale,
              child: Stack(
                fit: StackFit.expand,
                children: [
                  // --- Stage 2: Logo + Teks + Loading ---
                  _CenterContent(
                    logoCtrl: _logoCtrl,
                    textFadeCtrl: _textFadeCtrl,
                    loadingFadeCtrl: _loadingFadeCtrl,
=======
    return Scaffold(
      backgroundColor: Colors.white,
      body: FadeTransition(
        opacity: _fadeAnimation,
        child: FadeTransition(
          opacity: _exitFade,
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Logo
                ScaleTransition(
                  scale: _logoScale,
                  child: FadeTransition(
                    opacity: _logoFade,
                    child: Container(
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: const Color(0xFFDC2626).withAlpha(20),
                            blurRadius: 40,
                            spreadRadius: 0,
                            offset: const Offset(0, 10),
                          ),
                          BoxShadow(
                            color: Colors.black.withAlpha(6),
                            blurRadius: 20,
                            spreadRadius: 0,
                            offset: const Offset(0, 5),
                          ),
                        ],
                      ),
                      child: Image.asset(
                        'assets/icons/logo_splash.png',
                        width: 70,
                        height: 70,
                      ),
                    ),
>>>>>>> f69db6e40e06854413d398fd766130ce19c9aa76
                  ),
                ),

                const SizedBox(height: 32),

                // Title
                SlideTransition(
                  position: _contentSlide,
                  child: FadeTransition(
                    opacity: _contentFade,
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        ShaderMask(
                          blendMode: BlendMode.srcIn,
                          shaderCallback: (bounds) {
                            return const LinearGradient(
                              begin: Alignment.topCenter,
                              end: Alignment.bottomCenter,
                              colors: [
                                Color(0xFF1A1A1A),
                                Color(0xFF404040),
                              ],
                            ).createShader(bounds);
                          },
                          child: const Text(
                            'BBI Hub',
                            style: TextStyle(
                              fontSize: 32,
                              fontWeight: FontWeight.w900,
                              color: Colors.white,
                              letterSpacing: -1.0,
                              height: 1.2,
                            ),
                          ),
                        ),
                        const SizedBox(width: 2),
                        ShaderMask(
                          blendMode: BlendMode.srcIn,
                          shaderCallback: (bounds) {
                            return const LinearGradient(
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                              colors: [
                                Color(0xFF9B0D0D),
                                Color(0xFFDC2626),
                              ],
                            ).createShader(bounds);
                          },
                          child: const Text(
                            '+',
                            style: TextStyle(
                              fontSize: 32,
                              fontWeight: FontWeight.w900,
                              color: Colors.white,
                              height: 1.2,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                const SizedBox(height: 12),

                // Tagline
                SlideTransition(
                  position: _contentSlide,
                  child: FadeTransition(
                    opacity: _contentFade,
                    child: const Text(
                      'Your Trusted Workshop Partner',
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w500,
                        color: Color(0xFF999999),
                        letterSpacing: 0.5,
                      ),
                    ),
                  ),
                ),

                const SizedBox(height: 40),

                // Loading dots
                FadeTransition(
                  opacity: _contentFade,
                  child: _LoadingDots(controller: _loadingController),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// Reusable loading dots
class _LoadingDots extends StatelessWidget {
  final AnimationController controller;

  const _LoadingDots({required this.controller});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 40,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: List.generate(3, (index) {
          return AnimatedBuilder(
            animation: controller,
            builder: (context, child) {
              final delay = index * 0.15;
              final value = (controller.value + delay) % 1.0;
              final bounce = (value < 0.5)
                  ? Curves.easeOut.transform(value * 2)
                  : Curves.easeIn.transform((1 - value) * 2);

              return Transform.translate(
                offset: Offset(0, -bounce * 12),
                child: child,
              );
            },
            child: Container(
              margin: const EdgeInsets.symmetric(horizontal: 5),
              width: 8,
              height: 8,
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    Color(0xFF9B0D0D),
                    Color(0xFFDC2626),
                  ],
                ),
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFFDC2626).withAlpha(40),
                    blurRadius: 6,
                    spreadRadius: 0,
                  ),
                ],
              ),
            ),
          );
        }),
      ),
    );
  }
<<<<<<< HEAD

  // ================== CURTAIN BUILDER ==================
  // (TIDAK BERUBAH)
  Widget _buildCurtain(Size size, double t, CurtainStyle style) {
    const c1 = Color(0xFF9B0D0D);
    const c2 = Color(0xFFDC2626);
    final gradient = const LinearGradient(
      colors: [c1, c2],
      stops: [0.37, 0.63],
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
    );

    switch (style) {
      case CurtainStyle.horizontalSplit:
        final panelW = size.width / 2 + 24;
        final dx = t * (size.width / 2 + 24);
        return Stack(children: [
          Transform.translate(
            offset: Offset(-dx, 0),
            child: Align(
              alignment: Alignment.centerLeft,
              child: SizedBox(
                width: panelW,
                height: size.height,
                child: DecoratedBox(decoration: BoxDecoration(gradient: gradient)),
              ),
            ),
          ),
          Transform.translate(
            offset: Offset(dx, 0),
            child: Align(
              alignment: Alignment.centerRight,
              child: SizedBox(
                width: panelW,
                height: size.height,
                child: DecoratedBox(decoration: BoxDecoration(gradient: gradient)),
              ),
            ),
          ),
        ]);

      case CurtainStyle.verticalSplit:
        final panelH = size.height / 2 + 24;
        final dy = t * (size.height / 2 + 24);
        return Stack(children: [
          Transform.translate(
            offset: Offset(0, -dy),
            child: Align(
              alignment: Alignment.topCenter,
              child: SizedBox(
                width: size.width,
                height: panelH,
                child: DecoratedBox(decoration: BoxDecoration(gradient: gradient)),
              ),
            ),
          ),
          Transform.translate(
            offset: Offset(0, dy),
            child: Align(
              alignment: Alignment.bottomCenter,
              child: SizedBox(
                width: size.width,
                height: panelH,
                child: DecoratedBox(decoration: BoxDecoration(gradient: gradient)),
              ),
            ),
          ),
        ]);

      case CurtainStyle.circularReveal:
        return CustomPaint(
          size: Size.infinite,
          painter: _RevealPainter(
            progress: t,
            type: _RevealType.circle,
            gradient: gradient,
          ),
        );

      case CurtainStyle.diamondReveal:
        return CustomPaint(
          size: Size.infinite,
          painter: _RevealPainter(
            progress: t,
            type: _RevealType.diamond,
            gradient: gradient,
          ),
        );
    }
  }
}

// ================== CENTER CONTENT ==================
// (TIDAK BERUBAH)
class _CenterContent extends StatelessWidget {
  const _CenterContent({
    required this.logoCtrl,
    required this.textFadeCtrl,
    required this.loadingFadeCtrl,
  });

  final AnimationController logoCtrl;
  final AnimationController textFadeCtrl;
  final AnimationController loadingFadeCtrl;

  @override
  Widget build(BuildContext context) {
    const black2323 = Color(0xFF232323);

    return Center(
      child: FadeTransition(
        opacity: CurvedAnimation(parent: textFadeCtrl, curve: Curves.easeInOut),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ScaleTransition(
              scale: CurvedAnimation(parent: logoCtrl, curve: Curves.elasticOut),
              child: Image.asset(
                'assets/icons/logo_splash.png',
                width: 145,
                height: 145,
              ),
            ),
            const SizedBox(height: 36),
            const _GradientText(
              'Welcome to',
              fontSize: 20,
              colors: [Color(0xFF6E1313), Color(0xFFDC2626), Color(0xFF5A1919)],
              stops: [0.24, 0.55, 1.0],
            ),
            const SizedBox(height: 6),
            Row(
              mainAxisSize: MainAxisSize.min,
              children: const [
                Text(
                  'BBI Hub',
                  style: TextStyle(
                    fontSize: 47.8,
                    fontWeight: FontWeight.w800,
                    color: black2323,
                    height: 1.1,
                    letterSpacing: 0.2,
                  ),
                ),
                SizedBox(width: 4),
                _GradientText(
                  '+',
                  fontSize: 47.8,
                  colors: [Color(0xFF6E1313), Color(0xFFDC2626), Color(0xFF5A1919)],
                  stops: [0.24, 0.55, 1.0],
                ),
              ],
            ),
            const SizedBox(height: 164),
            FadeTransition(
              opacity: CurvedAnimation(parent: loadingFadeCtrl, curve: Curves.easeInOut),
              child: const SizedBox(
                width: 26,
                height: 26,
                child: CircularProgressIndicator(
                  strokeWidth: 3,
                  valueColor: AlwaysStoppedAnimation<Color>(Color(0xFFDC2626)),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ================== GRADIENT TEXT ==================
// (TIDAK BERUBAH)
class _GradientText extends StatelessWidget {
  const _GradientText(
      this.text, {
        required this.fontSize,
        required this.colors,
        required this.stops,
      });

  final String text;
  final double fontSize;
  final List<Color> colors;
  final List<double> stops;

  @override
  Widget build(BuildContext context) {
    return ShaderMask(
      blendMode: BlendMode.srcIn,
      shaderCallback: (bounds) => LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: colors,
        stops: stops,
      ).createShader(Rect.fromLTWH(0, 0, bounds.width, bounds.height)),
      child: Text(
        text,
        textAlign: TextAlign.center,
        style: TextStyle(
          fontSize: fontSize,
          fontWeight: FontWeight.w600,
          color: Colors.white,
          height: 1.1,
          letterSpacing: 0.2,
        ),
      ),
    );
  }
}

// ================== REVEAL PAINTER ==================
// (TIDAK BERUBAH)
enum _RevealType { circle, diamond }

class _RevealPainter extends CustomPainter {
  _RevealPainter({
    required this.progress,
    required this.type,
    required this.gradient,
  });

  final double progress;
  final _RevealType type;
  final Gradient gradient;

  @override
  void paint(Canvas canvas, Size size) {
    final rect = Offset.zero & size;
    canvas.saveLayer(rect, Paint());
    final paint = Paint()..shader = gradient.createShader(rect);
    canvas.drawRect(rect, paint);
    final clearPaint = Paint()..blendMode = BlendMode.clear;

    switch (type) {
      case _RevealType.circle:
        final diag = math.sqrt(size.width * size.width + size.height * size.height);
        final radius = progress * diag;
        final center = Offset(size.width / 2, size.height / 2);
        canvas.drawCircle(center, radius, clearPaint);
        break;

      case _RevealType.diamond:
        final r = progress * (math.max(size.width, size.height));
        final cx = size.width / 2;
        final cy = size.height / 2;
        final path = Path()
          ..moveTo(cx, cy - r)
          ..lineTo(cx + r, cy)
          ..lineTo(cx, cy + r)
          ..lineTo(cx - r, cy)
          ..close();
        canvas.drawPath(path, clearPaint);
        break;
    }

    canvas.restore();
  }

  @override
  bool shouldRepaint(covariant _RevealPainter oldDelegate) {
    return oldDelegate.progress != progress ||
        oldDelegate.type != type ||
        oldDelegate.gradient != gradient;
  }
=======
>>>>>>> f69db6e40e06854413d398fd766130ce19c9aa76
}