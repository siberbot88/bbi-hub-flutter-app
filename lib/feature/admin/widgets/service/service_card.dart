import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../reject_dialog.dart';
import '../accept_dialog.dart';
import '../../screens/service_detail.dart';
import 'service_helpers.dart';

class ServiceCard extends StatelessWidget {
  final Map<String, dynamic> task;

  const ServiceCard({super.key, required this.task});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha(20), // 0.08 * 255
            blurRadius: 6,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              CircleAvatar(
                radius: 18,
                backgroundImage: NetworkImage(
                    "https://i.pravatar.cc/150?img=${task['id']}"),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(task['name'],
                        style: GoogleFonts.poppins(
                            fontWeight: FontWeight.w600, fontSize: 14)),
                    Text("ID: ${task['id']}",
                        style: GoogleFonts.poppins(
                            fontSize: 12, color: Colors.grey[600])),
                  ],
                ),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(ServiceHelpers.formatDate(task['date'] as DateTime),
                      style: GoogleFonts.poppins(
                          fontSize: 12, color: Colors.grey[700])),
                  Text("Scheduled : 7 September 2025",
                      style: GoogleFonts.poppins(
                          fontSize: 12, color: Colors.grey[600])),
                ],
              )
            ],
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              Expanded(
                child: Text(
                  task['service'],
                  style: GoogleFonts.poppins(
                      fontSize: 16, fontWeight: FontWeight.bold),
                ),
              ),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: _getVehicleBgColor(task['vehicleCategory'])
                      .withAlpha(51), // 0.2 * 255
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  task['vehicleCategory'] ?? "Unknown",
                  style: GoogleFonts.poppins(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: _getVehicleTextColor(task['vehicleCategory'])),
                ),
              )
            ],
          ),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text("Plat Nomor",
                      style:
                          GoogleFonts.poppins(fontSize: 12, color: Colors.grey)),
                  Text(task['plate'],
                      style: GoogleFonts.poppins(
                          fontSize: 15, fontWeight: FontWeight.w600)),
                  const SizedBox(height: 10),
                  Row(
                    children: [
                      Builder(
                        builder: (ctx) => ElevatedButton(
                          onPressed: () => showRejectDialog(ctx),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.red.shade700,
                            padding: const EdgeInsets.symmetric(
                                horizontal: 20, vertical: 12),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(30),
                            ),
                          ),
                          child: Text(
                            "Tolak",
                            style: GoogleFonts.poppins(
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      ElevatedButton(
                        onPressed: () => showAcceptDialog(context),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.green.shade700,
                          padding: const EdgeInsets.symmetric(
                              horizontal: 20, vertical: 12),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(30),
                          ),
                        ),
                        child: Text(
                          "Terima",
                          style: GoogleFonts.poppins(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ],
                  )
                ],
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text("Type Motor",
                      style:
                          GoogleFonts.poppins(fontSize: 12, color: Colors.grey)),
                  Text(task['motor'],
                      style: GoogleFonts.poppins(
                          fontSize: 15, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 10),
                  ElevatedButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (_) => ServiceDetailPage(task: task)),
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.orange,
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(30)),
                    ),
                    child: Text(
                      "Detail",
                      style: GoogleFonts.poppins(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ],
              )
            ],
          )
        ],
      ),
    );
  }

  Color _getVehicleBgColor(String? category) {
    switch (category?.toLowerCase()) {
      case "sepeda motor":
        return Colors.red.shade100;
      case "mobil":
        return Colors.orange.shade200;
      default:
        return Colors.grey.shade300;
    }
  }

  Color _getVehicleTextColor(String? category) {
    switch (category?.toLowerCase()) {
      case "sepeda motor":
        return Colors.red.shade700;
      case "mobil":
        return Colors.orange.shade800;
      default:
        return Colors.black87;
    }
  }
}
