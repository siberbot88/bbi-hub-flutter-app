class DashboardStats {
  final List<DashboardTrend> trend;
  final List<TopService> topServices;

  DashboardStats({
    required this.trend,
    required this.topServices,
  });

  factory DashboardStats.fromJson(Map<String, dynamic> json) {
    var trendList = <DashboardTrend>[];
    if (json['trend'] is List) {
      trendList = (json['trend'] as List)
          .map((e) => DashboardTrend.fromJson(e))
          .toList();
    }

    var topList = <TopService>[];
    if (json['top_services'] is List) {
      topList = (json['top_services'] as List)
          .map((e) => TopService.fromJson(e))
          .toList();
    }

    return DashboardStats(
      trend: trendList,
      topServices: topList,
    );
  }
}

class DashboardTrend {
  final String date;
  final num total;

  DashboardTrend({required this.date, required this.total});

  factory DashboardTrend.fromJson(Map<String, dynamic> json) {
    return DashboardTrend(
      date: json['date']?.toString() ?? '',
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
