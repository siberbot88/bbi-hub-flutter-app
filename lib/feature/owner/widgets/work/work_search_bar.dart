import 'package:flutter/material.dart';

class WorkSearchBar extends StatelessWidget {
  final TextEditingController controller;
  final VoidCallback onFilterTap;
  final bool hasActiveFilter;
  final Function(String) onChanged;

  const WorkSearchBar({
    super.key,
    required this.controller,
    required this.onFilterTap,
    required this.hasActiveFilter,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 56,
      decoration: const BoxDecoration(
        color: Color(0xFFF0F1F5),
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(50),
          bottomLeft: Radius.circular(50),
          bottomRight: Radius.circular(30),
        ),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 18),
      child: Row(
        children: [
          const Icon(Icons.search, color: Colors.grey),
          const SizedBox(width: 10),
          Expanded(
            child: TextField(
              controller: controller,
              decoration: const InputDecoration(
                hintText: 'Cari kendaraan, customer, atau plat',
                border: InputBorder.none,
              ),
              onChanged: onChanged,
            ),
          ),
          InkWell(
            onTap: onFilterTap,
            borderRadius: BorderRadius.circular(24),
            child: Container(
              padding: const EdgeInsets.all(6),
              decoration: BoxDecoration(
                color:
                    hasActiveFilter ? const Color(0xFFDC2626) : Colors.transparent,
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.tune,
                color: hasActiveFilter ? Colors.white : Colors.grey,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
