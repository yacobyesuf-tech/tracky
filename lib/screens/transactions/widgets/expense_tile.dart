import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../../models/expense.dart';
import '../../../core/constants/categories.dart';
import '../../../core/theme/glass_container.dart';
import '../../../core/services/haptic_service.dart';

class ExpenseTile extends StatelessWidget {
  final Expense expense;
  final String currencySymbol;
  final VoidCallback onTap;
  final VoidCallback onDelete;

  const ExpenseTile({
    super.key,
    required this.expense,
    required this.currencySymbol,
    required this.onTap,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    final category = AppCategories.getById(expense.categoryId);
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Dismissible(
      key: ValueKey(expense.id ?? expense.hashCode),
      direction: DismissDirection.endToStart,
      onDismissed: (_) {
        HapticService.heavyImpact();
        onDelete();
      },
      confirmDismiss: (direction) async {
        HapticService.mediumImpact();
        return true;
      },
      background: Container(
        margin: const EdgeInsets.symmetric(vertical: 4),
        padding: const EdgeInsets.only(right: 20),
        alignment: Alignment.centerRight,
        decoration: BoxDecoration(
          color: Colors.redAccent.withOpacity(0.85),
          borderRadius: BorderRadius.circular(18),
        ),
        child: const Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            Icon(Icons.delete_sweep_rounded, color: Colors.white, size: 28),
            SizedBox(width: 8),
            Text(
              'Delete',
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 15,
              ),
            ),
          ],
        ),
      ),
      child: GlassContainer(
        margin: const EdgeInsets.symmetric(vertical: 4),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        borderRadius: 18,
        onTap: () {
          HapticService.lightImpact();
          onTap();
        },
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: category.defaultColor.withOpacity(0.18),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Icon(
                category.icon,
                color: category.defaultColor,
                size: 24,
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    expense.title,
                    style: theme.textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.w700,
                      fontSize: 15,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 3),
                  Row(
                    children: [
                      Text(
                        category.name,
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: isDark ? Colors.white60 : Colors.black54,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      const SizedBox(width: 6),
                      Text(
                        '•',
                        style: TextStyle(color: isDark ? Colors.white30 : Colors.black26),
                      ),
                      const SizedBox(width: 6),
                      Text(
                        DateFormat('MMM d').format(expense.date),
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: isDark ? Colors.white38 : Colors.black38,
                        ),
                      ),
                    ],
                  ),
                  if (expense.notes != null && expense.notes!.isNotEmpty) ...[
                    const SizedBox(height: 2),
                    Text(
                      expense.notes!,
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: isDark ? Colors.white38 : Colors.black38,
                        fontStyle: FontStyle.italic,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ],
              ),
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  '',
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w800,
                    letterSpacing: -0.5,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  expense.paymentMethod,
                  style: TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.w500,
                    color: isDark ? Colors.white38 : Colors.black38,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
