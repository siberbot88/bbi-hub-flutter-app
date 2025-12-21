import 'dart:async';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../widgets/custom_header.dart';
import '../widgets/invoice/payment_invoice_card.dart';
import '../providers/admin_service_provider.dart';
import 'package:bengkel_online_flutter/core/models/service.dart';

class PaymentInvoicePage extends StatefulWidget {
  final ServiceModel service;
  final String transactionId;
  final List<Map<String, dynamic>> items;
  final int totalAmount;
  final int? subtotal;
  final int? discountAmount;
  final String? voucherCode;
  final String? notes;

  const PaymentInvoicePage({
    super.key,
    required this.service,
    required this.transactionId,
    required this.items,
    required this.totalAmount,
    this.subtotal,
    this.discountAmount,
    this.voucherCode,
    this.notes,
  });

  @override
  State<PaymentInvoicePage> createState() => _PaymentInvoicePageState();
}

class _PaymentInvoicePageState extends State<PaymentInvoicePage> {
  // Status states
  bool _isInvoiceSent = false;      // Invoice sudah dikirim
  bool _isWaitingPayment = false;   // Menunggu pembayaran
  bool _isPaid = false;             // Lunas
  bool _isLoading = false;
  
  String? _invoiceCode;
  String? _selectedPaymentMethod;
  
  // Discount from user payment (when user applies voucher)
  int _userDiscountAmount = 0;
  String? _userVoucherCode;
  
  // Countdown timer
  Timer? _countdownTimer;
  int _remainingSeconds = 3600; // 1 hour default
  
  @override
  void dispose() {
    _countdownTimer?.cancel();
    super.dispose();
  }
  
