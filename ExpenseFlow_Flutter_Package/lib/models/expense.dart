class Expense {
  final int? id;
  final String title;
  final double amount;
  final String categoryId;
  final DateTime date;
  final String paymentMethod;
  final String? notes;

  const Expense({
    this.id,
    required this.title,
    required this.amount,
    required this.categoryId,
    required this.date,
    this.paymentMethod = 'Cash',
    this.notes,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'amount': amount,
      'category_id': categoryId,
      'date': date.toIso8601String(),
      'payment_method': paymentMethod,
      'notes': notes ?? '',
    };
  }

  factory Expense.fromMap(Map<String, dynamic> map) {
    return Expense(
      id: map['id'] as int?,
      title: map['title'] as String? ?? 'Untitled',
      amount: (map['amount'] as num?)?.toDouble() ?? 0.0,
      categoryId: map['category_id'] as String? ?? 'other',
      date: DateTime.tryParse(map['date'] as String? ?? '') ?? DateTime.now(),
      paymentMethod: map['payment_method'] as String? ?? 'Cash',
      notes: (map['notes'] as String?)?.isNotEmpty == true ? map['notes'] as String : null,
    );
  }

  Expense copyWith({
    int? id,
    String? title,
    double? amount,
    String? categoryId,
    DateTime? date,
    String? paymentMethod,
    String? notes,
  }) {
    return Expense(
      id: id ?? this.id,
      title: title ?? this.title,
      amount: amount ?? this.amount,
      categoryId: categoryId ?? this.categoryId,
      date: date ?? this.date,
      paymentMethod: paymentMethod ?? this.paymentMethod,
      notes: notes ?? this.notes,
    );
  }
}
