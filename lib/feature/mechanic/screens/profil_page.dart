import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:bengkel_online_flutter/feature/mechanic/widgets/smartasset.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'dart:math' as math;

class ProfilePage extends StatelessWidget {
  const ProfilePage({super.key});

  @override
  Widget build(BuildContext context) {
    final dummyUser = {
      "name": "Ahmad Rizki",
      "username": "@ahmadrizki",
      "role":
          "Mekanik Bengkel", // nanti bisa berubah: Admin Bengkel, Customer, dll
      "avatar": "assets/image/mekanik.png",
    };

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

          const primaryInner = Color(0xFFDC2626);
          const primaryOuter = Color(0xFF000000);

          return SingleChildScrollView(
            child: Column(
              children: [
                // ====== Header gradient ======
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
                              backgroundImage: AssetImage(dummyUser["avatar"]!),
                            ),
                            SizedBox(height: width * 0.03),

                            // Name
                            Text(
                              dummyUser["name"]!,
                              style: GoogleFonts.poppins(
                                color: Colors.white,
                                fontSize: nameFontSize,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            SizedBox(height: width * 0.01),

                            // Username
                            Text(
                              dummyUser["username"]!,
                              style: GoogleFonts.poppins(
                                color: Colors.white70,
                                fontSize: usernameFontSize,
                              ),
                            ),
                            SizedBox(height: width * 0.03),

                            // Role badge
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
                                dummyUser["role"]!,
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
                                // nanti bisa dihubungkan ke halaman edit profil
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

                // ====== Menu Card ======
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: width * 0.04),
                  child: Card(
                    elevation: 5,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(width * 0.04),
                    ),
                    child: Column(
                      children: [
                        _ProfileItem(
                          iconPath: "assets/icons/bahasa.svg",
                          title: "Bahasa",
                          onTap: () => Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (_) => const AboutPage()),
                          ),
                        ),
                        const Divider(height: 1),
                        _ProfileItem(
                          iconPath: "assets/icons/help.png",
                          title: "Bantuan & Dukungan",
                          onTap: () => Navigator.push(
                            context,
                            MaterialPageRoute(builder: (_) => const HelpPage()),
                          ),
                        ),
                        const Divider(height: 1),
                        _ProfileItem(
                          iconPath: "assets/icons/changepassword.svg",
                          title: "Ubah Sandi",
                          onTap: () => Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (_) => const ChangePasswordPage()),
                          ),
                        ),
                        const Divider(height: 1),
                        _ProfileItem(
                          iconPath: "assets/icons/feandrate.svg",
                          title: "Penilaian dan Umpan Balik",
                          onTap: () => Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (_) => const FeedbackProfile()),
                          ),
                        ),
                        const Divider(height: 1),
                        _ProfileItem(
                          iconPath: "assets/icons/logout.png",
                          title: "Keluar",
                          isLogout: true,
                          onTap: () => _showLogoutDialog(context),
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

  void _showLogoutDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text("Logout", style: GoogleFonts.poppins()),
        content: Text(
          "Apakah Anda yakin ingin keluar?",
          style: GoogleFonts.poppins(),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text("Batal", style: GoogleFonts.poppins()),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (_) => const LoginPage()),
              );
            },
            child: Text("Ya", style: GoogleFonts.poppins()),
          ),
        ],
      ),
    );
  }
}

// ===== Reusable Profile Item =====
class _ProfileItem extends StatelessWidget {
  final String iconPath;
  final String title;
  final bool isLogout;
  final VoidCallback? onTap;

  const _ProfileItem({
    required this.iconPath,
    required this.title,
    this.isLogout = false,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    final iconSize = (width * 0.07).clamp(20.0, 36.0);
    final fontSize = (width * 0.045).clamp(14.0, 18.0);

    return ListTile(
      contentPadding: EdgeInsets.symmetric(horizontal: width * 0.04),
      leading: Image.asset(
        iconPath,
        width: iconSize,
        height: iconSize,
        fit: BoxFit.contain,
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
      trailing: Icon(Icons.arrow_forward_ios,
          size: fontSize * 0.7, color: Colors.grey[600]),
      onTap: onTap,
    );
  }
}

// ===== Dummy pages tetap (bisa kamu ganti nanti) =====
class AboutPage extends StatelessWidget {
  const AboutPage({super.key});
  @override
  Widget build(BuildContext context) => Scaffold(
      appBar: AppBar(title: const Text("Bahasa")),
      body: const Center(child: Text("Halaman Bahasa")));
}

class HelpPage extends StatelessWidget {
  const HelpPage({super.key});
  @override
  Widget build(BuildContext context) => Scaffold(
      appBar: AppBar(title: const Text("Bantuan")),
      body: const Center(child: Text("Halaman Bantuan & Dukungan")));
}

class ChangePasswordPage extends StatelessWidget {
  const ChangePasswordPage({super.key});
  @override
  Widget build(BuildContext context) => Scaffold(
      appBar: AppBar(title: const Text("Ubah Sandi")),
      body: const Center(child: Text("Form Ubah Sandi")));
}

class FeedbackProfile extends StatelessWidget {
  const FeedbackProfile({super.key});
  @override
  Widget build(BuildContext context) => Scaffold(
      appBar: AppBar(title: const Text("Umpan Balik")),
      body: const Center(child: Text("Halama Umpan Balik")));
}

class LoginPage extends StatelessWidget {
  const LoginPage({super.key});
  @override
  Widget build(BuildContext context) => Scaffold(
      appBar: AppBar(title: const Text("Login")),
      body: const Center(child: Text("Form Login di sini")));
}
