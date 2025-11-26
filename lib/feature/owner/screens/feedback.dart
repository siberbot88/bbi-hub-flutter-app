// 📄 lib/feature/admin/screens/feedback_page.dart
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../widgets/custom_header.dart';

class FeedbackPage extends StatefulWidget {
  const FeedbackPage({super.key});

  @override
  State<FeedbackPage> createState() => _FeedbackPageState();
}

class _FeedbackPageState extends State<FeedbackPage> {
  static const _redDark = Color(0xFF9B0D0D);
  static const _bg = Color(0xFFF4F4F6);

  String _selectedFilter = 'semua'; // semua | 5 | 4 | 3 | 2 | 1

  final _reviews = <_Review>[
    _Review(
      initials: 'BS',
      name: 'Budi Santoso',
      ago: '1 hari lalu',
      stars: 5,
      service: 'Ganti Oli & Tune Up',
      text:
          'Pelayanan sangat memuaskan! Mekanik ramah dan profesional. Harga juga transparan, dijelaskan detail sebelum pengerjaan. Pasti balik lagi!',
    ),
    _Review(
      initials: 'SN',
      name: 'Siti Nurhaliza',
      ago: '2 hari lalu',
      stars: 5,
      service: 'Service Berkala',
      text:
          'Bengkel terbaik yang pernah saya kunjungi. Ruang tunggu nyaman, wifi kenceng, dan pengerjaan cepat. Recommended!',
    ),
    _Review(
      initials: 'AW',
      name: 'Andi Wijaya',
      ago: '1 minggu lalu',
      stars: 4,
      service: 'Perbaikan AC Mobil',
      text:
          'Overall bagus, AC mobil jadi dingin lagi. Cuma agak lama nunggu karena ramai. Tapi hasil kerjanya oke.',
    ),
    _Review(
      initials: 'DL',
      name: 'Dewi Lestari',
      ago: '1 minggu lalu',
      stars: 5,
      service: 'Ganti Ban & Balancing',
      text:
          'Cepat dan rapi! Mekaniknya juga kasih saran untuk perawatan ban. Tempatnya bersih dan nyaman.',
    ),
    _Review(
      initials: 'RH',
      name: 'Rudi Hartono',
      ago: '2 minggu lalu',
      stars: 5,
      service: 'Servis Rem',
      text:
          'Bagus, rem mobil jadi pakem lagi. Harga standar, sesuai dengan kualitas pekerjaan.',
    ),
  ];

  @override
  Widget build(BuildContext context) {
    final filtered = _selectedFilter == 'semua'
        ? _reviews
        : _reviews.where((r) => r.stars.toString() == _selectedFilter).toList();

    return Scaffold(
      backgroundColor: _bg,
      appBar: const CustomHeader(
        title: 'Rating & Ulasan',
        showBack: true,
        roundedBottomRadius: 28,
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
        children: [
          _searchBar(),
          const SizedBox(height: 14),
          _ratingSummaryCard(),
          const SizedBox(height: 12),
          _filterChips(),
          const SizedBox(height: 12),
          ...filtered
              .map((r) => _reviewCard(r))
              .expand((w) => [w, const SizedBox(height: 12)]),
          _seeMore(),
        ],
      ),
    );
  }

