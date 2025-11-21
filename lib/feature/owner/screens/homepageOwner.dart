import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

import 'package:bengkel_online_flutter/core/services/auth_provider.dart';
import 'package:bengkel_online_flutter/feature/owner/providers/service_provider.dart';
import 'package:bengkel_online_flutter/core/models/service.dart';
import 'package:bengkel_online_flutter/feature/owner/screens/listWork.dart';
import 'package:bengkel_online_flutter/feature/owner/screens/staffManagement.dart';
import 'package:bengkel_online_flutter/feature/owner/screens/reportPages.dart';

const Color primaryRed = Color(0xFFB70F0F);
const Color gradientRedStart = Color(0xFF9B0D0D);
const Color gradientRedEnd = Color(0xFFB70F0F);

enum SummaryRange { today, week, month }

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  SummaryRange _range = SummaryRange.today;

  @override
  void initState() {
    super.initState();
    // ambil data service saat dashboard dibuka
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final auth = context.read<AuthProvider>();
      final wsId = _pickWorkshopUuid(auth.user);
      context.read<ServiceProvider>().fetchServices(
        workshopUuid: wsId,
        includeExtras: true,
        page: 1,
        perPage: 50,
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle.light);

    final auth = context.watch<AuthProvider>();
    final userName = auth.user?.name ?? auth.user?.username ?? 'Owner';

    final now = DateTime.now();
    final tanggal =
        '${_dayNameId(now.weekday)}, ${now.day} ${_monthNameId(now.month)} ${now.year}';

    final serviceProv = context.watch<ServiceProvider>();
    final services = serviceProv.items;

    final summary = _buildSummary(services, _range);
    final latest = services.take(5).toList();

    return Scaffold(
      backgroundColor: Colors.white,
      body: CustomScrollView(
        physics: const BouncingScrollPhysics(),
        slivers: [
          SliverAppBar(
            backgroundColor: gradientRedStart,
            pinned: true,
            expandedHeight: 420,
            elevation: 0,
            flexibleSpace: FlexibleSpaceBar(
              background: Container(
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    colors: [gradientRedStart, gradientRedEnd],
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                  ),
                ),
                child: Stack(
                  children: [
                    Positioned(
                      right: -20,
                      bottom: 0,
                      child: Image.asset(
                        'assets/image/marquez.png',
                        height: 359,
                      ),
                    ),
                    SafeArea(
                      child: Padding(
                        padding: const EdgeInsets.all(20),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: const [
                                Icon(Icons.menu, color: Colors.white),
                                SizedBox(width: 10),
                                Text(
                                  'BBI HUB +',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                Spacer(),
                                CircleAvatar(
                                  radius: 18,
                                  backgroundColor: Colors.white,
                                  child:
                                  Icon(Icons.person, color: Colors.black),
                                ),
                              ],
                            ),
                            const SizedBox(height: 12),
                            const Text(
                              'Dashboard Owner',
                              style: TextStyle(
                                color: Colors.white70,
                                fontSize: 13,
                              ),
                            ),
                            const SizedBox(height: 6),
                            Text(
                              'Hallo, $userName',
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            Text(
                              tanggal,
                              style: const TextStyle(color: Colors.white70),
                            ),
                            const SizedBox(height: 20),
                            const Spacer(),
                            _MiniDashboard(
                              range: _range,
                              onRangeChanged: (r) =>
                                  setState(() => _range = r),
                              pendapatan: summary.revenue,
                              totalJob: summary.totalJob,
                              totalSelesai: summary.totalDone,
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),

          // BODY
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 24, 16, 24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Menu Cepat',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 12),
                  _QuickMenuRow(onTapPekerjaan: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => const ListWorkPage(),
                      ),
                    );
                  }, onTapKaryawan: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => const ManajemenKaryawanPage(),
                      ),
                    );
                  }, onTapLaporan: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => const ReportPage(),
                      ),
                    );
                  }),
                  const SizedBox(height: 28),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'Pekerjaan Terbaru',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      TextButton(
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => const ListWorkPage(),
                            ),
                          );
                        },
                        child: const Text(
                          'Lihat semua',
                          style: TextStyle(color: primaryRed),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  if (serviceProv.loading)
                    const Center(
                      child: Padding(
                        padding: EdgeInsets.all(24.0),
                        child: CircularProgressIndicator(),
                      ),
                    )
                  else if (latest.isEmpty)
                    const Padding(
                      padding: EdgeInsets.symmetric(vertical: 32),
                      child: Center(
                        child: Text('Belum ada pekerjaan'),
                      ),
                    )
                  else
                    Column(
                      children: latest.map((s) {
                        final c = s.customer;
                        final v = s.vehicle;
                        final vehicleText = [
                          if ((v?.brand ?? '').isNotEmpty) v!.brand,
                          if ((v?.model ?? '').isNotEmpty) v!.model,
                          if ((v?.year ?? '').toString().isNotEmpty)
                            v!.year.toString(),
                          if ((v?.plateNumber ?? '').isNotEmpty)
                            '- ${v!.plateNumber}',
                        ].whereType<String>().join(' ');

                        return _JobCard(
                          orderId: s.code,
                          name: c?.name ?? '-',
                          vehicle: vehicleText.isEmpty ? '-' : vehicleText,
                          service: s.name,
                          timeAgo: _timeAgo(s.createdAt ?? s.scheduledDate),
                          status: _statusLabel(s.status),
                          statusColor: _statusColor(s.status),
                          showRating:
                          s.status.toLowerCase() == 'completed',
                        );
                      }).toList(),
                    ),
                  const SizedBox(height: 32),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/* ===================== MINI DASHBOARD ===================== */

class _MiniDashboard extends StatelessWidget {
  final SummaryRange range;
  final ValueChanged<SummaryRange> onRangeChanged;
  final num pendapatan;
  final int totalJob;
  final int totalSelesai;

  const _MiniDashboard({
    required this.range,
    required this.onRangeChanged,
    required this.pendapatan,
    required this.totalJob,
    required this.totalSelesai,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      width: double.infinity,
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [
            Color(0xFF510707),
            Color(0xFF9B0D0D),
            Color(0xFFB70F0F),
          ],
          begin: Alignment.topCenter,
          end: Alignment.centerRight,
        ),
        borderRadius: BorderRadius.circular(20),
      ),
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          Row(
            children: [
              _RangeTab(
                label: 'Hari ini',
                selected: range == SummaryRange.today,
                onTap: () => onRangeChanged(SummaryRange.today),
              ),
              _RangeTab(
                label: 'Minggu ini',
                selected: range == SummaryRange.week,
                onTap: () => onRangeChanged(SummaryRange.week),
              ),
              _RangeTab(
                label: 'Bulan ini',
                selected: range == SummaryRange.month,
                onTap: () => onRangeChanged(SummaryRange.month),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _SummaryCard(
                value: 'Rp ${_rupiah(pendapatan)}',
                label: 'Pendapatan',
                growth: '-',
              ),
              const SizedBox(width: 8),
              _SummaryCard(
                value: '$totalJob',
                label: 'Total job',
                growth: '-',
              ),
              const SizedBox(width: 8),
              _SummaryCard(
                value: '$totalSelesai',
                label: 'Total Selesai',
                growth: '-',
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _RangeTab extends StatelessWidget {
  final String label;
  final bool selected;
  final VoidCallback onTap;

  const _RangeTab({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final bg = selected ? Colors.white : const Color(0xFF9B0D0D);
    final fg = selected ? primaryRed : Colors.white;

    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          margin: const EdgeInsets.symmetric(horizontal: 4),
          padding: const EdgeInsets.symmetric(vertical: 10),
          decoration: BoxDecoration(
            color: bg,
            borderRadius: BorderRadius.circular(12),
          ),
          alignment: Alignment.center,
          child: Text(
            label,
            style: TextStyle(
              color: fg,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ),
    );
  }
}

class _SummaryCard extends StatelessWidget {
  final String value, label, growth;

  const _SummaryCard({
    required this.value,
    required this.label,
    required this.growth,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: SizedBox(
        height: 100,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 10),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Text(
                value,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: primaryRed,
                ),
              ),
              Text(
                label,
                style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                ),
              ),
              Text(
                growth.isNotEmpty ? growth : '-',
                style: const TextStyle(
                  fontSize: 12,
                  color: Colors.green,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/* ======================== QUICK MENU ======================== */

class _QuickMenuRow extends StatelessWidget {
  final VoidCallback onTapPekerjaan;
  final VoidCallback onTapKaryawan;
  final VoidCallback onTapLaporan;

  const _QuickMenuRow({
    required this.onTapPekerjaan,
    required this.onTapKaryawan,
    required this.onTapLaporan,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        _QuickMenuItem(
          icon: Icons.build,
          label: 'Pekerjaan',
          onTap: onTapPekerjaan,
        ),
        _QuickMenuItem(
          icon: Icons.people,
          label: 'Karyawan',
          onTap: onTapKaryawan,
        ),
        _QuickMenuItem(
          icon: Icons.pie_chart,
          label: 'Laporan',
          onTap: onTapLaporan,
        ),
      ],
    );
  }
}

class _QuickMenuItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;

  const _QuickMenuItem({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: InkWell(
        borderRadius: BorderRadius.circular(10),
        onTap: onTap,
        child: Container(
          height: 80,
          margin: const EdgeInsets.symmetric(horizontal: 4),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(10),
            boxShadow: const [
              BoxShadow(
                color: Color.fromRGBO(0, 0, 0, 0.08),
                blurRadius: 22,
                offset: Offset(0, 0),
              ),
            ],
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: const Color(0xFFDC2626),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(icon, color: Colors.white),
              ),
              const SizedBox(height: 6),
              Text(label, style: const TextStyle(fontSize: 12)),
            ],
          ),
        ),
      ),
    );
  }
}

/* ========================== JOB CARD ======================== */

class _JobCard extends StatelessWidget {
  final String orderId, name, vehicle, service, timeAgo, status;
  final Color statusColor;
  final bool showRating;

  const _JobCard({
    required this.orderId,
    required this.name,
    required this.vehicle,
    required this.service,
    required this.timeAgo,
    required this.status,
    required this.statusColor,
    this.showRating = false,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 1,
      color: Colors.white,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  orderId,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                  ),
                ),
                Container(
                  padding:
                  const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: statusColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Text(
                    status,
                    style: TextStyle(
                      color: statusColor,
                      fontWeight: FontWeight.bold,
                      fontSize: 12,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 6),
            Text(name, style: const TextStyle(color: Colors.black87)),
            Text(vehicle, style: const TextStyle(color: Colors.black54)),
            const SizedBox(height: 8),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.grey[100],
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                service,
                style: const TextStyle(fontWeight: FontWeight.w500),
              ),
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Text(
                  timeAgo,
                  style: const TextStyle(
                    color: Colors.grey,
                    fontSize: 12,
                  ),
                ),
                if (showRating) const Spacer(),
                if (showRating)
                  Row(
                    children: List.generate(
                      5,
                          (index) => const Icon(
                        Icons.star,
                        color: Colors.amber,
                        size: 16,
                      ),
                    ),
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

/* ========================= HELPERS ========================== */

class _SummaryData {
  final num revenue;
  final int totalJob;
  final int totalDone;

  _SummaryData({
    required this.revenue,
    required this.totalJob,
    required this.totalDone,
  });
}

_SummaryData _buildSummary(List<ServiceModel> list, SummaryRange range) {
  final now = DateTime.now();

  bool inRange(ServiceModel s) {
    final d = s.scheduledDate ?? s.createdAt ?? s.updatedAt;
    if (d == null) return false;

    switch (range) {
      case SummaryRange.today:
        return d.year == now.year &&
            d.month == now.month &&
            d.day == now.day;
      case SummaryRange.week:
        final diff = now.difference(
          DateTime(d.year, d.month, d.day),
        );
        return !diff.isNegative && diff.inDays < 7;
      case SummaryRange.month:
        return d.year == now.year && d.month == now.month;
    }
  }

  num revenue = 0;
  int totalJob = 0;
  int totalDone = 0;

  for (final s in list.where(inRange)) {
    final status = s.status.toLowerCase();

    if (status == 'completed') {
      totalDone++;
      revenue += _serviceRevenue(s);
    } else if (status != 'cancelled') {
      totalJob++;
    }
  }

  return _SummaryData(
    revenue: revenue,
    totalJob: totalJob,
    totalDone: totalDone,
  );
}

num _serviceRevenue(ServiceModel s) {
  final partsTotal = (s.items ?? const [])
      .fold<num>(0, (a, it) => a + (it.subtotal ?? 0));
  return (s.price ?? 0) + partsTotal;
}

String _timeAgo(DateTime? dt) {
  if (dt == null) return '-';

  final now = DateTime.now();
  var diff = now.difference(dt);
  if (diff.isNegative) diff = Duration.zero;

  if (diff.inMinutes < 1) return 'Baru saja';
  if (diff.inMinutes < 60) return '${diff.inMinutes} menit yang lalu';
  if (diff.inHours < 24) return '${diff.inHours} jam yang lalu';
  if (diff.inDays == 1) return 'Kemarin';
  if (diff.inDays < 7) return '${diff.inDays} hari yang lalu';

  final weeks = diff.inDays ~/ 7;
  if (weeks < 4) return '$weeks minggu yang lalu';

  final months = diff.inDays ~/ 30;
  if (months < 12) return '$months bulan yang lalu';

  final years = diff.inDays ~/ 365;
  return '$years tahun yang lalu';
}

String _dayNameId(int weekday) {
  switch (weekday) {
    case DateTime.monday:
      return 'Senin';
    case DateTime.tuesday:
      return 'Selasa';
    case DateTime.wednesday:
      return 'Rabu';
    case DateTime.thursday:
      return 'Kamis';
    case DateTime.friday:
      return 'Jumat';
    case DateTime.saturday:
      return 'Sabtu';
    case DateTime.sunday:
      return 'Minggu';
    default:
      return '';
  }
}

String _monthNameId(int month) {
  const bulan = [
    'Jan',
    'Feb',
    'Mar',
    'Apr',
    'Mei',
    'Jun',
    'Jul',
    'Agu',
    'Sep',
    'Okt',
    'Nov',
    'Des',
  ];
  return bulan[month - 1];
}

String _rupiah(num n) {
  final s = n.toInt().toString();
  final b = StringBuffer();
  for (int i = 0; i < s.length; i++) {
    final rev = s.length - i;
    b.write(s[i]);
    if (rev > 1 && rev % 3 == 1) b.write('.');
  }
  return b.toString();
}

String _statusLabel(String raw) {
  switch (raw.toLowerCase()) {
    case 'completed':
      return 'Selesai';
    case 'in progress':
    case 'accept':
      return 'Process';
    case 'cancelled':
      return 'Batal';
    default:
      return 'Pending';
  }
}

Color _statusColor(String raw) {
  switch (raw.toLowerCase()) {
    case 'completed':
      return Colors.green;
    case 'in progress':
    case 'accept':
      return Colors.orange;
    case 'cancelled':
      return Colors.grey;
    default:
      return Colors.amber;
  }
}

String? _pickWorkshopUuid(dynamic user) {
  if (user == null) return null;
  try {
    final ws = user.workshops as List?;
    if (ws != null && ws.isNotEmpty) {
      final first = ws.first;
      try {
        final id = (first.id ?? first['id']) as String?;
        if (id != null && id.isNotEmpty) return id;
      } catch (_) {}
    }
  } catch (_) {}

  try {
    final emp = user.employment;
    final w = emp?.workshop ?? emp['workshop'];
    if (w != null) {
      try {
        final id = (w.id ?? w['id']) as String?;
        if (id != null && id.isNotEmpty) return id;
      } catch (_) {}
    }
  } catch (_) {}

  return null;
}
