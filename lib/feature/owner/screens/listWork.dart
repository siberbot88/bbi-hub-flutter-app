import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

import 'package:bengkel_online_flutter/core/models/service.dart';
import 'package:bengkel_online_flutter/feature/owner/providers/service_provider.dart';
import 'package:bengkel_online_flutter/feature/owner/screens/detailWork.dart';

const Color _gradStart = Color(0xFF9B0D0D);
const Color _gradEnd = Color(0xFFB70F0F);
const Color _danger = Color(0xFFDC2626);

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

/// state filter lanjutan (jenis kendaraan, kategori, urutan)
class _AdvancedFilter {
  final String? vehicleType; // 'mobil' | 'motor'
  final String? vehicleCategory; // 'matic', 'suv', dll (lowercase)
  final String sort; // 'newest' | 'oldest' | 'none'

  const _AdvancedFilter({
    this.vehicleType,
    this.vehicleCategory,
    this.sort = 'none',
  });

  bool get isEmpty =>
      (vehicleType == null || vehicleType!.isEmpty) &&
          (vehicleCategory == null || vehicleCategory!.isEmpty) &&
          (sort == 'none' || sort.isEmpty);

  _AdvancedFilter copyWith({
    String? vehicleType,
    String? vehicleCategory,
    String? sort,
  }) {
    return _AdvancedFilter(
      vehicleType: vehicleType ?? this.vehicleType,
      vehicleCategory: vehicleCategory ?? this.vehicleCategory,
      sort: sort ?? this.sort,
    );
  }

  static const empty = _AdvancedFilter();
}

class ListWorkPage extends StatefulWidget {
  const ListWorkPage({Key? key, this.workshopUuid}) : super(key: key);

  final String? workshopUuid;

  @override
  State<ListWorkPage> createState() => _ListWorkPageState();
}

class _ListWorkPageState extends State<ListWorkPage> {
  final TextEditingController _search = TextEditingController();
  WorkStatus _tabStatus = WorkStatus.pending;
  _AdvancedFilter _advancedFilter = _AdvancedFilter.empty;

  bool get _hasActiveFilter => !_advancedFilter.isEmpty;

