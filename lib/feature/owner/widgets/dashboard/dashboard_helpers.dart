import 'package:bengkel_online_flutter/core/models/service.dart';
import 'package:flutter/material.dart';
import 'package:bengkel_online_flutter/feature/owner/screens/homepage_owner.dart';

/// Summary data for dashboard
class SummaryData {
  final num revenue;
  final int totalJob;
  final int totalDone;

  SummaryData({
    required this.revenue,
    required this.totalJob,
    required this.totalDone,
  });
}

/// Build summary based on date range
SummaryData buildSummary(List<ServiceModel> list, SummaryRange range) {
  final now = DateTime.now();

  bool inRange(ServiceModel s) {
    final d = s.scheduledDate ?? s.createdAt ?? s.updatedAt;
    if (d == null) return false;

    switch (range) {
      case SummaryRange.today:
        return d.year == now.year &&
            d.month == now.month &&
            d.day == now.day;
      case SummaryRange.week:
        final diff = now.difference(
          DateTime(d.year, d.month, d.day),
        );
        return !diff.isNegative && diff.inDays < 7;
      case SummaryRange.month:
        return d.year == now.year && d.month == now.month;
    }
  }

  num revenue = 0;
  int totalJob = 0;
  int totalDone = 0;

  for (final s in list.where(inRange)) {
    final status = s.status.toLowerCase();

    if (status == 'completed') {
      totalDone++;
      revenue += serviceRevenue(s);
    } else if (status != 'cancelled') {
      totalJob++;
    }
  }

  return SummaryData(
    revenue: revenue,
    totalJob: totalJob,
    totalDone: totalDone,
  );
}

/// Calculate total revenue from a service (price + parts)
num serviceRevenue(ServiceModel s) {
  final partsTotal = (s.items ?? const [])
      .fold<num>(0, (a, it) => a + (it.subtotal ?? 0));
  return (s.price ?? 0) + partsTotal;
}

/// Format time as "X mins/hours/days ago"
String timeAgo(DateTime? dt) {
  if (dt == null) return '-';

  final now = DateTime.now();
  var diff = now.difference(dt);
  if (diff.isNegative) diff = Duration.zero;

  if (diff.inMinutes < 1) return 'Baru saja';
  if (diff.inMinutes < 60) return '${diff.inMinutes} menit yang lalu';
  if (diff.inHours < 24) return '${diff.inHours} jam yang lalu';
  if (diff.inDays == 1) return 'Kemarin';
  if (diff.inDays < 7) return '${diff.inDays} hari yang lalu';

  final weeks = diff.inDays ~/ 7;
  if (weeks < 4) return '$weeks minggu yang lalu';

  final months = diff.inDays ~/ 30;
  if (months < 12) return '$months bulan yang lalu';

  final years = diff.inDays ~/ 365;
  return '$years tahun yang lalu';
}

/// Get Indonesian day name from weekday number
String dayNameId(int weekday) {
  switch (weekday) {
    case DateTime.monday:
      return 'Senin';
    case DateTime.tuesday:
      return 'Selasa';
    case DateTime.wednesday:
      return 'Rabu';
    case DateTime.thursday:
      return 'Kamis';
    case DateTime.friday:
      return 'Jumat';
    case DateTime.saturday:
      return 'Sabtu';
    case DateTime.sunday:
      return 'Minggu';
    default:
      return '';
  }
}

/// Get Indonesian month abbreviation
String monthNameId(int month) {
  const bulan = [
    'Jan',
    'Feb',
    'Mar',
    'Apr',
    'Mei',
    'Jun',
    'Jul',
    'Agu',
    'Sep',
    'Okt',
    'Nov',
    'Des',
  ];
  return bulan[month - 1];
}

/// Format number as Indonesian Rupiah (with thousand separators)
String rupiah(num n) {
  final s = n.toInt().toString();
  final b = StringBuffer();
  for (int i = 0; i < s.length; i++) {
    final rev = s.length - i;
    b.write(s[i]);
    if (rev > 1 && rev % 3 == 1) b.write('.');
  }
  return b.toString();
}

/// Get Indonesian status label from English status
String statusLabel(String raw) {
  switch (raw.toLowerCase()) {
    case 'completed':
      return 'Selesai';
    case 'in progress':
    case 'accept':
      return 'Process';
    case 'cancelled':
      return 'Batal';
    default:
      return 'Pending';
  }
}

/// Get status color based on status string
Color statusColor(String raw) {
  switch (raw.toLowerCase()) {
    case 'completed':
      return Colors.green;
    case 'in progress':
    case 'accept':
      return Colors.blue;
    case 'cancelled':
      return Colors.red;
    default:
      return Colors.orange;
  }
}

/// Extract workshop UUID from user object
String? pickWorkshopUuid(dynamic user) {
  if (user == null) return null;
  try {
    final ws = user.workshops as List?;
    if (ws != null && ws.isNotEmpty) {
      final first = ws.first;
      try {
        final id = (first.id ?? first['id']) as String?;
        if (id != null && id.isNotEmpty) return id;
      } catch (_) {}
    }
  } catch (_) {}

  try {
    final emp = user.employment;
    final w = emp?.workshop ?? emp['workshop'];
    if (w != null) {
      try {
        final id = (w.id ?? w['id']) as String?;
        if (id != null && id.isNotEmpty) return id;
      } catch (_) {}
    }
  } catch (_) {}

  return null;
}
