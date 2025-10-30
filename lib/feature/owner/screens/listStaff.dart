import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

import 'package:bengkel_online_flutter/feature/owner/screens/addStaff.dart';
import 'package:bengkel_online_flutter/core/models/employment.dart';
import 'package:bengkel_online_flutter/feature/owner/providers/employee_provider.dart';

class ManajemenKaryawanTablePage extends StatefulWidget {
  const ManajemenKaryawanTablePage({super.key});

  @override
  State<ManajemenKaryawanTablePage> createState() => _ManajemenKaryawanTablePageState();
}

class _ManajemenKaryawanTablePageState extends State<ManajemenKaryawanTablePage> {
  final TextEditingController _searchC = TextEditingController();

  // sinkron header <-> body (scroll horizontal)
  final ScrollController _hHeader = ScrollController();
  final ScrollController _hBody = ScrollController();
  bool _syncFromHeader = false;
  bool _syncFromBody = false;

  // scroll vertical body
  final ScrollController _vBody = ScrollController();

  // checkbox selected (pakai id employment)
  final Set<String> _selectedIds = <String>{};

  @override
  void initState() {
    super.initState();
    SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle.light);

    // fetch pertama
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<EmployeeProvider>().fetchOwnerEmployees();
    });

    // sync H scroll
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

  Future<void> _refresh() async {
    await context.read<EmployeeProvider>().fetchOwnerEmployees();
  }

  List<Employment> _filter(List<Employment> items) {
    final q = _searchC.text.trim().toLowerCase();
    if (q.isEmpty) return items;
    return items.where((e) {
      return e.name.toLowerCase().contains(q) ||
          e.role.toLowerCase().contains(q) ||
          e.email.toLowerCase().contains(q);
    }).toList();
  }

  bool _allSelected(List<Employment> filtered) =>
      filtered.isNotEmpty && filtered.every((e) => _selectedIds.contains(e.id));

  void _toggleSelectAll(List<Employment> filtered, bool? value) {
    setState(() {
      if (value ?? false) {
        _selectedIds.addAll(filtered.map((e) => e.id));
      } else {
        _selectedIds.removeAll(filtered.map((e) => e.id));
      }
    });
  }

  void _toggleSelectOne(Employment e, bool? value) {
    setState(() {
      if (value ?? false) {
        _selectedIds.add(e.id);
      } else {
        _selectedIds.remove(e.id);
      }
    });
  }

  Future<void> _toggleActive(Employment e, bool value) async {
    final prov = context.read<EmployeeProvider>();
    try {
      await prov.toggleStatus(e.id, value);
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Status ${e.name} -> ${value ? 'Active' : 'Inactive'}'),
          behavior: SnackBarBehavior.floating,
          duration: const Duration(seconds: 2),
        ),
      );
    } catch (_) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Gagal mengubah status ${e.name}'),
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  Future<void> _editEmployee(Employment e) async {
    final result = await showModalBottomSheet<_EditResult>(
      context: context,
      useSafeArea: true,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) => _EditSheet(employment: e),
    );
    if (result == null) return;

    try {
      await context.read<EmployeeProvider>().updateEmployee(
        e.id,
        name: result.name,
        username: result.username,
        email: result.email,
        role: result.role,
        specialist: result.specialist,
        jobdesk: result.jobdesk,
      );
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Data karyawan diperbarui'),
          behavior: SnackBarBehavior.floating,
        ),
      );
    } catch (err) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Gagal update: $err'),
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  Future<void> _deleteEmployee(Employment e) async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Hapus Karyawan'),
        content: Text('Yakin hapus "${e.name}"?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Batal')),
          FilledButton.tonal(onPressed: () => Navigator.pop(ctx, true), child: const Text('Hapus')),
        ],
      ),
    );
    if (ok != true) return;

    try {
      await context.read<EmployeeProvider>().deleteEmployee(e.id);
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Karyawan dihapus'),
          behavior: SnackBarBehavior.floating,
        ),
      );
    } catch (err) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Gagal menghapus: $err'),
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    const gradStart = Color(0xFF9B0D0D);
    const gradEnd = Color(0xFFB70F0F);

    final prov = context.watch<EmployeeProvider>();
    final all = prov.items;
    final filtered = _filter(all);

    return Scaffold(
      body: RefreshIndicator.adaptive(
        onRefresh: _refresh,
        child: CustomScrollView(
          physics: const BouncingScrollPhysics(parent: AlwaysScrollableScrollPhysics()),
          slivers: [
            // HEADER
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
                                  backgroundColor:
                                  WidgetStatePropertyAll(Colors.white.withOpacity(0.25)),
                                  shape: const WidgetStatePropertyAll(CircleBorder()),
                                ),
                              ),
                              const SizedBox(width: 8),
                              const Text(
                                'List Karyawan',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                          const Spacer(),
                          Text(
                            '${filtered.length} karyawan',
                            style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w600),
                          ),
                          const SizedBox(height: 8),
                          // Search
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

            // BODY TABEL
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
                child: _TableCardEmployment(
                  rows: filtered,
                  allSelected: _allSelected(filtered),
                  headerController: _hHeader,
                  bodyHController: _hBody,
                  bodyVController: _vBody,
                  onToggleAll: (v) => _toggleSelectAll(filtered, v),
                  onToggleRow: _toggleSelectOne,
                  onToggleActive: _toggleActive,
                  onEdit: _editEmployee,
                  onDelete: _deleteEmployee,
                ),
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () async {
          await Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const AddStaffRegisterPage()),
          );
          if (!mounted) return;
          _refresh();
        },
        icon: const Icon(Icons.person_add_alt),
        label: const Text('Add Staff'),
      ),
    );
  }
}

