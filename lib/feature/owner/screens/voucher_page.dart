import 'package:bengkel_online_flutter/core/models/voucher.dart';
import 'package:bengkel_online_flutter/core/services/api_service.dart';
<<<<<<< HEAD
import 'package:bengkel_online_flutter/feature/owner/screens/voucher_editpage.dart';
import 'package:bengkel_online_flutter/feature/owner/screens/voucher_addpage.dart';
import 'package:bengkel_online_flutter/feature/owner/widgets/custom_header.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/date_symbol_data_local.dart'; // ✅ Pastikan import intl
=======
import 'package:bengkel_online_flutter/feature/owner/screens/voucher_addpage.dart';
import 'package:bengkel_online_flutter/feature/owner/screens/voucher_detail_page.dart';
import 'package:bengkel_online_flutter/feature/owner/widgets/custom_header.dart';
import 'package:bengkel_online_flutter/core/widgets/custom_alert.dart';
import 'package:flutter/material.dart';
import 'package:intl/date_symbol_data_local.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/theme/app_radius.dart';
import '../../../../core/theme/app_spacing.dart';
import 'list_voucher_page.dart';
>>>>>>> f69db6e40e06854413d398fd766130ce19c9aa76

class VoucherPage extends StatefulWidget {
  final bool showSuccess;

  const VoucherPage({super.key, this.showSuccess = false});

  @override
  State<VoucherPage> createState() => _VoucherPageState();
}

class _VoucherPageState extends State<VoucherPage> {
  final ApiService _apiService = ApiService();
  late Future<List<Voucher>> _vouchersFuture;

<<<<<<< HEAD
  final Color _primaryColor = const Color(0xFFDC2626);
  final Color _backgroundColor = Colors.white;
  final TextStyle _fontStyle = GoogleFonts.poppins(fontSize: 12);

  @override
  void initState() {
    super.initState();

    // ✅ Inisialisasi format tanggal (untuk jaga-jaga jika main.dart belum reload)
=======
  @override
  void initState() {
    super.initState();
>>>>>>> f69db6e40e06854413d398fd766130ce19c9aa76
    initializeDateFormatting('id_ID', null).then((_) {
      _loadData();
    });

    if (widget.showSuccess) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
<<<<<<< HEAD
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("Voucher berhasil disimpan 🎉", style: GoogleFonts.poppins(color: Colors.white)),
            backgroundColor: Colors.green[600],
            behavior: SnackBarBehavior.floating,
            margin: const EdgeInsets.all(20),
          ),
=======
        CustomAlert.show(
          context,
          title: "Berhasil",
          message: "Voucher berhasil disimpan 🎉",
          type: AlertType.success,
>>>>>>> f69db6e40e06854413d398fd766130ce19c9aa76
        );
      });
    }
  }

  void _loadData() {
    setState(() {
      _vouchersFuture = _apiService.fetchVouchers();
    });
  }

