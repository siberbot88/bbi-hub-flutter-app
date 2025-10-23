import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class HelpSupportPage extends StatefulWidget {
  const HelpSupportPage({super.key});

  @override
  State<HelpSupportPage> createState() => _HelpSupportPageState();
}

class _HelpSupportPageState extends State<HelpSupportPage>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final Color primaryColor = const Color(0xFFD32F2F);
  final TextEditingController searchController = TextEditingController();

  final List<Map<String, String>> faqList = [
    {
      'question': 'How do I manage my notifications?',
      'answer':
          'To manage notifications, go to “Settings”, select “Notification Settings”, and customize your preferences.'
    },
    {
      'question': 'How do I start a guided meditation session?',
      'answer': 'Open the Meditation tab, select a guide, and tap "Start Session".'
    },
    {
      'question': 'How do I join a support group?',
      'answer': 'Go to “Community”, choose a group, and click “Join”.'
    },
    {
      'question': 'Is my data safe and private?',
      'answer':
          'Yes. We use advanced encryption and privacy measures to protect your data.'
    },
  ];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  Widget build(BuildContext context) {
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
          'Bantuan & Dukungan',
          style: GoogleFonts.poppins(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
        bottom: TabBar(
          controller: _tabController,
          labelColor: Colors.white,
          unselectedLabelColor: Colors.white70,
          indicatorColor: Colors.white,
          tabs: const [
            Tab(text: 'FAQ'),
            Tab(text: 'Contact Us'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildFAQTab(),
          _buildContactTab(),
        ],
      ),
    );
  }

  Widget _buildFAQTab() {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          // Kolom pencarian
          TextField(
            controller: searchController,
            decoration: InputDecoration(
              hintText: 'Search for help',
              hintStyle: GoogleFonts.poppins(color: Colors.grey),
              prefixIcon: const Icon(Icons.search),
              suffixIcon: const Icon(Icons.tune),
              filled: true,
              fillColor: Colors.grey[100],
              border: OutlineInputBorder(
                borderSide: BorderSide.none,
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),
          const SizedBox(height: 16),
          Expanded(
            child: ListView.builder(
              itemCount: faqList.length,
              itemBuilder: (context, index) {
                return _buildFAQItem(
                  faqList[index]['question']!,
                  faqList[index]['answer']!,
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFAQItem(String question, String answer) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.grey[50],
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.15),
            blurRadius: 4,
            offset: const Offset(0, 2),
          )
        ],
      ),
      child: ExpansionTile(
        title: Text(
          question,
          style: GoogleFonts.poppins(fontWeight: FontWeight.w600),
        ),
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Text(
              answer,
              style: GoogleFonts.poppins(color: Colors.black87),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildContactTab() {
    return Center(
      child: Text(
        'Contact Us page is under development.',
        style: GoogleFonts.poppins(fontSize: 16, color: Colors.grey),
      ),
    );
  }
}