  // ---------- SEARCH ----------
  Widget _searchBar() {
    return Container(
      height: 44,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(22),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha(13),
            blurRadius: 10,
            offset: const Offset(0, 4),
          )
        ],
      ),
      child: TextField(
        style: GoogleFonts.poppins(fontSize: 13),
        decoration: InputDecoration(
          hintText: 'Cari ulasan...',
          hintStyle: GoogleFonts.poppins(color: Colors.black38, fontSize: 13),
          prefixIcon: const Icon(Icons.search, color: Colors.black38),
          border: InputBorder.none,
          contentPadding: const EdgeInsets.only(top: 12),
        ),
      ),
    );
  }

  // ---------- RATING SUMMARY CARD ----------
  Widget _ratingSummaryCard() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha(20),
            blurRadius: 10,
            offset: const Offset(0, 4),
          )
        ],
      ),
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 12),
      child: Column(
        children: [
          Row(
            children: [
              // kiri: angka besar + bintang + total ulasan
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('4.8',
                        style: GoogleFonts.poppins(
                            fontSize: 34, fontWeight: FontWeight.w700)),
                    const SizedBox(height: 4),
                    _starsRow(5, size: 18),
                    const SizedBox(height: 4),
                    Text('247 Ulasan',
                        style: GoogleFonts.poppins(
                            fontSize: 12, color: Colors.black54)),
                  ],
                ),
              ),
              // kanan: progress bar 5/4/3
              SizedBox(
                width: 160,
                child: Column(
                  children: const [
                    _RatingBarRow(label: '5', percent: 0.86, count: 198),
                    SizedBox(height: 8),
                    _RatingBarRow(label: '4', percent: 0.16, count: 37),
                    SizedBox(height: 8),
                    _RatingBarRow(label: '3', percent: 0.06, count: 10),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          // badges
          Row(
            children: [
              _statBadge(
                icon: Icons.thumb_up_alt_rounded,
                label: '96% Kepuasan',
              ),
              const SizedBox(width: 10),
              _statBadge(
                icon: Icons.calendar_month_rounded,
                label: '4.9 Bulan ini',
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _statBadge({required IconData icon, required String label}) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 12),
        decoration: BoxDecoration(
          color: const Color(0xFFF4C7C7),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Row(
          children: [
            Container(
              width: 20,
              height: 20,
              decoration: const BoxDecoration(
                color: Colors.white,
                shape: BoxShape.circle,
              ),
              child: Icon(icon, size: 14, color: _redDark),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Text(label,
                  style: GoogleFonts.poppins(
                      fontSize: 12.5,
                      color: _redDark,
                      fontWeight: FontWeight.w600)),
            ),
          ],
        ),
      ),
    );
  }

  // ---------- FILTER CHIPS ----------
  Widget _filterChips() {
    final filters = ['semua', '5', '4', '3', '2', '1'];
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(children: filters.map((f) => _chip(f)).toList()),
    );
  }

  Widget _chip(String value) {
    final isAll = value == 'semua';
    final selected = _selectedFilter == value;

    final Color bg;
    final Color border;
    final Color textColor;

    if (isAll) {
      bg = selected ? const Color(0xFFFFA63A) : const Color(0xFFFFE1BD);
      border = Colors.transparent;
      textColor = selected ? Colors.white : const Color(0xFF9B6A2E);
    } else {
      bg = Colors.white;
      border = selected ? const Color(0xFF999999) : const Color(0xFFDDDDDD);
      textColor = Colors.black87;
    }

    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: GestureDetector(
        onTap: () => setState(() => _selectedFilter = value),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
          decoration: BoxDecoration(
            color: bg,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: border),
          ),
          child: Row(
            children: [
              if (isAll) ...const [
                Icon(Icons.filter_alt, size: 16, color: Colors.orange),
                SizedBox(width: 6),
              ] else ...const [
                Icon(Icons.star,
                    size: 16, color: Color.fromARGB(255, 248, 248, 247)),
                SizedBox(width: 6),
              ],
              Text(isAll ? 'semua' : value,
                  style: GoogleFonts.poppins(
                      fontSize: 12.5,
                      fontWeight: FontWeight.w600,
                      color: textColor)),
            ],
          ),
        ),
      ),
    );
  }

  // ---------- REVIEW CARD ----------
  Widget _reviewCard(_Review r) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
              color: Colors.black.withAlpha(20),
              blurRadius: 10,
              offset: const Offset(0, 4))
        ],
      ),
      padding: const EdgeInsets.fromLTRB(14, 12, 14, 12),
      child: Column(
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _initialsAvatar(r.initials),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Nama + waktu
                    Row(
                      children: [
                        Expanded(
                          child: Text(r.name,
                              style: GoogleFonts.poppins(
                                  fontWeight: FontWeight.w700, fontSize: 13.5)),
                        ),
                        Text(r.ago,
                            style: GoogleFonts.poppins(
                                fontSize: 12, color: Colors.black45)),
                      ],
                    ),
                    const SizedBox(height: 4),
                    _starsRow(r.stars),
                    const SizedBox(height: 8),
                    _serviceTag(r.service),
                    const SizedBox(height: 10),
                    Text(r.text,
                        style: GoogleFonts.poppins(
                            fontSize: 13, color: Colors.black87)),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Align(
            alignment: Alignment.centerLeft,
            child: ElevatedButton(
              onPressed: () {},
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFFFA63A),
                foregroundColor: Colors.white,
                elevation: 0,
                padding:
                    const EdgeInsets.symmetric(horizontal: 18, vertical: 8),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(18)),
              ),
              child: Text('Balas',
                  style: GoogleFonts.poppins(
                      fontSize: 13, fontWeight: FontWeight.w600)),
            ),
          ),
        ],
      ),
    );
  }

  Widget _initialsAvatar(String initials) {
    return Container(
      width: 40,
      height: 40,
      decoration: const BoxDecoration(
        shape: BoxShape.circle,
        gradient: LinearGradient(
          colors: [Color(0xFF64B5F6), Color(0xFF42A5F5)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      alignment: Alignment.center,
      child: Text(initials,
          style: GoogleFonts.poppins(
              color: Colors.white, fontWeight: FontWeight.w700, fontSize: 12)),
    );
  }

  Widget _starsRow(int count, {double size = 16}) {
    return Row(
      children: List.generate(
        5,
        (i) => Icon(
          i < count ? Icons.star : Icons.star_border,
          size: size,
          color: const Color(0xFFFFB300),
        ),
      ),
    );
  }

  Widget _serviceTag(String label) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: const Color(0xFFEDEDED),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(label,
          style: GoogleFonts.poppins(
              fontSize: 12.5,
              color: Colors.black54,
              fontWeight: FontWeight.w500)),
    );
  }

  Widget _seeMore() {
    return Padding(
      padding: const EdgeInsets.only(top: 4),
      child: Center(
        child: Text(
          'Lihat lebih banyak lagi',
          style: GoogleFonts.poppins(
            fontSize: 13.5,
            fontWeight: FontWeight.w600,
            color: Colors.black87,
          ),
        ),
      ),
    );
  }
}

