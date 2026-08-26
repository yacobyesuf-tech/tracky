import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import '../../../models/category_stat.dart';
import '../../../core/services/haptic_service.dart';
import '../../../core/theme/glass_container.dart';

class InteractivePieChart extends StatefulWidget {
  final List<CategoryStat> categoryStats;
  final double totalSpent;
  final String currencySymbol;
  final Function(CategoryStat stat) onCategoryTap;

  const InteractivePieChart({
    super.key,
    required this.categoryStats,
    required this.totalSpent,
    required this.currencySymbol,
    required this.onCategoryTap,
  });

  @override
  State<InteractivePieChart> createState() => _InteractivePieChartState();
}

class _InteractivePieChartState extends State<InteractivePieChart> {
  int touchedIndex = -1;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    if (widget.categoryStats.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 32),
          child: Text(
            'No expense data in this period.',
            style: theme.textTheme.bodyMedium?.copyWith(
              color: isDark ? Colors.white54 : Colors.black45,
            ),
          ),
        ),
      );
    }

    return Column(
      children: [
        SizedBox(
          height: 230,
          child: Stack(
            alignment: Alignment.center,
            children: [
              PieChart(
                PieChartData(
                  pieTouchData: PieTouchData(
                    touchCallback: (FlTouchEvent event, pieTouchResponse) {
                      setState(() {
                        if (!event.isInterestedForInteractions ||
                            pieTouchResponse == null ||
                            pieTouchResponse.touchedSection == null) {
                          touchedIndex = -1;
                          return;
                        }
                        final index = pieTouchResponse.touchedSection!.touchedSectionIndex;
                        if (index >= 0 && index < widget.categoryStats.length) {
                          if (touchedIndex != index) {
                            HapticService.selectionClick();
                            touchedIndex = index;
                          }
                          if (event is FlTapUpEvent) {
                            HapticService.mediumImpact();
                            widget.onCategoryTap(widget.categoryStats[index]);
                          }
                        }
                      });
                    },
                  ),
                  borderData: FlBorderData(show: false),
                  sectionsSpace: 3,
                  centerSpaceRadius: 58,
                  sections: _buildSections(isDark),
                ),
                swapAnimationDuration: const Duration(milliseconds: 650),
                swapAnimationCurve: Curves.easeInOutCubic,
              ),
              GestureDetector(
                onTap: () {
                  if (touchedIndex >= 0 && touchedIndex < widget.categoryStats.length) {
                    widget.onCategoryTap(widget.categoryStats[touchedIndex]);
                  }
                },
                child: GlassContainer(
                  width: 104,
                  height: 104,
                  borderRadius: 52,
                  padding: const EdgeInsets.all(8),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        touchedIndex >= 0 && touchedIndex < widget.categoryStats.length
                            ? widget.categoryStats[touchedIndex].name
                            : 'Total Spent',
                        style: theme.textTheme.labelSmall?.copyWith(
                          color: isDark ? Colors.white60 : Colors.black54,
                          fontWeight: FontWeight.w500,
                        ),
                        textAlign: TextAlign.center,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 2),
                      Text(
                        touchedIndex >= 0 && touchedIndex < widget.categoryStats.length
                            ? ''
                            : '',
                        style: theme.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w800,
                          color: touchedIndex >= 0 && touchedIndex < widget.categoryStats.length
                              ? widget.categoryStats[touchedIndex].color
                              : (isDark ? Colors.white : Colors.black87),
                        ),
                      ),
                      if (touchedIndex >= 0 && touchedIndex < widget.categoryStats.length)
                        Text(
                          '%',
                          style: theme.textTheme.labelSmall?.copyWith(
                            color: widget.categoryStats[touchedIndex].color,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          alignment: WrapAlignment.center,
          children: widget.categoryStats.map((stat) {
            final isSelected = widget.categoryStats.indexOf(stat) == touchedIndex;
            return InkWell(
              onTap: () {
                HapticService.lightImpact();
                widget.onCategoryTap(stat);
              },
              borderRadius: BorderRadius.circular(20),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 250),
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: isSelected
                      ? stat.color.withOpacity(0.25)
                      : (isDark ? Colors.white.withOpacity(0.06) : Colors.black.withOpacity(0.04)),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: isSelected ? stat.color : Colors.transparent,
                    width: 1.2,
                  ),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      width: 10,
                      height: 10,
                      decoration: BoxDecoration(
                        color: stat.color,
                        shape: BoxShape.circle,
                      ),
                    ),
                    const SizedBox(width: 6),
                    Text(
                      ' (%)',
                      style: theme.textTheme.bodySmall?.copyWith(
                        fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
            );
          }).toList(),
        ),
      ],
    );
  }

  List<PieChartSectionData> _buildSections(bool isDark) {
    return List.generate(widget.categoryStats.length, (i) {
      final stat = widget.categoryStats[i];
      final isTouched = i == touchedIndex;
      final double radius = isTouched ? 42.0 : 32.0;

      return PieChartSectionData(
        color: stat.color,
        value: stat.totalAmount,
        title: '%',
        radius: radius,
        titleStyle: TextStyle(
          fontSize: isTouched ? 14 : 11,
          fontWeight: FontWeight.bold,
          color: Colors.white,
          shadows: const [
            Shadow(color: Colors.black45, blurRadius: 4),
          ],
        ),
        badgePositionPercentageOffset: .98,
      );
    });
  }
}
