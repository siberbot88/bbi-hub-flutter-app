// lib/screens/dashboard.dart
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:fl_chart/fl_chart.dart';
import 'tabs/technician_tab.dart';
import 'tabs/revenue_tab.dart';
import 'tabs/customer_tab.dart';

class DashboardPage extends StatefulWidget {
  const DashboardPage({super.key});

  @override
  State<DashboardPage> createState() => _DashboardPageState();
}

class _DashboardPageState extends State<DashboardPage> {
  String selectedTab = "Services";
  String selectedRange = "Today";
  String chartFilter = "Week"; // Week | Month

  // dummy data untuk services
  final List<Map<String, dynamic>> mostFreq = [
    {'name': 'Oil Change', 'count': 18},
    {'name': 'Brake Service', 'count': 12},
    {'name': 'Tire Rotation', 'count': 8},
  ];

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [
            Color(0xFF6A1B1B), // soft dark red
            Color(0xFFA12C2C), // medium soft red
            Color(0xFFE57373), // soft light red
          ],
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
        ),
      ),
      child: Scaffold(
        backgroundColor: Colors.transparent, // biar gradasi keliatan
        body: Column(
          children: [
            _buildHeader(),
            Expanded(child: _buildTabContent()),
          ],
        ),
      ),
    );
  }

  // 🔹 Header
  Widget _buildHeader() {
    final tabs = ["Services", "Technician", "Revenue", "Customer"];
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 50, 16, 20),
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [Color(0xFF510707), Color(0xFF9B0D0D), Color(0xFFB70F0F)],
          begin: Alignment.centerLeft,
          end: Alignment.centerRight,
        ),
      ),
      child: Column(
        children: [
          Text("Dashboard",
              style: GoogleFonts.poppins(
                  fontSize: 22, fontWeight: FontWeight.bold, color: Colors.white)),
          const SizedBox(height: 6),
          Text("Monitor services, technicians, revenue, and customers",
              style: GoogleFonts.poppins(
                  fontSize: 13, color: Colors.white.withOpacity(0.9))),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: tabs.map((tab) {
              final isSelected = selectedTab == tab;
              return GestureDetector(
                onTap: () => setState(() => selectedTab = tab),
                child: Text(tab,
                    style: GoogleFonts.poppins(
                        fontSize: 14,
                        fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                        color: isSelected ? Colors.white : Colors.white70)),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }

  // 🔹 Konten Tab
    Widget _buildTabContent() {
    switch (selectedTab) {
      case "Services":
        return _servicesTab(); 
      case "Technician":
        return TechnicianTab(
          selectedRange: selectedRange,
          onRangeChange: (v) => setState(() => selectedRange = v),
        );
      case "Revenue":
        return RevenueTab(
          selectedRange: selectedRange,
          chartFilter: chartFilter,
          onRangeChange: (v) => setState(() => selectedRange = v),
          onChartFilterChange: (f) => setState(() => chartFilter = f), // ✅ FIX
        );
      case "Customer":
        return CustomerTab(
          selectedRange: selectedRange,
          chartFilter: chartFilter,
          onRangeChange: (v) => setState(() => selectedRange = v),
          onChartFilterChange: (f) => setState(() => chartFilter = f), // ✅ FIX
        );
      default:
        return const SizedBox.shrink();
    }
  }

  // ----------------- Services Tab langsung di Dashboard -----------------
  Widget _servicesTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(16, 18, 16, 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 🔹 Title + Dropdown
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text("Services",
                  style: GoogleFonts.poppins(
                      fontSize: 22, fontWeight: FontWeight.w600, color: Colors.white)),
              _dropdownRange(),
            ],
          ),
          const SizedBox(height: 6),
          Align(
            alignment: Alignment.centerRight,
            child: GestureDetector(
              onTap: () => Navigator.pushNamed(context, "/service"),
              child: Text("View All",
                  style: GoogleFonts.poppins(
                      fontSize: 13,
                      fontWeight: FontWeight.w500,
                      color: Colors.red)),
            ),
          ),
          const SizedBox(height: 14),

          // 🔹 Tiga Summary Box
          Row(
            children: [
              Expanded(child: _summaryCard("Completed", "24", Icons.check_circle, Colors.green)),
              const SizedBox(width: 10),
              Expanded(child: _summaryCard("Pending", "12", Icons.access_time, Colors.orange)),
              const SizedBox(width: 10),
              Expanded(child: _summaryCard("In Progress", "5", Icons.build_circle, Colors.red)),
            ],
          ),
          const SizedBox(height: 18),

          // 🔹 Most Frequent Services
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(14),
              boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.06), blurRadius: 8, offset: const Offset(0, 3))],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text("Most Frequent Services", style: GoogleFonts.poppins(fontSize: 16, fontWeight: FontWeight.w600)),
                    Text("View Details", style: GoogleFonts.poppins(fontSize: 13, color: Colors.red, fontWeight: FontWeight.w500)),
                  ],
                ),
                const SizedBox(height: 10),
                ...mostFreq.map((m) => _serviceRow(m['name'], m['count'])).toList(),
              ],
            ),
          ),
          const SizedBox(height: 20),

          // 🔹 Analytics Title
          Text("Analytics", style: GoogleFonts.poppins(fontSize: 16, fontWeight: FontWeight.w600, color: Colors.white)),
          const SizedBox(height: 12),

          // 🔹 Chart
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(14),
              boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.06), blurRadius: 8, offset: const Offset(0, 3))],
            ),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text("Services", style: GoogleFonts.poppins(fontSize: 15, fontWeight: FontWeight.w600)),
                    Row(
                      children: ["Week", "Month"].map((f) {
                        final isSelected = chartFilter == f;
                        return GestureDetector(
                          onTap: () => setState(() => chartFilter = f),
                          child: Container(
                            margin: const EdgeInsets.only(left: 8),
                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                            decoration: BoxDecoration(
                              color: isSelected ? const Color(0xFFB70F0F) : Colors.grey.shade200,
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Text(f,
                                style: GoogleFonts.poppins(
                                    fontSize: 12,
                                    fontWeight: FontWeight.w600,
                                    color: isSelected ? Colors.white : Colors.black87)),
                          ),
                        );
                      }).toList(),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                SizedBox(height: 180, child: _buildLineChart()),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // 🔹 Dropdown Reusable
  Widget _dropdownRange() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: Colors.red[900],
        borderRadius: BorderRadius.circular(15),
      ),
      child: DropdownButton<String>(
        value: selectedRange,
        underline: const SizedBox(),
        dropdownColor: Colors.red[900],
        icon: const Icon(Icons.arrow_drop_down, color: Colors.white),
        style: GoogleFonts.poppins(color: Colors.white, fontSize: 12),
        items: ["Today", "Yesterday", "Week", "Month"]
            .map((e) => DropdownMenuItem(value: e, child: Text(e, style: const TextStyle(color: Colors.white))))
            .toList(),
        onChanged: (v) => setState(() => selectedRange = v ?? selectedRange),
      ),
    );
  }

  // 🔹 Summary Card
  Widget _summaryCard(String label, String value, IconData icon, Color iconColor) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 6, offset: const Offset(0, 3))],
      ),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(color: Colors.grey.shade100, borderRadius: BorderRadius.circular(10)),
            child: Icon(icon, color: iconColor, size: 26),
          ),
          const SizedBox(height: 12),
          Text(value, style: GoogleFonts.poppins(fontSize: 20, fontWeight: FontWeight.bold)),
          const SizedBox(height: 6),
          Text(label, style: GoogleFonts.poppins(fontSize: 13, fontWeight: FontWeight.w500)),
        ],
      ),
    );
  }

  Widget _serviceRow(String name, int count) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(name, style: GoogleFonts.poppins(fontSize: 14, fontWeight: FontWeight.w500)),
          Text('$count', style: GoogleFonts.poppins(fontSize: 14, fontWeight: FontWeight.bold, color: Colors.black87)),
        ],
      ),
    );
  }

  // 🔹 Chart
  Widget _buildLineChart() {
    final spots = chartFilter == "Week"
        ? [FlSpot(0, 3), FlSpot(1, 4), FlSpot(2, 2.5), FlSpot(3, 5), FlSpot(4, 4.5), FlSpot(5, 6)]
        : [FlSpot(0, 2), FlSpot(1, 3), FlSpot(2, 4), FlSpot(3, 5.5), FlSpot(4, 4.0), FlSpot(5, 6.5)];

    return LineChart(
      LineChartData(
        gridData: FlGridData(show: true, drawVerticalLine: false),
        borderData: FlBorderData(show: false),
        titlesData: FlTitlesData(
          bottomTitles: AxisTitles(sideTitles: SideTitles(showTitles: true, reservedSize: 22)),
          leftTitles: AxisTitles(sideTitles: SideTitles(showTitles: true, interval: 2)),
        ),
        lineBarsData: [
          LineChartBarData(
            spots: spots,
            isCurved: true,
            color: Colors.red,
            barWidth: 3,
            dotData: FlDotData(show: true),
          ),
        ],
      ),
    );
  }
}
