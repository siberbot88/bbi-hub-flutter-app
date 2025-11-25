import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
// untuk navigasi ke Scheduled
import 'service_pending.dart' as pending;
import 'service_progress.dart' as progress;
import 'service_complete.dart' as complete;

class ServiceLoggingPage extends StatefulWidget {
  const ServiceLoggingPage({super.key});

  @override
  State<ServiceLoggingPage> createState() => _ServiceLoggingPageState();
}

class _ServiceLoggingPageState extends State<ServiceLoggingPage> {
  int displayedMonth = DateTime.now().month;
  int displayedYear = DateTime.now().year;
  int selectedDay = DateTime.now().day;

  String searchText = "";
  String selectedLoggingFilter = "All"; // default All


  String? selectedTimeSlot; // slot waktu yang dipilih, null jika tidak ada
  
// dummy time slots
  final List<Map<String, dynamic>> availableTimeSlots = [
    {
      "time": "08:00 - 10:00",
      "tasks": 4,
      "status": "Aktif",
    },
    {
      "time": "10:00 - 12:00",
      "tasks": 2,
      "status": "Akan Datang",
    },
    {
      "time": "14:00 - 15:30",
      "tasks": 5,
      "status": "Penjadwalan",
    },
  ];


  // Dummy data for tasks/logs

  final List<Map<String, dynamic>> allTasks = [

    // Pending dummy 1
    {
      "id": "1",
      "user": "Andi",
      "date": DateTime(2025, 9, 1),
      "title": "General Checkup",
      "desc": "Penggantian bantalan rem lengkap dan kalibrasi sistem untuk unit excavator",
      "plate": "L 1234 XX",
      "motor": "Vario 2021",
      "status": "Pending",
      "category": "logging",
      "time": "07:00 - 08:00",
    },
    // Pending dummy 2
    {
      "id": "4",
      "user": "Rina",
      "date": DateTime(2025, 9, 1),
      "title": "Electrical Inspection",
      "desc": "Check battery and wiring",
      "plate": "D 5678 YY",
      "motor": "NMAX 2019",
      "status": "Pending",
      "category": "logging",
      "time": "07:30 - 08:30",
    },
    // In Progress
    {
      "id": "2",
      "user": "Siti",
      "date": DateTime(2025, 9, 2),
      "title": "Brake System Maintenance",
      "desc": "Complete brake pad replacement and calibration",
      "plate": "SU 814 NTO",
      "motor": "BEAT 2012",
      "status": "In Progress",
      "category": "logging",
      "time": "08:00 - 10:00",
    },
    // Completed
    {
      "id": "3",
      "user": "Budi",
      "date": DateTime(2025, 9, 4),
      "title": "Tire Replacement",
      "desc": "Full tire replacement for Yamaha 2018",
      "plate": "AB 1111",
      "motor": "Yamaha 2018",
      "status": "Completed",
      "category": "logging",
      "time": "10:00 - 12:00",
    },
  ];

  DateTime get selectedDate =>
      DateTime(displayedYear, displayedMonth, selectedDay);

  bool isSameDate(DateTime a, DateTime b) =>
      a.year == b.year && a.month == b.month && a.day == b.day;

  int daysInMonth(int year, int month) =>
      DateTime(year, month + 1, 0).day;

  bool _matchesFilterKey(Map<String, dynamic> t, String filterKey) {
    if (filterKey == 'All') return true;
    final status = (t['status'] as String).toLowerCase();
    switch (filterKey) {
      case 'Pending':
        return status.contains('pending');
      case 'In Progress':
        return status.contains('progress');
      case 'Completed':
        return status.contains('completed');
      default:
        return false;
    }
  }

