import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

import 'package:bengkel_online_flutter/core/models/service.dart';
import 'package:bengkel_online_flutter/feature/owner/providers/service_provider.dart';

// SESUAIKAN jika path berbeda
import 'package:bengkel_online_flutter/feature/owner/screens/detailWork.dart';

const Color _gradStart = Color(0xFF9B0D0D);
const Color _gradEnd   = Color(0xFFB70F0F);
const Color _danger    = Color(0xFFDC2626);

enum WorkStatus { pending, process, done }

class WorkItem {
  final String id;
  final String workOrder;
  final String customer;
  final String vehicle;
  final String plate;
  final String service;
  final DateTime? schedule;
  final String mechanic;
  final num? price;
  final WorkStatus status;

  WorkItem({
    required this.id,
    required this.workOrder,
    required this.customer,
    required this.vehicle,
    required this.plate,
    required this.service,
    required this.schedule,
    required this.mechanic,
    required this.price,
    required this.status,
  });
}

class ListWorkPage extends StatefulWidget {
  const ListWorkPage({super.key, this.workshopUuid});

  /// Filter server-side agar hanya menampilkan service milik bengkel ini.
  /// Jika null, server akan mengembalikan seluruh service (tidak direkomendasikan).
  final String? workshopUuid;

  @override
  State<ListWorkPage> createState() => _ListWorkPageState();
}

class _ListWorkPageState extends State<ListWorkPage> {
  final TextEditingController _search = TextEditingController();
  WorkStatus _filter = WorkStatus.pending;

