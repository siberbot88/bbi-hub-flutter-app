import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class ServiceTabSelector extends StatelessWidget {
  final int selectedTab;
  final Function(int) onTabChanged;

  const ServiceTabSelector({
    super.key,
    required this.selectedTab,
    required this.onTabChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        children: [
          Expanded(
            child: _buildTab(
              label: 'Penjadwalan',
              icon: Icons.calendar_today,
              isSelected: selectedTab == 0,
              onTap: () => onTabChanged(0),
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: _buildTab(
              label: 'On-the-site',
              icon: Icons.build,
              isSelected: selectedTab == 1,
              onTap: () => onTabChanged(1),
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: _buildTab(
              label: 'Pencatatan',
              icon: Icons.show_chart,
              isSelected: selectedTab == 2,
              onTap: () => onTabChanged(2),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTab({
    required String label,
    required IconData icon,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    const primaryColor = Color(0xFFB70F0F);
    
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 10),
        decoration: BoxDecoration(
          color: isSelected ? primaryColor : Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: primaryColor, width: 2),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              size: 18,
              color: isSelected ? Colors.white : primaryColor,
            ),
            const SizedBox(width: 6),
            Text(
              label,
              style: GoogleFonts.poppins(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: isSelected ? Colors.white : primaryColor,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
