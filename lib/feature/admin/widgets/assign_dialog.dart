import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:bengkel_online_flutter/feature/admin/providers/admin_service_provider.dart';
import 'package:bengkel_online_flutter/core/models/employment.dart';

/// 🔹 Popup pertama: pilih teknisi
void showTechnicianSelectDialog(
  BuildContext context, {
  required Function(String mechanicUuid, String mechanicName) onConfirm,
  String? workshopUuid, // Added workshopUuid param
}) {
  showDialog(
    context: context,
    builder: (context) {
      return Dialog(
        backgroundColor: Colors.grey[200],
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: TechnicianSelectContent(onConfirm: onConfirm, workshopUuid: workshopUuid),
        ),
      );
    },
  );
}

class TechnicianSelectContent extends StatefulWidget {
  final Function(String, String) onConfirm;
  final String? workshopUuid;

  const TechnicianSelectContent({super.key, required this.onConfirm, this.workshopUuid});

  @override
  State<TechnicianSelectContent> createState() => _TechnicianSelectContentState();
}

class _TechnicianSelectContentState extends State<TechnicianSelectContent> {
  String? selectedTechnicianUuid;
  String selectedTechnicianName = "";
  List<Employment> mechanics = [];
  bool loading = true;
  String? error;

  @override
  void initState() {
    super.initState();
    _fetchMechanics();
  }

  Future<void> _fetchMechanics() async {
    try {
      final adminProvider = context.read<AdminServiceProvider>();
      // Fetch mechanics/employees via Admin API
      final employees = await adminProvider.fetchEmployees(
        page: 1, 
        perPage: 100,
        role: 'mechanic', // Attempt backend filter
        workshopUuid: widget.workshopUuid, // Pass workshopUuid from widget
      );
      
      // Filter for mechanics
      setState(() {
        mechanics = employees.where((e) {
             final r = e.role.toLowerCase();
             final j = (e.jobdesk ?? '').toLowerCase();
             
             // Check strict role names
             final isRoleMatch = r.contains('mechanic') || r.contains('teknisi') || r.contains('mekanik');
             final isJobMatch = j.contains('mechanic') || j.contains('teknisi') || j.contains('mekanik');
             
             // Check via User.hasRole helper
             final user = e.user;
             bool isHasRoleMatch = false;
             if (user != null) {
                // Check common role variations
                if (user.hasRole('mechanic') || user.hasRole('teknisi') || user.hasRole('mekanik')) {
                  isHasRoleMatch = true;
                }
                final userRole = user.role.toLowerCase();
                 if (userRole.contains('mechanic') || userRole.contains('teknisi') || userRole.contains('mekanik')) {
                  isHasRoleMatch = true;
                }
             }

             return isRoleMatch || isJobMatch || isHasRoleMatch;
        }).toList();
        
        // Debug fallback: show all if strict filter has 0 results but we have employees
        // Useful if the returned "users" don't have roles set correctly yet
        if (mechanics.isEmpty && employees.isNotEmpty) {
             mechanics = employees;
        }
        loading = false;
      });
    } catch (e) {
      setState(() {
        error = e.toString().contains("Exception:") 
            ? e.toString().split("Exception:").last.trim() 
            : e.toString();
        loading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    const mainColor = Color(0xFFDC2626);

    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
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
        Text(
          "Pilih Teknisi untuk servis ini",
          style: GoogleFonts.poppins(fontSize: 14),
        ),
        const SizedBox(height: 6),

        if (loading)
           const Center(child: Padding(
             padding: EdgeInsets.all(8.0),
             child: CircularProgressIndicator(),
           ))
        else if (error != null)
           Padding(
             padding: const EdgeInsets.all(8.0),
             child: Text("Error: $error", style: TextStyle(color: Colors.red)),
           )
        else if (mechanics.isEmpty)
           Padding(
             padding: const EdgeInsets.all(8.0),
             child: Text("Tidak ada teknisi tersedia.", style: TextStyle(color: Colors.grey)),
           )
        else
          DropdownButtonFormField<String>(
            value: selectedTechnicianUuid,
            items: mechanics.map((e) {
              return DropdownMenuItem(
                value: e.id, // Use ID (Employment ID) to match exists:employments,id
                child: Text(
                  e.name,
                  style: GoogleFonts.poppins(fontSize: 14),
                ),
              );
            }).toList(),
            onChanged: (val) {
              setState(() {
                selectedTechnicianUuid = val;
                selectedTechnicianName = mechanics.firstWhere((e) => e.id == val).name;
              });
            },
            decoration: InputDecoration(
              fillColor: Colors.white,
              filled: true,
              hintText: "Pilih Teknisi",
              hintStyle: GoogleFonts.poppins(color: Colors.grey),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(
                  color: Colors.grey.shade400,
                  width: 1.5,
                ),
              ),
              focusedBorder: const OutlineInputBorder(
                borderRadius: BorderRadius.all(Radius.circular(12)),
                borderSide: BorderSide(color: mainColor, width: 2),
              ),
            ),
          ),

        const SizedBox(height: 24),

        Row(
          children: [
            Expanded(
              child: OutlinedButton(
                onPressed: () => Navigator.pop(context),
                style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 12),
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
            Expanded(
              child: ElevatedButton(
                onPressed: selectedTechnicianUuid == null
                    ? null
                    : () {
                        Navigator.pop(context); // close first dialog
                        showAssignConfirmDialog(
                          context,
                          selectedTechnicianName,
                          onConfirm: () => widget.onConfirm(selectedTechnicianUuid!, selectedTechnicianName),
                        ); 
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
  }
}

/// 🔹 Popup kedua: konfirmasi assign teknisi
void showAssignConfirmDialog(
  BuildContext context, 
  String technician, {
  required VoidCallback onConfirm,
}) {
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
                        onConfirm();
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
