import 'package:flutter/material.dart';

import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

import 'package:bengkel_online_flutter/core/models/service.dart';
import 'package:bengkel_online_flutter/core/providers/service_provider.dart';

import '../widgets/work/work_card.dart';
import '../widgets/work/work_helpers.dart';

const Color _gradStart = Color(0xFF9B0D0D);
const Color _gradEnd = Color(0xFFB70F0F);
const Color _danger = Color(0xFFDC2626);

class ListWorkPage extends StatefulWidget {
  const ListWorkPage({super.key, this.workshopUuid});

  final String? workshopUuid;

  @override
  State<ListWorkPage> createState() => _ListWorkPageState();
}

class _ListWorkPageState extends State<ListWorkPage> {
  final TextEditingController _search = TextEditingController();
  WorkStatus _tabStatus = WorkStatus.pending;
  AdvancedFilter _advancedFilter = AdvancedFilter.empty;

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

    final plate = s.vehicle?.plateNumber ??
        tryOrNull(() => (s as dynamic).vehicle?.plate) ??
        '-';

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
                              _advancedFilter = AdvancedFilter.empty;
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
                              _advancedFilter = AdvancedFilter(
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
                                WorkStatusChip(
                                  label: 'Pending',
                                  icon: Icons.error_outline,
                                  selected: _tabStatus == WorkStatus.pending,
                                  onTap: () => setState(
                                      () => _tabStatus = WorkStatus.pending),
                                ),
                                const SizedBox(width: 16),
                                WorkStatusChip(
                                  label: 'Process',
                                  icon: Icons.schedule_rounded,
                                  selected: _tabStatus == WorkStatus.process,
                                  onTap: () => setState(
                                      () => _tabStatus = WorkStatus.process),
                                ),
                                const SizedBox(width: 16),
                                WorkStatusChip(
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
                    itemBuilder: (_, i) {
                      return WorkCard(item: list[i]);
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
