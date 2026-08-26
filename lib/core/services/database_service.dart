import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart' as p;
import 'package:intl/intl.dart';
import '../constants/app_constants.dart';
import '../constants/categories.dart';
import '../../models/expense.dart';
import '../../models/category_stat.dart';
import '../../models/trend_point.dart';

class DatabaseService {
  static final DatabaseService instance = DatabaseService._internal();
  DatabaseService._internal();

  Database? _db;

  Future<Database> get database async {
    if (_db != null) return _db!;
    _db = await _initDatabase();
    return _db!;
  }

  Future<Database> _initDatabase() async {
    final dbPath = await getDatabasesPath();
    final path = p.join(dbPath, AppConstants.dbName);

    return await openDatabase(
      path,
      version: AppConstants.dbVersion,
      onCreate: (db, version) async {
        // High-Performance Unencrypted Schema for 60fps local speed
        await db.execute('''
          CREATE TABLE  (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            title TEXT NOT NULL,
            amount REAL NOT NULL,
            category_id TEXT NOT NULL,
            date TEXT NOT NULL,
            payment_method TEXT NOT NULL,
            notes TEXT
          )
        ''');

        // B-Tree Indexes for zero-latency queries
        await db.execute(
          'CREATE INDEX idx_expenses_date ON (date DESC)',
        );
        await db.execute(
          'CREATE INDEX idx_expenses_category ON (category_id)',
        );
        await db.execute(
          'CREATE INDEX idx_expenses_amount ON (amount)',
        );

        // Seed with realistic initial data
        await _seedInitialData(db);
      },
    );
  }

  Future<void> _seedInitialData(Database db) async {
    final now = DateTime.now();
    final sampleExpenses = [
      Expense(
        title: 'Whole Foods Grocery',
        amount: 142.50,
        categoryId: 'food',
        date: now.subtract(const Duration(hours: 4)),
        paymentMethod: 'Credit Card',
        notes: 'Organic groceries & fresh produce',
      ),
      Expense(
        title: 'Monthly Apartment Rent',
        amount: 1450.00,
        categoryId: 'housing',
        date: now.subtract(const Duration(days: 2)),
        paymentMethod: 'Bank Transfer',
        notes: 'Monthly lease payment',
      ),
      Expense(
        title: 'Shell Gas Station',
        amount: 58.20,
        categoryId: 'transport',
        date: now.subtract(const Duration(days: 3)),
        paymentMethod: 'Debit Card',
        notes: 'Full tank fuel',
      ),
      Expense(
        title: 'Apple Store - USB-C Hub',
        amount: 79.00,
        categoryId: 'shopping',
        date: now.subtract(const Duration(days: 5)),
        paymentMethod: 'Apple Pay',
        notes: 'Hardware accessories',
      ),
      Expense(
        title: 'IMAX Cinema Tickets',
        amount: 38.00,
        categoryId: 'entertainment',
        date: now.subtract(const Duration(days: 7)),
        paymentMethod: 'Credit Card',
        notes: 'Weekend movie with friends',
      ),
      Expense(
        title: 'Electricity & Water Bill',
        amount: 115.40,
        categoryId: 'utilities',
        date: now.subtract(const Duration(days: 10)),
        paymentMethod: 'Direct Debit',
        notes: 'Utility bill',
      ),
      Expense(
        title: 'Dental Checkup & Cleaning',
        amount: 160.00,
        categoryId: 'health',
        date: now.subtract(const Duration(days: 14)),
        paymentMethod: 'Credit Card',
        notes: 'Routine dental visit',
      ),
      Expense(
        title: 'Udemy Mobile Architecture Course',
        amount: 24.99,
        categoryId: 'education',
        date: now.subtract(const Duration(days: 18)),
        paymentMethod: 'PayPal',
        notes: 'Advanced Flutter deep dive',
      ),
      Expense(
        title: 'Index Fund Investment (S&P 500)',
        amount: 500.00,
        categoryId: 'investment',
        date: now.subtract(const Duration(days: 22)),
        paymentMethod: 'Bank Transfer',
        notes: 'Monthly DCA investment',
      ),
      Expense(
        title: 'Starbucks Coffee & Pastry',
        amount: 12.75,
        categoryId: 'food',
        date: now.subtract(const Duration(days: 25)),
        paymentMethod: 'Apple Pay',
        notes: 'Cold brew & croissant',
      ),
      Expense(
        title: 'Uber Ride Downtown',
        amount: 29.30,
        categoryId: 'transport',
        date: now.subtract(const Duration(days: 35)),
        paymentMethod: 'Credit Card',
      ),
      Expense(
        title: 'Nike Air Running Shoes',
        amount: 135.00,
        categoryId: 'shopping',
        date: now.subtract(const Duration(days: 45)),
        paymentMethod: 'Debit Card',
      ),
      Expense(
        title: 'Italian Bistro Dinner',
        amount: 92.40,
        categoryId: 'food',
        date: now.subtract(const Duration(days: 60)),
        paymentMethod: 'Credit Card',
      ),
      Expense(
        title: 'Spotify & Netflix Subscriptions',
        amount: 27.98,
        categoryId: 'entertainment',
        date: now.subtract(const Duration(days: 75)),
        paymentMethod: 'Credit Card',
      ),
      Expense(
        title: 'Annual Car Insurance',
        amount: 680.00,
        categoryId: 'transport',
        date: now.subtract(const Duration(days: 90)),
        paymentMethod: 'Bank Transfer',
      ),
    ];

    final batch = db.batch();
    for (final exp in sampleExpenses) {
      batch.insert(AppConstants.tableExpenses, exp.toMap());
    }
    await batch.commit(noResult: true);
  }

