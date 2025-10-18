import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:bengkel_online_flutter/feature/owner/screens/addStaff.dart';

/// ======== DATA MODEL ========
class Staff {
  final String id;
  String name;
  String position;
  String email;
  bool active;
  bool selected;

  Staff({
    required this.id,
    required this.name,
    required this.position,
    required this.email,
    this.active = true,
    this.selected = false,
  });

  Staff copyWith({
    String? name,
    String? position,
    String? email,
    bool? active,
    bool? selected,
  }) {
    return Staff(
      id: id,
      name: name ?? this.name,
      position: position ?? this.position,
      email: email ?? this.email,
      active: active ?? this.active,
      selected: selected ?? this.selected,
    );
  }
}

/// ======== PAGE (push biasa, ada tombol back yang pop) ========
class ManajemenKaryawanTablePage extends StatefulWidget {
  const ManajemenKaryawanTablePage({super.key});

  @override
  State<ManajemenKaryawanTablePage> createState() => _ManajemenKaryawanTablePageState();
}

class _ManajemenKaryawanTablePageState extends State<ManajemenKaryawanTablePage> {
  final TextEditingController _searchC = TextEditingController();
  final List<Staff> _all = _mockData();

  // sinkron horizontal header <-> body
  final ScrollController _hHeader = ScrollController();
  final ScrollController _hBody = ScrollController();
  bool _syncFromHeader = false;
  bool _syncFromBody = false;

  // scroll vertical body
  final ScrollController _vBody = ScrollController();

  bool get _allSelected => _filtered.isNotEmpty && _filtered.every((e) => e.selected);

  List<Staff> get _filtered {
    final q = _searchC.text.trim().toLowerCase();
    if (q.isEmpty) return _all;
    return _all.where((s) {
      return s.name.toLowerCase().contains(q) ||
          s.position.toLowerCase().contains(q) ||
          s.email.toLowerCase().contains(q);
    }).toList();
  }

  @override
  void initState() {
    super.initState();
    SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle.light);
    _hHeader.addListener(() {
      if (_syncFromBody) return;
      _syncFromHeader = true;
      _hBody.jumpTo(_hHeader.offset);
      _syncFromHeader = false;
    });
    _hBody.addListener(() {
      if (_syncFromHeader) return;
      _syncFromBody = true;
      _hHeader.jumpTo(_hBody.offset);
      _syncFromBody = false;
    });
  }

  @override
  void dispose() {
    _searchC.dispose();
    _hHeader.dispose();
    _hBody.dispose();
    _vBody.dispose();
    super.dispose();
  }

  void _toggleSelectAll(bool? value) {
    setState(() {
      for (final s in _filtered) {
        final idx = _all.indexWhere((e) => e.id == s.id);
        _all[idx] = _all[idx].copyWith(selected: value ?? false);
      }
    });
  }

  void _toggleSelectOne(Staff s, bool? value) {
    final idx = _all.indexWhere((e) => e.id == s.id);
    setState(() => _all[idx] = _all[idx].copyWith(selected: value ?? false));
  }

  void _toggleActive(Staff s, bool value) {
    final idx = _all.indexWhere((e) => e.id == s.id);
    setState(() => _all[idx] = _all[idx].copyWith(active: value));
  }

  void _editStaff(Staff s) async {
    final result = await showModalBottomSheet<Staff>(
      context: context,
      useSafeArea: true,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) => _EditSheet(staff: s),
    );
    if (result != null) {
      final idx = _all.indexWhere((e) => e.id == s.id);
      setState(() => _all[idx] = result);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Data staff diperbarui')),
      );
    }
  }

  void _deleteStaff(Staff s) async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Hapus Staff'),
        content: Text('Yakin hapus "${s.name}"?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Batal')),
          FilledButton.tonal(onPressed: () => Navigator.pop(ctx, true), child: const Text('Hapus')),
        ],
      ),
    );
    if (ok == true) {
      setState(() => _all.removeWhere((e) => e.id == s.id));
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Staff dihapus')));
    }
  }

  @override
  Widget build(BuildContext context) {
    const gradStart = Color(0xFF9B0D0D);
    const gradEnd = Color(0xFFB70F0F);

    return Scaffold(
      body: CustomScrollView(
        physics: const BouncingScrollPhysics(), // licin
        slivers: [
          // HEADER dengan back yang pop (bukan root)
          SliverAppBar(
            pinned: true,
            backgroundColor: gradStart,
            automaticallyImplyLeading: false,
            elevation: 0,
            expandedHeight: 180,
            flexibleSpace: FlexibleSpaceBar(
              background: Container(
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [gradStart, gradEnd],
                  ),
                ),
                child: SafeArea(
                  bottom: false,
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(16, 16, 16, 12),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            IconButton(
                              onPressed: () => Navigator.pop(context),
                              icon: const Icon(Icons.arrow_back, color: Colors.white),
                              style: ButtonStyle(
                                backgroundColor: WidgetStatePropertyAll(Colors.white.withOpacity(0.25)),
                                shape: const WidgetStatePropertyAll(CircleBorder()),
                              ),
                            ),
                            const SizedBox(width: 8),
                            const Text(
                              'List Karyawan',
                              style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
                            ),
                          ],
                        ),
                        const Spacer(),
                        Text(
                          '${_filtered.length} karyawan',
                          style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w600),
                        ),
                        const SizedBox(height: 8),
                        // Search bar
                        Material(
                          color: const Color(0xFFF0F1F5),
                          elevation: 0,
                          borderRadius: const BorderRadius.only(
                            topLeft: Radius.circular(50),
                            bottomLeft: Radius.circular(50),
                            bottomRight: Radius.circular(30),
                          ),
                          child: SizedBox(
                            height: 50,
                            child: Row(
                              children: [
                                const SizedBox(width: 16),
                                const Icon(Icons.search, color: Colors.grey),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: TextField(
                                    controller: _searchC,
                                    decoration: const InputDecoration(
                                      hintText: 'Search',
                                      border: InputBorder.none,
                                      contentPadding: EdgeInsets.symmetric(vertical: 14),
                                    ),
                                    onChanged: (_) => setState(() {}),
                                  ),
                                ),
                                IconButton(
                                  onPressed: () {
                                    _searchC.clear();
                                    setState(() {});
                                  },
                                  icon: const Icon(Icons.tune, color: Colors.grey),
                                ),
                                const SizedBox(width: 10),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),

          // BODY: TABEL
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
              child: _TableCard(
                headerController: _hHeader,
                bodyHController: _hBody,
                bodyVController: _vBody,
                rows: _filtered,
                allSelected: _allSelected,
                onToggleAll: _toggleSelectAll,
                onToggleRow: _toggleSelectOne,
                onToggleActive: _toggleActive,
                onEdit: _editStaff,
                onDelete: _deleteStaff,
              ),
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const AddStaffRegisterPage()),
          );
        },
        icon: const Icon(Icons.person_add_alt),
        label: const Text('Add Staff'),
      ),
    );
  }
}

