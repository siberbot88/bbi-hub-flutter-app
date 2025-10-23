import 'dart:async';
import 'package:bengkel_online_flutter/feature/mechanic/widgets/bottom_navbar.dart';
import 'package:bengkel_online_flutter/feature/mechanic/widgets/smartasset.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../widgets/custom_header.dart';
import 'profil_page.dart';
import 'servicePage.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'BBI HUB+',
      theme: ThemeData(
        primarySwatch: Colors.red,
        fontFamily: 'Poppins',
      ),
      home: const HomePageMechanic(),
      debugShowCheckedModeBanner: false,
    );
  }
}

// ---------------- HomePage ----------------
class HomePageMechanic extends StatefulWidget {
  const HomePageMechanic({super.key});

  @override
  State<HomePageMechanic> createState() => _HomePageMechanicState();
}

class _HomePageMechanicState extends State<HomePageMechanic> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const RoundelAppBar(),
      body: const HomeContent(),
      // bottomNavigationBar: CustomBottomNavBar(
      //     selectedIndex: 0,
      //     onTap: (index) {
      //       if (index == 1) {
      //         Navigator.push(
      //           context,
      //           MaterialPageRoute(
      //               builder: (context) => const ServiceLoggingPage_()),
      //         );
      //       } else if (index == 2) {
      //         Navigator.push(
      //           context,
      //           MaterialPageRoute(builder: (context) => const ProfilePage()),
      //         );
      //       }
      //     }),
    );
  }
}

// aksi saat avatar diketuk
// ---------------- AppBar with Roundels ----------------
class RoundelAppBar extends StatelessWidget implements PreferredSizeWidget {
  final int todayTasks;
  final DateTime? date;
  final String userName;
  final String roleLabel;
  final ImageProvider? avatar;
  final VoidCallback? onAvatarTap;

  final double greetingSize;
  final double subtitleSize;
  final double appNameSize;
  final double roleSize;
  final double dateValueSize;
  final double taskValueSize;
  final double labelSize;

  const RoundelAppBar({
    super.key,
    this.todayTasks = 12,
    this.date,
    this.userName = 'Ahmad Rizki',
    this.roleLabel = 'Dashboard Mekanik',
    this.avatar,
    this.onAvatarTap,
    this.greetingSize = 20,
    this.subtitleSize = 15,
    this.appNameSize = 14,
    this.roleSize = 12,
    this.dateValueSize = 20,
    this.taskValueSize = 20,
    this.labelSize = 12,
  });

  @override
  Size get preferredSize => const Size.fromHeight(324);

