import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../providers/admin_service_provider.dart';
import 'package:bengkel_online_flutter/core/models/service.dart';
import 'package:bengkel_online_flutter/core/services/auth_provider.dart';
import '../widgets/service/service_card.dart';
import '../widgets/service/service_calendar_section.dart';
import '../widgets/service/service_helpers.dart';

class ServiceOnTheSitePage extends StatefulWidget {
  const ServiceOnTheSitePage({super.key});

  @override
  State<ServiceOnTheSitePage> createState() => _ServiceOnTheSitePageState();
}

class _ServiceOnTheSitePageState extends State<ServiceOnTheSitePage> {
  // Statistics
  int total = 0;
  int processing = 0;
  int completed = 0;

  // Date filter state
  int displayedMonth = DateTime.now().month;
  int displayedYear = DateTime.now().year;
  int selectedDay = DateTime.now().day;
  
  DateTime get selectedDate =>
      DateTime(displayedYear, displayedMonth, selectedDay);

  @override
  void initState() {
    super.initState();
    // NOTE: Do NOT call _fetchData() here!
    // Parent (ServicePageAdmin) already fetches data for the shared AdminServiceProvider.
    // Calling fetch here would cause a race condition and overwrite the parent's data.
  }

  // _fetchData is no longer needed since parent handles it
  // Keep the calendar navigation methods but just call setState to update UI

  void _prevMonth() {
    setState(() {
      displayedMonth--;
      if (displayedMonth < 1) {
        displayedMonth = 12;
        displayedYear--;
      }
      selectedDay = 1;
    });
    // No need to fetch - data is already loaded by parent, we just filter client-side
  }

  void _nextMonth() {
    setState(() {
      displayedMonth++;
      if (displayedMonth > 12) {
        displayedMonth = 1;
        displayedYear++;
      }
      selectedDay = 1;
    });
    // No need to fetch - data is already loaded by parent, we just filter client-side
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<AdminServiceProvider>();
    final allServices = provider.items;
    
    // Antrian Hari Ini (Filter for today logic is in parent, so we take all)
    // Filter logic:
    // Total = All services today
    // Diproses = In Progress
    // Selesai = Completed / Lunas
    
    // Also user image shows specific "Walk-in" tag. 
    // Backend doesn't have "Walk-in" field yet explicitly, maybe check `categoryName`?
    // We'll leave it generic for now.

    // Filter ONLY Walk-in/On-site services
    final todayQueue = allServices.where((s) => (s.type ?? '') == 'on-site').toList(); 
    
    // Debug logging
    print('DEBUG service_on_the_site: allServices=${allServices.length}, onSiteServices=${todayQueue.length}');
    for (var s in todayQueue) {
      print('  -> id=${s.id}, type=${s.type}, status=${s.status}, name=${s.name}');
    }
    
    total = todayQueue.length;
    processing = todayQueue.where((s) {
       final st = (s.status).toLowerCase();
       return st == 'in_progress' || st == 'progress';
    }).length;
    completed = todayQueue.where((s) {
       final st = (s.status).toLowerCase();
       return st == 'completed' || st == 'lunas';
    }).length;

    return SingleChildScrollView(
      padding: const EdgeInsets.only(bottom: 80),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildAddButton(context),
          const SizedBox(height: 16),
          _buildSummaryBoxes(),
          const SizedBox(height: 16),
          // Calendar Section for date filtering
          ServiceCalendarSection(
            displayedMonth: displayedMonth,
            displayedYear: displayedYear,
            selectedDay: selectedDay,
            onPrevMonth: _prevMonth,
            onNextMonth: _nextMonth,
            onDaySelected: (day) {
              setState(() => selectedDay = day);
              // No need to fetch - data is already loaded by parent
            },
          ),
          const SizedBox(height: 20),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text("Antrian On-the-site", style: AppTextStyles.heading4()),
                Text(
                  DateFormat("d MMM yyyy").format(selectedDate), 
                  style: AppTextStyles.bodyMedium(color: Colors.grey),
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),
          if (todayQueue.isEmpty)
             Center(
              child: Padding(
                padding: const EdgeInsets.all(32.0),
                child: Text(
                  "Belum ada antrian hari ini",
                  style: AppTextStyles.bodyMedium(color: Colors.grey),
                ),
              ),
            )
          else
            Column(
              children: todayQueue.map((s) => ServiceCard(service: s)).toList(),
            ),
        ],
      ),
    );
  }

  Widget _buildAddButton(BuildContext context) {
    return Container(
      width: double.infinity,
      color: Colors.white,
      padding: const EdgeInsets.all(16),
      child: ElevatedButton.icon(
        onPressed: () {
          showDialog(
            context: context,
            builder: (ctx) => const AddWalkInServiceDialog(),
          );
        },
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFFD72B1C),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          padding: const EdgeInsets.symmetric(vertical: 14),
          elevation: 2,
        ),
        icon: const Icon(Icons.add, color: Colors.white),
        label: Text(
          "Tambah Servis On-the-site",
          style: GoogleFonts.poppins(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: Colors.white,
          ),
        ),
      ),
    );
  }

  Widget _buildSummaryBoxes() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        children: [
          _summaryBox("Total", total, Colors.blue.shade50, Colors.blue),
          const SizedBox(width: 8),
          _summaryBox("Diproses", processing, Colors.orange.shade50, Colors.orange),
          const SizedBox(width: 8),
          _summaryBox("Selesai", completed, Colors.green.shade50, Colors.green),
        ],
      ),
    );
  }

  Widget _summaryBox(String label, int count, Color bg, Color text) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: bg,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text("$count",
                style: GoogleFonts.poppins(
                    fontSize: 24, fontWeight: FontWeight.bold, color: text)),
            Text(label,
                style: GoogleFonts.poppins(
                    fontSize: 13, fontWeight: FontWeight.w500, color: text.withOpacity(0.8))),
          ],
        ),
      ),
    );
  }
}

