import 'package:bengkel_online_flutter/core/services/api_service.dart';
import 'package:bengkel_online_flutter/core/services/auth_provider.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:provider/provider.dart';
import 'dart:math' as math;

import 'widgets/register_step_one.dart';
import 'widgets/register_step_two.dart';
import 'widgets/register_step_three.dart';

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

      if (!mounted) return;
      setState(() => _isLoading = false);
      _goStep(3);
    } catch (e) {
      if (!mounted) return;
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

  Widget _buildProgressBar(double width) {
    final segment = width / 3;
    return SizedBox(
      height: 50,
      child: Stack(
        children: [
          Positioned(top: 20, left: segment / 2, right: segment / 2, child: Container(height: 2, color: Colors.red.withAlpha(77))),
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
                  border: Border.all(color: (i <= _currentStep) ? Colors.red : Colors.red.withAlpha(128)),
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

  Widget _buildStep3() {
    final h = MediaQuery.of(context).size.height;
    final double imageHeight = (h * 0.35).clamp(250.0, 320.0);

    return SizedBox(
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
                SizedBox(
                  width: double.infinity,
                  height: 50,
                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.pushReplacementNamed(context, '/login');
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFD72B1C),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      elevation: 5,
                      shadowColor: const Color(0xFFD72B1C).withAlpha(100),
                    ),
                    child: Text("Masuk Sekarang", style: GoogleFonts.poppins(fontSize: 16, fontWeight: FontWeight.w600, color: Colors.white)),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    final cardWidth = width > 600 ? 500.0 : width * 0.9;

    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            if (_currentStep < 3) ...[
              const SizedBox(height: 10),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    IconButton(
                      icon: const Icon(Icons.arrow_back, color: Colors.black),
                      onPressed: _currentStep > 0 ? () => _goStep(_currentStep - 1) : () => Navigator.pop(context),
                    ),
                    Text(
                      "Daftar Akun",
                      style: GoogleFonts.poppins(fontSize: 18, fontWeight: FontWeight.w600, color: Colors.black),
                    ),
                    const SizedBox(width: 48), // spacer
                  ],
                ),
              ),
              const SizedBox(height: 10),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24.0),
                child: _buildProgressBar(width - 48),
              ),
            ],
            Expanded(
              child: PageView(
                controller: _pageController,
                physics: const NeverScrollableScrollPhysics(),
                children: [
                  _scrollableStep(
                    SizedBox(
                      width: cardWidth,
                      child: RegisterStepOne(
                        formKey: _formKeys[0],
                        fullnameController: fullnameController,
                        usernameController: usernameController,
                        emailController: emailController,
                        passwordController: passwordController,
                        confirmPasswordController: confirmPasswordController,
                        obscurePassword: _obscurePassword,
                        obscureConfirmPassword: _obscureConfirmPassword,
                        onToggleObscurePassword: () => setState(() => _obscurePassword = !_obscurePassword),
                        onToggleObscureConfirmPassword: () => setState(() => _obscureConfirmPassword = !_obscureConfirmPassword),
                      ),
                    ),
                  ),
                  _scrollableStep(
                    SizedBox(
                      width: cardWidth,
                      child: RegisterStepTwo(
                        formKey: _formKeys[1],
                        workshopController: workshopController,
                        addressController: addressController,
                        cityController: cityController,
                        provinceController: provinceController,
                        postalCodeController: postalCodeController,
                        phoneController: phoneController,
                        wemailController: wemailController,
                        urlController: urlController,
                        latitudeController: latitudeController,
                        longitudeController: longitudeController,
                        openingTimeController: openingTimeController,
                        closingTimeController: closingTimeController,
                        operationalDaysController: operationalDaysController,
                        decsController: decsController,
                      ),
                    ),
                  ),
                  _scrollableStep(
                    SizedBox(
                      width: cardWidth,
                      child: RegisterStepThree(
                        formKey: _formKeys[2],
                        nibController: nibController,
                        npwpController: npwpController,
                      ),
                    ),
                  ),
                  _buildStep3(),
                ],
              ),
            ),
            if (_currentStep < 3)
              Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: Colors.white,
                  boxShadow: [BoxShadow(color: Colors.black.withAlpha(10), offset: const Offset(0, -4), blurRadius: 16)],
                ),
                child: SizedBox(
                  width: double.infinity,
                  height: 50,
                  child: ElevatedButton(
                    onPressed: _isLoading ? null : (_currentStep == 2 ? _handleRegister : _onNext),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFD72B1C),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      elevation: 5,
                      shadowColor: const Color(0xFFD72B1C).withAlpha(100),
                    ),
                    child: _isLoading
                        ? const SizedBox(width: 24, height: 24, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                        : Text(
                            _currentStep == 2 ? "Daftar Sekarang" : "Lanjut",
                            style: GoogleFonts.poppins(fontSize: 16, fontWeight: FontWeight.w600, color: Colors.white),
                          ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
