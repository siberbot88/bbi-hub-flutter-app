import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

void main() {
  runApp(const MaterialApp(
    debugShowCheckedModeBanner: false,
    home: DashboardScreen(),
  ));
}

const Color primaryRed = Color(0xFFB70F0F);
const Color gradientRedStart = Color(0xFF9B0D0D);
const Color gradientRedEnd = Color(0xFFB70F0F);

class DashboardScreen extends StatelessWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle.light);
    return Scaffold(
      backgroundColor: Colors.white,
      body: CustomScrollView(
        physics: const BouncingScrollPhysics(),
        slivers: [
          // ====== HEADER + MINI DASHBOARD di dalam header ======
          SliverAppBar(
            backgroundColor: gradientRedStart,
            pinned: true,
            expandedHeight: 420, // diperpanjang supaya seluruh card muat
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
                    // Gambar karakter di kanan bawah
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
                            // Bar atas (menu + title + avatar)
                            Row(
                              children: const [
                                Icon(Icons.menu, color: Colors.white),
                                SizedBox(width: 10),
                                Text('BBI HUB +',
                                    style: TextStyle(
                                        color: Colors.white,
                                        fontWeight: FontWeight.bold)),
                                Spacer(),
                                CircleAvatar(
                                  radius: 18,
                                  backgroundColor: Colors.white,
                                  child: Icon(Icons.person, color: Colors.black),
                                ),
                              ],
                            ),
                            const SizedBox(height: 12),

                            const Text("Dashboard Owner",
                                style: TextStyle(color: Colors.white70, fontSize: 13)),
                            const SizedBox(height: 6),
                            const Text("Hallo, Owner AHASS",
                                style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 20,
                                    fontWeight: FontWeight.bold)),
                            const Text("Rabu, 8 oktober 2025",
                                style: TextStyle(color: Colors.white70)),
                            const SizedBox(height: 20),

                            // Spacer untuk mendorong mini dashboard ke bawah
                            const Spacer(),

                            // Card besar dashboard mini dengan gradasi
                            Container(
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
                                  // Tabs
                                  Row(
                                    children: ['Hari ini', 'Minggu ini', 'Bulan ini']
                                        .map((text) {
                                      final isActive = text == 'Hari ini';
                                      return Expanded(
                                        child: Container(
                                          margin: const EdgeInsets.symmetric(horizontal: 4),
                                          padding: const EdgeInsets.symmetric(vertical: 10),
                                          decoration: BoxDecoration(
                                            color: isActive ? Colors.white : const Color(0xFF9B0D0D),
                                            borderRadius: BorderRadius.circular(12),
                                          ),
                                          alignment: Alignment.center,
                                          child: Text(
                                            text,
                                            style: TextStyle(
                                              color: isActive ? primaryRed : Colors.white,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                        ),
                                      );
                                    }).toList(),
                                  ),
                                  const SizedBox(height: 16),

                                  // Ringkasan 3 card
                                  Row(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: const [
                                      _SummaryCard(
                                        value: "Rp. 64.700.k",
                                        label: "Pendapatan",
                                        growth: "+12.5%",
                                      ),
                                      SizedBox(width: 8),
                                      _SummaryCard(
                                        value: "27",
                                        label: "Total job",
                                        growth: "+8%",
                                      ),
                                      SizedBox(width: 8),
                                      _SummaryCard(
                                        value: "22",
                                        label: "Total Selesai",
                                        growth: "-",
                                      ),
                                    ],
                                  ),
                                ],
                              ),
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

          // ===== BODY CONTENT =====
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 24, 16, 24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    "Menu Cepat",
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 12),
                  _QuickMenuRow(),
                  const SizedBox(height: 28),

                  // Pekerjaan Terbaru
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        "Pekerjaan Terbaru",
                        style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                      ),
                      TextButton(
                        onPressed: () {},
                        child: const Text("Lihat semua", style: TextStyle(color: primaryRed)),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),

                  const _JobCard(
                    orderId: "WO-021-2501764",
                    name: "Sharabuddin Magomed",
                    vehicle: "Kijang Innova 2015 - L 2543 AB",
                    service: "Service AC Mobil + ganti oli",
                    timeAgo: "40 menit yang lalu",
                    status: "Process",
                    statusColor: Colors.red,
                    showRating: false,
                  ),
                  _JobCard(
                    orderId: "WO-002-2598827",
                    name: "Siti Nuhaliza",
                    vehicle: "Beat Fi 2017 - L 5678 CD",
                    service: "Ganti Fanbelt + Clean up CVT",
                    timeAgo: "15 menit yang lalu",
                    status: "Pending",
                    statusColor: Colors.amber[700]!,
                    showRating: false,
                  ),
                  const _JobCard(
                    orderId: "WO-000-250989",
                    name: "Emanuel Dirgantara",
                    vehicle: "CBR 150 / 2019 - L 6234 BI",
                    service: "Ganti Ban depan uk 2.75",
                    timeAgo: "1 jam yang lalu",
                    status: "Selesai",
                    statusColor: Colors.green,
                    showRating: true,
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

// ===== SUMMARY CARD =====
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
            // tetap putih agar kontras terhadap background gradasi besar
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
                growth.isNotEmpty ? growth : "-",
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

// ===== QUICK MENU =====
class _QuickMenuRow extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Row(
      children: const [
        _QuickMenuItem(icon: Icons.build, label: "Pekerjaan"),
        _QuickMenuItem(icon: Icons.people, label: "Karyawan"),
        _QuickMenuItem(icon: Icons.pie_chart, label: "Laporan"),
      ],
    );
  }
}

class _QuickMenuItem extends StatelessWidget {
  final IconData icon;
  final String label;

  const _QuickMenuItem({required this.icon, required this.label});

  @override
  Widget build(BuildContext context) {
    return Expanded(
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
    );
  }
}

// ===== JOB CARD =====
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
            // Order Id & Status badge
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(orderId, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: statusColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Text(status,
                      style: TextStyle(
                          color: statusColor, fontWeight: FontWeight.bold, fontSize: 12)),
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
              child: Text(service, style: const TextStyle(fontWeight: FontWeight.w500)),
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Text(timeAgo, style: const TextStyle(color: Colors.grey, fontSize: 12)),
                if (showRating) const Spacer(),
                if (showRating)
                  Row(children: List.generate(5, (index) => const Icon(Icons.star, color: Colors.amber, size: 16))),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
