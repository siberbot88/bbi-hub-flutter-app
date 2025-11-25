enum TimeRange { daily, weekly, monthly }

class ReportData {
  final Map<String, double> serviceBreakdown;
  final List<double> revenueTrend;
  final List<double> jobsTrend;
  final List<String> labels;

  final int jobsDone;
  final int occupancy;
  final double avgRating;
  final int revenueThisPeriod;

  final String revenueGrowthText;
  final String jobsGrowthText;
  final String occupancyGrowthText;
  final String ratingGrowthText;

  final List<double> avgQueueBars;
  final List<double> peakHourBars;
  final List<String> peakHourLabels;

  final int avgQueue;
  final String peakRange;
  final int efficiency;

  ReportData({
    required this.serviceBreakdown,
    required this.revenueTrend,
    required this.jobsTrend,
    required this.labels,
    required this.jobsDone,
    required this.occupancy,
    required this.avgRating,
    required this.revenueThisPeriod,
    required this.revenueGrowthText,
    required this.jobsGrowthText,
    required this.occupancyGrowthText,
    required this.ratingGrowthText,
    required this.avgQueueBars,
    required this.peakHourBars,
    required this.peakHourLabels,
    required this.avgQueue,
    required this.peakRange,
    required this.efficiency,
  });

  static ReportData seed() {
    return ReportData(
      serviceBreakdown: const {
        'Service Rutin': 35,
        'Perbaikan': 28,
        'Ganti Onderdil': 22,
        'Body Repair': 15,
      },
      revenueTrend: const [40, 48, 43, 60, 57, 65],
      jobsTrend: const [35, 45, 40, 50, 48, 56],
      labels: const ['Mei', 'Jun', 'Jul', 'Agu', 'Sep', 'Okt'],
      jobsDone: 22,
      occupancy: 89,
      avgRating: 4.8,
      revenueThisPeriod: 64700000,
      revenueGrowthText: '+12,5%',
      jobsGrowthText: '+8%',
      occupancyGrowthText: '−3%',
      ratingGrowthText: '+5%',
      avgQueueBars: const [9, 12, 14, 11, 18, 22, 7],
      peakHourBars: const [28, 60, 84, 76, 88, 92, 54, 32],
      peakHourLabels: const [
        '08:00',
        '10:00',
        '12:00',
        '14:00',
        '16:00',
        '18:00',
        '20:00',
        '22:00'
      ],
      avgQueue: 15,
      peakRange: '14:00 - 18:00',
      efficiency: 92,
    );
  }

  ReportData forRange(TimeRange r) {
    if (r == TimeRange.monthly) return this;

    if (r == TimeRange.weekly) {
      return ReportData(
        serviceBreakdown: serviceBreakdown,
        revenueTrend: const [8, 10, 9, 12, 11, 13],
        jobsTrend: const [5, 7, 6, 8, 9, 10],
        labels: const ['Sen', 'Sel', 'Rab', 'Kam', 'Jum', 'Sab'],
        jobsDone: 12,
        occupancy: 86,
        avgRating: 4.7,
        revenueThisPeriod: 13200000,
        revenueGrowthText: '+3,1%',
        jobsGrowthText: '+2,6%',
        occupancyGrowthText: '−1%',
        ratingGrowthText: '+1%',
        avgQueueBars: const [10, 13, 15, 12, 18, 21, 8],
        peakHourBars: const [20, 48, 61, 70, 65, 72, 40, 22],
        peakHourLabels: const [
          '08',
          '10',
          '12',
          '14',
          '16',
          '18',
          '20',
          '22'
        ],
        avgQueue: 14,
        peakRange: '12:00 - 18:00',
        efficiency: 90,
      );
    }

    return ReportData(
      serviceBreakdown: serviceBreakdown,
      revenueTrend: const [2.1, 3.4, 2.8, 3.0, 3.6, 3.1],
      jobsTrend: const [3, 5, 4, 6, 7, 6],
      labels: const ['08', '10', '12', '14', '16', '18'],
      jobsDone: 5,
      occupancy: 82,
      avgRating: 4.8,
      revenueThisPeriod: 3600000,
      revenueGrowthText: '+0,8%',
      jobsGrowthText: '+1%',
      occupancyGrowthText: '+0,5%',
      ratingGrowthText: '+0,2%',
      avgQueueBars: const [4, 6, 8, 12, 10, 6, 2],
      peakHourBars: const [6, 14, 22, 20, 18, 8, 4, 2],
      peakHourLabels: const [
        '08',
        '10',
        '12',
        '14',
        '16',
        '18',
        '20',
        '22'
      ],
      avgQueue: 12,
      peakRange: '12:00 - 16:00',
      efficiency: 91,
    );
  }
}
