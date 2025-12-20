import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';

import 'service_logging.dart';
import 'service_on_the_site.dart';
import '../widgets/custom_header.dart';
import '../widgets/service/service_tab_selector.dart';
import '../widgets/service/service_calendar_section.dart';
import '../widgets/service/service_card.dart';
import '../widgets/service/service_helpers.dart';
import '../widgets/service/service_summary_boxes.dart';
import '../widgets/service/service_filter_tabs.dart';

import 'package:bengkel_online_flutter/feature/admin/providers/admin_service_provider.dart';
import 'package:bengkel_online_flutter/core/models/service.dart';
import 'package:bengkel_online_flutter/core/services/auth_provider.dart';
import 'package:intl/intl.dart';

class ServicePageAdmin extends StatefulWidget {
  const ServicePageAdmin({super.key});

  @override
  State<ServicePageAdmin> createState() => _ServicePageAdminState();
}

class _ServicePageAdminState extends State<ServicePageAdmin> {
  int displayedMonth = DateTime.now().month;
  int displayedYear = DateTime.now().year;
  int selectedDay = DateTime.now().day;
  String selectedFilter = "Semua";
  int selectedTab = 0; // 0 = Scheduled, 1 = Logging

  DateTime get selectedDate =>
      DateTime(displayedYear, displayedMonth, selectedDay);
      
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
    
    // Format to ISO string or format expected by backend (usually YYYY-MM-DD HH:mm:ss)
    final dateFrom = DateFormat('yyyy-MM-dd HH:mm:ss').format(startOfDay);
    final dateTo = DateFormat('yyyy-MM-dd HH:mm:ss').format(endOfDay);
    print("DEBUG: _fetchData UI -> Selected: $selectedDate, From: $dateFrom, To: $dateTo");
    
    // Fetch ALL services for the date
    context.read<AdminServiceProvider>().fetchServices(
      dateFrom: dateFrom,
      dateTo: dateTo,
      workshopUuid: workshopUuid,
      // Removed status: 'pending' to get all services for stats and filtering
    );
  }

  void _prevMonth() {
    setState(() {
      displayedMonth--;
      if (displayedMonth < 1) {
        displayedMonth = 12;
        displayedYear--;
      }
      final daysInMonth = ServiceHelpers.daysInMonth(displayedYear, displayedMonth);
      if (selectedDay > daysInMonth) {
        selectedDay = daysInMonth; // Clamp to last day of new month
      } else {
        selectedDay = 1; // Or default to 1 as before? User said "tanggal yg digunakan juga belum sesuai". 
        // If I switch month, usually I want to see the 1st, or stay on same day index?
        // Let's reset to 1 as it's safer, or clamp. The previous code reset to 1.
        // But user said "tanggal yg digunakan belum sesuai". maybe they want to keep the day?
        // I will reset to 1 but ensure it's valid.
        selectedDay = 1;
      }
      print("DEBUG: PrevMonth -> Month: $displayedMonth, Year: $displayedYear, Day: $selectedDay");
    });
    _fetchData();
  }

  void _nextMonth() {
    setState(() {
      displayedMonth++;
      if (displayedMonth > 12) {
        displayedMonth = 1;
        displayedYear++;
      }
      selectedDay = 1; // Default to 1st of next month
    });
    _fetchData();
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<AdminServiceProvider>();



    return Scaffold(
      backgroundColor: AppColors.backgroundLight,
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
                const ServiceOnTheSitePage(),
                const ServiceLoggingPage(),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildScheduledTab(AdminServiceProvider provider) {
    /*
    if (provider.loading) {
      return const Center(child: CircularProgressIndicator());
    }
    */
    // We don't block UI on loading because calendar needs to be visible or at least structure
    // But for now let's keep it simple or just show loading in the list area if needed.
    // Provider loading might be global for the list.

    if (provider.error != null) {
      return Center(
        child: Text(
          provider.error!,
          style: AppTextStyles.bodyMedium(color: AppColors.error),
        ),
      );
    }

    final allServices = provider.items;

    // Calculate Stats
    // All: Total services for the date (Booking Only)
    // Filter out Walk-ins first (Show Booking Only)
    // Menampilkan semua yang BUKAN on-site (termasuk type null atau 'booking')
    final bookingServices = allServices.where((s) {
       final type = (s.type ?? '').toLowerCase();
       return type != 'on-site'; // Semua yang bukan on-site dianggap booking
    }).toList();
    
    print('DEBUG service_page: allServices=${allServices.length}, bookingServices=${bookingServices.length}');
    for (var s in allServices) {
      print('  -> id=${s.id}, type=${s.type}, name=${s.name}');
    }

    final allCount = bookingServices.length;
    // Menunggu (Pending): acceptance_status == "pending"
    final pendingCount = bookingServices.where((s) => (s.acceptanceStatus ?? '').toLowerCase() == 'pending').length;
    // Terima (Accepted): acceptance_status == "accepted"
    final acceptedCount = bookingServices.where((s) => (s.acceptanceStatus ?? '').toLowerCase() == 'accepted').length;
    // Tolak (Declined): acceptance_status == "declined" or "rejected"
    final declinedCount = bookingServices.where((s) => (s.acceptanceStatus ?? '').toLowerCase() == 'decline').length;
    
    // Filter List
    final filteredServices = bookingServices.where((s) {
      final acceptance = (s.acceptanceStatus ?? '').toLowerCase();
      // final status = (s.status).toLowerCase();
      
      if (selectedFilter == 'Semua') return true;
      if (selectedFilter == 'Menunggu') return acceptance == 'pending';
      if (selectedFilter == 'Terima') return acceptance == 'accepted';
      if (selectedFilter == 'Tolak') return acceptance == 'declined' || acceptance == 'rejected' || acceptance == 'canceled' || acceptance == 'cancelled';
      return true;
    }).toList();


    return SingleChildScrollView(
      padding:  const EdgeInsets.only(bottom: 80),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 16),
          // Add Summary Boxes
          ServiceSummaryBoxes(
            all: allCount,
            accepted: acceptedCount,
            pending: pendingCount,
            declined: declinedCount,
          ),
          const SizedBox(height: 12),
          
          ServiceCalendarSection(
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
          
          const SizedBox(height: 20),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Text("Daftar Penjadwalan", style: AppTextStyles.heading4()),
          ),
          const SizedBox(height: 12),
          
          // Add Filter Tabs
           ServiceFilterTabs(
            selectedFilter: selectedFilter,
            onFilterChanged: (filter) =>
                setState(() => selectedFilter = filter),
          ),
          
          const SizedBox(height: 12),
          
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: provider.loading 
                ? const Center(child: CircularProgressIndicator()) 
                : filteredServices.isEmpty
                  ? Center(
                      child: Padding(
                        padding: const EdgeInsets.all(24.0),
                        child: Text(
                          "Tidak ada tugas yang sesuai.",
                          style: AppTextStyles.bodyMedium(color: AppColors.textSecondary),
                        ),
                      ),
                    )
                  : Column(
                      children: filteredServices.map((s) {
                        return ServiceCard(service: s);
                      }).toList(),
                    ),
          ),
        ],
      ),
    );
  }
}
