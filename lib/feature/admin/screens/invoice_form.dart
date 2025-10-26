import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:google_fonts/google_fonts.dart';
import '../widgets/custom_header.dart';
import 'invoice_payment.dart';


class InvoiceFormPage extends StatefulWidget {
  final Map<String, dynamic>? task;

  const InvoiceFormPage({super.key, this.task});

  @override
  State<InvoiceFormPage> createState() => _InvoiceFormPageState();
}

class _InvoiceFormPageState extends State<InvoiceFormPage> {
  final Color mainColor = const Color(0xFFDC2626);
  final TextEditingController technicianNoteController = TextEditingController();

  final List<Map<String, dynamic>> serviceList = [
    {"nama": "Servis besar", "jenis": "Jasa Pekerjaan", "harga": 450000},
    {"nama": "Ganti Kampas rem", "jenis": "Sparepart", "harga": 250000},
    {"nama": "Ganti Ban Belakang", "jenis": "Sparepart", "harga": 380000},
  ];

  final List<String> jenisOptions = [
    "Jasa Pekerjaan",
    "Sparepart",
    "Biaya Tambahan",
    "Lainnya (PPN, dll)"
  ];

  void _addService() {
    setState(() {
      serviceList.add({"nama": "", "jenis": "Jasa Pekerjaan", "harga": 0});
    });
  }

