import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'service_page.dart';
import '../widgets/home/home_app_bar.dart';
import '../widgets/home/home_stat_card.dart';
import '../widgets/home/home_quick_feature.dart';

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
      home: const HomePage(),
      debugShowCheckedModeBanner: false,
    );
  }
}

// Admin Homepage - Clean entry point
class HomePage extends StatelessWidget {
  const HomePage({super.key});
  
  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      appBar: HomeAppBar(),
      body: HomeContent(),
    );
  }
}

// Home content with stats, quick features, and banners
class HomeContent extends StatefulWidget {
  const HomeContent({super.key});

  @override
  State<HomeContent> createState() => _HomeContentState();
}

class _HomeContentState extends State<HomeContent> {
  final PageController _bannerController = PageController();
  Timer? _autoScrollTimer;
  int _currentBannerIndex = 0;

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
    _autoScrollTimer = Timer.periodic(const Duration(seconds: 5), (_) {
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
        // Top row title + detail button
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              "Operasional hari Ini",
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
            ),
            TextButton(
              onPressed: () {
                Navigator.pushNamed(context, '/dashboard');
              },
              child: const Text("Lihat detail",
                  style: TextStyle(color: Color(0xFFDC2626))),
            ),
          ],
        ),
        const SizedBox(height: 8),

        // Stat cards grid
        GridView.count(
          crossAxisCount: 2,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          mainAxisSpacing: 12,
          crossAxisSpacing: 12,
          childAspectRatio: 1.6,
          children: const [
            HomeStatCard(
              title: "Servis Hari ini",
              value: "24",
              assetPath: "assets/icons/servishariini.svg",
            ),
            HomeStatCard(
              title: "Perlu di Assign",
              value: "12",
              assetPath: "assets/icons/assign.svg",
            ),
            HomeStatCard(
              title: "Feedback",
              value: "5",
              assetPath: "assets/icons/feedback.svg",
            ),
            HomeStatCard(
              title: "Selesai",
              value: "2",
              assetPath: "assets/icons/selesai.svg",
            ),
          ],
        ),

        const SizedBox(height: 24),

        // Quick features section
        const Center(
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
            int columns = 3;
            if (width > 700) columns = 5;
            else if (width > 500) columns = 4;

            final double spacing = 16;
            final double itemWidth = (width - (columns - 1) * spacing - 32) / columns;

            return Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Wrap(
                spacing: spacing,
                runSpacing: 18,
                alignment: WrapAlignment.start,
                children: [
                  HomeQuickFeature(
                    assetPath: 'assets/icons/riwayatservis.svg',
                    label: "Riwayat\nServis",
                    iconSize: 26,
                    onTap: () {},
                  ),
                  HomeQuickFeature(
                    assetPath: 'assets/icons/terimajadwal.svg',
                    label: "Terima\nJadwal",
                    iconSize: 26,
                    onTap: () {},
                  ),
                  HomeQuickFeature(
                    assetPath: 'assets/icons/feedback.svg',
                    label: "Umpan\nBalik",
                    iconSize: 26,
                    onTap: () {},
                  ),
                ].map((w) => SizedBox(width: itemWidth, child: w)).toList(),
              ),
            );
          },
        ),

        const SizedBox(height: 24),

        // Warning card
        Card(
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          elevation: 2,
          child: InkWell(
            borderRadius: BorderRadius.circular(16),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const ServicePageAdmin()),
              );
            },
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  SizedBox(
                    width: 36,
                    height: 36,
                    child: Image.asset(
                      'assets/icons/antrian.png',
                      fit: BoxFit.contain,
                      errorBuilder: (context, error, stackTrace) => const Icon(
                        Icons.warning_amber_rounded,
                        color: Color(0xFF5C36F4),
                        size: 36,
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  const Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "Cek list antrian pelanggan kamu!!",
                          style: TextStyle(
                              fontSize: 14, fontWeight: FontWeight.w600),
                        ),
                        SizedBox(height: 4),
                        Text(
                          "Klik tombol dibawah ini untuk masuk menu Service",
                          style: TextStyle(fontSize: 12),
                        ),
                      ],
                    ),
                  ),
                  const Icon(Icons.arrow_forward_ios,
                      size: 16, color: Colors.grey),
                ],
              ),
            ),
          ),
        ),

        const SizedBox(height: 24),

        // Banner carousel section
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text('Promo & Banner',
                style: TextStyle(fontWeight: FontWeight.w600, fontSize: 16)),
          ],
        ),

        const SizedBox(height: 8),

        // Banner PageView
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
                          Image.asset(
                            b.imagePath,
                            fit: BoxFit.cover,
                            errorBuilder: (context, error, stackTrace) {
                              return Container(
                                decoration: BoxDecoration(
                                    gradient: _getBannerGradient(index)),
                                child: const Center(
                                  child: Padding(
                                    padding: EdgeInsets.symmetric(
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
                        ],
                      ),
                    ),
                  );
                },
              ),

              // Progress indicator
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

        // Dots indicator
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

