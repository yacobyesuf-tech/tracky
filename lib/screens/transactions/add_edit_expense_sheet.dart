import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../../models/expense.dart';
import '../../../core/constants/categories.dart';
import '../../../core/services/haptic_service.dart';
import '../../../core/theme/glass_container.dart';

class AddEditExpenseSheet extends StatefulWidget {
  final Expense? expense;
  final Function(Expense expense) onSave;

  const AddEditExpenseSheet({
    super.key,
    this.expense,
    required this.onSave,
  });

  @override
  State<AddEditExpenseSheet> createState() => _AddEditExpenseSheetState();
}

class _AddEditExpenseSheetState extends State<AddEditExpenseSheet> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _titleController;
  late TextEditingController _amountController;
  late TextEditingController _notesController;

  late String _selectedCategoryId;
  late DateTime _selectedDate;
  late String _selectedPaymentMethod;

  final List<String> _paymentMethods = [
    'Cash',
    'Credit Card',
    'Debit Card',
    'Apple Pay',
    'Google Pay',
    'Bank Transfer',
    'PayPal',
  ];

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController(text: widget.expense?.title ?? '');
    _amountController = TextEditingController(
      text: widget.expense != null ? widget.expense!.amount.toStringAsFixed(2) : '',
    );
    _notesController = TextEditingController(text: widget.expense?.notes ?? '');
    _selectedCategoryId = widget.expense?.categoryId ?? AppCategories.items[0].id;
    _selectedDate = widget.expense?.date ?? DateTime.now();
    _selectedPaymentMethod = widget.expense?.paymentMethod ?? 'Credit Card';
  }

  @override
  void dispose() {
    _titleController.dispose();
    _amountController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  void _submit() {
    if (!_formKey.currentState!.validate()) {
      HapticService.heavyImpact();
      return;
    }

    final amount = double.tryParse(_amountController.text.replaceAll(',', '.')) ?? 0.0;
    final newExpense = Expense(
      id: widget.expense?.id,
      title: _titleController.text.trim(),
      amount: amount,
      categoryId: _selectedCategoryId,
      date: _selectedDate,
      paymentMethod: _selectedPaymentMethod,
      notes: _notesController.text.trim().isNotEmpty ? _notesController.text.trim() : null,
    );

    HapticService.mediumImpact();
    widget.onSave(newExpense);
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Padding(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
      ),
      child: Container(
        padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
        decoration: BoxDecoration(
          color: isDark ? const Color(0xFF131720) : Colors.white,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(30)),
        ),
        child: SingleChildScrollView(
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(
                  child: Container(
                    width: 44,
                    height: 5,
                    decoration: BoxDecoration(
                      color: isDark ? Colors.white24 : Colors.black26,
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  widget.expense == null ? 'New Expense' : 'Edit Expense',
                  style: theme.textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 20),
                TextFormField(
                  controller: _amountController,
                  keyboardType: const TextInputType.numberWithOptions(decimal: true),
                  style: theme.textTheme.headlineMedium?.copyWith(
                    fontWeight: FontWeight.w800,
                    color: theme.colorScheme.secondary,
                  ),
                  decoration: const InputDecoration(
                    labelText: 'Amount',
                    hintText: '0.00',
                    prefixIcon: Icon(Icons.attach_money_rounded),
                  ),
                  validator: (val) {
                    if (val == null || val.trim().isEmpty) return 'Enter an amount';
                    final parsed = double.tryParse(val.replaceAll(',', '.'));
                    if (parsed == null || parsed <= 0) return 'Enter a valid positive number';
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _titleController,
                  textCapitalization: TextCapitalization.sentences,
                  decoration: const InputDecoration(
                    labelText: 'Item / Merchant Name',
                    hintText: 'e.g. Grocery, Coffee, Uber',
                    prefixIcon: Icon(Icons.shopping_cart_outlined),
                  ),
                  validator: (val) {
                    if (val == null || val.trim().isEmpty) return 'Enter an item title';
                    return null;
                  },
                ),
                const SizedBox(height: 20),
                Text(
                  'Category',
                  style: theme.textTheme.labelLarge?.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 10),
                SizedBox(
                  height: 44,
                  child: ListView.separated(
                    scrollDirection: Axis.horizontal,
                    itemCount: AppCategories.items.length,
                    separatorBuilder: (_, __) => const SizedBox(width: 8),
                    itemBuilder: (context, index) {
                      final cat = AppCategories.items[index];
                      final isSelected = cat.id == _selectedCategoryId;
                      return GestureDetector(
                        onTap: () {
                          HapticService.selectionClick();
                          setState(() => _selectedCategoryId = cat.id);
                        },
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 200),
                          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                          decoration: BoxDecoration(
                            color: isSelected
                                ? cat.defaultColor
                                : (isDark ? Colors.white.withOpacity(0.07) : Colors.black.withOpacity(0.05)),
                            borderRadius: BorderRadius.circular(14),
                            border: Border.all(
                              color: isSelected ? Colors.white : Colors.transparent,
                              width: 1.2,
                            ),
                          ),
                          child: Row(
                            children: [
                              Icon(
                                cat.icon,
                                size: 18,
                                color: isSelected ? Colors.white : cat.defaultColor,
                              ),
                              const SizedBox(width: 6),
                              Text(
                                cat.name,
                                style: TextStyle(
                                  fontSize: 13,
                                  fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                                  color: isSelected ? Colors.white : (isDark ? Colors.white70 : Colors.black87),
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                ),
                const SizedBox(height: 20),
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton.icon(
                        icon: const Icon(Icons.calendar_today_rounded, size: 18),
                        label: Text(
                          DateFormat('MMM d, yyyy').format(_selectedDate),
                          style: const TextStyle(fontSize: 13),
                        ),
                        style: OutlinedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                        ),
                        onPressed: () async {
                          HapticService.lightImpact();
                          final picked = await showDatePicker(
                            context: context,
                            initialDate: _selectedDate,
                            firstDate: DateTime(2020),
                            lastDate: DateTime(2035),
                          );
                          if (picked != null) {
                            setState(() => _selectedDate = picked);
                          }
                        },
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: DropdownButtonFormField<String>(
                        value: _selectedPaymentMethod,
                        decoration: InputDecoration(
                          contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(14)),
                        ),
                        items: _paymentMethods.map((m) {
                          return DropdownMenuItem(value: m, child: Text(m, style: const TextStyle(fontSize: 13)));
                        }).toList(),
                        onChanged: (val) {
                          if (val != null) {
                            HapticService.selectionClick();
                            setState(() => _selectedPaymentMethod = val);
                          }
                        },
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _notesController,
                  maxLines: 2,
                  decoration: const InputDecoration(
                    labelText: 'Notes (Optional)',
                    hintText: 'Add description or receipt tag',
                    prefixIcon: Icon(Icons.notes_rounded),
                  ),
                ),
                const SizedBox(height: 24),
                SizedBox(
                  width: double.infinity,
                  height: 54,
                  child: ElevatedButton(
                    onPressed: _submit,
                    child: Text(
                      widget.expense == null ? 'Add Expense' : 'Save Changes',
                      style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
