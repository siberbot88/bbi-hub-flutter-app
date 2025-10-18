// lib/pages/service_detail.dart
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../widgets/custom_header.dart';
import '../widgets/reject_dialog.dart';
import '../widgets/accept_dialog.dart';

class ServiceDetailPage extends StatelessWidget {
  final Map<String, dynamic> task;

  const ServiceDetailPage({super.key, required this.task});

  Color _getVehicleColor(String? category) {
    switch (category?.toLowerCase()) {
      case "sepeda motor":
        return Colors.pink.shade200;
      case "mobil":
        return Colors.amber.shade300;
      default:
        return Colors.grey.shade300;
    }
  }

  @override
  Widget build(BuildContext context) {
    final mq = MediaQuery.of(context);
    final textScale = mq.textScaleFactor.clamp(0.9, 1.15);
    double s(double size) => (size * textScale);

    return Scaffold(
      appBar: const CustomHeader(
        title: "Service Detail",
        showBack: true,
      ),
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFF510707), Color(0xFF9B0D0D), Color(0xFFB70F0F)],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: SafeArea(
          child: LayoutBuilder(
            builder: (context, constraints) {
              return SingleChildScrollView(
                child: ConstrainedBox(
                  constraints: BoxConstraints(minHeight: constraints.maxHeight),
                  child: IntrinsicHeight(
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(18),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(14),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.06),
                              blurRadius: 8,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // 🔹 User Info
                            Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                CircleAvatar(
                                  radius: 24,
                                  backgroundImage: NetworkImage(
                                    "https://i.pravatar.cc/150?img=${task['id']}",
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        task['name'] ?? '-',
                                        style: GoogleFonts.poppins(
                                          fontSize: s(18),
                                          fontWeight: FontWeight.w700,
                                        ),
                                      ),
                                      Text(
                                        "ID: ${task['id'] ?? '-'}",
                                        style: GoogleFonts.poppins(
                                          fontSize: s(13),
                                          color: Colors.grey[600],
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.end,
                                  children: [
                                    Text("Date order",
                                        style: TextStyle(
                                            fontSize: s(12),
                                            color: Colors.grey[600])),
                                    Text("2 September 2025",
                                        style: GoogleFonts.poppins(
                                            fontSize: s(14),
                                            fontWeight: FontWeight.w600)),
                                  ],
                                ),
                              ],
                            ),
                            const SizedBox(height: 16),

                            // 🔹 Foto Kendaraan (square 1:1)
                            Center(
                              child: ClipRRect(
                                borderRadius: BorderRadius.circular(12),
                                child: AspectRatio(
                                  aspectRatio: 1, // square
                                  child: Image.asset(
                                    "assets/image/motorbeat.png",
                                    width: double.infinity,
                                    fit: BoxFit.cover,
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(height: 16),

                            // 🔹 Type & Scheduled
                            Row(
                              children: [
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text("Model Vehicle",
                                          style: TextStyle(
                                              fontSize: s(12),
                                              color: Colors.grey[600])),
                                      Text(task['motor'] ?? '-',
                                          style: GoogleFonts.poppins(
                                              fontSize: s(15),
                                              fontWeight: FontWeight.w700)),
                                    ],
                                  ),
                                ),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.end,
                                    children: [
                                      Text("Scheduled",
                                          style: TextStyle(
                                              fontSize: s(12),
                                              color: Colors.grey[600])),
                                      Text("8 AM - 12 PM • 7 Sept 2025",
                                          style: GoogleFonts.poppins(
                                              fontSize: s(15),
                                              fontWeight: FontWeight.w700)),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 14),

                            // 🔹 Plat Nomor + Jenis Kendaraan
                            Row(
                              children: [
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text("Plat Nomor",
                                          style: TextStyle(
                                              fontSize: s(12),
                                              color: Colors.grey[600])),
                                      Text(task['plate'] ?? '-',
                                          style: GoogleFonts.poppins(
                                              fontSize: s(15),
                                              fontWeight: FontWeight.w700)),
                                    ],
                                  ),
                                ),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.end,
                                    children: [
                                      Text("Jenis Kendaraan",
                                          style: TextStyle(
                                              fontSize: s(12),
                                              color: Colors.grey[600])),
                                      Container(
                                        margin: const EdgeInsets.only(top: 4),
                                        padding: const EdgeInsets.symmetric(
                                            horizontal: 10, vertical: 6),
                                        decoration: BoxDecoration(
                                          color: _getVehicleColor(
                                              task['vehicleCategory']),
                                          borderRadius:
                                              BorderRadius.circular(20),
                                        ),
                                        child: Text(
                                          task['vehicleCategory'] ??
                                              'Tidak diketahui',
                                          style: GoogleFonts.poppins(
                                            fontSize: s(13),
                                            fontWeight: FontWeight.w600,
                                            color: Colors.white,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 14),

                            // 🔹 Category Service & Phone
                            Row(
                              children: [
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text("Category Service",
                                          style: TextStyle(
                                              fontSize: s(12),
                                              color: Colors.grey[600])),
                                      Container(
                                        margin: const EdgeInsets.only(top: 4),
                                        padding: const EdgeInsets.symmetric(
                                            horizontal: 10, vertical: 6),
                                        decoration: BoxDecoration(
                                          color: Colors.grey[200],
                                          borderRadius:
                                              BorderRadius.circular(20),
                                        ),
                                        child: Text(
                                          task['category'] ?? 'Maintenance',
                                          style: TextStyle(
                                              fontSize: s(13),
                                              fontWeight: FontWeight.w600),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.end,
                                    children: [
                                      Text("No. Telepon",
                                          style: TextStyle(
                                              fontSize: s(12),
                                              color: Colors.grey[600])),
                                      Text("08956733xxx",
                                          style: GoogleFonts.poppins(
                                              fontSize: s(14),
                                              fontWeight: FontWeight.w600)),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 16),

                            // 🔹 Keluhan
                            Text("Keluhan",
                                style: TextStyle(
                                    fontSize: s(14),
                                    fontWeight: FontWeight.w600)),
                            const SizedBox(height: 6),
                            Container(
                              width: double.infinity,
                              padding: const EdgeInsets.all(10),
                              decoration: BoxDecoration(
                                border: Border.all(color: Colors.red.shade300),
                                borderRadius: BorderRadius.circular(8),
                                color: Colors.red.shade50,
                              ),
                              child: Text(
                                task['desc'] ?? "No description provided.",
                                style: TextStyle(fontSize: s(13)),
                              ),
                            ),

                            const Spacer(),

                            // 🔹 Buttons
                            Row(
                              children: [
                                Expanded(
                                  child: Builder(
                                    builder: (ctx) => ElevatedButton(
                                      onPressed: () {
                                        showRejectDialog(ctx);
                                      },
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: Colors.red,
                                        padding: const EdgeInsets.symmetric(
                                            vertical: 14),
                                        shape: RoundedRectangleBorder(
                                          borderRadius:
                                              BorderRadius.circular(30),
                                        ),
                                      ),
                                      child: Text("Decline",
                                          style: GoogleFonts.poppins(
                                              fontSize: s(14),
                                              color: Colors.white,
                                              fontWeight: FontWeight.w600)),
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: ElevatedButton(
                                    onPressed: () {
                                      showAcceptDialog(context);
                                    },
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: Colors.green,
                                      padding: const EdgeInsets.symmetric(
                                          vertical: 14),
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(30),
                                      ),
                                    ),
                                    child: Text("Accept",
                                        style: GoogleFonts.poppins(
                                            fontSize: s(14),
                                            color: Colors.white,
                                            fontWeight: FontWeight.w600)),
                                  ),
                                ),
                              ],
                            )
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}
