import 'dart:io';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';

class RegisterBengkelScreen extends StatefulWidget {
  const RegisterBengkelScreen({super.key});

  @override
  State<RegisterBengkelScreen> createState() => _RegisterBengkelScreenState();
}

class _RegisterBengkelScreenState extends State<RegisterBengkelScreen> {
  final TextEditingController usernameController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController phoneController = TextEditingController();
  final TextEditingController alamatController = TextEditingController();
  final TextEditingController urlController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final TextEditingController confirmPasswordController =
      TextEditingController();

  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;

  String? hariOperasional;
  String? jamOperasional;

  File? _fotoBengkel;

  final List<String> hariList = [
    "Senin - Jumat",
    "Senin - Sabtu",
    "Setiap Hari"
  ];

  final List<String> jamList = ["08:00 - 17:00", "09:00 - 18:00", "24 Jam"];

  Future<void> _pickImage() async {
    final ImagePicker picker = ImagePicker();
    final XFile? pickedFile =
        await picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() {
        _fotoBengkel = File(pickedFile.path);
      });
    }
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
              // Logo
              Image.asset("assets/icons/logo.png", height: 90),
              const SizedBox(height: 20),

              // Title
              Text(
                "Register",
                style: GoogleFonts.poppins(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: const Color.fromARGB(255, 215, 43, 28),
                ),
              ),
              const SizedBox(height: 6),
              Text(
                "Sign up to get started",
                style: GoogleFonts.poppins(
                    fontSize: 14,
                    color: const Color.fromARGB(255, 215, 43, 28)),
              ),
              const SizedBox(height: 30),

              // Username
              _buildTextField(
                controller: usernameController,
                label: "Username",
                hint: "Masukkan username anda",
                iconPath: "assets/icons/log.png",
              ),
              const SizedBox(height: 16),

              // Email / Address
              _buildTextField(
                controller: emailController,
                label: "Email",
                hint: "Masukkan email anda",
                iconPath: "assets/icons/log.png",
              ),
              const SizedBox(height: 14),

              // Phone
              _buildTextField(
                controller: phoneController,
                label: "Phone",
                hint: "Masukkan nomor telepon",
                iconPath: "assets/icons/role.png",
              ),
              const SizedBox(height: 14),

              // Alamat
              _buildTextField(
                controller: alamatController,
                label: "Alamat",
                hint: "Masukkan alamat bengkel anda",
                iconPath: "assets/icons/alamat.png",
              ),
              const SizedBox(height: 14),

              // Alamat URL
              _buildTextField(
                controller: urlController,
                label: "Alamat URL",
                hint: "Masukkan URL maps bengkel anda",
                iconPath: "assets/icons/password.png",
              ),
              const SizedBox(height: 14),

              // Password
              _buildPasswordField(
                controller: passwordController,
                label: "Password",
                hint: "Masukkan password",
                obscure: _obscurePassword,
                onToggle: () {
                  setState(() {
                    _obscurePassword = !_obscurePassword;
                  });
                },
              ),
              const SizedBox(height: 14),

              // Confirm Password
              _buildPasswordField(
                controller: confirmPasswordController,
                label: "Confirm Password",
                hint: "Konfirmasi password",
                obscure: _obscureConfirmPassword,
                onToggle: () {
                  setState(() {
                    _obscureConfirmPassword = !_obscureConfirmPassword;
                  });
                },
              ),
              const SizedBox(height: 14),

              // Hari Operasional
              _buildDropdown(
                label: "Hari Operasional",
                hint: "Pilih hari bengkel beroperasi",
                value: hariOperasional,
                items: hariList,
                onChanged: (value) {
                  setState(() {
                    hariOperasional = value;
                  });
                },
              ),
              const SizedBox(height: 14),

              // Jam Operasional
              _buildDropdown(
                label: "Jam Operasional",
                hint: "Pilih jam bengkel beroperasi",
                value: jamOperasional,
                items: jamList,
                onChanged: (value) {
                  setState(() {
                    jamOperasional = value;
                  });
                },
              ),
              const SizedBox(height: 24),

              // Upload Foto Bengkel
              Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  "Upload Foto Bengkel",
                  style: GoogleFonts.poppins(
                    fontWeight: FontWeight.w500,
                    color: Color.fromARGB(255, 215, 43, 28),
                  ),
                ),
              ),
              const SizedBox(height: 8),
              GestureDetector(
                onTap: _pickImage,
                child: Container(
                  width: double.infinity,
                  height: 160,
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.grey),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: _fotoBengkel == null
                      ? Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Icon(Icons.cloud_upload,
                                size: 40,
                                color: Color.fromARGB(255, 215, 43, 28)),
                            const SizedBox(height: 8),
                            Text(
                              "Drag & drop files or Browse",
                              style: GoogleFonts.poppins(
                                color: Color.fromARGB(255, 215, 43, 28),
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            Text(
                              "Supported formats: JPEG, PNG",
                              style: GoogleFonts.poppins(
                                color: Colors.black54,
                                fontSize: 12,
                              ),
                            ),
                          ],
                        )
                      : ClipRRect(
                          borderRadius: BorderRadius.circular(12),
                          child: Image.file(
                            _fotoBengkel!,
                            fit: BoxFit.cover,
                            width: double.infinity,
                            height: double.infinity,
                          ),
                        ),
                ),
              ),

              const SizedBox(height: 40),

              // Sign Up Button
              SizedBox(
                width: double.infinity,
                height: 40,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color.fromARGB(255, 215, 43, 28),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(28),
                    ),
                    elevation: 8,
                    shadowColor:
                        const Color.fromARGB(255, 215, 43, 28).withOpacity(0.6),
                  ),
                  onPressed: () {
                    Navigator.pushReplacementNamed(context, "/home");
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
            ],
          ),
        ),
      ),
    );
  }

  /// 🔹 Normal TextField
  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required String hint,
    required String iconPath,
  }) {
    return TextField(
      controller: controller,
      decoration: InputDecoration(
        labelText: label,
        hintText: hint,
        labelStyle:
            GoogleFonts.poppins(color: Color.fromARGB(255, 215, 43, 28)),
        hintStyle: GoogleFonts.poppins(color: Colors.black38),
        prefixIcon: Padding(
          padding: const EdgeInsets.all(10.0),
          child: Image.asset(iconPath,
              width: 20, height: 20, color: Color.fromARGB(255, 215, 43, 28)),
        ),
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
        fillColor: const Color.fromARGB(222, 255, 255, 255).withOpacity(0.3),
      ),
      style: GoogleFonts.poppins(),
    );
  }

  /// 🔹 Password TextField
  Widget _buildPasswordField({
    required TextEditingController controller,
    required String label,
    required String hint,
    required bool obscure,
    required VoidCallback onToggle,
  }) {
    return TextField(
      controller: controller,
      obscureText: obscure,
      decoration: InputDecoration(
        labelText: label,
        hintText: hint,
        labelStyle:
            GoogleFonts.poppins(color: Color.fromARGB(255, 215, 43, 28)),
        hintStyle: GoogleFonts.poppins(color: Colors.black38),
        prefixIcon:
            const Icon(Icons.lock, color: Color.fromARGB(255, 215, 43, 28)),
        suffixIcon: IconButton(
          icon: Icon(
            obscure ? Icons.visibility_off : Icons.visibility,
            color: Color.fromARGB(255, 215, 43, 28),
          ),
          onPressed: onToggle,
        ),
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
        fillColor: const Color.fromARGB(222, 255, 255, 255).withOpacity(0.3),
      ),
      style: GoogleFonts.poppins(),
    );
  }

  Widget _buildDropdown({
    required String label,
    required String hint,
    required String? value,
    required List<String> items,
    required Function(String?) onChanged,
  }) {
    return DropdownButtonFormField<String>(
      value: value,
      items: items.map((item) {
        return DropdownMenuItem(
          value: item,
          child: Text(
            item,
            style: GoogleFonts.poppins(
              color: Colors.black,
              fontSize: 14,
            ),
          ),
        );
      }).toList(),
      onChanged: onChanged,
      dropdownColor: Colors.white,
      decoration: InputDecoration(
        labelText: label,
        hintText: hint,
        labelStyle:
            GoogleFonts.poppins(color: Color.fromARGB(255, 215, 43, 28)),
        hintStyle: GoogleFonts.poppins(color: Colors.black38),
        prefixIcon: const Icon(Icons.arrow_drop_down_circle,
            color: Color.fromARGB(255, 215, 43, 28)),
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
        fillColor: const Color.fromARGB(222, 255, 255, 255).withOpacity(0.3),
      ),
      style: GoogleFonts.poppins(
        color: Colors.black,
        fontSize: 14,
      ),
      icon: const Icon(
        Icons.keyboard_arrow_down, // 🔹 ikon lebih umum untuk dropdown
        color: Color.fromARGB(255, 215, 43, 28),
      ),
    );
  }
}