  @override
  Widget build(BuildContext context) {
    final now = date ?? DateTime.now();
    final waktu = _greeting(now);

    return AppBar(
      elevation: 3,
      foregroundColor: Colors.white,
      backgroundColor: Colors.transparent,
      surfaceTintColor: Colors.transparent,
      shadowColor: Colors.black.withOpacity(0.25),
      systemOverlayStyle: SystemUiOverlayStyle.light,
      titleSpacing: 0,
      title: const SizedBox.shrink(),
      flexibleSpace: Stack(
        fit: StackFit.expand,
        children: [
          // gradient utama
          Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [Color(0xFFDC2626), Color(0xFF000000)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
          ),

          // roundels
          Positioned(
            right: -40,
            top: -10,
            child: _Roundel(
              size: 240,
              innerColor: const Color(0xFFDC2626),
              outerColor: const Color(0xFF000000),
              opacity: 0.55,
            ),
          ),
          Positioned(
            left: -60,
            top: -30,
            child: _Roundel(
              size: 200,
              innerColor: const Color(0xFFDC2626),
              outerColor: const Color(0xFF000000),
              opacity: 0.35,
            ),
          ),
          Positioned(
            left: -20,
            bottom: -70,
            child: _Roundel(
              size: 280,
              innerColor: const Color(0xFF000000),
              outerColor: const Color(0xFF000000),
              opacity: 0.35,
            ),
          ),

          // gambar mekanik
          Positioned(
            right: 0,
            bottom: 0,
            child: Transform.translate(
              offset: const Offset(0, 20),
              child: Image.asset(
                "assets/image/marquez.png",
                height: 300,
                fit: BoxFit.contain,
              ),
            ),
          ),

          // konten teks dan tombol
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // bar atas
                  Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'BBI HUB +',
                              style: TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.w700,
                                fontSize: appNameSize,
                                letterSpacing: .3,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                            const SizedBox(height: 2),
                            Text(
                              roleLabel,
                              style: TextStyle(
                                color: Colors.white.withOpacity(0.85),
                                fontSize: roleSize,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ],
                        ),
                      ),
                      GestureDetector(
                        onTap: onAvatarTap,
                        child: CircleAvatar(
                          radius: 18,
                          backgroundColor: Colors.white.withOpacity(0.9),
                          backgroundImage: avatar,
                          child: avatar == null
                              ? const Icon(Icons.person, color: Colors.black)
                              : null,
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 76),
                  Text(
                    'Selamat $waktu, $userName',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: greetingSize,
                      fontWeight: FontWeight.w700,
                      height: 1.1,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      const Text(
                        'Mekanik Senior',
                        style: TextStyle(color: Colors.white70, fontSize: 14),
                      ),
                      const SizedBox(width: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 8, vertical: 3),
                        decoration: BoxDecoration(
                          color: Colors.green,
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: const Text(
                          'Aktif',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 11,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),

                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.white,
                      foregroundColor: Colors.black,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(30),
                      ),
                      padding: const EdgeInsets.symmetric(
                          horizontal: 20, vertical: 10),
                    ),
                    onPressed: () {},
                    child: const Text('Mulai Servis Sekarang'),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  String _greeting(DateTime now) {
    final hour = now.hour;
    if (hour < 10) return 'Pagi';
    if (hour < 15) return 'Siang';
    if (hour < 18) return 'Sore';
    return 'Malam';
  }
}

// komponen roundel
class _Roundel extends StatelessWidget {
  final double size;
  final Color innerColor;
  final Color outerColor;
  final double opacity;

  const _Roundel({
    required this.size,
    required this.innerColor,
    required this.outerColor,
    this.opacity = 0.5,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: RadialGradient(
          colors: [
            outerColor.withOpacity(opacity),
            innerColor.withOpacity(opacity * 0.4),
            Colors.transparent,
          ],
          stops: const [0.0, 0.6, 1.0],
        ),
      ),
    );
  }
}

// ------------------- HOME CONTENT (with banners, quick features etc) -------------------
class HomeContent extends StatefulWidget {
  const HomeContent({super.key});

  @override
  State<HomeContent> createState() => _HomeContentState();
}

class _HomeContentState extends State<HomeContent> {
  final PageController _bannerController = PageController();
  Timer? _autoScrollTimer;
  int _currentBannerIndex = 0;

  // sample banner list (admin can manipulate these)
  final List<BannerData> banners = [
    BannerData(imagePath: 'assets/image/banner1.png'),
    BannerData(imagePath: 'assets/image/banner2.png'),
    BannerData(imagePath: 'assets/image/banner3.png'),
    BannerData(imagePath: 'assets/image/banner4.png'),
  ];

  bool autoScroll = true;

  @override
  void initState() {
    super.initState();
    if (autoScroll) _startAutoScroll();
  }

  void _startAutoScroll() {
    _autoScrollTimer?.cancel();
    _autoScrollTimer =
        Timer.periodic(const Duration(seconds: 5), (Timer timer) {
      if (!mounted || banners.isEmpty) return;
      final next = (_currentBannerIndex + 1) % banners.length;
      _bannerController.animateToPage(
        next,
        duration: const Duration(milliseconds: 450),
        curve: Curves.easeInOut,
      );
    });
  }

  void _stopAutoScroll() {
    _autoScrollTimer?.cancel();
    _autoScrollTimer = null;
  }

  @override
  void dispose() {
    _autoScrollTimer?.cancel();
    _bannerController.dispose();
    super.dispose();
  }

  LinearGradient _getBannerGradient(int index) {
    switch (index % 5) {
      case 0:
        return const LinearGradient(
            colors: [Color(0xFFDC2626), Color(0xFF991B1B)]);
      case 1:
        return const LinearGradient(
            colors: [Color(0xFF2563EB), Color(0xFF1D4ED8)]);
      case 2:
        return const LinearGradient(
            colors: [Color(0xFF059669), Color(0xFF047857)]);
      case 3:
        return const LinearGradient(
            colors: [Color(0xFF7C3AED), Color(0xFF6D28D9)]);
      case 4:
      default:
        return const LinearGradient(
            colors: [Color(0xFFEA580C), Color(0xFFC2410C)]);
    }
  }

  @override
  Widget build(BuildContext context) {
    final brandColor = const Color(0xFFDC2626);

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        // top row title + detail button
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              "Ringkasan hari Ini",
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
            ),
            TextButton(
              onPressed: () {
                Navigator.pushNamed(context, '/serviceLoggingPage');
              },
              child: const Text("Lihat detail",
                  style: TextStyle(color: Color(0xFFDC2626))),
            ),
          ],
        ),
        const SizedBox(height: 8),

        // Stat cards
        LayoutBuilder(
          builder: (context, constraints) {
            final screenWidth = constraints.maxWidth;
            final aspectRatio = screenWidth < 360 ? 1.0 : 1.4; // responsif

            return GridView.count(
              crossAxisCount: 2,
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              mainAxisSpacing: 12,
              crossAxisSpacing: 12,
              childAspectRatio: 1.6,
              children: [
                _StatCard(
                  title: "Servis Selesai",
                  value: "4",
                  assetPath: "assets/icons/selesai.svg",
                ),
                _StatCard(
                  title: "Servis Hari ini",
                  value: "12",
                  assetPath: "assets/icons/servishariini.svg",
                ),
              ],
            );
          },
        ),

        const SizedBox(height: 20),

//=================================== FITUR CEPAT =============================
        Center(
          child: Text(
            'Fitur Cepat',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: Colors.black87,
            ),
          ),
        ),