  @override
  void initState() {
    super.initState();
    SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle.light);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<ServiceProvider>().fetchServices(
        workshopUuid: widget.workshopUuid,
      );
    });
  }

  @override
  void dispose() {
    _search.dispose();
    super.dispose();
  }

  // Map ServiceModel -> WorkItem
  WorkItem _map(ServiceModel s) {
    final status = _mapStatus(s.status);

    final vehicleName = s.vehicle?.name ??
        '${s.vehicle?.brand ?? ''} ${s.vehicle?.model ?? ''}'.trim();

    final plate = s.vehicle?.plateNumber ??
        // fallback jika model kendaraan punya key berbeda
        (tryOrNull(() => (s as dynamic).vehicle?.plate) as String?) ??
        '-';

    return WorkItem(
      id: s.id,
      workOrder: s.code,
      customer: s.customer?.name ?? '-',
      vehicle: vehicleName.isEmpty ? '-' : vehicleName,
      plate: plate,
      service: s.name,
      schedule: s.scheduledDate,
      mechanic: s.mechanicName.isEmpty ? '-' : s.mechanicName,
      price: s.price,
      status: status,
    );
  }

  WorkStatus _mapStatus(String raw) {
    switch (raw.toLowerCase()) {
      case 'in progress':
        return WorkStatus.process;
      case 'completed':
        return WorkStatus.done;
      case 'accept':
      case 'pending':
      default:
        return WorkStatus.pending;
    }
  }

  bool _matchTab(ServiceModel s) {
    final st = s.status.toLowerCase();
    switch (_filter) {
      case WorkStatus.pending:
        return st == 'pending' || st == 'accept' || st.isEmpty;
      case WorkStatus.process:
        return st == 'in progress';
      case WorkStatus.done:
        return st == 'completed';
    }
  }

  List<WorkItem> _filtered(List<ServiceModel> services) {
    final q = _search.text.trim().toLowerCase();
    final items = services.where(_matchTab).map(_map).toList();
    if (q.isEmpty) return items;
    return items.where((e) {
      return e.workOrder.toLowerCase().contains(q) ||
          e.customer.toLowerCase().contains(q) ||
          e.vehicle.toLowerCase().contains(q) ||
          e.plate.toLowerCase().contains(q) ||
          e.mechanic.toLowerCase().contains(q) ||
          e.service.toLowerCase().contains(q);
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    final media = MediaQuery.of(context);
    final prov = context.watch<ServiceProvider>();
    final list = _filtered(prov.items);

    return Scaffold(
      backgroundColor: Colors.white,
      body: Stack(
        children: [
          Positioned.fill(
            child: Container(
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  colors: [_gradStart, _gradEnd],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
              ),
            ),
          ),
          CustomScrollView(
            physics: const BouncingScrollPhysics(),
            slivers: [
              SliverAppBar(
                pinned: true,
                backgroundColor: _gradStart,
                elevation: 0,
                expandedHeight: 220,
                leading: IconButton(
                  icon: const Icon(Icons.arrow_back, color: Colors.white),
                  onPressed: () => Navigator.maybePop(context),
                ),
                actions: [
                  IconButton(
                    onPressed: () => context.read<ServiceProvider>().fetchServices(
                      workshopUuid: widget.workshopUuid,
                    ),
                    icon: const Icon(Icons.refresh, color: Colors.white),
                    tooltip: 'Refresh',
                  ),
                ],
                flexibleSpace: FlexibleSpaceBar(
                  background: Container(
                    decoration: const BoxDecoration(
                      gradient: LinearGradient(
                        colors: [_gradStart, _gradEnd],
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                      ),
                    ),
                    child: SafeArea(
                      bottom: false,
                      child: Padding(
                        padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            const SizedBox(height: 4),
                            const Text(
                              'Laporan',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 24,
                                fontWeight: FontWeight.w900,
                              ),
                            ),
                            const SizedBox(height: 4),
                            const Text(
                              'Daftar Pekerjaan',
                              style:
                              TextStyle(color: Colors.white70, fontSize: 14),
                            ),
                            const SizedBox(height: 18),
                            // Search
                            Container(
                              height: 56,
                              decoration: const BoxDecoration(
                                color: Color(0xFFF0F1F5),
                                borderRadius: BorderRadius.only(
                                  topLeft: Radius.circular(50),
                                  bottomLeft: Radius.circular(50),
                                  bottomRight: Radius.circular(30),
                                ),
                              ),
                              padding:
                              const EdgeInsets.symmetric(horizontal: 18),
                              child: Row(
                                children: [
                                  const Icon(Icons.search, color: Colors.grey),
                                  const SizedBox(width: 10),
                                  Expanded(
                                    child: TextField(
                                      controller: _search,
                                      decoration: const InputDecoration(
                                        hintText:
                                        'Cari kendaraan, customer, atau plat',
                                        border: InputBorder.none,
                                      ),
                                      onChanged: (_) => setState(() {}),
                                    ),
                                  ),
                                  IconButton(
                                    onPressed: () {
                                      _search.clear();
                                      setState(() {});
                                    },
                                    icon: const Icon(Icons.tune,
                                        color: Colors.grey),
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(height: 14),
                            // Filter chips
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                _StatusChip(
                                  label: 'Pending',
                                  icon: Icons.error_outline,
                                  selected: _filter == WorkStatus.pending,
                                  onTap: () => setState(
                                          () => _filter = WorkStatus.pending),
                                ),
                                const SizedBox(width: 16),
                                _StatusChip(
                                  label: 'Process',
                                  icon: Icons.schedule_rounded,
                                  selected: _filter == WorkStatus.process,
                                  onTap: () => setState(
                                          () => _filter = WorkStatus.process),
                                ),
                                const SizedBox(width: 16),
                                _StatusChip(
                                  label: 'Selesai',
                                  icon: Icons.verified_rounded,
                                  selected: _filter == WorkStatus.done,
                                  onTap: () =>
                                      setState(() => _filter = WorkStatus.done),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ),

              // konten
              if (prov.loading)
                const SliverFillRemaining(
                  child: Center(
                      child:
                      CircularProgressIndicator(color: Colors.white)),
                )
              else if (prov.lastError != null)
                SliverFillRemaining(
                  hasScrollBody: false,
                  child: Center(
                    child: Padding(
                      padding: const EdgeInsets.all(24.0),
                      child: Text(
                        prov.lastError!,
                        textAlign: TextAlign.center,
                        style: const TextStyle(color: Colors.white),
                      ),
                    ),
                  ),
                )
              else
                SliverPadding(
                  padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
                  sliver: SliverList.separated(
                    itemCount: list.length,
                    separatorBuilder: (_, __) =>
                    const SizedBox(height: 14),
                    itemBuilder: (context, i) =>
                        _WorkCard(item: list[i]),
                  ),
                ),

              SliverToBoxAdapter(
                child: SizedBox(height: media.padding.bottom + 8),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

/* ---------- Widgets ---------- */

class _StatusChip extends StatelessWidget {
  const _StatusChip({
    required this.label,
    required this.icon,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final IconData icon;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final bg = selected ? _danger : const Color(0xFFE9ECEF);
    final fg = selected ? Colors.white : const Color(0xFF9CA3AF);

    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        padding:
        const EdgeInsets.symmetric(horizontal: 18, vertical: 10),
        decoration: BoxDecoration(
          color: bg,
          borderRadius: BorderRadius.circular(28),
          boxShadow: selected
              ? [const BoxShadow(color: Color(0x33000000), blurRadius: 8)]
              : null,
        ),
        child: Row(
          children: [
            Icon(icon, size: 18, color: fg),
            const SizedBox(width: 8),
            Text(label,
                style: TextStyle(
                    color: fg, fontWeight: FontWeight.w700)),
          ],
        ),
      ),
    );
  }
}

class _WorkCard extends StatelessWidget {
  const _WorkCard({required this.item});
  final WorkItem item;

  void _openDetail(BuildContext context) {
    if (item.id.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('ID service tidak tersedia')),
      );
      return;
    }
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => DetailWorkPage(serviceId: item.id),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final price =
    item.price == null ? 'RP. -' : 'RP. ${_rupiah(item.price!)}';

    return Material(
      color: Colors.white,
      elevation: 0,
      borderRadius: BorderRadius.circular(22),
      child: InkWell(
        borderRadius: BorderRadius.circular(22),
        onTap: () => _openDetail(context),
        child: Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(22),
            boxShadow: const [
              BoxShadow(
                color: Color(0x22000000),
                blurRadius: 18,
                offset: Offset(0, 10),
              ),
            ],
          ),
          child: Padding(
            padding: const EdgeInsets.fromLTRB(20, 16, 12, 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // header
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: Text(
                        item.workOrder,
                        style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.w900,
                          letterSpacing: .2,
                        ),
                      ),
                    ),
                    IconButton(
                      onPressed: () {},
                      icon: const Icon(Icons.more_vert,
                          color: Colors.black54),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    const Icon(Icons.person_2_outlined,
                        size: 18, color: Colors.black45),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        item.customer,
                        style: const TextStyle(
                          fontSize: 16,
                          color: Colors.black54,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),

                // vehicle
                Container(
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF3F4F6),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.directions_car,
                          color: Colors.black54),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Column(
                          crossAxisAlignment:
                          CrossAxisAlignment.start,
                          children: [
                            Text(
                              item.vehicle,
                              style: const TextStyle(
                                  fontWeight: FontWeight.w700,
                                  fontSize: 16),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              item.plate,
                              style: const TextStyle(
                                  color: Colors.black54,
                                  fontSize: 13),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 16),
                Text(item.service,
                    style: const TextStyle(
                        fontSize: 16, fontWeight: FontWeight.w600)),
                const SizedBox(height: 16),
                const Divider(height: 1),
                const SizedBox(height: 12),

                // schedule + price
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Icon(Icons.event_outlined,
                        size: 18, color: Colors.black45),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        _dateTime(item.schedule),
                        style: const TextStyle(
                            color: Colors.black54, fontSize: 14),
                      ),
                    ),
                    Text(
                      price,
                      style: const TextStyle(
                        color: Color(0xFF7A0F0F),
                        fontSize: 18,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),

                // mechanic name
                Row(
                  children: [
                    const Icon(Icons.groups_2_outlined,
                        size: 18, color: Colors.black45),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        item.mechanic,
                        style: const TextStyle(
                            color: Colors.black45, fontSize: 14),
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 16),
                SizedBox(
                  width: double.infinity,
                  height: 48,
                  child: ElevatedButton(
                    onPressed: () => _openDetail(context),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: _danger,
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12)),
                      elevation: 0,
                    ),
                    child: const Text(
                      'Lihat Detail',
                      style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w800,
                          fontSize: 16),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/* ---------- Helpers ---------- */

String _dateTime(DateTime? dt) {
  if (dt == null) return '-';
  const bulan = [
    'Jan','Feb','Mar','Apr','Mei','Jun','Jul','Agu','Sep','Okt','Nov','Des'
  ];
  final tgl = '${dt.day} ${bulan[dt.month - 1]} ${dt.year}';
  final hh = dt.hour.toString().padLeft(2, '0');
  final mm = dt.minute.toString().padLeft(2, '0');
  return '$tgl - $hh:$mm';
}

String _rupiah(num nominal) {
  final s = nominal.toInt().toString();
  final buf = StringBuffer();
  for (int i = 0; i < s.length; i++) {
    final rev = s.length - i;
    buf.write(s[i]);
    if (rev > 1 && rev % 3 == 1) buf.write('.');
  }
  return buf.toString();
}

/// Helper aman untuk akses properti dynamic
T? tryOrNull<T>(T Function() f) {
  try { return f(); } catch (_) { return null; }
}
