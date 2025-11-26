import 'package:bengkel_online_flutter/core/models/voucher.dart';
import 'package:bengkel_online_flutter/core/services/api_service.dart';
import 'package:bengkel_online_flutter/feature/owner/screens/voucher_editpage.dart';
import 'package:bengkel_online_flutter/feature/owner/screens/voucher_addpage.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/date_symbol_data_local.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/theme/app_radius.dart';
import '../../../../core/theme/app_spacing.dart';

class VoucherPage extends StatefulWidget {
  final bool showSuccess;

  const VoucherPage({super.key, this.showSuccess = false});

  @override
  State<VoucherPage> createState() => _VoucherPageState();
}

class _VoucherPageState extends State<VoucherPage> with SingleTickerProviderStateMixin {
  final ApiService _apiService = ApiService();
  late Future<List<Voucher>> _vouchersFuture;
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    initializeDateFormatting('id_ID', null).then((_) {
      _loadData();
    });

    if (widget.showSuccess) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("Voucher berhasil disimpan 🎉", style: AppTextStyles.bodyMedium(color: Colors.white)),
            backgroundColor: AppColors.success,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(borderRadius: AppRadius.radiusMD),
            margin: AppSpacing.paddingMD,
          ),
        );
      });
    }
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  void _loadData() {
    setState(() {
      _vouchersFuture = _apiService.fetchVouchers();
    });
  }

  Future<void> _handleDelete(String id) async {
    try {
      await _apiService.deleteVoucher(id);
      if (!mounted) return;
      Navigator.pop(context); // Close dialog
      _loadData();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Voucher berhasil dihapus", style: AppTextStyles.bodyMedium(color: Colors.white)),
          backgroundColor: AppColors.success,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: AppRadius.radiusMD),
          margin: AppSpacing.paddingMD,
        ),
      );
    } catch (e) {
      Navigator.pop(context); // Close dialog
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Gagal menghapus: $e", style: AppTextStyles.bodyMedium(color: Colors.white)),
          backgroundColor: AppColors.error,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: AppRadius.radiusMD),
          margin: AppSpacing.paddingMD,
        ),
      );
    }
  }

  void _confirmDelete(String id) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: AppRadius.radiusLG),
        title: Text("Hapus Voucher?", style: AppTextStyles.heading4()),
        content: Text("Tindakan ini tidak dapat dibatalkan.", style: AppTextStyles.bodyMedium()),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text("Batal", style: AppTextStyles.buttonSmall(color: AppColors.textSecondary)),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.error,
              shape: RoundedRectangleBorder(borderRadius: AppRadius.radiusMD),
            ),
            onPressed: () => _handleDelete(id),
            child: Text("Hapus", style: AppTextStyles.buttonSmall(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundLight,
      body: NestedScrollView(
        headerSliverBuilder: (context, innerBoxIsScrolled) {
          return [
            SliverAppBar(
              expandedHeight: 120.0,
              floating: false,
              pinned: true,
              backgroundColor: AppColors.primaryRed,
              elevation: 0,
              systemOverlayStyle: SystemUiOverlayStyle.light,
              leading: IconButton(
                icon: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.white.withAlpha(51),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.arrow_back_ios_new_rounded, size: 18, color: Colors.white),
                ),
                onPressed: () {
                  Navigator.pushNamedAndRemoveUntil(
                    context,
                    '/main',
                    (route) => false,
                    arguments: 3,
                  );
                },
              ),
              flexibleSpace: FlexibleSpaceBar(
                titlePadding: const EdgeInsets.only(left: 20, bottom: 16),
                centerTitle: false,
                title: Text(
                  'Kelola Voucher',
                  style: AppTextStyles.heading3(color: Colors.white),
                ),
                background: Container(
                  decoration: const BoxDecoration(
                    gradient: AppColors.primaryGradient,
                  ),
                  child: Stack(
                    children: [
                      Positioned(
                        right: -20,
                        top: -20,
                        child: Icon(
                          Icons.confirmation_number_rounded,
                          size: 150,
                          color: Colors.white.withAlpha(25),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            SliverPersistentHeader(
              delegate: _SliverAppBarDelegate(
                TabBar(
                  controller: _tabController,
                  labelColor: AppColors.primaryRed,
                  unselectedLabelColor: AppColors.textSecondary,
                  indicatorColor: AppColors.primaryRed,
                  indicatorWeight: 3,
                  labelStyle: AppTextStyles.heading5(),
                  unselectedLabelStyle: AppTextStyles.heading5(),
                  tabs: const [
                    Tab(text: "Aktif"),
                    Tab(text: "Kadaluarsa"),
                  ],
                ),
              ),
              pinned: true,
            ),
          ];
        },
        body: FutureBuilder<List<Voucher>>(
          future: _vouchersFuture,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator(color: AppColors.primaryRed));
            }
            if (snapshot.hasError) {
              return Center(child: Text("Gagal memuat data", style: AppTextStyles.bodyMedium()));
            }

            final allVouchers = snapshot.data ?? [];
            final activeVouchers = allVouchers.where((v) => !v.isExpired && v.isActive).toList();
            final expiredVouchers = allVouchers.where((v) => v.isExpired).toList();

            return TabBarView(
              controller: _tabController,
              children: [
                _buildVoucherList(activeVouchers, isExpired: false),
                _buildVoucherList(expiredVouchers, isExpired: true),
              ],
            );
          },
        ),
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: AppColors.primaryRed,
        shape: const CircleBorder(),
        elevation: 4,
        onPressed: () {
          Navigator.push(context, MaterialPageRoute(builder: (_) => const AddVoucherPage()));
        },
        child: const Icon(Icons.add, color: Colors.white, size: 28),
      ),
    );
  }

  Widget _buildVoucherList(List<Voucher> vouchers, {required bool isExpired}) {
    if (vouchers.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              isExpired ? Icons.history_toggle_off_rounded : Icons.confirmation_number_outlined,
              size: 64,
              color: Colors.grey.shade300,
            ),
            AppSpacing.verticalSpaceMD,
            Text(
              isExpired ? "Tidak ada voucher kadaluarsa" : "Belum ada voucher aktif",
              style: AppTextStyles.bodyMedium(color: AppColors.textSecondary),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: AppSpacing.screenPadding,
      itemCount: vouchers.length,
      itemBuilder: (context, index) {
        return _buildVoucherCard(voucher: vouchers[index], isExpired: isExpired);
      },
    );
  }

  Widget _buildVoucherCard({required Voucher voucher, required bool isExpired}) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: AppRadius.radiusLG,
        boxShadow: [
          BoxShadow(
            color: AppColors.shadow,
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        borderRadius: AppRadius.radiusLG,
        child: InkWell(
          borderRadius: AppRadius.radiusLG,
          onTap: isExpired ? null : () async {
             final bool? result = await Navigator.push(
               context,
               MaterialPageRoute(builder: (_) => VoucherEditPage(voucher: voucher)),
             );
             if (result == true) {
               _loadData();
             }
          },
          child: Padding(
            padding: AppSpacing.paddingLG,
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: isExpired ? Colors.grey.shade100 : AppColors.primaryRed.withAlpha(26),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    Icons.confirmation_number_rounded,
                    color: isExpired ? Colors.grey : AppColors.primaryRed,
                    size: 24,
                  ),
                ),
                AppSpacing.horizontalSpaceMD,
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        voucher.title,
                        style: AppTextStyles.heading5(
                          color: isExpired ? AppColors.textSecondary : AppColors.textPrimary,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 4),
                      Text(
                        isExpired
                            ? "Kadaluarsa ${voucher.formattedUntilDate}"
                            : "Berlaku sampai ${voucher.formattedUntilDate}",
                        style: AppTextStyles.caption(
                          color: isExpired ? AppColors.error : AppColors.textSecondary,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        "Slot: ${voucher.quota} • Min: Rp ${voucher.minTransaction.toStringAsFixed(0)}",
                        style: AppTextStyles.caption(color: AppColors.textHint),
                      ),
                    ],
                  ),
                ),
                if (!isExpired)
                  Row(
                    children: [
                      IconButton(
                        icon: const Icon(Icons.edit_rounded, color: AppColors.accentOrange, size: 20),
                        onPressed: () async {
                          final bool? result = await Navigator.push(
                            context,
                            MaterialPageRoute(builder: (_) => VoucherEditPage(voucher: voucher)),
                          );
                          if (result == true) {
                            _loadData();
                          }
                        },
                      ),
                      IconButton(
                        icon: const Icon(Icons.delete_rounded, color: AppColors.error, size: 20),
                        onPressed: () => _confirmDelete(voucher.id),
                      ),
                    ],
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _SliverAppBarDelegate extends SliverPersistentHeaderDelegate {
  final TabBar _tabBar;

  _SliverAppBarDelegate(this._tabBar);

  @override
  double get minExtent => _tabBar.preferredSize.height;
  @override
  double get maxExtent => _tabBar.preferredSize.height;

  @override
  Widget build(BuildContext context, double shrinkOffset, bool overlapsContent) {
    return Container(
      color: Colors.white,
      child: _tabBar,
    );
  }

  @override
  bool shouldRebuild(_SliverAppBarDelegate oldDelegate) {
    return false;
  }
}