import 'dart:io';
import 'package:bengkel_online_flutter/feature/admin/screens/voucher_previewpage.dart';
import 'package:bengkel_online_flutter/feature/admin/widgets/custom_header.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:bengkel_online_flutter/feature/admin/widgets/datetime.dart'; // 🔹 Import widget kamu

class AddVoucherPage extends StatefulWidget {
  const AddVoucherPage({super.key});

  @override
  _AddVoucherPageState createState() => _AddVoucherPageState();
}

class _AddVoucherPageState extends State<AddVoucherPage> {
  final _formKey = GlobalKey<FormState>();

  final TextEditingController _namaController = TextEditingController();
  final TextEditingController _diskonController = TextEditingController();
  final TextEditingController _kuotaController = TextEditingController();
  final TextEditingController _jumlahController = TextEditingController();
  final TextEditingController _waktuMulaiController = TextEditingController();
  final TextEditingController _waktuBerakhirController =
      TextEditingController();
  final TextEditingController _kodeController = TextEditingController();

  File? _voucherImage;
  final Color primaryColor = const Color(0xFFDC2626);

  /// 🔹 Ambil gambar voucher
  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final pickedFile =
        await picker.pickImage(source: ImageSource.gallery, imageQuality: 80);

    if (pickedFile != null) {
      setState(() {
        _voucherImage = File(pickedFile.path);
      });
    }
  }

  /// 🔹 Field umum dengan validasi
  Widget _buildTextField({
    required String label,
    required String hint,
    required IconData icon,
    required TextEditingController controller,
    TextInputType keyboardType = TextInputType.text,
    List<TextInputFormatter>? inputFormatters,
    String? Function(String?)? validator,
  }) {
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      inputFormatters: inputFormatters,
      style: GoogleFonts.poppins(color: primaryColor),
      validator: validator,
      decoration: InputDecoration(
        labelText: label,
        hintText: hint,
        labelStyle: GoogleFonts.poppins(color: primaryColor),
        hintStyle: GoogleFonts.poppins(color: Colors.grey),
        prefixIcon: Icon(icon, color: primaryColor),

        // ✅ Border konsisten
        focusedBorder: OutlineInputBorder(
          borderSide: BorderSide(color: primaryColor, width: 2),
          borderRadius: BorderRadius.circular(8),
        ),
        enabledBorder: OutlineInputBorder(
          borderSide: BorderSide(color: primaryColor),
          borderRadius: BorderRadius.circular(8),
        ),
        errorBorder: OutlineInputBorder(
          borderSide: const BorderSide(color: Colors.red, width: 2),
          borderRadius: BorderRadius.circular(8),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderSide: const BorderSide(color: Colors.red, width: 2),
          borderRadius: BorderRadius.circular(8),
        ),

        // ✅ Biar errorText nggak bikin field loncat
        errorStyle: GoogleFonts.poppins(
          color: Colors.red,
          fontSize: 12,
          height: 1.2,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Theme(
      data: ThemeData(
        textTheme: GoogleFonts.poppinsTextTheme(),
      ),
      child: Scaffold(
        appBar: CustomHeader(
          title: "Tambah Voucher",
          onBack: () => Navigator.pop(context),
        ),

        body: SafeArea(
          child: Form(
            key: _formKey,
            child: ListView(
              padding: const EdgeInsets.all(16.0),
              children: [
                const SizedBox(height: 12),

                _buildTextField(
                  label: "Nama Voucher",
                  hint: "Masukkan nama voucher",
                  icon: Icons.card_giftcard,
                  controller: _namaController,
                  validator: (val) =>
                      val == null || val.isEmpty ? "Nama wajib diisi" : null,
                ),
                const SizedBox(height: 16),

                _buildTextField(
                  label: "Nominal Diskon (%)",
                  hint: "Masukkan nominal diskon",
                  icon: Icons.percent,
                  controller: _diskonController,
                  keyboardType: TextInputType.number,
                  inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                  validator: (val) =>
                      val == null || val.isEmpty ? "Diskon wajib diisi" : null,
                ),
                const SizedBox(height: 16),

                _buildTextField(
                  label: "Kuota Pemakai",
                  hint: "Masukkan kuota",
                  icon: Icons.people,
                  controller: _kuotaController,
                  keyboardType: TextInputType.number,
                  inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                  validator: (val) =>
                      val == null || val.isEmpty ? "Kuota wajib diisi" : null,
                ),
                const SizedBox(height: 16),

                _buildTextField(
                  label: "Jumlah Maksimal Pemakaian",
                  hint: "Masukkan jumlah maksimal per akun",
                  icon: Icons.confirmation_number,
                  controller: _jumlahController,
                  keyboardType: TextInputType.number,
                  inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                  validator: (val) => val == null || val.isEmpty
                      ? "Jumlah maksimal wajib diisi"
                      : null,
                ),
                const SizedBox(height: 16),

                // 🔹 Ganti dengan DateRangeField custom
                DateRangeField(
                  startController: _waktuMulaiController,
                  endController: _waktuBerakhirController,
                  primaryColor: primaryColor,
                  icon: Icons.calendar_today,
                ),
                const SizedBox(height: 16),

                _buildTextField(
                  label: "Kode Awal Voucher",
                  hint: "Masukkan kode voucher",
                  icon: Icons.vpn_key,
                  controller: _kodeController,
                  validator: (val) =>
                      val == null || val.isEmpty ? "Kode wajib diisi" : null,
                ),
                const SizedBox(height: 24),

                //Minimal Diskon 
                 _buildTextField(
                  label: "Jumlah Minimal Diskon",
                  hint: "Masukkan jumlah minimal diskon per transaksi",
                  icon: Icons.confirmation_number,
                  controller: _jumlahController,
                  keyboardType: TextInputType.number,
                  inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                  validator: (val) => val == null || val.isEmpty
                      ? "Jumlah minimal diskon wajib diisi"
                      : null,
                ),
                const SizedBox(height: 16),


                // Upload Gambar Voucher
                Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    "Upload Gambar Voucher",
                    style: GoogleFonts.poppins(
                      fontWeight: FontWeight.w600,
                      color: primaryColor,
                      fontSize: 16,
                    ),
                  ),
                ),
                const SizedBox(height: 8),
                GestureDetector(
                  onTap: _pickImage,
                  child: Container(
                    width: double.infinity,
                    height: 160,
                    decoration: BoxDecoration(
                      border: Border.all(color: primaryColor),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: _voucherImage == null
                        ? Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.cloud_upload,
                                  size: 40, color: primaryColor),
                              const SizedBox(height: 8),
                              Text(
                                "Drag & drop files or Browse",
                                style: GoogleFonts.poppins(
                                  color: primaryColor,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                              Text(
                                "Supported formats: JPEG, PNG",
                                style: GoogleFonts.poppins(
                                  color: Colors.black54,
                                  fontSize: 12,
                                ),
                              ),
                            ],
                          )
                        : ClipRRect(
                            borderRadius: BorderRadius.circular(12),
                            child: Image.file(
                              _voucherImage!,
                              fit: BoxFit.cover,
                              width: double.infinity,
                              height: double.infinity,
                            ),
                          ),
                  ),
                ),
                const SizedBox(height: 30),
              ],
            ),
          ),
        ),

        // 🔹 Tombol simpan voucher tetap di bawah
        bottomNavigationBar: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: primaryColor,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                onPressed: () {
                  if (_formKey.currentState!.validate()) {
                    // 🔹 Validasi manual tanggal
                    if (_waktuMulaiController.text.isNotEmpty &&
                        _waktuBerakhirController.text.isNotEmpty) {
                      final start = DateFormat("dd-MM-yyyy")
                          .parse(_waktuMulaiController.text);
                      final end = DateFormat("dd-MM-yyyy")
                          .parse(_waktuBerakhirController.text);

                      if (end.isBefore(start)) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                              content: Text(
                                  "Tanggal berakhir tidak boleh sebelum tanggal mulai")),
                        );
                        return;
                      }
                    }

                    // TODO: simpan voucher ke backend
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => VoucherPreviewPage(
                          nama: _namaController.text,
                          tanggalMulai: _waktuMulaiController.text,
                          tanggalAkhir: _waktuBerakhirController.text,
                          kuota: _kuotaController.text,
                          gambar: _voucherImage,
                        ),
                      ),
                    );
                  }
                },
                child: Text(
                  "SIMPAN VOUCHER",
                  style: GoogleFonts.poppins(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
