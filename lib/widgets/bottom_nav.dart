import 'package:flutter/material.dart';

class CustomBottomNavBar extends StatelessWidget {
  final int selectedIndex;
  final ValueChanged<int> onTap;

  const CustomBottomNavBar({
    super.key,
    required this.selectedIndex,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final List<Map<String, String>> items = [
      {
        'label': 'Home',
        'icon_inactive': 'assets/icons/home_tipis.png',
        'icon_active': 'assets/icons/home_highlight.png',
      },
      {
        'label': 'Service',
        'icon_inactive': 'assets/icons/service_tipis.png',
        'icon_active': 'assets/icons/service_tebal.png',
      },
      {
        'label': 'Dashboard',
        'icon_inactive': 'assets/icons/dashboard_tipis.png',
        'icon_active': 'assets/icons/dashboard_tebal.png',
      },
      {
        'label': 'Profile',
        'icon_inactive': 'assets/icons/user_tipis.png',
        'icon_active': 'assets/icons/user_tebal.png',
      },
    ];

    return SafeArea(
      top: false,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
        child: LayoutBuilder(
          builder: (context, constraints) {
            final totalWidth = constraints.maxWidth;
            final itemCount = items.length;
            final itemWidth = totalWidth / itemCount;

            return Container(
              height: 70,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(18),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.08),
                    blurRadius: 8,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Stack(
                alignment: Alignment.center,
                children: [
                  // Background merah animasi
                  AnimatedPositioned(
                    duration: const Duration(milliseconds: 300),
                    curve: Curves.easeOutCubic,
                    left: itemWidth * selectedIndex + 8,
                    top: 6,
                    width: itemWidth - 16,
                    height: 58,
                    child: Container(
                      decoration: BoxDecoration(
                        color: const Color(0xFFDC2626),
                        borderRadius: BorderRadius.circular(14),
                      ),
                    ),
                  ),
                  Row(
                    children: List.generate(itemCount, (index) {
                      final entry = items[index];
                      final active = index == selectedIndex;

                      return Expanded(
                        child: InkWell(
                          onTap: () => onTap(index),
                          splashColor: Colors.transparent,
                          highlightColor: Colors.transparent,
                          child: SizedBox(
                            height: 70,
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                // pakai Image.asset, bukan Icon
                                Image.asset(
                                  active
                                      ? entry['icon_active']!
                                      : entry['icon_inactive']!,
                                  width: 22,
                                  height: 22,
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  entry['label']!,
                                  style: TextStyle(
                                    fontSize: 12,
                                    fontWeight: FontWeight.w600,
                                    color: active
                                        ? Colors.white
                                        : const Color(0xFF9A9A9A),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      );
                    }),
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}