// Banner data model
class BannerData {
  final String imagePath;
  BannerData({required this.imagePath});
}

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
    this.userName = 'AHASS',
    this.roleLabel = 'admin workshop',
    this.avatar,
    this.onAvatarTap,
    this.greetingSize = 26,
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
    final tanggal = _formatTanggalID(now);
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

          // roundels (tidak const karena gradient non-const di dalamnya)
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

          // 🔥 Marquez di depan background, tapi belakang teks
          Positioned(
            right: 0,
            bottom: 0,
            child: Transform.translate(
              offset: const Offset(0, 20), // bisa disesuaikan
              child: Image.asset(
                "assets/image/marquez.png",
                height: 300,
                fit: BoxFit.contain,
              ),
            ),
          ),

          SafeArea(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
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
                  const Padding(padding: EdgeInsets.only(left: 20)),
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
                  Text(
                    'Yuk Kelola Operasional Hari ini 🔥',
                    style: TextStyle(
                      color: Colors.white.withOpacity(0.92),
                      fontSize: subtitleSize,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const Spacer(),
                  Center(
                    child: _StatsPill(
                      tanggal: tanggal,
                      tasks: todayTasks,
                      dateValueSize: dateValueSize,
                      taskValueSize: taskValueSize,
                      labelSize: labelSize,
                    ),
                  ),
                  const SizedBox(height: 28),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _Roundel extends StatelessWidget {
  final double size;
  final Color innerColor;
  final Color outerColor;
  final double opacity;

  const _Roundel({
    required this.size,
    required this.innerColor,
    required this.outerColor,
    this.opacity = 0.6,
  });

  @override
  Widget build(BuildContext context) {
    // radial gradient dari innerColor -> blend -> outerColor (diatur transparan agar menyatu)
    return IgnorePointer(
      child: Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          gradient: RadialGradient(
            center: const Alignment(-0.2, -0.2),
            radius: 0.8,
            colors: [
              innerColor.withOpacity(opacity),
              Color.lerp(innerColor, outerColor, 0.5)!
                  .withOpacity(opacity * 0.6),
              outerColor.withOpacity(0.0),
            ],
            stops: const [0.0, 0.6, 1.0],
          ),
        ),
      ),
    );
  }
}

class _StatsPill extends StatelessWidget {
  final String tanggal;
  final int tasks;
  final double dateValueSize;
  final double taskValueSize;
  final double labelSize;

  const _StatsPill({
    required this.tanggal,
    required this.tasks,
    this.dateValueSize = 20,
    this.taskValueSize = 20,
    this.labelSize = 12,
  });

  @override
  Widget build(BuildContext context) {
    final sw = MediaQuery.of(context).size.width;
    final double pillWidth = math.min(364.0, math.max(240.0, sw - 32.0));

    return Container(
      width: pillWidth,
      constraints: const BoxConstraints(minHeight: 92.0),
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.14),
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: Colors.white.withOpacity(0.22), width: 1),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.18),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Tanggal sekarang',
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.85),
                    fontSize: labelSize,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  tanggal,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                    height: 1.1,
                  ),
                ),
              ],
            ),
          ),
          Container(
            width: 1,
            height: 44,
            margin: const EdgeInsets.symmetric(horizontal: 12),
            color: Colors.white.withOpacity(0.25),
          ),
          Expanded(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  'Tugas hari ini',
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.85),
                    fontSize: labelSize,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  '$tasks',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: taskValueSize,
                    fontWeight: FontWeight.w700,
                    height: 1.1,
                  ),
                ),
              ],
            ),
          ),
        ],
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
    _autoScrollTimer = Timer.periodic(const Duration(seconds: 5), (_) {
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
              "Operasional hari Ini",
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
            ),
            TextButton(
              onPressed: () {
                Navigator.pushNamed(context, '/dashboard');
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
      children:  [
        _StatCard(title: "Servis Hari ini", value: "24", assetPath: "assets/icons/servishariini.svg", ),
        _StatCard(title: "Perlu di Assign", value: "12",  assetPath: "assets/icons/assign.svg",),
        _StatCard(title: "Feedback", value: "5", assetPath: "assets/icons/feedback.svg",),
        _StatCard(title: "Selesai", value: "2", assetPath: "assets/icons/selesai.svg",),
      ],
    );
  },
),

        const SizedBox(height: 24),

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
    if (width > 700) columns = 5;
    else if (width > 500) columns = 4;

    // 🔹 Hitung lebar item biar pas dan sejajar batas StatCard
    final double spacing = 16;
    final double itemWidth = (width - (columns - 1) * spacing - 32) / columns;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Wrap(
        spacing: spacing,
        runSpacing: 18,
        alignment: WrapAlignment.start,
        children: [
          _QuickFeature(
            assetPath: 'assets/icons/riwayatservis.svg',
            label: "Riwayat\nServis",
            iconSize: 26,
            onTap: () {},
          ),
          _QuickFeature(
            assetPath: 'assets/icons/terimajadwal.svg',
            label: "Terima\nJadwal",
            iconSize: 26,
            onTap: () {},
          ),
          _QuickFeature(
            assetPath: 'assets/icons/feedback.svg',
            label: "Umpan\nBalik",
            iconSize: 26,
            onTap: () {},
          ),
        ].map((w) => SizedBox(width: itemWidth, child: w)).toList(),
      ),
    );
  },
),

