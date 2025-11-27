import 'package:flutter/material.dart';
import 'package:bengkel_online_flutter/feature/owner/widgets/custom_header.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/theme/app_radius.dart';
import '../../../../core/theme/app_spacing.dart';

class FeedbackPage extends StatefulWidget {
  const FeedbackPage({super.key});

  @override
  State<FeedbackPage> createState() => _FeedbackPageState();
}

class _FeedbackPageState extends State<FeedbackPage> {
  String _selectedFilter = 'semua'; // semua | 5 | 4 | 3 | 2 | 1

  // Dummy Data
  final _reviews = <_Review>[
    _Review(
      initials: 'BS',
      name: 'Budi Santoso',
      ago: '2 jam lalu',
      stars: 5,
      service: 'Ganti Oli & Tune Up',
      text: 'Pelayanan sangat memuaskan! Mekanik ramah dan profesional. Harga juga transparan, dijelaskan detail sebelum pengerjaan. Pasti balik lagi!',
      avatarColor: Colors.blueAccent,
    ),
    _Review(
      initials: 'SN',
      name: 'Siti Nurhaliza',
      ago: '1 hari lalu',
      stars: 5,
      service: 'Service Berkala',
      text: 'Bengkel terbaik yang pernah saya kunjungi. Ruang tunggu nyaman, wifi kenceng, dan pengerjaan cepat. Recommended!',
      avatarColor: Colors.purpleAccent,
    ),
    _Review(
      initials: 'AW',
      name: 'Andi Wijaya',
      ago: '3 hari lalu',
      stars: 4,
      service: 'Perbaikan AC Mobil',
      text: 'Overall bagus, AC mobil jadi dingin lagi. Cuma agak lama nunggu karena ramai. Tapi hasil kerjanya oke.',
      avatarColor: Colors.orangeAccent,
    ),
    _Review(
      initials: 'DL',
      name: 'Dewi Lestari',
      ago: '5 hari lalu',
      stars: 5,
      service: 'Ganti Ban & Balancing',
      text: 'Cepat dan rapi! Mekaniknya juga kasih saran untuk perawatan ban. Tempatnya bersih dan nyaman.',
      avatarColor: Colors.teal,
    ),
    _Review(
      initials: 'RH',
      name: 'Rudi Hartono',
      ago: '1 minggu lalu',
      stars: 3,
      service: 'Servis Rem',
      text: 'Bagus, rem mobil jadi pakem lagi. Tapi harga agak sedikit mahal dibanding bengkel sebelah.',
      avatarColor: Colors.redAccent,
    ),
    _Review(
      initials: 'JK',
      name: 'Joko Kendil',
      ago: '2 minggu lalu',
      stars: 5,
      service: 'Cuci Mobil',
      text: 'Bersih banget! Sampai ke sela-sela mesin juga dibersihkan. Mantap jiwa!',
      avatarColor: Colors.indigo,
    ),
  ];