/// ======== TABEL CARD ========
class _TableCard extends StatelessWidget {
  _TableCard({
    required this.rows,
    required this.allSelected,
    required this.headerController,
    required this.bodyHController,
    required this.bodyVController,
    required this.onToggleAll,
    required this.onToggleRow,
    required this.onToggleActive,
    required this.onEdit,
    required this.onDelete,
  });

  final List<Staff> rows;
  final bool allSelected;

  final ScrollController headerController;
  final ScrollController bodyHController;
  final ScrollController bodyVController;

  final ValueChanged<bool?> onToggleAll;
  final void Function(Staff, bool?) onToggleRow;
  final void Function(Staff, bool) onToggleActive;
  final void Function(Staff) onEdit;
  final void Function(Staff) onDelete;

  static const double wCheck = 56;
  static const double wName = 220;
  static const double wPos = 180;
  static const double wEmail = 240;
  static const double wStatus = 140;
  static const double wActions = 120;

  static const double rowHeight = 64;

  static double get totalWidth => wCheck + wName + wPos + wEmail + wStatus + wActions;

  @override
  Widget build(BuildContext context) {
    return Material(
      elevation: 6,
      shadowColor: Colors.black12,
      borderRadius: BorderRadius.circular(20),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: const Color(0xFFE6EAF0)),
        ),
        child: Column(
          children: [
            // HEADER
            ClipRRect(
              borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
              child: Container(
                color: const Color(0xFFF9FAFB),
                padding: const EdgeInsets.symmetric(vertical: 10),
                child: SingleChildScrollView(
                  controller: headerController,
                  scrollDirection: Axis.horizontal,
                  physics: const BouncingScrollPhysics(),
                  child: SizedBox(
                    width: max(totalWidth, MediaQuery.of(context).size.width - 32),
                    child: Row(
                      children: [
                        _headerCell(
                          width: wCheck,
                          child: Checkbox(
                            value: allSelected,
                            onChanged: onToggleAll,
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
                          ),
                        ),
                        _headerCell(width: wName, label: 'NAME'),
                        _headerCell(width: wPos, label: 'Position'),
                        _headerCell(width: wEmail, label: 'E-Mail'),
                        _headerCell(width: wStatus, label: 'Status'),
                        _headerCell(width: wActions, label: ''),
                      ],
                    ),
                  ),
                ),
              ),
            ),
            const Divider(height: 1),

            // BODY (smooth + lazy)
            SizedBox(
              height: min(520.0, MediaQuery.of(context).size.height * 0.55),
              child: Scrollbar(
                controller: bodyVController,
                radius: const Radius.circular(10),
                thickness: 6,
                child: SingleChildScrollView(
                  controller: bodyHController,
                  scrollDirection: Axis.horizontal,
                  physics: const BouncingScrollPhysics(),
                  child: SizedBox(
                    width: max(totalWidth, MediaQuery.of(context).size.width - 32),
                    child: ListView.separated(
                      controller: bodyVController,
                      physics: const BouncingScrollPhysics(parent: AlwaysScrollableScrollPhysics()),
                      cacheExtent: 800, // prefetch
                      addAutomaticKeepAlives: false,
                      addRepaintBoundaries: true,
                      addSemanticIndexes: false,
                      keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
                      itemBuilder: (context, i) {
                        final s = rows[i];
                        return _TableRow(
                          staff: s,
                          onToggle: (v) => onToggleRow(s, v),
                          onToggleActive: (v) => onToggleActive(s, v),
                          onEdit: () => onEdit(s),
                          onDelete: () => onDelete(s),
                        );
                      },
                      separatorBuilder: (_, __) => const Divider(height: 1),
                      itemCount: rows.length,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _headerCell({required double width, String? label, Widget? child}) {
    const style = TextStyle(
      fontSize: 12,
      color: Color(0xFF475467),
      fontWeight: FontWeight.w700,
      letterSpacing: 0.2,
    );
    return SizedBox(
      width: width,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: Align(
          alignment: Alignment.centerLeft,
          child: child ?? Text(label ?? '', style: style),
        ),
      ),
    );
  }
}

/// ======== ROW ========
class _TableRow extends StatelessWidget {
  const _TableRow({
    required this.staff,
    required this.onToggle,
    required this.onToggleActive,
    required this.onEdit,
    required this.onDelete,
  });

  final Staff staff;
  final ValueChanged<bool?> onToggle;
  final ValueChanged<bool> onToggleActive;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  static const double wCheck = _TableCard.wCheck;
  static const double wName = _TableCard.wName;
  static const double wPos = _TableCard.wPos;
  static const double wEmail = _TableCard.wEmail;
  static const double wStatus = _TableCard.wStatus;
  static const double wActions = _TableCard.wActions;

  @override
  Widget build(BuildContext context) {
    final ts = Theme.of(context).textTheme;

    return InkWell(
      onTap: () => onToggle(!staff.selected),
      child: SizedBox(
        height: _TableCard.rowHeight,
        child: Row(
          children: [
            SizedBox(
              width: wCheck,
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Checkbox(
                  value: staff.selected,
                  onChanged: onToggle,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
                ),
              ),
            ),
            // NAME
            SizedBox(
              width: wName,
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Row(
                  children: [
                    Container(
                      width: 22,
                      height: 22,
                      decoration: BoxDecoration(
                        color: const Color(0xFFEBDDFF),
                        borderRadius: BorderRadius.circular(6),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          border: Border.all(color: const Color(0xFFE6EAF0)),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          staff.name,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: ts.bodyMedium?.copyWith(fontWeight: FontWeight.w600),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            // POSITION
            SizedBox(
              width: wPos,
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Text(
                  staff.position,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: ts.bodyMedium?.copyWith(
                    color: const Color(0xFF344054),
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ),
            // EMAIL
            SizedBox(
              width: wEmail,
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Text(
                  staff.email,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: ts.bodyMedium?.copyWith(color: const Color(0xFF344054)),
                ),
              ),
            ),
            // STATUS
            SizedBox(
              width: wStatus,
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Row(
                  children: [
                    Expanded(
                      child: Align(
                        alignment: Alignment.centerLeft,
                        child: _StatusPill(active: staff.active),
                      ),
                    ),
                    Switch.adaptive(
                      value: staff.active,
                      onChanged: onToggleActive,
                      materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                      activeColor: const Color(0xFF16A34A),
                    ),
                  ],
                ),
              ),
            ),
            // ACTIONS
            SizedBox(
              width: wActions,
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 6),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    IconButton(
                      tooltip: 'Edit',
                      icon: const Icon(Icons.edit_outlined),
                      onPressed: onEdit,
                    ),
                    IconButton(
                      tooltip: 'Delete',
                      icon: const Icon(Icons.delete_outline),
                      onPressed: onDelete,
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _StatusPill extends StatelessWidget {
  const _StatusPill({required this.active});
  final bool active;

  @override
  Widget build(BuildContext context) {
    final color = active ? const Color(0xFFDCFCE7) : const Color(0xFFF1F5F9);
    final textColor = active ? const Color(0xFF166534) : const Color(0xFF475467);
    final label = active ? 'Active' : 'Inactive';
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: const Color(0xFFE6EAF0)),
      ),
      child: Text(label, style: TextStyle(fontSize: 12, color: textColor, fontWeight: FontWeight.w600)),
    );
  }
}

/// ======== EDIT BOTTOM SHEET — aksen #DC2626 ========
class _EditSheet extends StatefulWidget {
  const _EditSheet({required this.staff});
  final Staff staff;

  @override
  State<_EditSheet> createState() => _EditSheetState();
}

class _EditSheetState extends State<_EditSheet> {
  static const _danger = Color(0xFFDC2626);

  late final TextEditingController _name = TextEditingController(text: widget.staff.name);
  late final TextEditingController _pos = TextEditingController(text: widget.staff.position);
  late final TextEditingController _mail = TextEditingController(text: widget.staff.email);
  late bool _active = widget.staff.active;

  @override
  void dispose() {
    _name.dispose();
    _pos.dispose();
    _mail.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final viewInsets = MediaQuery.of(context).viewInsets.bottom;
    return Padding(
      padding: EdgeInsets.fromLTRB(16, 16, 16, 16 + viewInsets),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(width: 36, height: 4, decoration: BoxDecoration(color: Colors.black12, borderRadius: BorderRadius.circular(999))),
          const SizedBox(height: 16),
          const Text('Edit Staff', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700, color: _danger)),
          const SizedBox(height: 16),
          TextField(controller: _name, decoration: const InputDecoration(labelText: 'Nama')),
          const SizedBox(height: 12),
          TextField(controller: _pos, decoration: const InputDecoration(labelText: 'Position')),
          const SizedBox(height: 12),
          TextField(controller: _mail, decoration: const InputDecoration(labelText: 'E-Mail')),
          const SizedBox(height: 12),
          SwitchListTile(
            value: _active,
            onChanged: (v) => setState(() => _active = v),
            title: const Text('Active'),
            contentPadding: EdgeInsets.zero,
            activeColor: _danger,
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: () => Navigator.pop(context),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: _danger,
                    side: const BorderSide(color: _danger),
                  ),
                  child: const Text('Batal'),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: FilledButton(
                  style: FilledButton.styleFrom(backgroundColor: _danger, foregroundColor: Colors.white),
                  onPressed: () {
                    final updated = widget.staff.copyWith(
                      name: _name.text.trim(),
                      position: _pos.text.trim(),
                      email: _mail.text.trim(),
                      active: _active,
                    );
                    Navigator.pop(context, updated);
                  },
                  child: const Text('Simpan'),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

/// ======== DUMMY DATA ========
List<Staff> _mockData() {
  final raw = <Staff>[
    Staff(id: '1', name: 'Andi Pratama', position: 'Admin', email: 'Andipratama@gmail.com', active: true),
    Staff(id: '2', name: 'Arya Mahendra', position: 'Mekanik mesin', email: 'Mahendra22@gmail.com', active: true),
    Staff(id: '3', name: 'Anton Dimas', position: 'Mekanik umum', email: 'Dimasantok@gmail.com', active: true),
    Staff(id: '4', name: 'Budi Aryanto', position: 'Mekanik Transmisi', email: 'Aryantobudspeed@gmail.com', active: true),
    Staff(id: '5', name: 'Fazayyan Alfi', position: 'Admin', email: 'alifazaya11@gmail.com', active: true),
    Staff(id: '6', name: 'Hariyono Efendi', position: 'Mekanik kelistrikan', email: 'efendii2002@gmail.com', active: true),
    Staff(id: '7', name: 'Hermansyah Drian', position: 'Mekanik Umum', email: 'Hermanherman@gmail.com', active: true),
  ];

  // tambahan untuk tes lazy scroll
  final rng = Random(42);
  final more = List<Staff>.generate(30, (i) {
    final base = raw[i % raw.length];
    return Staff(
      id: '${i + 10}',
      name: '${base.name} ${i + 1}',
      position: base.position,
      email: base.email.replaceFirst('@', '${i + 1}@'),
      active: rng.nextBool(),
    );
  });

  return [...raw, ...more];
}
