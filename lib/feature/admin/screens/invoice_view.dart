import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import '../widgets/custom_header.dart';
import '../widgets/invoice/payment_invoice_card.dart';
import 'package:bengkel_online_flutter/core/models/service.dart';

/// Read-only invoice view for completed/lunas services
class InvoiceViewPage extends StatelessWidget {
  final ServiceModel service;

  const InvoiceViewPage({super.key, required this.service});

  String _formatCurrency(num amount) {
    final formatter = NumberFormat('#,###', 'id_ID');
    return 'Rp ${formatter.format(amount)}';
  }

  String _formatCurrencyShort(num amount) {
    if (amount >= 1000000) {
      return 'IDR. ${(amount / 1000000).toStringAsFixed(1)}M';
    } else if (amount >= 1000) {
      return 'IDR. ${(amount / 1000).toStringAsFixed(0)}K';
    }
    return 'IDR. $amount';
  }

  @override
  Widget build(BuildContext context) {
    final customerName = service.displayCustomerName;
    final vehicleName = service.displayVehicleName;
    final plate = service.displayVehiclePlate;
    final phone = service.customer?.phoneNumber ?? '-';
    final address = service.customer?.address ?? '-';
    final invoiceDate = DateFormat('MMM d, yyyy').format(service.scheduledDate ?? DateTime.now()).toUpperCase();
    
    // Get items from service
    final serviceItems = (service.items ?? []).map((item) => {
      'name': (item.name ?? service.name).toString(),
      'price': _formatCurrency(item.price ?? service.price ?? 0),
    }).toList();
    
    // If no items, use service info
    if (serviceItems.isEmpty) {
      serviceItems.add({
        'name': service.name,
        'price': _formatCurrency(service.price ?? 0),
      });
    }
    
    final totalAmount = service.items?.fold<num>(0, (sum, item) => sum + (item.price ?? 0)) ?? service.price ?? 0;

    final bool isOnSiteService = (service.type?.toLowerCase() ?? '') == 'on-site' || 
                                  (service.type?.toLowerCase() ?? '') == 'onsite';

    return Scaffold(
      appBar: const CustomHeader(
        title: 'Detail Invoice',
        showBack: true,
      ),
      body: Container(
        width: double.infinity,
        height: double.infinity,
        color: Colors.white,
        child: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
            child: Column(
              children: [
                // Service type badge
                Container(
                  margin: const EdgeInsets.only(bottom: 12),
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  decoration: BoxDecoration(
                    color: isOnSiteService ? Colors.orange : Colors.blue,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        isOnSiteService ? Icons.store : Icons.calendar_month,
                        color: Colors.white,
                        size: 18,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        isOnSiteService ? 'ON-SITE SERVICE' : 'BOOKING SERVICE',
                        style: GoogleFonts.poppins(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ),

                // Invoice Card (read-only)
                PaymentInvoiceCard(
                  vehicleName: vehicleName.toUpperCase(),
                  invoiceNumber: 'INV-${service.id.substring(0, 8).toUpperCase()}',
                  licensePlate: plate,
                  phoneNumber: phone,
                  serviceItems: serviceItems,
                  totalAmount: _formatCurrency(totalAmount),
                  notes: service.description ?? service.complaint ?? 'Tidak ada catatan',
                  customerName: customerName,
                  customerAddress: address,
                  totalTagihan: _formatCurrencyShort(totalAmount),
                  invoiceDate: invoiceDate,
                  isSent: true, // Already paid
                  onSend: () {}, // No action needed
                ),
                
                const SizedBox(height: 24),
                
                // Lunas status card
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withAlpha(26),
                        blurRadius: 10,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Column(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: Colors.green.withOpacity(0.1),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(Icons.check_circle, size: 64, color: Colors.green),
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'LUNAS',
                        style: GoogleFonts.poppins(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: Colors.green,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Transaksi telah selesai',
                        style: GoogleFonts.poppins(
                          fontSize: 14,
                          color: Colors.grey[600],
                        ),
                      ),
                    ],
                  ),
                ),
                
                const SizedBox(height: 16),
                
                // Back button
                SizedBox(
                  width: double.infinity,
                  height: 52,
                  child: ElevatedButton.icon(
                    onPressed: () => Navigator.pop(context),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(26),
                      ),
                      elevation: 4,
                    ),
                    icon: const Icon(Icons.arrow_back, color: Color(0xFFB31217)),
                    label: Text(
                      'Kembali',
                      style: GoogleFonts.poppins(
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                        color: const Color(0xFFB31217),
                      ),
                    ),
                  ),
                ),
                
                const SizedBox(height: 32),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
