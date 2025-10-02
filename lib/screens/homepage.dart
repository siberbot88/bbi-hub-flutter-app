import 'dart:async';
import 'package:flutter/foundation.dart';
import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'dart:math' as math;
import 'dart:math' as math;
import 'package:flutter/services.dart';
import 'service_page.dart';
import 'package:google_fonts/google_fonts.dart';

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
         fontFamily: GoogleFonts.poppins().fontFamily,
        textTheme: GoogleFonts.poppinsTextTheme(),
      ),
      home: const HomePage(),
      debugShowCheckedModeBanner: false,
    );
  }
}

// ---------------- HomePage ----------------
import 'service_page.dart';
import 'package:google_fonts/google_fonts.dart';

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
        fontFamily: 'Roboto',
      ),
      home: const HomePage(),
      debugShowCheckedModeBanner: false,
    );
  }
}

// ---------------- HomePage ----------------
class HomePage extends StatelessWidget {
  const HomePage({super.key});
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const RoundelAppBar(),
      body: const HomeContent(),
      body: const HomeContent(),
    );
  }
}

// ---------------- AppBar with Roundels ----------------
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
    this.userName = 'AHASS',
    this.roleLabel = 'workshop manager',
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
          // gradient utama AppBar: DC2626 -> 000000
          // gradient utama AppBar: DC2626 -> 000000
          Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [Color(0xFFDC2626), Color(0xFF000000)],
                colors: [Color(0xFFDC2626), Color(0xFF000000)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
          ),

          // roundels (tidak const karena gradient non-const di dalamnya)
          Positioned(

          // roundels (tidak const karena gradient non-const di dalamnya)
          Positioned(
            right: -40,
            top: -10,
            child: _Roundel(
              size: 240,
              innerColor: const Color(0xFFDC2626),
              outerColor: const Color(0xFF000000),
              opacity: 0.55,
            ),
            child: _Roundel(
              size: 240,
              innerColor: const Color(0xFFDC2626),
              outerColor: const Color(0xFF000000),
              opacity: 0.55,
            ),
          ),
          Positioned(
          Positioned(
            left: -60,
            top: -30,
            child: _Roundel(
              size: 200,
              innerColor: const Color(0xFFDC2626),
              outerColor: const Color(0xFF000000),
              opacity: 0.35,
            ),
            child: _Roundel(
              size: 200,
              innerColor: const Color(0xFFDC2626),
              outerColor: const Color(0xFF000000),
              opacity: 0.35,
            ),
          ),
          Positioned(
          Positioned(
            left: -20,
            bottom: -70,
            child: _Roundel(
              size: 280,
              innerColor: const Color(0xFF000000),
              outerColor: const Color(0xFF000000),
              opacity: 0.35,
            ),
            child: _Roundel(
              size: 280,
              innerColor: const Color(0xFF000000),
              outerColor: const Color(0xFF000000),
              opacity: 0.35,
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
                              style: GoogleFonts.poppins(
                                color: Colors.white,
                                fontWeight: FontWeight.w700,
                                fontSize: appNameSize,
                                letterSpacing: .3,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                            
                           SizedBox(height: 2),
                            Text(
                              roleLabel,
                              style: GoogleFonts.poppins(
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
                   SizedBox(height: 76),
                   Padding(padding: EdgeInsets.only(left: 20)),
                  Text(
                    'Selamat $waktu, $userName',
                    style: GoogleFonts.poppins(
                      color: Colors.white,
                      fontSize: greetingSize,
                      fontWeight: FontWeight.w700,
                      height: 1.1,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                   SizedBox(height: 4),
                  Text(
                    'workshop Anda untuk hari ini',
                    style: GoogleFonts.poppins(
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
  final Color innerColor;
  final Color outerColor;
  final double opacity;

  const _Roundel({
    required this.size,
    required this.innerColor,
    required this.outerColor,
    this.opacity = 0.6,
  });

  const _Roundel({
    required this.size,
    required this.innerColor,
    required this.outerColor,
    this.opacity = 0.6,
  });

  @override
  Widget build(BuildContext context) {
    // radial gradient dari innerColor -> blend -> outerColor (diatur transparan agar menyatu)
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
            center: const Alignment(-0.2, -0.2),
            radius: 0.8,
            colors: [
              innerColor.withOpacity(opacity),
              Color.lerp(innerColor, outerColor, 0.5)!
                  .withOpacity(opacity * 0.6),
              outerColor.withOpacity(0.0),
              innerColor.withOpacity(opacity),
              Color.lerp(innerColor, outerColor, 0.5)!
                  .withOpacity(opacity * 0.6),
              outerColor.withOpacity(0.0),
            ],
            stops: const [0.0, 0.6, 1.0],
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
                  style: GoogleFonts.poppins(
                    color: Colors.white.withOpacity(0.85),
                    fontSize: labelSize,
                  ),
                ),
                 SizedBox(height: 4),
                Text(
                  tanggal,
                  style: GoogleFonts.poppins(
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
                  style: GoogleFonts.poppins(
                    color: Colors.white.withOpacity(0.85),
                    fontSize: labelSize,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  '$tasks',
                  style: GoogleFonts.poppins(
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
    BannerData(
        imagePath: 'assets/image/banner1.png'),
    BannerData(
        imagePath: 'assets/image/banner2.png'),
    BannerData(
        imagePath: 'assets/image/banner3.png'),
    BannerData(
        imagePath: 'assets/image/banner4.png'),
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

    if (_bannerController.hasClients) {
      _bannerController.animateToPage(
        next,
        duration: const Duration(milliseconds: 450),
        curve: Curves.easeInOut,
      );
    }
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

  // Admin helper: add a demo banner
  void _addBanner() {
    setState(() {
      banners.add(BannerData(
        title: 'New Banner ${banners.length + 1}',
        subtitle: 'Tambahan banner demo',
        imagePath: 'assets/images/banner_placeholder.png',
      ));
    });
  }

  // Admin helper: remove last banner
  void _removeBanner() {
    if (banners.isEmpty) return;
    setState(() {
      banners.removeLast();
      _currentBannerIndex = math.min(_currentBannerIndex, banners.length - 1);
    });
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
  State<HomeContent> createState() => _HomeContentState();
}

class _HomeContentState extends State<HomeContent> {
  final PageController _bannerController = PageController();
  Timer? _autoScrollTimer;
  int _currentBannerIndex = 0;

  // sample banner list (admin can manipulate these)
  final List<BannerData> banners = [
    BannerData(
        title: 'Promo Sparepart',
        subtitle: 'Diskon hingga 30% untuk oli motor',
        imagePath: 'assets/image/banner1.png'),
    BannerData(
        title: 'Service Express',
        subtitle: 'Servis cepat dalam 30 menit',
        imagePath: 'assets/image/banner2.png'),
    BannerData(
        title: 'Paket Hemat',
        subtitle: 'Servis + ganti oli mulai 150k',
        imagePath: 'assets/image/banner3.png'),
    BannerData(
        title: 'Member Special',
        subtitle: 'Cashback 10% untuk member',
        imagePath: 'assets/image/banner4.png'),
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
    }
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

  // Admin helper: add a demo banner
  void _addBanner() {
    setState(() {
      banners.add(BannerData(
        title: 'New Banner ${banners.length + 1}',
        subtitle: 'Tambahan banner demo',
        imagePath: 'assets/images/banner_placeholder.png',
      ));
    });
  }

  // Admin helper: remove last banner
  void _removeBanner() {
    if (banners.isEmpty) return;
    setState(() {
      banners.removeLast();
      _currentBannerIndex = math.min(_currentBannerIndex, banners.length - 1);
    });
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

    final brandColor = const Color(0xFFDC2626);

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        // top row title + detail button
        // top row title + detail button
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
             Text(
              "Kinerja Harian Bengkel",
              style: GoogleFonts.poppins(fontSize: 16, fontWeight: FontWeight.w600),
            ),
            TextButton(
              onPressed: () {},
              child:  Text("Lihat detail",
                  style: GoogleFonts.poppins(color: Color(0xFFDC2626))),
            ),

            TextButton(
              onPressed: () {},
              child: const Text("Lihat detail",
                  style: TextStyle(color: Color(0xFFDC2626))),
            ),
          ],
        ),
        const SizedBox(height: 8),

        // Stat cards

        // Stat cards
        GridView.count(
          crossAxisCount: 2,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          mainAxisSpacing: 12,
          crossAxisSpacing: 12,
          childAspectRatio: 1.2,
          children: const [
            _StatCard(title: "Servis Hari ini", value: "24"),
            _StatCard(title: "Servis Hari ini", value: "24"),
            _StatCard(title: "Servis Selesai", value: "12"),
            _StatCard(title: "Teknisi Aktiff", value: "58"),
            _StatCard(title: "Pendapatan", value: "Rp. 145.000"),
            _StatCard(title: "Pendapatan", value: "Rp. Rp. 145.000"),
            _StatCard(title: "Teknisi Aktiff", value: "58"),
            _StatCard(title: "Pendapatan", value: "Rp. Rp. 145.000"),
          ],
        ),


        const SizedBox(height: 24),

        // Fitur Cepat title (center)
        Center(
          child: Text(
            'Fitur Cepat',
            style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: Colors.black87),
          ),
        ),

        const SizedBox(height: 8),

        // Grid fitur cepat: 4 kolom, lebih besar

        // Fitur Cepat title (center)
        Center(
          child: Text(
            'Fitur Cepat',
            style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: Colors.black87),
          ),
        ),

        const SizedBox(height: 8),

        // Grid fitur cepat: 4 kolom, lebih besar
        GridView.count(
          crossAxisCount: 4,
          crossAxisCount: 4,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          mainAxisSpacing: 12,
          crossAxisSpacing: 12,
          childAspectRatio: 0.95, // sedikit lebih besar/tinggi
          children: [
            _QuickFeature(
              assetPath: 'assets/icons/teknisi.png',
              label: "Tambah\nteknisi",
              onTap: () {},
            ),
            _QuickFeature(
              assetPath: 'assets/icons/search.png',
              label: "List\nservice",
              onTap: () {},
            ),
            _QuickFeature(
              assetPath: 'assets/icons/dashboard_tipis.png',
              label: "Dashboard",
              onTap: () {},
            ),
            _QuickFeature(
              assetPath: 'assets/icons/voucher.png',
              label: "Tambah\nVoucher",
              onTap: () {},
            ),
          childAspectRatio: 0.95, // sedikit lebih besar/tinggi
          children: [
            _QuickFeature(
              assetPath: 'assets/icons/teknisi.png',
              label: "Tambah\nteknisi",
              onTap: () {},
            ),
            _QuickFeature(
              assetPath: 'assets/icons/search.png',
              label: "List\nservice",
              onTap: () {},
            ),
            _QuickFeature(
              assetPath: 'assets/icons/dashboard_tipis.png',
              label: "Dashboard",
              onTap: () {},
            ),
            _QuickFeature(
              assetPath: 'assets/icons/voucher.png',
              label: "Tambah\nVoucher",
              onTap: () {},
            ),
          ],
        ),

        // removed extra gap - langsung Warning card



        Card(
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          elevation: 2,
          child: InkWell(
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          elevation: 2,
          child: InkWell(
            borderRadius: BorderRadius.circular(16),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const ServicePage()),
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

                   SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "Cek list antrian pelanggan kamu!!",
                          style: GoogleFonts.poppins(
                              fontSize: 14, fontWeight: FontWeight.w600),
                        ),
                        SizedBox(height: 4),
                        Text(
                          "Klik tombol dibawah ini untuk masuk menu Service",
                          style: GoogleFonts.poppins(fontSize: 12),

                        ),
                      ],
                    ),
                  ),
                  const Icon(Icons.arrow_forward_ios,
                      size: 16, color: Colors.grey),
                ],
              ),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const ServicePage()),
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

        // Banner carousel + controls (auto scroll + add/remove)
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
             Text('Promo & Banner',
                style: GoogleFonts.poppins(fontWeight: FontWeight.w600)),
            Row(
              children: [
                IconButton(
                  tooltip:
                      autoScroll ? 'Stop auto-scroll' : 'Start auto-scroll',
                  icon:
                      Icon(autoScroll ? Icons.pause_circle : Icons.play_circle),
                  color: brandColor,
                  onPressed: () {
                    setState(() {
                      autoScroll = !autoScroll;
                      if (autoScroll) {
                        _startAutoScroll();
                      } else {
                        _stopAutoScroll();
                      }
                    });
                  },
                ),
                IconButton(
                  tooltip: 'Tambah banner (demo)',
                  icon: const Icon(Icons.add),
                  color: brandColor,
                  onPressed: _addBanner,
                ),
                IconButton(
                  tooltip: 'Hapus banner terakhir',
                  icon: const Icon(Icons.delete_outline),
                  color: brandColor,
                  onPressed: _removeBanner,
                ),
              ],
            )
          ],
        ),

        const SizedBox(height: 8),

        // PageView banner
        SizedBox(
          height: 160,
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
                                      children: [
                                        Text(b.title,
                                            style:  GoogleFonts.poppins(
                                                color: Colors.white,
                                                fontSize: 18,
                                                fontWeight: FontWeight.w600),
                                            textAlign: TextAlign.center),

                                         SizedBox(height: 8),
                                        Text(b.subtitle,
                                            style:  GoogleFonts.poppins(
                                                color: Colors.white70,
                                                fontSize: 12),
                                            textAlign: TextAlign.center),
                                      ],
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
                              children: [
                                Text(b.title,
                                    style:  GoogleFonts.poppins(
                                        color: Colors.white,
                                        fontSize: 16,
                                        fontWeight: FontWeight.w700)),
                                const SizedBox(height: 4),
                                Text(b.subtitle,
                                    style: GoogleFonts.poppins(
                                        color: Colors.white.withOpacity(0.9),
                                        fontSize: 12)),
                              ],
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

        // Banner carousel + controls (auto scroll + add/remove)
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text('Promo & Banner',
                style: TextStyle(fontWeight: FontWeight.w600)),
            Row(
              children: [
                IconButton(
                  tooltip:
                      autoScroll ? 'Stop auto-scroll' : 'Start auto-scroll',
                  icon:
                      Icon(autoScroll ? Icons.pause_circle : Icons.play_circle),
                  color: brandColor,
                  onPressed: () {
                    setState(() {
                      autoScroll = !autoScroll;
                      if (autoScroll) {
                        _startAutoScroll();
                      } else {
                        _stopAutoScroll();
                      }
                    });
                  },
                ),
                IconButton(
                  tooltip: 'Tambah banner (demo)',
                  icon: const Icon(Icons.add),
                  color: brandColor,
                  onPressed: _addBanner,
                ),
                IconButton(
                  tooltip: 'Hapus banner terakhir',
                  icon: const Icon(Icons.delete_outline),
                  color: brandColor,
                  onPressed: _removeBanner,
                ),
              ],
            )
          ],
        ),

        const SizedBox(height: 8),

        // PageView banner
        SizedBox(
          height: 160,
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
                                      children: [
                                        Text(b.title,
                                            style: const TextStyle(
                                                color: Colors.white,
                                                fontSize: 18,
                                                fontWeight: FontWeight.w600),
                                            textAlign: TextAlign.center),
                                        const SizedBox(height: 8),
                                        Text(b.subtitle,
                                            style: const TextStyle(
                                                color: Colors.white70,
                                                fontSize: 12),
                                            textAlign: TextAlign.center),
                                      ],
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
                              children: [
                                Text(b.title,
                                    style: const TextStyle(
                                        color: Colors.white,
                                        fontSize: 16,
                                        fontWeight: FontWeight.w700)),
                                const SizedBox(height: 4),
                                Text(b.subtitle,
                                    style: TextStyle(
                                        color: Colors.white.withOpacity(0.9),
                                        fontSize: 12)),
                              ],
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

        // Banner carousel + controls (auto scroll + add/remove)
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text('Promo & Banner',
                style: TextStyle(fontWeight: FontWeight.w600)),
            // Row(
            //   children: [
            //     // IconButton(
            //     //   tooltip:
            //     //       autoScroll ? 'Stop auto-scroll' : 'Start auto-scroll',
            //     //   icon:
            //     //       Icon(autoScroll ? Icons.pause_circle : Icons.play_circle),
            //     //   color: brandColor,
            //     //   onPressed: () {
            //     //     setState(() {
            //     //       autoScroll = !autoScroll;
            //     //       if (autoScroll) {
            //     //         _startAutoScroll();
            //     //       } else {
            //     //         _stopAutoScroll();
            //     //       }
            //     //     });
            //     //   },
            //     // ),
            //     // IconButton(
            //     //   tooltip: 'Tambah banner (demo)',
            //     //   icon: const Icon(Icons.add),
            //     //   color: brandColor,
            //     //   onPressed: _addBanner,
            //     // ),
            //     // IconButton(
            //     //   tooltip: 'Hapus banner terakhir',
            //     //   icon: const Icon(Icons.delete_outline),
            //     //   color: brandColor,
            //     //   onPressed: _removeBanner,
            //     // ),
            //   ],
            // )
          ],
        ),

        const SizedBox(height: 8),

        // PageView banner
        SizedBox(
          height: 400,
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
// ---------------- Stat Card ----------------
class _StatCard extends StatelessWidget {
  final String title;
  final String value;
  const _StatCard({required this.title, required this.value});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
          color: Colors.red.shade50, borderRadius: BorderRadius.circular(16)),
          color: Colors.red.shade50, borderRadius: BorderRadius.circular(16)),
      padding: const EdgeInsets.all(16),
      child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
        Text(value,
            style:  GoogleFonts.poppins(
                fontSize: 20, fontWeight: FontWeight.bold, color: Colors.red)),
        const SizedBox(height: 6),
        Text(title,
            style:  GoogleFonts.poppins(fontSize: 13), textAlign: TextAlign.center),
      ]),
      child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
        Text(value,
            style: const TextStyle(
                fontSize: 20, fontWeight: FontWeight.bold, color: Colors.red)),
        const SizedBox(height: 6),
        Text(
          title,
          style: GoogleFonts.poppins(
            fontSize: 13,
          ),
          textAlign: TextAlign.center,
        ),
      ],
    ),
  );
}


}

