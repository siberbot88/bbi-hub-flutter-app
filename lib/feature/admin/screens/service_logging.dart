import 'package:flutter/material.dart';

import '../widgets/service_logging/logging_summary_boxes.dart';
import '../widgets/service_logging/logging_calendar.dart';
import '../widgets/service_logging/logging_filter_tabs.dart';
import '../widgets/service_logging/logging_time_slots.dart';
import '../widgets/service_logging/logging_task_card.dart';
import '../widgets/service_logging/logging_helpers.dart';

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
  String selectedLoggingFilter = "All";
  String? selectedTimeSlot;

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
      "status": "Penjadwalaan",
    },
  ];

  final List<Map<String, dynamic>> allTasks = [
    {
      "id": "1",
      "user": "Andi",
      "date": DateTime(2025, 9, 1),
      "title": "General Checkup",
      "desc":
          "Penggantian bantalan rem lengkap dan kalibrasi sistem untuk unit excavator",
      "plate": "L 1234 XX",
      "motor": "Vario 2021",
      "status": "Pending",
      "category": "logging",
      "time": "07:00 - 08:00",
    },
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

  List<Map<String, dynamic>> _getFilteredTasks() {
    return allTasks.where((task) {
      bool dateMatch =
          LoggingHelpers.isSameDate(task['date'] as DateTime, selectedDate);
      bool categoryMatch = task['category'] == 'logging';
      if (!dateMatch || !categoryMatch) return false;

      bool statusMatch = _matchesFilterKey(task, selectedLoggingFilter);
      if (!statusMatch) return false;

      if (selectedTimeSlot != null && task['time'] != selectedTimeSlot) {
        return false;
      }

      if (searchText.trim().isNotEmpty) {
        final q = searchText.toLowerCase();
        return (task['title'] as String).toLowerCase().contains(q) ||
            (task['plate'] as String).toLowerCase().contains(q) ||
            (task['user'] as String).toLowerCase().contains(q);
      }

      return true;
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    final tasksForDate =
        allTasks.where((t) => LoggingHelpers.isSameDate(t['date'] as DateTime, selectedDate));
    
    final pending = tasksForDate
        .where((t) =>
            (t['status'] as String).toLowerCase().contains('pending'))
        .length;
    final inProgress = tasksForDate
        .where((t) =>
            (t['status'] as String).toLowerCase().contains('progress'))
        .length;
    final completed = tasksForDate
        .where((t) =>
            (t['status'] as String).toLowerCase().contains('completed'))
        .length;

    final loggingFiltered = _getFilteredTasks();
    final title = selectedTimeSlot == null
        ? "Semua Tugas"
        : "Tugas untuk jam $selectedTimeSlot";

    return SingleChildScrollView(
      padding: const EdgeInsets.only(bottom: 90),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 8),
          LoggingSummaryBoxes(
            pending: pending,
            inProgress: inProgress,
            completed: completed,
          ),
          const SizedBox(height: 12),
          LoggingCalendar(
            displayedMonth: displayedMonth,
            displayedYear: displayedYear,
            selectedDay: selectedDay,
            onPrevMonth: _prevMonth,
            onNextMonth: _nextMonth,
            onDaySelected: (day) => setState(() => selectedDay = day),
          ),
          const SizedBox(height: 12),
          _buildSearchBar(),
          const SizedBox(height: 12),
          LoggingFilterTabs(
            selectedFilter: selectedLoggingFilter,
            onFilterChanged: (filter) =>
                setState(() => selectedLoggingFilter = filter),
          ),
          const SizedBox(height: 12),
          if (selectedLoggingFilter == "All") ...[
            LoggingTimeSlots(
              timeSlots: availableTimeSlots,
              selectedTimeSlot: selectedTimeSlot,
              onTimeSlotSelected: (slot) =>
                  setState(() => selectedTimeSlot = slot),
            ),
            const SizedBox(height: 12),
          ],
          _buildLoggingContent(title, loggingFiltered),
        ],
      ),
    );
  }

  Widget _buildSearchBar() {
    return Padding(
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
    );
  }

  Widget _buildLoggingContent(
      String title, List<Map<String, dynamic>> filtered) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 12),
          if (filtered.isEmpty)
            const Center(
              child: Padding(
                padding: EdgeInsets.all(24.0),
                child: Text(
                  "Tidak ada tugas yang sesuai dengan filter.",
                  textAlign: TextAlign.center,
                  style: TextStyle(color: Colors.grey),
                ),
              ),
            )
          else
            ...filtered.map((t) => LoggingTaskCard(task: t)),
        ],
      ),
    );
  }

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