  @override
  Widget build(BuildContext context) {
  return SingleChildScrollView(
  padding: const EdgeInsets.only(bottom: 90),
  child: Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      const SizedBox(height: 8),

      // Summary Boxes
      _summaryBoxes(),
      const SizedBox(height: 12),

      // Kalender
      _calendarBar(),
      const SizedBox(height: 12),

      // Search bar
      Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: BoxDecoration(
            color: Colors.grey[200],
            borderRadius: BorderRadius.circular(12),
          ),
          child: Row(
            children: [
              const Icon(Icons.search, color: Colors.grey),
              const SizedBox(width: 8),
              Expanded(
                child: TextField(
                  decoration: const InputDecoration.collapsed(
                    hintText: "Search logging...",
                  ),
                  onChanged: (val) => setState(() => searchText = val),
                ),
              ),
              IconButton(
                icon: const Icon(Icons.filter_list, color: Colors.grey),
                onPressed: () {},
              ),
            ],
          ),
        ),
      ),

      const SizedBox(height: 12),

      _buildFilterTabs(),
      const SizedBox(height: 12),

      // Hanya tampilkan container "Waktu Tersedia" jika filter "All" dipilih
      if (selectedLoggingFilter == "All") ...[
        _buildAvailableTimes(),
        const SizedBox(height: 12),
      ],

      _loggingContent(),
    ],
  ),
);

  }

  // 🔹 Summary Boxes
  Widget _summaryBoxes() {
    final pending = allTasks.where((t) =>
        (t['status'] as String).toLowerCase().contains('pending') &&
        isSameDate(t['date'] as DateTime, selectedDate)).length;
    final inProgress = allTasks.where((t) =>
        (t['status'] as String).toLowerCase().contains('progress') &&
        isSameDate(t['date'] as DateTime, selectedDate)).length;
    final completed = allTasks.where((t) =>
        (t['status'] as String).toLowerCase().contains('completed') &&
        isSameDate(t['date'] as DateTime, selectedDate)).length;

    Widget buildBox(String label, int count, Color color) {
      return Expanded(
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 12),
          margin: const EdgeInsets.symmetric(horizontal: 4),
          decoration: BoxDecoration(
            color: Colors.white,
            border: Border.all(color: color.withOpacity(0.6), width: 1.5),
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(color: Colors.black.withOpacity(0.02), blurRadius: 4)
            ],
          ),
          child: Column(
            children: [
              Text("$count",
                  style: GoogleFonts.poppins(
                      fontSize: 20, fontWeight: FontWeight.bold, color: color)),
              const SizedBox(height: 6),
              Text(label,
                  style: GoogleFonts.poppins(
                      fontSize: 12, fontWeight: FontWeight.w600, color: color)),
            ],
          ),
        ),
      );
    }

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(children: [
        buildBox("Pending", pending, Colors.blue),
        buildBox("In Progress", inProgress, Colors.orange),
        buildBox("Completed", completed, Colors.green),
      ]),
    );
  }

  // 🔹 Calendar
  Widget _calendarBar() {
    return Column(children: [
      Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: Row(children: [
          Text("${_monthName(displayedMonth)} $displayedYear",
              style: GoogleFonts.poppins(
                  fontWeight: FontWeight.bold, fontSize: 16)),
          const Spacer(),
          IconButton(
              icon: const Icon(Icons.chevron_left, size: 20),
              onPressed: _prevMonth),
          IconButton(
              icon: const Icon(Icons.chevron_right, size: 20),
              onPressed: _nextMonth),
        ]),
      ),
      SizedBox(
        height: 80,
        child: ListView.builder(
          scrollDirection: Axis.horizontal,
          padding: const EdgeInsets.symmetric(horizontal: 16),
          itemCount: daysInMonth(displayedYear, displayedMonth),
          itemBuilder: (context, index) {
            final day = index + 1;
            final dt = DateTime(displayedYear, displayedMonth, day);
            final isSelected = isSameDate(dt, selectedDate);
            return GestureDetector(
              onTap: () => setState(() => selectedDay = day),
              child: Container(
                width: 60,
                margin:
                    const EdgeInsets.symmetric(horizontal: 4, vertical: 8),
                decoration: BoxDecoration(
                  color: isSelected ? Colors.red[100] : Colors.grey[200],
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                      color: isSelected ? Colors.red : Colors.transparent,
                      width: 2),
                ),
                child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(_weekdayShort(dt.weekday),
                          style: GoogleFonts.poppins(
                              fontWeight: FontWeight.bold, fontSize: 12)),
                      const SizedBox(height: 6),
                      Text("$day",
                          style: GoogleFonts.poppins(
                              fontSize: 16, fontWeight: FontWeight.bold)),
                    ]),
              ),
            );
          },
        ),
      ),
    ]);
  }

  // 🔹 Filter Tabs
  Widget _buildFilterTabs() {
    final tabs = ["All", "Pending", "In Progress", "Completed"];
    return SizedBox(
      height: 40,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        itemCount: tabs.length,
        separatorBuilder: (_, __) => const SizedBox(width: 8),
        itemBuilder: (context, index) {
          final tab = tabs[index];
          final active = selectedLoggingFilter == tab;
          return GestureDetector(
            onTap: () => setState(() => selectedLoggingFilter = tab),
            child: Container(
              padding:
                  const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                color: active ? const Color(0xFFB70F0F) : Colors.grey[200],
                borderRadius: BorderRadius.circular(20),
              ),
              child: Center(
                child: Text(
                  tab,
                  style: GoogleFonts.poppins(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: active ? Colors.white : Colors.black87),
                ),
              ),
            ),
          );
        },
      ),
    );
  }



  // Letakkan method-method ini di dalam class _ServiceLoggingPageState

