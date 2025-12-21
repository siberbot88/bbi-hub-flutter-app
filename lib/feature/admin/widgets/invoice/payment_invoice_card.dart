import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class PaymentInvoiceCard extends StatelessWidget {
  final String vehicleName;
  final String invoiceNumber;
  final String licensePlate;
  final String phoneNumber;
  final List<Map<String, String>> serviceItems;
  final String totalAmount;
  final String notes;
  final String customerName;
  final String customerAddress;
  final String totalTagihan;
  final String invoiceDate;
  final bool isSent;
  final VoidCallback onSend;
  final String? voucherCode;
  final String? discountAmount;
  final String? paymentDuration;

  const PaymentInvoiceCard({
    super.key,
    required this.vehicleName,
    required this.invoiceNumber,
    required this.licensePlate,
    required this.phoneNumber,
    required this.serviceItems,
    required this.totalAmount,
    required this.notes,
    required this.customerName,
    required this.customerAddress,
    required this.totalTagihan,
    required this.invoiceDate,
    required this.isSent,
    required this.onSend,
    this.voucherCode,
    this.discountAmount,
    this.paymentDuration,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha(23), // 0.09 * 255
            blurRadius: 14,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Stack(
        children: [
          // Header merah
          Container(
            height: 180,
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [Color(0xFFB31217), Color(0xFFE52D27)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(18),
                topRight: Radius.circular(18),
                bottomLeft: Radius.circular(36),
                bottomRight: Radius.circular(36),
              ),
            ),
            padding: const EdgeInsets.fromLTRB(16, 14, 16, 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 10, vertical: 6),
                      decoration: BoxDecoration(
                        color: Colors.white.withAlpha(38), // 0.15 * 255
                        borderRadius: BorderRadius.circular(18),
                      ),
                      child: Text(
                        '● Invoice',
                        style: GoogleFonts.poppins(
                          color: Colors.white,
                          fontWeight: FontWeight.w600,
                          fontSize: 12,
                        ),
                      ),
                    ),
                    const Spacer(),
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: Colors.white.withAlpha(46), // 0.18 * 255
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(Icons.edit, size: 16, color: Colors.white),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                Text(
                  vehicleName,
                  style: GoogleFonts.poppins(
                    color: Colors.white,
                    fontSize: 28,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 6),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: Text(
                        invoiceNumber,
                        style: GoogleFonts.poppins(
                          color: Colors.white.withAlpha(230), // 0.9 * 255
                          fontSize: 13,
                        ),
                      ),
                    ),
                    Expanded(
                      child: Text(
                        'LP: $licensePlate\n$phoneNumber',
                        textAlign: TextAlign.right,
                        style: GoogleFonts.poppins(
                          color: Colors.white.withAlpha(230), // 0.9 * 255
                          fontSize: 13,
                          height: 1.35,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),

          // Badge putih mengambang
          _InvoicePill(
            customerName: customerName,
            customerAddress: customerAddress,
            totalTagihan: totalTagihan,
            invoiceDate: invoiceDate,
          ),

          // Content
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 244, 16, 18),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        'Daftar Perbaikan',
                        style: GoogleFonts.poppins(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                    Text(
                      'TOTAL',
                      style: GoogleFonts.poppins(
                        fontSize: 12.5,
                        color: Colors.grey[700],
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                ...serviceItems.map((item) => _rowItem(item['name']!, item['price']!)),
               const SizedBox(height: 12),
                Divider(color: Colors.grey.shade300, height: 28),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Catatan',
                              style: GoogleFonts.poppins(
                                  fontSize: 13, fontWeight: FontWeight.w600)),
                          const SizedBox(height: 6),
                          Text(
                            notes,
                            style: GoogleFonts.poppins(
                              fontSize: 12.5,
                              color: Colors.black87,
                              height: 1.35,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 10),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        // Show voucher discount if applied
                        if (voucherCode != null && discountAmount != null) ...[
                          Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(Icons.local_offer, size: 14, color: Colors.green[700]),
                              const SizedBox(width: 4),
                              Text(
                                voucherCode!,
                                style: GoogleFonts.poppins(
                                  fontSize: 11,
                                  color: Colors.green[700],
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
                          ),
                          Text(
                            '- $discountAmount',
                            style: GoogleFonts.poppins(
                              fontSize: 12,
                              color: Colors.green[700],
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          const SizedBox(height: 4),
                        ],
                        Text(
                          'TOTAL AMOUNT',
                          style: GoogleFonts.poppins(
                            fontSize: 11.5,
                            color: Colors.grey[700],
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          totalAmount,
                          style: GoogleFonts.poppins(
                            fontSize: 15.5,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Status pembayaran',
                            style: GoogleFonts.poppins(
                              fontSize: 12,
                              color: Colors.grey[700],
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          const SizedBox(height: 6),
                          _PaymentStatusBadge(isSent: isSent),
                        ],
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Text(
                            'Durasi Pembayaran',
                            style: GoogleFonts.poppins(
                              fontSize: 12,
                              color: Colors.grey[700],
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          const SizedBox(height: 6),
                          Text(
                            paymentDuration ?? '01 : 00 : 00',
                            style: GoogleFonts.poppins(
                              fontSize: 14,
                              fontWeight: FontWeight.w700,
                              color: paymentDuration != null ? const Color(0xFFB31217) : Colors.black,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 22),
                SizedBox(
                  width: double.infinity,
                  height: 48,
                  child: ElevatedButton(
                    onPressed: isSent ? null : onSend,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFB31217),
                      disabledBackgroundColor:
                          const Color(0xFFB31217).withAlpha(128), // 0.5 * 255
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(28),
                      ),
                      elevation: 4,
                    ),
                    child: Text(
                      'Kirim Invoice',
                      style: GoogleFonts.poppins(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _rowItem(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        children: [
          Expanded(
            child: Text(
              label,
              style: GoogleFonts.poppins(
                fontSize: 13.5,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
          Text(
            value,
            style: GoogleFonts.poppins(
              fontSize: 13.5,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}

class _InvoicePill extends StatelessWidget {
  final String customerName;
  final String customerAddress;
  final String totalTagihan;
  final String invoiceDate;

  const _InvoicePill({
    required this.customerName,
    required this.customerAddress,
    required this.totalTagihan,
    required this.invoiceDate,
  });

  @override
  Widget build(BuildContext context) {
    return Positioned(
      left: 16,
      right: 16,
      top: 140,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          Container(
            width: double.infinity,
            padding: const EdgeInsets.fromLTRB(16, 14, 140, 14),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(22),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withAlpha(20), // 0.08 * 255
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('INVOICE FOR',
                    style: GoogleFonts.poppins(
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                      color: Colors.grey[700],
                    )),
                const SizedBox(height: 4),
                Text(customerName,
                    style: GoogleFonts.poppins(
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                    )),
                const SizedBox(height: 2),
                Text(
                  customerAddress,
                  style: GoogleFonts.poppins(
                    fontSize: 12.5,
                    color: Colors.black87,
                    height: 1.35,
                  ),
                ),
              ],
            ),
          ),
          Positioned(
            right: 8,
            top: 8,
            bottom: 8,
            child: Container(
              width: 132,
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(18),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withAlpha(26), // 0.10 * 255
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text('Total Tagihan',
                      style: GoogleFonts.poppins(
                        fontSize: 10,
                        fontWeight: FontWeight.w600,
                        color: Colors.grey[700],
                      )),
                  const SizedBox(height: 2),
                  FittedBox(
                    fit: BoxFit.scaleDown,
                    child: Text(totalTagihan,
                        style: GoogleFonts.poppins(
                          fontSize: 16,
                          fontWeight: FontWeight.w800,
                        )),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '● $invoiceDate',
                    style: GoogleFonts.poppins(
                      fontSize: 9.5,
                      color: const Color(0xFFB31217),
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _PaymentStatusBadge extends StatelessWidget {
  final bool isSent;

  const _PaymentStatusBadge({required this.isSent});

  @override
  Widget build(BuildContext context) {
    if (isSent) {
      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
        decoration: BoxDecoration(
          color: const Color(0xFFDFF2E0),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Text(
          'Berhasil',
          style: GoogleFonts.poppins(
            fontSize: 12,
            fontWeight: FontWeight.w700,
            color: const Color(0xFF2E7D32),
          ),
        ),
      );
    }
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
      decoration: BoxDecoration(
        color: Colors.grey.shade300,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        'PENDING',
        style: GoogleFonts.poppins(
          fontSize: 12,
          fontWeight: FontWeight.w700,
          color: Colors.black54,
        ),
      ),
    );
  }
}
