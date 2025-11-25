import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

import 'package:bengkel_online_flutter/feature/owner/screens/add_staff.dart';
import 'package:bengkel_online_flutter/core/models/employment.dart';
import 'package:bengkel_online_flutter/feature/owner/providers/employee_provider.dart';

import '../widgets/manajemen_karyawan/staff_table.dart';
import '../widgets/manajemen_karyawan/staff_edit_sheet.dart';

class ManajemenKaryawanTablePage extends StatefulWidget {
  const ManajemenKaryawanTablePage({super.key});

  @override
  State<ManajemenKaryawanTablePage> createState() => _ManajemenKaryawanTablePageState();
}

class _ManajemenKaryawanTablePageState extends State<ManajemenKaryawanTablePage> {
  final TextEditingController _searchC = TextEditingController();

  final ScrollController _hHeader = ScrollController();
  final ScrollController _hBody = ScrollController();
  bool _syncFromHeader = false;
  bool _syncFromBody = false;

  final ScrollController _vBody = ScrollController();

  @override
  void initState() {
    super.initState();
    SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle.light);

    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<EmployeeProvider>().fetchOwnerEmployees();
    });

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
    final result = await showModalBottomSheet<StaffEditResult>(
      context: context,
      useSafeArea: true,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(14)),
      ),
      builder: (ctx) => StaffEditSheet(employment: e),
    );
    if (result == null) return;
    if (!mounted) return;

    final prov = context.read<EmployeeProvider>();
    try {
      await prov.updateEmployee(
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
    if (!mounted) return;

    final prov = context.read<EmployeeProvider>();
    try {
      await prov.deleteEmployee(e.id);
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
                                  WidgetStatePropertyAll(Colors.white.withAlpha(64)),
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
                padding: const EdgeInsets.fromLTRB(16, 12, 16, 32), // margin bawah 32px
                child: StaffTable(
                  rows: filtered,
                  headerController: _hHeader,
                  bodyHController: _hBody,
                  bodyVController: _vBody,
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
