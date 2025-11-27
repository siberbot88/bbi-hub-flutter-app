import 'package:flutter/material.dart';

import 'package:bengkel_online_flutter/core/theme/app_colors.dart';
import 'package:bengkel_online_flutter/core/theme/app_text_styles.dart';
import '../widgets/custom_header.dart';

class FeedbackPage extends StatefulWidget {
  const FeedbackPage({super.key});

  @override
  State<FeedbackPage> createState() => _FeedbackPageState();
}

class _FeedbackPageState extends State<FeedbackPage> with SingleTickerProviderStateMixin {
  String _selectedFilter = 'semua'; // semua | 5 | 4 | 3 | 2 | 1

  // Animation Controller for manual staggered animation
  late final AnimationController _animController;

  final _reviews = <_Review>[
    _Review(
      initials: 'BS',
      name: 'Budi Santoso',
      ago: '1 hari lalu',
      stars: 5,
      service: 'Ganti Oli & Tune Up',
      text: 'Pelayanan sangat memuaskan! Mekanik ramah dan profesional. Harga juga transparan, dijelaskan detail sebelum pengerjaan. Pasti balik lagi!',
    ),
    _Review(
      initials: 'SN',
      name: 'Siti Nurhaliza',
      ago: '2 hari lalu',
      stars: 5,
      service: 'Service Berkala',
      text: 'Bengkel terbaik yang pernah saya kunjungi. Ruang tunggu nyaman, wifi kenceng, dan pengerjaan cepat. Recommended!',
    ),
    _Review(
      initials: 'AW',
      name: 'Andi Wijaya',
      ago: '1 minggu lalu',
      stars: 4,
      service: 'Perbaikan AC Mobil',
      text: 'Overall bagus, AC mobil jadi dingin lagi. Cuma agak lama nunggu karena ramai. Tapi hasil kerjanya oke.',
    ),
    _Review(
      initials: 'DL',
      name: 'Dewi Lestari',
      ago: '1 minggu lalu',
      stars: 5,
      service: 'Ganti Ban & Balancing',
      text: 'Cepat dan rapi! Mekaniknya juga kasih saran untuk perawatan ban. Tempatnya bersih dan nyaman.',
    ),
    _Review(
      initials: 'RH',
      name: 'Rudi Hartono',
      ago: '2 minggu lalu',
      stars: 5,
      service: 'Servis Rem',
      text: 'Bagus, rem mobil jadi pakem lagi. Harga standar, sesuai dengan kualitas pekerjaan.',
    ),
  ];

