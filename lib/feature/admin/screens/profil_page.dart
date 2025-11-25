import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

// Import services dan models
import 'package:bengkel_online_flutter/core/services/auth_provider.dart';
import 'package:bengkel_online_flutter/core/models/user.dart';

// Import halaman-halaman tujuan (pastikan path-nya sesuai)
import 'package:bengkel_online_flutter/feature/owner/screens/feedback.dart';
import 'package:bengkel_online_flutter/feature/owner/screens/voucher_page.dart';
import 'package:bengkel_online_flutter/feature/owner/screens/edit_profile_page.dart';
import 'package:bengkel_online_flutter/feature/owner/screens/ubah_bahasa_page.dart';
import 'package:bengkel_online_flutter/feature/owner/screens/help_support_page.dart';

// (Nama kelas diubah menjadi ProfilePageAdmin)
class ProfilePageAdmin extends StatelessWidget {
  const ProfilePageAdmin({super.key});

  // Helper untuk mendapatkan inisial dari nama
  String _getInitials(String name) {
    if (name.isEmpty) return 'A';
    final parts = name.trim().split(' ');
    if (parts.length > 1) {
      return (parts.first.isNotEmpty ? parts.first[0] : '') +
          (parts.last.isNotEmpty ? parts.last[0] : '');
    } else if (parts.first.isNotEmpty) {
      return parts.first[0];
    }
    return 'A';
  }

  // Helper untuk format nama role
  String _formatRole(String role) {
    if (role.isEmpty) return 'User';
    return role[0].toUpperCase() + role.substring(1);
  }

