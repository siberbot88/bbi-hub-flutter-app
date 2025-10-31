import 'package:bengkel_online_flutter/core/services/api_service.dart';
import 'package:bengkel_online_flutter/core/services/auth_provider.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:provider/provider.dart';
import 'dart:math' as math;

void main() {
  runApp(
    ChangeNotifierProvider(
      create: (context) => AuthProvider(),
      child: const MyApp(),
    ),
  );
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
        textSelectionTheme: const TextSelectionThemeData(cursorColor: Colors.red),
      ),
      home: const RegisterFlowPage(),
      debugShowCheckedModeBanner: false,
      routes: {
        '/login': (context) => const Scaffold(body: Center(child: Text('Halaman Login'))),
        // Pastikan /main sudah didefinisikan di app utama kamu
      },
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
  final ApiService _apiService = ApiService();
  bool _isLoading = false;
  String? _createdWorkshopId;

  final PageController _pageController = PageController();

  late AnimationController _successAnimController;
  late Animation<double> _successScaleAnim;

  final List<GlobalKey<FormState>> _formKeys = [
    GlobalKey<FormState>(), // step 0
    GlobalKey<FormState>(), // step 1
    GlobalKey<FormState>(), // step 2
  ];

  // controllers
  final TextEditingController fullnameController = TextEditingController();
  final TextEditingController usernameController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final TextEditingController confirmPasswordController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController workshopController = TextEditingController();
  final TextEditingController addressController = TextEditingController();
  final TextEditingController phoneController = TextEditingController();
  final TextEditingController urlController = TextEditingController();
  final TextEditingController decsController = TextEditingController();
  final TextEditingController nibController = TextEditingController();
  final TextEditingController npwpController = TextEditingController();
  final TextEditingController wemailController = TextEditingController();
  final TextEditingController cityController = TextEditingController();
  final TextEditingController provinceController = TextEditingController();
  final TextEditingController postalCodeController = TextEditingController();
  final TextEditingController latitudeController = TextEditingController();
  final TextEditingController longitudeController = TextEditingController();
  final TextEditingController openingTimeController = TextEditingController();
  final TextEditingController closingTimeController = TextEditingController();
  final TextEditingController operationalDaysController = TextEditingController();

  int _currentStep = 0;
  bool _step0IsValid = false;
  bool _step1IsValid = false;
  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;

  @override
  void initState() {
    super.initState();
    _successAnimController = AnimationController(vsync: this, duration: const Duration(milliseconds: 800));
    _successScaleAnim = TweenSequence<double>([
      TweenSequenceItem(tween: Tween(begin: 0.9, end: 1.1).chain(CurveTween(curve: Curves.easeOutBack)), weight: 50),
      TweenSequenceItem(tween: Tween(begin: 1.1, end: 1.0).chain(CurveTween(curve: Curves.easeIn)), weight: 50),
    ]).animate(_successAnimController);
  }

  void _goStep(int step) {
    if (_isLoading || step < 0 || step > 3) return;
    FocusScope.of(context).unfocus();
    setState(() => _currentStep = step);
    _pageController.animateToPage(step, duration: const Duration(milliseconds: 500), curve: Curves.easeInOutCubicEmphasized);
    if (step == 3) {
      _successAnimController
        ..reset()
        ..forward();
    }
  }

  void _onNext() {
    if (_formKeys[_currentStep].currentState?.validate() ?? false) {
      if (_currentStep == 0) _step0IsValid = true;
      if (_currentStep == 1) _step1IsValid = true;
      _goStep(_currentStep + 1);
    }
  }

  @override
  void dispose() {
    _pageController.dispose();
    _successAnimController.dispose();
    fullnameController.dispose();
    usernameController.dispose();
    passwordController.dispose();
    confirmPasswordController.dispose();
    emailController.dispose();
    workshopController.dispose();
    addressController.dispose();
    phoneController.dispose();
    urlController.dispose();
    decsController.dispose();
    nibController.dispose();
    npwpController.dispose();
    wemailController.dispose();
    cityController.dispose();
    provinceController.dispose();
    postalCodeController.dispose();
    latitudeController.dispose();
    longitudeController.dispose();
    openingTimeController.dispose();
    closingTimeController.dispose();
    operationalDaysController.dispose();
    super.dispose();
  }

  Future<void> _handleRegister() async {
    FocusScope.of(context).unfocus();

    if (!(_formKeys[2].currentState?.validate() ?? false)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Harap lengkapi data dokumen.'), backgroundColor: Colors.orange),
      );
      return;
    }

    if (passwordController.text != confirmPasswordController.text) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Password dan konfirmasi tidak cocok!'), backgroundColor: Colors.red),
      );
      _goStep(0);
      return;
    }

    setState(() => _isLoading = true);
    final authProvider = Provider.of<AuthProvider>(context, listen: false);

    try {
      final ok = await authProvider.register(
        name: fullnameController.text.trim(),
        username: usernameController.text.trim(),
        email: emailController.text.trim(),
        password: passwordController.text,
        passwordConfirmation: confirmPasswordController.text,
      );
      if (!ok) throw Exception(authProvider.authError ?? 'Registrasi user gagal');

      final workshop = await _apiService.createWorkshop(
        name: workshopController.text.trim(),
        description: decsController.text.trim(),
        address: addressController.text.trim(),
        phone: phoneController.text.trim(),
        email: wemailController.text.trim(),
        mapsUrl: urlController.text.trim(),
        city: cityController.text.trim(),
        province: provinceController.text.trim(),
        country: "Indonesia",
        postalCode: postalCodeController.text.trim(),
        latitude: double.tryParse(latitudeController.text.trim().replaceAll(',', '.')) ?? 0.0,
        longitude: double.tryParse(longitudeController.text.trim().replaceAll(',', '.')) ?? 0.0,
        openingTime: openingTimeController.text.trim(),
        closingTime: closingTimeController.text.trim(),
        operationalDays: operationalDaysController.text.trim(),
      );

      _createdWorkshopId = workshop.id;

      await _apiService.createDocument(
        workshopUuid: _createdWorkshopId!,
        nib: nibController.text.trim(),
        npwp: npwpController.text.trim(),
      );

      // refresh profil agar workshop tampil di AuthProvider.user
      await authProvider.checkLoginStatus();

      setState(() => _isLoading = false);
      _goStep(3);
    } catch (e) {
      setState(() => _isLoading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: ${e.toString().replaceFirst("Exception: ", "")}'), backgroundColor: Colors.red),
      );
      if (!authProvider.isLoggedIn) {
        _goStep(0);
      } else if (_createdWorkshopId == null) {
        _goStep(1);
      }
    }
  }

  String? _validateNotEmpty(String? v, String name) => (v == null || v.trim().isEmpty) ? '$name tidak boleh kosong.' : null;
  String? _validateEmail(String? v) {
    if (v == null || v.trim().isEmpty) return 'Email tidak boleh kosong.';
    final r = RegExp(r'^[^@]+@[^@]+\.[^@]+');
    return r.hasMatch(v.trim()) ? null : 'Format email tidak valid.';
  }
  String? _validateEmailOptional(String? v) {
    if (v == null || v.trim().isEmpty) return null;
    final r = RegExp(r'^[^@]+@[^@]+\.[^@]+');
    return r.hasMatch(v.trim()) ? null : 'Format email tidak valid.';
  }
  String? _validatePassword(String? v) {
    if (v == null || v.isEmpty) return 'Password tidak boleh kosong.';
    if (v.length < 8) return 'Password minimal 8 karakter.';
    return null;
  }
  String? _validateConfirmPassword(String? v) {
    if (v == null || v.isEmpty) return 'Verifikasi password tidak boleh kosong.';
    if (v != passwordController.text) return 'Password tidak cocok.';
    return null;
  }
  String? _validateTimeFormat(String? v, String name) {
    if (v == null || v.trim().isEmpty) return '$name tidak boleh kosong.';
    final r = RegExp(r'^\d{2}:\d{2}$');
    return r.hasMatch(v.trim()) ? null : 'Format $name harus HH:MM (08:00).';
  }
  String? _validateNumber(String? v, String name) {
    if (v == null || v.trim().isEmpty) return '$name tidak boleh kosong.';
    return double.tryParse(v.trim().replaceAll(',', '.')) == null ? '$name harus berupa angka.' : null;
  }
  String? _validateUrl(String? v, String name) {
    if (v == null || v.trim().isEmpty) return '$name tidak boleh kosong.';
    final s = v.trim().toLowerCase();
    return (s.startsWith('http://') || s.startsWith('https://')) ? null : 'Format $name tidak valid (http/https).';
  }
  String? _validateOptional(String? v, String name) => null;

  Widget _buildProgressBar(double width) {
    final segment = width / 3;
    return SizedBox(
      height: 50,
      child: Stack(
        children: [
          Positioned(top: 20, left: segment / 2, right: segment / 2, child: Container(height: 2, color: Colors.red.withOpacity(0.3))),
          Positioned(
            top: 20,
            left: segment / 2,
            width: segment * math.min(_currentStep, 2.0),
            child: AnimatedContainer(duration: const Duration(milliseconds: 500), curve: Curves.easeInOut, height: 2, color: Colors.red),
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
                  border: Border.all(color: (i <= _currentStep) ? Colors.red : Colors.red.withOpacity(0.5)),
                  shape: BoxShape.circle,
                ),
                child: Center(
                  child: AnimatedSwitcher(
                    duration: const Duration(milliseconds: 200),
                    child: (i < _currentStep)
                        ? const Icon(Icons.check, size: 16, color: Colors.white, key: ValueKey('check'))
                        : const SizedBox.shrink(key: ValueKey('empty')),
                  ),
                ),
              ),
            ),
          for (int i = 0; i < 3; i++)
            Positioned(
              left: segment * i,
              top: 34,
              width: segment,
              child: Center(
                child: AnimatedDefaultTextStyle(
                  duration: const Duration(milliseconds: 300),
                  style: TextStyle(
                    fontSize: 12,
                    fontFamily: 'Poppins',
                    color: (i == _currentStep) ? Colors.red : Colors.grey,
                    fontWeight: (i == _currentStep) ? FontWeight.bold : FontWeight.normal,
                  ),
                  child: Text(['Data diri', 'Data bengkel', 'Dokumen'][i]),
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required String hint,
    required String iconPath,
    bool isPassword = false,
    int maxline = 1,
    TextInputType keyboardType = TextInputType.text,
    TextCapitalization textCapitalization = TextCapitalization.none,
    bool? obscureState,
    VoidCallback? onToggleObscure,
    FormFieldValidator<String>? validator,
  }) {
    return TextFormField(
      controller: controller,
      maxLines: maxline,
      obscureText: isPassword ? (obscureState ?? true) : false,
      keyboardType: keyboardType,
      textCapitalization: textCapitalization,
      validator: validator,
      autovalidateMode: AutovalidateMode.onUserInteraction,
      decoration: InputDecoration(
        labelText: label,
        labelStyle: GoogleFonts.poppins(color: Colors.red, fontSize: 14, fontWeight: FontWeight.w500),
        hintText: hint,
        hintStyle: GoogleFonts.poppins(color: Colors.grey),
        prefixIcon: Padding(
          padding: const EdgeInsets.all(12.0),
          child: SvgPicture.asset(iconPath, width: 20, height: 20, color: Colors.red),
        ),
        suffixIcon: isPassword
            ? IconButton(
          icon: Icon((obscureState ?? true) ? Icons.visibility_off : Icons.visibility, color: const Color(0xFFD72B1C)),
          onPressed: onToggleObscure,
        )
            : null,
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Color(0xFFD72B1C), width: 1.5),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Color(0xFFD72B1C), width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Colors.orange, width: 1.5),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Colors.orange, width: 2),
        ),
        errorStyle: const TextStyle(fontSize: 10, color: Colors.orange),
        filled: true,
        fillColor: const Color(0x66FFFFFF),
      ),
      style: GoogleFonts.poppins(color: Colors.black, fontSize: 12),
    );
  }

  Widget _buildFormCard({required Widget child, required double cardWidth}) {
    return Container(
      width: cardWidth,
      margin: const EdgeInsets.symmetric(vertical: 16),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        color: Colors.white,
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.08), offset: const Offset(0, 0), blurRadius: 22)],
      ),
      child: child,
    );
  }

  Widget _scrollableStep(Widget child) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final kb = MediaQuery.of(context).viewInsets.bottom;
        return SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          padding: EdgeInsets.only(bottom: 16 + kb),
          child: ConstrainedBox(
            constraints: BoxConstraints(minHeight: constraints.maxHeight - 16 - kb),
            child: Align(alignment: Alignment.topCenter, child: child),
          ),
        );
      },
    );
  }

  Widget _buildStep0(double cardWidth) {
    final content = _buildFormCard(
      cardWidth: cardWidth,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(24, 24, 24, 16),
        child: Form(
          key: _formKeys[0],
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Row(
                children: [
                  Container(
                    width: 41,
                    height: 41,
                    decoration: BoxDecoration(color: const Color.fromRGBO(220, 38, 38, 0.21), borderRadius: BorderRadius.circular(10)),
                    child: const Icon(Icons.person, color: Colors.red, size: 28),
                  ),
                  const SizedBox(width: 14),
                  const Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text("Isi Data Diri", style: TextStyle(fontSize: 14, color: Colors.black)),
                        SizedBox(height: 4),
                        Text("Buatlah akun pertamamu...", style: TextStyle(fontSize: 12, color: Colors.black54)),
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
                textCapitalization: TextCapitalization.words,
                validator: (v) => _validateNotEmpty(v, 'Nama Lengkap'),
              ),
              const SizedBox(height: 22),
              _buildTextField(
                controller: usernameController,
                label: "Username",
                hint: "Masukkan username",
                iconPath: "assets/svg/user.svg",
                keyboardType: TextInputType.visiblePassword,
                validator: (v) => _validateNotEmpty(v, 'Username'),
              ),
              const SizedBox(height: 22),
              _buildTextField(
                controller: emailController,
                label: "Email",
                hint: "Masukkan email kamu",
                iconPath: "assets/svg/email.svg",
                keyboardType: TextInputType.emailAddress,
                validator: _validateEmail,
              ),
              const SizedBox(height: 22),
              _buildTextField(
                controller: passwordController,
                label: "Password",
                hint: "Minimal 8 karakter",
                iconPath: "assets/svg/key.svg",
                isPassword: true,
                obscureState: _obscurePassword,
                onToggleObscure: () => setState(() => _obscurePassword = !_obscurePassword),
                validator: _validatePassword,
              ),
              const SizedBox(height: 22),
              _buildTextField(
                controller: confirmPasswordController,
                label: "Verifikasi Password",
                hint: "Ulangi password kamu",
                iconPath: "assets/svg/key.svg",
                isPassword: true,
                obscureState: _obscureConfirmPassword,
                onToggleObscure: () => setState(() => _obscureConfirmPassword = !_obscureConfirmPassword),
                validator: _validateConfirmPassword,
              ),
              const SizedBox(height: 16),
            ],
          ),
        ),
      ),
    );
    return _scrollableStep(content);
  }

  Widget _buildStep1(double cardWidth) {
    final content = _buildFormCard(
      cardWidth: cardWidth,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(24, 24, 24, 16),
        child: Form(
          key: _formKeys[1],
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Row(
                children: [
                  Container(
                    width: 41,
                    height: 41,
                    decoration: BoxDecoration(color: const Color.fromRGBO(220, 38, 38, 0.21), borderRadius: BorderRadius.circular(10)),
                    child: const Icon(Icons.store, color: Colors.red, size: 28),
                  ),
                  const SizedBox(width: 14),
                  const Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text("Isi Data Bengkel", style: TextStyle(fontSize: 14, color: Colors.black)),
                        SizedBox(height: 4),
                        Text("Daftarkan bengkelmu sekarang...", style: TextStyle(fontSize: 12, color: Colors.black54)),
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
                textCapitalization: TextCapitalization.words,
                validator: (v) => _validateNotEmpty(v, 'Nama bengkel'),
              ),
              const SizedBox(height: 22),
              _buildTextField(
                controller: addressController,
                label: "Alamat Lengkap Bengkel",
                hint: "Contoh: Jl. Merdeka No. 17",
                iconPath: "assets/svg/address.svg",
                textCapitalization: TextCapitalization.sentences,
                maxline: 2,
                validator: (v) => _validateNotEmpty(v, 'Alamat'),
              ),
              const SizedBox(height: 22),
              Row(
                children: [
                  Expanded(
                    child: _buildTextField(
                      controller: cityController,
                      label: "Kota",
                      hint: "Masukkan kota",
                      iconPath: "assets/svg/address.svg",
                      textCapitalization: TextCapitalization.words,
                      validator: (v) => _validateNotEmpty(v, 'Kota'),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: _buildTextField(
                      controller: provinceController,
                      label: "Provinsi",
                      hint: "Contoh: Jawa Barat",
                      iconPath: "assets/svg/address.svg",
                      textCapitalization: TextCapitalization.words,
                      validator: (v) => _validateNotEmpty(v, 'Provinsi'),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 22),
              _buildTextField(
                controller: postalCodeController,
                label: "Kode Pos",
                hint: "Contoh: 40123",
                iconPath: "assets/svg/address.svg",
                keyboardType: TextInputType.number,
                validator: (v) => _validateNotEmpty(v, 'Kode Pos'),
              ),
              const SizedBox(height: 22),
              _buildTextField(
                controller: phoneController,
                label: "Telepon Bengkel",
                hint: "Contoh: 081234567890",
                iconPath: "assets/svg/phone.svg",
                keyboardType: TextInputType.phone,
                validator: (v) => _validateNotEmpty(v, 'Telepon'),
              ),
              const SizedBox(height: 22),
              _buildTextField(
                controller: wemailController,
                label: "Email Bengkel (Opsional)",
                hint: "Contoh: info@bengkeljaya.com",
                iconPath: "assets/svg/email.svg",
                keyboardType: TextInputType.emailAddress,
                validator: _validateEmailOptional,
              ),
              const SizedBox(height: 22),
              _buildTextField(
                controller: urlController,
                label: "URL Google Maps",
                hint: "Salin dari Google Maps",
                iconPath: "assets/svg/url.svg",
                keyboardType: TextInputType.url,
                validator: (v) => _validateUrl(v, 'URL Google Maps'),
              ),
              const SizedBox(height: 22),
              Row(
                children: [
                  Expanded(
                    child: _buildTextField(
                      controller: latitudeController,
                      label: "Latitude",
                      hint: "Contoh: -6.9175",
                      iconPath: "assets/svg/url.svg",
                      keyboardType: const TextInputType.numberWithOptions(decimal: true, signed: true),
                      validator: (v) => _validateNumber(v, 'Latitude'),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: _buildTextField(
                      controller: longitudeController,
                      label: "Longitude",
                      hint: "Contoh: 107.6191",
                      iconPath: "assets/svg/url.svg",
                      keyboardType: const TextInputType.numberWithOptions(decimal: true, signed: true),
                      validator: (v) => _validateNumber(v, 'Longitude'),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 22),
              Row(
                children: [
                  Expanded(
                    child: _buildTextField(
                      controller: openingTimeController,
                      label: "Jam Buka",
                      hint: "HH:MM (Contoh: 08:00)",
                      iconPath: "assets/svg/user.svg",
                      keyboardType: TextInputType.datetime,
                      validator: (v) => _validateTimeFormat(v, 'Jam Buka'),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: _buildTextField(
                      controller: closingTimeController,
                      label: "Jam Tutup",
                      hint: "HH:MM (Contoh: 17:00)",
                      iconPath: "assets/svg/user.svg",
                      keyboardType: TextInputType.datetime,
                      validator: (v) => _validateTimeFormat(v, 'Jam Tutup'),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 22),
              _buildTextField(
                controller: operationalDaysController,
                label: "Hari Operasional",
                hint: "Contoh: Senin - Sabtu",
                iconPath: "assets/svg/user.svg",
                textCapitalization: TextCapitalization.words,
                validator: (v) => _validateNotEmpty(v, 'Hari Operasional'),
              ),
              const SizedBox(height: 22),
              _buildTextField(
                controller: decsController,
                label: "Deskripsi Bengkel",
                hint: "Jelaskan layanan, keunggulan, dll.",
                iconPath: "assets/svg/laporan_tebal.svg",
                textCapitalization: TextCapitalization.sentences,
                maxline: 3,
                validator: (v) => _validateNotEmpty(v, 'Deskripsi Bengkel'),
              ),
              const SizedBox(height: 16),
            ],
          ),
        ),
      ),
    );
    return _scrollableStep(content);
  }

  Widget _buildStep2(double cardWidth) {
    final content = _buildFormCard(
      cardWidth: cardWidth,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(24, 24, 24, 16),
        child: Form(
          key: _formKeys[2],
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Row(
                children: [
                  Container(
                    width: 41,
                    height: 41,
                    decoration: BoxDecoration(color: const Color.fromRGBO(220, 38, 38, 0.21), borderRadius: BorderRadius.circular(10)),
                    child: const Icon(Icons.badge_outlined, color: Colors.red, size: 28),
                  ),
                  const SizedBox(width: 14),
                  const Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text("Dokumen Pendukung", style: TextStyle(fontSize: 14, color: Colors.black)),
                        SizedBox(height: 4),
                        Text("Lengkapi dokumen legalitas", style: TextStyle(fontSize: 12, color: Colors.black54)),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),
              _buildTextField(
                controller: nibController,
                label: "NIB (Nomor Induk Berusaha)",
                hint: "Masukkan NIB (Wajib)",
                iconPath: "assets/svg/nib.svg",
                keyboardType: TextInputType.number,
                validator: (v) => _validateNotEmpty(v, 'NIB'),
              ),
              const SizedBox(height: 22),
              _buildTextField(
                controller: npwpController,
                label: "NPWP (Nomor Pokok Wajib Pajak)",
                hint: "Masukkan NPWP (Opsional)",
                iconPath: "assets/svg/npwp.svg",
                keyboardType: TextInputType.text,
                maxline: 1,
                validator: (v) => _validateOptional(v, 'NPWP'),
              ),
              const SizedBox(height: 16),
              GestureDetector(
                onTap: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Fitur upload belum diimplementasikan.')),
                  );
                },
                child: Container(
                  height: 150,
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.red.withOpacity(0.5)),
                    borderRadius: BorderRadius.circular(12),
                    color: Colors.grey.shade50,
                  ),
                  child: Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.cloud_upload_outlined, size: 36, color: Colors.grey.shade600),
                        const SizedBox(height: 8),
                        Text(
                          "Upload Dokumen Legalitas (Opsional)\n(.pdf, .jpg, .png maks 10MB)",
                          textAlign: TextAlign.center,
                          style: TextStyle(color: Colors.grey.shade600, fontSize: 12),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Text(
                "Informasi Tambahan:\n"
                    "1. Dokumen Anda aman dan hanya digunakan untuk verifikasi.\n"
                    "2. Proses verifikasi dapat memakan waktu 1-2 hari kerja.",
                style: TextStyle(fontSize: 10, color: Colors.grey.shade600),
                textAlign: TextAlign.left,
              ),
              const SizedBox(height: 16),
            ],
          ),
        ),
      ),
    );
    return _scrollableStep(content);
  }

  Widget _buildStep3(double cardWidth) {
    final h = MediaQuery.of(context).size.height;
    final double imageHeight = (h * 0.35).clamp(250.0, 320.0);

    final content = SizedBox(
      width: double.infinity,
      child: Stack(
        alignment: Alignment.center,
        children: [
          Positioned.fill(
            child: SvgPicture.asset(
              'assets/svg/bg-successreg.svg',
              fit: BoxFit.cover,
              placeholderBuilder: (context) => Container(color: Colors.grey.shade200),
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 30),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  "Selamat, bengkel Anda telah resmi terdaftar di aplikasi.",
                  textAlign: TextAlign.center,
                  style: GoogleFonts.poppins(fontSize: 16, fontWeight: FontWeight.w700, color: const Color(0xFF232323)),
                ),
                const SizedBox(height: 20),
                AnimatedBuilder(
                  animation: _successScaleAnim,
                  builder: (context, child) => Transform.scale(scale: _successScaleAnim.value, child: child),
                  child: SizedBox(
                    height: imageHeight + 10,
                    width: double.infinity,
                    child: Stack(
                      alignment: Alignment.center,
                      children: [
                        Positioned.fill(
                          child: SvgPicture.asset('assets/svg/bg-successreg.svg', fit: BoxFit.cover, placeholderBuilder: (_) => const SizedBox()),
                        ),
                        Positioned(
                          bottom: 0,
                          child: Image.asset(
                            'assets/image/succes-car.png',
                            height: imageHeight,
                            fit: BoxFit.contain,
                            errorBuilder: (_, __, ___) => const Icon(Icons.check_circle_outline, size: 100, color: Colors.green),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 28),
                FadeTransition(
                  opacity: CurvedAnimation(parent: _successAnimController, curve: Curves.easeIn),
                  child: Text(
                    "Mulailah menambahkan layanan, harga, dan\njadwal operasional untuk menarik lebih banyak pelanggan.",
                    textAlign: TextAlign.center,
                    style: GoogleFonts.poppins(fontSize: 14, fontWeight: FontWeight.w700, color: Colors.black54),
                  ),
                ),
                const SizedBox(height: 20),
              ],
            ),
          ),
        ],
      ),
    );
    return _scrollableStep(content);
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final cardWidth = screenWidth * 0.85;
    const horizontalPadding = 24.0;
    const verticalPadding = 36.0;

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: _currentStep > 0 && _currentStep < 3
            ? IconButton(icon: const Icon(Icons.arrow_back, color: Colors.black), onPressed: () => _goStep(_currentStep - 1))
            : null,
        title: Text(_currentStep == 3 ? "Berhasil" : "Daftar",
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.black)),
        centerTitle: true,
      ),
      body: Column(
        children: [
          const SizedBox(height: 8),
          if (_currentStep < 3)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: horizontalPadding),
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
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: horizontalPadding, vertical: verticalPadding),
            child: SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                onPressed: _isLoading
                    ? null
                    : () {
                  if (_currentStep == 2) {
                    final step2Valid = _formKeys[2].currentState?.validate() ?? false;

                    if (!_step0IsValid) {
                      _goStep(0);
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Data diri Anda belum lengkap.'), backgroundColor: Colors.orange),
                      );
                    } else if (!_step1IsValid) {
                      _goStep(1);
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Data bengkel Anda belum lengkap.'), backgroundColor: Colors.orange),
                      );
                    } else if (!step2Valid) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Data dokumen Anda belum lengkap.'), backgroundColor: Colors.orange),
                      );
                    } else {
                      _handleRegister();
                    }
                  } else if (_currentStep == 3) {
                    Navigator.pushNamedAndRemoveUntil(context, '/main', (route) => false);
                  } else {
                    _onNext();
                  }
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red,
                  disabledBackgroundColor: Colors.red.withOpacity(0.5),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(32)),
                  elevation: _isLoading ? 0 : 2,
                ),
                child: _isLoading
                    ? const SizedBox(
                  height: 24,
                  width: 24,
                  child: CircularProgressIndicator(color: Colors.white, strokeWidth: 3),
                )
                    : Text(
                  _currentStep == 2 ? 'Daftar' : (_currentStep == 3 ? 'Selesai' : 'Next'),
                  style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white),
                ),
              ),
            ),
          )
        ],
      ),
    );
  }
}