<<<<<<< HEAD
  Future<void> _handleDelete(String id) async {
    try {
      await _apiService.deleteVoucher(id);
      if (!mounted) return;
      Navigator.pop(context);
      _loadData();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Voucher berhasil dihapus", style: GoogleFonts.poppins()), backgroundColor: Colors.green),
      );
    } catch (e) {
      Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Gagal menghapus: $e"), backgroundColor: Colors.red),
      );
    }
  }

  void _confirmDelete(String id) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        title: Text("Hapus Voucher?", style: GoogleFonts.poppins(fontWeight: FontWeight.bold, fontSize: 16)),
        content: Text("Tindakan ini tidak dapat dibatalkan.", style: GoogleFonts.poppins(fontSize: 13)),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text("Batal", style: GoogleFonts.poppins(color: Colors.grey)),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: _primaryColor),
            onPressed: () => _handleDelete(id),
            child: Text("Hapus", style: GoogleFonts.poppins(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _backgroundColor,

      // ✅ CUSTOM HEADER DENGAN LOGIKA NAVIGASI
      appBar: CustomHeader(
        title: "Voucher",
        onBack: () {
          // Hapus semua route di stack, buka /main, dan kirim argument 3 (Profile)
          Navigator.pushNamedAndRemoveUntil(
            context,
            '/main',
                (route) => false,
            arguments: 3, // 3 adalah index tab Profile pada Owner
          );
        },
      ),

      body: RefreshIndicator(
        color: _primaryColor,
        onRefresh: () async => _loadData(),
        child: FutureBuilder<List<Voucher>>(
          future: _vouchersFuture,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return Center(child: CircularProgressIndicator(color: _primaryColor));
            }
            if (snapshot.hasError) {
              return Center(child: Text("Gagal memuat data", style: _fontStyle));
            }

            final allVouchers = snapshot.data ?? [];
            final activeVouchers = allVouchers.where((v) => !v.isExpired && v.isActive).toList();
            final expiredVouchers = allVouchers.where((v) => v.isExpired).toList();

            return ListView(
              padding: const EdgeInsets.all(16),
              children: [
                _buildSectionHeader("Voucher Aktif"),
                if (activeVouchers.isEmpty)
                  _buildEmptyState("Belum ada voucher aktif"),
                ...activeVouchers.map((v) => _buildVoucherCard(voucher: v, isExpired: false)),

                const SizedBox(height: 24),

                _buildSectionHeader("Voucher Kadaluarsa"),
                if (expiredVouchers.isEmpty)
                  _buildEmptyState("Tidak ada voucher kadaluarsa"),
                ...expiredVouchers.map((v) => _buildVoucherCard(voucher: v, isExpired: true)),

                const SizedBox(height: 80),
              ],
            );
          },
        ),
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: _primaryColor,
        shape: const CircleBorder(),
        onPressed: () {
          Navigator.push(context, MaterialPageRoute(builder: (_) => const AddVoucherPage()));
        },
        child: const Icon(Icons.add, color: Colors.white, size: 28),
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Text(
        title,
        style: GoogleFonts.poppins(fontSize: 16, fontWeight: FontWeight.w600, color: Colors.black87),
      ),
    );
  }

  Widget _buildEmptyState(String message) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: Center(child: Text(message, style: GoogleFonts.poppins(fontSize: 12, color: Colors.grey, fontStyle: FontStyle.italic))),
    );
  }

  Widget _buildVoucherCard({required Voucher voucher, required bool isExpired}) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade200),
        boxShadow: [BoxShadow(color: Colors.grey.shade100, blurRadius: 4, offset: const Offset(0, 2))],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: isExpired ? Colors.grey.shade300 : _primaryColor,
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.confirmation_number_outlined, color: Colors.white, size: 20),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  voucher.title,
                  style: GoogleFonts.poppins(fontSize: 14, fontWeight: FontWeight.w600),
                  maxLines: 1, overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 4),
                Text(
                  isExpired ? "Kadaluarsa ${voucher.formattedUntilDate}" : "Berlaku sampai ${voucher.formattedUntilDate}",
                  style: GoogleFonts.poppins(fontSize: 12, color: isExpired ? Colors.red : Colors.grey.shade600),
                ),
                const SizedBox(height: 4),
                Text(
                  "Slot: ${voucher.quota} • Min Belanja: Rp ${voucher.minTransaction.toStringAsFixed(0)}",
                  style: GoogleFonts.poppins(fontSize: 12, color: Colors.grey.shade500),
                ),
              ],
            ),
          ),
          if (!isExpired)
            Row(
              children: [
                _buildActionButton(Icons.delete_outline, Colors.red, () => _confirmDelete(voucher.id)),
                const SizedBox(width: 4),
                _buildActionButton(Icons.edit_outlined, Colors.orange, () async {
                  final bool? result = await Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => VoucherEditPage(voucher: voucher)),
                  );
                  if (result == true) {
                    _loadData();
                  }
                }),
              ],
            )
        ],
      ),
    );
  }

  Widget _buildActionButton(IconData icon, Color color, VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Icon(icon, color: color, size: 22),
=======
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: CustomHeader(
        title: "Voucher",
        onBack: () {
          Navigator.pushNamedAndRemoveUntil(
            context,
            '/main',
            (route) => false,
            arguments: 3,
          );
        },
        actions: [
          IconButton(
            icon: const Icon(Icons.search_rounded, color: Colors.white),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const ListVoucherPage()),
              );
            },
          ),
        ],
>>>>>>> f69db6e40e06854413d398fd766130ce19c9aa76
      ),
      body: RefreshIndicator(
        color: AppColors.primaryRed,
        onRefresh: () async => _loadData(),
        child: FutureBuilder<List<Voucher>>(
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

            return ListView(
              padding: AppSpacing.screenPadding,
              children: [
                _buildSectionHeader("Voucher Aktif"),
                if (activeVouchers.isEmpty)
                  _buildEmptyState("Belum ada voucher aktif"),
                ...activeVouchers.map((v) => _buildVoucherCard(voucher: v, isExpired: false)),

                AppSpacing.verticalSpaceXL,

                _buildSectionHeader("Voucher Kadaluarsa"),
                if (expiredVouchers.isEmpty)
                  _buildEmptyState("Tidak ada voucher kadaluarsa"),
                ...expiredVouchers.map((v) => _buildVoucherCard(voucher: v, isExpired: true)),

                const SizedBox(height: 80),
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
<<<<<<< HEAD
=======

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Text(
        title,
        style: AppTextStyles.heading4(color: Colors.black87),
      ),
    );
  }

  Widget _buildEmptyState(String message) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 20),
      child: Center(
        child: Text(
          message,
          style: AppTextStyles.bodyMedium(color: AppColors.textSecondary).copyWith(fontStyle: FontStyle.italic),
        ),
      ),
    );
  }

  Widget _buildVoucherCard({required Voucher voucher, required bool isExpired}) {
    return GestureDetector(
      onTap: () async {
        final result = await Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => VoucherDetailPage(voucher: voucher)),
        );
        if (result != null) {
          _loadData();
          
          if (!mounted) return;

          if (result == 'deleted') {
            CustomAlert.show(
              context,
              title: "Berhasil",
              message: "Voucher berhasil dihapus",
              type: AlertType.success,
            );
          } else if (result == 'updated') {
            CustomAlert.show(
              context,
              title: "Berhasil",
              message: "Voucher berhasil diperbarui",
              type: AlertType.success,
            );
          }
        }
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: AppRadius.radiusLG,
          border: Border.all(color: Colors.grey.shade200),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.shade100,
              blurRadius: 4,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: isExpired ? Colors.grey.shade300 : AppColors.primaryRed,
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.confirmation_number_outlined, color: Colors.white, size: 20),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    voucher.title,
                    style: AppTextStyles.heading5(),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    isExpired ? "Kadaluarsa ${voucher.formattedUntilDate}" : "Berlaku sampai ${voucher.formattedUntilDate}",
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
            const Icon(Icons.chevron_right, color: AppColors.textHint),
          ],
        ),
      ),
    );
  }
>>>>>>> f69db6e40e06854413d398fd766130ce19c9aa76
}