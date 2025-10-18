// list_work_page_fixed.dart
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

void main() {
  runApp(const MaterialApp(
    debugShowCheckedModeBanner: false,
    home: ListWorkPage(),
  ));
}

const Color _gradStart = Color(0xFF9B0D0D);
const Color _gradEnd   = Color(0xFFB70F0F);
const Color _danger    = Color(0xFFDC2626);

enum WorkStatus { pending, process, done }

class WorkItem {
  final String workOrder;
  final String customer;
  final String vehicle;
  final String plate;
  final String service;
  final DateTime schedule;
  final String mechanic;
  final int? price;
  final WorkStatus status;

  WorkItem({
    required this.workOrder,
    required this.customer,
    required this.vehicle,
    required this.plate,
    required this.service,
    required this.schedule,
    required this.mechanic,
    this.price,
    required this.status,
  });
}

class ListWorkPage extends StatefulWidget {
  const ListWorkPage({super.key});

  @override
  State<ListWorkPage> createState() => _ListWorkPageState();
}

class _ListWorkPageState extends State<ListWorkPage> {
  final TextEditingController _search = TextEditingController();
  WorkStatus _filter = WorkStatus.pending;

  late final List<WorkItem> _all = _dummy();

  List<WorkItem> get _filtered {
    final q = _search.text.trim().toLowerCase();
    final byStatus = _all.where((e) => e.status == _filter);
    if (q.isEmpty) return byStatus.toList();
    return byStatus.where((e) {
      return e.workOrder.toLowerCase().contains(q) ||
          e.customer.toLowerCase().contains(q) ||
          e.vehicle.toLowerCase().contains(q) ||
          e.plate.toLowerCase().contains(q) ||
          e.mechanic.toLowerCase().contains(q) ||
          e.service.toLowerCase().contains(q);
    }).toList();
  }

  @override
  void initState() {
    super.initState();
    SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle.light);
  }

  @override
  void dispose() {
    _search.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final media = MediaQuery.of(context);

    return Scaffold(
      backgroundColor: Colors.white,
      body: Stack(
        children: [
          // BACKGROUND gradient full, jadi overscroll tidak "kepotong".
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

          // CONTENT
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
                            const Text('Laporan',
                                style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 24,
                                    fontWeight: FontWeight.w900)),
                            const SizedBox(height: 4),
                            const Text('Daftar Pekerjaan',
                                style: TextStyle(
                                    color: Colors.white70, fontSize: 14)),
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
                                  selected:
                                  _filter == WorkStatus.pending,
                                  onTap: () => setState(() =>
                                  _filter = WorkStatus.pending),
                                ),
                                const SizedBox(width: 16),
                                _StatusChip(
                                  label: 'Process',
                                  icon: Icons.schedule_rounded,
                                  selected:
                                  _filter == WorkStatus.process,
                                  onTap: () => setState(() =>
                                  _filter = WorkStatus.process),
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

              // HAPUS bar gradient 12px yang bikin garis merah. Ganti padding top list.
              SliverPadding(
                padding: const EdgeInsets.fromLTRB(16, 16, 16, 24), // top 16 supaya tidak mepet
                sliver: SliverList.separated(
                  itemCount: _filtered.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 14),
                  itemBuilder: (context, i) {
                    final w = _filtered[i];
                    return _WorkCard(item: w);
                  },
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
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 10),
        decoration: BoxDecoration(
          color: bg,
          borderRadius: BorderRadius.circular(28),
          boxShadow:
          selected ? [const BoxShadow(color: Color(0x33000000), blurRadius: 8)] : null,
        ),
        child: Row(
          children: [
            Icon(icon, size: 18, color: fg),
            const SizedBox(width: 8),
            Text(label, style: TextStyle(color: fg, fontWeight: FontWeight.w700)),
          ],
        ),
      ),
    );
  }
}

class _WorkCard extends StatelessWidget {
  const _WorkCard({required this.item});
  final WorkItem item;