  void _startCountdown() {
    _countdownTimer?.cancel();
    _remainingSeconds = 3600; // Reset to 1 hour
    _countdownTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_remainingSeconds > 0 && !_isPaid) {
        setState(() => _remainingSeconds--);
      } else {
        timer.cancel();
      }
    });
  }
  
  String _formatCountdown() {
    final hours = _remainingSeconds ~/ 3600;
    final minutes = (_remainingSeconds % 3600) ~/ 60;
    final seconds = _remainingSeconds % 60;
    return '${hours.toString().padLeft(2, '0')} : ${minutes.toString().padLeft(2, '0')} : ${seconds.toString().padLeft(2, '0')}';
  }

  final List<String> _paymentMethods = ['Cash', 'Transfer Bank', 'QRIS', 'Kartu Debit/Kredit'];

  /// Cek apakah service ini tipe on-site (walk-in)
  bool get _isOnSiteService {
    final type = widget.service.type?.toLowerCase() ?? '';
    return type == 'on-site' || type == 'onsite' || type == 'walk-in' || type == 'walkin';
  }

  /// Kirim Invoice - Status berubah ke "Menunggu Pembayaran"
  /// Also applies voucher to transaction if one was selected
  Future<void> _sendInvoice() async {
    setState(() => _isLoading = true);
    
    try {
      final provider = context.read<AdminServiceProvider>();
      
      // Apply voucher if one was selected
      if (widget.voucherCode != null && widget.voucherCode!.isNotEmpty) {
        await provider.applyVoucher(
          transactionId: widget.transactionId,
          voucherCode: widget.voucherCode!,
        );
      }
      
      // Simulate invoice creation (TODO: integrate with real API)
      await Future.delayed(const Duration(milliseconds: 500));
      
      if (mounted) {
        setState(() {
          _isLoading = false;
          _isInvoiceSent = true;
          _isWaitingPayment = true;
          _invoiceCode = 'INV-${DateTime.now().millisecondsSinceEpoch.toString().substring(5)}';
        });
        
        // Start payment countdown timer
        _startCountdown();
        if (_isOnSiteService) {
          _showCustomSnackbar('Invoice berhasil dibuat. Silakan terima pembayaran.');
        } else {
          _showCustomSnackbar('Invoice berhasil dikirim ke pelanggan.');
        }
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
        _showCustomSnackbar('Gagal membuat invoice: $e', isError: true);
      }
    }
  }

  /// DUMMY: Tandai Lunas (hanya untuk ON-SITE) - Status berubah ke "Lunas"
  void _markAsPaid() async {
    // Show payment method dialog first
    final method = await showDialog<String>(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text('Pilih Metode Pembayaran', style: GoogleFonts.poppins(fontWeight: FontWeight.bold)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: _paymentMethods.map((method) => 
            ListTile(
              leading: Icon(_getPaymentIcon(method), color: const Color(0xFFB31217)),
              title: Text(method, style: GoogleFonts.poppins()),
              onTap: () => Navigator.pop(context, method),
            ),
          ).toList(),
        ),
      ),
    );

    if (method == null) return;

    setState(() => _isLoading = true);

    try {
      // Call API to update service status to 'lunas'
      final provider = context.read<AdminServiceProvider>();
      await provider.updateServiceStatusAsAdmin(widget.service.id, 'lunas');
      
      if (mounted) {
        setState(() {
          _isLoading = false;
          _isPaid = true;
          _isWaitingPayment = false;
          _selectedPaymentMethod = method;
        });

        _showCustomSnackbar('Pembayaran berhasil dicatat via $method');
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
        _showCustomSnackbar('Gagal update status: $e');
      }
    }
  }

  /// Simulasi pembayaran dari user (untuk testing booking flow)
  /// Opens a dialog that simulates the user app payment experience
  void _showUserPaymentDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => _UserPaymentSimulationDialog(
        transactionId: widget.transactionId,
        totalAmount: widget.totalAmount,
        serviceId: widget.service.id,
        onPaymentComplete: (paymentMethod, voucherCode, discountAmount) {
          Navigator.pop(context); // Close dialog
          setState(() {
            _isPaid = true;
            _isWaitingPayment = false;
            _selectedPaymentMethod = '$paymentMethod (User)';
            _userDiscountAmount = discountAmount;
            _userVoucherCode = voucherCode;
          });
          _showCustomSnackbar('Pembayaran dari customer berhasil diterima!');
        },
      ),
    );
  }

  IconData _getPaymentIcon(String method) {
    switch (method) {
      case 'Cash': return Icons.payments_outlined;
      case 'Transfer Bank': return Icons.account_balance_outlined;
      case 'QRIS': return Icons.qr_code_2;
      case 'Kartu Debit/Kredit': return Icons.credit_card;
      default: return Icons.payment;
    }
  }

  void _showCustomSnackbar(String message, {bool isError = false}) {
    ScaffoldMessenger.of(context).hideCurrentSnackBar();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        behavior: SnackBarBehavior.floating,
        margin: const EdgeInsets.only(left: 16, right: 16, bottom: 16),
        elevation: 0,
        backgroundColor: Colors.transparent,
        duration: const Duration(seconds: 2),
        content: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          decoration: BoxDecoration(
            color: isError ? Colors.red[50] : Colors.white,
            borderRadius: BorderRadius.circular(24),
            border: isError ? Border.all(color: Colors.red.shade300) : null,
            boxShadow: [
              BoxShadow(
                color: Colors.black.withAlpha(26),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Row(
            children: [
              Icon(
                isError ? Icons.error_outline : (_isPaid ? Icons.check_circle : Icons.send),
                color: isError ? Colors.red : (_isPaid ? Colors.green : const Color(0xFFB31217)),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  message,
                  style: GoogleFonts.poppins(
                    color: isError ? Colors.red[800] : Colors.black87,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _formatCurrency(int amount) {
    final formatter = NumberFormat('#,###', 'id_ID');
    return 'Rp ${formatter.format(amount)}';
  }

  String _formatCurrencyShort(int amount) {
    if (amount >= 1000000) {
      return 'IDR. ${(amount / 1000000).toStringAsFixed(1)}M';
    } else if (amount >= 1000) {
      return 'IDR. ${(amount / 1000).toStringAsFixed(0)}K';
    }
    return 'IDR. $amount';
  }

  void _handleButtonPress() {
    if (_isLoading) return;
    
    if (!_isInvoiceSent) {
      _sendInvoice();
    } else if (_isWaitingPayment && !_isPaid && _isOnSiteService) {
      // Hanya on-site yang bisa manual tandai lunas
      _markAsPaid();
    }
  }

  @override
  Widget build(BuildContext context) {
    final customerName = widget.service.displayCustomerName;
    final vehicleName = widget.service.displayVehicleName;
    final plate = widget.service.displayVehiclePlate;
    final phone = widget.service.customer?.phoneNumber ?? '-';
    final address = widget.service.customer?.address ?? '-';
    final invoiceDate = DateFormat('MMM d, yyyy').format(DateTime.now()).toUpperCase();

    // Convert items to the format expected by PaymentInvoiceCard
    final serviceItems = widget.items.map((item) => {
      'name': (item['nama'] ?? '-').toString(),
      'price': _formatCurrency(item['harga'] ?? 0),
    }).toList();

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
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
            child: Column(
              children: [
                // Service type badge
                Container(
                  margin: const EdgeInsets.only(bottom: 12),
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  decoration: BoxDecoration(
                    color: _isOnSiteService ? Colors.orange : Colors.blue,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        _isOnSiteService ? Icons.store : Icons.calendar_month,
                        color: Colors.white,
                        size: 18,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        _isOnSiteService ? 'ON-SITE SERVICE' : 'BOOKING SERVICE',
                        style: GoogleFonts.poppins(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ),

                // Invoice Card with real data
                // Show discounted amount if user applied voucher during payment
                PaymentInvoiceCard(
                  vehicleName: vehicleName.toUpperCase(),
                  invoiceNumber: _invoiceCode ?? 'Menunggu...',
                  licensePlate: plate,
                  phoneNumber: phone,
                  serviceItems: serviceItems,
                  totalAmount: _formatCurrency(_isPaid && _userDiscountAmount > 0 
                      ? widget.totalAmount - _userDiscountAmount 
                      : widget.totalAmount),
                  notes: widget.notes ?? 'Tidak ada catatan',
                  customerName: customerName,
                  customerAddress: address,
                  totalTagihan: _formatCurrencyShort(_isPaid && _userDiscountAmount > 0 
                      ? widget.totalAmount - _userDiscountAmount 
                      : widget.totalAmount),
                  invoiceDate: invoiceDate,
                  isSent: _isPaid,
                  onSend: _handleButtonPress,
                  // Show voucher info if applied
                  voucherCode: _isPaid ? _userVoucherCode : null,
                  discountAmount: _isPaid && _userDiscountAmount > 0 ? _formatCurrency(_userDiscountAmount) : null,
                  // Show countdown timer when waiting for payment
                  paymentDuration: _isWaitingPayment && !_isPaid ? _formatCountdown() : null,
                ),
                
                const SizedBox(height: 24),
                
                // Loading indicator
                if (_isLoading)
                  const Center(
                    child: CircularProgressIndicator(color: Colors.white),
                  ),
                
                // ========== ON-SITE FLOW ==========
                if (_isOnSiteService && _isWaitingPayment && !_isPaid)
                  _buildOnSiteWaitingCard(),
                
                // ========== BOOKING FLOW ==========
                if (!_isOnSiteService && _isWaitingPayment && !_isPaid)
                  _buildBookingWaitingCard(),
                
                // ========== LUNAS STATE (both flows) ==========
                if (_isPaid)
                  _buildPaidCard(),
                
                // Tombol kembali setelah lunas
                if (_isPaid) ...[
                  const SizedBox(height: 16),
                  SizedBox(
                    width: double.infinity,
                    height: 52,
                    child: ElevatedButton.icon(
                      onPressed: () => Navigator.of(context).popUntil((route) => route.isFirst),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(26),
                        ),
                        elevation: 4,
                      ),
                      icon: const Icon(Icons.arrow_back, color: Color(0xFFB31217)),
                      label: Text(
                        'Kembali ke Daftar Servis',
                        style: GoogleFonts.poppins(
                          fontSize: 15,
                          fontWeight: FontWeight.w600,
                          color: const Color(0xFFB31217),
                        ),
                      ),
                    ),
                  ),
                ],
                
                const SizedBox(height: 32),
              ],
            ),
          ),
        ),
      ),
    );
  }

  /// Card untuk ON-SITE: Admin bisa tandai lunas
  Widget _buildOnSiteWaitingCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
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
          Icon(Icons.point_of_sale, size: 48, color: Colors.orange[700]),
          const SizedBox(height: 12),
          Text(
            'Terima Pembayaran',
            style: GoogleFonts.poppins(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.orange[700],
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Customer membayar di tempat.\nTerima pembayaran lalu tekan tombol di bawah.',
            textAlign: TextAlign.center,
            style: GoogleFonts.poppins(
              fontSize: 13,
              color: Colors.grey[600],
            ),
          ),
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            height: 48,
            child: ElevatedButton.icon(
              onPressed: _isLoading ? null : _markAsPaid,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(24),
                ),
              ),
              icon: const Icon(Icons.check_circle, color: Colors.white),
              label: Text(
                'Tandai Lunas',
                style: GoogleFonts.poppins(
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                  color: Colors.white,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// Card untuk BOOKING: Menunggu pembayaran dari user
  Widget _buildBookingWaitingCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
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
          // Animated waiting icon
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.blue.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(Icons.hourglass_top, size: 48, color: Colors.blue[700]),
          ),
          const SizedBox(height: 12),
          Text(
            'Menunggu Pembayaran User',
            style: GoogleFonts.poppins(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.blue[700],
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Invoice sudah dikirim ke aplikasi customer.\nStatus akan otomatis update setelah customer membayar.',
            textAlign: TextAlign.center,
            style: GoogleFonts.poppins(
              fontSize: 13,
              color: Colors.grey[600],
            ),
          ),
          const SizedBox(height: 16),
          
          // Info box
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.blue.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.blue.withOpacity(0.3)),
            ),
            child: Row(
              children: [
                Icon(Icons.info_outline, color: Colors.blue[700], size: 20),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    'Anda akan menerima notifikasi saat pembayaran selesai.',
                    style: GoogleFonts.poppins(
                      fontSize: 12,
                      color: Colors.blue[700],
                    ),
                  ),
                ),
              ],
            ),
          ),
          
          const SizedBox(height: 16),
          
          // Tombol simulasi (untuk testing - bisa dihapus nanti)
          SizedBox(
            width: double.infinity,
            height: 40,
            child: OutlinedButton.icon(
              onPressed: _isLoading ? null : _showUserPaymentDialog,
              style: OutlinedButton.styleFrom(
                side: BorderSide(color: Colors.blue[700]!),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                ),
              ),
              icon: Icon(Icons.bug_report, color: Colors.blue[700], size: 18),
              label: Text(
                'Simulasi Pembayaran User (Test)',
                style: GoogleFonts.poppins(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: Colors.blue[700],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// Card setelah LUNAS
  Widget _buildPaidCard() {
    return Container(
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
            'Pembayaran via $_selectedPaymentMethod',
            style: GoogleFonts.poppins(
              fontSize: 14,
              color: Colors.grey[600],
            ),
          ),
          const SizedBox(height: 4),
          Text(
            _isOnSiteService ? 'Transaksi on-site selesai!' : 'Booking berhasil dibayar!',
            style: GoogleFonts.poppins(
              fontSize: 13,
              color: Colors.grey[500],
            ),
          ),
        ],
      ),
    );
  }
}

