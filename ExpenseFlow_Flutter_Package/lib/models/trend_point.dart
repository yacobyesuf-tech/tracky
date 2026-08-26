class TrendPoint {
  final String label;
  final DateTime date;
  final double amount;

  const TrendPoint({
    required this.label,
    required this.date,
    required this.amount,
  });
}

enum TimeFrame {
  daily,
  monthly,
  yearly,
}
