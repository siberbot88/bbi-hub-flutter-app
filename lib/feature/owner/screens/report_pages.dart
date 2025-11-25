import 'package:bengkel_online_flutter/feature/owner/screens/list_work.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../widgets/report/report_charts.dart';
import '../widgets/report/report_data.dart';
import '../widgets/report/report_health_tile.dart';
import '../widgets/report/report_helpers.dart';
import '../widgets/report/report_kpi_card.dart';
import '../widgets/report/report_panels.dart';

const Color kRedStart = Color(0xFF9B0D0D);
const Color kRedEnd = Color(0xFFB70F0F);
const Color kDanger = Color(0xFFDC2626);

class ReportPage extends StatefulWidget {
  const ReportPage({super.key});

  @override
  State<ReportPage> createState() => _ReportPageState();
}

class _ReportPageState extends State<ReportPage> {
  TimeRange _range = TimeRange.monthly;
  late ReportData _data;

  @override
  void initState() {
    super.initState();
    SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle.light);
    _data = ReportData.seed();
  }

  @override
  Widget build(BuildContext context) {
    final d = _data.forRange(_range);
    final canPop = Navigator.of(context).canPop();

    return Scaffold(
      backgroundColor: Colors.white,
      body: CustomScrollView(
        physics: const BouncingScrollPhysics(),
        slivers: [
          SliverAppBar(
            pinned: true,
            automaticallyImplyLeading: false,
            leading: canPop
                ? IconButton(
                    icon: const Icon(Icons.arrow_back, color: Colors.white),
                    onPressed: () => Navigator.pop(context),
                  )
                : null,
            backgroundColor: kRedStart,
            elevation: 0,
            expandedHeight: 230,
            flexibleSpace: FlexibleSpaceBar(
              background: Container(
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [kRedStart, kRedEnd],
                  ),
                ),
                child: SafeArea(
                  bottom: false,
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(16, 10, 16, 16),
                    child: Column(
                      children: [
                        const SizedBox(height: 8),
                        const Text(
                          'Laporan',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 22,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                        const SizedBox(height: 4),
                        const Text(
                          'Dashboard Analitik',
                          style: TextStyle(
                            color: Colors.white70,
                            fontSize: 14,
                          ),
                        ),
                        const SizedBox(height: 18),
                        Row(
                          children: [
                            ReportRangeChip(
                              text: 'Harian',
                              selected: _range == TimeRange.daily,
                              onTap: () =>
                                  setState(() => _range = TimeRange.daily),
                            ),
                            const SizedBox(width: 12),
                            ReportRangeChip(
                              text: 'Mingguan',
                              selected: _range == TimeRange.weekly,
                              onTap: () =>
                                  setState(() => _range = TimeRange.weekly),
                            ),
                            const SizedBox(width: 12),
                            ReportRangeChip(
                              text: 'Bulanan',
                              selected: _range == TimeRange.monthly,
                              highlight: true,
                              onTap: () =>
                                  setState(() => _range = TimeRange.monthly),
                            ),
                          ],
                        ),
                        const Spacer(),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),

          // BODY
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 18, 16, 24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // KPI cards
                  Wrap(
                    spacing: 14,
                    runSpacing: 14,
                    children: [
                      ReportKpiCard(
                        icon: Icons.attach_money,
                        title: 'Rp. ${formatCurrency(d.revenueThisPeriod)}',
                        subtitle: _range == TimeRange.monthly
                            ? 'Pendapatan bulan ini'
                            : _range == TimeRange.weekly
                                ? 'Pendapatan minggu ini'
                                : 'Pendapatan hari ini',
                        growthText: d.revenueGrowthText,
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => const ListWorkPage(),
                            ),
                          );
                        },
                      ),
                      ReportKpiCard(
                        icon: Icons.assignment_turned_in_rounded,
                        title: d.jobsDone.toString(),
                        subtitle: 'Pekerjaan Selesai',
                        growthText: d.jobsGrowthText,
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => const ListWorkPage(),
                            ),
                          );
                        },
                      ),
                      ReportKpiCard(
                        icon: Icons.groups_rounded,
                        title: '${d.occupancy}%',
                        subtitle: 'Occupancy Rate',
                        growthText: d.occupancyGrowthText,
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => const DummyDetail(title: 'Detail Occupancy'),
                            ),
                          );
                        },
                      ),
                      ReportKpiCard(
                        icon: Icons.verified_rounded,
                        title: d.avgRating.toStringAsFixed(1),
                        subtitle: 'Rating rata-rata',
                        growthText: d.ratingGrowthText,
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => const DummyDetail(title: 'Detail Rating'),
                            ),
                          );
                        },
                      ),
                    ],
                  ),
                  const SizedBox(height: 18),

                  // Line chart
                  ReportPanel(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const ReportPanelHeader(
                          title: 'Grafik Tren',
                          subtitle: 'Pendapatan & pekerjaan',
                        ),
                        const SizedBox(height: 8),
                        SizedBox(
                          height: 220,
                          child: LineChart(
                            ReportCharts.lineChartData(
                              labels: d.labels,
                              seriesA: d.revenueTrend,
                              colorA: const Color(0xFF7C3AED),
                              seriesB: d.jobsTrend,
                              colorB: const Color(0xFF2563EB),
                            ),
                            duration: const Duration(milliseconds: 400),
                          ),
                        ),
                        const SizedBox(height: 10),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: const [
                            ReportLegend(
                              color: Color(0xFF7C3AED),
                              text: 'Pendapatan (juta)',
                            ),
                            SizedBox(width: 16),
                            ReportLegend(
                              color: Color(0xFF2563EB),
                              text: 'Pekerjaan',
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Donut + Avg queue
                  Row(
                    children: [
                      Expanded(
                        child: ReportPanel(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const ReportPanelHeader(title: 'Jenis Service'),
                              const SizedBox(height: 8),
                              SizedBox(
                                height: 180,
                                child: PieChart(
                                  ReportCharts.donutData(d.serviceBreakdown),
                                  swapAnimationDuration:
                                      const Duration(milliseconds: 350),
                                ),
                              ),
                              const SizedBox(height: 8),
                              Column(
                                children: [
                                  ReportLegendRow(
                                    color: const Color(0xFF7C3AED),
                                    text: 'Service Rutin',
                                    value:
                                        '${d.serviceBreakdown['Service Rutin']!.toInt()}%',
                                  ),
                                  ReportLegendRow(
                                    color: const Color(0xFF22C55E),
                                    text: 'Perbaikan',
                                    value:
                                        '${d.serviceBreakdown['Perbaikan']!.toInt()}%',
                                  ),
                                  ReportLegendRow(
                                    color: const Color(0xFF06B6D4),
                                    text: 'Ganti Onderdil',
                                    value:
                                        '${d.serviceBreakdown['Ganti Onderdil']!.toInt()}%',
                                  ),
                                  ReportLegendRow(
                                    color: const Color(0xFFF59E0B),
                                    text: 'Body Repair',
                                    value:
                                        '${d.serviceBreakdown['Body Repair']!.toInt()}%',
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: ReportPanel(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const ReportPanelHeader(
                                title: 'Avg. Antrian',
                              ),
                              const SizedBox(height: 8),
                              SizedBox(
                                height: 180,
                                child: BarChart(
                                  ReportCharts.barsData(
                                    values: d.avgQueueBars,
                                    labels: const [
                                      'Sen',
                                      'Sel',
                                      'Rab',
                                      'Kam',
                                      'Jum',
                                      'Sab',
                                      'Min'
                                    ],
                                    color: const Color(0xFF7C3AED),
                                  ),
                                  swapAnimationDuration:
                                      const Duration(milliseconds: 350),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),

                  // Peak hour
                  ReportPanel(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const ReportPanelHeader(
                          title: 'Peak Hour',
                          subtitle: 'Jam Sibuk bengkel',
                          trailingIcon: Icons.access_time,
                        ),
                        const SizedBox(height: 8),
                        SizedBox(
                          height: 220,
                          child: BarChart(
                            ReportCharts.barsData(
                              values: d.peakHourBars,
                              labels: d.peakHourLabels,
                              color: const Color(0xFF3B82F6),
                            ),
                            swapAnimationDuration:
                                const Duration(milliseconds: 350),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Operational health
                  ReportPanel(
                    background: const Color(0xFFFFF1F2),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Kesehatan Operasional',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                        const SizedBox(height: 12),
                        Wrap(
                          spacing: 12,
                          runSpacing: 12,
                          children: [
                            ReportHealthTile(
                              title: 'Rata-rata antrian',
                              value: '${d.avgQueue} mobil',
                              tag: 'Normal',
                              tagColor: const Color(0xFF22C55E),
                            ),
                            ReportHealthTile(
                              title: 'Occupancy Bengkel',
                              value: '${d.occupancy}%',
                              tag: 'Tinggi',
                              tagColor: kDanger,
                            ),
                            ReportHealthTile(
                              title: 'Peak Hours',
                              value: d.peakRange,
                              tag: 'Optimal',
                              tagColor: const Color(0xFF3B82F6),
                            ),
                            ReportHealthTile(
                              title: 'Efisiensi',
                              value: '${d.efficiency}%',
                              tag: 'Baik',
                              tagColor: const Color(0xFF22C55E),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 18),

                  SizedBox(
                    width: double.infinity,
                    height: 52,
                    child: ElevatedButton(
                      onPressed: () {},
                      style: ElevatedButton.styleFrom(
                        backgroundColor: kDanger,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                        elevation: 0,
                      ),
                      child: const Text(
                        'Cetak Laporan',
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w700,
                          fontSize: 16,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/* ============================================================
   DUMMY DETAIL PAGES
   ============================================================ */



class DummyDetail extends StatelessWidget {
  const DummyDetail({required this.title, super.key});
  final String title;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: kRedStart,
        title: Text(title),
      ),
      body: Center(
        child: Text(
          '$title\n(Ganti dengan halaman tujuanmu)',
          textAlign: TextAlign.center,
          style: const TextStyle(fontSize: 18),
        ),
      ),
    );
  }
}
