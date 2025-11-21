import 'package:flutter/material.dart';

class HomePageOwner extends StatelessWidget {
   HomePageOwner({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Home - Owner"),
        backgroundColor: Colors.red,
      ),
      body: const Center(
        child: Text(
          "Ini halaman HomePage Owner 🚗",
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.w500),
        ),
      ),
    );
  }
}