  @override
  void initState() {
    super.initState();
    _animController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    )..forward();
  }

  @override
  void dispose() {
    _animController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final filtered = _selectedFilter == 'semua'
        ? _reviews
        : _reviews.where((r) => r.stars.toString() == _selectedFilter).toList();

    return Scaffold(
      backgroundColor: AppColors.backgroundLight,
      appBar: const CustomHeader(
        title: 'Rating & Ulasan',
        showBack: true,
        roundedBottomRadius: 28,
      ),
      body: AnimatedBuilder(
        animation: _animController,
        builder: (context, child) {
          return ListView(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
            physics: const BouncingScrollPhysics(),
            children: [
              _buildAnimatedItem(0, _searchBar()),
              const SizedBox(height: 16),
              _buildAnimatedItem(1, _ratingSummaryCard()),
              const SizedBox(height: 16),
              _buildAnimatedItem(2, _filterChips()),
              const SizedBox(height: 16),
              ...List.generate(filtered.length, (index) {
                return Column(
                  children: [
                    _buildAnimatedItem(3 + index, _reviewCard(filtered[index])),
                    const SizedBox(height: 12),
                  ],
                );
              }),
              _buildAnimatedItem(3 + filtered.length, _seeMore()),
            ],
          );
        },
      ),
    );
  }

  Widget _buildAnimatedItem(int index, Widget child) {
    final delay = index * 0.1;
    final animation = CurvedAnimation(
      parent: _animController,
      curve: Interval(
        (delay).clamp(0.0, 1.0),
        (delay + 0.4).clamp(0.0, 1.0),
        curve: Curves.easeOutCubic,
      ),
    );

    return FadeTransition(
      opacity: animation,
      child: SlideTransition(
        position: Tween<Offset>(
          begin: const Offset(0, 0.2),
          end: Offset.zero,
        ).animate(animation),
        child: child,
      ),
    );
  }

  // ---------- SEARCH ----------
  Widget _searchBar() {
    return Container(
      height: 48,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: AppColors.shadow,
            blurRadius: 12,
            offset: const Offset(0, 4),
          )
        ],
      ),
      child: TextField(
        style: AppTextStyles.bodyMedium(),
        decoration: InputDecoration(
          hintText: 'Cari ulasan pelanggan...',
          hintStyle: AppTextStyles.bodyMedium(color: AppColors.textHint),
          prefixIcon: const Icon(Icons.search, color: AppColors.textSecondary),
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(vertical: 14),
        ),
      ),
    );
  }

  // ---------- RATING SUMMARY CARD ----------
  Widget _ratingSummaryCard() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: AppColors.shadow,
            blurRadius: 16,
            offset: const Offset(0, 4),
          )
        ],
      ),
      padding: const EdgeInsets.all(20),
      child: Column(
        children: [
          Row(
            children: [
              // Left: Big Number
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('4.8', style: AppTextStyles.heading1(color: AppColors.textPrimary).copyWith(fontSize: 42)),
                    const SizedBox(height: 4),
                    _starsRow(5, size: 20),
                    const SizedBox(height: 8),
                    Text('247 Ulasan', style: AppTextStyles.bodySmall()),
                  ],
                ),
              ),
              // Right: Progress Bars
              SizedBox(
                width: 160,
                child: Column(
                  children: const [
                    _RatingBarRow(label: '5', percent: 0.86, count: 198),
                    SizedBox(height: 8),
                    _RatingBarRow(label: '4', percent: 0.16, count: 37),
                    SizedBox(height: 8),
                    _RatingBarRow(label: '3', percent: 0.06, count: 10),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          // Badges
          Row(
            children: [
              _statBadge(
                icon: Icons.thumb_up_alt_rounded,
                label: '96% Kepuasan',
                color: AppColors.success,
              ),
              const SizedBox(width: 12),
              _statBadge(
                icon: Icons.trending_up_rounded,
                label: '4.9 Bulan ini',
                color: AppColors.primaryRed,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _statBadge({required IconData icon, required String label, required Color color}) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 12),
        decoration: BoxDecoration(
          color: color.withAlpha(25),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 16, color: color),
            const SizedBox(width: 8),
            Flexible(
              child: Text(
                label,
                style: AppTextStyles.label(color: color).copyWith(fontWeight: FontWeight.w700),
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ---------- FILTER CHIPS ----------
  Widget _filterChips() {
    final filters = ['semua', '5', '4', '3', '2', '1'];
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      physics: const BouncingScrollPhysics(),
      child: Row(children: filters.map((f) => _chip(f)).toList()),
    );
  }

  Widget _chip(String value) {
    final isAll = value == 'semua';
    final selected = _selectedFilter == value;

    final Color bg = selected ? AppColors.primaryRed : Colors.white;
    final Color border = selected ? AppColors.primaryRed : AppColors.border;
    final Color textColor = selected ? Colors.white : AppColors.textSecondary;

    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: GestureDetector(
        onTap: () => setState(() => _selectedFilter = value),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
          decoration: BoxDecoration(
            color: bg,
            borderRadius: BorderRadius.circular(24),
            border: Border.all(color: border),
            boxShadow: selected
                ? [
                    BoxShadow(
                      color: AppColors.primaryRed.withAlpha(80),
                      blurRadius: 8,
                      offset: const Offset(0, 4),
                    )
                  ]
                : [],
          ),
          child: Row(
            children: [
              if (isAll) ...[
                Icon(Icons.filter_list_rounded, size: 16, color: textColor),
                const SizedBox(width: 6),
              ] else ...[
                Icon(Icons.star_rounded, size: 16, color: selected ? Colors.white : AppColors.warning),
                const SizedBox(width: 6),
              ],
              Text(
                isAll ? 'Semua' : value,
                style: AppTextStyles.label(color: textColor),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ---------- REVIEW CARD ----------
  Widget _reviewCard(_Review r) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: AppColors.shadow,
            blurRadius: 12,
            offset: const Offset(0, 4),
          )
        ],
      ),
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _initialsAvatar(r.initials),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(r.name, style: AppTextStyles.heading5()),
                        Text(r.ago, style: AppTextStyles.caption()),
                      ],
                    ),
                    const SizedBox(height: 4),
                    _starsRow(r.stars, size: 14),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          _serviceTag(r.service),
          const SizedBox(height: 12),
          Text(r.text, style: AppTextStyles.bodyMedium(color: AppColors.textSecondary)),
          const SizedBox(height: 16),
          Divider(color: AppColors.divider.withAlpha(50), height: 1),
          const SizedBox(height: 12),
          Align(
            alignment: Alignment.centerRight,
            child: TextButton.icon(
              onPressed: () {},
              icon: const Icon(Icons.reply_rounded, size: 18),
              label: const Text("Balas Ulasan"),
              style: TextButton.styleFrom(
                foregroundColor: AppColors.primaryRed,
                textStyle: AppTextStyles.buttonSmall(),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _initialsAvatar(String initials) {
    return Container(
      width: 48,
      height: 48,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: const LinearGradient(
          colors: [Color(0xFF64B5F6), Color(0xFF1976D2)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.blue.withAlpha(60),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      alignment: Alignment.center,
      child: Text(
        initials,
        style: AppTextStyles.heading4(color: Colors.white),
      ),
    );
  }

  Widget _starsRow(int count, {double size = 16}) {
    return Row(
      children: List.generate(
        5,
        (i) => Icon(
          i < count ? Icons.star_rounded : Icons.star_outline_rounded,
          size: size,
          color: AppColors.warning,
        ),
      ),
    );
  }

  Widget _serviceTag(String label) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: AppColors.backgroundLight,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: AppColors.border),
      ),
      child: Text(
        label,
        style: AppTextStyles.caption(color: AppColors.textSecondary).copyWith(fontWeight: FontWeight.w600),
      ),
    );
  }

  Widget _seeMore() {
    return Padding(
      padding: const EdgeInsets.only(top: 8),
      child: Center(
        child: TextButton(
          onPressed: () {},
          child: Text(
            'Lihat lebih banyak lagi',
            style: AppTextStyles.link(color: AppColors.textPrimary),
          ),
        ),
      ),
    );
  }
}

// ---------- SMALL WIDGETS ----------
class _RatingBarRow extends StatelessWidget {
  final String label;
  final double percent; // 0..1
  final int count;
  const _RatingBarRow({
    required this.label,
    required this.percent,
    required this.count,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Text(label, style: AppTextStyles.label().copyWith(fontWeight: FontWeight.bold)),
        const SizedBox(width: 4),
        const Icon(Icons.star_rounded, size: 14, color: AppColors.warning),
        const SizedBox(width: 8),
        Expanded(
          child: Stack(
            alignment: Alignment.centerLeft,
            children: [
              Container(
                height: 6,
                decoration: BoxDecoration(
                  color: AppColors.backgroundLight,
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              FractionallySizedBox(
                widthFactor: percent.clamp(0.0, 1.0),
                child: Container(
                  height: 6,
                  decoration: BoxDecoration(
                    color: AppColors.warning,
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(width: 8),
        SizedBox(
          width: 24,
          child: Text(
            '$count',
            style: AppTextStyles.caption(),
            textAlign: TextAlign.end,
          ),
        ),
      ],
    );
  }
}

class _Review {
  final String initials;
  final String name;
  final String ago;
  final int stars;
  final String service;
  final String text;

  const _Review({
    required this.initials,
    required this.name,
    required this.ago,
    required this.stars,
    required this.service,
    required this.text,
  });
}