        const SizedBox(height: 14),

        LayoutBuilder(
          builder: (context, constraints) {
            final double width = constraints.maxWidth;

            // 🔹 Responsif: jumlah kolom otomatis tergantung lebar layar
            int columns = 3;
            if (width > 700)
              columns = 5;
            else if (width > 500) columns = 4;

            // 🔹 Hitung lebar item biar pas dan sejajar batas StatCard
            final double spacing = 16;
            final double itemWidth =
                (width - (columns - 1) * spacing - 32) / columns;

            return Padding(
              padding: const EdgeInsets.symmetric(horizontal: 19),
              child: Wrap(
                spacing: spacing,
                runSpacing: 16,
                alignment: WrapAlignment.center,
                children: [
                  _QuickFeature(
                    assetPath: 'assets/icons/jadwalhariini.svg',
                    label: "Jadwal\nHari Ini",
                    iconSize: 26,
                    onTap: () {},
                  ),
                  _QuickFeature(
                    assetPath: 'assets/icons/tugasmenanti.svg',
                    label: "Tugas\nMenanti",
                    iconSize: 26,
                    onTap: () {},
                  ),
                ].map((w) => SizedBox(width: itemWidth, child: w)).toList(),
              ),
            );
          },
        ),

        const SizedBox(height: 24),

