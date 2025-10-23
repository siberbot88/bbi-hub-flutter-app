import 'package:flutter/material.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();

  final _nameController = TextEditingController();
  final _usernameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;

  String? _selectedRole;
  final List<String> _roles = ['AdminWorkshop', 'Technician'];

  String? _selectedWorkshop;
  final List<String> _workshops = ['Ahas', 'Yamaha Lub', 'Pulsar'];

  InputDecoration getInputDecoration(String label, Icon icon) {
    return InputDecoration(
      labelText: label,
      prefixIcon: Icon(icon.icon, color: Colors.red),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(20),
        borderSide: BorderSide(color: Colors.red),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(20),
        borderSide: const BorderSide(color: Colors.red, width: 2),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(20),
        borderSide: const BorderSide(color: Colors.red),
      ),
      focusedErrorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(20),
        borderSide: const BorderSide(color: Colors.red, width: 2),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          Positioned.fill(
            child: Image.asset(
              "assets/bg.png",
              fit: BoxFit.cover,
            ),
          ),

          /// ===== Main Content =====
          SafeArea(
            child: Column(
              children: [
                // ===== FIXED HEADER (LOGO + TITLE) =====
                Padding(
                  padding: const EdgeInsets.only(top: 30),
                  child: Column(
                    children: [
                      Image.asset("assets/logo.png", height: 80),
                      const SizedBox(height: 10),
                      const Text(
                        "Register",
                        style: TextStyle(
                          fontSize: 22,
                          color: Colors.red,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 15),
                      const Text(
                        "Daftar sekarang dan kelola bengkelmu",
                        style:
                            TextStyle(color: Color(0xFF232323), fontSize: 18),
                      ),
                      const SizedBox(height: 20),
                    ],
                  ),
                ),

                // ===== FORM & SCROLLABLE AREA =====
                Expanded(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.symmetric(horizontal: 24),
                    child: Form(
                      key: _formKey,
                      child: Column(
                        children: [
                          const SizedBox(height: 20),
                          TextFormField(
                            controller: _nameController,
                            decoration: getInputDecoration(
                                "Name", const Icon(Icons.person)),
                            validator: (value) => value == null || value.isEmpty
                                ? 'Enter your name'
                                : null,
                          ),
                          const SizedBox(height: 20),
                          TextFormField(
                            controller: _usernameController,
                            decoration: getInputDecoration(
                                "Username", const Icon(Icons.person_outline)),
                            validator: (value) => value == null || value.isEmpty
                                ? 'Enter a username'
                                : null,
                          ),
                          const SizedBox(height: 20),
                          TextFormField(
                            controller: _emailController,
                            decoration: getInputDecoration(
                                "Email", const Icon(Icons.email)),
                            validator: (value) =>
                                value == null || !value.contains('@')
                                    ? 'Enter a valid email'
                                    : null,
                          ),
                          const SizedBox(height: 20),
                          DropdownButtonFormField<String>(
                            value: _selectedRole,
                            decoration: getInputDecoration("Select Role",
                                const Icon(Icons.assignment_ind)),
                            style: const TextStyle(
                              color: Color(0xFF232323),
                              fontSize: 16,
                            ),
                            dropdownColor: Colors.white,
                            icon: const Icon(Icons.keyboard_arrow_down,
                                color: Colors.red),
                            borderRadius: BorderRadius.circular(12),
                            items: _roles.map((w) {
                              return DropdownMenuItem(
                                value: w,
                                child: Text(
                                  w,
                                  style:
                                      const TextStyle(color: Color(0xFF232323)),
                                ),
                              );
                            }).toList(),
                            onChanged: (value) {
                              setState(() {
                                _selectedRole = value;
                              });
                            },
                            validator: (value) =>
                                value == null ? 'Select a role' : null,
                          ),
                          const SizedBox(height: 20),
                          DropdownButtonFormField<String>(
                            value: _selectedWorkshop,
                            decoration: getInputDecoration(
                                "Select Workshop", const Icon(Icons.build)),
                            style: const TextStyle(
                              color: Color(0xFF232323),
                              fontSize: 16,
                            ),
                            dropdownColor: Colors.white,
                            icon: const Icon(Icons.keyboard_arrow_down,
                                color: Colors.red),
                            borderRadius: BorderRadius.circular(12),
                            items: _workshops.map((w) {
                              return DropdownMenuItem(
                                value: w,
                                child: Text(
                                  w,
                                  style:
                                      const TextStyle(color: Color(0xFF232323)),
                                ),
                              );
                            }).toList(),
                            onChanged: (value) {
                              setState(() {
                                _selectedWorkshop = value;
                              });
                            },
                            validator: (value) =>
                                value == null ? 'Select a workshop' : null,
                          ),
                          const SizedBox(height: 20),
                          TextFormField(
                            controller: _passwordController,
                            obscureText: _obscurePassword,
                            decoration: getInputDecoration(
                                    "Password", const Icon(Icons.lock))
                                .copyWith(
                              suffixIcon: IconButton(
                                icon: Icon(
                                  _obscurePassword
                                      ? Icons.visibility_off
                                      : Icons.visibility,
                                ),
                                onPressed: () => setState(
                                    () => _obscurePassword = !_obscurePassword),
                              ),
                            ),
                            validator: (value) =>
                                value == null || value.length < 6
                                    ? 'Minimum 6 characters'
                                    : null,
                          ),
                          const SizedBox(height: 20),
                          TextFormField(
                            controller: _confirmPasswordController,
                            obscureText: _obscureConfirmPassword,
                            decoration: getInputDecoration("Confirm Password",
                                    const Icon(Icons.lock_outline))
                                .copyWith(
                              suffixIcon: IconButton(
                                icon: Icon(
                                  _obscureConfirmPassword
                                      ? Icons.visibility_off
                                      : Icons.visibility,
                                ),
                                onPressed: () => setState(() =>
                                    _obscureConfirmPassword =
                                        !_obscureConfirmPassword),
                              ),
                            ),
                            validator: (value) {
                              if (value != _passwordController.text) {
                                return 'Passwords do not match';
                              }
                              return null;
                            },
                          ),
                          const SizedBox(height: 40),

                          /// ===== SIGN UP BUTTON =====
                          SizedBox(
                            width: double.infinity,
                            height: 50,
                            child: ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.red,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(15),
                                ),
                              ),
                              onPressed: () {
                                if (_formKey.currentState!.validate()) {
                                  Navigator.pushReplacementNamed(
                                      context, '/home');
                                }
                              },
                              child: const Text("SIGN UP",
                                  style: TextStyle(
                                      fontSize: 16, color: Colors.white)),
                            ),
                          ),
                          const SizedBox(height: 10),

                          /// ===== LOGIN TEXT =====
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const Text("Already have an account? "),
                              GestureDetector(
                                onTap: () =>
                                    Navigator.pushNamed(context, '/login'),
                                child: const Text(
                                  "Log in",
                                  style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      color: Colors.black),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 30),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
