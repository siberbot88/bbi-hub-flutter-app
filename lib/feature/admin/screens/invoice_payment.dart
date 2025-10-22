import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../widgets/custom_header.dart';

class PaymentInvoicePage extends StatefulWidget {
  const PaymentInvoicePage({super.key});
  @override
  State<PaymentInvoicePage> createState() => _PaymentInvoicePageState();
}

class _PaymentInvoicePageState extends State<PaymentInvoicePage> {
  bool _sent = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // ✅ Pakai header di slot appBar supaya header merah tampak
      appBar: const CustomHeader(
        title: 'Nota Pembayaran',
        showBack: true,
      ),
      backgroundColor: const Color(0xFFB31217),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.only(bottom: 16),
          child: Column(
            children: [
              // ====== KARTU INVOICE ======
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(18),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.09),
                        blurRadius: 14,
                        offset: const Offset(0, 6),
                      ),
                    ],
                  ),
                  child: Stack(
                    children: [
                      // HEADER MERAH
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
                                    color: Colors.white.withOpacity(0.15),
                                    borderRadius: BorderRadius.circular(18),
                                  ),
                                  child: Text('● Invoice',
                                      style: GoogleFonts.poppins(
                                          color: Colors.white,
                                          fontWeight: FontWeight.w600,
                                          fontSize: 12)),
                                ),
                                const Spacer(),
                                Container(
                                  padding: const EdgeInsets.all(8),
                                  decoration: BoxDecoration(
                                    color: Colors.white.withOpacity(0.18),
                                    shape: BoxShape.circle,
                                  ),
                                  child: const Icon(Icons.edit,
                                      size: 16, color: Colors.white),
                                ),
                              ],
                            ),
                            const SizedBox(height: 10),
                            Text('BEAT 2012',
                                style: GoogleFonts.poppins(
                                  color: Colors.white,
                                  fontSize: 28,
                                  fontWeight: FontWeight.w800,
                                )),
                            const SizedBox(height: 6),
                            Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Expanded(
                                  child: Text('PR26051420004799',
                                      style: GoogleFonts.poppins(
                                        color: Colors.white.withOpacity(0.9),
                                        fontSize: 13,
                                      )),
                                ),
                                Expanded(
                                  child: Text('LP: SU814NTO\n08956733xxx',
                                      textAlign: TextAlign.right,
                                      style: GoogleFonts.poppins(
                                        color: Colors.white.withOpacity(0.9),
                                        fontSize: 13,
                                        height: 1.35,
                                      )),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),

                      // BADGE PUTIH (INVOICE FOR + Total Tagihan overlay)
                      _invoicePill(),

                      // KONTEN
                      Padding(
                        padding:
                            const EdgeInsets.fromLTRB(16, 180 + 64, 16, 18),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Expanded(
                                  child: Text('Daftar Perbaikan',
                                      style: GoogleFonts.poppins(
                                          fontSize: 13,
                                          fontWeight: FontWeight.w600)),
                                ),
                                Text('TOTAL',
                                    style: GoogleFonts.poppins(
                                        fontSize: 12.5,
                                        color: Colors.grey[700],
                                        fontWeight: FontWeight.w600)),
                              ],
                            ),
                            const SizedBox(height: 10),
                            _rowItem('Servis besar', '450000'),
                            _rowItem('Ganti kampas rem', '250000'),
                            _rowItem('Ganti Ban belakang', '380000'),
                            const SizedBox(height: 12),
                            Divider(color: Colors.grey.shade300, height: 28),

                            Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text('Catatan',
                                          style: GoogleFonts.poppins(
                                              fontSize: 13,
                                              fontWeight: FontWeight.w600)),
                                      const SizedBox(height: 6),
                                      Text(
                                        'Perlu perawatan dan pengecheckan rutinan\nsetiap 3 bulan sekali kedepannya',
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
                                    Text('TOTAL AMOUNT',
                                        style: GoogleFonts.poppins(
                                          fontSize: 11.5,
                                          color: Colors.grey[700],
                                          fontWeight: FontWeight.w600,
                                        )),
                                    const SizedBox(height: 4),
                                    Text('IDR.1,080K',
                                        style: GoogleFonts.poppins(
                                          fontSize: 15.5,
                                          fontWeight: FontWeight.w800,
                                        )),
                                  ],
                                ),
                              ],
                            ),

                            const SizedBox(height: 16),

                            // STATUS & DURASI
                            Row(
                              children: [
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text('Status pembayaran',
                                          style: GoogleFonts.poppins(
                                            fontSize: 12,
                                            color: Colors.grey[700],
                                            fontWeight: FontWeight.w600,
                                          )),
                                      const SizedBox(height: 6),
                                      _statusBadge(), // <-- berubah sesuai _sent
                                    ],
                                  ),
                                ),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.end,
                                    children: [
                                      Text('Durasi Pembayaran',
                                          style: GoogleFonts.poppins(
                                            fontSize: 12,
                                            color: Colors.grey[700],
                                            fontWeight: FontWeight.w600,
                                          )),
                                      const SizedBox(height: 6),
                                      Text('01 : 00 : 59',
                                          style: GoogleFonts.poppins(
                                            fontSize: 14,
                                            fontWeight: FontWeight.w700,
                                          )),
                                    ],
                                  ),
                                ),
                              ],
                            ),

                            const SizedBox(height: 22),

                            // TOMBOL KIRIM INVOICE
                            SizedBox(
                              width: double.infinity,
                              height: 48,
                              child: ElevatedButton(
                                onPressed: _sent ? null : _sendInvoice,
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: const Color(0xFFB31217),
                                  disabledBackgroundColor:
                                      const Color(0xFFB31217).withOpacity(.5),
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
                ),
              ),

              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }

  // ---------- UI helper ----------
  Widget _rowItem(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        children: [
          Expanded(
            child: Text(label,
                style: GoogleFonts.poppins(
                    fontSize: 13.5, fontWeight: FontWeight.w700)),
          ),
          Text(value,
              style: GoogleFonts.poppins(
                  fontSize: 13.5, fontWeight: FontWeight.w600)),
        ],
      ),
    );
  }

  // ✅ Badge status berubah sesuai _sent
  Widget _statusBadge() {
    if (_sent) {
      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
        decoration: BoxDecoration(
          color: const Color(0xFFDFF2E0),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Text('Berhasil',
            style: GoogleFonts.poppins(
                fontSize: 12,
                fontWeight: FontWeight.w700,
                color: const Color(0xFF2E7D32))),
      );
    }
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
      decoration: BoxDecoration(
        color: Colors.grey.shade300,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text('PENDING',
          style: GoogleFonts.poppins(
              fontSize: 12,
              fontWeight: FontWeight.w700,
              color: Colors.black54)),
    );
  }

  Widget _invoicePill() {
    const double chargeW = 140;
    const double chargeH = 84;

    return Positioned(
      left: 16,
      right: 16,
      top: 140,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          // === BASE PILL PUTIH ===
          Container(
            // pastikan setidaknya setinggi kartu kecil + padding vertikal
            constraints: BoxConstraints(minHeight: chargeH + 16),
            // sisakan ruang kanan sebesar lebar kartu kecil agar teks tidak ketutup
            padding: EdgeInsets.fromLTRB(16, 16, chargeW + 24, 16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(22),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.08),
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
                Text('Prabowo',
                    style: GoogleFonts.poppins(
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                    )),
                const SizedBox(height: 2),
                Text(
                  'Jl. Krestal No.32 Torjun, Sampang\nJawa Timur',
                  style: GoogleFonts.poppins(
                    fontSize: 12.5,
                    color: Colors.black87,
                    height: 1.35,
                  ),
                ),
              ],
            ),
          ),

          // === KARTU KECIL "TOTAL TAGIHAN" (mengambang, centerRight) ===
          Align(
            alignment: Alignment.centerRight,
            child: Container(
              width: chargeW,
              height: chargeH, // tinggi tetap → tidak bakal overflow
              margin: const EdgeInsets.only(right: 8), // jarak dari tepi kanan
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(18),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.10),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Total Tagihan',
                      style: GoogleFonts.poppins(
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                        color: Colors.grey[700],
                      )),
                  const SizedBox(height: 4),
                  Text('IDR. 1,080K',
                      style: GoogleFonts.poppins(
                        fontSize: 18,
                        fontWeight: FontWeight.w800,
                      )),
                  const SizedBox(height: 6),
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: const Color(0xFFF6E7E7),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Text(
                      '● SEP 2, 2026',
                      style: GoogleFonts.poppins(
                        fontSize: 10.5,
                        color: const Color(0xFFB31217),
                        fontWeight: FontWeight.w600,
                      ),
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

  // ---------- action kirim invoice ----------
  void _sendInvoice() {
    setState(() => _sent = true);

    final messenger = ScaffoldMessenger.of(context);
    messenger.hideCurrentSnackBar();

    messenger.showSnackBar(
      SnackBar(
        behavior: SnackBarBehavior.floating,
        margin: const EdgeInsets.only(left: 16, right: 16, top: 12),
        elevation: 0,
        backgroundColor: Colors.transparent, // biar kontainer custom terlihat
        duration: const Duration(seconds: 2),
        // bentuk pill putih seperti contoh
        content: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(24),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.10),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Center(
            child: Text(
              'Invoice berhasil dikirimkan',
              style: GoogleFonts.poppins(
                color: Colors.black87,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ),
      ),
    );
  }
}