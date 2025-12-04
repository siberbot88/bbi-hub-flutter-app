import 'package:bengkel_online_flutter/core/models/service.dart';

/// Model untuk performance metrics setiap staff
class StaffPerformance {
  final String staffId;
  final String staffName;
  final String role;
  final String? photoUrl;
  
  // Metrics
  final int totalJobsCompleted;
  final num totalRevenue;
  final int activeJobs;
  
  // Detail jobs
  final List<ServiceModel> inProgressJobs;
  final List<ServiceModel> completedJobs;

  StaffPerformance({
    required this.staffId,
    required this.staffName,
    required this.role,
    this.photoUrl,
    required this.totalJobsCompleted,
    required this.totalRevenue,
    required this.activeJobs,
    required this.inProgressJobs,
    required this.completedJobs,
  });

  /// Calculate completion rate percentage
  double get completionRate {
    final total = totalJobsCompleted + activeJobs;
    if (total == 0) return 0;
    return (totalJobsCompleted / total) * 100;
  }

  /// Average revenue per completed job
  num get averageRevenuePerJob {
    if (totalJobsCompleted == 0) return 0;
    return totalRevenue / totalJobsCompleted;
  }

  /// Empty performance (for staff with no data)
  factory StaffPerformance.empty({
    required String staffId,
    required String staffName,
    required String role,
    String? photoUrl,
  }) {
    return StaffPerformance(
      staffId: staffId,
      staffName: staffName,
      role: role,
      photoUrl: photoUrl,
      totalJobsCompleted: 0,
      totalRevenue: 0,
      activeJobs: 0,
      inProgressJobs: [],
      completedJobs: [],
    );
  }
}
