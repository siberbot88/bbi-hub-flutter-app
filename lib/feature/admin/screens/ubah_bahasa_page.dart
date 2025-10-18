import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../widgets/custom_header.dart';

class UbahBahasaPage extends StatefulWidget {
  const UbahBahasaPage({super.key});

  @override
  State<UbahBahasaPage> createState() => _UbahBahasaPageState();
}

class _UbahBahasaPageState extends State<UbahBahasaPage> {
  String _selectedLanguage = "Bahasa Indonesia";

  final List<String> languages = [
    "English",
    "Bahasa Indonesia",
    "Bahasa Melayu",
    "한국어 (Korean)",
    "日本語 (Japanese)",
    "中文 (Mandarin)",
    "Français",
  ];

  @override
  Widget build(BuildContext context) {
    const red = Color(0xFFDC2626);

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: const CustomHeader(
        title: "Ubah Bahasa", // ⬅️ hanya ganti title sesuai permintaan
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(vertical: 10),
        child: ListView.builder(
          itemCount: languages.length,
          itemBuilder: (context, index) {
            final lang = languages[index];
            return RadioListTile<String>(
              value: lang,
              groupValue: _selectedLanguage,
              activeColor: red,
              title: Text(
                lang,
                style: GoogleFonts.poppins(
                  fontSize: 15,
                  color: Colors.black87,
                ),
              ),
              onChanged: (val) {
                setState(() => _selectedLanguage = val!);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(
                      "Bahasa diubah ke $val",
                      style: GoogleFonts.poppins(color: Colors.white),
                    ),
                    backgroundColor: red,
                    duration: const Duration(seconds: 1),
                  ),
                );
              },
            );
          },
        ),
      ),
    );
  }
}
