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
  
  bool _isLoading = false;
  String? _transactionId;

  // Service items that can be edited
  late List<Map<String, dynamic>> serviceList;

  final List<String> jenisOptions = [
    "Jasa Pekerjaan",
    "Sparepart",
    "Biaya Tambahan",
    "Lainnya (PPN, dll)"
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
        {"nama": widget.service.name, "jenis": "Jasa Pekerjaan", "harga": (widget.service.price ?? 0).toInt()},
      ];
    }
  }

  String _mapItemType(String? type) {
    switch (type?.toLowerCase()) {
      case 'jasa': return 'Jasa Pekerjaan';
      case 'sparepart': return 'Sparepart';
      case 'biaya_tambahan': return 'Biaya Tambahan';
      default: return 'Lainnya (PPN, dll)';
    }
  }

  String _reverseMapItemType(String jenis) {
    switch (jenis) {
      case 'Jasa Pekerjaan': return 'jasa';
      case 'Sparepart': return 'sparepart';
      case 'Biaya Tambahan': return 'biaya_tambahan';
      default: return 'lainnya';
    }
  }

  void _addService() {
    setState(() {
      serviceList.add({"nama": "", "jenis": "Jasa Pekerjaan", "harga": 0});
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

  int get _totalAmount {
    return serviceList.fold(0, (sum, item) => sum + ((item['harga'] as int?) ?? 0));
  }

  Future<void> _createTransactionAndContinue() async {
    setState(() => _isLoading = true);

    try {
      final provider = context.read<AdminServiceProvider>();
      
      // Convert service list to API format
      final items = serviceList.map((item) => {
        'name': item['nama'],
        'type': _reverseMapItemType(item['jenis']),
        'quantity': 1,
        'price': item['harga'],
      }).toList();

      // Create transaction
      final transactionData = await provider.createTransaction(
        serviceUuid: widget.service.id,
        notes: technicianNoteController.text,
        items: items,
      );

      _transactionId = transactionData['id']?.toString();

      if (mounted && _transactionId != null) {
        // Navigate to payment page with transaction data
        Navigator.of(context).push(
          MaterialPageRoute(
            builder: (context) => PaymentInvoicePage(
              service: widget.service,
              transactionId: _transactionId!,
              items: serviceList,
              totalAmount: _totalAmount,
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
                  
                  // Total
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: mainColor.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text("Total", style: GoogleFonts.poppins(fontSize: 16, fontWeight: FontWeight.bold)),
                        Text("Rp ${_totalAmount.toString().replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (m) => '${m[1]}.')}",
                            style: GoogleFonts.poppins(fontSize: 16, fontWeight: FontWeight.bold, color: mainColor)),
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
