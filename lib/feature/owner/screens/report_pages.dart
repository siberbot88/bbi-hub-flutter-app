import 'package:bengkel_online_flutter/feature/owner/screens/list_work.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';

import '../widgets/report/report_charts.dart';
import '../widgets/report/report_data.dart';
import '../widgets/report/report_health_matrix.dart';
import '../widgets/report/report_kpi_card.dart';
import '../../../core/services/report_pdf_service.dart';
import '../../../core/repositories/analytics_repository.dart';

// --- Colors ---
const Color kPrimaryRed = Color(0xFFB70F0F); // Darker red to match Staff Management
const Color kPrimaryRedDark = Color(0xFF9B0D0D); // Even darker for gradient
const Color kBackground = Color(0xFFF5F5F5); // Light Gray Background

class ReportPage extends StatefulWidget {
  const ReportPage({super.key});

  @override
  State<ReportPage> createState() => _ReportPageState();
}

class _ReportPageState extends State<ReportPage> {
  TimeRange _range = TimeRange.monthly;
  ReportData? _data;
  bool _isLoading = true;
  String? _errorMessage;
  final _analyticsRepo = AnalyticsRepository();

  @override
  void initState() {
    super.initState();
    // Use light status bar icons when on red header
    SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle.light);
    _loadAnalytics();
  }

  Future<void> _loadAnalytics() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final rangeString = _range == TimeRange.monthly ? 'monthly' 
          : _range == TimeRange.weekly ? 'weekly' : 'daily';
      
      final data = await _analyticsRepo.getAnalyticsWithAuth(range: rangeString);
      
      setState(() {
        _data = data;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _errorMessage = e.toString();
        _isLoading = false;
        // Fallback to seed data on error
        _data = ReportData.seed();
      });
      
      // Show error snackbar
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Gagal memuat data: ${e.toString()}'),
            backgroundColor: Colors.red,
            action: SnackBarAction(
              label: 'Coba Lagi',
              textColor: Colors.white,
              onPressed: _loadAnalytics,
            ),
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading || _data == null) {
      return Scaffold(
        backgroundColor: kPrimaryRed,
        body: Column(
          children: [
            _buildHeader(context),
            Expanded(
              child: Container(
                decoration: const BoxDecoration(
                  color: kBackground,
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(30),
                    topRight: Radius.circular(30),
                  ),
                ),
                child: const Center(
                  child: CircularProgressIndicator(
                    valueColor: AlwaysStoppedAnimation<Color>(kPrimaryRed),
                  ),
                ),
              ),
            ),
          ],
        ),
      );
    }

    final d = _data!;
    
    return Scaffold(
      backgroundColor: kPrimaryRed, // Background fallback
      body: Column( // Removed SafeArea to let Header go behind status bar
        children: [
          // 1. Header (Gradient + Segmented Control)
          _buildHeader(context),

          // 2. Scrollable Body
          Expanded(
            child: Container(
              width: double.infinity,
                decoration: const BoxDecoration(
                  color: kBackground,
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(30),
                    topRight: Radius.circular(30),
                  ),
                ),
                child: ClipRRect(
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(30),
                    topRight: Radius.circular(30),
                  ),
                  child: ListView(
                    padding: const EdgeInsets.fromLTRB(20, 24, 20, 24),
                    physics: const BouncingScrollPhysics(),
                    children: [
                            // KPI GRid
                            _buildKpiSection(d),
                            const SizedBox(height: 24),

                            // Trend Chart
                            _buildTrendChart(d),
                            const SizedBox(height: 20),

                            // Breakdown & Queue
                            _buildBreakdownRow(d),
                            const SizedBox(height: 20),

                            // Peak Hour
                            _buildPeakHour(d),
                            const SizedBox(height: 20),

                      // Operational Health
                      ReportHealthMatrix(
                        avgQueue: '${d.avgQueue} mobil',
                        occupancy: '${d.occupancy}%',
                        peakRange: d.peakRange,
                        efficiency: '${d.efficiency}%',
                      ),
                      
                      const SizedBox(height: 32),
                      
                      // CTA Button (now at bottom of scrollable content)
                      _buildCtaButton(),
                      
                      const SizedBox(height: 24),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
    );
  }

  // --- Header Section ---
  Widget _buildHeader(BuildContext context) {
    final bool canPop = Navigator.of(context).canPop();
    final double topPadding = MediaQuery.of(context).padding.top;

    return Container(
      // Add topPadding to local padding
      padding: EdgeInsets.fromLTRB(20, topPadding + 10, 20, 24),
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [kPrimaryRed, kPrimaryRedDark],
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
        ),
      ),
      child: Column(
        children: [
          // Nav Bar Row (Icons only)
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              // Back Button (Only if canPop)
              canPop 
                  ? _buildCircleButton(
                      icon: Icons.chevron_left_rounded,
                      onTap: () => Navigator.maybePop(context),
                    )
                  : const SizedBox(width: 44, height: 44), // Placeholder to keep layout balanced if needed, or just nothing.
              
              // Notification Button
              _buildCircleButton(
                icon: Icons.notifications_none_rounded,
                onTap: () {},
              ),
            ],
          ),
          const SizedBox(height: 16),
          
          // Centered Title & Subtitle
          Center(
            child: Column(
              children: [
                 Text(
                  'Laporan',
                  style: GoogleFonts.poppins(
                    fontSize: 28, // Matches AppTheme.headingTitle
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Dashboard Analitik',
                  style: GoogleFonts.poppins(
                    fontSize: 14, // Matches AppTheme.headingSubtitle
                    fontWeight: FontWeight.w500,
                    color: Colors.white.withOpacity(0.9),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),
          
          // Segmented Control
          Container(
            padding: const EdgeInsets.all(4),
            decoration: BoxDecoration(
              color: Colors.black.withOpacity(0.2), // Matches StaffPerformanceScreen dark transparent
              borderRadius: BorderRadius.circular(30),
            ),
            child: Row(
              children: [
                _buildSegmentTab('Harian', TimeRange.daily),
                _buildSegmentTab('Mingguan', TimeRange.weekly),
                _buildSegmentTab('Bulanan', TimeRange.monthly),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCircleButton({required IconData icon, required VoidCallback onTap}) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(50),
      child: Container(
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.15),
          shape: BoxShape.circle,
        ),
        child: Icon(icon, color: Colors.white, size: 24),
      ),
    );
  }

  Widget _buildSegmentTab(String label, TimeRange range) {
    final bool isSelected = _range == range;
    return Expanded(
      child: GestureDetector(
        onTap: () {
          if (_range != range) {
            setState(() => _range = range);
            _loadAnalytics(); // Reload with new range
          }
        },
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.symmetric(vertical: 10),
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: isSelected ? Colors.white : Colors.transparent,
            borderRadius: BorderRadius.circular(24),
            boxShadow: isSelected ? [
               BoxShadow(
                 color: Colors.black.withOpacity(0.1), 
                 blurRadius: 4, 
                 offset: const Offset(0, 2)
               )
            ] : [],
          ),
          child: Text(
            label,
            style: GoogleFonts.poppins(
              fontSize: 13,
              fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
              color: isSelected ? kPrimaryRed : Colors.white.withOpacity(0.9),
            ),
          ),
        ),
      ),
    );
  }

  // --- KPI Section ---
  Widget _buildKpiSection(ReportData d) {
    return Column(
      children: [
        Row(
          children: [
            ReportKpiCard(
              icon: Icons.attach_money_rounded,
              title: 'Rp. ${(d.revenueThisPeriod / 1000000).toStringAsFixed(1)}Jt', // Short format (64.7Jt)
              subtitle: 'Pendapatan bulan ini',
              growthText: d.revenueGrowthText,
              onTap: () {},
            ),
            const SizedBox(width: 14),
            ReportKpiCard(
              icon: Icons.assignment_turned_in_rounded,
              title: '${d.jobsDone} Order',
              subtitle: 'Pekerjaan Selesai',
              growthText: d.jobsGrowthText,
              iconBgColor: const Color(0xFFE3F2FD), // Blue bg
              iconColor: const Color(0xFF1976D2),
              onTap: () {},
            ),
          ],
        ),
        const SizedBox(height: 14),
        Row(
          children: [
             ReportKpiCard(
              icon: Icons.groups_rounded,
              title: '${d.occupancy}%',
              subtitle: 'Occupancy Rate',
              growthText: d.occupancyGrowthText, // e.g -3%
              iconBgColor: const Color(0xFFF3E5F5), // Purple bg
              iconColor: const Color(0xFF7B1FA2),
              onTap: () {},
            ),
            const SizedBox(width: 14),
             ReportKpiCard(
              icon: Icons.star_rounded,
              title: '${d.avgRating}',
              subtitle: 'Rating Rata-rata',
              growthText: d.ratingGrowthText,
              iconBgColor: const Color(0xFFFFF8E1), // Amber bg
              iconColor: const Color(0xFFFFA000),
              onTap: () {},
            ),
          ],
        ),
      ],
    );
  }

  // --- Chart Sections ---
  
  Widget _buildTrendChart(ReportData d) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
         color: Colors.white,
         borderRadius: BorderRadius.circular(24),
         boxShadow: [
            BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 15, offset: const Offset(0, 4)),
         ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                   Text('Grafik Tren', style: _titleStyle),
                   Text('Pendapatan & Pekerjaan', style: _subtitleStyle),
                ],
              ),
              Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(color: Colors.grey[100], borderRadius: BorderRadius.circular(8)),
                child: const Icon(Icons.more_horiz, size: 16, color: Colors.grey),
              ),
            ],
          ),
          const SizedBox(height: 24),
          SizedBox(
            height: 200,
            child: LineChart(
              ReportCharts.lineChartData(
                labels: d.labels,
                seriesA: d.revenueTrend, // Pendapatan
                colorA: const Color(0xFF7C3AED), // Purple
                seriesB: d.jobsTrend, // Pekerjaan
                colorB: const Color(0xFF3B82F6), // Blue
              ),
              duration: const Duration(milliseconds: 400),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBreakdownRow(ReportData d) {
    return Column( // Use Column on small screens if needed, but spec says Row
       children: [
          _buildServiceTypeCard(d),
          const SizedBox(height: 20),
          _buildAvgQueueCard(d),
       ],
    );
  }

  Widget _buildServiceTypeCard(ReportData d) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
         color: Colors.white,
         borderRadius: BorderRadius.circular(24),
         boxShadow: [
            BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 15, offset: const Offset(0, 4)),
         ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
           Text('Jenis Service', style: _titleStyle),
           const SizedBox(height: 20),
           Row(
             children: [
               // Donut
               SizedBox(
                 height: 120,
                 width: 120,
                 child: PieChart(ReportCharts.donutData(d.serviceBreakdown)),
               ),
               const SizedBox(width: 20),
               // Legend
               Expanded(
                 child: Column(
                   children: [
                      _buildLegendRow('Rutin', '35%', const Color(0xFF7C3AED)),
                      _buildLegendRow('Perbaikan', '28%', const Color(0xFF3B82F6)),
                      _buildLegendRow('Onderdil', '22%', const Color(0xFF22C55E)),
                      _buildLegendRow('Body', '15%', const Color(0xFFF59E0B)),
                   ],
                 ),
               )
             ],
           )
        ],
      ),
    );
  }

  Widget _buildAvgQueueCard(ReportData d) {
     return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
         color: Colors.white,
         borderRadius: BorderRadius.circular(24),
         boxShadow: [
            BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 15, offset: const Offset(0, 4)),
         ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
           Row(
             mainAxisAlignment: MainAxisAlignment.spaceBetween,
             children: [
               Text('Avg. Antrian', style: _titleStyle),
               Container(
                 padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                 decoration: BoxDecoration(
                   color: const Color(0xFFE8F5E9),
                   borderRadius: BorderRadius.circular(6),
                 ),
                 child: Text('+2.4%', style: GoogleFonts.poppins(fontSize: 10, fontWeight: FontWeight.bold, color: const Color(0xFF2E7D32))),
               )
             ],
           ),
           const SizedBox(height: 20),
           SizedBox(
             height: 150,
             child: BarChart(
               ReportCharts.barsData(
                 values: d.avgQueueBars,
                 labels: const ['Sn', 'Sl', 'Rb', 'Km', 'Jm', 'Sb', 'Mn'],
                 color: const Color(0xFFA855F7), // Light Purple
               )
             ),
           )
        ],
      ),
    );
  }

  Widget _buildPeakHour(ReportData d) {
     return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
         color: Colors.white,
         borderRadius: BorderRadius.circular(24),
         boxShadow: [
            BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 15, offset: const Offset(0, 4)),
         ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
           Row(
             mainAxisAlignment: MainAxisAlignment.spaceBetween,
             children: [
               Column(
                 crossAxisAlignment: CrossAxisAlignment.start,
                 children: [
                   Text('Peak Hour', style: _titleStyle),
                   Text('Jam Sibuk bengkel', style: _subtitleStyle),
                 ],
               ),
               Container(
                 padding: const EdgeInsets.all(8),
                 decoration: BoxDecoration(
                   color: const Color(0xFFE3F2FD),
                   borderRadius: BorderRadius.circular(8),
                 ),
                 child: const Icon(Icons.schedule_rounded, size: 18, color: Color(0xFF1976D2)),
               ),
             ],
           ),
           const SizedBox(height: 24),
           SizedBox(
             height: 160,
             child: BarChart(
               ReportCharts.barsData(
                 values: d.peakHourBars.map((v) => v.toDouble()).toList(),
                 labels: d.peakHourLabels,
                 color: const Color(0xFF3B82F6), // Blue
               )
             ),
           )
        ],
      ),
    );
  }

  Widget _buildCtaButton() {
    return Container(
      decoration: BoxDecoration(
        boxShadow: [
           BoxShadow(
             color: kPrimaryRed.withOpacity(0.4),
             blurRadius: 12,
             offset: const Offset(0, 6)
           )
        ]
      ),
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: kPrimaryRed,
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(vertical: 16),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          elevation: 0,
        ),
        onPressed: () async {
          // Generate and show PDF
          if (_data != null) {
            await ReportPdfService.generate(
              data: _data!,
              range: _range,
            );
          }
        },
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
             const Icon(Icons.print_rounded, size: 20),
             const SizedBox(width: 8),
             Text(
               'Cetak Laporan',
               style: GoogleFonts.poppins(fontSize: 16, fontWeight: FontWeight.bold),
             ),
          ],
        ),
      ),
    );
  }

  // --- Styles & Helpers ---
  TextStyle get _titleStyle => GoogleFonts.poppins(
    fontSize: 16,
    fontWeight: FontWeight.bold,
    color: const Color(0xFF212121),
  );
  
  TextStyle get _subtitleStyle => GoogleFonts.poppins(
    fontSize: 12,
    color: const Color(0xFF9E9E9E),
  );

  Widget _buildLegendRow(String label, String value, Color color) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
               Container(width: 8, height: 8, decoration: BoxDecoration(color: color, shape: BoxShape.circle)),
               const SizedBox(width: 8),
               Text(label, style: GoogleFonts.poppins(fontSize: 12, color: const Color(0xFF757575))),
            ],
          ),
          Text(value, style: GoogleFonts.poppins(fontSize: 12, fontWeight: FontWeight.w600, color: const Color(0xFF212121))),
        ],
      ),
    );
  }

  String formatCurrency(int v) {
    // simplified
    return v.toString();
  }
}