const SizedBox(height: 24),


        // removed extra gap - langsung Warning card

        Card(
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          elevation: 2,
          child: InkWell(
            borderRadius: BorderRadius.circular(16),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const ServicePageAdmin()),
              );
            },
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  SizedBox(
                    width: 36,
                    height: 36,
                    child: Image.asset(
                      'assets/icons/antrian.png',
                      fit: BoxFit.contain,
                      errorBuilder: (context, error, stackTrace) => const Icon(
                        Icons.warning_amber_rounded,
                        color: Color(0xFF5C36F4),
                        size: 36,
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  const Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "Cek list antrian pelanggan kamu!!",
                          style: TextStyle(
                              fontSize: 14, fontWeight: FontWeight.w600),
                        ),
                        SizedBox(height: 4),
                        Text(
                          "Klik tombol dibawah ini untuk masuk menu Service",
                          style: TextStyle(fontSize: 12),
                        ),
                      ],
                    ),
                  ),
                  const Icon(Icons.arrow_forward_ios,
                      size: 16, color: Colors.grey),
                ],
              ),
            ),
          ),
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
    this.updateDate = "2 days ago",
    this.percentage = "+15%",
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    final bool isNegative = percentage.startsWith('-');
    final Color trendColor = isNegative ? Colors.red : Colors.green;

    final screenWidth = MediaQuery.of(context).size.width;

    // 🔹 Ukuran adaptif berdasarkan lebar layar
    final double iconSize = screenWidth < 360 ? 24 : 28;
    final double fontSizeTitle = screenWidth < 360 ? 12 : 13;
    final double fontSizeValue = screenWidth < 360 ? 20 : 24;
    final double fontSizeFooter = screenWidth < 360 ? 9 : 11;
    final double iconSizeFooter = screenWidth < 360 ? 9 : 10.5;
    final double paddingVertical = screenWidth < 360 ? 8 : 10;
    final double paddingHorizontal = screenWidth < 360 ? 10 : 14;

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
      padding: EdgeInsets.symmetric(
        horizontal: paddingHorizontal,
        vertical: paddingVertical,
      ),
      child: IntrinsicHeight(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 🔹 Judul
            Text(
              title,
              style: TextStyle(
                fontSize: fontSizeTitle,
                fontWeight: FontWeight.w600,
                color: const Color(0xFFDC2626),
              ),
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 4),

            // 🔹 Angka + Icon sejajar
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Flexible(
                  child: Text(
                    value,
                    style: TextStyle(
                      fontSize: fontSizeValue,
                      fontWeight: FontWeight.bold,
                      color: const Color(0xFFDC2626),
                    ),
                    overflow: TextOverflow.ellipsis,
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

            // 🔹 Footer update + persen (versi responsif)
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Flexible(
                  child: Text(
                    "Update: $updateDate",
                    style: TextStyle(
                      fontSize: fontSizeFooter,
                      color: Colors.grey.shade600,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                const SizedBox(width: 4),
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      isNegative ? Icons.arrow_downward : Icons.arrow_upward,
                      size: iconSizeFooter,
                      color: trendColor,
                    ),
                    const SizedBox(width: 2),
                    Text(
                      percentage,
                      style: TextStyle(
                        fontSize: fontSizeFooter,
                        fontWeight: FontWeight.w500,
                        color: trendColor,
                      ),
                      overflow: TextOverflow.ellipsis,
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
