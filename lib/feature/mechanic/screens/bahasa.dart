import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class LanguagePage extends StatefulWidget {
  const LanguagePage({super.key});

  @override
  State<LanguagePage> createState() => _LanguagePageState();
}

class _LanguagePageState extends State<LanguagePage> {
  String? selectedLanguage = "Bahasa Indonesia";

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
    final Color primaryColor = const Color(0xFFD32F2F);

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: primaryColor,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        centerTitle: true,
        title: Text(
          'Bahasa',
          style: GoogleFonts.poppins(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: languages.length,
        itemBuilder: (context, index) {
          final lang = languages[index];
          return Column(
            children: [
              RadioListTile<String>(
                title: Text(
                  lang,
                  style: GoogleFonts.poppins(fontSize: 16),
                ),
                value: lang,
                activeColor: primaryColor,
                groupValue: selectedLanguage,
                onChanged: (value) {
                  setState(() {
                    selectedLanguage = value;
                  });
                },
              ),
              if (index != languages.length - 1)
                const Divider(
                  height: 0,
                  thickness: 0.5,
                  color: Color(0xFFE0E0E0),
                ),
            ],
          );
        },
      ),
    );
  }
}
