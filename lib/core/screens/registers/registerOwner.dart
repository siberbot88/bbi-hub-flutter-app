import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_svg/flutter_svg.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Register Multi Step',
      theme: ThemeData(
        primaryColor: const Color(0xFFD72B1C),
        scaffoldBackgroundColor: Colors.grey.shade100,
        fontFamily: 'Poppins',
      ),
      home: const RegisterFlowPage(),
      debugShowCheckedModeBanner: false,
    );
  }
}

class RegisterFlowPage extends StatefulWidget {
  const RegisterFlowPage({super.key});
  @override
  State<RegisterFlowPage> createState() => _RegisterFlowPageState();
}

class _RegisterFlowPageState extends State<RegisterFlowPage>
    with TickerProviderStateMixin {
  final PageController _pageController = PageController();

  late AnimationController _successAnimController;
  late Animation<double> _successScaleAnim;

  final TextEditingController fullnameController = TextEditingController();
  final TextEditingController usernameController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController workshopController = TextEditingController();
  final TextEditingController addressController = TextEditingController();
  final TextEditingController phoneController = TextEditingController();
  final TextEditingController urlController = TextEditingController();
  final TextEditingController decsController = TextEditingController();
  final TextEditingController nibController = TextEditingController();
  final TextEditingController npwpController = TextEditingController();
  final TextEditingController wemailController = TextEditingController();

  int _currentStep = 0;
  bool obscureText = true;

  @override
  void initState() {
    super.initState();
    _successAnimController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );
    _successScaleAnim = TweenSequence<double>([
      TweenSequenceItem(
        tween: Tween(begin: 0.9, end: 1.1)
            .chain(CurveTween(curve: Curves.easeOutBack)),
        weight: 50,
      ),
      TweenSequenceItem(
        tween:
        Tween(begin: 1.1, end: 1.0).chain(CurveTween(curve: Curves.easeIn)),
        weight: 50,
      ),
    ]).animate(_successAnimController);
  }

  void _goStep(int step) {
    if (step < 0 || step > 3) return;
    setState(() => _currentStep = step);
    _pageController.animateToPage(
      step,
      duration: const Duration(milliseconds: 500),
      curve: Curves.easeInOutCubicEmphasized,
    );
    if (step == 3) {
      _successAnimController
        ..reset()
        ..forward();
    }
  }

  void _onNext() => _goStep(_currentStep + 1);
  void _onBack() => _goStep(_currentStep - 1);

  @override
  void dispose() {
    _pageController.dispose();
    _successAnimController.dispose();
    super.dispose();
  }

  // ---------- PROGRESS ----------
  Widget _buildProgressBar(double width) {
    double segment = width / 3;
    return SizedBox(
      height: 50,
      child: Stack(
        children: [
          Positioned(
            top: 20,
            left: segment / 2,
            right: segment / 2,
            child: Container(height: 2, color: Colors.red.withOpacity(0.3)),
          ),
          Positioned(
            top: 20,
            left: segment / 2,
            width: segment * (_currentStep.clamp(0, 2)),
            child: Container(height: 2, color: Colors.red),
          ),
          for (int i = 0; i < 3; i++)
            Positioned(
              left: segment * i + (segment / 2) - 12,
              top: 8,
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 300),
                width: 24,
                height: 24,
                decoration: BoxDecoration(
                  color: (i <= _currentStep) ? Colors.red : Colors.white,
                  border: Border.all(color: Colors.red),
                  shape: BoxShape.circle,
                ),
                child: Center(
                  child: (i < _currentStep)
                      ? const Icon(Icons.check, size: 16, color: Colors.white)
                      : const SizedBox.shrink(),
                ),
              ),
            ),
          for (int i = 0; i < 3; i++)
            Positioned(
              left: segment * i,
              top: 34,
              width: segment,
              child: Center(
                child: Text(
                  ['Data diri', 'Data bengkel', 'Dokumen'][i],
                  style: TextStyle(
                    fontSize: 12,
                    color: (i == _currentStep) ? Colors.red : Colors.grey,
                    fontWeight:
                    (i == _currentStep) ? FontWeight.bold : FontWeight.normal,
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }

  // ---------- TEXTFIELD (tetap sesuai modifikasi kamu) ----------
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
          onPressed: () {
            setState(() {
              obscureText = !obscureText;
            });
          },
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
      ),
      style: GoogleFonts.poppins(color: Colors.black, fontSize: 12),
    );
  }

  // ---------- CARD ----------
  Widget _buildFormCard({required Widget child, required double cardWidth}) {
    return Container(
      width: cardWidth,
      margin: const EdgeInsets.symmetric(vertical: 16),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            offset: const Offset(0, 0),
            blurRadius: 22,
          ),
        ],
      ),
      child: child,
    );
  }

  // ---------- WRAPPER anti-OVERFLOW (scrollable, nempel atas) ----------
  Widget _scrollableStep(Widget child) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final kb = MediaQuery.of(context).viewInsets.bottom;
        return SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          padding: EdgeInsets.only(
            bottom:
            16 + kb, // konten bisa naik saat keyboard muncul, tombol tetap 36
          ),
          child: ConstrainedBox(
            constraints: BoxConstraints(minHeight: constraints.maxHeight),
            child: Align(alignment: Alignment.topCenter, child: child),
          ),
        );
      },
    );
  }

  // ---------- STEP SELECTOR ----------
  Widget _buildStepByIndex(int index, double cardWidth) {
    switch (index) {
      case 0:
        return _buildStep0(cardWidth);
      case 1:
        return _buildStep1(cardWidth);
      case 2:
        return _buildStep2(cardWidth);
      case 3:
        return _buildStep3(cardWidth);
      default:
        return const SizedBox.shrink();
    }
  }

  // ---------- STEP 0 ----------
  Widget _buildStep0(double cardWidth) {
    final content = _buildFormCard(
      cardWidth: cardWidth,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(24, 24, 24, 16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              children: [
                Container(
                  width: 41,
                  height: 41,
                  decoration: BoxDecoration(
                    color: const Color.fromRGBO(220, 38, 38, 0.21),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Icon(Icons.person, color: Colors.red, size: 28),
                ),
                const SizedBox(width: 14),
                const Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text("Isi Data Diri",
                          style: TextStyle(fontSize: 14, color: Colors.black)),
                      SizedBox(height: 4),
                      Text("Buatlah akun pertamamu...",
                          style:
                          TextStyle(fontSize: 12, color: Colors.black54)),
                    ],
                  ),
                ),
              ],
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
              hint: "Masukkan password",
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
              controller: passwordController,
              label: "Verifikasi Password",
              hint: "verifikasi password kamu",
              iconPath: "assets/svg/key.svg",
              isPassword: true,
            ),
          ],
        ),
      ),
    );
    return _scrollableStep(content);
  }

  // ---------- STEP 1 ----------
  Widget _buildStep1(double cardWidth) {
    final content = _buildFormCard(
      cardWidth: cardWidth,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(24, 24, 24, 16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              children: [
                Container(
                  width: 41,
                  height: 41,
                  decoration: BoxDecoration(
                    color: const Color.fromRGBO(220, 38, 38, 0.21),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Icon(Icons.store, color: Colors.red, size: 28),
                ),
                const SizedBox(width: 14),
                const Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text("Isi Data Bengkel",
                          style: TextStyle(fontSize: 14, color: Colors.black)),
                      SizedBox(height: 4),
                      Text("Daftarkan bengkelmu sekarang...",
                          style:
                          TextStyle(fontSize: 12, color: Colors.black54)),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),
            _buildTextField(
              controller: workshopController,
              label: "Nama bengkel",
              hint: "Masukkan Nama bengkel",
              iconPath: "assets/svg/workshop.svg",
            ),
            const SizedBox(height: 22),
            _buildTextField(
              controller: addressController,
              label: "Alamat",
              hint: "Masukkan alamat bengkel ",
              iconPath: "assets/svg/address.svg",
            ),
            const SizedBox(height: 22),
            _buildTextField(
              controller: phoneController,
              label: "Telepon",
              hint: "Masukkan nomor telepon",
              iconPath: "assets/svg/phone.svg",
            ),
            const SizedBox(height: 22),
            _buildTextField(
              controller: wemailController,
              label: "Email Kantor",
              hint: "Masukkan email kantor",
              iconPath: "assets/svg/email.svg",
            ),
            const SizedBox(height: 22),
            _buildTextField(
              controller: urlController,
              label: "Maps Url",
              hint: "Masukkan Url maps bengkel",
              iconPath: "assets/svg/url.svg",
            ),
            const SizedBox(height: 22),
            _buildTextField(
              controller: decsController,
              label: "Deskripsi",
              hint: "Masukkan deskripsi bengkel",
              iconPath: "assets/svg/laporan_tebal.svg",
              maxline: 3,
            ),
          ],
        ),
      ),
    );
    return _scrollableStep(content);
  }

  // ---------- STEP 2 ----------
  Widget _buildStep2(double cardWidth) {
    final content = _buildFormCard(
      cardWidth: cardWidth,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(24, 24, 24, 16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              children: [
                Container(
                  width: 41,
                  height: 41,
                  decoration: BoxDecoration(
                    color: const Color.fromRGBO(220, 38, 38, 0.21),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Icon(Icons.badge, color: Colors.red, size: 28),
                ),
                const SizedBox(width: 14),
                const Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text("Dokumen Pendukung",
                          style: TextStyle(fontSize: 14, color: Colors.black)),
                      SizedBox(height: 4),
                      Text("Lengkapi Dokumen anda...",
                          style:
                          TextStyle(fontSize: 12, color: Colors.black54)),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),
            _buildTextField(
              controller: nibController,
              label: "NIB",
              hint: "Nomor induk berusaha",
              iconPath: "assets/svg/nib.svg",
            ),
            const SizedBox(height: 22),
            _buildTextField(
              controller: npwpController,
              label: "NPWP",
              hint: "Masukkan NPWP bengkel",
              iconPath: "assets/svg/npwp.svg",
              maxline: 3,
            ),
            const SizedBox(height: 16),
            GestureDetector(
              onTap: () {},
              child: Container(
                height: 150,
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.red),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.cloud_upload, size: 36, color: Colors.grey),
                      SizedBox(height: 8),
                      Text(
                        "Click to upload or drag & drop\nPNG, JPG up to 10MB",
                        textAlign: TextAlign.center,
                        style: TextStyle(color: Colors.grey),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            const SizedBox(height: 16),
            const Text(
              "1. Dokumen dienkripsi dan disimpan dengan standar keamanan tinggi.\n"
                  "2. Hanya tim verifikasi yang dapat mengakses dokumen.\n"
                  "3. Dokumen akan otomatis dihapus setelah verifikasi selesai.",
              style: TextStyle(fontSize: 10, color: Colors.grey),
              textAlign: TextAlign.justify,
            ),
          ],
        ),
      ),
    );
    return _scrollableStep(content);
  }

  // ---------- STEP 3 (Success + bounce) ----------
  Widget _buildStep3(double cardWidth) {
    final content = SizedBox(
      width: double.infinity,
      child: Stack(
        children: [
          // Blob latar menyatu ke tepi
          Positioned.fill(
            child: SvgPicture.asset(
              'assets/svg/bg-successreg.svg',
              fit: BoxFit.fitWidth,
            ),
          ),
          Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Text(
                  "Selamat, bengkel Anda telah resmi terdaftar di aplikasi.",
                  textAlign: TextAlign.center,
                  style: GoogleFonts.poppins(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    color: const Color(0xFF232323),
                  ),
                ),
              ),
              const SizedBox(height: 20),
              AnimatedBuilder(
                animation: _successScaleAnim,
                builder: (context, child) {
                  return Transform.scale(
                    scale: _successScaleAnim.value,
                    child: child,
                  );
                },
                child: SizedBox(
                  height: 300,
                  width: double.infinity,
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      Positioned.fill(
                        child: SvgPicture.asset(
                          'assets/svg/bg-successreg.svg',
                          fit: BoxFit.cover,
                        ),
                      ),
                      Positioned(
                        bottom: 0,
                        child: Image.asset(
                          'assets/image/succes-car.png',
                          height: 290,
                          fit: BoxFit.contain,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 28),
              AnimatedOpacity(
                opacity: 1.0,
                duration: const Duration(milliseconds: 800),
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  child: Text(
                    "Mulailah menambahkan layanan, harga, dan\njadwal operasional untuk menarik lebih banyak pelanggan.",
                    textAlign: TextAlign.center,
                    style: GoogleFonts.poppins(
                      fontSize: 14,
                      color: Colors.black54,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
    return _scrollableStep(content);
  }

  // ---------- BUILD ----------
  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final cardWidth = screenWidth * 0.85;

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: _currentStep > 0
            ? IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: _onBack,
        )
            : null,
        title: const Text(
          "Daftar",
          style: TextStyle(
              fontSize: 18, fontWeight: FontWeight.bold, color: Colors.black),
        ),
        centerTitle: true,
      ),
      body: Column(
        children: [
          const SizedBox(height: 8),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: _buildProgressBar(cardWidth),
          ),
          const SizedBox(height: 16),
          Expanded(
            child: PageView(
              controller: _pageController,
              physics: const NeverScrollableScrollPhysics(),
              children: [
                _buildStep0(cardWidth),
                _buildStep1(cardWidth),
                _buildStep2(cardWidth),
                _buildStep3(cardWidth),
              ],
            ),
          ),
          // Bottom button dengan padding 36 (sesuai permintaan)
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 36),
            child: SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                onPressed: () {
                  if (_currentStep < 3) {
                    _onNext();
                  } else {
                    Navigator.pushNamedAndRemoveUntil(
                      context,
                      '/main',
                          (route) => false,
                    );
                  }
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(32),
                  ),
                ),
                child: Text(
                  _currentStep < 3 ? 'Next' : 'Selesai',
                  style: const TextStyle(
                      fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
