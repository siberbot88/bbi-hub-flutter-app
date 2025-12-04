import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

import 'package:bengkel_online_flutter/core/services/auth_provider.dart';
import 'package:bengkel_online_flutter/core/models/user.dart';
import 'package:bengkel_online_flutter/core/providers/service_provider.dart';
import 'package:bengkel_online_flutter/feature/owner/providers/employee_provider.dart';
import 'package:bengkel_online_flutter/feature/owner/widgets/staff/performance_helpers.dart';
import 'package:bengkel_online_flutter/feature/owner/widgets/staff/performance_card.dart';
import 'package:bengkel_online_flutter/feature/owner/widgets/dashboard/dashboard_helpers.dart';
import 'package:bengkel_online_flutter/core/theme/app_colors.dart';
import 'package:bengkel_online_flutter/core/theme/app_text_styles.dart';
import 'package:bengkel_online_flutter/core/theme/app_spacing.dart';

/// Screen untuk menampilkan performance semua staff
class StaffPerformanceScreen extends StatefulWidget {
  const StaffPerformanceScreen({super.key});

  @override
  State<StaffPerformanceScreen> createState() => _StaffPerformanceScreenState();
}

class _StaffPerformanceScreenState extends State<StaffPerformanceScreen> {
  PerformanceRange _selectedRange = PerformanceRange.month;

  @override
  void initState() {
    super.initState();
    // Fetch data saat screen dibuka
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _fetchData();
    });
  }

  Future<void> _fetchData() async {
    final auth = context.read<AuthProvider>();
    final wsId = pickWorkshopUuid(auth.user);

    // Fetch employees and services
    await Future.wait([
      context.read<EmployeeProvider>().fetchOwnerEmployees(),
      context.read<ServiceProvider>().fetchServices(
        workshopUuid: wsId,
        includeExtras: true,
        page: 1,
        perPage: 100,
      ),
    ]);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundLight,
      body: CustomScrollView(
        physics: const BouncingScrollPhysics(),
        slivers: [
          // App Bar
          SliverAppBar(
            pinned: true,
            expandedHeight: 120,
            backgroundColor: AppColors.primaryRed,
            elevation: 0,
            systemOverlayStyle: SystemUiOverlayStyle.light,
            leading: IconButton(
              icon: const Icon(Icons.arrow_back_ios_new, color: Colors.white),
              onPressed: () => Navigator.pop(context),
            ),
            flexibleSpace: FlexibleSpaceBar(
              background: Container(
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    colors: [Color(0xFF9B0D0D), Color(0xFFB70F0F)],
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                  ),
                ),
                child: SafeArea(
                  child: Padding(
                    padding: AppSpacing.paddingLG,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        Row(
                          children: [
                            const Icon(
                              Icons.analytics_outlined,
                              color: Colors.white,
                              size: 28,
                            ),
                            AppSpacing.horizontalSpaceSM,
                            Text(
                              'Kinerja Staff',
                              style: AppTextStyles.heading3(color: Colors.white),
                            ),
                          ],
                        ),
                        AppSpacing.verticalSpaceXS,
                        Text(
                          'Pantau performa tim Anda',
                          style: AppTextStyles.bodySmall(
                            color: Colors.white.withValues(alpha: 0.9),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),

          // Range Filter
          SliverToBoxAdapter(
            child: Padding(
              padding: AppSpacing.paddingMD,
              child: _buildRangeFilter(),
            ),
          ),

          // Performance List
          _buildPerformanceList(),
        ],
      ),
    );
  }

  /// Range filter buttons
  Widget _buildRangeFilter() {
    return Card(
      elevation: 1,
      child: Padding(
        padding: AppSpacing.paddingSM,
        child: Row(
          children: [
            Expanded(
              child: _RangeButton(
                label: 'Hari ini',
                isSelected: _selectedRange == PerformanceRange.today,
                onTap: () => setState(() => _selectedRange = PerformanceRange.today),
              ),
            ),
            AppSpacing.horizontalSpaceXS,
            Expanded(
              child: _RangeButton(
                label: 'Minggu ini',
                isSelected: _selectedRange == PerformanceRange.week,
                onTap: () => setState(() => _selectedRange = PerformanceRange.week),
              ),
            ),
            AppSpacing.horizontalSpaceXS,
            Expanded(
              child: _RangeButton(
                label: 'Bulan ini',
                isSelected: _selectedRange == PerformanceRange.month,
                onTap: () => setState(() => _selectedRange = PerformanceRange.month),
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Build list of staff performance
  Widget _buildPerformanceList() {
    return Consumer2<EmployeeProvider, ServiceProvider>(
      builder: (context, employeeProv, serviceProv, child) {
        // Loading state
        if (employeeProv.loading || serviceProv.loading) {
          return const SliverFillRemaining(
            child: Center(child: CircularProgressIndicator()),
          );
        }

        // Empty state
        if (employeeProv.items.isEmpty) {
          return SliverFillRemaining(
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.people_outline,
                    size: 80,
                    color: AppColors.textSecondary.withValues(alpha: 0.5),
                  ),
                  AppSpacing.verticalSpaceMD,
                  Text(
                    'Belum ada staff',
                    style: AppTextStyles.bodyLarge(
                      color: AppColors.textSecondary,
                    ),
                  ),
                  AppSpacing.verticalSpaceXS,
                  Text(
                    'Tambahkan staff untuk melihat performance',
                    style: AppTextStyles.bodySmall(
                      color: AppColors.textSecondary,
                    ),
                  ),
                ],
              ),
            ),
          );
        }

        // Calculate performance untuk semua staff
        final performanceList = PerformanceHelpers.calculateAllStaffPerformance(
          staffList: employeeProv.items.map((e) => e.user).whereType<User>().toList(),
          allServices: serviceProv.items,
          range: _selectedRange,
        );

        // Sort by total revenue (highest first)
        performanceList.sort((a, b) => b.totalRevenue.compareTo(a.totalRevenue));

        return SliverPadding(
          padding: AppSpacing.paddingMD,
          sliver: SliverList(
            delegate: SliverChildBuilderDelegate(
              (context, index) {
                final performance = performanceList[index];
                return Padding(
                  padding: EdgeInsets.only(
                    bottom: index < performanceList.length - 1 
                        ? AppSpacing.md 
                        : 0,
                  ),
                  child: PerformanceCard(
                    performance: performance,
                    onTap: () {
                      // TODO: Navigate to detail screen
                      debugPrint('Tap performance: ${performance.staffName}');
                    },
                  ),
                );
              },
              childCount: performanceList.length,
            ),
          ),
        );
      },
    );
  }
}

/// Range button widget
class _RangeButton extends StatelessWidget {
  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  const _RangeButton({
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 10),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.primaryRed : Colors.transparent,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Text(
          label,
          textAlign: TextAlign.center,
          style: AppTextStyles.labelBold(
            color: isSelected ? Colors.white : AppColors.textSecondary,
          ),
        ),
      ),
    );
  }
}
