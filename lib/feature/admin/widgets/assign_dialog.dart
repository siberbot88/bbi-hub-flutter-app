import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/// 🔹 Popup pertama: pilih teknisi
void showTechnicianSelectDialog(BuildContext context) {
  final List<String> technicians = ["Budi", "Andi", "Siti", "Rahmat"];
  String? selectedTechnician;
  const mainColor = Color(0xFFDC2626); // warna utama (merah)

  showDialog(
    context: context,
    builder: (context) {
      return Dialog(
        backgroundColor: Colors.grey[200], // warna latar belakang dialog
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: StatefulBuilder(
            builder: (context, setState) {
              return Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Judul
                  Center(
                    child: Text(
                      "Tetapkan Mekanik",
                      style: GoogleFonts.poppins(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.red[800],
                      ),
                    ),
                  ),
                  const SizedBox(height: 14),

                  // Subjudul
                  Text(
                    "Pilih Teknisi untuk servis ini",
                    style: GoogleFonts.poppins(fontSize: 14),
                  ),
                  const SizedBox(height: 6),

                  // Dropdown teknisi
                  DropdownButtonFormField<String>(
                    initialValue: selectedTechnician,
                    items: technicians
                        .map(
                          (e) => DropdownMenuItem(
                            value: e,
                            child: Text(
                              e,
                              style: GoogleFonts.poppins(fontSize: 14),
                            ),
                          ),
                        )
                        .toList(),
                    onChanged: (val) =>
                        setState(() => selectedTechnician = val),
                    decoration: InputDecoration(
                      fillColor: Colors.white,
                      filled: true,
                      hintText: "Pilih Teknisi untuk servis ini",
                      hintStyle: GoogleFonts.poppins(color: Colors.grey),
                      // Border saat tidak fokus
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide(
                          color: Colors.grey.shade400,
                          width: 1.5,
                        ),
                      ),
                      // Border saat fokus
                      focusedBorder: const OutlineInputBorder(
                        borderRadius: BorderRadius.all(Radius.circular(12)),
                        borderSide: BorderSide(color: mainColor, width: 2),
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),

                  // Tombol Batal & Lanjutkan
                  Row(
                    children: [
                      // Tombol Batal
                      Expanded(
                        child: OutlinedButton(
                          onPressed: () => Navigator.pop(context),
                          style: OutlinedButton.styleFrom(
                            padding:
                                const EdgeInsets.symmetric(vertical: 12),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            side: BorderSide(
                              color: Colors.grey.shade400,
                              width: 1.5,
                            ),
                          ),
                          child: Text(
                            "Batalkan",
                            style: GoogleFonts.poppins(
                              fontSize: 14,
                              color: Colors.black,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),

                      // Tombol Lanjutkan
                      Expanded(
                        child: ElevatedButton(
                          onPressed: selectedTechnician == null
                              ? null
                              : () {
                                  Navigator.pop(context); // tutup popup pertama
                                  showAssignConfirmDialog(
                                    context,
                                    selectedTechnician!,
                                  ); // buka popup kedua
                                },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: mainColor,
                            disabledBackgroundColor: Colors.grey,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          child: Text(
                            "Lanjutkan",
                            style: GoogleFonts.poppins(
                              fontSize: 14,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              );
            },
          ),
        ),
      );
    },
  );
}

/// 🔹 Popup kedua: konfirmasi assign teknisi
void showAssignConfirmDialog(BuildContext context, String technician) {
  showDialog(
    context: context,
    builder: (context) {
      return Dialog(
        backgroundColor: Colors.grey[200], // warna latar belakang dialog
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.engineering, size: 50, color: Colors.red),
              const SizedBox(height: 12),
              Text(
                "Apakah anda yakin untuk assign teknisi\n$technician pada service ini?",
                textAlign: TextAlign.center,
                style: GoogleFonts.poppins(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 20),
              Row(
                children: [
                  // Tombol Batal
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => Navigator.pop(context),
                      style: OutlinedButton.styleFrom(
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: Text(
                        "Batalkan",
                        style: GoogleFonts.poppins(
                          fontSize: 14,
                          color: Colors.black,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),

                  // Tombol Yakin
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () {
                        Navigator.pop(context); // tutup popup konfirmasi
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(
                              "Service berhasil diassign ke $technician",
                              style: GoogleFonts.poppins(),
                            ),
                            backgroundColor: Colors.green,
                          ),
                        );
                        // TODO: Tambahkan logika update status service di sini
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFFB70F0F),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: Text(
                        "Yakin",
                        style: GoogleFonts.poppins(
                          fontSize: 14,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                ],
              )
            ],
          ),
        ),
      );
    },
  );
}
