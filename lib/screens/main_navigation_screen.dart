import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../core/theme/theme_provider.dart';
import '../core/services/haptic_service.dart';
import '../providers/expense_provider.dart';
import 'dashboard/analytics_dashboard_screen.dart';
import 'transactions/transaction_list_screen.dart';
import 'transactions/add_edit_expense_sheet.dart';
import 'theme/theme_customizer_screen.dart';
import 'settings/settings_screen.dart';

class MainNavigationScreen extends StatefulWidget {
  const MainNavigationScreen({super.key});

  @override
  State<MainNavigationScreen> createState() => _MainNavigationScreenState();
}

class _MainNavigationScreenState extends State<MainNavigationScreen> {
  int _currentIndex = 0;

  final List<Widget> _screens = const [
    AnalyticsDashboardScreen(),
    TransactionListScreen(),
    ThemeCustomizerScreen(),
    SettingsScreen(),
  ];

  void _openAddExpenseModal() {
    HapticService.mediumImpact();
    final expenseProv = Provider.of<ExpenseProvider>(context, listen: false);
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => AddEditExpenseSheet(
        onSave: (expense) {
          expenseProv.addExpense(expense);
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final themeProv = context.watch<ThemeProvider>();
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      body: Stack(
        children: [
          IndexedStack(
            index: _currentIndex,
            children: _screens,
          ),

          // Glassmorphic Floating Bottom Bar
          Positioned(
            left: 16,
            right: 16,
            bottom: 16,
            child: ClipRRect(
              borderRadius: BorderRadius.circular(26),
              child: BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 18, sigmaY: 18),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
                  decoration: BoxDecoration(
                    color: isDark
                        ? const Color(0xFF10141D).withOpacity(0.85)
                        : Colors.white.withOpacity(0.88),
                    borderRadius: BorderRadius.circular(26),
                    border: Border.all(
                      color: isDark ? Colors.white.withOpacity(0.12) : Colors.black.withOpacity(0.08),
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.2),
                        blurRadius: 20,
                        offset: const Offset(0, 8),
                      ),
                    ],
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      _buildNavItem(0, Icons.pie_chart_rounded, 'Analytics', themeProv.accentColor),
                      _buildNavItem(1, Icons.receipt_long_rounded, 'Ledger', themeProv.accentColor),
                      
                      // Central Quick Add Action Button
                      GestureDetector(
                        onTap: _openAddExpenseModal,
                        child: Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: themeProv.accentColor,
                            shape: BoxShape.circle,
                            boxShadow: [
                              BoxShadow(
                                color: themeProv.accentColor.withOpacity(0.45),
                                blurRadius: 12,
                                spreadRadius: 2,
                              ),
                            ],
                          ),
                          child: Icon(
                            Icons.add_rounded,
                            color: isDark ? Colors.black : Colors.white,
                            size: 26,
                          ),
                        ),
                      ),

                      _buildNavItem(2, Icons.palette_rounded, 'Themes', themeProv.accentColor),
                      _buildNavItem(3, Icons.settings_rounded, 'Settings', themeProv.accentColor),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNavItem(int index, IconData icon, String label, Color accentColor) {
    final isSelected = _currentIndex == index;
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return InkWell(
      onTap: () {
        HapticService.selectionClick();
        setState(() => _currentIndex = index);
      },
      borderRadius: BorderRadius.circular(16),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? accentColor.withOpacity(0.18) : Colors.transparent,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              size: 22,
              color: isSelected ? accentColor : (isDark ? Colors.white54 : Colors.black45),
            ),
            const SizedBox(height: 3),
            Text(
              label,
              style: TextStyle(
                fontSize: 10,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                color: isSelected ? accentColor : (isDark ? Colors.white54 : Colors.black45),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
