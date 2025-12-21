import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../widgets/custom_header.dart';
import '../widgets/invoice/invoice_customer_header.dart';
import '../widgets/invoice/invoice_service_info.dart';
import '../widgets/invoice/invoice_service_list.dart';
import '../providers/admin_service_provider.dart';
import 'package:bengkel_online_flutter/core/models/service.dart';
import 'invoice_payment.dart';

class InvoiceFormPage extends StatefulWidget {
  final ServiceModel service;

  const InvoiceFormPage({super.key, required this.service});

  @override
  State<InvoiceFormPage> createState() => _InvoiceFormPageState();
}

class _InvoiceFormPageState extends State<InvoiceFormPage> {
  final Color mainColor = const Color(0xFFDC2626);
  final TextEditingController technicianNoteController = TextEditingController();
  final TextEditingController voucherController = TextEditingController();
  
  bool _isLoading = false;
  bool _isValidatingVoucher = false;
  String? _transactionId;
  
  // Voucher state
  bool _voucherApplied = false;
  String? _voucherCode;
  num _discountAmount = 0;
  String? _voucherError;

  // Service items that can be edited
  late List<Map<String, dynamic>> serviceList;

  final List<String> jenisOptions = [
    "Servis Ringan",
    "Servis Sedang",
    "Servis Berat",
    "Sparepart",
    "Biaya Tambahan",
    "Lainnya"
  ];

  @override
  void initState() {
    super.initState();
    // Initialize with service items if available, otherwise default
    if (widget.service.items != null && widget.service.items!.isNotEmpty) {
      serviceList = widget.service.items!.map((item) => {
        "nama": item.name ?? "",
        "jenis": _mapItemType(item.serviceTypeName),
        "harga": (item.price).toInt(),
      }).toList();
    } else {
      serviceList = [
        {"nama": widget.service.name, "jenis": "Servis Ringan", "harga": (widget.service.price ?? 0).toInt()},
      ];
    }
  }

  String _mapItemType(String? type) {
    switch (type?.toLowerCase()) {
      case 'servis ringan': return 'Servis Ringan';
      case 'servis sedang': return 'Servis Sedang';
      case 'servis berat': return 'Servis Berat';
      case 'sparepart': return 'Sparepart';
      case 'biaya tambahan': return 'Biaya Tambahan';
      default: return 'Lainnya';
    }
  }

  String _reverseMapItemType(String jenis) {
    switch (jenis) {
      case 'Servis Ringan': return 'servis ringan';
      case 'Servis Sedang': return 'servis sedang';
      case 'Servis Berat': return 'servis berat';
      case 'Sparepart': return 'sparepart';
      case 'Biaya Tambahan': return 'biaya tambahan';
      default: return 'lainnya';
    }
  }

  void _addService() {
    setState(() {
      serviceList.add({"nama": "", "jenis": "Servis Ringan", "harga": 0});
    });
  }