/* ==================== TABEL EMPLOYMENT ==================== */

class _TableCardEmployment extends StatelessWidget {
  const _TableCardEmployment({
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

  final List<Employment> rows;
  final bool allSelected;

  final ScrollController headerController;
  final ScrollController bodyHController;
  final ScrollController bodyVController;

  final ValueChanged<bool?> onToggleAll;
  final void Function(Employment, bool?) onToggleRow;
  final Future<void> Function(Employment, bool) onToggleActive;
  final Future<void> Function(Employment) onEdit;
  final Future<void> Function(Employment) onDelete;

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
            // Header
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

            // Body
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
                      itemBuilder: (context, i) {
                        final e = rows[i];
                        return _RowEmployment(
                          data: e,
                          onToggle: (v) => onToggleRow(e, v),
                          onToggleActive: (v) => onToggleActive(e, v),
                          onEdit: () => onEdit(e),
                          onDelete: () => onDelete(e),
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

class _RowEmployment extends StatelessWidget {
  const _RowEmployment({
    required this.data,
    required this.onToggle,
    required this.onToggleActive,
    required this.onEdit,
    required this.onDelete,
  });

  final Employment data;
  final ValueChanged<bool?> onToggle;
  final ValueChanged<bool> onToggleActive;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  static const double wCheck = _TableCardEmployment.wCheck;
  static const double wName = _TableCardEmployment.wName;
  static const double wPos = _TableCardEmployment.wPos;
  static const double wEmail = _TableCardEmployment.wEmail;
  static const double wStatus = _TableCardEmployment.wStatus;
  static const double wActions = _TableCardEmployment.wActions;

  @override
  Widget build(BuildContext context) {
    final ts = Theme.of(context).textTheme;

    return SizedBox(
      height: _TableCardEmployment.rowHeight,
      child: Row(
        children: [
          SizedBox(
            width: wCheck,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Checkbox(
                value: false,
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
                        data.name.isEmpty ? '-' : data.name,
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
                data.role.isEmpty ? '-' : data.role,
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
                data.email.isEmpty ? '-' : data.email,
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
                      child: _StatusPill(active: data.isActive),
                    ),
                  ),
                  Switch.adaptive(
                    value: data.isActive,
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

/* ==================== EDIT SHEET (integrasi API) ==================== */

class _EditResult {
  final String? name;
  final String? username;
  final String? email;
  final String? role;
  final String? specialist;
  final String? jobdesk;
  _EditResult({this.name, this.username, this.email, this.role, this.specialist, this.jobdesk});
}

class _EditSheet extends StatefulWidget {
  const _EditSheet({required this.employment});
  final Employment employment;

  @override
  State<_EditSheet> createState() => _EditSheetState();
}

class _EditSheetState extends State<_EditSheet> {
  static const _danger = Color(0xFFDC2626);

  late final TextEditingController _name =
  TextEditingController(text: widget.employment.name);
  late final TextEditingController _username =
  TextEditingController(text: widget.employment.user?.username ?? '');
  late final TextEditingController _mail =
  TextEditingController(text: widget.employment.email);
  late final TextEditingController _specialist =
  TextEditingController(text: widget.employment.specialist ?? '');
  late final TextEditingController _jobdesk =
  TextEditingController(text: widget.employment.jobdesk ?? '');
  late String _role = (widget.employment.role.isEmpty) ? 'mechanic' : widget.employment.role;

  @override
  void dispose() {
    _name.dispose();
    _username.dispose();
    _mail.dispose();
    _specialist.dispose();
    _jobdesk.dispose();
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
          const Text('Edit Karyawan', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700, color: _danger)),
          const SizedBox(height: 16),
          TextField(controller: _name, decoration: const InputDecoration(labelText: 'Nama')),
          const SizedBox(height: 12),
          TextField(controller: _username, decoration: const InputDecoration(labelText: 'Username')),
          const SizedBox(height: 12),
          TextField(controller: _mail, decoration: const InputDecoration(labelText: 'E-Mail')),
          const SizedBox(height: 12),
          DropdownButtonFormField<String>(
            value: _role,
            items: const [
              DropdownMenuItem(value: 'admin', child: Text('Admin')),
              DropdownMenuItem(value: 'mechanic', child: Text('Mekanik')),
            ],
            onChanged: (v) => setState(() => _role = v ?? 'mechanic'),
            decoration: const InputDecoration(labelText: 'Role'),
          ),
          const SizedBox(height: 12),
          TextField(controller: _specialist, decoration: const InputDecoration(labelText: 'Spesialis')),
          const SizedBox(height: 12),
          TextField(controller: _jobdesk, decoration: const InputDecoration(labelText: 'Jobdesk')),
          const SizedBox(height: 16),
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
                    Navigator.pop(
                      context,
                      _EditResult(
                        name: _name.text.trim(),
                        username: _username.text.trim(),
                        email: _mail.text.trim(),
                        role: _role,
                        specialist: _specialist.text.trim(),
                        jobdesk: _jobdesk.text.trim(),
                      ),
                    );
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