        // Banner carousel + controls (auto scroll + add/remove)
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text('Promo & Banner',
                style: TextStyle(fontWeight: FontWeight.w600, fontSize: 16)),
          ],
        ),

        const SizedBox(height: 8),

        // PageView banner
        SizedBox(
          height: 300,
          child: Stack(
            children: [
              PageView.builder(
                controller: _bannerController,
                itemCount: banners.length,
                onPageChanged: (index) {
                  setState(() {
                    _currentBannerIndex = index;
                  });
                },
                itemBuilder: (context, index) {
                  final b = banners[index];
                  return Container(
                    margin: EdgeInsets.only(
                        right: index == banners.length - 1 ? 0 : 12),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(16),
                      child: Stack(
                        fit: StackFit.expand,
                        children: [
                          // Image with error fallback to gradient
                          Image.asset(
                            b.imagePath,
                            fit: BoxFit.cover,
                            errorBuilder: (context, error, stackTrace) {
                              // fallback gradient with texts
                              return Container(
                                decoration: BoxDecoration(
                                    gradient: _getBannerGradient(index)),
                                child: Center(
                                  child: Padding(
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 14.0),
                                    child: Column(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                    ),
                                  ),
                                ),
                              );
                            },
                          ),
                          // overlay gradient for readability
                          Container(
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                begin: Alignment.topCenter,
                                end: Alignment.bottomCenter,
                                colors: [
                                  Colors.transparent,
                                  Colors.black.withOpacity(0.45)
                                ],
                              ),
                            ),
                          ),
                          // bottom texts
                          Positioned(
                            left: 16,
                            bottom: 12,
                            right: 16,
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [],
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),

              // custom progress bar scrollbar (brand color) at top
              Positioned(
                top: 8,
                left: 0,
                right: 0,
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 4.0),
                  child: LinearProgressIndicator(
                    value: banners.isEmpty
                        ? 0
                        : (_currentBannerIndex + 1) / banners.length,
                    color: brandColor,
                    backgroundColor: brandColor.withOpacity(0.12),
                    minHeight: 4,
                  ),
                ),
              ),
            ],
          ),
        ),

        const SizedBox(height: 12),

        // dots indicator
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: List.generate(banners.length, (i) {
            final isActive = _currentBannerIndex == i;
            return AnimatedContainer(
              duration: const Duration(milliseconds: 300),
              margin: const EdgeInsets.symmetric(horizontal: 4),
              width: isActive ? 18 : 8,
              height: 8,
              decoration: BoxDecoration(
                color: isActive ? brandColor : Colors.grey.withOpacity(0.25),
                borderRadius: BorderRadius.circular(8),
              ),
            );
          }),
        ),

        const SizedBox(height: 24),
      ],
    );
  }
}

// ---------------- Stat Card ----------------
class _StatCard extends StatelessWidget {
  final String title;
  final String value;
  final String updateDate;
  final String percentage;
  final String assetPath;