  void _editService(int index) {
    final namaController = TextEditingController(text: serviceList[index]["nama"]);
    final hargaController = TextEditingController(text: serviceList[index]["harga"].toString());
    String selectedJenis = serviceList[index]["jenis"];

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text("Edit Servis", style: GoogleFonts.poppins(fontWeight: FontWeight.bold)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: namaController,
              decoration: const InputDecoration(labelText: "Nama Servis"),
            ),
            const SizedBox(height: 8),
            DropdownButtonFormField<String>(
              value: selectedJenis,
              decoration: const InputDecoration(labelText: "Jenis Servis"),
              items: jenisOptions.map((e) => DropdownMenuItem(value: e, child: Text(e))).toList(),
              onChanged: (value) => selectedJenis = value!,
            ),
            const SizedBox(height: 8),
            TextField(
              controller: hargaController,
              decoration: const InputDecoration(labelText: "Harga Servis"),
              keyboardType: TextInputType.number,
            ),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text("Batal")),
          TextButton(
            onPressed: () {
              setState(() {
                serviceList[index]["nama"] = namaController.text;
                serviceList[index]["jenis"] = selectedJenis;
                serviceList[index]["harga"] = int.tryParse(hargaController.text) ?? 0;
              });
              Navigator.pop(context);
            },
            child: const Text("Simpan"),
          ),
        ],
      ),
    );
  }

  void _deleteService(int index) {
    setState(() => serviceList.removeAt(index));
  }

  void _onJenisChanged(int index, String value) {
    setState(() {
      serviceList[index]['jenis'] = value;
    });
  }

  int get _subtotal {
    return serviceList.fold(0, (sum, item) => sum + ((item['harga'] as int?) ?? 0));
  }

  int get _totalAmount {
    return (_subtotal - _discountAmount).toInt();
  }

  Future<void> _validateVoucher() async {
    final code = voucherController.text.trim();
    if (code.isEmpty) return;

    setState(() {
      _isValidatingVoucher = true;
      _voucherError = null;
    });

    try {
      final provider = context.read<AdminServiceProvider>();
      final result = await provider.validateVoucher(
        code: code,
        amount: _subtotal,
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
      voucherController.clear();
    });
  }

  Future<void> _createTransactionAndContinue() async {
    setState(() => _isLoading = true);

    try {
      final provider = context.read<AdminServiceProvider>();
      
      // Check if transaction already exists (backend creates it when service marked complete)
      String? txnId = widget.service.transactionUuid;
      
      if (txnId == null || txnId.isEmpty) {
        // Fallback: Create transaction if not exists
        print('DEBUG: No transactionUuid found, creating new transaction...');
        final transactionData = await provider.createTransaction(
          serviceUuid: widget.service.id,
          notes: technicianNoteController.text,
        );
        txnId = transactionData['id']?.toString();
      } else {
        print('DEBUG: Using existing transactionUuid: $txnId');
      }
      
      _transactionId = txnId;
      
      if (_transactionId == null) {
        throw Exception('Transaction ID not available');
      }

      // Add each item separately via transaction-items endpoint
      for (final item in serviceList) {
        await provider.addTransactionItem(
          transactionUuid: _transactionId!,
          name: item['nama'] ?? '',
          serviceType: _reverseMapItemType(item['jenis'] ?? 'Jasa Pekerjaan'),
          price: item['harga'] ?? 0,
          quantity: 1,
        );
      }

      if (mounted && _transactionId != null) {
        // Navigate to payment page with transaction data
        Navigator.of(context).push(
          MaterialPageRoute(
            builder: (context) => PaymentInvoicePage(
              service: widget.service,
              transactionId: _transactionId!,
              items: serviceList,
              totalAmount: _totalAmount,
              subtotal: _subtotal,
              discountAmount: _discountAmount.toInt(),
              voucherCode: _voucherCode,
              notes: technicianNoteController.text,
            ),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Gagal membuat transaksi: $e'), backgroundColor: Colors.red),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    // Build legacy task map for compatibility with existing widgets
    final task = {
      'id': widget.service.id,
      'user': widget.service.displayCustomerName,
      'date': widget.service.scheduledDate ?? DateTime.now(),
      'title': widget.service.name,
      'desc': widget.service.description ?? '-',
      'plate': widget.service.displayVehiclePlate,
      'motor': widget.service.displayVehicleName,
      'status': widget.service.status,
      'category': widget.service.categoryName ?? 'Servis',
    };

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: const CustomHeader(title: "Invoice Form", showBack: true),
      body: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  InvoiceCustomerHeader(task: task),
                  const SizedBox(height: 18),
                  Center(
                    child: Text("Informasi Servis",
                        style: GoogleFonts.poppins(fontSize: 16, fontWeight: FontWeight.bold)),
                  ),
                  const SizedBox(height: 12),
                  InvoiceServiceInfo(task: task, mainColor: mainColor),
                  const SizedBox(height: 18),
                  InvoiceServiceList(
                    serviceList: serviceList,
                    jenisOptions: jenisOptions,
                    mainColor: mainColor,
                    onAdd: _addService,
                    onEdit: _editService,
                    onDelete: _deleteService,
                    onJenisChanged: _onJenisChanged,
                  ),
                  const SizedBox(height: 16),
                  
                  // Voucher Input Section
                  Text("Kode Voucher (Opsional)", style: GoogleFonts.poppins(fontSize: 15, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Expanded(
                        child: TextField(
                          controller: voucherController,
                          enabled: !_voucherApplied,
                          decoration: InputDecoration(
                            hintText: "Masukkan kode voucher...",
                            hintStyle: GoogleFonts.poppins(fontSize: 13),
                            contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                            enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10),
                              borderSide: BorderSide(color: Colors.grey.shade400),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10),
                              borderSide: BorderSide(color: mainColor),
                            ),
                            disabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10),
                              borderSide: BorderSide(color: Colors.grey.shade300),
                            ),
                            filled: _voucherApplied,
                            fillColor: _voucherApplied ? Colors.green.withOpacity(0.1) : null,
                            suffixIcon: _voucherApplied
                                ? const Icon(Icons.check_circle, color: Colors.green)
                                : null,
                          ),
                        ),
                      ),
                      const SizedBox(width: 10),
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
                                backgroundColor: mainColor,
                                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                              ),
                              child: _isValidatingVoucher
                                  ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                                  : Text("Apply", style: GoogleFonts.poppins(color: Colors.white, fontWeight: FontWeight.w600)),
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
                      child: Text("Voucher berhasil diterapkan!", style: GoogleFonts.poppins(fontSize: 12, color: Colors.green, fontWeight: FontWeight.w500)),
                    ),
                  
                  const SizedBox(height: 16),
                  
                  // Price Breakdown
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: mainColor.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Column(
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text("Subtotal", style: GoogleFonts.poppins(fontSize: 14, color: Colors.grey[700])),
                            Text("Rp ${_subtotal.toString().replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (m) => '${m[1]}.')}",
                                style: GoogleFonts.poppins(fontSize: 14, color: Colors.grey[700])),
                          ],
                        ),
                        if (_voucherApplied && _discountAmount > 0) ...[
                          const SizedBox(height: 8),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text("Diskon Voucher", style: GoogleFonts.poppins(fontSize: 14, color: Colors.green[700])),
                              Text("- Rp ${_discountAmount.toInt().toString().replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (m) => '${m[1]}.')}",
                                  style: GoogleFonts.poppins(fontSize: 14, color: Colors.green[700], fontWeight: FontWeight.w500)),
                            ],
                          ),
                        ],
                        const Divider(height: 16),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text("Total", style: GoogleFonts.poppins(fontSize: 16, fontWeight: FontWeight.bold)),
                            Text("Rp ${_totalAmount.toString().replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (m) => '${m[1]}.')}",
                                style: GoogleFonts.poppins(fontSize: 16, fontWeight: FontWeight.bold, color: mainColor)),
                          ],
                        ),
                      ],
                    ),
                  ),
                  
                  const SizedBox(height: 16),
                  Text("Catatan Teknisi", style: GoogleFonts.poppins(fontSize: 15, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 8),
                  TextField(
                    controller: technicianNoteController,
                    maxLines: 4,
                    decoration: InputDecoration(
                      hintText: "Masukkan catatan teknisi...",
                      hintStyle: GoogleFonts.poppins(fontSize: 13),
                      contentPadding: const EdgeInsets.all(10),
                      enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                          borderSide: BorderSide(color: mainColor, width: 1.2)),
                      focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                          borderSide: BorderSide(color: mainColor, width: 1.5)),
                    ),
                  ),
                  const SizedBox(height: 24),
                ],
              ),
            ),
          ),
          Container(
            color: Colors.white,
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
            child: Row(
              children: [
                Expanded(
                  child: SizedBox(
                    height: 58,
                    child: ElevatedButton(
                      onPressed: _isLoading ? null : () => Navigator.pop(context),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.grey,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
                        elevation: 4,
                      ),
                      child: Text("Batalkan",
                          style: GoogleFonts.poppins(fontSize: 15, fontWeight: FontWeight.bold, color: Colors.white)),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: SizedBox(
                    height: 58,
                    child: ElevatedButton(
                      onPressed: _isLoading ? null : _createTransactionAndContinue,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: mainColor,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
                        elevation: 4,
                      ),
                      child: _isLoading 
                        ? const SizedBox(width: 24, height: 24, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                        : Text("Lanjutkan", style: GoogleFonts.poppins(fontSize: 15, fontWeight: FontWeight.bold, color: Colors.white)),
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
}
