import 'dart:async';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../core/services/auth_provider.dart';
import '../providers/admin_service_provider.dart';
import 'package:bengkel_online_flutter/core/models/dashboard_stats.dart';
import 'service_page.dart';
import 'feedback.dart';
import '../widgets/home/home_app_bar.dart';
import '../widgets/home/home_stat_card.dart';
import '../widgets/home/home_quick_feature.dart';

// Admin Homepage - Clean entry point
class HomePage extends StatelessWidget {
  final void Function(int, {int? serviceTab, String? serviceFilter})? onTabChange;
  
  const HomePage({super.key, this.onTabChange});
  
  @override
  Widget build(BuildContext context) {
    final user = context.watch<AuthProvider>().user;
    return Scaffold(
      appBar: HomeAppBar(
        userName: user?.name ?? "Admin",
      ),
      body: HomeContent(onTabChange: onTabChange),
    );
  }
}

// Home content with stats, quick features, and banners
class HomeContent extends StatefulWidget {
  final void Function(int, {int? serviceTab, String? serviceFilter})? onTabChange;
  
  const HomeContent({super.key, this.onTabChange});

  @override
  State<HomeContent> createState() => _HomeContentState();
}

class _HomeContentState extends State<HomeContent> {
  final PageController _bannerController = PageController();
  Timer? _autoScrollTimer;
  int _currentBannerIndex = 0;
  
  // Dashboard stats from API
  DashboardStats? _stats;
  bool _loadingStats = true;

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
    _fetchDashboardStats();
  }
  
  void _fetchDashboardStats() async {
    try {
      final provider = context.read<AdminServiceProvider>();
      final auth = context.read<AuthProvider>();
      final stats = await provider.fetchDashboardStats(
        workshopUuid: auth.user?.workshopUuid,
      );
      if (mounted) {
        setState(() {
          _stats = stats;
          _loadingStats = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() => _loadingStats = false);
        print('Error fetching home stats: $e');
      }
    }
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
    _stopAutoScroll();
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
                // Switch to Dashboard tab (index 2)
                widget.onTabChange?.call(2);
              },
              child: const Text("Lihat detail",
                  style: TextStyle(color: Color(0xFFDC2626))),
            ),
          ],
        ),
        const SizedBox(height: 8),

        // Stat cards grid - use API data
        GridView.count(
          crossAxisCount: 2,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          mainAxisSpacing: 12,
          crossAxisSpacing: 12,
          childAspectRatio: 1.6,
          children: [
            HomeStatCard(
              title: "Servis Hari ini",
              value: "${_stats?.servicesToday ?? 0}",
              assetPath: "assets/icons/servishariini.svg",
              isLoading: _loadingStats,
            ),
            HomeStatCard(
              title: "Perlu di Assign",
              value: "${_stats?.needsAssignment ?? 0}",
              assetPath: "assets/icons/assign.svg",
              isLoading: _loadingStats,
            ),
            HomeStatCard(
              title: "Sedang Dikerjakan",
              value: "${_stats?.inProgress ?? 0}",
              assetPath: "assets/icons/feedback.svg",
              isLoading: _loadingStats,
            ),
            HomeStatCard(
              title: "Selesai",
              value: "${_stats?.completed ?? 0}",
              assetPath: "assets/icons/selesai.svg",
              isLoading: _loadingStats,
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
            if (width > 700) {
              columns = 5;
            } else if (width > 500) {
              columns = 4;
            }

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
                    onTap: () {
                      // Tab 1 (Service), Sub-tab 2 (Logging), Filter Lunas
                      widget.onTabChange?.call(1, serviceTab: 2, serviceFilter: "Lunas");
                    },
                  ),
                  HomeQuickFeature(
                    assetPath: 'assets/icons/terimajadwal.svg',
                    label: "Terima\nJadwal",
                    iconSize: 26,
                    onTap: () {
                      // Tab 1 (Service), Sub-tab 0 (Scheduled), Filter Menunggu
                      widget.onTabChange?.call(1, serviceTab: 0, serviceFilter: "Menunggu");
                    },
                  ),
                  HomeQuickFeature(
                    assetPath: 'assets/icons/feedback.svg',
                    label: "Umpan\nBalik",
                    iconSize: 26,
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => const FeedbackPage()),
                      );
                    },
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
                                  Colors.black.withAlpha(115)
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
                    backgroundColor: brandColor.withAlpha(31),
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
                color: isActive ? brandColor : Colors.grey.withAlpha(64),
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
