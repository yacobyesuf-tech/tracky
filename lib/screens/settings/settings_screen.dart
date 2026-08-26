import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/settings_provider.dart';
import '../../providers/expense_provider.dart';
import '../../core/theme/theme_provider.dart';
import '../../core/theme/glass_container.dart';
import '../../core/services/export_service.dart';
import '../../core/services/haptic_service.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final settingsProv = context.watch<SettingsProvider>();
    final expenseProv = context.watch<ExpenseProvider>();
    final themeProv = context.watch<ThemeProvider>();
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Settings & Security'),
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 96),
        children: [
          // Security Section
          Text(
            'Security',
            style: theme.textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: 8),
          GlassContainer(
            borderRadius: 18,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Icon(Icons.fingerprint_rounded, color: themeProv.accentColor, size: 26),
                    const SizedBox(width: 14),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Biometric App Lock',
                          style: theme.textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w600),
                        ),
                        Text(
                          'Fingerprint / Face ID on app launch',
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: isDark ? Colors.white54 : Colors.black54,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
                Switch(
                  value: settingsProv.isBiometricsEnabled,
                  activeColor: themeProv.accentColor,
                  onChanged: (val) async {
                    final ok = await settingsProv.toggleBiometrics(val);
                    if (!ok && context.mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Biometric hardware unavailable or authentication cancelled'),
                        ),
                      );
                    }
                  },
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),

          // Interactivity & Haptics
          Text(
            'Interactive UX',
            style: theme.textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: 8),
          GlassContainer(
            borderRadius: 18,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Icon(Icons.vibration_rounded, color: themeProv.accentColor, size: 26),
                    const SizedBox(width: 14),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Haptic Feedback',
                          style: theme.textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w600),
                        ),
                        Text(
                          'Tactile clicks on buttons and chart touches',
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: isDark ? Colors.white54 : Colors.black54,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
                Switch(
                  value: settingsProv.isHapticsEnabled,
                  activeColor: themeProv.accentColor,
                  onChanged: (val) => settingsProv.toggleHaptics(val),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),

          // Currency Preference
          Text(
            'Currency Symbol',
            style: theme.textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: 8),
          GlassContainer(
            borderRadius: 18,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Icon(Icons.monetization_on_outlined, color: themeProv.accentColor, size: 26),
                    const SizedBox(width: 14),
                    Text(
                      'Display Currency',
                      style: theme.textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w600),
                    ),
                  ],
                ),
                DropdownButton<String>(
                  value: settingsProv.currencySymbol,
                  dropdownColor: isDark ? const Color(0xFF1B202B) : Colors.white,
                  underline: const SizedBox(),
                  items: SettingsProvider.availableCurrencies.map((sym) {
                    return DropdownMenuItem(value: sym, child: Text(sym, style: const TextStyle(fontWeight: FontWeight.bold)));
                  }).toList(),
                  onChanged: (val) {
                    if (val != null) settingsProv.setCurrency(val);
                  },
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),

          // Export & Reports Section
          Text(
            'Data Export & Reports',
            style: theme.textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: 8),
          GlassContainer(
            borderRadius: 18,
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                // Export CSV
                ListTile(
                  contentPadding: EdgeInsets.zero,
                  leading: Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: const Color(0xFF42A5F5).withOpacity(0.2),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Icon(Icons.table_chart_rounded, color: Color(0xFF42A5F5)),
                  ),
                  title: const Text('Export to CSV', style: TextStyle(fontWeight: FontWeight.w600)),
                  subtitle: const Text('Spreadsheet compatible table with all fields'),
                  trailing: const Icon(Icons.arrow_forward_ios_rounded, size: 16),
                  onTap: () async {
                    HapticService.mediumImpact();
                    try {
                      await ExportService.exportToCsv(expenseProv.allExpenses);
                    } catch (e) {
                      if (context.mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text('Export failed: ')),
                        );
                      }
                    }
                  },
                ),
                const Divider(),

                // Export PDF
                ListTile(
                  contentPadding: EdgeInsets.zero,
                  leading: Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: const Color(0xFFEF5350).withOpacity(0.2),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Icon(Icons.picture_as_pdf_rounded, color: Color(0xFFEF5350)),
                  ),
                  title: const Text('Export to PDF Report', style: TextStyle(fontWeight: FontWeight.w600)),
                  subtitle: const Text('Formatted multi-page report with KPI cards & ledger'),
                  trailing: const Icon(Icons.arrow_forward_ios_rounded, size: 16),
                  onTap: () async {
                    HapticService.mediumImpact();
                    try {
                      await ExportService.exportToPdf(
                        expenses: expenseProv.allExpenses,
                        categoryStats: expenseProv.categoryStats,
                        totalSpent: expenseProv.totalSpent,
                        currencySymbol: settingsProv.currencySymbol,
                        dateRange: expenseProv.dateRange,
                      );
                    } catch (e) {
                      if (context.mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text('PDF generation failed: ')),
                        );
                      }
                    }
                  },
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),

          // Offline Performance & Database Status
          Text(
            'Architecture & Performance',
            style: theme.textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: 8),
          GlassContainer(
            borderRadius: 18,
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const Icon(Icons.speed_rounded, color: Color(0xFF00E676), size: 22),
                    const SizedBox(width: 10),
                    Text(
                      '100% Offline SQLite Engine',
                      style: theme.textTheme.titleSmall?.copyWith(fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Text(
                  'Unencrypted local storage with zero cloud latency. Optimized B-Tree indices provide 60fps animations for real-time chart aggregations.',
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: isDark ? Colors.white60 : Colors.black54,
                  ),
                ),
                const SizedBox(height: 12),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Total SQLite Records: ',
                      style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13),
                    ),
                    TextButton.icon(
                      icon: const Icon(Icons.refresh_rounded, size: 16),
                      label: const Text('Reload DB'),
                      onPressed: () {
                        HapticService.lightImpact();
                        expenseProv.loadData();
                      },
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