// Method untuk membangun container utama "Waktu Tersedia"
Widget _buildAvailableTimes() {
  return Padding(
    padding: const EdgeInsets.symmetric(horizontal: 16),
    child: Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 6,
            offset: const Offset(0, 3),
          )
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "Waktu tersedia",
            style: GoogleFonts.poppins(
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 12),
          ...availableTimeSlots.map((slot) => _buildTimeSlotCard(slot)),
        ],
      ),
    ),
  );
}

// Method untuk membangun setiap kartu/baris slot waktu
// Ganti method _buildTimeSlotCard yang lama dengan yang ini
Widget _buildTimeSlotCard(Map<String, dynamic> slot) {
  final String status = slot['status'];
  final String time = slot['time'];
  final bool isSelected = selectedTimeSlot == time; // Cek apakah slot ini sedang dipilih

  Color dotColor, statusColor, bgColor, borderColor;

  switch (status) {
    case 'Aktif':
      dotColor = const Color(0xFF007BFF);
      statusColor = const Color(0xFF007BFF);
      bgColor = isSelected ? const Color(0xFF007BFF).withOpacity(0.2) : const Color(0xFF007BFF).withOpacity(0.1);
      break;
    case 'Akan Datang':
      dotColor = Colors.orange;
      statusColor = Colors.orange;
      bgColor = isSelected ? Colors.orange.withOpacity(0.2) : Colors.grey.shade100;
      break;
    case 'Penjadwalaan':
    default:
      dotColor = Colors.grey.shade600;
      statusColor = Colors.black87;
      bgColor = isSelected ? Colors.grey.shade300 : Colors.grey.shade100;
      break;
  }
  
  // Tentukan warna border jika terpilih
  borderColor = isSelected ? dotColor : Colors.transparent;

  return GestureDetector( // Dibungkus GestureDetector agar bisa di-tap
    onTap: () {
      setState(() {
        // Logika untuk memilih dan membatalkan pilihan
        if (isSelected) {
          selectedTimeSlot = null; // Jika sudah terpilih, batalkan pilihan
        } else {
          selectedTimeSlot = time; // Jika belum, pilih slot ini
        }
      });
    },
    child: Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      margin: const EdgeInsets.only(bottom: 8),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: borderColor, width: 1.5), // Border dinamis
      ),
      child: Row(
        // ... (Isi Row tetap sama seperti sebelumnya)
        children: [
          Container(
            width: 10,
            height: 10,
            decoration: BoxDecoration(
              color: dotColor,
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  slot['time'],
                  style: GoogleFonts.poppins(
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                  ),
                ),
                Text(
                  "${slot['tasks']} tasks scheduled",
                  style: GoogleFonts.poppins(
                    color: Colors.grey.shade600,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
          Text(
            status,
            style: GoogleFonts.poppins(
              color: statusColor,
              fontWeight: FontWeight.w600,
              fontSize: 13,
            ),
          )
        ],
      ),
    ),
  );
}

  // 🔹 Logging Content