  const _StatCard({
    required this.title,
    required this.value,
    required this.assetPath,
    this.updateDate = "selesai ",
    this.percentage = "40%",
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    final bool isNegative = percentage.startsWith('-');
    final Color trendColor = isNegative ? Colors.red : Colors.green;

    final screenWidth = MediaQuery.of(context).size.width;
    final double iconSize = screenWidth < 360 ? 24 : 28; // adaptif sedikit

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: Colors.grey.shade200),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 5,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      child: IntrinsicHeight(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 🔹 Judul
            Text(
              title,
              style: const TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: Color.fromARGB(255, 0, 0, 0),
              ),
            ),
            const SizedBox(height: 4),

            // 🔹 Angka + Icon sejajar
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Text(
                  value,
                  style: const TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Color.fromARGB(255, 0, 0, 0),
                  ),
                ),
                SizedBox(
                  width: iconSize,
                  height: iconSize,
                  child: SmartAsset(
                    path: assetPath,
                    fit: BoxFit.contain,
                  ),
                ),
              ],
            ),
            const Spacer(),

            // 🔹 Footer update + persen
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  "Update: $updateDate",
                  style: TextStyle(fontSize: 11, color: Colors.grey.shade600),
                ),
                Row(
                  children: [
                    Icon(
                      isNegative ? Icons.arrow_downward : Icons.arrow_upward,
                      size: 10.5,
                      color: trendColor,
                    ),
                    const SizedBox(width: 2),
                    Text(
                      percentage,
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w500,
                        color: trendColor,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

// ---------------- Quick Feature (interactive) ----------------
class _QuickFeature extends StatefulWidget {
  final String assetPath;
  final String label;
  final double iconSize;
  final VoidCallback? onTap;

  const _QuickFeature({
    required this.assetPath,
    required this.label,
    this.iconSize = 26,
    this.onTap,
    super.key,
  });

  @override
  State<_QuickFeature> createState() => _QuickFeatureState();
}

class _QuickFeatureState extends State<_QuickFeature>
    with SingleTickerProviderStateMixin {
  late final AnimationController _animationController;
  late final Animation<double> _scaleAnimation;
  bool _hovering = false;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 120),
      vsync: this,
    );
    _scaleAnimation = Tween<double>(begin: 1.0, end: 0.94).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeOut),
    );
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;

    // Responsif ukuran
    final double adaptiveIconSize =
        screenWidth < 360 ? widget.iconSize - 4 : widget.iconSize;
    final double adaptiveFontSize =
        screenWidth < 360 ? 10 : (screenWidth > 600 ? 13 : 11);

    final Color bgColor = Colors.red.shade100;

    final iconWidget = SmartAsset(
      path: widget.assetPath,
      width: adaptiveIconSize,
      height: adaptiveIconSize,
      fit: BoxFit.contain,
    );

    final double cardWidth = screenWidth > 800
        ? screenWidth * 0.18 // laptop / desktop
        : screenWidth > 600
            ? screenWidth * 0.22 // tablet
            : screenWidth * 0.26; // mobile (lebih lebar dikit)

    final featureCard = Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 5,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            decoration: BoxDecoration(
              color: bgColor,
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.08),
                  blurRadius: 8,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            padding: const EdgeInsets.all(12),
            child: iconWidget,
          ),
          const SizedBox(height: 8),
          Text(
            widget.label,
            style: TextStyle(
              fontSize: adaptiveFontSize,
              fontWeight: FontWeight.w500,
              color: Colors.black87,
              height: 1.2,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );

    Widget interactive = GestureDetector(
      onTapDown: (_) => _animationController.forward(),
      onTapCancel: () => _animationController.reverse(),
      onTapUp: (_) {
        _animationController.reverse();
        widget.onTap?.call();
      },
      child: ScaleTransition(scale: _scaleAnimation, child: featureCard),
    );

    // Hover animasi (web/desktop)
    if (kIsWeb ||
        Theme.of(context).platform == TargetPlatform.macOS ||
        Theme.of(context).platform == TargetPlatform.windows ||
        Theme.of(context).platform == TargetPlatform.linux) {
      interactive = MouseRegion(
        onEnter: (_) => setState(() => _hovering = true),
        onExit: (_) => setState(() => _hovering = false),
        cursor: SystemMouseCursors.click,
        child: AnimatedScale(
          scale: _hovering ? 1.03 : 1.0,
          duration: const Duration(milliseconds: 120),
          child: interactive,
        ),
      );
    }

    return interactive;
  }
}

// ---------------- BannerData ----------------
class BannerData {
  final String imagePath;
  BannerData({required this.imagePath});
}

// ---------------- Helpers ----------------
String _formatTanggalID(DateTime d) {
  const bulan = [
    'Januari',
    'Februari',
    'Maret',
    'April',
    'Mei',
    'Juni',
    'Juli',
    'Agustus',
    'September',
    'Oktober',
    'November',
    'Desember',
  ];
  return '${d.day} ${bulan[d.month - 1]} ${d.year}';
}

String _greeting(DateTime d) {
  final h = d.hour;
  if (h >= 4 && h < 11) return 'Pagi';
  if (h >= 11 && h < 15) return 'Siang';
  if (h >= 15 && h < 19) return 'Sore';
  return 'Malam';
}
