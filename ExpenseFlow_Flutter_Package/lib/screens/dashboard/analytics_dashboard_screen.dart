import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/expense_provider.dart';
import '../../providers/settings_provider.dart';
import '../../core/theme/theme_provider.dart';
import '../../core/theme/glass_container.dart';
import '../../models/category_stat.dart';
import '../../models/trend_point.dart';
import 'widgets/metric_card.dart';
import 'widgets/interactive_pie_chart.dart';
import 'widgets/trend_line_chart.dart';
import 'widgets/drill_down_sheet.dart';

class AnalyticsDashboardScreen extends StatelessWidget {
  const AnalyticsDashboardScreen({super.key});

  void _showDrillDown(BuildContext context, CategoryStat stat) {
    final expenseProv = Provider.of<ExpenseProvider>(context, listen: false);
    final settingsProv = Provider.of<SettingsProvider>(context, listen: false);

    final expenses = expenseProv.allExpenses.where((e) => e.categoryId == stat.categoryId).toList();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => DrillDownSheet(
        categoryStat: stat,
        itemizedExpenses: expenses,
        currencySymbol: settingsProv.currencySymbol,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final themeProv = context.watch<ThemeProvider>();
    final expenseProv = context.watch<ExpenseProvider>();
    final settingsProv = context.watch<SettingsProvider>();
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    if (expenseProv.isLoading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    final topCategory = expenseProv.topCategory;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Financial Analytics'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh_rounded),
            tooltip: 'Refresh Analytics',
            onPressed: () => expenseProv.loadData(),
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: () => expenseProv.loadData(),
        child: ListView(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 96),
          children: [
            GridView.count(
              crossAxisCount: 2,
              crossAxisSpacing: 12,
              mainAxisSpacing: 12,
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              childAspectRatio: 1.35,
              children: [
                MetricCard(
                  title: 'Total Spent',
                  value: '',
                  icon: Icons.account_balance_wallet_rounded,
                  accentColor: themeProv.accentColor,
                  subtitle: ' total entries',
                ),
                MetricCard(
                  title: 'Daily Average',
                  value: '',
                  icon: Icons.calendar_today_rounded,
                  accentColor: const Color(0xFF42A5F5),
                  subtitle: 'Smoothed run-rate',
                ),
                MetricCard(
                  title: 'Top Category',
                  value: topCategory != null ? topCategory.name : 'N/A',
                  icon: topCategory != null ? topCategory.icon : Icons.star_rounded,
                  accentColor: topCategory?.color ?? const Color(0xFFFF7043),
                  subtitle: topCategory != null
                      ? '% of expenses'
                      : 'No expenses',
                ),
                MetricCard(
                  title: 'Active Theme',
                  value: themeProv.isCustomTheme ? 'Custom' : themeProv.activePreset.name,
                  icon: Icons.palette_rounded,
                  accentColor: const Color(0xFFAB47BC),
                  subtitle: isDark ? 'Dark Glass' : 'Light Glass',
                ),
              ],
            ),
            const SizedBox(height: 20),
            GlassContainer(
              padding: const EdgeInsets.all(18),
              borderRadius: 22,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Category Allocation',
                        style: theme.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: themeProv.accentColor.withOpacity(0.15),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          'Tap slice to drill down',
                          style: TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                            color: themeProv.accentColor,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  InteractivePieChart(
                    categoryStats: expenseProv.categoryStats,
                    totalSpent: expenseProv.totalSpent,
                    currencySymbol: settingsProv.currencySymbol,
                    onCategoryTap: (stat) => _showDrillDown(context, stat),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
            TrendLineChart(
              trendPoints: expenseProv.selectedTimeFrame == TimeFrame.daily
                  ? expenseProv.dailyTrend
                  : expenseProv.selectedTimeFrame == TimeFrame.monthly
                      ? expenseProv.monthlyTrend
                      : expenseProv.yearlyTrend,
              activeTimeFrame: expenseProv.selectedTimeFrame,
              primaryColor: themeProv.primaryColor,
              accentColor: themeProv.accentColor,
              currencySymbol: settingsProv.currencySymbol,
              onTimeFrameChanged: (frame) => expenseProv.setTimeFrame(frame),
            ),
          ],
        ),
      ),
    );
  }
}
