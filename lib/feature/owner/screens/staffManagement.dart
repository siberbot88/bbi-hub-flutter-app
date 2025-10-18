import 'package:bengkel_online_flutter/feature/owner/screens/listStaff.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:bengkel_online_flutter/feature/owner/screens/addStaff.dart';

const Color _primaryRed = Color(0xFFB70F0F);
const Color _gradStart  = Color(0xFF9B0D0D);
const Color _gradEnd    = Color(0xFFB70F0F);

class ManajemenKaryawanPage extends StatefulWidget {
  const ManajemenKaryawanPage({super.key});

  @override
  State<ManajemenKaryawanPage> createState() => _ManajemenKaryawanPageState();
}

class _ManajemenKaryawanPageState extends State<ManajemenKaryawanPage> {
  final List<Staff> _staffs = [
    Staff(
      name: 'Andi Pratama',
      jobdesk:
      'Mengelola data pelanggan dan transaksi servis\nMenjadwalkan servis & memastikan antrian berjalan rapi',
      role: 'Admin',
    ),
    Staff(
      name: 'Arya Mahendra',
      jobdesk:
      'Overhaul mesin motor/mobil\nTune up dan servis besar\nDiagnosa kerusakan mesin menggunakan alat scanner',
      role: 'Mekanik mesin',
    ),
    Staff(
      name: 'Hariyono Efendi',
      jobdesk:
      'Perbaikan sistem kelistrikan (aki, kabel, lampu, dsb)\nPemasangan aksesoris elektronik (alarm, sensor, audio)\nPemeriksaan sistem ECU/ECM',
      role: 'Mekanik Kelistrikan',
    ),
    Staff(
      name: 'Hariyono Efendi',
      jobdesk:
      'Perbaikan sistem kelistrikan (aki, kabel, lampu, dsb)\nPemasangan aksesoris elektronik (alarm, sensor, audio)\nPemeriksaan sistem ECU/ECM',
      role: 'Mekanik Kelistrikan',
    ),
    Staff(
      name: 'Hariyono Efendi',
      jobdesk:
      'Perbaikan sistem kelistrikan (aki, kabel, lampu, dsb)\nPemasangan aksesoris elektronik (alarm, sensor, audio)\nPemeriksaan sistem ECU/ECM',
      role: 'Mekanik Kelistrikan',
    ),
    Staff(
      name: 'Hariyono Efendi',
      jobdesk:
      'Perbaikan sistem kelistrikan (aki, kabel, lampu, dsb)\nPemasangan aksesoris elektronik (alarm, sensor, audio)\nPemeriksaan sistem ECU/ECM',
      role: 'Mekanik Kelistrikan',
    ),
    Staff(
      name: 'Hariyono Efendi',
      jobdesk:
      'Perbaikan sistem kelistrikan (aki, kabel, lampu, dsb)\nPemasangan aksesoris elektronik (alarm, sensor, audio)\nPemeriksaan sistem ECU/ECM',
      role: 'Mekanik Kelistrikan',
    ),
  ];

  String _searchQuery = '';

  @override
  Widget build(BuildContext context) {
    SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle.light);

    final filtered = _staffs
        .where((s) =>
    s.name.toLowerCase().contains(_searchQuery.toLowerCase()) ||
        s.jobdesk.toLowerCase().contains(_searchQuery.toLowerCase()) ||
        s.role.toLowerCase().contains(_searchQuery.toLowerCase()))
        .toList();