// ---------------- Quick Feature (interactive) ----------------
class _QuickFeature extends StatefulWidget {
  final IconData? icon;
  final String? assetPath;
// ---------------- Quick Feature (interactive) ----------------
class _QuickFeature extends StatefulWidget {
  final IconData? icon;
  final String? assetPath;
  final String label;
  final double iconSize = 32;
  final VoidCallback? onTap;

  const _QuickFeature({
    this.icon,
    this.assetPath,
    required this.label,
    this.onTap,
  }) : assert(icon != null || assetPath != null, 'Berikan icon atau assetPath');

  @override
  State<_QuickFeature> createState() => _QuickFeatureState();
}

class _QuickFeatureState extends State<_QuickFeature>
    with SingleTickerProviderStateMixin {
  late final AnimationController _animationController;
  late final Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
        duration: const Duration(milliseconds: 120), vsync: this);
    _scaleAnimation = Tween<double>(begin: 1.0, end: 0.92).animate(
        CurvedAnimation(parent: _animationController, curve: Curves.easeOut));
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  // for hover on desktop/web
  bool _hovering = false;
  final double iconSize;
  final VoidCallback? onTap;

  const _QuickFeature({
    this.icon,
    this.assetPath,
    required this.label,
    this.iconSize = 28,
    this.onTap,
    super.key,
  }) : assert(icon != null || assetPath != null, 'Berikan icon atau assetPath');

