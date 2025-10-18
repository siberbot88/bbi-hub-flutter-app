// report_page_fl_chart.dart
// ReportPage dengan grafik menggunakan fl_chart + data dummy.
// Jalankan langsung atau push dari halaman lain:
// Navigator.push(context, MaterialPageRoute(builder: (_) => const ReportPage()));

import 'dart:math';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

void main() {
  runApp(const MaterialApp(
    debugShowCheckedModeBanner: false,
    home: ReportPage(),
  ));
}

const Color kRedStart = Color(0xFF9B0D0D);
const Color kRedEnd   = Color(0xFFB70F0F);
const Color kDanger   = Color(0xFFDC2626);

enum TimeRange { daily, weekly, monthly }

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

    return Scaffold(
      backgroundColor: Colors.white,
      body: CustomScrollView(
        physics: const BouncingScrollPhysics(),
        slivers: [
          // HEADER
          SliverAppBar(
            pinned: true,
            automaticallyImplyLeading: true,
            backgroundColor: kRedStart,
            elevation: 0,
            expandedHeight: 230,
            flexibleSpace: FlexibleSpaceBar(
              background: Container(
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter, end: Alignment.bottomCenter,
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
                        const Text('Laporan',
                            style: TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.w800)),
                        const SizedBox(height: 4),
                        const Text('Dashboard Analitik',
                            style: TextStyle(color: Colors.white70, fontSize: 14)),
                        const SizedBox(height: 18),
                        Row(
                          children: [
                            _RangeChip(
                              text: 'Harian',
                              selected: _range == TimeRange.daily,
                              onTap: () => setState(() => _range = TimeRange.daily),
                            ),
                            const SizedBox(width: 12),
                            _RangeChip(
                              text: 'Mingguan',
                              selected: _range == TimeRange.weekly,
                              onTap: () => setState(() => _range = TimeRange.weekly),
                            ),
                            const SizedBox(width: 12),
                            _RangeChip(
                              text: 'Bulanan',
                              selected: _range == TimeRange.monthly,
                              highlight: true,
                              onTap: () => setState(() => _range = TimeRange.monthly),
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
                  // KPI CARDS
                  Wrap(
                    spacing: 14,
                    runSpacing: 14,
                    children: [
                      _KpiCard(
                        icon: Icons.attach_money,
                        title: 'Rp. ${_formatCurrency(d.revenueThisPeriod)}',
                        subtitle: _range == TimeRange.monthly
                            ? 'Pendapatan bulan ini'
                            : _range == TimeRange.weekly
                            ? 'Pendapatan minggu ini'
                            : 'Pendapatan hari ini',
                        growthText: d.revenueGrowthText,
                      ),
                      _KpiCard(
                        icon: Icons.assignment_turned_in_rounded,
                        title: d.jobsDone.toString(),
                        subtitle: 'Pekerjaan Selesai',
                        growthText: d.jobsGrowthText,
                      ),
                      _KpiCard(
                        icon: Icons.groups_rounded,
                        title: '${d.occupancy}%',
                        subtitle: 'Occupancy Rate',
                        growthText: d.occupancyGrowthText,
                      ),
                      _KpiCard(
                        icon: Icons.verified_rounded,
                        title: d.avgRating.toStringAsFixed(1),
                        subtitle: 'Rating rata-rata',
                        growthText: d.ratingGrowthText,
                      ),
                    ],
                  ),
                  const SizedBox(height: 18),

                  // LINE CHART: Pendapatan & Pekerjaan
                  _Panel(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const _PanelHeader(
                          title: 'Grafik Tren',
                          subtitle: 'Pendapatan & pekerjaan',
                        ),
                        const SizedBox(height: 8),
                        SizedBox(
                          height: 220,
                          child: LineChart(
                            _lineChartData(
                              labels: d.labels,
                              seriesA: d.revenueTrend,
                              seriesALabel: 'Pendapatan (juta)',
                              colorA: const Color(0xFF7C3AED),
                              seriesB: d.jobsTrend,
                              seriesBLabel: 'Pekerjaan',
                              colorB: const Color(0xFF2563EB),
                            ),
                            duration: const Duration(milliseconds: 400),
                          ),
                        ),
                        const SizedBox(height: 10),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: const [
                            _Legend(color: Color(0xFF7C3AED), text: 'Pendapatan (juta)'),
                            SizedBox(width: 16),
                            _Legend(color: Color(0xFF2563EB), text: 'Pekerjaan'),
                          ],
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),

                  // DONUT + AVG QUEUE
                  Row(
                    children: [
                      Expanded(
                        child: _Panel(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const _PanelHeader(title: 'Jenis Service'),
                              const SizedBox(height: 8),
                              SizedBox(
                                height: 180,
                                child: PieChart(
                                  _donutData(d.serviceBreakdown),
                                  swapAnimationDuration: const Duration(milliseconds: 350),
                                ),
                              ),
                              const SizedBox(height: 8),
                              Column(
                                children: [
                                  _LegendRow(color: const Color(0xFF7C3AED), text: 'Service Rutin', value: '${d.serviceBreakdown['Service Rutin']!.toInt()}%'),
                                  _LegendRow(color: const Color(0xFF22C55E), text: 'Perbaikan', value: '${d.serviceBreakdown['Perbaikan']!.toInt()}%'),
                                  _LegendRow(color: const Color(0xFF06B6D4), text: 'Ganti Onderdil', value: '${d.serviceBreakdown['Ganti Onderdil']!.toInt()}%'),
                                  _LegendRow(color: const Color(0xFFF59E0B), text: 'Body Repair', value: '${d.serviceBreakdown['Body Repair']!.toInt()}%'),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _Panel(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const _PanelHeader(title: 'Avg. Antrian'),
                              const SizedBox(height: 8),
                              SizedBox(
                                height: 180,
                                child: BarChart(
                                  _barsData(
                                    values: d.avgQueueBars,
                                    labels: const ['Sen','Sel','Rab','Kam','Jum','Sab','Min'],
                                    color: const Color(0xFF7C3AED),
                                  ),
                                  swapAnimationDuration: const Duration(milliseconds: 350),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),

                  // PEAK HOUR
                  _Panel(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const _PanelHeader(title: 'Peak Hour', subtitle: 'Jam Sibuk bengkel', trailingIcon: Icons.access_time),
                        const SizedBox(height: 8),
                        SizedBox(
                          height: 220,
                          child: BarChart(
                            _barsData(
                              values: d.peakHourBars,
                              labels: d.peakHourLabels,
                              color: const Color(0xFF3B82F6),
                            ),
                            swapAnimationDuration: const Duration(milliseconds: 350),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),

                  // OPERATIONAL HEALTH
                  _Panel(
                    background: const Color(0xFFFFF1F2),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('Kesehatan Operasional',
                            style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800)),
                        const SizedBox(height: 12),
                        Wrap(
                          spacing: 12,
                          runSpacing: 12,
                          children: [
                            _HealthTile(title: 'Rata-rata antrian', value: '${d.avgQueue} mobil', tag: 'Normal', tagColor: const Color(0xFF22C55E)),
                            _HealthTile(title: 'Occupancy Bengkel', value: '${d.occupancy}%', tag: 'Tinggi', tagColor: kDanger),
                            _HealthTile(title: 'Peak Hours', value: d.peakRange, tag: 'Optimal', tagColor: const Color(0xFF3B82F6)),
                            _HealthTile(title: 'Efisiensi', value: '${d.efficiency}%', tag: 'Baik', tagColor: const Color(0xFF22C55E)),
                          ],
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 18),

                  // PRINT
                  SizedBox(
                    width: double.infinity,
                    height: 52,
                    child: ElevatedButton(
                      onPressed: () {},
                      style: ElevatedButton.styleFrom(
                        backgroundColor: kDanger,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                        elevation: 0,
                      ),
                      child: const Text('Cetak Laporan',
                          style: TextStyle(color: Colors.white, fontWeight: FontWeight.w700, fontSize: 16)),
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

/* =========================
   CHART BUILDERS (fl_chart)
   ========================= */

LineChartData _lineChartData({
  required List<String> labels,
  required List<double> seriesA,
  required String seriesALabel,
  required Color colorA,
  required List<double> seriesB,
  required String seriesBLabel,
  required Color colorB,
}) {
  final maxY = [...seriesA, ...seriesB].reduce(max) * 1.2;

  SideTitles bottomTitles() => SideTitles(
    showTitles: true,
    reservedSize: 28,
    getTitlesWidget: (value, meta) {
      final i = value.toInt();
      if (i < 0 || i >= labels.length) return const SizedBox.shrink();
      return Padding(
        padding: const EdgeInsets.only(top: 6),
        child: Text(labels[i], style: const TextStyle(fontSize: 10, color: Colors.black54)),
      );
    },
  );

  return LineChartData(
    minY: 0,
    maxY: maxY,
    gridData: FlGridData(show: true, drawVerticalLine: false, horizontalInterval: maxY / 4),
    titlesData: FlTitlesData(
      topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
      rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
      leftTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
      bottomTitles: AxisTitles(sideTitles: bottomTitles()),
    ),
    lineBarsData: [
      LineChartBarData(
        spots: List.generate(seriesA.length, (i) => FlSpot(i.toDouble(), seriesA[i])),
        isCurved: true,
        color: colorA,
        barWidth: 3,
        dotData: FlDotData(show: true, dotSize: 3),
      ),
      LineChartBarData(
        spots: List.generate(seriesB.length, (i) => FlSpot(i.toDouble(), seriesB[i])),
        isCurved: true,
        color: colorB,
        barWidth: 3,
        dotData: FlDotData(show: true, dotSize: 3),
      ),
    ],
    borderData: FlBorderData(show: false),
  );
}

PieChartData _donutData(Map<String, double> breakdown) {
  final entries = breakdown.entries.toList();
  final colors = [
    const Color(0xFF7C3AED),
    const Color(0xFF22C55E),
    const Color(0xFF06B6D4),
    const Color(0xFFF59E0B),
  ];
  return PieChartData(
    centerSpaceRadius: 46,
    sectionsSpace: 2,
    sections: List.generate(entries.length, (i) {
      return PieChartSectionData(
        value: entries[i].value,
        color: colors[i % colors.length],
        radius: 34,
        title: '',
      );
    }),
  );
}

BarChartData _barsData({
  required List<double> values,
  required List<String> labels,
  required Color color,
}) {
  final maxY = values.reduce(max) * 1.2;

  return BarChartData(
    maxY: maxY,
    minY: 0,
    gridData: FlGridData(show: true, drawVerticalLine: false, horizontalInterval: maxY / 4),
    titlesData: FlTitlesData(
      topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
      leftTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
      rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
      bottomTitles: AxisTitles(
        sideTitles: SideTitles(
          showTitles: true,
          reservedSize: 26,
          getTitlesWidget: (value, meta) {
            final i = value.toInt();
            if (i < 0 || i >= labels.length) return const SizedBox.shrink();
            return Padding(
              padding: const EdgeInsets.only(top: 6),
              child: Text(labels[i], style: const TextStyle(fontSize: 10, color: Colors.black54)),
            );
          },
        ),
      ),
    ),
    borderData: FlBorderData(show: false),
    barGroups: List.generate(values.length, (i) {
      return BarChartGroupData(
        x: i,
        barRods: [
          BarChartRodData(
            toY: values[i],
            color: color,
            width: 14,
            borderRadius: BorderRadius.circular(6),
          ),
        ],
      );
    }),
  );
}

/* =========================
   UI PARTS
   ========================= */

class _RangeChip extends StatelessWidget {
  const _RangeChip({
    required this.text,
    required this.selected,
    required this.onTap,
    this.highlight = false,
  });

  final String text;
  final bool selected;
  final bool highlight;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Ink(
          height: 44,
          decoration: BoxDecoration(
            color: selected
                ? (highlight ? const Color(0xFFF59E0B) : Colors.white)
                : const Color(0xFF9B0D0D),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Center(
            child: Text(
              text,
              style: TextStyle(
                color: selected
                    ? (highlight ? Colors.white : kDanger)
                    : Colors.white70,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _Panel extends StatelessWidget {
  const _Panel({required this.child, this.background = Colors.white});
  final Widget child;
  final Color background;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 16),
      decoration: BoxDecoration(
        color: background,
        borderRadius: BorderRadius.circular(22),
        boxShadow: const [
          BoxShadow(color: Color(0x11000000), blurRadius: 18, offset: Offset(0, 10)),
        ],
      ),
      child: child,
    );
  }
}

class _PanelHeader extends StatelessWidget {
  const _PanelHeader({required this.title, this.subtitle, this.trailingIcon});
  final String title;
  final String? subtitle;
  final IconData? trailingIcon;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(title, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w800)),
          if (subtitle != null)
            Text(subtitle!, style: const TextStyle(color: Colors.black54, fontSize: 12)),
        ]),
        const Spacer(),
        if (trailingIcon != null) Icon(trailingIcon, color: const Color(0xFF9CA3AF)),
      ],
    );
  }
}

class _KpiCard extends StatelessWidget {
  const _KpiCard({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.growthText,
  });

  final IconData icon;
  final String title;
  final String subtitle;
  final String growthText;

  @override
  Widget build(BuildContext context) {
    final w = (MediaQuery.of(context).size.width - 16 * 2 - 14) / 2;
    return SizedBox(
      width: w,
      child: Container(
        height: 120,
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [Color(0xFF7A0F0F), Color(0xFFB01212)],
            begin: Alignment.topLeft, end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(20),
          boxShadow: const [BoxShadow(color: Color(0x14000000), blurRadius: 12, offset: Offset(0, 6))],
        ),
        child: Stack(
          children: [
            Positioned(
              right: 0, top: 0,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(.15),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.trending_up_rounded, color: Colors.white, size: 14),
                    const SizedBox(width: 4),
                    Text(growthText, style: const TextStyle(color: Colors.white, fontSize: 12)),
                  ],
                ),
              ),
            ),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: 40, height: 40,
                  decoration: BoxDecoration(color: Colors.white.withOpacity(.15), borderRadius: BorderRadius.circular(12)),
                  child: Icon(icon, color: Colors.white),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                    Text(title, maxLines: 1, overflow: TextOverflow.ellipsis,
                        style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.w800)),
                    const SizedBox(height: 2),
                    Text(subtitle, style: const TextStyle(color: Colors.white70, fontSize: 12)),
                  ]),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _Legend extends StatelessWidget {
  const _Legend({required this.color, required this.text});
  final Color color;
  final String text;

  @override
  Widget build(BuildContext context) {
    return Row(children: [
      Container(width: 10, height: 10, decoration: BoxDecoration(color: color, shape: BoxShape.circle)),
      const SizedBox(width: 6),
      Text(text, style: const TextStyle(fontSize: 12, color: Colors.black87)),
    ]);
  }
}

class _LegendRow extends StatelessWidget {
  const _LegendRow({required this.color, required this.text, required this.value});
  final Color color;
  final String text;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 3),
      child: Row(
        children: [
          _Legend(color: color, text: text),
          const Spacer(),
          Text(value, style: const TextStyle(fontWeight: FontWeight.w700)),
        ],
      ),
    );
  }
}

class _HealthTile extends StatelessWidget {
  const _HealthTile({required this.title, required this.value, required this.tag, required this.tagColor});
  final String title;
  final String value;
  final String tag;
  final Color tagColor;

  @override
  Widget build(BuildContext context) {
    final w = (MediaQuery.of(context).size.width - 16 * 2 - 12) / 2;
    return SizedBox(
      width: w,
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(14)),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(title, style: const TextStyle(color: Colors.black54, fontSize: 12)),
          const SizedBox(height: 6),
          Text(value, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w800)),
          const SizedBox(height: 2),
          Text(tag, style: TextStyle(color: tagColor, fontWeight: FontWeight.w700)),
        ]),
      ),
    );
  }
}

/* =========================
   DATA DUMMY & MAPPER
   ========================= */

class ReportData {
  final Map<String, double> serviceBreakdown;
  final List<double> revenueTrend; // juta
  final List<double> jobsTrend; // count
  final List<String> labels;

  final int jobsDone;
  final int occupancy;
  final double avgRating;
  final int revenueThisPeriod;

  final String revenueGrowthText;
  final String jobsGrowthText;
  final String occupancyGrowthText;
  final String ratingGrowthText;

  final List<double> avgQueueBars;
  final List<double> peakHourBars;
  final List<String> peakHourLabels;

  final int avgQueue;
  final String peakRange;
  final int efficiency;

  ReportData({
    required this.serviceBreakdown,
    required this.revenueTrend,
    required this.jobsTrend,
    required this.labels,
    required this.jobsDone,
    required this.occupancy,
    required this.avgRating,
    required this.revenueThisPeriod,
    required this.revenueGrowthText,
    required this.jobsGrowthText,
    required this.occupancyGrowthText,
    required this.ratingGrowthText,
    required this.avgQueueBars,
    required this.peakHourBars,
    required this.peakHourLabels,
    required this.avgQueue,
    required this.peakRange,
    required this.efficiency,
  });

  static ReportData seed() {
    return ReportData(
      serviceBreakdown: const {
        'Service Rutin': 35,
        'Perbaikan': 28,
        'Ganti Onderdil': 22,
        'Body Repair': 15,
      },
      revenueTrend: const [40, 48, 43, 60, 57, 65], // Mei..Okt (juta)
      jobsTrend: const [35, 45, 40, 50, 48, 56],
      labels: const ['Mei','Jun','Jul','Agu','Sep','Okt'],
      jobsDone: 22,
      occupancy: 89,
      avgRating: 4.8,
      revenueThisPeriod: 64700000,
      revenueGrowthText: '+12,5%',
      jobsGrowthText: '+8%',
      occupancyGrowthText: '−3%',
      ratingGrowthText: '+5%',
      avgQueueBars: const [9, 12, 14, 11, 18, 22, 7],
      peakHourBars: const [28, 60, 84, 76, 88, 92, 54, 32], // 08..22
      peakHourLabels: const ['08:00','10:00','12:00','14:00','16:00','18:00','20:00','22:00'],
      avgQueue: 15,
      peakRange: '14:00 - 18:00',
      efficiency: 92,
    );
  }

  ReportData forRange(TimeRange r) {
    if (r == TimeRange.monthly) return this;
    if (r == TimeRange.weekly) {
      return ReportData(
        serviceBreakdown: serviceBreakdown,
        revenueTrend: const [8, 10, 9, 12, 11, 13],
        jobsTrend: const [5, 7, 6, 8, 9, 10],
        labels: const ['Sen','Sel','Rab','Kam','Jum','Sab'],
        jobsDone: 27,
        occupancy: 86,
        avgRating: 4.7,
        revenueThisPeriod: 13200000,
        revenueGrowthText: '+3,1%',
        jobsGrowthText: '+2,6%',
        occupancyGrowthText: '−1%',
        ratingGrowthText: '+1%',
        avgQueueBars: const [10, 13, 15, 12, 18, 21, 8],
        peakHourBars: const [20, 48, 61, 70, 65, 72, 40, 22],
        peakHourLabels: const ['08','10','12','14','16','18','20','22'],
        avgQueue: 14,
        peakRange: '12:00 - 18:00',
        efficiency: 90,
      );
    } else {
      // daily
      return ReportData(
        serviceBreakdown: serviceBreakdown,
        revenueTrend: const [2.1, 3.4, 2.8, 3.0, 3.6, 3.1],
        jobsTrend: const [3, 5, 4, 6, 7, 6],
        labels: const ['08','10','12','14','16','18'],
        jobsDone: 5,
        occupancy: 82,
        avgRating: 4.8,
        revenueThisPeriod: 3600000,
        revenueGrowthText: '+0,8%',
        jobsGrowthText: '+1%',
        occupancyGrowthText: '+0,5%',
        ratingGrowthText: '+0,2%',
        avgQueueBars: const [4, 6, 8, 12, 10, 6, 2],
        peakHourBars: const [6, 14, 22, 20, 18, 8, 4, 2],
        peakHourLabels: const ['08','10','12','14','16','18','20','22'],
        avgQueue: 12,
        peakRange: '12:00 - 16:00',
        efficiency: 91,
      );
    }
  }
}

/* =========================
   HELPERS
   ========================= */
String _formatCurrency(int value) {
  final s = value.toString();
  final buf = StringBuffer();
  for (int i = 0; i < s.length; i++) {
    final idx = s.length - i;
    buf.write(s[i]);
    if (idx > 1 && idx % 3 == 1) buf.write('.');
  }
  return buf.toString();
}