  @override
  Widget build(BuildContext context) {
    final price = item.price == null ? 'RP. -' : 'RP. ${_rupiah(item.price!)}';

    return Material(
      color: Colors.white,
      elevation: 0,
      borderRadius: BorderRadius.circular(22),
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
                    child: Text(item.workOrder,
                        style: const TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.w900,
                            letterSpacing: .2)),
                  ),
                  IconButton(
                    onPressed: () {},
                    icon: const Icon(Icons.more_vert, color: Colors.black54),
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
                    child: Text(item.customer,
                        style: const TextStyle(
                            fontSize: 16,
                            color: Colors.black54,
                            fontWeight: FontWeight.w600)),
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
                    const Icon(Icons.directions_car, color: Colors.black54),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(item.vehicle,
                              style: const TextStyle(
                                  fontWeight: FontWeight.w700, fontSize: 16)),
                          const SizedBox(height: 2),
                          Text(item.plate,
                              style: const TextStyle(
                                  color: Colors.black54, fontSize: 13)),
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
                    child: Text(_dateTime(item.schedule),
                        style: const TextStyle(
                            color: Colors.black54, fontSize: 14)),
                  ),
                  Text(price,
                      style: const TextStyle(
                          color: Color(0xFF7A0F0F),
                          fontSize: 18,
                          fontWeight: FontWeight.w800)),
                ],
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  const Icon(Icons.groups_2_outlined,
                      size: 18, color: Colors.black45),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(item.mechanic,
                        style: const TextStyle(
                            color: Colors.black45, fontSize: 14)),
                  ),
                ],
              ),

              const SizedBox(height: 16),
              SizedBox(
                width: double.infinity,
                height: 48,
                child: ElevatedButton(
                  onPressed: () {},
                  style: ElevatedButton.styleFrom(
                    backgroundColor: _danger,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12)),
                    elevation: 0,
                  ),
                  child: const Text('Lihat Detail',
                      style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w800,
                          fontSize: 16)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/* ---------- Dummy & helpers ---------- */

List<WorkItem> _dummy() {
  final now = DateTime(2025, 10, 8);
  return [
    WorkItem(
      workOrder: 'WO-001-2501255',
      customer: 'Ahmad Yani',
      vehicle: 'Toyota Avanza',
      plate: 'L 1234 RAB',
      service: 'Service Rutin + ganti oli',
      schedule: now.add(const Duration(hours: 9)),
      mechanic: 'Hermansyah Dian',
      price: null,
      status: WorkStatus.pending,
    ),
    WorkItem(
      workOrder: 'WO-002-2598827',
      customer: 'Siti Nuhaliza',
      vehicle: 'Beat Fi 2017',
      plate: 'L 5678 CD',
      service: 'Ganti Fanbelt  + Clean up CVT',
      schedule: now.add(const Duration(hours: 10, minutes: 30)),
      mechanic: 'Budi Aryanto',
      price: null,
      status: WorkStatus.pending,
    ),
    WorkItem(
      workOrder: 'WO-003-2590092',
      customer: 'Dimas Budi Adi',
      vehicle: 'Yamaha Vixion 150 2018',
      plate: 'L 9105 NM',
      service: 'Ganti Aki + Busi',
      schedule: now.add(const Duration(hours: 1, minutes: 10)),
      mechanic: 'Hariyono Efendi',
      price: null,
      status: WorkStatus.pending,
    ),
    WorkItem(
      workOrder: 'WO-021-2501764',
      customer: 'Sharabuddin Magomed',
      vehicle: 'Kijang Innova 2015',
      plate: 'L 2543 AB',
      service: 'Service AC Mobil + ganti oli',
      schedule: now.add(const Duration(hours: 8, minutes: 20)),
      mechanic: 'Anton dimas',
      price: null,
      status: WorkStatus.process,
    ),
    WorkItem(
      workOrder: 'WO-022-2598666',
      customer: 'Firhan adiyatma',
      vehicle: 'Supra x 125 2017',
      plate: 'L 7655 AU',
      service: 'Clean Up Karbu + Service Karbu',
      schedule: now.add(const Duration(hours: 8, minutes: 30)),
      mechanic: 'Budi Aryanto',
      price: null,
      status: WorkStatus.process,
    ),
    WorkItem(
      workOrder: 'WO-000-250989',
      customer: 'Emanuel Dirgantara',
      vehicle: 'Cbr 150 r 2019',
      plate: 'L 6234 BI',
      service: 'Ganti Ban depan uk 2.75',
      schedule: now.add(const Duration(hours: 8, minutes: 50)),
      mechanic: 'Hermansyah Dian',
      price: 275000,
      status: WorkStatus.done,
    ),
  ];
}

String _dateTime(DateTime dt) {
  const bulan = [
    'Jan','Feb','Mar','Apr','Mei','Jun','Jul','Agu','Sep','Okt','Nov','Des'
  ];
  final tgl = '${dt.day} ${bulan[dt.month - 1]} ${dt.year}';
  final hh = dt.hour.toString().padLeft(2, '0');
  final mm = dt.minute.toString().padLeft(2, '0');
  return '$tgl - $hh:$mm';
}

String _rupiah(int nominal) {
  final s = nominal.toString();
  final buf = StringBuffer();
  for (int i = 0; i < s.length; i++) {
    final rev = s.length - i;
    buf.write(s[i]);
    if (rev > 1 && rev % 3 == 1) buf.write('.');
  }
  return buf.toString();
}
