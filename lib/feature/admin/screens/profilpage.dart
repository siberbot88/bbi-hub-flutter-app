// urutan import yang rapi: dart -> flutter -> package -> local
import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:google_fonts/google_fonts.dart';

import 'package:bengkel_online_flutter/feature/admin/screens/change_password.dart';
import 'package:bengkel_online_flutter/feature/admin/screens/feedback.dart';
import 'package:bengkel_online_flutter/feature/admin/screens/voucher_page.dart';
import 'package:bengkel_online_flutter/feature/admin/screens/edit_profile_page.dart';
import 'package:bengkel_online_flutter/feature/admin/screens/ubah_bahasa_page.dart';
import 'package:bengkel_online_flutter/feature/admin/screens/help_support_page.dart';


class ProfilePage extends StatelessWidget {
  const ProfilePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: LayoutBuilder(
        builder: (context, constraints) {
          final width = constraints.maxWidth;

          // ====== Responsif sizing ======
          final bottomRadius = width * 0.08;
          final avatarRadius = ((width * 0.16)).clamp(50.0, 88.0) as double;
          final titleFontSize =
              width < 360 ? 18.0 : (width > 600 ? 24.0 : 20.0);
          final nameFontSize = (width * 0.05).clamp(16.0, 26.0) as double;
          final usernameFontSize = (width * 0.035).clamp(12.0, 16.0) as double;
          final roleFontSize = (width * 0.036).clamp(12.0, 16.0) as double;
          final editFontSize = (width * 0.045).clamp(13.0, 18.0) as double;
          final itemIconSize = (width * 0.07).clamp(20.0, 36.0) as double;
          final itemFontSize = (width * 0.045).clamp(14.0, 18.0) as double;

          const primaryInner = Color(0xFF9B0D0D);
          const primaryOuter = Color(0xFFDC2626);

          return SingleChildScrollView(
            child: Column(
              children: [
                // ====== HEADER GRADIENT ======
                ClipRRect(
                  borderRadius: BorderRadius.vertical(
                    bottom: Radius.circular(bottomRadius),
                  ),
                  child: Container(
                    width: double.infinity,
                    decoration: const BoxDecoration(
                      gradient: LinearGradient(
                        colors: [primaryInner, primaryOuter],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                    ),
                    child: SafeArea(
                      child: Padding(
                        padding: EdgeInsets.symmetric(
                          vertical: width * 0.06,
                          horizontal: width * 0.05,
                        ),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            Text(
                              "Profile",
                              style: GoogleFonts.poppins(
                                color: Colors.white,
                                fontSize: titleFontSize,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                            SizedBox(height: width * 0.04),

                            // Avatar
                            CircleAvatar(
                              radius: avatarRadius,
                              backgroundColor: Colors.white,
                              backgroundImage: const AssetImage(
                                "assets/image/profil_image.png",
                              ),
                            ),
                            SizedBox(height: width * 0.03),

                            // Name
                            Text(
                              "AHAS CENGKARENG",
                              style: GoogleFonts.poppins(
                                color: Colors.white,
                                fontSize: nameFontSize,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            SizedBox(height: width * 0.01),

                            // Username
                            Text(
                              "@AHAS_Cengkareng01",
                              style: GoogleFonts.poppins(
                                color: Colors.white70,
                                fontSize: usernameFontSize,
                              ),
                            ),
                            SizedBox(height: width * 0.03),

                            // Role Badge
                            Container(
                              padding: EdgeInsets.symmetric(
                                horizontal: width * 0.04,
                                vertical: width * 0.015,
                              ),
                              decoration: BoxDecoration(
                                color: Colors.white.withOpacity(0.20),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Text(
                                "Admin Bengkel",
                                style: GoogleFonts.poppins(
                                  color: Colors.white,
                                  fontSize: roleFontSize,
                                ),
                              ),
                            ),
                            SizedBox(height: width * 0.03),

                            // Edit button
                            ElevatedButton(
                              onPressed: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                      builder: (_) => const EditProfilePage()),
                                );
                              },
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.amber,
                                foregroundColor: Colors.black,
                                padding: EdgeInsets.symmetric(
                                  horizontal: width * 0.1,
                                  vertical: width * 0.018,
                                ),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(24),
                                ),
                              ),
                              child: Text(
                                "Edit",
                                style: GoogleFonts.poppins(
                                  fontSize: editFontSize,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),

                SizedBox(height: width * 0.06),

                // ====== CARD MENU ======
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: width * 0.04),
                  child: Card(
                    color: Colors.white,
                    elevation: 5,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(width * 0.04),
                    ),
                    child: Column(
                      children: [
                        _ProfileItem(
                          iconPath: "assets/icons/bahasa.svg",
                          title: "Bahasa",
                          iconSize: itemIconSize,
                          fontSize: itemFontSize,
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (_) => const UbahBahasaPage()),
                            );
                          },
                        ),
                        const Divider(height: 1),
                        _ProfileItem(
                          iconPath: "assets/icons/help.svg",
                          title: "Bantuan & Dukungan",
                          iconSize: itemIconSize,
                          fontSize: itemFontSize,
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (_) => const HelpSupportPage()),
                            );
                          },
                        ),
                        const Divider(height: 1),
                        _ProfileItem(
                          iconPath: "assets/icons/password.svg",
                          title: "Ganti Password",
                          iconSize: itemIconSize,
                          fontSize: itemFontSize,
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (_) => const ChangePasswordPage()),
                            );
                          },
                        ),
                        const Divider(height: 1),
                        _ProfileItem(
                          iconPath: "assets/icons/voucher.svg",
                          title: "Voucher",
                          iconSize: itemIconSize,
                          fontSize: itemFontSize,
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (_) => const VoucherPage()),
                            );
                          },
                        ),
                        const Divider(height: 1),
                        _ProfileItem(
                          iconPath: "assets/icons/feedback.svg",
                          title: "Umpan Balik",
                          iconSize: itemIconSize,
                          fontSize: itemFontSize,
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (_) => const FeedbackPage()),
                            );
                          },
                        ),
                        const Divider(height: 1),
                        _ProfileItem(
                          iconPath: "assets/icons/logout.svg",
                          title: "Keluar",
                          iconSize: itemIconSize,
                          fontSize: itemFontSize,
                          isLogout: true,
                          onTap: () {
                            showDialog(
                              context: context,
                              builder: (context) => AlertDialog(
                                title: Text("Keluar",
                                    style: GoogleFonts.poppins()),
                                content: Text(
                                  "Apakah Anda yakin ingin keluar?",
                                  style: GoogleFonts.poppins(),
                                ),
                                actions: [
                                  TextButton(
                                    onPressed: () => Navigator.pop(context),
                                    child: Text("Batal",
                                        style: GoogleFonts.poppins()),
                                  ),
                                  TextButton(
                                    onPressed: () {
                                      Navigator.pushReplacementNamed(context, '/login');
                                    },
                                    child: Text("Ya",
                                        style: GoogleFonts.poppins()),
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
                SizedBox(height: width * 0.08),
              ],
            ),
          );
        },
      ),
    );
  }
}