  List<_Review> get _filteredReviews {
    if (_selectedFilter == 'semua') return _reviews;
    return _reviews.where((r) => r.stars.toString() == _selectedFilter).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundLight,
      appBar: CustomHeader(
        title: "Ulasan Pelanggan",
        onBack: () => Navigator.pop(context),
      ),
      body: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        child: Padding(
          padding: AppSpacing.screenPadding,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              AppSpacing.verticalSpaceLG,
              _buildRatingOverview(),
              AppSpacing.verticalSpaceXXL,
              _buildFilterChips(),
              AppSpacing.verticalSpaceLG,
              _buildReviewList(),
              AppSpacing.verticalSpaceXXL,
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildRatingOverview() {
    return Container(
      padding: AppSpacing.paddingXL,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: AppRadius.radiusXL,
        border: Border.all(color: AppColors.border, width: 1),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha(10),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            flex: 4,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Text(
                  '4.8',
                  style: AppTextStyles.heading1(color: AppColors.textPrimary).copyWith(
                    fontSize: 52,
                    height: 1,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                AppSpacing.verticalSpaceXS,
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: List.generate(5, (index) {
                    return const Icon(
                      Icons.star_rounded,
                      color: AppColors.accentOrange,
                      size: 22,
                    );
                  }),
                ),
                AppSpacing.verticalSpaceSM,
                Text(
                  '247 Ulasan',
                  style: AppTextStyles.bodySmall(color: AppColors.textSecondary),
                ),
              ],
            ),
          ),
          Container(width: 1, height: 90, color: AppColors.divider),
          AppSpacing.horizontalSpaceXL,
          Expanded(
            flex: 6,
            child: Column(
              children: [
                _buildProgressBar('5', 0.85),
                _buildProgressBar('4', 0.10),
                _buildProgressBar('3', 0.03),
                _buildProgressBar('2', 0.01),
                _buildProgressBar('1', 0.01),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProgressBar(String label, double percent) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 3),
      child: Row(
        children: [
          Text(
            label,
            style: AppTextStyles.bodySmall(color: AppColors.textSecondary).copyWith(
              fontSize: 13,
              fontWeight: FontWeight.w500,
            ),
          ),
          AppSpacing.horizontalSpaceSM,
          const Icon(Icons.star_rounded, size: 14, color: AppColors.accentOrange),
          AppSpacing.horizontalSpaceSM,
          Expanded(
            child: ClipRRect(
              borderRadius: AppRadius.radiusSM,
              child: LinearProgressIndicator(
                value: percent,
                backgroundColor: AppColors.backgroundLight,
                valueColor: const AlwaysStoppedAnimation<Color>(AppColors.accentOrange),
                minHeight: 7,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterChips() {
    final filters = ['semua', '5', '4', '3', '2', '1'];
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      physics: const BouncingScrollPhysics(),
      child: Row(
        children: filters.map((filter) {
          final isSelected = _selectedFilter == filter;
          return Padding(
            padding: const EdgeInsets.only(right: 8),
            child: ChoiceChip(
              label: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (filter != 'semua') ...[
                    Icon(
                      Icons.star_rounded,
                      size: 16,
                      color: isSelected ? Colors.white : AppColors.accentOrange,
                    ),
                    const SizedBox(width: 4),
                  ],
                  Text(
                    filter == 'semua' ? 'Semua' : filter,
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                      color: isSelected ? Colors.white : AppColors.textPrimary,
                    ),
                  ),
                ],
              ),
              selected: isSelected,
              onSelected: (bool selected) {
                setState(() {
                  _selectedFilter = filter;
                });
              },
              backgroundColor: Colors.white,
              selectedColor: AppColors.primaryRed,
              shape: RoundedRectangleBorder(
                borderRadius: AppRadius.radiusXL,
                side: BorderSide(
                  color: isSelected ? Colors.transparent : AppColors.border,
                  width: 1,
                ),
              ),
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              elevation: isSelected ? 2 : 0,
              shadowColor: AppColors.primaryRed.withAlpha(76),
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildReviewList() {
    final reviews = _filteredReviews;
    return Column(
      children: reviews.map((review) => _buildReviewCard(review)).toList(),
    );
  }

  Widget _buildReviewCard(_Review review) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: AppRadius.radiusLG,
        border: Border.all(color: AppColors.border.withAlpha(128), width: 1),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha(8),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Quote Icon
          Icon(
            Icons.format_quote_rounded,
            size: 32,
            color: AppColors.accentOrange.withAlpha(76),
          ),
          AppSpacing.verticalSpaceSM,
          
          // Review Text
          Text(
            review.text,
            style: AppTextStyles.bodyMedium(color: AppColors.textPrimary).copyWith(
              height: 1.6,
              fontSize: 14,
            ),
          ),
          
          AppSpacing.verticalSpaceLG,
          
          // User Info
          Row(
            children: [
              // Avatar
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: review.avatarColor.withAlpha(38),
                  shape: BoxShape.circle,
                ),
                child: Center(
                  child: Text(
                    review.initials,
                    style: AppTextStyles.heading5(color: review.avatarColor).copyWith(
                      fontSize: 15,
                    ),
                  ),
                ),
              ),
              AppSpacing.horizontalSpaceMD,
              
              // Name, Stars, Time
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      review.name,
                      style: AppTextStyles.heading5(color: AppColors.textPrimary).copyWith(
                        fontSize: 15,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        ...List.generate(5, (i) {
                          return Icon(
                            Icons.star_rounded,
                            size: 14,
                            color: i < review.stars
                                ? AppColors.accentOrange
                                : AppColors.border,
                          );
                        }),
                        AppSpacing.horizontalSpaceSM,
                        Text(
                          review.ago,
                          style: AppTextStyles.caption(color: AppColors.textHint).copyWith(
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
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
  final Color avatarColor;

  const _Review({
    required this.initials,
    required this.name,
    required this.ago,
    required this.stars,
    required this.service,
    required this.text,
    required this.avatarColor,
  });
}
