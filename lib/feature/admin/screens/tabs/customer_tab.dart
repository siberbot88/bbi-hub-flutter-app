// 📄 lib/feature/admin/screens/tabs/customer_tab.dart
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:syncfusion_flutter_charts/charts.dart';
import 'package:bengkel_online_flutter/core/models/dashboard_stats.dart';

class CustomerTab extends StatefulWidget {
  final String selectedRange;
  final String chartFilter;
  final ValueChanged<String> onRangeChange;
  final ValueChanged<String> onChartFilterChange;
  final CustomerStats? customerStats; // ✅ Data from API
  final List<DashboardTrend> trend;
  final bool isLoading;

  const CustomerTab({
    super.key,
    required this.selectedRange,
    required this.chartFilter,
    required this.onRangeChange,
    required this.onChartFilterChange,
    this.customerStats,
    this.trend = const [],
    this.isLoading = false,
  });

  @override
  State<CustomerTab> createState() => _CustomerTabState();
}

class _CustomerTabState extends State<CustomerTab> {
  static const _redDark = Color(0xFF9B0D0D);

  @override
  Widget build(BuildContext context) {
    // Use API data or default to 0
    final stats = widget.customerStats;
    final totalCustomers = stats?.total ?? 0;
    final activeCustomers = stats?.active ?? 0;
    final newCustomers = stats?.newThisMonth ?? 0;

    // Chart data from trend
    final chartData = widget.trend.map((t) => _Pt(
      t.month ?? t.date,
      t.total.toDouble(),
    )).toList();

    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Judul + pill
          Row(
            children: [
              Expanded(
                child: Text(
                  'Pelanggan',
                  style: GoogleFonts.poppins(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                    color: Colors.black87,
                  ),
                ),
              ),
              _rangePill(context),
            ],
          ),
          const SizedBox(height: 16),

          // Loading state
          if (widget.isLoading)
            const Center(
              child: Padding(
                padding: EdgeInsets.all(32),
                child: CircularProgressIndicator(color: Color(0xFFDC2626)),
              ),
            )
          else ...[
            // Kartu Total Pelanggan (besar) - FROM API
            _bigTotalCard(count: totalCustomers, title: 'Total Pelanggan'),
            const SizedBox(height: 14),

            // Dua kartu kecil - FROM API
            Row(
              children: [
                Expanded(
                    child: _smallCard(title: 'Pelanggan Aktif', value: '$activeCustomers')),
                const SizedBox(width: 12),
                Expanded(child: _smallCard(title: 'Pelanggan Baru', value: '$newCustomers')),
              ],
            ),

            const SizedBox(height: 20),
            Text('Analisis',
                style: GoogleFonts.poppins(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: Colors.black87)),
            const SizedBox(height: 10),

            // Card Chart
            Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withAlpha(15),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              padding: const EdgeInsets.fromLTRB(14, 14, 14, 6),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Title + filter Week/Month
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('Customer Growth Trend',
                          style: GoogleFonts.poppins(
                              fontSize: 14.5,
                              fontWeight: FontWeight.w600,
                              color: const Color(0xFF9B0D0D))),
                      Row(
                        children: ['Week', 'Month'].map((f) {
                          final selected = widget.chartFilter == f;
                          return GestureDetector(
                            onTap: () => widget.onChartFilterChange(f),
                            child: Container(
                              margin: const EdgeInsets.only(left: 8),
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 12, vertical: 4),
                              decoration: BoxDecoration(
                                color:
                                    selected ? _redDark : const Color(0xFFEDEDED),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Text(
                                f,
                                style: GoogleFonts.poppins(
                                  color: selected ? Colors.white : Colors.black87,
                                  fontWeight: FontWeight.w600,
                                  fontSize: 12,
                                ),
                              ),
                            ),
                          );
                        }).toList(),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),

                  // Chart
                  chartData.isEmpty
                      ? Container(
                          height: 180,
                          alignment: Alignment.center,
                          child: Text(
                            'Belum ada data trend',
                            style: GoogleFonts.poppins(
                              color: Colors.grey[500],
                              fontSize: 13,
                            ),
                          ),
                        )
                      : SizedBox(
                          height: 180,
                          child: SfCartesianChart(
                            plotAreaBorderWidth: 0,
                            primaryXAxis: CategoryAxis(
                              majorGridLines: const MajorGridLines(width: 0.25),
                              labelStyle: GoogleFonts.poppins(fontSize: 11),
                            ),
                            primaryYAxis: NumericAxis(
                              majorGridLines: const MajorGridLines(width: 0.25),
                              axisLine: const AxisLine(width: 0),
                              labelStyle: GoogleFonts.poppins(fontSize: 10),
                            ),
                            series: <CartesianSeries<_Pt, String>>[
                              LineSeries<_Pt, String>(
                                dataSource: chartData,
                                xValueMapper: (d, _) => d.label,
                                yValueMapper: (d, _) => d.value,
                                color: const Color(0xFFB388FF),
                                width: 2,
                                markerSettings: const MarkerSettings(
                                  isVisible: true,
                                  shape: DataMarkerType.circle,
                                  borderColor: Colors.black,
                                  borderWidth: 1,
                                  width: 7,
                                  height: 7,
                                  color: Colors.white,
                                ),
                              ),
                            ],
                          ),
                        ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  // ----------------- Widgets Kecil -----------------

  Widget _rangePill(BuildContext context) {
    return Container(
      padding: const EdgeInsets.only(left: 14, right: 6),
      height: 36,
      decoration: BoxDecoration(
        color: const Color(0xFFDC2626),
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha(26),
            blurRadius: 8,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: widget.selectedRange,
          icon: const Icon(Icons.keyboard_arrow_down, color: Colors.white),
          dropdownColor: Colors.white,
          style: GoogleFonts.poppins(color: Colors.white, fontSize: 13),
          items: const ['Hari ini', 'Minggu ini', 'Bulan ini']
              .map((e) => DropdownMenuItem(
                    value: e,
                    child: Text(
                      e,
                      style: GoogleFonts.poppins(color: Colors.black),
                    ),
                  ))
              .toList(),
          onChanged: (v) {
            if (v != null) {
              widget.onRangeChange(v);
            }
          },
        ),
      ),
    );
  }

  Widget _bigTotalCard({required int count, required String title}) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 22),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha(20),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          Text(title,
              style: GoogleFonts.poppins(
                  fontSize: 13,
                  color: Colors.black54,
                  fontWeight: FontWeight.w500)),
          const SizedBox(height: 8),
          Text(
            '$count',
            style: GoogleFonts.poppins(
                fontSize: 28,
                color: const Color(0xFFDC2626),
                fontWeight: FontWeight.w700),
          ),
        ],
      ),
    );
  }

  Widget _smallCard({required String title, required String value}) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
              color: Colors.black.withAlpha(20),
              blurRadius: 10,
              offset: const Offset(0, 4))
        ],
      ),
      child: Column(
        children: [
          Text(title,
              style: GoogleFonts.poppins(
                  fontSize: 13,
                  color: Colors.black54,
                  fontWeight: FontWeight.w600)),
          const SizedBox(height: 10),
          Text(value,
              style: GoogleFonts.poppins(
                  fontSize: 22,
                  color: const Color(0xFFDC2626),
                  fontWeight: FontWeight.w700)),
        ],
      ),
    );
  }
}

class _Pt {
  final String label;
  final double value;
  const _Pt(this.label, this.value);
}
