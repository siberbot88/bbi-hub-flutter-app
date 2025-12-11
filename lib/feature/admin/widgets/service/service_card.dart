import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../reject_dialog.dart';
import '../accept_dialog.dart';
import '../../screens/service_detail.dart';
import 'service_helpers.dart';
import 'package:provider/provider.dart';
import 'package:bengkel_online_flutter/feature/admin/providers/admin_service_provider.dart';
import 'package:bengkel_online_flutter/core/models/service.dart';

class ServiceCard extends StatelessWidget {
  final ServiceModel service;

  const ServiceCard({super.key, required this.service});

  @override
  Widget build(BuildContext context) {
    // Helper accessors
    final customerName = service.displayCustomerName;
    final vehicleName = service.displayVehicleName;
    final plate = service.displayVehiclePlate;
    final category = service.vehicle?.category ?? service.vehicle?.type ?? "Unknown";
    final scheduledDate = service.scheduledDate ?? DateTime.now();
    final serviceName = service.name;
    final id = service.id;

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
                    "https://i.pravatar.cc/150?img=$id"),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(customerName,
                        style: GoogleFonts.poppins(
                            fontWeight: FontWeight.w600, fontSize: 14)),
                    Text("ID: $id",
                        style: GoogleFonts.poppins(
                            fontSize: 12, color: Colors.grey[600])),
                  ],
                ),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(ServiceHelpers.formatDate(scheduledDate),
                      style: GoogleFonts.poppins(
                          fontSize: 12, color: Colors.grey[700])),
                  // Jika mau menampilkan info scheduled spesifik
                  Text("Scheduled",
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
                  serviceName,
                  style: GoogleFonts.poppins(
                      fontSize: 16, fontWeight: FontWeight.bold),
                ),
              ),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: _getVehicleBgColor(category)
                      .withAlpha(51), // 0.2 * 255
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  category,
                  style: GoogleFonts.poppins(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: _getVehicleTextColor(category)),
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
                  Text(plate,
                      style: GoogleFonts.poppins(
                          fontSize: 15, fontWeight: FontWeight.w600)),
                  const SizedBox(height: 10),
                  Row(
                    children: [
                      Builder(
                        builder: (ctx) => ElevatedButton(
                          onPressed: () => showRejectDialog(
                            ctx,
                            onConfirm: (reason, desc) {
                              context
                                  .read<AdminServiceProvider>()
                                  .declineServiceAsAdmin(
                                    service.id,
                                    reason: reason,
                                    reasonDescription: desc,
                                  );
                            },
                          ),
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
                        onPressed: () => showAcceptDialog(
                          context,
                          onConfirm: () {
                            context
                                .read<AdminServiceProvider>()
                                .acceptServiceAsAdmin(service.id);
                          },
                        ),
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
                  Text(vehicleName,
                      style: GoogleFonts.poppins(
                          fontSize: 15, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 10),
                  ElevatedButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (_) => ServiceDetailPage(service: service)),
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
