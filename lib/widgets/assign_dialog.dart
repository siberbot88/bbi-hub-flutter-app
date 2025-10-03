import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/// 🔹 Popup pertama: pilih teknisi
void showTechnicianSelectDialog(BuildContext context) {
  final List<String> technicians = ["Budi", "Andi", "Siti", "Rahmat"];
  String? selectedTechnician;

  showDialog(
    context: context,
    builder: (context) {
      return Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: StatefulBuilder(
            builder: (context, setState) {
              return Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Center(
                    child: Text("Assign Technisi",
                        style: GoogleFonts.poppins(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Colors.red[800])),
                  ),
                  const SizedBox(height: 14),
                  Text("Choose a technician",
                      style: GoogleFonts.poppins(fontSize: 14)),
                  const SizedBox(height: 6),

                  // Dropdown teknisi
                  DropdownButtonFormField<String>(
                    value: selectedTechnician,
                    items: technicians
                        .map((e) => DropdownMenuItem(
                              value: e,
                              child: Text(e,
                                  style: GoogleFonts.poppins(fontSize: 14)),
                            ))
                        .toList(),
                    onChanged: (val) =>
                        setState(() => selectedTechnician = val),
                    decoration: InputDecoration(
                      hintText: "Choose a technician",
                      hintStyle: GoogleFonts.poppins(),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                      contentPadding: const EdgeInsets.symmetric(
                          horizontal: 10, vertical: 10),
                    ),
                  ),

                  const SizedBox(height: 20),

                  // Tombol Batal & Lanjutkan
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton(
                          onPressed: () => Navigator.pop(context),
                          style: OutlinedButton.styleFrom(
                              shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12))),
                          child: Text("Batalkan",
                              style: GoogleFonts.poppins(
                                  fontSize: 14, color: Colors.black)),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: ElevatedButton(
                          onPressed: selectedTechnician == null
                              ? null
                              : () {
                                  Navigator.pop(context); // tutup popup pertama
                                  showAssignConfirmDialog(context,
                                      selectedTechnician!); // buka popup kedua
                                },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFFB70F0F),
                            disabledBackgroundColor: Colors.grey,
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12)),
                          ),
                          child: Text("Lanjutkan",
                              style: GoogleFonts.poppins(
                                  fontSize: 14, color: Colors.white)),
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

/// 🔹 Popup kedua: konfirmasi
void showAssignConfirmDialog(BuildContext context, String technician) {
  showDialog(
    context: context,
    builder: (context) {
      return Dialog(
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
                    fontSize: 14, fontWeight: FontWeight.w500),
              ),
              const SizedBox(height: 20),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => Navigator.pop(context),
                      style: OutlinedButton.styleFrom(
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12))),
                      child: Text("Batalkan",
                          style: GoogleFonts.poppins(
                              fontSize: 14, color: Colors.black)),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () {
                        Navigator.pop(context); // tutup popup confirm
                        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                          content:
                              Text("Service berhasil diassign ke $technician"),
                          backgroundColor: Colors.green,
                        ));
                        // TODO: update status service di sini
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFFB70F0F),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12)),
                      ),
                      child: Text("Yakin",
                          style: GoogleFonts.poppins(
                              fontSize: 14, color: Colors.white)),
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
