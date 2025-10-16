import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class TechnicianTab extends StatelessWidget {
  final String selectedRange;
  final ValueChanged<String> onRangeChange;

  const TechnicianTab({
    super.key,
    required this.selectedRange,
    required this.onRangeChange,
  });

  final List<Map<String, dynamic>> technicians = const [
    {
      "name": "James Hariyanto",
      "id": "T0001 • Senior Technician",
      "rating": 4.9,
      "jobs": 18,
      "avg": "2.5h",
      "photo": "https://i.pravatar.cc/150?img=1",
    },
    {
      "name": "Nanda Santoso",
      "id": "T0002 • Lead Technician",
      "rating": 4.5,
      "jobs": 15,
      "avg": "1.9h",
      "photo": "https://i.pravatar.cc/150?img=2",
    },
    {
      "name": "Dimas Doniansyah",
      "id": "T0003 • Junior Technician",
      "rating": 4.2,
      "jobs": 10,
      "avg": "1.7h",
      "photo": "https://i.pravatar.cc/150?img=3",
    },
    {
      "name": "Sandy Kanara",
      "id": "T0004 • Senior Technician",
      "rating": 5.0,
      "jobs": 9,
      "avg": "2.8h",
      "photo": "https://i.pravatar.cc/150?img=4",
    },
  ];

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 🔹 Title + Dropdown
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text("Technician Performances",
                  style: GoogleFonts.poppins(
                      fontWeight: FontWeight.w600,
                      fontSize: 16,
                      color: Colors.white)),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.red[900],
                  borderRadius: BorderRadius.circular(20),
                ),
                child: DropdownButton<String>(
                  value: selectedRange,
                  underline: const SizedBox(),
                  dropdownColor: Colors.red[900],
                  icon: const Icon(Icons.arrow_drop_down, color: Colors.white),
                  style: GoogleFonts.poppins(color: Colors.white),
                  items: ["Today", "Yesterday", "Week", "Month"]
                      .map((e) => DropdownMenuItem(
                            value: e,
                            child: Text(e,
                                style: const TextStyle(color: Colors.white)),
                          ))
                      .toList(),
                  onChanged: (value) {
                    if (value != null) onRangeChange(value);
                  },
                ),
              ),
            ],
          ),

          const SizedBox(height: 8),

          // 🔹 View All
          Align(
            alignment: Alignment.centerRight,
            child: GestureDetector(
              onTap: () {
                // Arahkan ke halaman detail semua teknisi
              },
              child: Text("View All",
                  style: GoogleFonts.poppins(
                      fontSize: 13,
                      fontWeight: FontWeight.w500,
                      color: Colors.white)),
            ),
          ),

          const SizedBox(height: 12),

          // 🔹 List Technician
          Column(
            children: technicians
                .map((t) => _technicianCard(
                      t["photo"]!,
                      t["name"]!,
                      t["id"]!,
                      t["rating"]!,
                      t["jobs"]!,
                      t["avg"]!,
                    ))
                .toList(),
          ),
        ],
      ),
    );
  }

  Widget _technicianCard(String photo, String name, String id, double rating,
      int jobs, String avg) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 6,
              offset: const Offset(0, 3))
        ],
      ),
      child: Row(
        children: [
          // 🔹 Foto Profil
          CircleAvatar(radius: 25, backgroundImage: NetworkImage(photo)),
          const SizedBox(width: 12),

          // 🔹 Nama, ID, Rating
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(name,
                    style: GoogleFonts.poppins(
                        fontWeight: FontWeight.w600, fontSize: 14)),
                Text(id,
                    style: GoogleFonts.poppins(
                        fontSize: 12, color: Colors.grey[600])),
                Row(
                  children: [
                    const Icon(Icons.star, color: Colors.amber, size: 16),
                    Text("$rating Rating",
                        style: GoogleFonts.poppins(fontSize: 12)),
                  ],
                ),
              ],
            ),
          ),

          // 🔹 Jobs + Avg
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text("$jobs Jobs Today",
                  style: GoogleFonts.poppins(
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                      color: Colors.red[700])),
              Text("Avg: $avg per service",
                  style: GoogleFonts.poppins(fontSize: 11, color: Colors.grey)),
            ],
          ),
        ],
      ),
    );
  }
}
