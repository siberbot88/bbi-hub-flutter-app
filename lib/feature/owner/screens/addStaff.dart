import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_svg/flutter_svg.dart';

const _primary = Color(0xFFD72B1C);

class AddStaffRegisterPage extends StatefulWidget {
  const AddStaffRegisterPage({super.key});

  @override
  State<AddStaffRegisterPage> createState() => _AddStaffRegisterPageState();
}

class _AddStaffRegisterPageState extends State<AddStaffRegisterPage>
    with SingleTickerProviderStateMixin {
  // ===== controllers (pakai yang relevan) =====
  final TextEditingController fullnameController = TextEditingController();
  final TextEditingController usernameController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController workshopController = TextEditingController(); // Spesialis
  final TextEditingController decsController = TextEditingController(); // Jobdesk
  final TextEditingController npwpController = TextEditingController(); // Verifikasi password

  // sesuai struktur yang kamu minta
  final TextEditingController addressController = TextEditingController();
  final TextEditingController phoneController = TextEditingController();
  final TextEditingController urlController = TextEditingController();
  final TextEditingController nibController = TextEditingController();
  final TextEditingController wemailController = TextEditingController();

  int _currentStep = 0; // tidak dipakai, biar tetap sama dengan struktur kamu
  bool obscureText = true;

  bool _isSuccess = false;
  bool _saving = false;

  late final AnimationController _successCtrl;
  late final Animation<double> _successScale;

  @override
  void initState() {
    super.initState();
    _successCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );
    _successScale = TweenSequence<double>([
      TweenSequenceItem(
        tween:
        Tween(begin: .9, end: 1.1).chain(CurveTween(curve: Curves.easeOutBack)),
        weight: 50,
      ),
      TweenSequenceItem(
        tween: Tween(begin: 1.1, end: 1.0)
            .chain(CurveTween(curve: Curves.easeIn)),
        weight: 50,
      ),
    ]).animate(_successCtrl);
  }

  @override
  void dispose() {
    fullnameController.dispose();
    usernameController.dispose();
    passwordController.dispose();
    emailController.dispose();
    workshopController.dispose();
    decsController.dispose();
    npwpController.dispose();
    addressController.dispose();
    phoneController.dispose();
    urlController.dispose();
    nibController.dispose();
    wemailController.dispose();
    _successCtrl.dispose();
    super.dispose();
  }

  // ---------- TEXTFIELD (versi kamu) ----------
  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required String hint,
    required String iconPath,
    bool isPassword = false,
    int maxline = 1,
  }) {
    return TextField(
      controller: controller,
      obscureText: isPassword ? obscureText : false,
      maxLines: maxline,
      decoration: InputDecoration(
        labelText: label,
        labelStyle: GoogleFonts.poppins(
          color: Colors.red,
          fontSize: 14,
          fontWeight: FontWeight.w500,
        ),
        hintText: hint,
        hintStyle: GoogleFonts.poppins(color: Colors.grey),
        prefixIcon: Padding(
          padding: const EdgeInsets.all(12.0),
          child: SvgPicture.asset(iconPath, width: 20, height: 20, color: Colors.red),
        ),
        suffixIcon: isPassword
            ? IconButton(
          icon: Icon(
            obscureText ? Icons.visibility_off : Icons.visibility,
            color: const Color.fromARGB(255, 215, 43, 28),
          ),
          onPressed: () => setState(() => obscureText = !obscureText),
        )
            : null,
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(
              color: Color.fromARGB(255, 215, 43, 28), width: 1.5),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(
              color: Color.fromARGB(255, 215, 43, 28), width: 2),
        ),
        filled: true,
        fillColor: const Color.fromARGB(222, 255, 255, 255).withOpacity(0.4),
        contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
      ),
      style: GoogleFonts.poppins(color: Colors.black, fontSize: 12),
    );
  }

  Future<void> _submit() async {
    FocusScope.of(context).unfocus();
    setState(() => _saving = true);

    // TODO: validasi & call API di sini
    await Future.delayed(const Duration(milliseconds: 900));

    if (!mounted) return;
    setState(() {
      _saving = false;
      _isSuccess = true;
    });
    _successCtrl
      ..reset()
      ..forward();
  }

  @override
  Widget build(BuildContext context) {
    final bottomInset = MediaQuery.of(context).viewInsets.bottom;

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Daftar Akun Staff',
          style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
      ),

      body: AnimatedSwitcher(
        duration: const Duration(milliseconds: 400),
        switchInCurve: Curves.easeOutCubic,
        switchOutCurve: Curves.easeInCubic,
        child: _isSuccess
            ? _buildSuccess()
            : SingleChildScrollView(
          key: const ValueKey('form'),
          physics: const BouncingScrollPhysics(),
          padding: EdgeInsets.fromLTRB(20, 14, 20, 20 + bottomInset),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Header kecil
              Container(
                padding: const EdgeInsets.fromLTRB(18, 16, 18, 16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(.08),
                      blurRadius: 22,
                      offset: const Offset(0, 0),
                    ),
                  ],
                ),
                child: Row(
                  children: [
                    Container(
                      width: 52,
                      height: 52,
                      decoration: BoxDecoration(
                        color: const Color(0x33D72B1C),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Icon(Icons.person, color: _primary, size: 30),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Isi Data Diri',
                              style: GoogleFonts.poppins(
                                  fontSize: 14, fontWeight: FontWeight.w600)),
                          const SizedBox(height: 4),
                          Text('Buatlah akun admin & mekanikmu…',
                              style: GoogleFonts.poppins(
                                  fontSize: 12, color: Colors.black54)),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),
              _buildTextField(
                controller: fullnameController,
                label: "Nama Lengkap",
                hint: "Masukkan nama lengkap kamu",
                iconPath: "assets/svg/user.svg",
              ),
              const SizedBox(height: 22),
              _buildTextField(
                controller: usernameController,
                label: "Username",
                hint: "Masukkan username kamu",
                iconPath: "assets/svg/user.svg",
              ),
              const SizedBox(height: 22),
              _buildTextField(
                controller: emailController,
                label: "Email",
                hint: "Masukkan email kamu",
                iconPath: "assets/svg/email.svg",
              ),
              const SizedBox(height: 22),
              _buildTextField(
                controller: passwordController,
                label: "Password",
                hint: "Masukkan password kamu",
                iconPath: "assets/svg/key.svg",
                isPassword: true,
              ),
              const SizedBox(height: 22),
              _buildTextField(
                controller: npwpController, // confirm password
                label: "Verifikasi Password",
                hint: "Verifikasi password kamu",
                iconPath: "assets/svg/key.svg",
                isPassword: true,
              ),
              const SizedBox(height: 22),
              _buildTextField(
                controller: workshopController,
                label: "Spesialis",
                hint: "Masukkan bidang spesial staff",
                iconPath: "assets/svg/bintang.svg",
              ),
              const SizedBox(height: 22),
              _buildTextField(
                controller: decsController,
                label: "Jobdesk",
                hint: "Masukkan detail jobdesk",
                iconPath: "assets/svg/laporan_tebal.svg",
                maxline: 4,
              ),
            ],
          ),
        ),
      ),

      bottomNavigationBar: SafeArea(
        minimum: const EdgeInsets.fromLTRB(24, 10, 24, 24),
        child: SizedBox(
          height: 54,
          child: ElevatedButton(
            onPressed: _saving
                ? null
                : _isSuccess
                ? () => Navigator.pop(context)
                : _submit,
            style: ElevatedButton.styleFrom(
              backgroundColor: _primary,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(32)),
              elevation: 2,
              shadowColor: _primary.withOpacity(.35),
            ),
            child: AnimatedSwitcher(
              duration: const Duration(milliseconds: 250),
              child: _saving
                  ? const SizedBox(
                key: ValueKey('prg'),
                width: 22,
                height: 22,
                child: CircularProgressIndicator(
                  strokeWidth: 2.6,
                  valueColor: AlwaysStoppedAnimation(Colors.white),
                ),
              )
                  : Text(
                _isSuccess ? 'Lanjutkan' : 'Simpan',
                key: ValueKey(_isSuccess ? 'lanjut' : 'simpan'),
                style: GoogleFonts.poppins(
                    color: Colors.white, fontWeight: FontWeight.w700, fontSize: 16),
              ),
            ),
          ),
        ),
      ),
    );
  }

  // ---------- SUCCESS (mirip owner, tanpa progress bar) ----------
  Widget _buildSuccess() {
    return SingleChildScrollView(
      key: const ValueKey('success'),
      physics: const BouncingScrollPhysics(),
      child: Column(
        children: [
          const SizedBox(height: 160),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Text(
              "Selamat, Staff Anda telah resmi terdaftar di aplikasi.",
              textAlign: TextAlign.center,
              style: GoogleFonts.poppins(
                fontSize: 16,
                fontWeight: FontWeight.w700,
                color: const Color(0xFF232323),
              ),
            ),
          ),
          const SizedBox(height: 20),
          SizedBox(
            height: 300,
            width: double.infinity,
            child: Stack(
              alignment: Alignment.center,
              children: [
                // blob merah di belakang
                Positioned.fill(
                  child: SvgPicture.asset(
                    'assets/svg/bg-successreg.svg',
                    fit: BoxFit.fitWidth,
                  ),
                ),
                // gambar tengah + bounce
                AnimatedBuilder(
                  animation: _successScale,
                  builder: (context, child) {
                    return Transform.scale(
                      scale: _successScale.value,
                      child: child,
                    );
                  },
                  child: Image.asset(
                    'assets/image/succes-car.png', // ganti sesuai asetmu
                    height: 250,
                    fit: BoxFit.contain,
                    // fallback jika aset belum ada
                    errorBuilder: (_, __, ___) => Container(
                      width: 160,
                      height: 160,
                      decoration: BoxDecoration(
                        color: Colors.green.shade50,
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(Icons.verified_rounded,
                          color: Colors.green, size: 96),
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 28),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Text(
              "Mulailah memantau karyawan anda untuk tetap aktif dan melayani pelanggan.",
              textAlign: TextAlign.center,
              style: GoogleFonts.poppins(
                fontSize: 14,
                color: Colors.black54,
              ),
            ),
          ),
          const SizedBox(height: 8),
        ],
      ),
    );
  }
}
