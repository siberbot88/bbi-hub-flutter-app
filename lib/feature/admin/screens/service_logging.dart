import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import 'package:google_fonts/google_fonts.dart';

import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import 'package:bengkel_online_flutter/feature/admin/providers/admin_service_provider.dart';
import 'package:bengkel_online_flutter/core/services/auth_provider.dart';
import 'package:bengkel_online_flutter/core/models/service.dart';
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

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _fetchData();
    });
  }

  void _fetchData() {
    final auth = context.read<AuthProvider>();
    final workshopUuid = auth.user?.workshopUuid;
    final startOfDay = DateTime(displayedYear, displayedMonth, selectedDay, 0, 0, 0);
    final endOfDay = DateTime(displayedYear, displayedMonth, selectedDay, 23, 59, 59);

    final dateFrom = DateFormat('yyyy-MM-dd HH:mm:ss').format(startOfDay);
    final dateTo = DateFormat('yyyy-MM-dd HH:mm:ss').format(endOfDay);
    
    context.read<AdminServiceProvider>().fetchServices(
      dateFrom: dateFrom,
      dateTo: dateTo,
      workshopUuid: workshopUuid,
      // We don't limit by status here because logging page shows Pending (Mechanic), In Progress, and Completed.
      // But we MUST exclude those that are NOT accepted yet (handled in filtering later).
    );
  }

  DateTime get selectedDate =>
      DateTime(displayedYear, displayedMonth, selectedDay);

  bool _matchesFilterKey(ServiceModel t, String filterKey) {
    if (filterKey == 'All') return true;
    final status = (t.status).toLowerCase();
    switch (filterKey) {
      case 'Pending':
        // Di logging page, 'Pending' berarti Accepted but waiting for Mechanic
        return status == 'pending';
      case 'In Progress':
        return status == 'in_progress' || status == 'progress' || status == 'in progress';
      case 'Completed':
        return status == 'completed' || status == 'menunggu pembayaran';
      case 'Lunas':
        return status == 'lunas';
      default:
        return false;
    }
  }

  List<ServiceModel> _getFilteredTasks(List<ServiceModel> allServices) {
    return allServices.where((service) {
      // 1. Must be Accepted by Admin
      if ((service.acceptanceStatus ?? '').toLowerCase() != 'accepted') return false;

      // 2. Date match (API filters by date, but double check)
       // bool dateMatch = LoggingHelpers.isSameDate(service.scheduledDate ?? DateTime.now(), selectedDate);
       // if (!dateMatch) return false;

      // 3. Status Filter (Tabs)
      bool statusMatch = _matchesFilterKey(service, selectedLoggingFilter);
      if (!statusMatch) return false;

      // ... (search logic)
      if (searchText.trim().isNotEmpty) {
        final q = searchText.toLowerCase();
        final title = (service.name).toLowerCase();
        final plate = (service.displayVehiclePlate).toLowerCase();
        final user = (service.displayCustomerName).toLowerCase();
        
        return title.contains(q) || plate.contains(q) || user.contains(q);
      }

      return true;
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<AdminServiceProvider>();
    final allServices = provider.items;

    // Filter for accepted services strictly
    // API returns all services for the date. We filter client side.
    final acceptedServicesForDate = allServices.where((s) {
       final acc = (s.acceptanceStatus ?? '').toLowerCase();
       return acc == 'accepted';
    }).toList();

    // Categorize based on Service Status
    // Pending: Accepted by Admin, but "status" is still pending (Waiting for Mechanic)
    final pending = acceptedServicesForDate
        .where((t) => (t.status).toLowerCase() == 'pending')
        .length;
        
    // In Progress: Mechanic Assigned
    final inProgress = acceptedServicesForDate
        .where((t) {
            final st = (t.status).toLowerCase();
            return st == 'in_progress' || st == 'progress' || st == 'in progress';
        })
        .length;
        
    // Completed (Menunggu Pembayaran considered completed in terms of work, but maybe not finalized)
    // User requested "Lunas" box separate.
    // Let's assume 'completed' and 'menunggu pembayaran' go to Completed box vs Lunas box.
    final completed = acceptedServicesForDate
        .where((t) {
           final st = (t.status).toLowerCase();
           return st == 'completed' || st == 'menunggu pembayaran';
        })
        .length;

    // Lunas
    final lunas = acceptedServicesForDate
        .where((t) => (t.status).toLowerCase() == 'lunas')
        .length;

    // Declined (Ditolak) - from allServices, not acceptedServicesForDate
    final declined = allServices
        .where((t) => (t.acceptanceStatus ?? '').toLowerCase() == 'declined')
        .length;

    final loggingFiltered = _getFilteredTasks(allServices);
    final title = selectedTimeSlot == null
        ? "Semua Tugas"
        : "Tugas untuk jam $selectedTimeSlot"; 

    return SingleChildScrollView(
      padding: const EdgeInsets.only(bottom: 90),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 8),
          Container(
            width: double.infinity,
            margin: const EdgeInsets.symmetric(horizontal: 16),
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.blue.shade50,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.blue.shade200),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "Pencatatan menampilkan semua order yang sudah diterima:",
                  style: GoogleFonts.poppins(
                      fontSize: 13, fontWeight: FontWeight.w600, color: Colors.blue.shade900),
                ),
                const SizedBox(height: 4),
                _bulletPoint("Booking yang diterima"),
                _bulletPoint("Walk-in (otomatis diterima)"),
              ],
            ),
          ),
          const SizedBox(height: 12),
          LoggingSummaryBoxes(
            pending: pending,
            inProgress: inProgress,
            completed: completed,
            lunas: lunas,
          ),
          const SizedBox(height: 12),
          LoggingCalendar(
            displayedMonth: displayedMonth,
            displayedYear: displayedYear,
            selectedDay: selectedDay,
            onPrevMonth: _prevMonth,
            onNextMonth: _nextMonth,
            onDaySelected: (day) {
              setState(() => selectedDay = day);
              _fetchData();
            },
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
            // Padding for timeslots if we implement logic later
            // LoggingTimeSlots(...), 
            // const SizedBox(height: 12),
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
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AppColors.border),
        ),
        child: Row(
          children: [
            const Icon(Icons.search, color: Colors.grey),
            const SizedBox(width: 8),
            Expanded(
                child: TextField(
                decoration: InputDecoration.collapsed(
                  hintText: "Search logging...",
                  hintStyle: AppTextStyles.caption(),
                ),
                style: AppTextStyles.bodyMedium(),
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
      String title, List<ServiceModel> filtered) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: AppTextStyles.heading4(),
          ),
          const SizedBox(height: 12),
          if (filtered.isEmpty)
            Center(
              child: Padding(
                padding: EdgeInsets.all(24.0),
                child: Text(
                  "Tidak ada tugas yang sesuai dengan filter.",
                  textAlign: TextAlign.center,
                  style: AppTextStyles.bodyMedium(color: AppColors.textSecondary),
                ),
              ),
            )
          else
            ...filtered.map((t) => LoggingTaskCard(service: t)),
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
        _fetchData();
      });

  void _nextMonth() => setState(() {
        displayedMonth += 1;
        if (displayedMonth > 12) {
          displayedMonth = 1;
          displayedYear += 1;
        }
        selectedDay = 1;
        _fetchData();
      });

  Widget _bulletPoint(String text) {
    return Row(
      children: [
        const Icon(Icons.circle, size: 6, color: Colors.blue),
        const SizedBox(width: 8),
        Text(text, style: GoogleFonts.poppins(fontSize: 12, color: Colors.black87)),
      ],
    );
  }
}