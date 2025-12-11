import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

import 'service_logging.dart';
import '../widgets/custom_header.dart';
import '../widgets/service/service_tab_selector.dart';
import '../widgets/service/service_calendar_section.dart';
import '../widgets/service/service_card.dart';
import '../widgets/service/service_helpers.dart';

import 'package:bengkel_online_flutter/feature/admin/providers/admin_service_provider.dart';
import 'package:bengkel_online_flutter/core/models/service.dart';

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

  DateTime get selectedDate =>
      DateTime(displayedYear, displayedMonth, selectedDay);

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<AdminServiceProvider>().fetchServices();
    });
  }

  bool _matchesFilterKey(ServiceModel s, String filterKey) {
    if (filterKey == 'All') return true;
    return s.status.toLowerCase() == filterKey.toLowerCase();
  }

  List<ServiceModel> _getScheduledServices(List<ServiceModel> all) {
    return all
        .where((s) =>
    s.scheduledDate != null &&
        ServiceHelpers.isSameDate(s.scheduledDate!, selectedDate))
        .where((s) => _matchesFilterKey(s, selectedFilter))
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
    final provider = context.watch<AdminServiceProvider>();

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
                _buildScheduledTab(provider),
                const ServiceLoggingPage(),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildScheduledTab(AdminServiceProvider provider) {
    if (provider.loading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (provider.error != null) {
      return Center(
        child: Text(
          provider.error!,
          style: GoogleFonts.poppins(),
        ),
      );
    }

    final scheduled = _getScheduledServices(provider.items);

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
              child: Text(
                "No scheduled tasks",
                style: GoogleFonts.poppins(),
              ),
            )
                : Column(
              children: scheduled.map((s) {
                final taskMap = {
                  "id": s.id,
                  "name": s.displayCustomerName,
                  "date": s.scheduledDate ?? DateTime.now(),
                  "service": s.name,
                  "plate": s.displayVehiclePlate,
                  "motor": s.displayVehicleName,
                  "vehicleCategory": "-",
                  "location": s.displayWorkshopName,
                  "status": s.status,
                };

                return ServiceCard(task: taskMap);
              }).toList(),
            ),
          ),
        ],
      ),
    );
  }
}
