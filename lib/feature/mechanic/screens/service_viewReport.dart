import 'package:bengkel_online_flutter/feature/mechanic/widgets/custom_header.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class ServiceViewReport extends StatelessWidget {
  const ServiceViewReport({super.key});

  @override
  Widget build(BuildContext context) {
    const mainColor = Color.fromRGBO(155, 13, 13, 1);

    return Scaffold(
      backgroundColor: const Color.fromRGBO(155, 13, 13, 1),
      appBar: const CustomHeader(
        title: "Tugas",
        showBack: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            // 🔹 Card Utama
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.08),
                    blurRadius: 6,
                    offset: const Offset(0, 3),
                  ),
                ],
              ),
              child: Column(
                children: [
                  // 🔹 Header Profil & Tanggal
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      CircleAvatar(
                        radius: 20,
                        backgroundImage:
                            const AssetImage("assets/image/profile1.png"),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              "Prabowo",
                              style: GoogleFonts.poppins(
                                fontSize: 15,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            Text(
                              "08955330272",
                              style: GoogleFonts.poppins(
                                fontSize: 13,
                                color: Colors.grey,
                              ),
                            ),
                          ],
                        ),
                      ),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Text(
                            "Tanggal Pesan",
                            style: GoogleFonts.poppins(
                              fontSize: 12,
                              color: Colors.grey,
                            ),
                          ),
                          Text(
                            "2 September 2025",
                            style: GoogleFonts.poppins(
                              fontSize: 13,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),

                  const SizedBox(height: 14),

                  // 🔹 Foto kendaraan
                  ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: AspectRatio(
                      aspectRatio: 1,
                      child: Image.asset(
                        "assets/image/motorbeatjos.png",
                        width: double.infinity,
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),

                  const SizedBox(height: 16),

                  // ============================
                  // 🔹 CARD: Identifikasi Servis
                  // ============================
                  _cardSection(
                    title: "Identifikasi Servis",
                    children: [
                      _infoRow("ID Tugas", "SC23863892610"),
                      _infoRow("Waktu Mulai", "08:00"),
                      _infoRow("Waktu Selesai", "08:50"),
                      _infoRow("Durasi Pengerjaan", "150 menit"),
                      _infoRow("Status Akhir", "Selesai"),
                      _infoRow("Nama Teknisi", "Sugiarto Sutejo"),
                    ],
                  ),

                  const SizedBox(height: 14),

                  // ============================
                  // 🔹 CARD: Detail Kendaraan
                  // ============================
                  _cardSection(
                    title: "Detail Kendaraan",
                    children: [
                      _infoRow("Model", "BEAT 2012"),
                      _infoRow("Plat Nomor", "SU B14N 70"),
                      _infoRow("Jenis", "Sepeda Motor"),
                      _infoRow("Alamat Pemilik",
                          "Jl. Medokan Ayu No.13, Kecamatan Gunung Anyar"),
                      _infoRow("No. Telepon", "089553401177"),
                    ],
                  ),

                  const SizedBox(height: 14),

                  // ============================
                  // 🔹 CARD: Keluhan
                  // ============================
                  _cardSection(
                    title: "Pesan",
                    children: [
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: Colors.grey.shade200,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          "Penggantian bantalan rem lengkap dan kalibrasi sistem untuk unit excavator",
                          style: GoogleFonts.poppins(fontSize: 14),
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 14),

                  // ============================
                  // 🔹 CARD: Hasil Pengerjaan
                  // ============================
                  _cardSection(
                    title: "Hasil pengerjaan",
                    children: [
                      _waitingBox("Detail Pekerjaan"),
                      _waitingBox("Suku Cadang yang digunakan"),
                      _waitingBox("Catatan Teknisi"),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // 🔸 Widget Section Card
  Widget _cardSection({required String title, required List<Widget> children}) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(color: Colors.black12),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Text(
            title,
            style: GoogleFonts.poppins(
              fontSize: 15,
              fontWeight: FontWeight.w700,
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: 8),
          ...children,
        ],
      ),
    );
  }

  // 🔸 Info Row
  Widget _infoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            flex: 3,
            child: Text(
              label,
              style: GoogleFonts.poppins(fontSize: 13, color: Colors.black87),
            ),
          ),
          Expanded(
            flex: 4,
            child: Text(
              ": $value",
              style: GoogleFonts.poppins(
                fontSize: 13,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // 🔸 Waiting Box (Menunggu input admin)
  Widget _waitingBox(String label) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: GoogleFonts.poppins(
              fontSize: 14,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 4),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: Colors.grey.shade200,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              "Menunggu input dari admin",
              style: GoogleFonts.poppins(
                fontSize: 13,
                color: Colors.black54,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