Widget _loggingContent() {
  // Rantai filter menjadi lebih efisien dan mudah dibaca
  final List<Map<String, dynamic>> loggingFiltered = allTasks.where((task) {
    // 1. Filter berdasarkan tanggal dan kategori
    bool dateMatch = isSameDate(task['date'] as DateTime, selectedDate);
    bool categoryMatch = task['category'] == 'logging';
    if (!dateMatch || !categoryMatch) return false;

    // 2. Filter berdasarkan tab status (All, Pending, dll.)
    bool statusMatch = _matchesFilterKey(task, selectedLoggingFilter);
    if (!statusMatch) return false;

    // 3. Filter berdasarkan slot waktu yang dipilih
    if (selectedTimeSlot != null && task['time'] != selectedTimeSlot) {
      return false;
    }

    // 4. Filter berdasarkan teks pencarian
    if (searchText.trim().isNotEmpty) {
      final q = searchText.toLowerCase();
      return (task['title'] as String).toLowerCase().contains(q) ||
             (task['plate'] as String).toLowerCase().contains(q) ||
             (task['user'] as String).toLowerCase().contains(q);
    }

    return true; // Lolos semua filter
  }).toList();

  // Judul dinamis
  final String title = selectedTimeSlot == null
      ? "Semua Tugas"
      : "Tugas untuk jam $selectedTimeSlot";

  return Padding(
    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title, // Menggunakan judul dinamis
          style: GoogleFonts.poppins(
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 12),
        if (loggingFiltered.isEmpty)
          Center(
            child: Padding(
              padding: const EdgeInsets.all(24.0),
              child: Text(
                "Tidak ada tugas yang sesuai dengan filter.",
                textAlign: TextAlign.center,
                style: GoogleFonts.poppins(color: Colors.grey.shade600),
              ),
            ),
          )
        else
          ...loggingFiltered.map((t) => taskLoggingCard(t)),
      ],
    ),
  );
}

  // 🔹 Task card per type pending/inprogress/completed