  void _editService(int index) {
    final namaController =
        TextEditingController(text: serviceList[index]["nama"]);
    final hargaController =
        TextEditingController(text: serviceList[index]["harga"].toString());
    String selectedJenis = serviceList[index]["jenis"];

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title:
            Text("Edit Servis", style: GoogleFonts.poppins(fontWeight: FontWeight.bold)),
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
              items: jenisOptions
                  .map((e) => DropdownMenuItem(value: e, child: Text(e)))
                  .toList(),
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
                serviceList[index]["harga"] =
                    int.tryParse(hargaController.text) ?? 0;
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

  Widget _smallBox({required Widget child}) {
    return Container(
      height: 48,
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
      decoration: BoxDecoration(
        border: Border.all(color: mainColor, width: 1.1),
        borderRadius: BorderRadius.circular(10),
      ),
      child: child,
    );
  }

@override
Widget build(BuildContext context) {
  final task = widget.task ?? {};
  final DateTime? orderDate = task['date'] is DateTime ? task['date'] : null;

  return Scaffold(
    backgroundColor: Colors.white,
    appBar: const CustomHeader(title: "Invoice Form", showBack: true),
    body: Column(
      children: [
        // --- Area Scrollable ---
        Expanded(
          child: SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // === Header User ===
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    CircleAvatar(
                      radius: 20,
                      backgroundImage: NetworkImage(
                        "https://i.pravatar.cc/150?img=${task['id'] ?? 1}",
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(task['user'] ?? "Prabowo",
                              style: GoogleFonts.poppins(
                                  fontSize: 15,
                                  fontWeight: FontWeight.w600)),
                          const SizedBox(height: 2),
                          Text("ID: ${task['id'] ?? '4589930272'}",
                              style: GoogleFonts.poppins(
                                  fontSize: 12, color: Colors.grey[700])),
                        ],
                      ),
                    ),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text("Tanggal order",
                            style: GoogleFonts.poppins(
                                fontSize: 12, color: Colors.grey[700])),
                        Text(
                          orderDate != null
                              ? _formatDate(orderDate)
                              : "2 September 2025",
                          style: GoogleFonts.poppins(
                              fontSize: 12, fontWeight: FontWeight.w600),
                        ),
                      ],
                    ),
                  ],
                ),

                const SizedBox(height: 18),

                // === Informasi Servis ===
                Center(
                  child: Text("Informasi Servis",
                      style: GoogleFonts.poppins(
                          fontSize: 16, fontWeight: FontWeight.bold)),
                ),
                const SizedBox(height: 12),

                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text("Model Kendaraan",
                                style: GoogleFonts.poppins(
                                    fontSize: 12,
                                    fontWeight: FontWeight.w500)),
                            const SizedBox(height: 4),
                            Text(task['model'] ?? "BEAT2012",
                                style: GoogleFonts.poppins(
                                    color: Colors.blueAccent, fontSize: 13)),
                            const SizedBox(height: 8),
                            Text("Plat Nomor",
                                style: GoogleFonts.poppins(
                                    fontSize: 12,
                                    fontWeight: FontWeight.w500)),
                            const SizedBox(height: 4),
                            Text(task['plate'] ?? "SU 814 NTO",
                                style: GoogleFonts.poppins(fontSize: 13)),
                          ]),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text("Penjadwalan",
                                style: GoogleFonts.poppins(
                                    fontSize: 12,
                                    fontWeight: FontWeight.w500)),
                            const SizedBox(height: 4),
                            Text(
                                task['jadwal'] ??
                                    "8:00 - 10:00 AM : 05/08/2025",
                                style:
                                    GoogleFonts.poppins(fontSize: 13)),
                            const SizedBox(height: 8),
                            Text("Jenis Kendaraan",
                                style: GoogleFonts.poppins(
                                    fontSize: 12,
                                    fontWeight: FontWeight.w500)),
                            const SizedBox(height: 4),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 8, vertical: 3),
                              decoration: BoxDecoration(
                                  color: const Color(0xFFFFE5E5),
                                  borderRadius:
                                      BorderRadius.circular(14)),
                              child: Text(
                                  task['jenis'] ?? "Sepeda Motor",
                                  style: GoogleFonts.poppins(
                                      color: mainColor,
                                      fontSize: 12,
                                      fontWeight: FontWeight.w600)),
                            ),
                          ]),
                    ),
                  ],
                ),

                const SizedBox(height: 18),

                // === Input Servis Form ===
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text("Input Servis Form",
                        style: GoogleFonts.poppins(
                            fontSize: 15, fontWeight: FontWeight.w600)),
                    InkWell(
                      onTap: _addService,
                      child: Container(
                        padding: const EdgeInsets.all(6),
                        decoration: BoxDecoration(
                            color: mainColor,
                            borderRadius: BorderRadius.circular(8)),
                        child: SvgPicture.asset('assets/icons/plus.svg',
                            width: 16,
                            height: 16,
                            colorFilter: const ColorFilter.mode(
                                Colors.white, BlendMode.srcIn)),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Text("Nama Servis / Jenis / Harga",
                    style: GoogleFonts.poppins(
                        fontSize: 12, color: Colors.black87)),
                const SizedBox(height: 10),

                // === Daftar Servis (Tinggi dan Lebar Konsisten) ===
                Column(
                  children: List.generate(serviceList.length, (index) {
                    final item = serviceList[index];
                    return Padding(
                      padding: const EdgeInsets.symmetric(vertical: 5),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          // Nama Servis
                          Expanded(
                            flex: 38,
                            child: Container(
                              height: 48,
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 8),
                              decoration: BoxDecoration(
                                border: Border.all(
                                    color: mainColor, width: 1.1),
                                borderRadius: BorderRadius.circular(10),
                              ),
                              alignment: Alignment.centerLeft,
                              child: Text(
                                item['nama'].isEmpty
                                    ? "Isi nama servis..."
                                    : item['nama'],
                                style: GoogleFonts.poppins(
                                    fontSize: 13,
                                    fontWeight: FontWeight.w600,
                                    color: mainColor),
                                overflow: TextOverflow.ellipsis,
                                maxLines: 1,
                              ),
                            ),
                          ),
                          const SizedBox(width: 8),

                          // Jenis
                          Expanded(
                            flex: 30,
                            child: Container(
                              height: 48,
                              padding:
                                  const EdgeInsets.symmetric(horizontal: 8),
                              decoration: BoxDecoration(
                                border: Border.all(
                                    color: mainColor, width: 1.1),
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: DropdownButtonHideUnderline(
                              child: DropdownButton<String>(
                                isExpanded: true,
                                value: item['jenis'],
                                icon: SvgPicture.asset(
                                'assets/icons/dropdown.svg',
                          width: 16,
                          height: 16,
                        ),
                        items: jenisOptions
                            .map(
                              (e) => DropdownMenuItem(
                                value: e,
                                child: Text(
                                  e,
                                  style: GoogleFonts.poppins(fontSize: 13),
                                  overflow: TextOverflow.ellipsis, // ✅ biar teks panjang jadi "..."
                                  maxLines: 1,
                                ),
                              ),
                            )
                            .toList(),
                        onChanged: (v) {
                          setState(() {
                            item['jenis'] = v!;
                          });
                        },
                      ),

                              ),
                            ),
                          ),
                          const SizedBox(width: 8),

                          // Harga
                          Expanded(
                            flex: 32,
                            child: Container(
                              height: 48,
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 8),
                              decoration: BoxDecoration(
                                border: Border.all(
                                    color: mainColor, width: 1.1),
                                borderRadius: BorderRadius.circular(10),
                              ),
                              alignment: Alignment.centerLeft,
                              child: Text(
                                "Rp. ${item['harga']}",
                                style: GoogleFonts.poppins(
                                    fontSize: 13,
                                    fontWeight: FontWeight.w600,
                                    color: Colors.black87),
                                overflow: TextOverflow.ellipsis,
                                maxLines: 1,
                              ),
                            ),
                          ),
                          const SizedBox(width: 6),

                          // Tombol Aksi
                          Row(
                            children: [
                              InkWell(
                                onTap: () => _deleteService(index),
                                borderRadius: BorderRadius.circular(8),
                                child: Container(
                                  width: 40,
                                  height: 48,
                                  padding: const EdgeInsets.all(8),
                                  decoration: BoxDecoration(
                                    border: Border.all(
                                        color: Colors.red, width: 1.5),
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: SvgPicture.asset(
                                    'assets/icons/delete.svg',
                                    colorFilter: const ColorFilter.mode(
                                        Colors.red, BlendMode.srcIn),
                                  ),
                                ),
                              ),
                              const SizedBox(width: 6),
                              InkWell(
                                onTap: () => _editService(index),
                                borderRadius: BorderRadius.circular(8),
                                child: Container(
                                  width: 40,
                                  height: 48,
                                  padding: const EdgeInsets.all(8),
                                  decoration: BoxDecoration(
                                    border: Border.all(
                                        color: Colors.red, width: 1.5),
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: SvgPicture.asset(
                                    'assets/icons/edit.svg',
                                    colorFilter: const ColorFilter.mode(
                                        Colors.red, BlendMode.srcIn),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    );
                  }),
                ),

                const SizedBox(height: 16),

                // === Catatan Teknisi ===
                Text("Catatan Teknisi",
                    style: GoogleFonts.poppins(
                        fontSize: 15, fontWeight: FontWeight.bold)),
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
                        borderSide:
                            BorderSide(color: mainColor, width: 1.2)),
                    focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                        borderSide:
                            BorderSide(color: mainColor, width: 1.5)),
                  ),
                ),

                const SizedBox(height: 24),
              ],
            ),
          ),
        ),

        // === Tombol Bawah Tetap ===
        Container(
          color: Colors.white,
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
          child: Row(
            children: [
              Expanded(
                child: SizedBox(
                  height: 58,
                  child: ElevatedButton(
                    onPressed: () {},
                    style: ElevatedButton.styleFrom(
                      backgroundColor: mainColor,
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(30)),
                      elevation: 4,
                    ),
                    child: Text("Batalkan",
                        style: GoogleFonts.poppins(
                            fontSize: 15,
                            fontWeight: FontWeight.bold,
                            color: Colors.white)),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: SizedBox(
                  height: 58,
                  child: ElevatedButton(
                    onPressed: () {
                    Navigator.of(context).push(
                    MaterialPageRoute(
                   builder: (context) => PaymentInvoicePage(),
                     ),
                     );
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: mainColor,
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(30)),
                      elevation: 4,
                    ),
                    child: Text("Lanjutkan",
                        style: GoogleFonts.poppins(
                            fontSize: 15,
                            fontWeight: FontWeight.bold,
                            color: Colors.white)),
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


  String _formatDate(DateTime d) {
    const months = ["Jan","Feb","Mar","Apr","Mei","Jun","Jul","Ags","Sep","Okt","Nov","Des"];
    return "${d.day} ${months[d.month - 1]} ${d.year}";
  }
}
