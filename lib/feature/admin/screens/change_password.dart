import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class ChangePasswordPage extends StatefulWidget {
  const ChangePasswordPage({super.key});

  @override
  State<ChangePasswordPage> createState() => _ChangePasswordPageState();
}

class _ChangePasswordPageState extends State<ChangePasswordPage> {
  final TextEditingController lastController = TextEditingController();
  final TextEditingController newController = TextEditingController();
  final TextEditingController confirmController = TextEditingController();

  bool obscureLast = true;
  bool obscureNew = true;
  bool obscureConfirm = true;

  final _formKey = GlobalKey<FormState>();

  Color primaryRed = const Color.fromARGB(255, 215, 43, 28);

  InputDecoration _buildInputDecoration(
      {required String label,
      required String hint,
      required String iconPath,
      required bool obscure,
      required VoidCallback toggle}) {
    return InputDecoration(
      labelText: label,
      labelStyle: GoogleFonts.poppins(
        color: primaryRed,
        fontWeight: FontWeight.w500,
      ),
      hintText: hint,
      hintStyle: GoogleFonts.poppins(color: Colors.grey),
      prefixIcon: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Image.asset(
          iconPath,
          width: 22,
          height: 22,
          color: primaryRed,
        ),
      ),
      suffixIcon: IconButton(
        icon: Icon(
          obscure ? Icons.visibility_off : Icons.visibility,
          color: primaryRed,
        ),
        onPressed: toggle,
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: primaryRed, width: 1.5),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: primaryRed, width: 2),
      ),
      filled: true,
      fillColor: Colors.transparent,
    );
  }

  void _save() {
    if (_formKey.currentState?.validate() ?? false) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text("Password berhasil diubah"),
          backgroundColor: primaryRed,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios_new, color: primaryRed, size: 18),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          "Change Password",
          style: GoogleFonts.poppins(
            color: primaryRed,
            fontSize: 18,
            fontWeight: FontWeight.w600,
          ),
        ),
        centerTitle: true,
      ),
      backgroundColor: Colors.white,
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              // 🔹 Last Password
              TextFormField(
                controller: lastController,
                obscureText: obscureLast,
                decoration: _buildInputDecoration(
                  label: "Last Password",
                  hint: "Masukkan password lama",
                  iconPath: "assets/icons/password.png", // pakai asset milikmu
                  obscure: obscureLast,
                  toggle: () => setState(() => obscureLast = !obscureLast),
                ),
                validator: (v) =>
                    v == null || v.isEmpty ? "Isi password lama" : null,
              ),
              const SizedBox(height: 18),

              // 🔹 New Password
              TextFormField(
                controller: newController,
                obscureText: obscureNew,
                decoration: _buildInputDecoration(
                  label: "New Password",
                  hint: "Masukkan password baru",
                  iconPath: "assets/icons/password.png", // pakai asset milikmu
                  obscure: obscureNew,
                  toggle: () => setState(() => obscureNew = !obscureNew),
                ),
                validator: (v) =>
                    v == null || v.isEmpty ? "Isi password baru" : null,
              ),
              const SizedBox(height: 18),

              // 🔹 Confirm Password
              TextFormField(
                controller: confirmController,
                obscureText: obscureConfirm,
                decoration: _buildInputDecoration(
                  label: "Confirm Password",
                  hint: "Konfirmasi password baru",
                  iconPath: "assets/icons/password.png", // pakai asset milikmu
                  obscure: obscureConfirm,
                  toggle: () =>
                      setState(() => obscureConfirm = !obscureConfirm),
                ),
                validator: (v) {
                  if (v == null || v.isEmpty) {
                    return "Konfirmasi password";
                  }
                  if (v != newController.text) {
                    return "Password tidak sama";
                  }
                  return null;
                },
              ),
              const SizedBox(height: 30),
              SizedBox(
                width: double.infinity,
                height: 40,
                child: ElevatedButton(
                  onPressed: _save,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: primaryRed,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(28),
                    ),
                    elevation: 8,
                    shadowColor: primaryRed.withOpacity(0.6),
                  ),
                  child: Text(
                    'SAVE',
                    style: GoogleFonts.poppins(
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
