import 'package:flutter/material.dart';
import 'logging_helpers.dart';
import '../../screens/service_pending.dart' as pending;
import '../../screens/service_progress.dart' as progress;
import '../../screens/service_complete.dart' as complete;

class LoggingTaskCard extends StatelessWidget {
  final Map<String, dynamic> task;

  const LoggingTaskCard({
    super.key,
    required this.task,
  });

  @override
  Widget build(BuildContext context) {
    Color statusColor;
    final status = task['status'] as String;

    if (status == "Completed") {
      statusColor = Colors.green;
    } else if (status == "In Progress") {
      statusColor = Colors.orange;
    } else if (status == "Pending") {
      statusColor = Colors.grey.shade800;
    } else {
      statusColor = Colors.grey.shade800;
    }

    Widget actionButton;

    if (status == 'Pending') {
      actionButton = ElevatedButton(
        onPressed: () {
          Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => pending.ServicePendingDetail(task: task),
              ));
        },
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFFDC2626),
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
        ),
        child: const Text("Tetapkan Mekanik",
            style: TextStyle(fontSize: 12, color: Colors.white)),
      );
    } else if (status == 'In Progress') {
      actionButton = ElevatedButton(
        onPressed: () {
          Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => progress.ServiceProgressDetail(task: task),
              ));
        },
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.orange,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
        ),
        child: const Text("Lihat Detail",
            style: TextStyle(fontSize: 12, color: Colors.white)),
      );
    } else if (status == 'Completed') {
      actionButton = ElevatedButton(
        onPressed: () {
          Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => complete.ServiceCompleteDetail(task: task),
              ));
        },
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.green,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
        ),
        child: const Text("Buat Invoice",
            style: TextStyle(fontSize: 12, color: Colors.white)),
      );
    } else {
      actionButton = const SizedBox.shrink();
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
              color: Colors.black.withAlpha(13), // 0.05 * 255
              blurRadius: 6,
              offset: const Offset(0, 3))
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                    color: statusColor.withAlpha(77), // 0.3 * 255
                    borderRadius: BorderRadius.circular(20)),
                child: Text(task['status'],
                    style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: statusColor)),
              ),
              Text(
                  "${LoggingHelpers.formatDate(task['date'] as DateTime)} • ${task['time']}",
                  style: const TextStyle(
                      fontSize: 12,
                      color: Colors.grey,
                      fontWeight: FontWeight.w500)),
            ],
          ),
          const SizedBox(height: 8),
          Text(task['title'],
              style:
                  const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
          const SizedBox(height: 4),
          Text(task['desc'],
              style: const TextStyle(fontSize: 12, color: Colors.black87)),
          const SizedBox(height: 8),
          Row(
            children: [
              const Icon(Icons.settings, size: 16, color: Colors.grey),
              const SizedBox(width: 6),
              Text("${task['motor']}  #${task['plate']}",
                  style: const TextStyle(fontSize: 12, color: Colors.grey)),
            ],
          ),
          const SizedBox(height: 10),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  CircleAvatar(
                      radius: 14,
                      backgroundImage: NetworkImage(
                          "https://i.pravatar.cc/150?img=${task['id']}")),
                  const SizedBox(width: 8),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(task['user'],
                          style: const TextStyle(
                              fontSize: 13, fontWeight: FontWeight.w600)),
                      Text("ID: ${task['id']}",
                          style: const TextStyle(
                              fontSize: 11, color: Colors.grey)),
                    ],
                  ),
                ],
              ),
              actionButton,
            ],
          ),
        ],
      ),
    );
  }
}
