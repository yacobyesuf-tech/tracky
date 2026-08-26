import 'package:flutter/material.dart';
import '../models/expense.dart';
import '../models/category_stat.dart';
import '../models/trend_point.dart';
import '../core/services/database_service.dart';
import '../core/services/haptic_service.dart';

class ExpenseProvider extends ChangeNotifier {
  final DatabaseService _db = DatabaseService.instance;

  List<Expense> _allExpenses = [];
  List<CategoryStat> _categoryStats = [];
  List<TrendPoint> _dailyTrend = [];
  List<TrendPoint> _monthlyTrend = [];
  List<TrendPoint> _yearlyTrend = [];

  TimeFrame _selectedTimeFrame = TimeFrame.monthly;
  String? _selectedCategoryFilter;
  List<Expense> _drillDownExpenses = [];

  DateTimeRange? _dateRange;
  String _searchQuery = '';
  bool _isLoading = true;
  Expense? _recentlyDeletedExpense;

  // Getters
  List<Expense> get allExpenses => _allExpenses;
  List<CategoryStat> get categoryStats => _categoryStats;
  List<TrendPoint> get dailyTrend => _dailyTrend;
  List<TrendPoint> get monthlyTrend => _monthlyTrend;
  List<TrendPoint> get yearlyTrend => _yearlyTrend;
  TimeFrame get selectedTimeFrame => _selectedTimeFrame;
  String? get selectedCategoryFilter => _selectedCategoryFilter;
  List<Expense> get drillDownExpenses => _drillDownExpenses;
  DateTimeRange? get dateRange => _dateRange;
  String get searchQuery => _searchQuery;
  bool get isLoading => _isLoading;

  List<Expense> get filteredExpenses {
    return _allExpenses.where((exp) {
      final matchesSearch = _searchQuery.isEmpty ||
          exp.title.toLowerCase().contains(_searchQuery.toLowerCase()) ||
          (exp.notes != null && exp.notes!.toLowerCase().contains(_searchQuery.toLowerCase()));

      final matchesDate = _dateRange == null ||
          (exp.date.isAfter(_dateRange!.start.subtract(const Duration(days: 1))) &&
              exp.date.isBefore(_dateRange!.end.add(const Duration(days: 1))));

      final matchesCategory = _selectedCategoryFilter == null ||
          exp.categoryId == _selectedCategoryFilter;

      return matchesSearch && matchesDate && matchesCategory;
    }).toList();
  }

  double get totalSpent {
    return _categoryStats.fold(0.0, (sum, cat) => sum + cat.totalAmount);
  }

  double get dailyAverage {
    if (_allExpenses.isEmpty) return 0.0;
    final now = DateTime.now();
    final firstDate = _allExpenses.last.date;
    final days = now.difference(firstDate).inDays.clamp(1, 365);
    final total = _allExpenses.fold(0.0, (sum, exp) => sum + exp.amount);
    return total / days;
  }

  CategoryStat? get topCategory {
    if (_categoryStats.isEmpty) return null;
    return _categoryStats.reduce((curr, next) => curr.totalAmount > next.totalAmount ? curr : next);
  }

  int get totalTransactionsCount => _allExpenses.length;

  ExpenseProvider() {
    loadData();
  }

  Future<void> loadData() async {
    _isLoading = true;
    notifyListeners();

    try {
      _allExpenses = await _db.getAllExpenses();

      final now = DateTime.now();
      final startOfRange = _dateRange?.start ?? now.subtract(const Duration(days: 90));
      final endOfRange = _dateRange?.end ?? now;

      // Aggregations
      _categoryStats = await _db.getCategoryAggregates(startOfRange, endOfRange);
      _dailyTrend = await _db.getDailyTrend(now.subtract(const Duration(days: 14)), now);
      _monthlyTrend = await _db.getMonthlyTrend(now.year);
      _yearlyTrend = await _db.getYearlyTrend();

      if (_selectedCategoryFilter != null) {
        _drillDownExpenses = await _db.getExpensesByCategory(
          _selectedCategoryFilter!,
          _dateRange?.start,
          _dateRange?.end,
        );
      }
    } catch (_) {}

    _isLoading = false;
    notifyListeners();
  }

  Future<void> addExpense(Expense expense) async {
    HapticService.mediumImpact();
    await _db.insertExpense(expense);
    await loadData();
  }

  Future<void> updateExpense(Expense expense) async {
    HapticService.lightImpact();
    await _db.updateExpense(expense);
    await loadData();
  }

  Future<void> deleteExpense(Expense expense) async {
    HapticService.heavyImpact();
    _recentlyDeletedExpense = expense;
    if (expense.id != null) {
      await _db.deleteExpense(expense.id!);
      await loadData();
    }
  }

  Future<void> undoDelete() async {
    if (_recentlyDeletedExpense != null) {
      HapticService.mediumImpact();
      await _db.insertExpense(_recentlyDeletedExpense!);
      _recentlyDeletedExpense = null;
      await loadData();
    }
  }

  void setTimeFrame(TimeFrame frame) {
    _selectedTimeFrame = frame;
    HapticService.selectionClick();
    notifyListeners();
  }

  Future<void> selectCategoryForDrillDown(String? categoryId) async {
    _selectedCategoryFilter = categoryId;
    HapticService.lightImpact();
    if (categoryId != null) {
      _drillDownExpenses = await _db.getExpensesByCategory(
        categoryId,
        _dateRange?.start,
        _dateRange?.end,
      );
    } else {
      _drillDownExpenses = [];
    }
    notifyListeners();
  }

  void setSearchQuery(String query) {
    _searchQuery = query;
    notifyListeners();
  }

  void setDateRange(DateTimeRange? range) {
    _dateRange = range;
    loadData();
  }
}
