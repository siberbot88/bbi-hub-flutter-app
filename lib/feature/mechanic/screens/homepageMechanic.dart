import 'package:flutter/material.dart';

class HomePageMechanic extends StatelessWidget {
   HomePageMechanic({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Home - Mechanic"),
        backgroundColor: Colors.red,
      ),
      body: const Center(
        child: Text(
          "Ini halaman HomePage Mechanic 🔧",
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.w500),
        ),
      ),
    );
  }
}
