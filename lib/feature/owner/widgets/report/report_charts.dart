import 'dart:math';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';

class ReportCharts {
  static LineChartData lineChartData({
    required List<String> labels,
    required List<double> seriesA,
    required String seriesALabel,
    required Color colorA,
    required List<double> seriesB,
    required String seriesBLabel,
    required Color colorB,
  }) {
    final maxY = [...seriesA, ...seriesB].reduce(max) * 1.2;

    SideTitles bottomTitles() => SideTitles(
          showTitles: true,
          reservedSize: 28,
          getTitlesWidget: (value, meta) {
            final i = value.toInt();
            if (i < 0 || i >= labels.length) {
              return const SizedBox.shrink();
            }
            return Padding(
              padding: const EdgeInsets.only(top: 6),
              child: Text(
                labels[i],
                style: const TextStyle(
                  fontSize: 10,
                  color: Colors.black54,
                ),
              ),
            );
          },
        );

    FlDotData dot(Color c) => FlDotData(
          show: true,
          getDotPainter: (spot, percent, barData, index) =>
              FlDotCirclePainter(radius: 3, color: c, strokeWidth: 0),
        );

    return LineChartData(
      minY: 0,
      maxY: maxY,
      gridData: FlGridData(
        show: true,
        drawVerticalLine: false,
        horizontalInterval: maxY / 4,
      ),
      titlesData: FlTitlesData(
        topTitles: const AxisTitles(
          sideTitles: SideTitles(showTitles: false),
        ),
        rightTitles: const AxisTitles(
          sideTitles: SideTitles(showTitles: false),
        ),
        leftTitles: const AxisTitles(
          sideTitles: SideTitles(showTitles: false),
        ),
        bottomTitles: AxisTitles(sideTitles: bottomTitles()),
      ),
      lineBarsData: [
        LineChartBarData(
          spots: List.generate(
            seriesA.length,
            (i) => FlSpot(i.toDouble(), seriesA[i]),
          ),
          isCurved: true,
          color: colorA,
          barWidth: 3,
          dotData: dot(colorA),
        ),
        LineChartBarData(
          spots: List.generate(
            seriesB.length,
            (i) => FlSpot(i.toDouble(), seriesB[i]),
          ),
          isCurved: true,
          color: colorB,
          barWidth: 3,
          dotData: dot(colorB),
        ),
      ],
      borderData: FlBorderData(show: false),
    );
  }

  static PieChartData donutData(Map<String, double> breakdown) {
    final entries = breakdown.entries.toList();
    final colors = [
      const Color(0xFF7C3AED),
      const Color(0xFF22C55E),
      const Color(0xFF06B6D4),
      const Color(0xFFF59E0B),
    ];

    return PieChartData(
      centerSpaceRadius: 46,
      sectionsSpace: 2,
      sections: List.generate(entries.length, (i) {
        return PieChartSectionData(
          value: entries[i].value,
          color: colors[i % colors.length],
          radius: 34,
          title: '',
        );
      }),
    );
  }

  static BarChartData barsData({
    required List<double> values,
    required List<String> labels,
    required Color color,
  }) {
    final maxY = values.reduce(max) * 1.2;

    return BarChartData(
      maxY: maxY,
      minY: 0,
      gridData: FlGridData(
        show: true,
        drawVerticalLine: false,
        horizontalInterval: maxY / 4,
      ),
      titlesData: FlTitlesData(
        topTitles: const AxisTitles(
          sideTitles: SideTitles(showTitles: false),
        ),
        leftTitles: const AxisTitles(
          sideTitles: SideTitles(showTitles: false),
        ),
        rightTitles: const AxisTitles(
          sideTitles: SideTitles(showTitles: false),
        ),
        bottomTitles: AxisTitles(
          sideTitles: SideTitles(
            showTitles: true,
            reservedSize: 26,
            getTitlesWidget: (value, meta) {
              final i = value.toInt();
              if (i < 0 || i >= labels.length) {
                return const SizedBox.shrink();
              }
              return Padding(
                padding: const EdgeInsets.only(top: 6),
                child: Text(
                  labels[i],
                  style: const TextStyle(
                    fontSize: 10,
                    color: Colors.black54,
                  ),
                ),
              );
            },
          ),
        ),
      ),
      borderData: FlBorderData(show: false),
      barGroups: List.generate(values.length, (i) {
        return BarChartGroupData(
          x: i,
          barRods: [
            BarChartRodData(
              toY: values[i],
              color: color,
              width: 14,
              borderRadius: BorderRadius.circular(6),
            ),
          ],
        );
      }),
    );
  }
}