  // CRUD Operations
  Future<int> insertExpense(Expense expense) async {
    final db = await database;
    return await db.insert(
      AppConstants.tableExpenses,
      expense.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<int> updateExpense(Expense expense) async {
    final db = await database;
    return await db.update(
      AppConstants.tableExpenses,
      expense.toMap(),
      where: 'id = ?',
      whereArgs: [expense.id],
    );
  }

  Future<int> deleteExpense(int id) async {
    final db = await database;
    return await db.delete(
      AppConstants.tableExpenses,
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  Future<List<Expense>> getAllExpenses() async {
    final db = await database;
    final maps = await db.query(
      AppConstants.tableExpenses,
      orderBy: 'date DESC',
    );
    return maps.map((m) => Expense.fromMap(m)).toList();
  }

  Future<List<Expense>> getExpensesByDateRange(DateTime start, DateTime end) async {
    final db = await database;
    final startStr = start.toIso8601String();
    final endStr = end.toIso8601String();

    final maps = await db.query(
      AppConstants.tableExpenses,
      where: 'date >= ? AND date <= ?',
      whereArgs: [startStr, endStr],
      orderBy: 'date DESC',
    );
    return maps.map((m) => Expense.fromMap(m)).toList();
  }

  // Drill-Down: Get expenses for specific category within range
  Future<List<Expense>> getExpensesByCategory(
    String categoryId,
    DateTime? start,
    DateTime? end,
  ) async {
    final db = await database;
    String where = 'category_id = ?';
    List<dynamic> args = [categoryId];

    if (start != null && end != null) {
      where += ' AND date >= ? AND date <= ?';
      args.addAll([start.toIso8601String(), end.toIso8601String()]);
    }

    final maps = await db.query(
      AppConstants.tableExpenses,
      where: where,
      whereArgs: args,
      orderBy: 'date DESC',
    );
    return maps.map((m) => Expense.fromMap(m)).toList();
  }

  // Aggregated Category Stats for Animated Pie Chart
  Future<List<CategoryStat>> getCategoryAggregates(DateTime start, DateTime end) async {
    final db = await database;
    final startStr = start.toIso8601String();
    final endStr = end.toIso8601String();

    // 1. Total Spend in Range
    final totalResult = await db.rawQuery(
      'SELECT SUM(amount) as total FROM  WHERE date >= ? AND date <= ?',
      [startStr, endStr],
    );
    final double totalSpend = (totalResult.first['total'] as num?)?.toDouble() ?? 0.0;

    if (totalSpend == 0) return [];

    // 2. Group by Category
    final result = await db.rawQuery('''
      SELECT category_id, SUM(amount) as cat_total, COUNT(id) as cat_count
      FROM 
      WHERE date >= ? AND date <= ?
      GROUP BY category_id
      ORDER BY cat_total DESC
    ''', [startStr, endStr]);

    return result.map((row) {
      final catId = row['category_id'] as String;
      final catTotal = (row['cat_total'] as num).toDouble();
      final catCount = row['cat_count'] as int;
      final percentage = (catTotal / totalSpend) * 100.0;
      final categoryItem = AppCategories.getById(catId);

      return CategoryStat(
        categoryId: catId,
        name: categoryItem.name,
        totalAmount: catTotal,
        percentage: percentage,
        transactionCount: catCount,
        color: categoryItem.defaultColor,
        icon: categoryItem.icon,
      );
    }).toList();
  }

  // Daily Trend Line Data (Last N days or within range)
  Future<List<TrendPoint>> getDailyTrend(DateTime start, DateTime end) async {
    final db = await database;
    final startStr = DateFormat('yyyy-MM-dd').format(start);
    final endStr = DateFormat('yyyy-MM-dd').format(end);

    final result = await db.rawQuery('''
      SELECT substr(date, 1, 10) as day_str, SUM(amount) as day_total
      FROM 
      WHERE substr(date, 1, 10) >= ? AND substr(date, 1, 10) <= ?
      GROUP BY day_str
      ORDER BY day_str ASC
    ''', [startStr, endStr]);

    return result.map((row) {
      final dayStr = row['day_str'] as String;
      final date = DateTime.tryParse(dayStr) ?? DateTime.now();
      final total = (row['day_total'] as num).toDouble();
      return TrendPoint(
        label: DateFormat('d MMM').format(date),
        date: date,
        amount: total,
      );
    }).toList();
  }

  // Monthly Trend Line Data
  Future<List<TrendPoint>> getMonthlyTrend(int year) async {
    final db = await database;
    final yearStr = year.toString();

    final result = await db.rawQuery('''
      SELECT substr(date, 1, 7) as month_str, SUM(amount) as month_total
      FROM 
      WHERE substr(date, 1, 4) = ?
      GROUP BY month_str
      ORDER BY month_str ASC
    ''', [yearStr]);

    return result.map((row) {
      final monthStr = row['month_str'] as String;
      final date = DateTime.tryParse('-01') ?? DateTime.now();
      final total = (row['month_total'] as num).toDouble();
      return TrendPoint(
        label: DateFormat('MMM').format(date),
        date: date,
        amount: total,
      );
    }).toList();
  }

  // Yearly Trend Line Data
  Future<List<TrendPoint>> getYearlyTrend() async {
    final db = await database;
    final result = await db.rawQuery('''
      SELECT substr(date, 1, 4) as year_str, SUM(amount) as year_total
      FROM 
      GROUP BY year_str
      ORDER BY year_str ASC
    ''');

    return result.map((row) {
      final yearStr = row['year_str'] as String;
      final date = DateTime.tryParse('-01-01') ?? DateTime.now();
      final total = (row['year_total'] as num).toDouble();
      return TrendPoint(
        label: yearStr,
        date: date,
        amount: total,
      );
    }).toList();
  }

  Future<int> getRecordCount() async {
    final db = await database;
    final res = await db.rawQuery('SELECT COUNT(*) as count FROM ');
    return (res.first['count'] as int?) ?? 0;
  }
}
