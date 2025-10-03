import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../widgets/custom_header.dart';
import '../widgets/assign_dialog.dart';  // pastikan path sesuai


class ServiceViewReportPage extends StatelessWidget {
  final Map<String, dynamic> task;

  const ServiceViewReportPage({super.key, required this.task});

  @override
  Widget build(BuildContext context) {
    final DateTime? orderDate = task['date'] is DateTime ? task['date'] : null;
    final double screenWidth = MediaQuery.of(context).size.width;
    final double screenHeight = MediaQuery.of(context).size.height;

    return Scaffold(
      appBar: const CustomHeader(
        title: "Tasks",
        showBack: true,
      ),
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [
              Color(0xFF510707),
              Color(0xFF9B0D0D),
              Color(0xFFB70F0F),
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: ConstrainedBox(
            constraints: BoxConstraints(
              minHeight: screenHeight - kToolbarHeight - 32, 
              // minimal 1 layar penuh, dikurangi appbar & padding
            ),
            child: Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 6,
                    offset: const Offset(0, 3),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // 🔹 User + Date Order
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      CircleAvatar(
                        radius: 22,
                        backgroundImage: NetworkImage(
                            "https://i.pravatar.cc/150?img=${task['id']}"),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(task['user'] ?? "-",
                                style: GoogleFonts.poppins(
                                    fontSize: 16, fontWeight: FontWeight.w600)),
                            Text("ID: ${task['id']}",
                                style: GoogleFonts.poppins(
                                    fontSize: 13, color: Colors.grey)),
                          ],
                        ),
                      ),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Text("Date order",
                              style: GoogleFonts.poppins(
                                  fontSize: 13, color: Colors.grey)),
                          Text(
                            orderDate != null ? _formatDate(orderDate) : "-",
                            style: GoogleFonts.poppins(
                                fontSize: 14, fontWeight: FontWeight.w600),
                          ),
                        ],
                      ),
                    ],
                  ),

                  const SizedBox(height: 20),

                  // 🔹 Foto Kendaraan
                  ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: Image.asset(
                      "assets/images/motorbeat.jpg",
                      height: screenWidth * 0.45,
                      width: double.infinity,
                      fit: BoxFit.cover,
                    ),
                  ),

                  const SizedBox(height: 20),

                  // 🔹 Detail Kendaraan
                  _detailRow("Tipe Kendaraan", task['motor']),
                  _detailRow(
                      "Scheduled",
                      "${task['time']} : ${orderDate != null ? _formatDate(orderDate) : '-'}"),
                  _detailRow("Plat Nomor", task['plate']),
                  _detailRow("Status", task['status'],
                      custom: Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                          color: Colors.grey[300],
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(task['status'] ?? "-",
                            style: GoogleFonts.poppins(
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                                color: Colors.black87)),
                      )),
                  _detailRow("No. Telepon", "08956733xxx"),
                  _detailRow("Address",
                      "Jl. Medokan Ayu No.13, Kecamatan Gunung Anyar"),

                  const SizedBox(height: 18),

                  // 🔹 Keluhan
                  Text("Keluhan",
                      style: GoogleFonts.poppins(
                          fontSize: 15, fontWeight: FontWeight.w600)),
                  const SizedBox(height: 6),
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.red, width: 1),
                      borderRadius: BorderRadius.circular(8),
                      color: Colors.red.shade50,
                    ),
                    child: Text(task['desc'] ?? "-",
                        style: GoogleFonts.poppins(fontSize: 14)),
                  ),

                  const SizedBox(height: 24),

                  // 🔹 Tombol Assign Technisi
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                    onPressed: () {
                      // misalnya teknisi dipilih dari dropdown / hardcoded dulu
                      String selectedTechnician = "Budi";  
                      showTechnicianSelectDialog(context); 
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFB70F0F),
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(30)),
                    ),
                    icon: const Icon(Icons.engineering, color: Colors.white),
                    label: Text(
                      "Assign Technisi",
                      style: GoogleFonts.poppins(
                          fontSize: 15,
                          fontWeight: FontWeight.bold,
                          color: Colors.white),
                    ),
                  ),
                  )
                ],
              ),
            ),
          ),
        ),
      ),
      
    );
  }

  // 🔹 Helper Row Info
  Widget _detailRow(String label, String? value, {Widget? custom}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            flex: 3,
            child: Text(label,
                style: GoogleFonts.poppins(
                    fontSize: 14, color: Colors.black87)),
          ),
          Expanded(
            flex: 5,
            child: Align(
              alignment: Alignment.centerRight,
              child: custom ??
                  Text(value ?? "-",
                      textAlign: TextAlign.right,
                      style: GoogleFonts.poppins(
                          fontSize: 14, fontWeight: FontWeight.w600)),
            ),
          ),
        ],
      ),
    );
  }

  // 🔹 Date Formatter
  String _formatDate(DateTime d) {
    const months = [
      "",
      "January",
      "February",
      "March",
      "April",
      "May",
      "June",
      "July",
      "August",
      "September",
      "October",
      "November",
      "December"
    ];
    return "${d.day} ${months[d.month]} ${d.year}";
  }
  
}