    return Scaffold(
      backgroundColor: Colors.white,
      body: CustomScrollView(
        physics: const BouncingScrollPhysics(),
        slivers: [
          // ===== HEADER collapsible (card fitur di dalam header) =====
          SliverAppBar(
            pinned: true,
            backgroundColor: _gradStart,
            elevation: 0,
            expandedHeight: 280,
            flexibleSpace: FlexibleSpaceBar(
              collapseMode: CollapseMode.parallax,
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
                    padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Top bar
                        Row(
                          children: [
                            InkWell(
                              onTap: () {
                                Navigator.pushReplacementNamed(context, "/main");
                              },
                              borderRadius: BorderRadius.circular(30),
                              child: Container(
                                padding: const EdgeInsets.all(8),
                                decoration: BoxDecoration(
                                  color: Colors.white.withOpacity(0.3),
                                  shape: BoxShape.circle,
                                ),
                                child: const Icon(Icons.arrow_back,
                                    color: Colors.white),
                              ),
                            ),
                            const SizedBox(width: 16),
                            const Text(
                              'Manajemen Karyawan',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 20),
                        const Text(
                          '3 Karyawan',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(height: 4),
                        const Text(
                          '8 hadir hari ini · 4 izin/sakit',
                          style: TextStyle(color: Colors.white70, fontSize: 12),
                        ),
                        const SizedBox(height: 24), // info -> card (24)

                        // Card fitur (tetap di header)
                        Material(
                          elevation: 6,
                          borderRadius: BorderRadius.circular(16),
                          child: Container(
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(16),
                            ),
                            padding: const EdgeInsets.symmetric(vertical: 18),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                              children: [
                                _FeatureButton(
                                  icon: Icons.person_add,
                                  label: 'Add Staff',
                                  onTap: () {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(builder: (_) => const AddStaffRegisterPage()),
                                    );
                                  },
                                ),
                                _FeatureButton(
                                  icon: Icons.list,
                                  label: 'List Staff',
                                  onTap: () {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(builder: (_) => const ManajemenKaryawanTablePage()),
                                    );
                                  },
                                ),
                                _FeatureButton(
                                  icon: Icons.access_time,
                                  label: 'Absensi',
                                  onTap: () {},
                                ),
                              ],
                            ),
                          ),
                        ),

                        const SizedBox(height: 20), // card -> body (NAIK dari 36 ke 20)
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),

          // ===== BODY CONTENT =====
          SliverToBoxAdapter(
            child: _searchSection(
              // kasih jarak dari batas body (biar nggak dempet)
              outerPadding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
              innerPadding: const EdgeInsets.symmetric(horizontal: 20),
              fieldContentPadding: const EdgeInsets.symmetric(vertical: 14),
            ),
          ),
          const SliverToBoxAdapter(child: SizedBox(height: 12)),
          SliverToBoxAdapter(child: _listHeaderSection()),

          SliverList(
            delegate: SliverChildBuilderDelegate(
                  (context, i) => Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: StaffCard(staff: filtered[i]),
              ),
              childCount: filtered.length,
            ),
          ),
          const SliverToBoxAdapter(child: SizedBox(height: 24)),
        ],
      ),
    );
  }

  // ===== Search Section (pakai padding parameter) =====
  Widget _searchSection({
    required EdgeInsets outerPadding,
    required EdgeInsets innerPadding,
    required EdgeInsets fieldContentPadding,
  }) {
    return Padding(
      padding: outerPadding,
      child: Row(
        children: [
          Expanded(
            child: Container(
              height: 48,
              decoration: const BoxDecoration(
                color: Color(0xFFF0F1F5),
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(50),
                  bottomLeft: Radius.circular(50),
                  bottomRight: Radius.circular(30),
                ),
              ),
              padding: innerPadding,
              child: Row(
                children: [
                  const Icon(Icons.search, color: Colors.grey),
                  const SizedBox(width: 8),
                  Expanded(
                    child: TextField(
                      decoration: InputDecoration(
                        hintText: 'Search',
                        border: InputBorder.none,
                        isDense: true,
                        contentPadding: fieldContentPadding,
                      ),
                      onChanged: (v) => setState(() => _searchQuery = v),
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(width: 8),
          GestureDetector(
            onTap: () => setState(() => _searchQuery = ''),
            child: const Text(
              'Cancel',
              style: TextStyle(
                color: Color(0xFFDC2626),
                fontSize: 16,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _listHeaderSection() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: const [
          Text('List Jobdesk Staff',
              style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600)),
          Text('Lainnya',
              style: TextStyle(
                  fontSize: 13, color: Color(0xFFDC2626), fontWeight: FontWeight.w500)),
        ],
      ),
    );
  }
}

// ===== Feature Button =====
class _FeatureButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;

  const _FeatureButton({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: SizedBox(
        width: 90,
        child: Column(
          children: [
            Icon(icon, color: _primaryRed, size: 28),
            const SizedBox(height: 6),
            Text(label,
                textAlign: TextAlign.center,
                style: const TextStyle(fontSize: 12, color: Colors.black87)),
          ],
        ),
      ),
    );
  }
}

// ===== Staff Card =====
class StaffCard extends StatelessWidget {
  final Staff staff;

  const StaffCard({required this.staff});

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 250),
      curve: Curves.easeInOut,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        gradient: const LinearGradient(
          colors: [Color(0xFF510606), Color(0xFF9B0D0D), Color(0xFFB70F0F)],
          begin: Alignment.bottomLeft,
          end: Alignment.topRight,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black12.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(staff.name,
              style: const TextStyle(
                  color: Colors.white, fontSize: 14, fontWeight: FontWeight.w600)),
          const SizedBox(height: 8),
          Text(staff.jobdesk,
              style: const TextStyle(color: Colors.white70, fontSize: 10, height: 1.4)),
          const SizedBox(height: 12),
          Align(
            alignment: Alignment.topRight,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
              decoration: BoxDecoration(
                border: Border.all(color: Colors.white),
                borderRadius: BorderRadius.circular(50),
              ),
              child: Text(staff.role,
                  style: const TextStyle(color: Colors.white, fontSize: 11)),
            ),
          ),
        ],
      ),
    );
  }
}

// ===== Model =====
class Staff {
  final String name;
  final String jobdesk;
  final String role;

  Staff({required this.name, required this.jobdesk, required this.role});
}
