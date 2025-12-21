import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
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
            color: Colors.black.withAlpha(20),
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
                radius: 20,
                backgroundColor: AppColors.primaryRed.withOpacity(0.1),
                child: Text(
                  _getInitials(customerName),
                  style: AppTextStyles.labelBold(color: AppColors.primaryRed),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(customerName, style: AppTextStyles.labelBold()),
                    Text("ID: $id", style: AppTextStyles.caption()),
                  ],
                ),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(ServiceHelpers.formatDate(scheduledDate),
                      style: AppTextStyles.caption(color: AppColors.textPrimary)),
                  Container(
                    margin: const EdgeInsets.only(top: 4),
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                    decoration: BoxDecoration(
                      color: AppColors.statusPending.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Text("Scheduled",
                        style: AppTextStyles.caption(color: AppColors.statusPending)
                            .copyWith(fontSize: 10, fontWeight: FontWeight.bold)),
                  ),
                ],
              )
            ],
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              Expanded(
                child: Text(serviceName, style: AppTextStyles.heading5()),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: _getVehicleBgColor(category).withOpacity(0.2),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  category,
                  style: AppTextStyles.caption(color: _getVehicleTextColor(category))
                      .copyWith(fontWeight: FontWeight.w600),
                ),
              )
            ],
          ),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text("Plat Nomor", style: AppTextStyles.caption()),
                    Text(plate,
                        style: AppTextStyles.bodyMedium(color: AppColors.textPrimary)
                            .copyWith(fontWeight: FontWeight.w600)),
                    const SizedBox(height: 10),
                    _buildActionButtons(context),
                  ],
                ),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text("Type Motor", style: AppTextStyles.caption()),
                  Text(vehicleName,
                      style: AppTextStyles.bodyMedium().copyWith(fontWeight: FontWeight.bold)),
                  const SizedBox(height: 10),
                  ElevatedButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (_) => ServiceDetailPage(service: service)),
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.orange,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
                    ),
                    child: Text("Detail", style: AppTextStyles.buttonSmall(color: Colors.white)),
                  ),
                ],
              )
            ],
          )
        ],
      ),
    );
  }

  Future<void> _handleAccept(BuildContext context) async {
    // 1. Show Loading
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => const Center(child: CircularProgressIndicator()),
    );

    try {
      // 2. Call API
      // Note: provider.acceptServiceAsAdmin already calls fetchServices() internally if successful
      // but let's be explicit if needed. AdminServiceProvider.acceptServiceAsAdmin returns void currently
      // but throws on error.
      await context.read<AdminServiceProvider>().acceptServiceAsAdmin(service.id);
      
      if (!context.mounted) return;
      // Close loading dialog
      Navigator.of(context, rootNavigator: true).pop();

      // 3. Show Success Message
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Jadwal diterima! Masuk ke tab 'Terima'"),
          backgroundColor: Colors.green,
          duration: Duration(seconds: 2),
        ),
      );
      
      // No navigation needed, list updates automatically via Provider
    } catch (e) {
      if (!context.mounted) return;
      // Close loading dialog
      Navigator.of(context, rootNavigator: true).pop();
      
      // Show Error
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Gagal menerima jadwal: $e"),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Widget _buildActionButtons(BuildContext context) {
    final status = (service.acceptanceStatus ?? 'pending').toLowerCase();

    if (status == 'pending') {
      return Wrap(
        spacing: 8,
        runSpacing: 8,
        children: [
          SizedBox(
            height: 36,
            child: ElevatedButton(
              onPressed: () => showRejectDialog(
                context,
                onConfirm: (reason, desc) {
                  context.read<AdminServiceProvider>().declineServiceAsAdmin(
                    service.id,
                    reason: reason,
                    reasonDescription: desc,
                  );
                },
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red.shade700,
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 0),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
              ),
              child: Text("Tolak", style: AppTextStyles.buttonSmall(color: Colors.white)),
            ),
          ),
          SizedBox(
            height: 36,
            child: ElevatedButton(
              onPressed: () => showAcceptDialog(
                context,
                onConfirm: () {
                   // Close the generic confirmation dialog first
                   // Wait, showAcceptDialog handles onConfirm. 
                   // Let's modify showAcceptDialog call or just call _handleAccept directly?
                   // showAcceptDialog typically closes itself then calls onConfirm.
                   _handleAccept(context);
                },
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green.shade700,
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 0),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
              ),
              child: Text("Terima", style: AppTextStyles.buttonSmall(color: Colors.white)),
            ),
          ),
        ],
      );
    } else if (status == 'accepted') {
      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: Colors.green.withOpacity(0.1),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: Colors.green),
        ),
        child: Text("Diterima",
            style: AppTextStyles.caption(color: Colors.green).copyWith(fontWeight: FontWeight.bold)),
      );
    } else if (['declined', 'rejected', 'canceled', 'cancelled'].contains(status)) {
      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: Colors.red.withOpacity(0.1),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: Colors.red),
        ),
        child: Text("Ditolak",
            style: AppTextStyles.caption(color: Colors.red).copyWith(fontWeight: FontWeight.bold)),
      );
    } else {
      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: Colors.grey.withOpacity(0.1),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: Colors.grey),
        ),
        child: Text(service.acceptanceStatus ?? 'Unknown',
            style: AppTextStyles.caption(color: Colors.grey)),
      );
    }
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

  String _getInitials(String name) {
    if (name.isEmpty) return "?";
    final parts = name.trim().split(' ');
    if (parts.isEmpty) return "?";

    if (parts.length == 1) {
      return parts[0].substring(0, 1).toUpperCase();
    }

    return (parts[0][0] + parts[1][0]).toUpperCase();
  }
}
