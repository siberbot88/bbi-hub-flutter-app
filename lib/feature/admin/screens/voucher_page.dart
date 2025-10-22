import 'package:bengkel_online_flutter/feature/admin/screens/voucher_editpage.dart';
import 'package:bengkel_online_flutter/feature/admin/screens/voucher_addpage.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:bengkel_online_flutter/feature/admin/widgets/custom_header.dart';
import 'package:bengkel_online_flutter/feature/admin/screens/profilpage.dart';

class VoucherPage extends StatefulWidget {
  final bool showSuccess; // ✅ flag untuk notifikasi

  const VoucherPage({super.key, this.showSuccess = false});

  @override
  State<VoucherPage> createState() => _VoucherPageState();
}

class _VoucherPageState extends State<VoucherPage> {
  @override
  void initState() {
    super.initState();
    // ✅ Tampilkan notifikasi kalau showSuccess = true
    if (widget.showSuccess) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              "Voucher berhasil dibuat 🎉",
              style: GoogleFonts.poppins(color: Colors.white),
            ),
            backgroundColor: Colors.green[600],
            behavior: SnackBarBehavior.floating,
            margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
            duration: const Duration(seconds: 3),
          ),
        );
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    // ✅ Dummy data
    final activeVouchers = [
      {
        "title": "Diskon 20%",
        "expired": "30 Agustus 2025",
        "slot": 10,
        "sisa": 7
      },
      {
        "title": "Diskon 20% Service",
        "expired": "30 Agustus 2025",
        "slot": 10,
        "sisa": 7
      },
    ];

    final expiredVouchers = [
      {
        "title": "Diskon 50%",
        "expired": "30 Agustus 2025",
        "slot": 10,
        "sisa": 7
      },
    ];

    return Scaffold(
        backgroundColor: Colors.grey[100],

        appBar: CustomHeader(
          title: "Voucher",
          onBack: () {
           Navigator.pop(context);

          },
        ),

        body: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ================== Voucher Aktif ==================
              Text(
                "Voucher Aktif",
                style: GoogleFonts.poppins(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 12),
              Column(
                children: activeVouchers.map((voucher) {
                  return _buildVoucherCard(
                    context,
                    title: voucher["title"].toString(),
                    expired: voucher["expired"].toString(),
                    slot: voucher["slot"] as int,
                    sisa: voucher["sisa"] as int,
                    isExpired: false,
                  );
                }).toList(),
              ),

              const SizedBox(height: 24),

              // ================== Voucher Kadaluarsa ==================
              Text(
                "Voucher Kadaluarsa",
                style: GoogleFonts.poppins(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 12),
              Column(
                children: expiredVouchers.map((voucher) {
                  return _buildVoucherCard(
                    context,
                    title: voucher["title"].toString(),
                    expired: voucher["expired"].toString(),
                    slot: voucher["slot"] as int,
                    sisa: voucher["sisa"] as int,
                    isExpired: true,
                  );
                }).toList(),
              ),
            ],
          ),
        ),

        // ================== Floating Action Button ==================
        floatingActionButton: FloatingActionButton(
          backgroundColor: const Color(0xFFDC2626),
          shape: const CircleBorder(),
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const AddVoucherPage()),
            );
          },
          child: Image.asset(
            "assets/icons/add.png",
            width: 28,
            height: 28,
          ),
        ),
      );
  }

  // ================== Widget Voucher Card ==================
  Widget _buildVoucherCard(
    BuildContext context, {
    required String title,
    required String expired,
    required int slot,
    required int sisa,
    required bool isExpired,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: const [
          BoxShadow(
            color: Colors.black12,
            blurRadius: 4,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          // 🔹 Icon voucher
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: isExpired ? Colors.grey : const Color(0xFFB70F0F),
            ),
            child: Image.asset(
              "assets/icons/voucherputih.png",
              width: 24,
              height: 24,
              color: Colors.white,
            ),
          ),
          const SizedBox(width: 12),

          // 🔹 Info voucher
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: GoogleFonts.poppins(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  isExpired ? "Kadaluarsa $expired" : "Berlaku sampai $expired",
                  style: GoogleFonts.poppins(
                    color: Colors.black54,
                    fontSize: 12,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  "Slot: $slot • Sisa: $sisa",
                  style: GoogleFonts.poppins(
                    color: Colors.black45,
                    fontSize: 12,
                  ),
                ),
                if (isExpired)
                  Padding(
                    padding: const EdgeInsets.only(top: 4),
                    child: Text(
                      "Kadaluarsa",
                      style: GoogleFonts.poppins(
                        color: Colors.red,
                        fontSize: 12,
                      ),
                    ),
                  ),
              ],
            ),
          ),

          // 🔹 Aksi (hapus + edit) hanya untuk yang aktif
          if (!isExpired) ...[
            // 🔹 Tombol Hapus
            GestureDetector(
              onTap: () {
                _showDeleteDialog(context);
              },
              child: Container(
                margin: const EdgeInsets.symmetric(horizontal: 4),
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.red, width: 2),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Image.asset(
                  "assets/icons/delete.png",
                  width: 22,
                  height: 22,
                  color: Colors.red,
                ),
              ),
            ),

            // 🔹 Tombol Edit
            GestureDetector(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => const VoucherEditPage(),
                  ),
                );
              },
              child: Container(
                margin: const EdgeInsets.symmetric(horizontal: 4),
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.red, width: 2),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Image.asset(
                  "assets/icons/edit.png",
                  width: 22,
                  height: 22,
                  color: Colors.red,
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  // ================== Dialog Hapus ==================
  void _showDeleteDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        title: Text(
          "Konfirmasi Hapus",
          style: GoogleFonts.poppins(fontWeight: FontWeight.bold),
        ),
        content: Text(
          "Yakin ingin menghapus voucher ini?",
          style: GoogleFonts.poppins(),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              "Batal",
              style: GoogleFonts.poppins(),
            ),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFDC2626),
              foregroundColor: Colors.white,
            ),
            onPressed: () {
              Navigator.pop(context);

              // ✅ tampilkan pop up berhasil dihapus
              showDialog(
                context: context,
                builder: (context) => AlertDialog(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  title: Text(
                    "Berhasil",
                    style: GoogleFonts.poppins(fontWeight: FontWeight.bold),
                  ),
                  content: Text(
                    "Voucher berhasil dihapus.",
                    style: GoogleFonts.poppins(),
                  ),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.pop(context),
                      child: Text(
                        "Oke",
                        style: GoogleFonts.poppins(),
                      ),
                    ),
                  ],
                ),
              );
            },
            child: Text(
              "Hapus",
              style: GoogleFonts.poppins(fontWeight: FontWeight.w600),
            ),
          ),
        ],
      ),
    );
  }
}
