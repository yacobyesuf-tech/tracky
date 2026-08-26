import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import '../../../models/trend_point.dart';
import '../../../core/services/haptic_service.dart';
import '../../../core/theme/glass_container.dart';

class TrendLineChart extends StatelessWidget {
  final List<TrendPoint> trendPoints;
  final TimeFrame activeTimeFrame;
  final Color primaryColor;
  final Color accentColor;
  final String currencySymbol;
  final Function(TimeFrame frame) onTimeFrameChanged;

  const TrendLineChart({
    super.key,
    required this.trendPoints,
    required this.activeTimeFrame,
    required this.primaryColor,
    required this.accentColor,
    required this.currencySymbol,
    required this.onTimeFrameChanged,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    final spots = _generateSpots();
    final maxY = _calculateMaxY();

    return GlassContainer(
      padding: const EdgeInsets.all(16),
      borderRadius: 22,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Spending Trend',
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w700,
                ),
              ),
              _buildTimeframeSelector(isDark),
            ],
          ),
          const SizedBox(height: 24),
          SizedBox(
            height: 190,
            child: trendPoints.isEmpty
                ? Center(
                    child: Text(
                      'No trend data recorded yet.',
                      style: theme.textTheme.bodyMedium?.copyWith(color: Colors.grey),
                    ),
                  )
                : LineChart(
                    LineChartData(
                      gridData: FlGridData(
                        show: true,
                        drawVerticalLine: false,
                        horizontalInterval: maxY > 0 ? (maxY / 4) : 1,
                        getDrawingHorizontalLine: (value) => FlLine(
                          color: isDark ? Colors.white10 : Colors.black12,
                          strokeWidth: 1,
                          dashArray: [5, 5],
                        ),
                      ),
                      titlesData: FlTitlesData(
                        show: true,
                        rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                        topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                        leftTitles: AxisTitles(
                          sideTitles: SideTitles(
                            showTitles: true,
                            reservedSize: 42,
                            interval: maxY > 0 ? (maxY / 3) : 1,
                            getTitlesWidget: (value, meta) {
                              if (value == 0) return const SizedBox();
                              final formatted = value >= 1000 ? 'k' : value.toInt().toString();
                              return Text(
                                '',
                                style: TextStyle(
                                  fontSize: 10,
                                  color: isDark ? Colors.white38 : Colors.black38,
                                  fontWeight: FontWeight.w600,
                                ),
                              );
                            },
                          ),
                        ),
                        bottomTitles: AxisTitles(
                          sideTitles: SideTitles(
                            showTitles: true,
                            reservedSize: 28,
                            interval: 1,
                            getTitlesWidget: (value, meta) {
                              final int index = value.toInt();
                              if (index < 0 || index >= trendPoints.length) {
                                return const SizedBox();
                              }
                              if (trendPoints.length > 7 && index % 2 != 0) {
                                return const SizedBox();
                              }
                              return Padding(
                                padding: const EdgeInsets.only(top: 8.0),
                                child: Text(
                                  trendPoints[index].label,
                                  style: TextStyle(
                                    fontSize: 10,
                                    color: isDark ? Colors.white54 : Colors.black54,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              );
                            },
                          ),
                        ),
                      ),
                      borderData: FlBorderData(show: false),
                      minX: 0,
                      maxX: (trendPoints.length - 1).toDouble().clamp(0, double.infinity),
                      minY: 0,
                      maxY: maxY * 1.15,
                      lineTouchData: LineTouchData(
                        handleBuiltInTouches: true,
                        touchTooltipData: LineTouchTooltipData(
                          getTooltipItems: (List<LineBarSpot> touchedSpots) {
                            return touchedSpots.map((spot) {
                              final pt = trendPoints[spot.x.toInt()];
                              return LineTooltipItem(
                                '\n',
                                TextStyle(
                                  color: accentColor,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 12,
                                ),
                              );
                            }).toList();
                          },
                        ),
                      ),
                      lineBarsData: [
                        LineChartBarData(
                          spots: spots,
                          isCurved: true,
                          curveSmoothness: 0.35,
                          color: accentColor,
                          barWidth: 3.5,
                          isStrokeCapRound: true,
                          dotData: FlDotData(
                            show: trendPoints.length <= 10,
                            getDotPainter: (spot, percent, barData, index) {
                              return FlDotCirclePainter(
                                radius: 4,
                                color: accentColor,
                                strokeWidth: 2,
                                strokeColor: isDark ? Colors.black : Colors.white,
                              );
                            },
                          ),
                          belowBarData: BarAreaData(
                            show: true,
                            gradient: LinearGradient(
                              begin: Alignment.topCenter,
                              end: Alignment.bottomCenter,
                              colors: [
                                accentColor.withOpacity(0.38),
                                accentColor.withOpacity(0.0),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                    duration: const Duration(milliseconds: 500),
                    curve: Curves.easeInOutCubic,
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildTimeframeSelector(bool isDark) {
    return Container(
      decoration: BoxDecoration(
        color: isDark ? Colors.white.withOpacity(0.07) : Colors.black.withOpacity(0.05),
        borderRadius: BorderRadius.circular(12),
      ),
      padding: const EdgeInsets.all(3),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          _buildPill(TimeFrame.daily, 'Daily'),
          _buildPill(TimeFrame.monthly, 'Monthly'),
          _buildPill(TimeFrame.yearly, 'Yearly'),
        ],
      ),
    );
  }

  Widget _buildPill(TimeFrame frame, String text) {
    final isSelected = activeTimeFrame == frame;
    return GestureDetector(
      onTap: () {
        HapticService.selectionClick();
        onTimeFrameChanged(frame);
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
        decoration: BoxDecoration(
          color: isSelected ? accentColor : Colors.transparent,
          borderRadius: BorderRadius.circular(9),
        ),
        child: Text(
          text,
          style: TextStyle(
            fontSize: 11,
            fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
            color: isSelected ? Colors.black : null,
          ),
        ),
      ),
    );
  }

  List<FlSpot> _generateSpots() {
    return List.generate(trendPoints.length, (i) {
      return FlSpot(i.toDouble(), trendPoints[i].amount);
    });
  }

  double _calculateMaxY() {
    if (trendPoints.isEmpty) return 100;
    double max = 0;
    for (final pt in trendPoints) {
      if (pt.amount > max) max = pt.amount;
    }
    return max == 0 ? 100 : max;
  }
}
