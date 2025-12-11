import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../theme/app_theme.dart';

class UnderlineCurvePainter extends CustomPainter {
  final Color color;

  UnderlineCurvePainter({required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..strokeWidth = 3
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    final path = Path();
    path.moveTo(0, size.height * 0.5);
    path.quadraticBezierTo(
      size.width * 0.5,
      size.height,
      size.width,
      size.height * 0.5,
    );

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

/// Premium Membership Screen dengan UI yang mendekati pixel perfect
class PremiumMembershipScreen extends StatefulWidget {
  const PremiumMembershipScreen({
    super.key,
    required this.onViewMembershipPackages,
    required this.onContinueFreeVersion,
  });

  final VoidCallback onViewMembershipPackages;
  final VoidCallback onContinueFreeVersion;

  @override
  State<PremiumMembershipScreen> createState() => _PremiumMembershipScreenState();
}

class _PremiumMembershipScreenState extends State<PremiumMembershipScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _scaleController;
  late Animation<double> _scaleAnimation;
  bool _isPressed = false;

  @override
  void initState() {
    super.initState();
    _scaleController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 200),
    );
    _scaleAnimation = Tween<double>(begin: 1.0, end: 0.98).animate(
      CurvedAnimation(parent: _scaleController, curve: Curves.easeOut),
    );
  }

