import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'dart:math' as math;

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const RoundelAppBar(),
      body: const HomeContent(), // 🔥 ganti disini
    );
  }
}

class RoundelAppBar extends StatelessWidget implements PreferredSizeWidget {
  final int todayTasks;
  final DateTime? date;
  final String userName;
  final String roleLabel;
  final ImageProvider? avatar;
  final VoidCallback? onAvatarTap;

  final double greetingSize;
  final double subtitleSize;
  final double appNameSize;
  final double roleSize;
  final double dateValueSize;
  final double taskValueSize;
  final double labelSize;

  const RoundelAppBar({
    super.key,
    this.todayTasks = 12,
    this.date,
    this.userName = 'AHASS',
    this.roleLabel = 'workshop manager',
    this.avatar,
    this.onAvatarTap,
    this.greetingSize = 26,
    this.subtitleSize = 15,
    this.appNameSize = 14,
    this.roleSize = 12,
    this.dateValueSize = 20,
    this.taskValueSize = 20,
    this.labelSize = 12,
  });

  @override
  Size get preferredSize => const Size.fromHeight(324);

  @override
  Widget build(BuildContext context) {
    final now = date ?? DateTime.now();
    final tanggal = _formatTanggalID(now);
    final waktu = _greeting(now);

    return AppBar(
      elevation: 3,
      foregroundColor: Colors.white,
      backgroundColor: Colors.transparent,
      surfaceTintColor: Colors.transparent,
      shadowColor: Colors.black.withOpacity(0.25),
      systemOverlayStyle: SystemUiOverlayStyle.light,
      titleSpacing: 0,
      title: const SizedBox.shrink(),
      flexibleSpace: Stack(
        fit: StackFit.expand,
        children: [
          Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [Color(0xFF000000), Color(0xFFDC2626)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
          ),
          const Positioned(
            right: -40,
            top: -10,
            child: _Roundel(size: 240, color: Color(0xFFCA2323), opacity: 0.55),
          ),
          const Positioned(
            left: -60,
            top: -30,
            child: _Roundel(size: 200, color: Color(0xFFCA2323), opacity: 0.35),
          ),
          const Positioned(
            left: -20,
            bottom: -70,
            child: _Roundel(size: 280, color: Color(0xFF000000), opacity: 0.35),
          ),
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'BBI HUB +',
                              style: TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.w700,
                                fontSize: appNameSize,
                                letterSpacing: .3,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                            const SizedBox(height: 2),
                            Text(
                              roleLabel,
                              style: TextStyle(
                                color: Colors.white.withOpacity(0.85),
                                fontSize: roleSize,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ],
                        ),
                      ),
                      GestureDetector(
                        onTap: onAvatarTap,
                        child: CircleAvatar(
                          radius: 18,
                          backgroundColor: Colors.white.withOpacity(0.9),
                          backgroundImage: avatar,
                          child: avatar == null
                              ? const Icon(Icons.person, color: Colors.black)
                              : null,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 76),
                  const Padding(padding: EdgeInsets.only(left: 20)),
                  Text(
                    'Selamat $waktu, $userName',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: greetingSize,
                      fontWeight: FontWeight.w700,
                      height: 1.1,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'workshop Anda untuk hari ini',
                    style: TextStyle(
                      color: Colors.white.withOpacity(0.92),
                      fontSize: subtitleSize,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const Spacer(),
                  Center(
                    child: _StatsPill(
                      tanggal: tanggal,
                      tasks: todayTasks,
                      dateValueSize: dateValueSize,
                      taskValueSize: taskValueSize,
                      labelSize: labelSize,
                    ),
                  ),
                  const SizedBox(height: 28),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _Roundel extends StatelessWidget {
  final double size;
  final Color color;
  final double opacity;
  const _Roundel({required this.size, required this.color, this.opacity = 0.6});

  @override
  Widget build(BuildContext context) {
    return IgnorePointer(
      child: Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          gradient: RadialGradient(
            colors: [
              color.withOpacity(opacity),
              color.withOpacity(opacity * .25),
              color.withOpacity(0),
            ],
            stops: const [0.0, 0.55, 1.0],
          ),
        ),
      ),
    );
  }
}

class _StatsPill extends StatelessWidget {
  final String tanggal;
  final int tasks;
  final double dateValueSize;
  final double taskValueSize;
  final double labelSize;

  const _StatsPill({
    required this.tanggal,
    required this.tasks,
    this.dateValueSize = 20,
    this.taskValueSize = 20,
    this.labelSize = 12,
  });

  @override
  Widget build(BuildContext context) {
    final sw = MediaQuery.of(context).size.width;
    final double pillWidth = math.min(364.0, math.max(240.0, sw - 32.0));

    return Container(
      width: pillWidth,
      constraints: const BoxConstraints(minHeight: 92.0),
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.14),
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: Colors.white.withOpacity(0.22), width: 1),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.18),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Tanggal sekarang',
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.85),
                    fontSize: labelSize,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  tanggal,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                    height: 1.1,
                  ),
                ),
              ],
            ),
          ),
          Container(
            width: 1,
            height: 44,
            margin: const EdgeInsets.symmetric(horizontal: 12),
            color: Colors.white.withOpacity(0.25),
          ),
          Expanded(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  'Tugas hari ini',
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.85),
                    fontSize: labelSize,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  '$tasks',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: taskValueSize,
                    fontWeight: FontWeight.w700,
                    height: 1.1,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ------------------- HOME CONTENT -------------------
