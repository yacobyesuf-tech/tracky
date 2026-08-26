import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/expense_provider.dart';
import '../../providers/settings_provider.dart';
import '../../models/expense.dart';
import 'widgets/expense_tile.dart';
import 'add_edit_expense_sheet.dart';

class TransactionListScreen extends StatelessWidget {
  const TransactionListScreen({super.key});

  void _openAddEditSheet(BuildContext context, [Expense? expense]) {
    final expenseProv = Provider.of<ExpenseProvider>(context, listen: false);
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => AddEditExpenseSheet(
        expense: expense,
        onSave: (savedExpense) {
          if (savedExpense.id == null) {
            expenseProv.addExpense(savedExpense);
          } else {
            expenseProv.updateExpense(savedExpense);
          }
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final expenseProv = context.watch<ExpenseProvider>();
    final settingsProv = context.watch<SettingsProvider>();
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final expenses = expenseProv.filteredExpenses;

    return Scaffold(
      appBar: AppBar(
        title: const Text('All Transactions'),
        actions: [
          IconButton(
            icon: const Icon(Icons.date_range_rounded),
            tooltip: 'Filter by Date Range',
            onPressed: () async {
              final picked = await showDateRangePicker(
                context: context,
                firstDate: DateTime(2020),
                lastDate: DateTime(2035),
                initialDateRange: expenseProv.dateRange,
              );
              expenseProv.setDateRange(picked);
            },
          ),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: TextField(
              onChanged: (val) => expenseProv.setSearchQuery(val),
              decoration: InputDecoration(
                hintText: 'Search items or notes...',
                prefixIcon: const Icon(Icons.search_rounded),
                suffixIcon: expenseProv.searchQuery.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear_rounded),
                        onPressed: () => expenseProv.setSearchQuery(''),
                      )
                    : null,
                contentPadding: const EdgeInsets.symmetric(vertical: 14),
              ),
            ),
          ),
          Expanded(
            child: expenses.isEmpty
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.receipt_long_rounded,
                          size: 64,
                          color: isDark ? Colors.white24 : Colors.black26,
                        ),
                        const SizedBox(height: 12),
                        Text(
                          'No transactions found',
                          style: theme.textTheme.titleMedium?.copyWith(
                            color: isDark ? Colors.white54 : Colors.black54,
                          ),
                        ),
                      ],
                    ),
                  )
                : ListView.builder(
                    padding: const EdgeInsets.fromLTRB(16, 4, 16, 96),
                    itemCount: expenses.length,
                    itemBuilder: (context, index) {
                      final exp = expenses[index];
                      return ExpenseTile(
                        expense: exp,
                        currencySymbol: settingsProv.currencySymbol,
                        onTap: () => _openAddEditSheet(context, exp),
                        onDelete: () {
                          expenseProv.deleteExpense(exp);
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text('Deleted '),
                              action: SnackBarAction(
                                label: 'UNDO',
                                onPressed: () => expenseProv.undoDelete(),
                              ),
                              behavior: SnackBarBehavior.floating,
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                            ),
                          );
                        },
                      );
                    },
                  ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _openAddEditSheet(context),
        icon: const Icon(Icons.add_rounded),
        label: const Text('Add Expense'),
      ),
    );
  }
}
