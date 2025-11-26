import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'service_logging.dart';
import '../widgets/custom_header.dart';
import '../widgets/service/service_tab_selector.dart';
import '../widgets/service/service_calendar_section.dart';
import '../widgets/service/service_card.dart';
import '../widgets/service/service_helpers.dart';

class ServicePageAdmin extends StatefulWidget {
  const ServicePageAdmin({super.key});

  @override
  State<ServicePageAdmin> createState() => _ServicePageAdminState();
}

class _ServicePageAdminState extends State<ServicePageAdmin> {
  int displayedMonth = DateTime.now().month;
  int displayedYear = DateTime.now().year;
  int selectedDay = DateTime.now().day;
  String selectedFilter = "All";
  int selectedTab = 0; // 0 = Scheduled, 1 = Logging

  final List<Map<String, dynamic>> allTasks = [
    {
      "id": "1",
      "name": "Prabowo",
      "date": DateTime(2025, 9, 2),
      "service": "Engine Oil Change",
      "plate": "SU 814 NTO",
      "motor": "BEAT 2012",
      "vehicleCategory": "Sepeda Motor",
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
      "vehicleCategory": "Mobil",
      "location": "ON-SITE",
      "status": "Accept",
    },
  ];

  DateTime get selectedDate =>
      DateTime(displayedYear, displayedMonth, selectedDay);

  bool _matchesFilterKey(Map<String, dynamic> t, String filterKey) {
    if (filterKey == 'All') return true;
    return (t['status'] as String).toLowerCase() == filterKey.toLowerCase();
  }

  List<Map<String, dynamic>> _getScheduledTasks() {
    return allTasks
        .where((t) =>
            ServiceHelpers.isSameDate(t['date'] as DateTime, selectedDate))
        .where((t) => _matchesFilterKey(t, selectedFilter))
        .toList();
  }

  void _prevMonth() => setState(() {
        displayedMonth--;
        if (displayedMonth < 1) {
          displayedMonth = 12;
          displayedYear--;
        }
        selectedDay = 1;
      });

  void _nextMonth() => setState(() {
        displayedMonth++;
        if (displayedMonth > 12) {
          displayedMonth = 1;
          displayedYear++;
        }
        selectedDay = 1;
      });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: const CustomHeader(
        title: "Service",
        showBack: false,
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 8),
          ServiceTabSelector(
            selectedTab: selectedTab,
            onTabChanged: (index) => setState(() => selectedTab = index),
          ),
          Expanded(
            child: IndexedStack(
              index: selectedTab,
              children: [
                _buildScheduledTab(),
                const ServiceLoggingPage(),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildScheduledTab() {
    final scheduled = _getScheduledTasks();

    return SingleChildScrollView(
      padding: const EdgeInsets.only(bottom: 80),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 16),
          ServiceCalendarSection(
            displayedMonth: displayedMonth,
            displayedYear: displayedYear,
            selectedDay: selectedDay,
            onPrevMonth: _prevMonth,
            onNextMonth: _nextMonth,
            onDaySelected: (day) => setState(() => selectedDay = day),
          ),
          const SizedBox(height: 12),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: scheduled.isEmpty
                ? Center(
                    child: Text("No scheduled tasks",
                        style: GoogleFonts.poppins()))
                : Column(
                    children:
                        scheduled.map((t) => ServiceCard(task: t)).toList(),
                  ),
          ),
        ],
      ),
    );
  }
}