class HomeContent extends StatelessWidget {
  const HomeContent({super.key});

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              "Kinerja Harian Bengkel",
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
            ),
            TextButton(onPressed: () {}, child: const Text("Lihat detail")),
          ],
        ),
        const SizedBox(height: 8),
        GridView.count(
          crossAxisCount: 2,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          mainAxisSpacing: 12,
          crossAxisSpacing: 12,
          childAspectRatio: 1.2,
          children: const [
            _StatCard(title: "Antrian", value: "24"),
            _StatCard(title: "Servis Selesai", value: "12"),
            _StatCard(title: "Sparepart Terpakai", value: "58"),
            _StatCard(title: "Teknisi Aktif", value: "6"),
          ],
        ),
        const SizedBox(height: 24),
        const Text(
          "Fitur Cepat",
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
        ),
        const SizedBox(height: 12),
        GridView.count(
          crossAxisCount: 5,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          mainAxisSpacing: 12,
          crossAxisSpacing: 12,
          childAspectRatio: 0.8,
          children: const [
            _QuickFeature(icon: Icons.list_alt, label: "Antrian"),
            _QuickFeature(icon: Icons.build, label: "Servis"),
            _QuickFeature(icon: Icons.inventory, label: "Sparepart"),
            _QuickFeature(icon: Icons.people, label: "Pelanggan"),
            _QuickFeature(icon: Icons.bar_chart, label: "Laporan"),
          ],
        ),
        const SizedBox(height: 24),
        Card(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          elevation: 2,
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                const Icon(Icons.warning, color: Colors.red, size: 36),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: const [
                      Text(
                        "Cek list antrian pelanggan kamu!!",
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      SizedBox(height: 4),
                      Text(
                        "Klik tombol dibawah ini untuk masuk menu Service",
                        style: TextStyle(fontSize: 12),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 16),
        ClipRRect(
          borderRadius: BorderRadius.circular(16),
          child: Image.asset(
            "assets/images/banner.png",
            fit: BoxFit.cover,
            height: 160,
          ),
        ),
      ],
    );
  }
}

class _StatCard extends StatelessWidget {
  final String title;
  final String value;
  const _StatCard({required this.title, required this.value});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.red.shade50,
        borderRadius: BorderRadius.circular(16),
      ),
      padding: const EdgeInsets.all(16),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            value,
            style: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Colors.red,
            ),
          ),
          const SizedBox(height: 6),
          Text(title, style: const TextStyle(fontSize: 13)),
        ],
      ),
    );
  }
}

class _QuickFeature extends StatelessWidget {
  final IconData icon;
  final String label;
  const _QuickFeature({required this.icon, required this.label});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          decoration: BoxDecoration(
            color: Colors.red.shade100,
            borderRadius: BorderRadius.circular(12),
          ),
          padding: const EdgeInsets.all(8),
          child: Icon(icon, size: 28, color: Colors.red),
        ),
        const SizedBox(height: 6),
        Text(label, style: const TextStyle(fontSize: 11)),
      ],
    );
  }
}

// Helpers
String _formatTanggalID(DateTime d) {
  const bulan = [
    'Januari',
    'Februari',
    'Maret',
    'April',
    'Mei',
    'Juni',
    'Juli',
    'Agustus',
    'September',
    'Oktober',
    'November',
    'Desember',
  ];
  return '${d.day} ${bulan[d.month - 1]} ${d.year}';
}

String _greeting(DateTime d) {
  final h = d.hour;
  if (h >= 4 && h < 11) return 'Pagi';
  if (h >= 11 && h < 15) return 'Siang';
  if (h >= 15 && h < 19) return 'Sore';
  return 'Malam';
}
