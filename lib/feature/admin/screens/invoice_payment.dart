import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../widgets/custom_header.dart';
import '../providers/admin_service_provider.dart';
import 'package:bengkel_online_flutter/core/models/service.dart';

class PaymentInvoicePage extends StatefulWidget {
  final ServiceModel service;
  final String transactionId;
  final List<Map<String, dynamic>> items;
  final int totalAmount;
  final String? notes;

  const PaymentInvoicePage({
    super.key,
    required this.service,
    required this.transactionId,
    required this.items,
    required this.totalAmount,
    this.notes,
  });

  @override
  State<PaymentInvoicePage> createState() => _PaymentInvoicePageState();
}

class _PaymentInvoicePageState extends State<PaymentInvoicePage> {
  bool _isCreatingInvoice = false;
  bool _isMarkingPaid = false;
  String? _invoiceId;
  String? _invoiceCode;
  bool _isPaid = false;
  String? _selectedPaymentMethod;

  final List<String> _paymentMethods = ['Cash', 'Transfer Bank', 'QRIS', 'Kartu Debit/Kredit'];

  Future<void> _createAndSendInvoice() async {
    setState(() => _isCreatingInvoice = true);

    try {
      final provider = context.read<AdminServiceProvider>();
      
      // Create invoice from transaction
      final invoiceData = await provider.createInvoice(widget.transactionId);
      
      setState(() {
        _invoiceId = invoiceData['id']?.toString();
        _invoiceCode = invoiceData['code']?.toString() ?? 'INV-${DateTime.now().millisecondsSinceEpoch}';
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Invoice berhasil dibuat dan dikirimkan!'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Gagal membuat invoice: $e'), backgroundColor: Colors.red),
        );
      }
    } finally {
      if (mounted) setState(() => _isCreatingInvoice = false);
    }
  }

  Future<void> _markAsPaid() async {
    if (_invoiceId == null || _selectedPaymentMethod == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Pilih metode pembayaran terlebih dahulu'), backgroundColor: Colors.orange),
      );
      return;
    }

    setState(() => _isMarkingPaid = true);

    try {
      final provider = context.read<AdminServiceProvider>();
      
      await provider.markInvoicePaid(_invoiceId!, paymentMethod: _selectedPaymentMethod);
      
      setState(() => _isPaid = true);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Pembayaran berhasil dicatat!'),
            backgroundColor: Colors.green,
          ),
        );
        
        // Pop back to service list after success
        Navigator.of(context).popUntil((route) => route.isFirst);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Gagal mencatat pembayaran: $e'), backgroundColor: Colors.red),
        );
      }
    } finally {
      if (mounted) setState(() => _isMarkingPaid = false);
    }
  }

  String _formatCurrency(int amount) {
    return 'Rp ${amount.toString().replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (m) => '${m[1]}.')}';
  }

  @override
  Widget build(BuildContext context) {
    final customerName = widget.service.displayCustomerName;
    final vehicleName = widget.service.displayVehicleName;
    final plate = widget.service.displayVehiclePlate;
    final phone = widget.service.customer?.phoneNumber ?? '-';
    final address = widget.service.customer?.address ?? '-';
    final invoiceDate = DateFormat('MMM d, yyyy').format(DateTime.now());

    return Scaffold(
      appBar: const CustomHeader(
        title: 'Nota Pembayaran',
        showBack: true,
      ),
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFFB31217), Color(0xFFE52D27)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                // Invoice Card
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.1),
                        blurRadius: 10,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Header
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('INVOICE', style: GoogleFonts.poppins(fontSize: 24, fontWeight: FontWeight.bold, color: const Color(0xFFDC2626))),
                              if (_invoiceCode != null)
                                Text(_invoiceCode!, style: GoogleFonts.poppins(fontSize: 12, color: Colors.grey)),
                            ],
                          ),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: [
                              Text('Tanggal', style: GoogleFonts.poppins(fontSize: 12, color: Colors.grey)),
                              Text(invoiceDate, style: GoogleFonts.poppins(fontSize: 14, fontWeight: FontWeight.w600)),
                            ],
                          ),
                        ],
                      ),
                      
                      const Divider(height: 32),
                      
                      // Customer Info
                      Text('Pelanggan', style: GoogleFonts.poppins(fontSize: 12, color: Colors.grey)),
                      Text(customerName, style: GoogleFonts.poppins(fontSize: 16, fontWeight: FontWeight.w600)),
                      const SizedBox(height: 4),
                      Text(phone, style: GoogleFonts.poppins(fontSize: 14, color: Colors.grey[600])),
                      Text(address, style: GoogleFonts.poppins(fontSize: 14, color: Colors.grey[600])),
                      
                      const SizedBox(height: 16),
                      
                      // Vehicle Info
                      Row(
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text('Kendaraan', style: GoogleFonts.poppins(fontSize: 12, color: Colors.grey)),
                                Text(vehicleName, style: GoogleFonts.poppins(fontSize: 14, fontWeight: FontWeight.w600)),
                              ],
                            ),
                          ),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.end,
                              children: [
                                Text('Plat Nomor', style: GoogleFonts.poppins(fontSize: 12, color: Colors.grey)),
                                Text(plate, style: GoogleFonts.poppins(fontSize: 14, fontWeight: FontWeight.w600)),
                              ],
                            ),
                          ),
                        ],
                      ),
                      
                      const Divider(height: 32),
                      
                      // Service Items
                      Text('Rincian Servis', style: GoogleFonts.poppins(fontSize: 14, fontWeight: FontWeight.bold)),
                      const SizedBox(height: 12),
                      
                      ...widget.items.map((item) => Padding(
                        padding: const EdgeInsets.only(bottom: 8),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(item['nama'] ?? '-', style: GoogleFonts.poppins(fontSize: 14)),
                                  Text(item['jenis'] ?? '', style: GoogleFonts.poppins(fontSize: 12, color: Colors.grey)),
                                ],
                              ),
                            ),
                            Text(_formatCurrency(item['harga'] ?? 0), style: GoogleFonts.poppins(fontSize: 14, fontWeight: FontWeight.w500)),
                          ],
                        ),
                      )),
                      
                      const Divider(height: 24),
                      
                      // Total
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text('TOTAL', style: GoogleFonts.poppins(fontSize: 18, fontWeight: FontWeight.bold)),
                          Text(_formatCurrency(widget.totalAmount), 
                              style: GoogleFonts.poppins(fontSize: 20, fontWeight: FontWeight.bold, color: const Color(0xFFDC2626))),
                        ],
                      ),
                      
                      if (widget.notes != null && widget.notes!.isNotEmpty) ...[
                        const Divider(height: 24),
                        Text('Catatan Teknisi', style: GoogleFonts.poppins(fontSize: 12, color: Colors.grey)),
                        const SizedBox(height: 4),
                        Text(widget.notes!, style: GoogleFonts.poppins(fontSize: 14)),
                      ],
                      
                      // Payment Method Selection (if invoice created)
                      if (_invoiceId != null && !_isPaid) ...[
                        const Divider(height: 32),
                        Text('Metode Pembayaran', style: GoogleFonts.poppins(fontSize: 14, fontWeight: FontWeight.bold)),
                        const SizedBox(height: 12),
                        DropdownButtonFormField<String>(
                          value: _selectedPaymentMethod,
                          decoration: InputDecoration(
                            border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                            contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                          ),
                          hint: const Text('Pilih Metode Pembayaran'),
                          items: _paymentMethods.map((method) => 
                            DropdownMenuItem(value: method, child: Text(method))
                          ).toList(),
                          onChanged: (value) => setState(() => _selectedPaymentMethod = value),
                        ),
                      ],
                      
                      // Status Badge
                      if (_isPaid) ...[
                        const SizedBox(height: 24),
                        Center(
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                            decoration: BoxDecoration(
                              color: Colors.green.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(24),
                              border: Border.all(color: Colors.green),
                            ),
                            child: Text('LUNAS', style: GoogleFonts.poppins(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.green)),
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
                
                const SizedBox(height: 24),
                
                // Action Buttons
                if (!_isPaid)
                  SizedBox(
                    width: double.infinity,
                    height: 56,
                    child: ElevatedButton(
                      onPressed: (_isCreatingInvoice || _isMarkingPaid) 
                          ? null 
                          : (_invoiceId == null ? _createAndSendInvoice : _markAsPaid),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: _invoiceId == null ? const Color(0xFFDC2626) : Colors.green,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
                      ),
                      child: (_isCreatingInvoice || _isMarkingPaid)
                          ? const SizedBox(width: 24, height: 24, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                          : Text(
                              _invoiceId == null ? 'Buat & Kirim Invoice' : 'Tandai Lunas',
                              style: GoogleFonts.poppins(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white),
                            ),
                    ),
                  ),
                
                const SizedBox(height: 16),
              ],
            ),
          ),
        ),
      ),
    );
  }
}