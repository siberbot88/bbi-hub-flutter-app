import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class InvoiceCustomerHeader extends StatelessWidget {
  final Map<String, dynamic> task;

  const InvoiceCustomerHeader({
    super.key,
    required this.task,
  });

  String _getInitials(String name) {
    if (name.isEmpty) return "?";
    final parts = name.trim().split(' ');
    if (parts.isEmpty) return "?";
    if (parts.length == 1) return parts[0].substring(0, 1).toUpperCase();
    return (parts[0][0] + parts[1][0]).toUpperCase();
  }

  @override
  Widget build(BuildContext context) {
    final DateTime? orderDate =
        task['date'] is DateTime ? task['date'] : null;

    final userName = task['user'] ?? "Prabowo";

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        CircleAvatar(
          radius: 20,
          backgroundColor: Colors.blue.shade50,
          child: Text(
            _getInitials(userName),
            style: GoogleFonts.poppins(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: Colors.blue.shade700,
            ),
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(task['user'] ?? "Prabowo",
                  style: GoogleFonts.poppins(
                      fontSize: 15, fontWeight: FontWeight.w600)),
              const SizedBox(height: 2),
              Text("ID: ${task['id'] ?? '4589930272'}",
                  style: GoogleFonts.poppins(
                      fontSize: 12, color: Colors.grey[700])),
            ],
          ),
        ),
        Column(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Text("Tanggal order",
                style: GoogleFonts.poppins(
                    fontSize: 12, color: Colors.grey[700])),
            Text(
              orderDate != null
                  ? _formatDate(orderDate)
                  : "2 September 2025",
              style: GoogleFonts.poppins(
                  fontSize: 12, fontWeight: FontWeight.w600),
            ),
          ],
        ),
      ],
    );
  }

  String _formatDate(DateTime d) {
    const months = [
      "Jan",
      "Feb",
      "Mar",
      "Apr",
      "Mei",
      "Jun",
      "Jul",
      "Ags",
      "Sep",
      "Okt",
      "Nov",
      "Des"
    ];
    return "${d.day} ${months[d.month - 1]} ${d.year}";
  }
}