class AddWalkInServiceDialog extends StatefulWidget {
  const AddWalkInServiceDialog({super.key});

  @override
  State<AddWalkInServiceDialog> createState() => _AddWalkInServiceDialogState();
}

class _AddWalkInServiceDialogState extends State<AddWalkInServiceDialog> {
  final _formKey = GlobalKey<FormState>();
  
  // Controllers
  final _customerNameCtrl = TextEditingController();
  final _customerPhoneCtrl = TextEditingController();
  final _customerEmailCtrl = TextEditingController();
  
  final _plateCtrl = TextEditingController();
  final _brandCtrl = TextEditingController();
  final _modelCtrl = TextEditingController();
  final _yearCtrl = TextEditingController();
  final _odometerCtrl = TextEditingController();
  
  final _serviceNameCtrl = TextEditingController();
  final _descriptionCtrl = TextEditingController(); // For keluhan/description
  // final _categoryCtrl = TextEditingController(); // Removed for Dropdown
  
  String? _selectedCategory;
  String? _selectedVehicleCategory; // Added
  final List<String> _categoryOptions = ['ringan', 'sedang', 'berat', 'maintenance']; 

  bool _loading = false;

  @override
  void dispose() {
    _customerNameCtrl.dispose();
    _customerPhoneCtrl.dispose();
    _customerEmailCtrl.dispose();
    _plateCtrl.dispose();
    _brandCtrl.dispose();
    _modelCtrl.dispose();
    _yearCtrl.dispose();
    _odometerCtrl.dispose();
    _serviceNameCtrl.dispose();
    _descriptionCtrl.dispose();
    // _categoryCtrl.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    
    setState(() => _loading = true);
    
    try {
        final auth = context.read<AuthProvider>();
        final workshopUuid = auth.user?.workshopUuid ?? '';
        
        await context.read<AdminServiceProvider>().createWalkInService(
            workshopUuid: workshopUuid,
            name: _serviceNameCtrl.text,
            scheduledDate: DateTime.now(), // On the site = Now
            categoryName: _selectedCategory, // Use selected dropdown value
            description: _descriptionCtrl.text.isNotEmpty ? _descriptionCtrl.text : 'Walk-in service',
            
            customerName: _customerNameCtrl.text,
            customerPhone: _customerPhoneCtrl.text,
            customerEmail: _customerEmailCtrl.text,
            
            vehiclePlate: _plateCtrl.text,
            vehicleBrand: _brandCtrl.text,
            vehicleModel: _modelCtrl.text,
            vehicleCategory: _selectedVehicleCategory, // Added
            vehicleYear: int.tryParse(_yearCtrl.text),
            vehicleOdometer: int.tryParse(_odometerCtrl.text),
        );
        
        if (mounted) {
            Navigator.pop(context); // close dialog
            ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text("Servis berhasil ditambahkan ke antrian"), backgroundColor: Colors.green),
            );
        }
    } catch (e) {
        if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text("Gagal: $e"), backgroundColor: Colors.red),
            );
        }
    } finally {
        if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
       backgroundColor: Colors.white, // Ensure white background
       insetPadding: const EdgeInsets.all(16),
       shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
       child: Container(
         constraints: const BoxConstraints(maxWidth: 500, maxHeight: 800),
         child: Column(
           children: [
             // Header
             Padding(
               padding: const EdgeInsets.all(16),
               child: Row(
                 mainAxisAlignment: MainAxisAlignment.spaceBetween,
                 children: [
                   Text("Tambah Servis Walk-In", style: AppTextStyles.heading4()),
                   IconButton(icon: const Icon(Icons.close), onPressed: () => Navigator.pop(context)),
                 ],
               ),
             ),
             const Divider(height: 1),
             
             // Form
             Expanded(
               child: SingleChildScrollView(
                 padding: const EdgeInsets.all(16),
                 child: Form(
                   key: _formKey,
                   child: Column(
                     crossAxisAlignment: CrossAxisAlignment.start,
                     children: [
                       _sectionHeader(Icons.person, "Informasi Pelanggan"),
                       _inputField("Nama Pelanggan *", _customerNameCtrl, required: true),
                       _inputField("No. HP Pelanggan *", _customerPhoneCtrl, required: true, keyboardType: TextInputType.phone),
                       _inputField("Email Pelanggan", _customerEmailCtrl, hint: "email@example.com (opsional)", keyboardType: TextInputType.emailAddress),
                       
                       const SizedBox(height: 16),
                       _sectionHeader(Icons.two_wheeler, "Informasi Kendaraan"),
                       _inputField("Plat Nomor *", _plateCtrl, required: true),
                        
                        // Dropdown for Vehicle Type (Mobil, Motor, Truck)
                        Padding(
                          padding: const EdgeInsets.only(bottom: 12),
                          child: DropdownButtonFormField<String>(
                            value: _selectedVehicleCategory,
                            items: ['mobil', 'motor', 'truck'].map((String val) {
                              return DropdownMenuItem<String>(
                                value: val,
                                child: Text(
                                  val[0].toUpperCase() + val.substring(1), 
                                  style: GoogleFonts.poppins(fontSize: 14),
                                ),
                              );
                            }).toList(),
                            onChanged: (val) => setState(() => _selectedVehicleCategory = val),
                            validator: (val) => (val == null || val.isEmpty) ? 'Wajib dipilih' : null, // Added validator
                            decoration: InputDecoration(
                              labelText: "Jenis Kendaraan",
                              labelStyle: GoogleFonts.poppins(fontSize: 14, color: Colors.black54),
                              hintText: "Pilih Jenis Kendaraan", // Added hint text
                              hintStyle: GoogleFonts.poppins(fontSize: 13, color: Colors.grey.shade400),
                              contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(8),
                                borderSide: BorderSide(color: Colors.grey.shade300),
                              ),
                              enabledBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(8),
                                borderSide: BorderSide(color: Colors.grey.shade300),
                              ),
                            ),
                            style: GoogleFonts.poppins(fontSize: 14, color: Colors.black87),
                          ),
                        ),

                        Row(
                          children: [
                            Expanded(child: _inputField("Merk Kendaraan", _brandCtrl, hint: "Honda, Yamaha...")),
                            const SizedBox(width: 12),
                            Expanded(child: _inputField("Model", _modelCtrl, hint: "Beat, Vario...")),
                          ],
                        ),
                       Row(
                         children: [
                           Expanded(child: _inputField("Tahun", _yearCtrl, keyboardType: TextInputType.number)),
                           const SizedBox(width: 12),
                           Expanded(child: _inputField("Odometer (km)", _odometerCtrl, keyboardType: TextInputType.number)),
                         ],
                       ),
                       
                       const SizedBox(height: 16),
                       _sectionHeader(Icons.build, "Informasi Servis"),
                       _inputField("Nama Servis *", _serviceNameCtrl, hint: "Servis Rutin, Ganti Oli...", required: true),
                       
                       // Description/Keluhan field
                       Padding(
                         padding: const EdgeInsets.only(bottom: 12),
                         child: Column(
                           crossAxisAlignment: CrossAxisAlignment.start,
                           children: [
                             Text(
                               "Keluhan / Deskripsi",
                               style: GoogleFonts.poppins(fontSize: 12, color: Colors.black54),
                             ),
                             const SizedBox(height: 6),
                             TextFormField(
                               controller: _descriptionCtrl,
                               maxLines: 3,
                               decoration: InputDecoration(
                                 hintText: "Isi keluhanmu disini....",
                                 hintStyle: GoogleFonts.poppins(fontSize: 13, color: Colors.grey.shade400),
                                 contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                                 border: OutlineInputBorder(
                                   borderRadius: BorderRadius.circular(8),
                                   borderSide: BorderSide(color: Colors.grey.shade300),
                                 ),
                                 enabledBorder: OutlineInputBorder(
                                   borderRadius: BorderRadius.circular(8),
                                   borderSide: BorderSide(color: Colors.grey.shade300),
                                 ),
                               ),
                               style: GoogleFonts.poppins(fontSize: 14, color: Colors.black87),
                             ),
                           ],
                         ),
                       ),
                       
                       // Dropdown for Category
                       Padding(
                         padding: const EdgeInsets.only(bottom: 12),
                         child: Column(
                           crossAxisAlignment: CrossAxisAlignment.start,
                           children: [
                             RichText(
                               text: TextSpan(
                                 text: "Kategori Servis",
                                 style: GoogleFonts.poppins(fontSize: 12, color: Colors.black54),
                                 children: const [
                                   TextSpan(text: ' *', style: TextStyle(color: Colors.red)),
                                 ],
                               ),
                             ),
                             const SizedBox(height: 6),
                             DropdownButtonFormField<String>(
                               value: _selectedCategory,
                               items: _categoryOptions.map((String val) {
                                 return DropdownMenuItem<String>(
                                   value: val,
                                   child: Text(
                                     val[0].toUpperCase() + val.substring(1), // Capitalize
                                     style: GoogleFonts.poppins(fontSize: 14),
                                   ),
                                 );
                               }).toList(),
                               onChanged: (val) => setState(() => _selectedCategory = val),
                               validator: (val) => (val == null || val.isEmpty) ? 'Wajib dipilih' : null,
                               decoration: InputDecoration(
                                 hintText: "Pilih Kategori",
                                 hintStyle: GoogleFonts.poppins(fontSize: 13, color: Colors.grey.shade400),
                                 contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                                 border: OutlineInputBorder(
                                   borderRadius: BorderRadius.circular(8),
                                   borderSide: BorderSide(color: Colors.grey.shade300),
                                 ),
                                 enabledBorder: OutlineInputBorder(
                                   borderRadius: BorderRadius.circular(8),
                                   borderSide: BorderSide(color: Colors.grey.shade300),
                                 ),
                               ),
                               style: GoogleFonts.poppins(fontSize: 14, color: Colors.black87),
                             ),
                           ],
                         ),
                       ),
                     ],
                   ),
                 ),
               ),
             ),
             
             // Actions
             const Divider(height: 1),
             Padding(
               padding: const EdgeInsets.all(16),
               child: Row(
                 children: [
                   Expanded(
                     child: OutlinedButton(
                       onPressed: () => Navigator.pop(context),
                       style: OutlinedButton.styleFrom(
                         padding: const EdgeInsets.symmetric(vertical: 14),
                         shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                       ),
                       child: Text("Batal", style: GoogleFonts.poppins(color: Colors.black87)),
                     ),
                   ),
                   const SizedBox(width: 12),
                   Expanded(
                     child: ElevatedButton(
                       onPressed: _loading ? null : _submit,
                       style: ElevatedButton.styleFrom(
                         padding: const EdgeInsets.symmetric(vertical: 14),
                         backgroundColor: const Color(0xFFD72B1C),
                         shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                       ),
                       child: _loading 
                         ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                         : Text("Tambah ke Antrian", style: GoogleFonts.poppins(color: Colors.white, fontWeight: FontWeight.w600)),
                     ),
                   ),
                 ],
               ),
             )
           ],
         ),
       ),
    );
  }

  Widget _sectionHeader(IconData icon, String title) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: icon == Icons.person ? Colors.blue.shade50 : icon == Icons.two_wheeler ? Colors.orange.shade50 : Colors.green.shade50,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: [
           Icon(icon, size: 18, color: Colors.grey[800]),
           const SizedBox(width: 8),
           Text(title, style: AppTextStyles.bodyMedium(color: Colors.black87).copyWith(fontWeight: FontWeight.w600)),
        ],
      ),
    );
  }

  Widget _inputField(String label, TextEditingController ctrl, {
    bool required = false, 
    String? hint, 
    TextInputType? keyboardType,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          RichText(
            text: TextSpan(
              text: label.replaceAll('*', ''),
              style: GoogleFonts.poppins(fontSize: 12, color: Colors.black54),
              children: [
                if (required) const TextSpan(text: ' *', style: TextStyle(color: Colors.red)),
              ],
            ),
          ),
          const SizedBox(height: 6),
          TextFormField(
            controller: ctrl,
            keyboardType: keyboardType,
            validator: required ? (v) => (v == null || v.trim().isEmpty) ? 'Wajib diisi' : null : null,
            decoration: InputDecoration(
              hintText: hint ?? label.replaceAll('*', '').trim(),
              hintStyle: GoogleFonts.poppins(fontSize: 13, color: Colors.grey.shade400),
              contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: BorderSide(color: Colors.grey.shade300),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: BorderSide(color: Colors.grey.shade300),
              ),
            ),
            style: GoogleFonts.poppins(fontSize: 14),
          ),
        ],
      ),
    );
  }
}
