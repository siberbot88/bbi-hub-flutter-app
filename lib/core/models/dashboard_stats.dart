class DashboardStats {
  final int servicesToday;
  final int needsAssignment;
  final int inProgress;
  final int completed;
  final List<DashboardTrend> trend;
  final List<TopService> topServices;
  final List<MechanicStat> mechanicStats;
  final CustomerStats? customerStats;

  DashboardStats({
    required this.servicesToday,
    required this.needsAssignment,
    required this.inProgress,
    required this.completed,
    required this.trend,
    required this.topServices,
    required this.mechanicStats,
    this.customerStats,
  });

  factory DashboardStats.fromJson(Map<String, dynamic> json) {
    // Debug: print what we receive
    print('DEBUG DashboardStats.fromJson received keys: ${json.keys.toList()}');
    
    // Use json directly - API already passes j['data']
    // But also handle case where full response is passed
    final Map<String, dynamic> data;
    if (json.containsKey('services_today') || json.containsKey('trend')) {
      // Direct data object
      data = json;
    } else if (json['data'] is Map<String, dynamic>) {
      // Nested in 'data'
      data = json['data'] as Map<String, dynamic>;
    } else {
      // Fallback
      data = json;
    }
    
    print('DEBUG DashboardStats parsing data keys: ${data.keys.toList()}');
    
    var trendList = <DashboardTrend>[];
    if (data['trend'] is List) {
      trendList = (data['trend'] as List)
          .map((e) => DashboardTrend.fromJson(e))
          .toList();
    }

    var topList = <TopService>[];
    if (data['top_services'] is List) {
      topList = (data['top_services'] as List)
          .map((e) => TopService.fromJson(e))
          .toList();
    }

    var mechanicList = <MechanicStat>[];
    if (data['mechanic_stats'] is List) {
      mechanicList = (data['mechanic_stats'] as List)
          .map((e) => MechanicStat.fromJson(e))
          .toList();
    }

    CustomerStats? custStats;
    if (data['customer_stats'] is Map) {
      custStats = CustomerStats.fromJson(data['customer_stats']);
    }

    return DashboardStats(
      servicesToday: _parseInt(data['services_today']),
      needsAssignment: _parseInt(data['needs_assignment']),
      inProgress: _parseInt(data['in_progress']),
      completed: _parseInt(data['completed']),
      trend: trendList,
      topServices: topList,
      mechanicStats: mechanicList,
      customerStats: custStats,
    );
  }
  
  static int _parseInt(dynamic value) {
    if (value is int) return value;
    if (value is double) return value.toInt();
    if (value is String) return int.tryParse(value) ?? 0;
    return 0;
  }
}

class DashboardTrend {
  final String date;
  final String? month; // For monthly view
  final num total;

  DashboardTrend({required this.date, this.month, required this.total});

  factory DashboardTrend.fromJson(Map<String, dynamic> json) {
    return DashboardTrend(
      date: json['date']?.toString() ?? '',
      month: json['month']?.toString(),
      total: json['total'] is num ? json['total'] : 0,
    );
  }
}

class TopService {
  final String categoryService;
  final int count;

  TopService({required this.categoryService, required this.count});

  factory TopService.fromJson(Map<String, dynamic> json) {
    return TopService(
      categoryService: json['category_service']?.toString() ?? 'Unknown',
      count: json['count'] is int ? json['count'] : 0,
    );
  }
}

/// Mechanic stats for dashboard
class MechanicStat {
  final String id;
  final String name;
  final String role;
  final int completedJobs;
  final int activeJobs;

  MechanicStat({
    required this.id,
    required this.name,
    required this.role,
    required this.completedJobs,
    required this.activeJobs,
  });

  factory MechanicStat.fromJson(Map<String, dynamic> json) {
    return MechanicStat(
      id: json['id']?.toString() ?? '',
      name: json['name']?.toString() ?? 'Unknown',
      role: json['role']?.toString() ?? 'mechanic',
      completedJobs: json['completed_jobs'] is int ? json['completed_jobs'] : 0,
      activeJobs: json['active_jobs'] is int ? json['active_jobs'] : 0,
    );
  }

  String get roleDisplayName {
    switch (role.toLowerCase()) {
      case 'senior_mechanic':
      case 'senior mechanic':
        return 'Senior Mekanik';
      case 'junior_mechanic':
      case 'junior mechanic':
        return 'Junior Mekanik';
      case 'lead_mechanic':
      case 'lead mechanic':
        return 'Lead Mekanik';
      default:
        return 'Mekanik';
    }
  }
}

/// Customer stats for dashboard
class CustomerStats {
  final int total;
  final int newThisMonth;
  final int active;

  CustomerStats({
    required this.total,
    required this.newThisMonth,
    required this.active,
  });

  factory CustomerStats.fromJson(Map<String, dynamic> json) {
    return CustomerStats(
      total: json['total'] is int ? json['total'] : 0,
      newThisMonth: json['new_this_month'] is int ? json['new_this_month'] : 0,
      active: json['active'] is int ? json['active'] : 0,
    );
  }
}