  @override
  Widget build(BuildContext context) {
    // ====== 1. AMBIL DATA DARI PROVIDER ======
    final auth = context.watch<AuthProvider>();
    final User? user = auth.user;

    // Pengaman jika user null (misal saat proses logout)
    if (user == null) {
      return const Scaffold(
        backgroundColor: Color(0xFFF4F4F5),
        body: Center(
          child: CircularProgressIndicator(color: Color(0xFF9B0D0D)),
        ),
      );
    }

    // ====== 2. SIAPKAN DATA ADMIN (BERBEDA DARI OWNER) ======
    final String photoUrl = user.photo ?? '';
    final String initials = _getInitials(user.name);
    final String adminName = user.name; // <-- Pakai nama user
    final String adminEmail = user.email; // <-- Pakai email user
    final String roleName = _formatRole(user.role); // <-- Akan jadi "Admin"

    return Scaffold(
      backgroundColor: const Color(0xFFF4F4F5),
      body: LayoutBuilder(
        builder: (context, constraints) {
          final width = constraints.maxWidth;

          // (Sizing responsif tetap sama)
          final bottomRadius = width * 0.08;
          final avatarRadius =
          ((width * 0.15)).clamp(46.0, 72.0);
          final titleFontSize =
          (width * 0.045).clamp(16.0, 20.0);
          final nameFontSize =
          (width * 0.048).clamp(15.0, 22.0);
          final usernameFontSize =
          (width * 0.032).clamp(11.0, 14.0);
          final roleFontSize =
          (width * 0.032).clamp(11.0, 14.0);
          final editFontSize =
          (width * 0.04).clamp(12.0, 16.0);
          final itemIconSize =
          (width * 0.06).clamp(18.0, 26.0);
          final itemFontSize =
          (width * 0.04).clamp(13.0, 16.0);

          const primaryInner = Color(0xFF9B0D0D);
          const primaryOuter = Color(0xFFB70F0F);
          const softSurface = Color(0xFFFFFFFF);

          return SingleChildScrollView(
            physics: const BouncingScrollPhysics(),
            child: Column(
              children: [
                // ====== HEADER GRADIENT (Tetap) ======
                ClipRRect(
                  borderRadius: BorderRadius.vertical(
                    bottom: Radius.circular(bottomRadius),
                  ),
                  child: Container(
                    width: double.infinity,
                    decoration: const BoxDecoration(
                      gradient: LinearGradient(
                        colors: [primaryInner, primaryOuter],
                        stops: [0.29, 0.79],
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                      ),
                    ),
                    child: SafeArea(
                      child: Padding(
                        padding: EdgeInsets.only(
                          top: width * 0.06,
                          bottom: width * 0.18,
                          left: width * 0.05,
                          right: width * 0.05,
                        ),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            // Title (Tetap)
                            _FadeInSlide(
                              offsetY: 14,
                              delayMs: 0,
                              child: Text(
                                "Profile",
                                style: GoogleFonts.poppins(
                                  color: Colors.white,
                                  fontSize: titleFontSize,
                                  fontWeight: FontWeight.w600,
                                  letterSpacing: 0.4,
                                ),
                              ),
                            ),
                            SizedBox(height: width * 0.04),

                            // ====== 3. AVATAR ADMIN DINAMIS ======
                            _ScaleIn(
                              delayMs: 80,
                              child: CircleAvatar(
                                radius: avatarRadius,
                                backgroundColor:
                                Colors.white.withOpacity(0.15),
                                child: _ProfileAvatar(
                                  photoUrl: photoUrl,
                                  initials: initials,
                                  radius: avatarRadius - 4,
                                  color: primaryInner,
                                ),
                              ),
                            ),
                            SizedBox(height: width * 0.03),

                            // ====== 4. NAMA ADMIN DINAMIS ======
                            _FadeInSlide(
                              offsetY: 12,
                              delayMs: 160,
                              child: Text(
                                adminName, // <-- Data Dinamis
                                textAlign: TextAlign.center,
                                style: GoogleFonts.poppins(
                                  color: Colors.white,
                                  fontSize: nameFontSize,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                            SizedBox(height: width * 0.008),

                            // ====== 5. EMAIL ADMIN DINAMIS ======
                            _FadeInSlide(
                              offsetY: 10,
                              delayMs: 220,
                              child: Text(
                                adminEmail, // <-- Data Dinamis
                                style: GoogleFonts.poppins(
                                  color: Colors.white.withOpacity(0.8),
                                  fontSize: usernameFontSize,
                                ),
                              ),
                            ),
                            SizedBox(height: width * 0.02),

                            // Role Badge + Edit Button
                            _FadeInSlide(
                              offsetY: 10,
                              delayMs: 280,
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  // ====== 6. ROLE DINAMIS ======
                                  Container(
                                    padding: EdgeInsets.symmetric(
                                      horizontal: width * 0.03,
                                      vertical: width * 0.008,
                                    ),
                                    decoration: BoxDecoration(
                                      color: Colors.white.withOpacity(0.18),
                                      borderRadius: BorderRadius.circular(14),
                                    ),
                                    child: Text(
                                      roleName, // <-- Data Dinamis (akan jadi "Admin")
                                      style: GoogleFonts.poppins(
                                        color: Colors.white,
                                        fontSize: roleFontSize,
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                  ),
                                  SizedBox(width: width * 0.03),
                                  // Edit button (Tetap)
                                  TextButton.icon(
                                    style: TextButton.styleFrom(
                                      foregroundColor: Colors.white,
                                      padding: EdgeInsets.symmetric(
                                        horizontal: width * 0.04,
                                        vertical: width * 0.01,
                                      ),
                                      shape: RoundedRectangleBorder(
                                        borderRadius:
                                        BorderRadius.circular(24),
                                        side: BorderSide(
                                          color: Colors.white.withOpacity(0.4),
                                          width: 0.8,
                                        ),
                                      ),
                                    ),
                                    onPressed: () {
                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                          builder: (_) =>
                                          const EditProfilePage(),
                                        ),
                                      );
                                    },
                                    icon: const Icon(
                                      Icons.edit_outlined,
                                      size: 18,
                                    ),
                                    label: Text(
                                      "Edit",
                                      style: GoogleFonts.poppins(
                                        fontSize: editFontSize,
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),

                // ====== CARD MENU (Tetap) ======
                Transform.translate(
                  offset: Offset(0, -width * 0.13),
                  child: Padding(
                    padding: EdgeInsets.symmetric(horizontal: width * 0.05),
                    child: _FadeInSlide(
                      offsetY: 16,
                      delayMs: 180,
                      child: Card(
                        elevation: 3,
                        shadowColor: Colors.black26,
                        color: softSurface,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(width * 0.045),
                        ),
                        child: Padding(
                          padding: EdgeInsets.symmetric(
                            vertical: width * 0.02,
                          ),
                          child: Column(
                            children: [
                              _AnimatedProfileItem(
                                index: 0,
                                iconPath: "assets/icons/bahasa.svg",
                                title: "Bahasa",
                                iconSize: itemIconSize,
                                fontSize: itemFontSize,
                                onTap: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (_) => const UbahBahasaPage(),
                                    ),
                                  );
                                },
                              ),
                              const _SoftDivider(),
                              _AnimatedProfileItem(
                                index: 1,
                                iconPath: "assets/icons/help.svg",
                                title: "Bantuan & Dukungan",
                                iconSize: itemIconSize,
                                fontSize: itemFontSize,
                                onTap: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (_) => const HelpSupportPage(),
                                    ),
                                  );
                                },
                              ),
                              const _SoftDivider(),
                              _AnimatedProfileItem(
                                index: 2,
                                iconPath: "assets/icons/password.svg",
                                title: "Ganti Password",
                                iconSize: itemIconSize,
                                fontSize: itemFontSize,
                                onTap: () {
                                  Navigator.pushNamed(context, '/changePassword');
                                },
                              ),

                              // (Anda bisa hapus Voucher & Feedback jika
                              // tidak relevan untuk Admin)
                              const _SoftDivider(),
                              _AnimatedProfileItem(
                                index: 3,
                                iconPath: "assets/icons/voucher.svg",
                                title: "Voucher",
                                iconSize: itemIconSize,
                                fontSize: itemFontSize,
                                onTap: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (_) => const VoucherPage(),
                                    ),
                                  );
                                },
                              ),
                              const _SoftDivider(),
                              _AnimatedProfileItem(
                                index: 4,
                                iconPath: "assets/icons/feedback.svg",
                                title: "Umpan Balik",
                                iconSize: itemIconSize,
                                fontSize: itemFontSize,
                                onTap: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (_) => const FeedbackPage(),
                                    ),
                                  );
                                },
                              ),
                              const _SoftDivider(),

                              // ====== LOGOUT (Logika tetap sama) ======
                              _AnimatedProfileItem(
                                index: 5,
                                iconPath: "assets/icons/logout.svg",
                                title: "Keluar",
                                isLogout: true,
                                iconSize: itemIconSize,
                                fontSize: itemFontSize,
                                onTap: () {
                                  showDialog(
                                    context: context,
                                    builder: (dialogContext) => AlertDialog(
                                      shape: RoundedRectangleBorder(
                                        borderRadius:
                                        BorderRadius.circular(20),
                                      ),
                                      title: Text(
                                        "Keluar",
                                        style: GoogleFonts.poppins(
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                      content: Text(
                                        "Apakah Anda yakin ingin keluar?",
                                        style: GoogleFonts.poppins(),
                                      ),
                                      actions: [
                                        TextButton(
                                          onPressed: () =>
                                              Navigator.pop(dialogContext),
                                          child: Text(
                                            "Batal",
                                            style: GoogleFonts.poppins(),
                                          ),
                                        ),
                                        TextButton(
                                          onPressed: () {
                                            // Panggil logout dari AuthProvider
                                            context.read<AuthProvider>().logout();

                                            Navigator.of(context)
                                                .pushNamedAndRemoveUntil(
                                              '/login',
                                                  (route) => false,
                                            );
                                          },
                                          child: Text(
                                            "Ya",
                                            style: GoogleFonts.poppins(
                                              fontWeight: FontWeight.w500,
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  );
                                },
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                ),

                SizedBox(height: width * 0.02),
              ],
            ),
          );
        },
      ),
    );
  }
}

// ==========================================================
// (SEMUA HELPER WIDGETS DI BAWAH INI TETAP SAMA)
// ==========================================================

/// Widget ini menampilkan NetworkImage, atau fallback ke Inisial
class _ProfileAvatar extends StatelessWidget {
  final String? photoUrl;
  final String initials;
  final double radius;
  final Color color;

  const _ProfileAvatar({
    required this.photoUrl,
    required this.initials,
    required this.radius,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    final hasImage = (photoUrl != null &&
        photoUrl!.isNotEmpty &&
        (photoUrl!.startsWith('http') || photoUrl!.startsWith('https')));

    return CircleAvatar(
      radius: radius,
      backgroundColor: color,
      backgroundImage: hasImage ? NetworkImage(photoUrl!) : null,
      child: hasImage
          ? null
          : Text(
        initials.toUpperCase(),
        style: GoogleFonts.poppins(
          color: Colors.white,
          fontSize: radius * 0.9,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}

// ====== Divider yang lebih halus ======
class _SoftDivider extends StatelessWidget {
  const _SoftDivider();

  @override
  Widget build(BuildContext context) {
    return Divider(
      height: 1,
      thickness: 0.5,
      indent: MediaQuery.of(context).size.width * 0.16,
      endIndent: MediaQuery.of(context).size.width * 0.04,
      color: Colors.grey.withOpacity(0.25),
    );
  }
}

// ===== ProfileItem (responsif & tetap dipakai) =====
class _ProfileItem extends StatelessWidget {
  final String iconPath;
  final String title;
  final bool isLogout;
  final VoidCallback? onTap;
  final double iconSize;
  final double fontSize;

  const _ProfileItem({
    required this.iconPath,
    required this.title,
    this.isLogout = false,
    this.onTap,
    this.iconSize = 28,
    this.fontSize = 16,
  });

  @override
  Widget build(BuildContext context) {
    final isDarkLogout = isLogout;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: EdgeInsets.symmetric(
            horizontal: MediaQuery.of(context).size.width * 0.04,
            vertical: 6,
          ),
          child: ListTile(
            minLeadingWidth: 0,
            contentPadding: EdgeInsets.zero,
            leading: _buildIcon(
              iconPath,
              size: iconSize,
              color: isDarkLogout
                  ? const Color(0xFFB70F0F)
                  : const Color(0xFF9B0D0D),
            ),
            title: Text(
              title,
              style: GoogleFonts.poppins(
                fontSize: fontSize,
                color: isDarkLogout
                    ? const Color(0xFFB70F0F)
                    : const Color(0xFF111827),
                fontWeight: isDarkLogout ? FontWeight.w600 : FontWeight.w400,
              ),
            ),
            trailing: Icon(
              Icons.arrow_forward_ios_rounded,
              size: fontSize * 0.82,
              color: Colors.grey[500],
            ),
          ),
        ),
      ),
    );
  }

  /// ✅ Fungsi helper untuk menampilkan ikon baik .svg maupun .png
  Widget _buildIcon(String path, {Color? color, double size = 24}) {
    if (path.toLowerCase().endsWith('.svg')) {
      return SvgPicture.asset(
        path,
        width: size,
        height: size,
        colorFilter: color != null ? ColorFilter.mode(color, BlendMode.srcIn) : null,
      );
    }
    return Image.asset(path, width: size, height: size, color: color);
  }
}

// ====== Wrapper untuk animasi item menu (fade + slide + sedikit "lazy") ======
class _AnimatedProfileItem extends StatelessWidget {
  final int index;
  final String iconPath;
  final String title;
  final bool isLogout;
  final VoidCallback? onTap;
  final double iconSize;
  final double fontSize;

  const _AnimatedProfileItem({
    required this.index,
    required this.iconPath,
    required this.title,
    this.isLogout = false,
    this.onTap,
    this.iconSize = 28,
    this.fontSize = 16,
  });

  @override
  Widget build(BuildContext context) {
    final delayMs = 80 * index;

    return _FadeInSlide(
      offsetY: 10,
      delayMs: delayMs,
      child: _ProfileItem(
        iconPath: iconPath,
        title: title,
        isLogout: isLogout,
        onTap: onTap,
        iconSize: iconSize,
        fontSize: fontSize,
      ),
    );
  }
}

// ====== Widget helper animasi (smooth & ringan) ======

class _FadeInSlide extends StatelessWidget {
  final Widget child;
  final double offsetY;
  final int delayMs;

  const _FadeInSlide({
    required this.child,
    this.offsetY = 12,
    this.delayMs = 0,
  });

  @override
  Widget build(BuildContext context) {
    return TweenAnimationBuilder<double>(
      duration: const Duration(milliseconds: 420),
      curve: Curves.easeOutCubic,
      tween: Tween(begin: 0, end: 1),
      builder: (context, value, child) {
        double t = value;
        if (delayMs > 0) {
          final totalMs = 420 + delayMs;
          final current = (value * totalMs).clamp(0, totalMs).toDouble();
          t = (current - delayMs) / (totalMs - delayMs);
          t = t.clamp(0.0, 1.0);
        }

        return Opacity(
          opacity: t,
          child: Transform.translate(
            offset: Offset(0, (1 - t) * offsetY),
            child: child,
          ),
        );
      },
      child: child,
    );
  }
}

class _ScaleIn extends StatelessWidget {
  final Widget child;
  final int delayMs;

  const _ScaleIn({
    required this.child,
    this.delayMs = 0,
  });

  @override
  Widget build(BuildContext context) {
    return TweenAnimationBuilder<double>(
      duration: const Duration(milliseconds: 420),
      curve: Curves.easeOutCubic,
      tween: Tween(begin: 0.85, end: 1),
      builder: (context, value, child) {
        double t = value;
        if (delayMs > 0) {
          final totalMs = 420 + delayMs;
          final current = (value * totalMs).clamp(0, totalMs).toDouble();
          t = 0.85 +
              ((current - delayMs) / (totalMs - delayMs))
                  .clamp(0.0, 1.0) *
                  (1 - 0.85);
        }
        return Transform.scale(
          scale: t,
          child: child,
        );
      },
      child: child,
    );
  }
}