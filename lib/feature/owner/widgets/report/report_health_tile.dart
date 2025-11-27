import 'package:flutter/material.dart';
import 'package:bengkel_online_flutter/core/theme/app_colors.dart';
import 'package:bengkel_online_flutter/core/theme/app_text_styles.dart';

class ReportHealthTile extends StatelessWidget {
  const ReportHealthTile({
    super.key,
    required this.title,
    required this.value,
    required this.tag,
    required this.tagColor,
  });

  final String title;
  final String value;
  final String tag;
  final Color tagColor;

  IconData _getIconFromTitle(String title) {
    if (title.toLowerCase().contains('antrian')) {
      return Icons.queue_rounded;
    } else if (title.toLowerCase().contains('occupancy')) {
      return Icons.engineering_rounded;
    } else if (title.toLowerCase().contains('peak')) {
      return Icons.schedule_rounded;
    } else if (title.toLowerCase().contains('efisiensi')) {
      return Icons.speed_rounded;
    }
    return Icons.analytics_rounded;
  }

  double _getProgressFromValue(String value) {
    final regex = RegExp(r'(\d+)');
    final match = regex.firstMatch(value);
    if (match != null) {
      final number = int.tryParse(match.group(1) ?? '0') ?? 0;
      if (value.contains('%')) {
        return number / 100;
      } else {
        return (number / 10).clamp(0.0, 1.0);
      }
    }
    return 0.5;
  }

  String _getTrendPercentage(double progress) {
    if (progress >= 0.8) return '+12%';
    if (progress >= 0.6) return '+8%';
    if (progress >= 0.4) return '+3%';
    return '-2%';
  }

  bool _isPositiveTrend(double progress) {
    return progress >= 0.4;
  }

  @override
  Widget build(BuildContext context) {
    final icon = _getIconFromTitle(title);
    final progress = _getProgressFromValue(value);
    final trendPercentage = _getTrendPercentage(progress);
    final isPositive = _isPositiveTrend(progress);

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.border.withAlpha(30)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha(5),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header Row: Icon + Badge
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: tagColor.withAlpha(20),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(icon, color: tagColor, size: 16),
              ),
              const Spacer(),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: tagColor.withAlpha(20),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  tag,
                  style: TextStyle(
                    color: tagColor,
                    fontSize: 10,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),

          // Title
          Text(
            title,
            style: AppTextStyles.bodySmall(color: AppColors.textSecondary),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 4),

          // Value + Trend
          Row(
            crossAxisAlignment: CrossAxisAlignment.baseline,
            textBaseline: TextBaseline.alphabetic,
            children: [
              Flexible(
                child: Text(
                  value,
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w700,
                    color: AppColors.textPrimary,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              const SizedBox(width: 6),
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    isPositive ? Icons.arrow_upward : Icons.arrow_downward,
                    size: 12,
                    color: isPositive ? AppColors.success : AppColors.error,
                  ),
                  const SizedBox(width: 2),
                  Text(
                    trendPercentage,
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                      color: isPositive ? AppColors.success : AppColors.error,
                    ),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 12),

          // Progress Bar
          Stack(
            children: [
              Container(
                height: 4,
                decoration: BoxDecoration(
                  color: AppColors.backgroundLight,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              FractionallySizedBox(
                widthFactor: progress.clamp(0.0, 1.0),
                child: Container(
                  height: 4,
                  decoration: BoxDecoration(
                    color: tagColor,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),

          // Completion Text
          Text(
            '${(progress * 100).toInt()}% Complete',
            style: TextStyle(
              fontSize: 10,
              color: AppColors.textHint,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}
