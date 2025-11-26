import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../widgets/custom_header.dart';

class HelpSupportPage extends StatefulWidget {
  const HelpSupportPage({super.key});

  @override
  State<HelpSupportPage> createState() => _HelpSupportPageState();
}

class _HelpSupportPageState extends State<HelpSupportPage>
    with SingleTickerProviderStateMixin {
  final _searchC = TextEditingController();
  final Color red = const Color(0xFFDC2626);
  final List<_FaqItem> _faqs = const [
    _FaqItem(
      q: "How do I manage my notifications?",
      a: "To manage notifications, go to \"Settings,\" select \"Notification Settings,\" and customize your preferences.",
    ),
    _FaqItem(
      q: "How do I start a guided meditation session?",
      a: "Open the Meditation tab, pick a program, and press Start.",
    ),
    _FaqItem(
      q: "How do I join a support group?",
      a: "Navigate to Community > Groups, choose a group, and tap Join.",
    ),
    _FaqItem(
      q: "How do I manage my notifications?",
      a: "Open Settings > Notifications and adjust toggles as needed.",
    ),
    _FaqItem(
      q: "Is my data safe and private?",
      a: "Yes. We use encryption in transit and at rest. You can control data in Settings > Privacy.",
    ),
  ];

  int _expandedIndex = 0; // item pertama terbuka

  @override
  void dispose() {
    _searchC.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        backgroundColor: Colors.white,
        appBar: const CustomHeader(
          title: "Bantuan & Dukungan", // ⬅️ hanya ganti title sesuai permintaan
        ),
        body: Column(
          children: [
            // ======= Tab Bar (FAQ | Contact Us) =======
            Container(
              color: Colors.white,
              padding: const EdgeInsets.only(top: 6),
              child: TabBar(
                labelColor: Colors.black87,
                unselectedLabelColor: Colors.black45,
                labelStyle: GoogleFonts.poppins(
                    fontSize: 14, fontWeight: FontWeight.w600),
                unselectedLabelStyle:
                    GoogleFonts.poppins(fontSize: 14, fontWeight: FontWeight.w500),
                indicator: UnderlineTabIndicator(
                  borderSide: BorderSide(color: red, width: 2.5),
                  insets: const EdgeInsets.symmetric(horizontal: 18),
                ),
                tabs: const [
                  Tab(text: "FAQ"),
                  Tab(text: "Contact Us"),
                ],
              ),
            ),

            const SizedBox(height: 8),

            Expanded(
              child: TabBarView(
                children: [
                  // ======= TAB: FAQ =======
                  _buildFaqTab(context),

                  // ======= TAB: Contact Us =======
                  _buildContactTab(context),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFaqTab(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: ListView(
        children: [
          const SizedBox(height: 8),

          // ======= Search bar + tools icon =======
          Row(
            children: [
              Expanded(
                child: _SearchField(controller: _searchC),
              ),
              const SizedBox(width: 10),
              _RoundIcon(
                icon: Icons.tune,
                onTap: () {},
              ),
            ],
          ),

          const SizedBox(height: 16),

          // ======= FAQ Cards =======
          ...List.generate(_faqs.length, (i) {
            final item = _faqs[i];
            final isExpanded = _expandedIndex == i;
            return _FaqCard(
              item: item,
              expanded: isExpanded,
              onTap: () {
                setState(() {
                  _expandedIndex = (isExpanded) ? -1 : i;
                });
              },
            );
          }),
          const SizedBox(height: 16),
        ],
      ),
    );
  }

  Widget _buildContactTab(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 18),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _ContactLine(
            label: "Email",
            value: "support@yourapp.com",
            icon: Icons.email_outlined,
          ),
          const SizedBox(height: 12),
          _ContactLine(
            label: "Phone",
            value: "+62 812 3456 7890",
            icon: Icons.phone_outlined,
          ),
          const SizedBox(height: 12),
          _ContactLine(
            label: "Live Chat",
            value: "Available 09:00–17:00 WIB",
            icon: Icons.chat_bubble_outline_rounded,
          ),
        ],
      ),
    );
  }
}

/* ====================== Widgets ====================== */

class _SearchField extends StatelessWidget {
  final TextEditingController controller;
  const _SearchField({required this.controller});

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      style: GoogleFonts.poppins(fontSize: 14),
      decoration: InputDecoration(
        prefixIcon: const Icon(Icons.search, color: Colors.black26),
        hintText: "search for help",
        hintStyle: GoogleFonts.poppins(color: Colors.black26, fontSize: 14),
        contentPadding: const EdgeInsets.symmetric(vertical: 12, horizontal: 12),
        filled: true,
        fillColor: Colors.white,
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(28),
          borderSide: BorderSide(color: Colors.grey.shade300),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(28),
          borderSide: const BorderSide(color: Color(0xFFDC2626), width: 1.4),
        ),
      ),
    );
  }
}

class _RoundIcon extends StatelessWidget {
  final IconData icon;
  final VoidCallback? onTap;
  const _RoundIcon({required this.icon, this.onTap});

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.white,
      shape: const CircleBorder(),
      elevation: 0,
      child: InkWell(
        onTap: onTap,
        customBorder: const CircleBorder(),
        child: Container(
          width: 44,
          height: 44,
          decoration: BoxDecoration(
            border: Border.all(color: Colors.grey.shade300),
            shape: BoxShape.circle,
          ),
          child: Icon(icon, color: Colors.black54),
        ),
      ),
    );
  }
}

class _FaqItem {
  final String q;
  final String a;
  const _FaqItem({required this.q, required this.a});
}

class _FaqCard extends StatelessWidget {
  final _FaqItem item;
  final bool expanded;
  final VoidCallback onTap;
  const _FaqCard({
    required this.item,
    required this.expanded,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final title = Text(
      item.q,
      style: GoogleFonts.poppins(
        fontSize: 15,
        color: Colors.black87,
        fontWeight: FontWeight.w700,
        height: 1.2,
      ),
    );

    final answer = Text(
      item.a,
      style: GoogleFonts.poppins(
        fontSize: 12.5,
        color: Colors.black54,
        height: 1.4,
      ),
    );

    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(18),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 180),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(18),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withAlpha(10),
                blurRadius: 12,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(child: title),
                  const SizedBox(width: 8),
                  Icon(
                    expanded
                        ? Icons.keyboard_arrow_up_rounded
                        : Icons.keyboard_arrow_down_rounded,
                    color: Colors.black54,
                  ),
                ],
              ),
              if (expanded) ...[
                const SizedBox(height: 10),
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF8F8F8),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: answer,
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

class _ContactLine extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;

  const _ContactLine({
    required this.label,
    required this.value,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, color: Colors.black54),
        const SizedBox(width: 12),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(label,
                style: GoogleFonts.poppins(
                    fontSize: 12, color: Colors.black54)),
            const SizedBox(height: 2),
            Text(value,
                style: GoogleFonts.poppins(
                    fontSize: 14.5, fontWeight: FontWeight.w600)),
          ],
        )
      ],
    );
  }
}
