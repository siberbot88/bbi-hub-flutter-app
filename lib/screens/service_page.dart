import 'package:flutter/material.dart';

class ServicePage extends StatelessWidget {
  const ServicePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Service Page"),
        centerTitle: true,
      ),
      body: const Center(
        child: Text(
          "Halaman Service (kosong dulu)",
          style: TextStyle(fontSize: 16),
        ),
      ),
    );
  }
}
