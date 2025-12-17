import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class LoggingSummaryBoxes extends StatelessWidget {
  final int declined;

  const LoggingSummaryBoxes({
    super.key,
    required this.pending,
    required this.inProgress,
    required this.completed,
    required this.lunas,
    required this.declined,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(children: [
          _buildBox("Pending", pending, Colors.blue),
          const SizedBox(width: 8),
          _buildBox("Proses", inProgress, Colors.orange),
          const SizedBox(width: 8),
          _buildBox("Selesai", completed, Colors.green),
          const SizedBox(width: 8),
          _buildBox("Lunas", lunas, Colors.teal),
          const SizedBox(width: 8),
          _buildBox("Ditolak", declined, Colors.red),
        ]),
      ),
    );
  }

  Widget _buildBox(String label, int count, Color color) {
    return Container(
      width: 100, // Fixed width since we use scroll
      padding: const EdgeInsets.symmetric(vertical: 12),
      // margin removed since we use SizedBox
      decoration: BoxDecoration(
          color: Colors.white,
          border: Border.all(color: color.withAlpha(153), width: 1.5), // 0.6 * 255
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(color: Colors.black.withAlpha(5), blurRadius: 4) // 0.02 * 255
          ],
        ),
        child: Column(
          children: [
            Text("$count",
                style: GoogleFonts.poppins(
                    fontSize: 20, fontWeight: FontWeight.bold, color: color)),
            const SizedBox(height: 6),
            Text(label,
                style: GoogleFonts.poppins(
                    fontSize: 12, fontWeight: FontWeight.w600, color: color)),
          ],
        ),
      ),
    );
  }
}
