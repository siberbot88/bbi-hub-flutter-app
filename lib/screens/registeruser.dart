import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter/services.dart'; // penting untuk input formatter

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();

  final _usernameController = TextEditingController();
  final _emailController = TextEditingController();
  final _nikController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;

  String? _selectedRole;
  final List<String> _roles = ['AdminWorkshop', 'Technician'];

  String? _selectedWorkshop;
  final List<String> _workshops = ['Ahas', 'Yamaha Lub', 'Pulsar'];

  InputDecoration getInputDecoration(
      String label, String assetPath, String hint) {
    return InputDecoration(
      labelText: label,
      hintText: hint,
      labelStyle: GoogleFonts.poppins(
        color: Colors.red,
        fontWeight: FontWeight.w500,
      ),
      hintStyle: GoogleFonts.poppins(color: Colors.grey.shade500),
      prefixIcon: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Image.asset(assetPath, width: 20, height: 20, color: Colors.red),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(
            color: Color.fromARGB(255, 215, 43, 28), width: 1.5),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide:
            const BorderSide(color: Color.fromARGB(255, 215, 43, 28), width: 2),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: Colors.red, width: 1.5),
      ),
      focusedErrorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: Colors.red, width: 2),
      ),
      filled: true,
      fillColor: const Color.fromARGB(220, 255, 255, 255).withOpacity(0.4),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: const BoxDecoration(
          image: DecorationImage(
            image: AssetImage("assets/icons/inibg.png"),
            fit: BoxFit.cover,
          ),
        ),
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 28.0, vertical: 40),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              /// Logo
              Image.asset("assets/icons/logo.png", height: 90),
              const SizedBox(height: 20),

              /// Title
              Text(
                "Register",
                style: GoogleFonts.poppins(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: const Color.fromARGB(255, 215, 43, 28),
                ),
              ),
              const SizedBox(height: 10),
              Text(
                "Sign up to get started",
                style: GoogleFonts.poppins(
                  fontSize: 16,
                  color: Colors.black87,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 25),

              /// ===== FORM =====
              Form(
                key: _formKey,
                child: Column(
                  children: [
                    TextFormField(
                      controller: _usernameController,
                      style: GoogleFonts.poppins(),
                      decoration: getInputDecoration("Username",
                          "assets/icons/log.png", "Masukkan username"),
                      validator: (value) => value == null || value.isEmpty
                          ? 'Masukkan username'
                          : null,
                    ),
                    const SizedBox(height: 15),

                    TextFormField(
                      controller: _emailController,
                      style: GoogleFonts.poppins(),
                      decoration: getInputDecoration("Email",
                          "assets/icons/log.png", "Masukkan email aktif"),
                      validator: (value) =>
                          value == null || !value.contains('@')
                              ? 'Masukkan email valid'
                              : null,
                    ),
                    const SizedBox(height: 15),

                    /// NIK hanya angka
                    TextFormField(
                      controller: _nikController,
                      keyboardType: TextInputType.number,
                      inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                      style: GoogleFonts.poppins(),
                      decoration: getInputDecoration("NIK",
                          "assets/icons/log.png", "Masukkan NIK hanya angka"),
                      validator: (value) => value == null || value.isEmpty
                          ? 'Masukkan NIK yang valid'
                          : null,
                    ),
                    const SizedBox(height: 15),

                    DropdownButtonFormField<String>(
                      value: _selectedRole,
                      decoration: getInputDecoration(
                          "Role", "assets/icons/role.png", "Pilih role anda"),
                      style: GoogleFonts.poppins(color: Colors.black),
                      items: _roles
                          .map(
                              (w) => DropdownMenuItem(value: w, child: Text(w)))
                          .toList(),
                      onChanged: (value) =>
                          setState(() => _selectedRole = value),
                      validator: (value) => value == null ? 'Pilih Role' : null,
                    ),
                    const SizedBox(height: 15),

                    DropdownButtonFormField<String>(
                      value: _selectedWorkshop,
                      decoration: getInputDecoration("Bengkel",
                          "assets/icons/alamat.png", "Pilih bengkel anda"),
                      style: GoogleFonts.poppins(color: Colors.black),
                      items: _workshops
                          .map(
                              (w) => DropdownMenuItem(value: w, child: Text(w)))
                          .toList(),
                      onChanged: (value) =>
                          setState(() => _selectedWorkshop = value),
                      validator: (value) =>
                          value == null ? 'Pilih Workshop' : null,
                    ),
                    const SizedBox(height: 15),

                    TextFormField(
                      controller: _passwordController,
                      obscureText: _obscurePassword,
                      style: GoogleFonts.poppins(),
                      decoration: getInputDecoration("Password",
                              "assets/icons/password.png", "Masukkan password")
                          .copyWith(
                        suffixIcon: IconButton(
                          icon: Icon(
                            _obscurePassword
                                ? Icons.visibility_off
                                : Icons.visibility,
                            color: Colors.red,
                          ),
                          onPressed: () => setState(
                              () => _obscurePassword = !_obscurePassword),
                        ),
                      ),
                      validator: (value) => value == null || value.length < 6
                          ? 'Minimal 6 karakter'
                          : null,
                    ),
                    const SizedBox(height: 15),

                    TextFormField(
                      controller: _confirmPasswordController,
                      obscureText: _obscureConfirmPassword,
                      style: GoogleFonts.poppins(),
                      decoration: getInputDecoration("Confirm Password",
                              "assets/icons/password.png", "Ulangi password")
                          .copyWith(
                        suffixIcon: IconButton(
                          icon: Icon(
                            _obscureConfirmPassword
                                ? Icons.visibility_off
                                : Icons.visibility,
                            color: Colors.red,
                          ),
                          onPressed: () => setState(() =>
                              _obscureConfirmPassword =
                                  !_obscureConfirmPassword),
                        ),
                      ),
                      validator: (value) {
                        if (value != _passwordController.text) {
                          return 'Password tidak sesuai';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 25),

                    /// ===== SIGN UP BUTTON =====
                    SizedBox(
                      width: double.infinity,
                      height: 45,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor:
                              const Color.fromARGB(255, 215, 43, 28),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(28),
                          ),
                          elevation: 8,
                        ),
                        onPressed: () {
                          Navigator.pushReplacementNamed(context, "/login");
                        },
                        child: Text(
                          "SIGN UP",
                          style: GoogleFonts.poppins(
                            color: Colors.white,
                            fontSize: 16,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 30),

                    Row(
                      children: [
                        const Expanded(child: Divider()),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 8),
                          child: Text(
                            "or sign up with",
                            style: GoogleFonts.poppins(fontSize: 13),
                          ),
                        ),
                        const Expanded(child: Divider()),
                      ],
                    ),
                    const SizedBox(height: 24),

                    /// Social Buttons
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        _socialButton("assets/icons/google.png"),
                        const SizedBox(width: 20),
                        _socialButton("assets/icons/Facebook.png"),
                        const SizedBox(width: 20),
                        _socialButton("assets/icons/Apple.png"),
                      ],
                    ),
                    const SizedBox(height: 30),

                    /// LOGIN TEXT
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text("Already have an account? ",
                            style: GoogleFonts.poppins()),
                        GestureDetector(
                          onTap: () => Navigator.pushNamed(context, '/login'),
                          child: Text("Log in",
                              style: GoogleFonts.poppins(
                                fontWeight: FontWeight.bold,
                                color: Colors.black,
                              )),
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
    );
  }

  /// reusable social button
  Widget _socialButton(String assetPath) {
    return Container(
      width: 50,
      height: 50,
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: Border.all(color: Colors.grey.shade300),
        color: Colors.white,
      ),
      child: Image.asset(assetPath),
    );
  }
}