/// Dialog yang simulasi POV user untuk pembayaran
/// User bisa input voucher dan pilih metode pembayaran
class _UserPaymentSimulationDialog extends StatefulWidget {
  final String transactionId;
  final int totalAmount;
  final String serviceId;
  final void Function(String paymentMethod, String? voucherCode, int discountAmount) onPaymentComplete;

  const _UserPaymentSimulationDialog({
    required this.transactionId,
    required this.totalAmount,
    required this.serviceId,
    required this.onPaymentComplete,
  });

  @override
  State<_UserPaymentSimulationDialog> createState() => _UserPaymentSimulationDialogState();
}

class _UserPaymentSimulationDialogState extends State<_UserPaymentSimulationDialog> {
  final TextEditingController _voucherController = TextEditingController();
  
  bool _isValidatingVoucher = false;
  bool _isProcessingPayment = false;
  bool _voucherApplied = false;
  
  String? _voucherCode;
  num _discountAmount = 0;
  String? _voucherError;
  String? _selectedPaymentMethod;

  final List<String> _paymentMethods = ['Transfer Bank', 'QRIS', 'Kartu Debit/Kredit', 'E-Wallet'];

  int get _finalAmount => (widget.totalAmount - _discountAmount).toInt();

  String _formatCurrency(int amount) {
    final formatter = NumberFormat('#,###', 'id_ID');
    return 'Rp ${formatter.format(amount)}';
  }