  @override
  void initState() {
    super.initState();
    SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle.light);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final prov = context.read<ServiceProvider>();
      prov.fetchServices(workshopUuid: widget.workshopUuid);
    });
  }

  @override
  void dispose() {
    _search.dispose();
    super.dispose();
  }

  WorkItem _map(ServiceModel s) {
    final status = _mapStatus(s.status);

    final vehicleName = (() {
      final brand = (s.vehicle?.brand ?? '').trim();
      final model = (s.vehicle?.model ?? '').trim();
      final year = (s.vehicle?.year ?? '').toString().trim();
      final parts = [brand, model, year].where((e) => e.isNotEmpty).toList();
      if (parts.isEmpty) return '-';
      return parts.join(' ');
    })();

    final plate =
        s.vehicle?.plateNumber ?? tryOrNull(() => (s as dynamic).vehicle?.plate) ?? '-';

    return WorkItem(
      id: s.id,
      workOrder: s.code,
      customer: s.customer?.name ?? '-',
      vehicle: vehicleName,
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
    switch (_tabStatus) {
      case WorkStatus.pending:
        return st == 'pending' || st == 'accept' || st.isEmpty;
      case WorkStatus.process:
        return st == 'in progress';
      case WorkStatus.done:
        return st == 'completed';
    }
  }

  DateTime _dateForSort(ServiceModel s) =>
      s.scheduledDate ??
          s.createdAt ??
          DateTime.fromMillisecondsSinceEpoch(0);

  List<WorkItem> _filtered(List<ServiceModel> services) {
    Iterable<ServiceModel> filtered = services.where(_matchTab);

    // filter jenis kendaraan
    if (_advancedFilter.vehicleType != null &&
        _advancedFilter.vehicleType!.isNotEmpty) {
      final want = _advancedFilter.vehicleType!.toLowerCase();
      filtered = filtered.where((s) {
        final vt = (s.vehicle?.type ?? '').toLowerCase();
        return vt == want;
      });
    }

    // filter kategori kendaraan
    if (_advancedFilter.vehicleCategory != null &&
        _advancedFilter.vehicleCategory!.isNotEmpty) {
      final want = _advancedFilter.vehicleCategory!.toLowerCase();
      filtered = filtered.where((s) {
        final vc = (s.vehicle?.category ?? '').toLowerCase();
        return vc == want;
      });
    }

    final list = filtered.toList();

    // sort
    if (_advancedFilter.sort == 'newest') {
      list.sort((a, b) => _dateForSort(b).compareTo(_dateForSort(a)));
    } else if (_advancedFilter.sort == 'oldest') {
      list.sort((a, b) => _dateForSort(a).compareTo(_dateForSort(b)));
    }

    var items = list.map(_map).toList();

    final q = _search.text.trim().toLowerCase();
    if (q.isEmpty) return items;

    items = items.where((e) {
      return e.workOrder.toLowerCase().contains(q) ||
          e.customer.toLowerCase().contains(q) ||
          e.vehicle.toLowerCase().contains(q) ||
          e.plate.toLowerCase().contains(q) ||
          e.mechanic.toLowerCase().contains(q) ||
          e.service.toLowerCase().contains(q);
    }).toList();

    return items;
  }

  void _openFilterSheet() {
    String? tempType = _advancedFilter.vehicleType;
    String? tempCat = _advancedFilter.vehicleCategory;
    String tempSort = _advancedFilter.sort;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) {
        final bottom = MediaQuery.of(ctx).padding.bottom;
        return StatefulBuilder(
          builder: (ctx, setModalState) {
            Widget buildTypeChip(String label, String value) {
              final sel = tempType == value;
              return ChoiceChip(
                label: Text(label),
                selected: sel,
                onSelected: (v) {
                  setModalState(() {
                    tempType = v ? value : null;
                    if (tempType == null) tempCat = null;
                  });
                },
              );
            }

            Widget buildCatChip(String label, String value) {
              final sel = tempCat == value;
              return ChoiceChip(
                label: Text(label),
                selected: sel,
                onSelected: (v) {
                  setModalState(() {
                    tempCat = v ? value : null;
                  });
                },
              );
            }

            Widget buildSortChip(String label, String value) {
              final sel = tempSort == value;
              return ChoiceChip(
                label: Text(label),
                selected: sel,
                onSelected: (v) {
                  setModalState(() {
                    tempSort = v ? value : 'none';
                  });
                },
              );
            }

            return Padding(
              padding: EdgeInsets.fromLTRB(16, 12, 16, 16 + bottom),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Center(
                    child: Container(
                      width: 40,
                      height: 4,
                      margin: const EdgeInsets.only(bottom: 12),
                      decoration: BoxDecoration(
                        color: Colors.grey.shade300,
                        borderRadius: BorderRadius.circular(999),
                      ),
                    ),
                  ),
                  const Text(
                    'Filter Pekerjaan',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800),
                  ),
                  const SizedBox(height: 16),
                  const Text('Jenis Kendaraan',
                      style:
                      TextStyle(fontSize: 14, fontWeight: FontWeight.w600)),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 8,
                    children: [
                      buildTypeChip('Semua', ''),
                      buildTypeChip('Mobil', 'mobil'),
                      buildTypeChip('Motor', 'motor'),
                    ],
                  ),
                  const SizedBox(height: 16),
                  const Text('Kategori Kendaraan',
                      style:
                      TextStyle(fontSize: 14, fontWeight: FontWeight.w600)),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 8,
                    children: [
                      buildCatChip('Matic', 'matic'),
                      buildCatChip('Sport', 'sport'),
                      buildCatChip('Bebek', 'bebek'),
                      buildCatChip('SUV', 'suv'),
                      buildCatChip('MPV', 'mpv'),
                      buildCatChip('Hatchback', 'hatchback'),
                      buildCatChip('Sedan', 'sedan'),
                    ],
                  ),
                  const SizedBox(height: 16),
                  const Text('Urutkan',
                      style:
                      TextStyle(fontSize: 14, fontWeight: FontWeight.w600)),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 8,
                    children: [
                      buildSortChip('Terbaru', 'newest'),
                      buildSortChip('Terlama', 'oldest'),
                    ],
                  ),
                  const SizedBox(height: 24),
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton(
                          onPressed: () {
                            setState(() {
                              _advancedFilter = _AdvancedFilter.empty;
                            });
                            Navigator.pop(ctx);
                          },
                          child: const Text('Reset'),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: _danger,
                          ),
                          onPressed: () {
                            setState(() {
                              final typeValue =
                              (tempType ?? '').isEmpty ? null : tempType;
                              final catValue =
                              (tempCat ?? '').isEmpty ? null : tempCat;
                              _advancedFilter = _AdvancedFilter(
                                vehicleType: typeValue,
                                vehicleCategory: catValue,
                                sort: tempSort,
                              );
                            });
                            Navigator.pop(ctx);
                          },
                          child: const Text(
                            'Terapkan',
                            style: TextStyle(fontWeight: FontWeight.w700),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            );
          },
        );
      },
    );
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
                    onPressed: () =>
                        prov.fetchServices(workshopUuid: widget.workshopUuid),
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
                              style: TextStyle(
                                  color: Colors.white70, fontSize: 14),
                            ),
                            const SizedBox(height: 18),
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
                                  InkWell(
                                    onTap: _openFilterSheet,
                                    borderRadius: BorderRadius.circular(24),
                                    child: Container(
                                      padding: const EdgeInsets.all(6),
                                      decoration: BoxDecoration(
                                        color: _hasActiveFilter
                                            ? _danger
                                            : Colors.transparent,
                                        shape: BoxShape.circle,
                                      ),
                                      child: Icon(
                                        Icons.tune,
                                        color: _hasActiveFilter
                                            ? Colors.white
                                            : Colors.grey,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(height: 14),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                _StatusChip(
                                  label: 'Pending',
                                  icon: Icons.error_outline,
                                  selected: _tabStatus == WorkStatus.pending,
                                  onTap: () => setState(
                                          () => _tabStatus = WorkStatus.pending),
                                ),
                                const SizedBox(width: 16),
                                _StatusChip(
                                  label: 'Process',
                                  icon: Icons.schedule_rounded,
                                  selected: _tabStatus == WorkStatus.process,
                                  onTap: () => setState(
                                          () => _tabStatus = WorkStatus.process),
                                ),
                                const SizedBox(width: 16),
                                _StatusChip(
                                  label: 'Selesai',
                                  icon: Icons.verified_rounded,
                                  selected: _tabStatus == WorkStatus.done,
                                  onTap: () => setState(
                                          () => _tabStatus = WorkStatus.done),
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

              if (prov.loading)
                const SliverFillRemaining(
                  child: Center(
                    child: CircularProgressIndicator(color: Colors.white),
                  ),
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
              else if (list.isEmpty)
                  const SliverFillRemaining(
                    hasScrollBody: false,
                    child: Center(
                      child: Text(
                        'Belum ada pekerjaan',
                        style: TextStyle(color: Colors.white70),
                      ),
                    ),
                  )
                else
                  SliverPadding(
                    padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
                    sliver: SliverList.separated(
                      itemCount: list.length,
                      separatorBuilder: (_, __) => const SizedBox(height: 14),
                      itemBuilder: (context, i) {
                        return _AnimatedWorkCard(item: list[i]);
                      },
                    ),
                  ),

              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 16.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      ElevatedButton(
                        onPressed: prov.currentPage > 1 && !prov.loading
                            ? () => prov.goToPage(
                          prov.currentPage - 1,
                          workshopUuid: widget.workshopUuid,
                        )
                            : null,
                        child: const Text('Prev'),
                      ),
                      const SizedBox(width: 16),
                      Text('Page ${prov.currentPage} of ${prov.totalPages}',
                          style: const TextStyle(color: Colors.white)),
                      const SizedBox(width: 16),
                      ElevatedButton(
                        onPressed:
                        prov.currentPage < prov.totalPages && !prov.loading
                            ? () => prov.goToPage(
                          prov.currentPage + 1,
                          workshopUuid: widget.workshopUuid,
                        )
                            : null,
                        child: const Text('Next'),
                      ),
                    ],
                  ),
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

/* ---------- Widgets kecil ---------- */

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

class _AnimatedWorkCard extends StatefulWidget {
  final WorkItem item;
  const _AnimatedWorkCard({required this.item});

  @override
  State<_AnimatedWorkCard> createState() => _AnimatedWorkCardState();
}

class _AnimatedWorkCardState extends State<_AnimatedWorkCard>
    with SingleTickerProviderStateMixin {
  late AnimationController _animCtrl;
  late Animation<double> _fade;

  @override
  void initState() {
    super.initState();
    _animCtrl =
        AnimationController(vsync: this, duration: const Duration(milliseconds: 400));
    _fade = CurvedAnimation(parent: _animCtrl, curve: Curves.easeIn);
    _animCtrl.forward();
  }

  @override
  void dispose() {
    _animCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final item = widget.item;
    final price = item.price == null ? 'RP. -' : 'RP. ${_rupiah(item.price!)}';

    return FadeTransition(
      opacity: _fade,
      child: Material(
        color: Colors.white,
        elevation: 0,
        borderRadius: BorderRadius.circular(22),
        child: InkWell(
          borderRadius: BorderRadius.circular(22),
          onTap: () {
            if (item.id.isEmpty) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('ID service tidak tersedia')),
              );
              return;
            }
            Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => DetailWorkPage(serviceId: item.id)),
            );
          },
          child: Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(22),
              boxShadow: const [
                BoxShadow(color: Color(0x22000000), blurRadius: 18, offset: Offset(0, 10)),
              ],
            ),
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 16, 12, 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
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
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => DetailWorkPage(serviceId: item.id),
                          ),
                        );
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: _danger,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        elevation: 0,
                      ),
                      child: const Text(
                        'Lihat Detail',
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w800,
                          fontSize: 16,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
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
    'Des'
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

T? tryOrNull<T>(T Function() f) {
  try {
    return f();
  } catch (_) {
    return null;
  }
}