Widget taskLoggingCard(Map<String, dynamic> task) {
  Color statusColor;
  final status = (task['status'] as String); // Tidak perlu toLowerCase() di sini

  if (status == "Completed") {
    statusColor = Colors.green;
  } else if (status == "In Progress") statusColor = Colors.orange;
  else if (status == "Pending") statusColor = Colors.grey.shade800;
  else statusColor = Colors.grey.shade800;

  // --- BAGIAN BARU DIMULAI DARI SINI ---

  // 1. Deklarasikan sebuah variabel Widget untuk menampung tombol aksi
  Widget actionButton;

  // 2. Gunakan if-else-if untuk mengisi variabel 'actionButton' berdasarkan status
  if (status == 'Pending') {
    actionButton = ElevatedButton(
      onPressed: () {
        Navigator.push(context, MaterialPageRoute(
          builder: (_) => pending.ServicePendingDetail(task: task),
        ));
      },
      style: ElevatedButton.styleFrom(
        backgroundColor: const Color(0xFFDC2626),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
      ),
      child: const Text("Tetapkan Mekanik", style: TextStyle(fontSize: 12, color: Colors.white)),
    );
  } else if (status == 'In Progress') {
    actionButton = ElevatedButton(
      onPressed: () {
        Navigator.push(context, MaterialPageRoute(
          builder: (_) => progress.ServiceProgressDetail(task: task),
        ));
      },
      style: ElevatedButton.styleFrom(
        backgroundColor: Colors.orange,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
      ),
      child: const Text("Lihat Detail", style: TextStyle(fontSize: 12, color: Colors.white)),
    );
  } else if (status == 'Completed') {
    actionButton = ElevatedButton(
      onPressed: () {
        Navigator.push(context, MaterialPageRoute(
          builder: (_) => complete.ServiceCompleteDetail(task: task),
        ));
      },
      style: ElevatedButton.styleFrom(
        backgroundColor: Colors.green,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
      ),
      child: const Text("Buat Invoice", style: TextStyle(fontSize: 12, color: Colors.white)),
    );
  } else {
    // Fallback jika status tidak dikenali
    actionButton = const SizedBox.shrink();
  }

  // --- BAGIAN BARU SELESAI DI SINI ---

  return Container(
    margin: const EdgeInsets.only(bottom: 12),
    padding: const EdgeInsets.all(12),
    decoration: BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(12),
      boxShadow: [
        BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 6,
            offset: const Offset(0, 3))
      ],
    ),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // ... Bagian atas kartu (Status, Judul, Deskripsi, dll.) tetap sama ...
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                  color: statusColor.withOpacity(0.3),
                  borderRadius: BorderRadius.circular(20)),
              child: Text(task['status'],
                  style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: statusColor)),
            ),
            Text(
                "${_formatDate(task['date'] as DateTime)} • ${task['time']}",
                style: const TextStyle(
                    fontSize: 12,
                    color: Colors.grey,
                    fontWeight: FontWeight.w500)),
          ],
        ),
        const SizedBox(height: 8),
        Text(task['title'],
            style:
                const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
        const SizedBox(height: 4),
        Text(task['desc'],
            style: const TextStyle(fontSize: 12, color: Colors.black87)),
        const SizedBox(height: 8),
        Row(
          children: [
            const Icon(Icons.settings, size: 16, color: Colors.grey),
            const SizedBox(width: 6),
            Text("${task['motor']}  #${task['plate']}",
                style: const TextStyle(fontSize: 12, color: Colors.grey)),
          ],
        ),
        const SizedBox(height: 10),

        // User info + Button
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              children: [
                CircleAvatar(
                    radius: 14,
                    backgroundImage: NetworkImage(
                        "https://i.pravatar.cc/150?img=${task['id']}")),
                const SizedBox(width: 8),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(task['user'],
                        style: const TextStyle(
                            fontSize: 13, fontWeight: FontWeight.w600)),
                    Text("ID: ${task['id']}",
                        style: const TextStyle(
                            fontSize: 11, color: Colors.grey)),
                  ],
                ),
              ],
            ),
            
            // 3. Gunakan variabel 'actionButton' yang sudah diisi
            actionButton,

          ],
        ),
      ],
    ),
  );
}
  // 🔹 Utils
  String _formatDate(DateTime d) =>
      "${d.day} ${_monthName(d.month)} ${d.year}";
  String _monthName(int m) => [
        "",
        "January",
        "February",
        "March",
        "April",
        "May",
        "June",
        "July",
        "August",
        "September",
        "October",
        "November",
        "December"
      ][m];
  String _weekdayShort(int wd) =>
      ["", "MON", "TUE", "WED", "THU", "FRI", "SAT", "SUN"][wd];

  void _prevMonth() => setState(() {
        displayedMonth -= 1;
        if (displayedMonth < 1) {
          displayedMonth = 12;
          displayedYear -= 1;
        }
        selectedDay = 1;
      });

  void _nextMonth() => setState(() {
        displayedMonth += 1;
        if (displayedMonth > 12) {
          displayedMonth = 1;
          displayedYear += 1;
        }
        selectedDay = 1;
      });
}