  @override
  void dispose() {
    _scaleController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final primaryColor = Theme.of(context).colorScheme.primary;

    return Scaffold(
      body: SafeArea(
        child: Center(
          child: Container(
            constraints: const BoxConstraints(maxWidth: 430),
            child: SingleChildScrollView(
              child: Column(
                children: [
                  // 1. Premium Access Tag
                  _buildPremiumTag(primaryColor),

                  // 2. Hero / Dashboard Illustration
                  _buildHeroImage(isDark),

                  // 3. Headline
                  _buildHeadline(context, isDark, primaryColor),

                  // 4. Benefits Cards
                  _buildBenefitsSection(isDark, primaryColor),

                  // 5. Footer CTA
                  _buildFooterCTA(context, isDark, primaryColor),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildPremiumTag(Color primaryColor) {
    return Padding(
      padding: const EdgeInsets.only(top: 24, bottom: 8),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
        decoration: BoxDecoration(
          color: primaryColor.withAlpha((0.05 * 255).round()),
          border: Border.all(
            color: primaryColor.withAlpha((0.1 * 255).round()),
            width: 1,
          ),
          borderRadius: BorderRadius.circular(999),
        ),
        child: Text(
          'PREMIUM ACCESS',
          style: GoogleFonts.poppins(
            fontSize: 11,
            fontWeight: FontWeight.bold,
            letterSpacing: 1.5,
            color: primaryColor,
          ),
        ),
      ),
    );
  }

  Widget _buildHeroImage(bool isDark) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 16, 24, 0),
      child: TweenAnimationBuilder<double>(
        tween: Tween(begin: 0.9, end: 1.0),
        duration: const Duration(milliseconds: 600),
        curve: Curves.easeOut,
        builder: (context, scale, child) {
          return Transform.scale(
            scale: scale,
            child: child,
          );
        },
        child: AspectRatio(
          aspectRatio: 4 / 3,
          child: Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(24),
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: isDark
                    ? [Colors.grey[800]!, AppTheme.backgroundDark]
                    : [Colors.white, AppTheme.backgroundLight],
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withAlpha((0.08 * 255).round()),
                  blurRadius: 30,
                  offset: const Offset(0, 8),
                ),
              ],
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(24),
              child: Stack(
                children: [
                  // Gambar utama
                  Image.network(
                    'https://lh3.googleusercontent.com/aida-public/AB6AXuAGKONxdobdx_XHt7f9SuDG3exKUhQ6yOHh67i_AdYBX4MW6dKEwdk2YDNp4Nxdrnk4iu78dj1_RBSSQM4_bPim_DcDZ3i_r1qnXQhot3uPXy3UO4DaFjcq7xy_zo-rl5kcscE_TD-NFMnLcRW-WaAUw1qmfsb1arliq5roPdWEX06FNBhFgv-AuXGWl6sNBEIMsoUltlwczJeSxfdJo9k1ypQTmvvAPS1b5h0rni887K7t4XUYGDq0ijlvctSuE8uBK6MziuMzSjA',
                    fit: BoxFit.cover,
                    width: double.infinity,
                    height: double.infinity,
                  ),
                  // Fade effect di bawah
                  Positioned(
                    bottom: 0,
                    left: 0,
                    right: 0,
                    height: 150,
                    child: Container(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          colors: [
                            Colors.transparent,
                            isDark
                                ? AppTheme.backgroundDark
                                : AppTheme.backgroundLight,
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeadline(BuildContext context, bool isDark, Color primaryColor) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
      child: Column(
        children: [
          // Judul dengan underline dekoratif
          RichText(
            textAlign: TextAlign.center,
            text: TextSpan(
              style: AppTheme.heading(context: context, fontSize: 30),
              children: [
                const TextSpan(text: 'Kelola Bengkel\n'),
                WidgetSpan(
                  alignment: PlaceholderAlignment.baseline,
                  baseline: TextBaseline.alphabetic,
                  child: Stack(
                    clipBehavior: Clip.none,
                    children: [
                      Text(
                        'Lebih Cerdas',
                        style: AppTheme.heading(
                          context: context,
                          fontSize: 30,
                          color: primaryColor,
                        ),
                      ),
                      // Garis melengkung dekoratif
                      Positioned(
                        bottom: -4,
                        left: 0,
                        right: 0,
                        child: CustomPaint(
                          size: const Size(double.infinity, 8),
                          painter: UnderlineCurvePainter(
                            color: primaryColor.withAlpha((0.2 * 255).round()),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          
          const SizedBox(height: 12),
          
          // Deskripsi
          SizedBox(
            width: 280,
            child: Text(
              'Tingkatkan efisiensi, pantau profit, dan kontrol akses tim Anda.',
              textAlign: TextAlign.center,
              style: GoogleFonts.manrope(
                fontSize: 13,
                fontWeight: FontWeight.w500,
                color: isDark ? Colors.grey[400] : Colors.grey[500],
                height: 1.5,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBenefitsSection(bool isDark, Color primaryColor) {
    final benefits = [
      {
        'icon': Icons.show_chart,
        'title': 'Analitik Canggih',
        'subtitle': 'Pantau performa bengkel secara real-time.',
      },
      {
        'icon': Icons.smart_toy_outlined,
        'title': 'Otomatisasi Penuh',
        'subtitle': 'Hemat waktu dengan fitur admin otomatis.',
      },
      {
        'icon': Icons.groups_2_outlined,
        'title': 'Akses Multi-Peran',
        'subtitle': 'Kontrol penuh untuk Pemilik, Admin, dan Mekanik.',
      },
    ];

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Column(
        children: benefits.map((benefit) {
          return Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: _buildBenefitCard(
              icon: benefit['icon'] as IconData,
              title: benefit['title'] as String,
              subtitle: benefit['subtitle'] as String,
              isDark: isDark,
              primaryColor: primaryColor,
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildBenefitCard({
    required IconData icon,
    required String title,
    required String subtitle,
    required bool isDark,
    required Color primaryColor,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark ? AppTheme.cardDark : Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha((0.04 * 255).round()),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          // Icon container
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: isDark 
                  ? primaryColor.withAlpha((0.1 * 255).round())
                  : primaryColor.withAlpha((0.05 * 255).round()),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              icon,
              color: primaryColor,
              size: 26,
            ),
          ),
          
          const SizedBox(width: 16),
          
          // Text
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: GoogleFonts.poppins(
                    fontSize: 15,
                    fontWeight: FontWeight.bold,
                    color: isDark ? Colors.white : const Color(0xFF1A0E0E),
                    height: 1.2,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  subtitle,
                  style: GoogleFonts.manrope(
                    fontSize: 13,
                    color: isDark ? Colors.grey[400] : Colors.grey[500],
                    height: 1.4,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFooterCTA(BuildContext context, bool isDark, Color primaryColor) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(24, 16, 24, 32),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            Colors.transparent,
            isDark
                ? AppTheme.backgroundDark
                : AppTheme.backgroundLight,
          ],
        ),
      ),
      child: Column(
        children: [
          // Tombol utama dengan efek shimmer dan scale
          GestureDetector(
            onTapDown: (_) {
              setState(() => _isPressed = true);
              _scaleController.forward();
            },
            onTapUp: (_) {
              setState(() => _isPressed = false);
              _scaleController.reverse();
              widget.onViewMembershipPackages();
            },
            onTapCancel: () {
              setState(() => _isPressed = false);
              _scaleController.reverse();
            },
            child: ScaleTransition(
              scale: _scaleAnimation,
              child: Container(
                height: 56,
                decoration: BoxDecoration(
                  color: primaryColor,
                  borderRadius: BorderRadius.circular(18),
                  boxShadow: [
                    BoxShadow(
                      color: primaryColor.withAlpha((0.3 * 255).round()),
                      blurRadius: 15,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Stack(
                  children: [
                    // Shimmer effect
                    if (!_isPressed)
                      TweenAnimationBuilder<double>(
                        tween: Tween(begin: -1.0, end: 2.0),
                        duration: const Duration(milliseconds: 1500),
                        builder: (context, value, child) {
                          return Positioned.fill(
                            child: Transform.translate(
                              offset: Offset(value * 200, 0),
                              child: Container(
                                decoration: BoxDecoration(
                                  gradient: LinearGradient(
                                    colors: [
                                      Colors.transparent,
                                      Colors.white.withAlpha((0.2 * 255).round()),
                                      Colors.transparent,
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          );
                        },
                        onEnd: () {
                          if (mounted) setState(() {});
                        },
                      ),
                    
                    // Button content
                    Center(
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            'Lihat Paket Membership',
                            style: GoogleFonts.poppins(
                              fontSize: 17,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                              letterSpacing: 0.3,
                            ),
                          ),
                          const SizedBox(width: 8),
                          const Icon(
                            Icons.arrow_forward_rounded,
                            color: Colors.white,
                            size: 22,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          
          const SizedBox(height: 16),
          
          // Tombol sekunder
          TextButton(
            onPressed: widget.onContinueFreeVersion,
            style: TextButton.styleFrom(
              minimumSize: const Size(double.infinity, 40),
              padding: const EdgeInsets.symmetric(horizontal: 20),
            ),
            child: Text(
              'Lanjut pakai versi gratis',
              style: GoogleFonts.manrope(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: isDark ? Colors.grey[400] : Colors.grey[500],
                letterSpacing: 0.3,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