// ---------- SMALL WIDGETS ----------
class _RatingBarRow extends StatelessWidget {
  final String label;
  final double percent; // 0..1
  final int count;
  const _RatingBarRow({
    required this.label,
    required this.percent,
    required this.count,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        const Icon(Icons.star, size: 16, color: Color(0xFFFFB300)),
        const SizedBox(width: 4),
        Text(label,
            style: GoogleFonts.poppins(
                fontSize: 12.5, fontWeight: FontWeight.w600)),
        const SizedBox(width: 8),
        Expanded(
          child: Stack(
            alignment: Alignment.centerLeft,
            children: [
              Container(
                height: 8,
                decoration: BoxDecoration(
                  color: const Color(0xFFE6E6E6),
                  borderRadius: BorderRadius.circular(20),
                ),
              ),
              FractionallySizedBox(
                widthFactor: percent.clamp(0.0, 1.0),
                child: Container(
                  height: 8,
                  decoration: BoxDecoration(
                    color: const Color(0xFFFFB300),
                    borderRadius: BorderRadius.circular(20),
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(width: 8),
        Text('$count',
            style: GoogleFonts.poppins(fontSize: 12, color: Colors.black54)),
      ],
    );
  }
}

class _Review {
  final String initials;
  final String name;
  final String ago;
  final int stars;
  final String service;
  final String text;

  const _Review({
    required this.initials,
    required this.name,
    required this.ago,
    required this.stars,
    required this.service,
    required this.text,
  });
}
