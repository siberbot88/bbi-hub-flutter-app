import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'service_logging.dart';
import 'service_detail.dart';
import '../widgets/custom_header.dart';
import '../widgets/reject_dialog.dart';
import '../widgets/accept_dialog.dart';

class ServicePage extends StatefulWidget {
  const ServicePage({super.key});

  @override
  State<ServicePage> createState() => _ServicePageState();
}

class _ServicePageState extends State<ServicePage> {
  int displayedMonth = DateTime.now().month;
  int displayedYear = DateTime.now().year;
  int selectedDay = DateTime.now().day;
  String selectedFilter = "All";

  final List<Map<String, dynamic>> allTasks = [
    {
      "id": "1",
      "name": "Prabowo",
      "date": DateTime(2025, 9, 2),
      "service": "Engine Oil Change",
      "plate": "SU 814 NTO",
      "motor": "BEAT 2012",
      "vehicleCategory": "Sepeda Motor", // 🔹 kategori kendaraan
      "location": "WORKSHOP",
      "status": "Waiting",
    },
    {
      "id": "2",
      "name": "Ayu",
      "date": DateTime(2025, 9, 4),
      "service": "Battery Check",
      "plate": "XY 9999",
      "motor": "Honda 2020",
      "vehicleCategory": "Mobil", // 🔹 kategori kendaraan
      "location": "ON-SITE",
      "status": "Accept",
    },
  ];

  DateTime get selectedDate =>
      DateTime(displayedYear, displayedMonth, selectedDay);

  bool isSameDate(DateTime a, DateTime b) =>
      a.year == b.year && a.month == b.month && a.day == b.day;

  int daysInMonth(int year, int month) => DateTime(year, month + 1, 0).day;

  bool _matchesFilterKey(Map<String, dynamic> t, String filterKey) {
    if (filterKey == 'All') return true;
    return (t['status'] as String).toLowerCase() == filterKey.toLowerCase();
  }