  Future<void> _validateVoucher() async {
    final code = _voucherController.text.trim();
    if (code.isEmpty) return;

    setState(() {
      _isValidatingVoucher = true;
      _voucherError = null;
    });

    try {
      final provider = context.read<AdminServiceProvider>();
      final result = await provider.validateVoucher(
        code: code,
        amount: widget.totalAmount,
      );

      if (mounted) {
        setState(() {
          _isValidatingVoucher = false;
          if (result['valid'] == true) {
            _voucherApplied = true;
            _voucherCode = code;
            // Safely parse discount_amount (may come as String or num)
            final discountRaw = result['discount_amount'];
            _discountAmount = discountRaw is num 
                ? discountRaw 
                : num.tryParse(discountRaw?.toString() ?? '0') ?? 0;
            _voucherError = null;
          } else {
            _voucherApplied = false;
            _voucherCode = null;
            _discountAmount = 0;
            _voucherError = result['message']?.toString() ?? 'Voucher tidak valid';
          }
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isValidatingVoucher = false;
          _voucherApplied = false;
          _voucherError = e.toString().replaceFirst('Exception: ', '');
        });
      }
    }
  }

  void _removeVoucher() {
    setState(() {
      _voucherApplied = false;
      _voucherCode = null;
      _discountAmount = 0;
      _voucherError = null;
      _voucherController.clear();
    });
  }

