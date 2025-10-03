import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../widgets/bottom_nav.dart';
import '../widgets/custom_header.dart';
import 'service_page.dart'; // untuk navigasi ke Scheduled
import 'service_view_report.dart'; // halaman target untuk "View Report"

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

  final List<Map<String, dynamic>> allTasks = [
    // Pending dummy 1
    {
      "id": "1",
      "user": "Andi",
      "date": DateTime(2025, 9, 1),
      "title": "General Checkup",
      "desc": "Initial diagnosis pending approval",
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
    return Scaffold(
      appBar: const CustomHeader(
        title: "Service",
        showBack: false,
      ),

      body: SingleChildScrollView(
        padding: const EdgeInsets.only(bottom: 90),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 8),

            // 🔹 Tab Scheduled & Logging
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Row(
                children: [
                  // Scheduled tab
                  Expanded(
                    child: GestureDetector(
                      onTap: () {
                        Navigator.pushReplacement(
                          context,
                          MaterialPageRoute(builder: (_) => const ServicePage()),
                        );
                      },
                      child: Container(
                        padding: const EdgeInsets.symmetric(vertical: 10),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(color: const Color(0xFFB70F0F), width: 2),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Icon(Icons.calendar_today,
                                size: 18, color: Color(0xFFB70F0F)),
                            const SizedBox(width: 6),
                            Text("Scheduled",
                                style: GoogleFonts.poppins(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w600,
                                    color: const Color(0xFFB70F0F))),
                          ],
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  // Logging tab aktif
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
                          const Icon(Icons.show_chart, size: 18, color: Colors.white),
                          const SizedBox(width: 6),
                          Text("Logging",
                              style: GoogleFonts.poppins(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w600,
                                  color: Colors.white)),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 12),

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
                    borderRadius: BorderRadius.circular(12)),
                child: Row(children: [
                  const Icon(Icons.search, color: Colors.grey),
                  const SizedBox(width: 8),
                  Expanded(
                    child: TextField(
                      decoration: const InputDecoration.collapsed(
                          hintText: "Search logging..."),
                      onChanged: (val) => setState(() => searchText = val),
                    ),
                  ),
                  IconButton(
                      icon: const Icon(Icons.filter_list, color: Colors.grey),
                      onPressed: () {}),
                ]),
              ),
            ),

            const SizedBox(height: 12),

            _buildFilterTabs(),
            const SizedBox(height: 12),

            _loggingContent(),
          ],
        ),
      ),

      bottomNavigationBar: CustomBottomNavBar(
        selectedIndex: 1,
        onTap: (i) {
          if (i == 0) Navigator.pushReplacementNamed(context, '/home');
          else if (i == 1) Navigator.pushReplacementNamed(context, '/service');
          else if (i == 2) Navigator.pushReplacementNamed(context, '/dashboard');
          else if (i == 3) Navigator.pushReplacementNamed(context, '/profile');
        },
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

  // 🔹 Logging Content
  Widget _loggingContent() {
    final loggingAll = allTasks
        .where((t) =>
            isSameDate(t['date'] as DateTime, selectedDate) &&
            t['category'] == 'logging')
        .toList();

    final loggingFiltered = loggingAll.where((t) {
      if (selectedLoggingFilter == 'All') return true;
      return _matchesFilterKey(t, selectedLoggingFilter);
    }).where((t) {
      if (searchText.trim().isEmpty) return true;
      final q = searchText.toLowerCase();
      return (t['title'] as String).toLowerCase().contains(q) ||
          (t['plate'] as String).toLowerCase().contains(q) ||
          (t['user'] as String).toLowerCase().contains(q);
    }).toList();

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text("Logging Tasks",
              style: GoogleFonts.poppins(
                  fontSize: 16, fontWeight: FontWeight.bold)),
          const SizedBox(height: 12),
          if (loggingFiltered.isEmpty)
            Center(
                child: Text("No tasks match the filters",
                    style: GoogleFonts.poppins()))
          else
            ...loggingFiltered.map((t) => taskLoggingCard(t)).toList(),
        ],
      ),
    );
  }

  // 🔹 Task card
  Widget taskLoggingCard(Map<String, dynamic> task) {
    Color statusColor;
    final status = (task['status'] as String).toLowerCase();
    if (status.contains("completed")) statusColor = Colors.green;
    else if (status.contains("progress")) statusColor = Colors.orange;
    else if (status.contains("pending")) statusColor = Colors.blue;
    else statusColor = Colors.grey;

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
          // Status and date/time
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                    color: statusColor.withOpacity(0.12),
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

          // Title
          Text(task['title'],
              style:
                  const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
          const SizedBox(height: 4),

          // Desc
          Text(task['desc'],
              style: const TextStyle(fontSize: 12, color: Colors.black87)),
          const SizedBox(height: 8),

          // Motor info
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
              ElevatedButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (_) => ServiceViewReportPage(task: task)),
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20)),
                  padding:
                      const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                ),
                child: const Text("View Report",
                    style: TextStyle(fontSize: 12, color: Colors.white)),
              ),
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
