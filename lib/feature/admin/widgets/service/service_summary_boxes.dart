import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class ServiceSummaryBoxes extends StatelessWidget {
  final int all;
  final int accepted;
  final int pending;
  final int declined;

  const ServiceSummaryBoxes({
    super.key,
    required this.all,
    required this.accepted,
    required this.pending,
    required this.declined,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(children: [
        _buildBox("Semua", all, Colors.blueGrey, Colors.grey.shade200),
        _buildBox("Diterima", accepted, const Color(0xFF4285F4), const Color(0xFFE8F0FE)), // Blue
        _buildBox("Menunggu", pending, const Color(0xFFFBBC05), const Color(0xFFFEF7E0)), // Yellow
        _buildBox("Ditolak", declined, const Color(0xFFD32F2F), const Color(0xFFFFEBEE)), // Red
      ]),
    );
  }

  Widget _buildBox(String label, int count, Color textColor, Color bgColor) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12),
        margin: const EdgeInsets.symmetric(horizontal: 4),
        decoration: BoxDecoration(
          color: bgColor,
          borderRadius: BorderRadius.circular(12),
          // border: Border.all(color: textColor.withOpacity(0.3), width: 1),
        ),
        child: Column(
          children: [
            Text("$count",
                style: GoogleFonts.poppins(
                    fontSize: 20, fontWeight: FontWeight.bold, color: textColor)),
            const SizedBox(height: 6),
            Text(label,
                style: GoogleFonts.poppins(
                    fontSize: 10, fontWeight: FontWeight.w600, color: textColor), maxLines: 1, overflow: TextOverflow.ellipsis),
          ],
        ),
      ),
    );
  }
}