  Future<void> _processPayment() async {
    if (_selectedPaymentMethod == null) {
      setState(() {
        _voucherError = 'Pilih metode pembayaran terlebih dahulu';
      });
      return;
    }

    setState(() => _isProcessingPayment = true);

    try {
      final provider = context.read<AdminServiceProvider>();
      
      // Apply voucher if one was selected
      if (_voucherCode != null && _voucherCode!.isNotEmpty) {
        await provider.applyVoucher(
          transactionId: widget.transactionId,
          voucherCode: _voucherCode!,
        );
      }
      
      // Update service status to lunas
      await provider.updateServiceStatusAsAdmin(widget.serviceId, 'lunas');
      
      if (mounted) {
        widget.onPaymentComplete(_selectedPaymentMethod!, _voucherCode, _discountAmount.toInt());
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isProcessingPayment = false;
          _voucherError = 'Gagal memproses pembayaran: $e';
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: Container(
        padding: const EdgeInsets.all(20),
        constraints: const BoxConstraints(maxWidth: 400),
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: Colors.blue.withOpacity(0.1),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(Icons.phone_android, color: Colors.blue[700], size: 24),
                  ),
                  const SizedBox(width: 12),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('POV Aplikasi User',
                          style: GoogleFonts.poppins(fontSize: 16, fontWeight: FontWeight.bold)),
                      Text('Simulasi pembayaran customer',
                          style: GoogleFonts.poppins(fontSize: 12, color: Colors.grey[600])),
                    ],
                  ),
                  const Spacer(),
                  IconButton(
                    onPressed: () => Navigator.pop(context),
                    icon: const Icon(Icons.close),
                  ),
                ],
              ),
              
              const Divider(height: 24),
              
              // Order Summary
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.grey[100],
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text('Subtotal', style: GoogleFonts.poppins(fontSize: 14)),
                        Text(_formatCurrency(widget.totalAmount), 
                            style: GoogleFonts.poppins(fontSize: 14)),
                      ],
                    ),
                    if (_voucherApplied && _discountAmount > 0) ...[
                      const SizedBox(height: 8),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Row(
                            children: [
                              Icon(Icons.local_offer, size: 16, color: Colors.green[700]),
                              const SizedBox(width: 4),
                              Text('Diskon ($_voucherCode)', 
                                  style: GoogleFonts.poppins(fontSize: 14, color: Colors.green[700])),
                            ],
                          ),
                          Text('- ${_formatCurrency(_discountAmount.toInt())}', 
                              style: GoogleFonts.poppins(fontSize: 14, color: Colors.green[700], fontWeight: FontWeight.w600)),
                        ],
                      ),
                    ],
                    const Divider(height: 16),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text('Total Bayar', style: GoogleFonts.poppins(fontSize: 16, fontWeight: FontWeight.bold)),
                        Text(_formatCurrency(_finalAmount), 
                            style: GoogleFonts.poppins(fontSize: 16, fontWeight: FontWeight.bold, color: const Color(0xFFB31217))),
                      ],
                    ),
                  ],
                ),
              ),
              
              const SizedBox(height: 16),
              
              // Voucher Input
              Text('Kode Voucher', style: GoogleFonts.poppins(fontSize: 14, fontWeight: FontWeight.w600)),
              const SizedBox(height: 8),
              Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _voucherController,
                      enabled: !_voucherApplied,
                      decoration: InputDecoration(
                        hintText: 'Masukkan kode voucher',
                        hintStyle: GoogleFonts.poppins(fontSize: 13),
                        contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                          borderSide: BorderSide(color: Colors.grey.shade400),
                        ),
                        filled: _voucherApplied,
                        fillColor: _voucherApplied ? Colors.green.withOpacity(0.1) : null,
                        suffixIcon: _voucherApplied
                            ? const Icon(Icons.check_circle, color: Colors.green)
                            : null,
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  _voucherApplied
                      ? IconButton(
                          onPressed: _removeVoucher,
                          icon: const Icon(Icons.close, color: Colors.red),
                          style: IconButton.styleFrom(
                            backgroundColor: Colors.red.withOpacity(0.1),
                          ),
                        )
                      : ElevatedButton(
                          onPressed: _isValidatingVoucher ? null : _validateVoucher,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.blue[700],
                            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                          ),
                          child: _isValidatingVoucher
                              ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                              : Text('Apply', style: GoogleFonts.poppins(color: Colors.white, fontWeight: FontWeight.w600)),
                        ),
                ],
              ),
              if (_voucherError != null)
                Padding(
                  padding: const EdgeInsets.only(top: 6),
                  child: Text(_voucherError!, style: GoogleFonts.poppins(fontSize: 12, color: Colors.red)),
                ),
              if (_voucherApplied)
                Padding(
                  padding: const EdgeInsets.only(top: 6),
                  child: Text('Voucher berhasil diterapkan!', style: GoogleFonts.poppins(fontSize: 12, color: Colors.green, fontWeight: FontWeight.w500)),
                ),
              
              const SizedBox(height: 16),
              
              // Payment Method
              Text('Metode Pembayaran', style: GoogleFonts.poppins(fontSize: 14, fontWeight: FontWeight.w600)),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: _paymentMethods.map((method) {
                  final isSelected = _selectedPaymentMethod == method;
                  return GestureDetector(
                    onTap: () => setState(() => _selectedPaymentMethod = method),
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                      decoration: BoxDecoration(
                        color: isSelected ? Colors.blue[700] : Colors.white,
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                          color: isSelected ? Colors.blue[700]! : Colors.grey.shade400,
                        ),
                      ),
                      child: Text(
                        method,
                        style: GoogleFonts.poppins(
                          fontSize: 13,
                          fontWeight: FontWeight.w500,
                          color: isSelected ? Colors.white : Colors.grey[800],
                        ),
                      ),
                    ),
                  );
                }).toList(),
              ),
              
              const SizedBox(height: 24),
              
              // Pay Button
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton.icon(
                  onPressed: _isProcessingPayment || _selectedPaymentMethod == null ? null : _processPayment,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(25)),
                    disabledBackgroundColor: Colors.grey[300],
                  ),
                  icon: _isProcessingPayment
                      ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                      : const Icon(Icons.payment, color: Colors.white),
                  label: Text(
                    _isProcessingPayment ? 'Memproses...' : 'Bayar Sekarang',
                    style: GoogleFonts.poppins(fontSize: 16, fontWeight: FontWeight.w600, color: Colors.white),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}