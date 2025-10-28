import 'dart:math' as math;
import 'package:flutter/material.dart';

enum CurtainStyle {
  horizontalSplit, // kiri-kanan geser
  verticalSplit,   // atas-bawah geser
  circularReveal,  // lingkaran mengembang
  diamondReveal,   // belah ketupat mengembang
}

class SplashScreen extends StatefulWidget {
  const SplashScreen({
    super.key,
    this.style = CurtainStyle.diamondReveal, // pilih gaya tirai di sini
    this.nextRoute = '/onboarding',
    this.holdAfterShow = const Duration(seconds: 3), // splash 2 stay
  });

  final CurtainStyle style;
  final String nextRoute;
  final Duration holdAfterShow;

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with TickerProviderStateMixin {
  // Curtain open (easeInOut)
  late final AnimationController _curtainCtrl;
  late final CurvedAnimation _curtainAnim;

  // Content (logo + text)
  late final AnimationController _logoCtrl;      // bounce
  late final AnimationController _textFadeCtrl;  // dissolve
  late final AnimationController _loadingFadeCtrl; // <-- spinner fade-in

  // Close (dissolve + mini bounce)
  late final AnimationController _closeCtrl;
  late final Animation<double> _closeFade;
  late final Animation<double> _closeScale;

  @override
  void initState() {
    super.initState();

    _curtainCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600), // sesuai kodenya sekarang
    );
    _curtainAnim = CurvedAnimation(parent: _curtainCtrl, curve: Curves.easeInOut);

    _logoCtrl = AnimationController(vsync: this, duration: const Duration(milliseconds: 800));
    _textFadeCtrl = AnimationController(vsync: this, duration: const Duration(milliseconds: 300));
    _loadingFadeCtrl = AnimationController(vsync: this, duration: const Duration(milliseconds: 300)); // <-- NEW

    _closeCtrl = AnimationController(vsync: this, duration: const Duration(milliseconds: 300));
    _closeFade = Tween<double>(begin: 1, end: 0).animate(
      CurvedAnimation(parent: _closeCtrl, curve: Curves.easeInOut),
    );
    _closeScale = TweenSequence<double>([
      TweenSequenceItem(tween: Tween(begin: 1.0, end: 1.04), weight: 40),
      TweenSequenceItem(tween: Tween(begin: 1.04, end: 0.98), weight: 30),
      TweenSequenceItem(tween: Tween(begin: 0.98, end: 1.0), weight: 30),
    ]).animate(CurvedAnimation(parent: _closeCtrl, curve: Curves.easeInOut));

    _runSequence();
  }

  Future<void> _runSequence() async {
    // After delay 800ms → open curtain
    await Future.delayed(const Duration(milliseconds: 800));
    if (!mounted) return;
    await _curtainCtrl.forward();

    // Show content
    _logoCtrl.forward();        // bounce logo
    _textFadeCtrl.forward();    // dissolve teks
    _loadingFadeCtrl.forward(); // <-- spinner muncul saat menunggu

    // Stay (Splash 2)
    await Future.delayed(widget.holdAfterShow);

    // Close + navigate
    await _closeCtrl.forward();
    if (!mounted) return;
    Navigator.of(context).pushReplacementNamed(widget.nextRoute);
  }

  @override
  void dispose() {
    _curtainCtrl.dispose();
    _logoCtrl.dispose();
    _textFadeCtrl.dispose();
    _loadingFadeCtrl.dispose(); // <-- NEW
    _closeCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
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
                    loadingFadeCtrl: _loadingFadeCtrl, // <-- NEW
                  ),

                  // --- Stage 1: Tirai (overlay) ---
                  _buildCurtain(size, progress, widget.style),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  // ================== CURTAIN BUILDER ==================
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
      // Dua panel: kiri & kanan geser keluar
        final panelW = size.width / 2 + 24; // overlap biar gak ada seam
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
      // Dua panel: atas & bawah geser keluar
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
      // Overlay merah berlubang lingkaran yang mengembang dari tengah
        return CustomPaint(
          size: Size.infinite,
          painter: _RevealPainter(
            progress: t,
            type: _RevealType.circle,
            gradient: gradient,
          ),
        );

      case CurtainStyle.diamondReveal:
      // Overlay merah berlubang belah ketupat dari tengah
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
class _CenterContent extends StatelessWidget {
  const _CenterContent({
    required this.logoCtrl,
    required this.textFadeCtrl,
    required this.loadingFadeCtrl, // <-- NEW
  });

  final AnimationController logoCtrl;
  final AnimationController textFadeCtrl;
  final AnimationController loadingFadeCtrl; // <-- NEW

  @override
  Widget build(BuildContext context) {
    const black2323 = Color(0xFF232323);

    return Center(
      child: FadeTransition(
        opacity: CurvedAnimation(parent: textFadeCtrl, curve: Curves.easeInOut),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Logo 145x145, bounce
            ScaleTransition(
              scale: CurvedAnimation(parent: logoCtrl, curve: Curves.elasticOut),
              child: Image.asset(
                'assets/icons/logo_splash.png',
                width: 145,
                height: 145,
              ),
            ),
            const SizedBox(height: 36),

            // Text 1 (gradient)
            const _GradientText(
              'Welcome to',
              fontSize: 20,
              colors: [Color(0xFF6E1313), Color(0xFFDC2626), Color(0xFF5A1919)],
              stops: [0.24, 0.55, 1.0],
            ),
            const SizedBox(height: 6),

            // Text 2 + plus
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

            // --- Loading spinner tepat di bawah text 2 ---
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
enum _RevealType { circle, diamond }

class _RevealPainter extends CustomPainter {
  _RevealPainter({
    required this.progress, // 0..1
    required this.type,
    required this.gradient,
  });

  final double progress;
  final _RevealType type;
  final Gradient gradient;

  @override
  void paint(Canvas canvas, Size size) {
    final rect = Offset.zero & size;

    // Layer: gambar overlay merah lalu "lubangi" dengan clear
    canvas.saveLayer(rect, Paint());

    // Overlay gradient
    final paint = Paint()..shader = gradient.createShader(rect);
    canvas.drawRect(rect, paint);

    // Punch hole: lingkaran / diamond → BlendMode.clear
    final clearPaint = Paint()..blendMode = BlendMode.clear;

    switch (type) {
      case _RevealType.circle:
        final diag = math.sqrt(size.width * size.width + size.height * size.height);
        final radius = progress * diag; // 0..max
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
}