  int _countTasks(String filterKey) {
    return allTasks
        .where((t) =>
            isSameDate(t['date'] as DateTime, selectedDate) &&
            _matchesFilterKey(t, filterKey))
        .length;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: const CustomHeader(
        title: "Service",
        showBack: false,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.only(bottom: 80),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 8),
            // 🔹 Tab Scheduled & Logging
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Row(
                children: [
                  // Scheduled aktif
                  Expanded(
                    child: Container(
                      padding: const EdgeInsets.symmetric(vertical: 10),
                      decoration: BoxDecoration(
                        color: const Color(0xFFB70F0F),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(Icons.calendar_today,
                              size: 18, color: Colors.white),
                          const SizedBox(width: 6),
                          Text("Scheduled",
                              style: GoogleFonts.poppins(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w600,
                                  color: Colors.white)),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  // Logging pasif
                  Expanded(
                    child: GestureDetector(
                      onTap: () {
                        Navigator.pushReplacement(
                          context,
                          MaterialPageRoute(
                              builder: (_) => const ServiceLoggingPage()),
                        );
                      },
                      child: Container(
                        padding: const EdgeInsets.symmetric(vertical: 10),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(
                              color: const Color(0xFFB70F0F), width: 2),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Icon(Icons.show_chart,
                                size: 18, color: Color(0xFFB70F0F)),
                            const SizedBox(width: 6),
                            Text("Logging",
                                style: GoogleFonts.poppins(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w600,
                                    color: const Color(0xFFB70F0F))),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 16),

            _calendarSection(),
            const SizedBox(height: 12),
            _scheduledList(),
          ],
        ),
      ),
    );
  }

  Widget _scheduledList() {
    final scheduled = allTasks
        .where((t) => isSameDate(t['date'] as DateTime, selectedDate))
        .where((t) => _matchesFilterKey(t, selectedFilter))
        .toList();

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: scheduled.isEmpty
          ? Center(
              child: Text("No scheduled tasks", style: GoogleFonts.poppins()))
          : Column(
              children: scheduled
                  .map((t) => _serviceCardFromMap(context, t))
                  .toList(),
            ),
    );
  }

  Widget _calendarSection() {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Row(
            children: [
              Text(
                "${_monthName(displayedMonth)} $displayedYear",
                style: GoogleFonts.poppins(
                    fontWeight: FontWeight.bold, fontSize: 16),
              ),
              const Spacer(),
              IconButton(
                icon: const Icon(Icons.chevron_left, size: 20),
                onPressed: _prevMonth,
              ),
              IconButton(
                icon: const Icon(Icons.chevron_right, size: 20),
                onPressed: _nextMonth,
              ),
            ],
          ),
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
                      width: 2,
                    ),
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        _weekdayShort(dt.weekday),
                        style: GoogleFonts.poppins(
                            fontWeight: FontWeight.bold, fontSize: 12),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        "$day",
                        style: GoogleFonts.poppins(
                            fontSize: 16, fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _serviceCardFromMap(BuildContext context, Map<String, dynamic> t) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 6,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 🔹 User + Date Order + Scheduled
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              CircleAvatar(
                radius: 18,
                backgroundImage:
                    NetworkImage("https://i.pravatar.cc/150?img=${t['id']}"),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(t['name'],
                        style: GoogleFonts.poppins(
                            fontWeight: FontWeight.w600, fontSize: 14)),
                    Text("ID: ${t['id']}",
                        style: GoogleFonts.poppins(
                            fontSize: 12, color: Colors.grey[600])),
                  ],
                ),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(_formatDate(t['date'] as DateTime),
                      style: GoogleFonts.poppins(
                          fontSize: 12, color: Colors.grey[700])),
                  Text("Scheduled : 7 September 2025",
                      style: GoogleFonts.poppins(
                          fontSize: 12, color: Colors.grey[600])),
                ],
              )
            ],
          ),

          const SizedBox(height: 10),

          // 🔹 Service Title + Category Kendaraan
          Row(
            children: [
              Expanded(
                child: Text(
                  t['service'],
                  style: GoogleFonts.poppins(
                      fontSize: 16, fontWeight: FontWeight.bold),
                ),
              ),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color:
                      _getVehicleBgColor(t['vehicleCategory']).withOpacity(0.2),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  t['vehicleCategory'] ?? "Unknown",
                  style: GoogleFonts.poppins(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: _getVehicleTextColor(t['vehicleCategory'])),
                ),
              )
            ],
          ),

          const SizedBox(height: 12),

          // 🔹 Plat + Motor + Buttons
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text("Plat Nomor",
                      style: GoogleFonts.poppins(
                          fontSize: 12, color: Colors.grey)),
                  Text(t['plate'],
                      style: GoogleFonts.poppins(
                          fontSize: 15, fontWeight: FontWeight.w600)),
                  const SizedBox(height: 10),
                  Row(
                    children: [
                      // 🔹 Tombol Tolak
                      Builder(
                        builder: (ctx) => ElevatedButton(
                          onPressed: () => showRejectDialog(ctx),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.red.shade700, // merah tua
                            padding: const EdgeInsets.symmetric(
                                horizontal: 20, vertical: 12),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(30),
                            ),
                          ),
                          child: Text(
                            "Tolak",
                            style: GoogleFonts.poppins(
                              // 🔹 pakai poppins
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),

                      // 🔹 Tombol Terima
                      ElevatedButton(
                        onPressed: () => showAcceptDialog(context),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.green.shade700, // hijau tua
                          padding: const EdgeInsets.symmetric(
                              horizontal: 20, vertical: 12),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(30),
                          ),
                        ),
                        child: Text(
                          "Terima",
                          style: GoogleFonts.poppins(
                            // 🔹 pakai poppins
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ],
                  )
                ],
              ),

              // 🔹 Type Motor + Detail
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text("Type Motor",
                      style: GoogleFonts.poppins(
                          fontSize: 12, color: Colors.grey)),
                  Text(t['motor'],
                      style: GoogleFonts.poppins(
                          fontSize: 15, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 10),
                  ElevatedButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (_) => ServiceDetailPage(task: t)),
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.orange,
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(30)),
                    ),
                    child: Text(
                      "Detail",
                      style: GoogleFonts.poppins(
                        // 🔹 pakai poppins
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ],
              )
            ],
          )
        ],
      ),
    );
  }

  /// 🔹 Helper untuk warna kategori kendaraan
  Color _getVehicleBgColor(String? category) {
    switch (category?.toLowerCase()) {
      case "sepeda motor":
        return Colors.red.shade100; // background pink muda
      case "mobil":
        return Colors.orange.shade200; // background orange muda
      default:
        return Colors.grey.shade300;
    }
  }

  Color _getVehicleTextColor(String? category) {
    switch (category?.toLowerCase()) {
      case "sepeda motor":
        return Colors.red.shade700; // teks merah tua
      case "mobil":
        return Colors.orange.shade800; // teks orange gelap
      default:
        return Colors.black87;
    }
  }

  String _formatDate(DateTime d) => "${d.day} ${_monthName(d.month)} ${d.year}";

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
