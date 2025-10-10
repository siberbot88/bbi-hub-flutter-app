import 'dart:io';
import 'package:bengkel_online_flutter/feature/admin/screens/voucher_page.dart'; // ✅ Import halaman utama voucher
import 'package:bengkel_online_flutter/feature/admin/widgets/custom_header.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class VoucherPreviewPage extends StatelessWidget {
  final String nama;
  final String tanggalMulai;
  final String tanggalAkhir;
  final String kuota;
  final File? gambar;

  const VoucherPreviewPage({
    super.key,
    required this.nama,
    required this.tanggalMulai,
    required this.tanggalAkhir,
    required this.kuota,
    this.gambar,
  });

  @override
  Widget build(BuildContext context) {
    final primaryColor = const Color(0xFFDC2626);

    return Theme(
      data: ThemeData(textTheme: GoogleFonts.poppinsTextTheme()),
      child: Scaffold(
        backgroundColor: Colors.grey[100],
        appBar: CustomHeader(
          title: "Preview Voucher",
          onBack: () => Navigator.pop(context),
        ),
        body: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              // 🔹 Card Preview Voucher
              Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: const [
                    BoxShadow(
                      color: Colors.black12,
                      blurRadius: 6,
                      offset: Offset(0, 3),
                    ),
                  ],
                ),
                child: Padding(
                  padding: const EdgeInsets.all(12),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        nama,
                        style: GoogleFonts.poppins(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Colors.black87,
                        ),
                      ),
                      const SizedBox(height: 8),

                      // 🔹 Gambar Voucher
                      ClipRRect(
                        borderRadius: BorderRadius.circular(8),
                        child: gambar != null
                            ? Image.file(
                                gambar!,
                                width: double.infinity,
                                height: 160,
                                fit: BoxFit.cover,
                              )
                            : Image.asset(
                                "assets/image/sample_voucher.png",
                                width: double.infinity,
                                height: 160,
                                fit: BoxFit.cover,
                              ),
                      ),
                      const SizedBox(height: 8),

                      // 🔹 Info kuota & tanggal
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            "Tersisa : $kuota",
                            style: GoogleFonts.poppins(
                              fontSize: 12,
                              color: Colors.black54,
                            ),
                          ),
                          Text(
                            "$tanggalMulai - $tanggalAkhir",
                            style: GoogleFonts.poppins(
                              fontSize: 12,
                              color: Colors.black54,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),

                      // 🔹 Tombol Lihat Detail
                      SizedBox(
                        width: double.infinity,
                        height: 50,
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: primaryColor,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          onPressed: () {
                            // TODO: arahkan ke detail voucher
                          },
                          child: Text(
                            "Lihat Detail",
                            style: GoogleFonts.poppins(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const Spacer(),
            ],
          ),
        ),

        // 🔹 Tombol Edit & Selesaikan
        bottomNavigationBar: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    style: OutlinedButton.styleFrom(
                      side: BorderSide(color: primaryColor, width: 2),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      minimumSize: const Size.fromHeight(50),
                    ),
                    onPressed: () {
                      Navigator.pop(context); // balik ke edit page
                    },
                    child: Text(
                      "EDIT",
                      style: GoogleFonts.poppins(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: primaryColor,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: primaryColor,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      minimumSize: const Size.fromHeight(50),
                    ),
                    onPressed: () {
                      // ✅ Arahkan ke VoucherPage dan tampilkan snackbar sukses
                      Navigator.pushAndRemoveUntil(
                        context,
                        MaterialPageRoute(
                          builder: (_) => const VoucherPage(
                            showSuccess: true, // kirim flag
                          ),
                        ),
                        (route) => false,
                      );
                    },
                    child: Text(
                      "SELESAIKAN",
                      style: GoogleFonts.poppins(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