  @override
  State<_QuickFeature> createState() => _QuickFeatureState();
}

class _QuickFeatureState extends State<_QuickFeature>
    with SingleTickerProviderStateMixin {
  late final AnimationController _animationController;
  late final Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
        duration: const Duration(milliseconds: 120), vsync: this);
    _scaleAnimation = Tween<double>(begin: 1.0, end: 0.92).animate(
        CurvedAnimation(parent: _animationController, curve: Curves.easeOut));
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  // for hover on desktop/web
  bool _hovering = false;

  @override
  Widget build(BuildContext context) {
    final bg = Colors.red.shade100;

    Widget iconWidget;
    if (widget.assetPath != null) {
      // use Image.asset with errorBuilder so app doesn't crash if not found
      iconWidget = Image.asset(
        widget.assetPath!,
        width: widget.iconSize,
        height: widget.iconSize,
        fit: BoxFit.contain,
        // if your PNG is monochrome and you want tinting, use ImageIcon(AssetImage(...))
        errorBuilder: (context, error, stackTrace) {
          return Icon(widget.icon ?? Icons.help_outline,
              size: widget.iconSize, color: Colors.red);
        },
      );
    } else {
      iconWidget = Icon(widget.icon, size: widget.iconSize, color: Colors.red);
    }

    final child = Column(
      mainAxisSize: MainAxisSize.min,
    final bg = Colors.red.shade100;

    Widget iconWidget;
    if (widget.assetPath != null) {
      // use Image.asset with errorBuilder so app doesn't crash if not found
      iconWidget = Image.asset(
        widget.assetPath!,
        width: widget.iconSize,
        height: widget.iconSize,
        fit: BoxFit.contain,
        // if your PNG is monochrome and you want tinting, use ImageIcon(AssetImage(...))
        errorBuilder: (context, error, stackTrace) {
          return Icon(widget.icon ?? Icons.help_outline,
              size: widget.iconSize, color: Colors.red);
        },
      );
    } else {
      iconWidget = Icon(widget.icon, size: widget.iconSize, color: Colors.red);
    }

    final child = Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          decoration:
              BoxDecoration(color: bg, borderRadius: BorderRadius.circular(12)),
          padding: const EdgeInsets.all(10),
          child: iconWidget,
          decoration:
              BoxDecoration(color: bg, borderRadius: BorderRadius.circular(12)),
          padding: const EdgeInsets.all(10),
          child: iconWidget,
        ),
        const SizedBox(height: 6),
        Text(widget.label,
            style:  GoogleFonts.poppins(fontSize: 11), textAlign: TextAlign.center),
      ],
    );

    Widget interactive = GestureDetector(
      onTapDown: (_) => _animationController.forward(),
      onTapCancel: () => _animationController.reverse(),
      onTapUp: (_) {
        _animationController.reverse();
        widget.onTap?.call();
      },
      child: ScaleTransition(scale: _scaleAnimation, child: child),
    );

    if (kIsWeb ||
        Theme.of(context).platform == TargetPlatform.macOS ||
        Theme.of(context).platform == TargetPlatform.windows ||
        Theme.of(context).platform == TargetPlatform.linux) {
      // wrap with MouseRegion for hover effect on web/desktop
      interactive = MouseRegion(
        onEnter: (_) => setState(() => _hovering = true),
        onExit: (_) => setState(() => _hovering = false),
        cursor: SystemMouseCursors.click,
        child: AnimatedScale(
            scale: _hovering ? 1.03 : 1.0,
            duration: const Duration(milliseconds: 120),
            child: interactive),
      );
    }

    return interactive;
  }
        Text(widget.label,
            style:  GoogleFonts.poppins(fontSize: 11), textAlign: TextAlign.center),
      ],
    );

    Widget interactive = GestureDetector(
      onTapDown: (_) => _animationController.forward(),
      onTapCancel: () => _animationController.reverse(),
      onTapUp: (_) {
        _animationController.reverse();
        widget.onTap?.call();
      },
      child: ScaleTransition(scale: _scaleAnimation, child: child),
    );

    if (kIsWeb ||
        Theme.of(context).platform == TargetPlatform.macOS ||
        Theme.of(context).platform == TargetPlatform.windows ||
        Theme.of(context).platform == TargetPlatform.linux) {
      // wrap with MouseRegion for hover effect on web/desktop
      interactive = MouseRegion(
        onEnter: (_) => setState(() => _hovering = true),
        onExit: (_) => setState(() => _hovering = false),
        cursor: SystemMouseCursors.click,
        child: AnimatedScale(
            scale: _hovering ? 1.03 : 1.0,
            duration: const Duration(milliseconds: 120),
            child: interactive),
      );
    }

    return interactive;
  }
    
    Widget interactive = GestureDetector(
      onTapDown: (_) => _animationController.forward(),
      onTapCancel: () => _animationController.reverse(),
      onTapUp: (_) {
        _animationController.reverse();
        widget.onTap?.call();
      },
      child: ScaleTransition(scale: _scaleAnimation, child: child),
    );

    if (kIsWeb ||
        Theme.of(context).platform == TargetPlatform.macOS ||
        Theme.of(context).platform == TargetPlatform.windows ||
        Theme.of(context).platform == TargetPlatform.linux) {
      // wrap with MouseRegion for hover effect on web/desktop
      interactive = MouseRegion(
        onEnter: (_) => setState(() => _hovering = true),
        onExit: (_) => setState(() => _hovering = false),
        cursor: SystemMouseCursors.click,
        child: AnimatedScale(
            scale: _hovering ? 1.03 : 1.0,
            duration: const Duration(milliseconds: 120),
            child: interactive),
      );
    }

    return interactive;
  }
}

// ---------------- BannerData ----------------
class BannerData {
  final String title;
  final String subtitle;
  final String imagePath;
  BannerData(
      {required this.title, required this.subtitle, required this.imagePath});
}

// ---------------- Helpers ----------------
// ---------------- BannerData ----------------
class BannerData {
  final String title;
  final String subtitle;
  final String imagePath;
  BannerData(
      {required this.title, required this.subtitle, required this.imagePath});
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