// ===== ProfileItem (responsif) =====
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
    return ListTile(
      contentPadding: EdgeInsets.symmetric(
        horizontal: MediaQuery.of(context).size.width * 0.04,
      ),
      leading: _buildIcon(
        iconPath,
        size: iconSize,
        color: isLogout ? Colors.red : Colors.red,
      ),
      title: Text(
        title,
        style: GoogleFonts.poppins(
          fontSize: fontSize,
          color: isLogout ? Colors.red : Colors.black,
          fontWeight: isLogout ? FontWeight.w600 : FontWeight.normal,
        ),
      ),
      trailing: Icon(
        Icons.arrow_forward_ios,
        size: fontSize * 0.7,
        color: Colors.grey[600],
      ),
      onTap: onTap,
    );
  }

  /// ✅ Fungsi helper untuk menampilkan ikon baik .svg maupun .png
  Widget _buildIcon(String path, {Color? color, double size = 24}) {
    if (path.toLowerCase().endsWith('.svg')) {
      return SvgPicture.asset(path, width: size, height: size, color: color);
    }
    return Image.asset(path, width: size, height: size, color: color);
  }
}

// ======================= Dummy pages (tetap) =======================
class AboutPage extends StatelessWidget {
  const AboutPage({super.key});
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(title: const Text("About Us")),
        body: const Center(child: Text("Ini halaman About Us")));
  }
}

class HelpPage extends StatelessWidget {
  const HelpPage({super.key});
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(title: const Text("Help & Support")),
        body: const Center(child: Text("Ini halaman Help & Support")));
  }
}

class LoginPage extends StatelessWidget {
  const LoginPage({super.key});
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(title: const Text("Login")),
        body: const Center(child: Text("Form login di sini")));
  }
}
