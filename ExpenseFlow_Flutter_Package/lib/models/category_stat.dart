import 'package:flutter/material.dart';

class CategoryStat {
  final String categoryId;
  final String name;
  final double totalAmount;
  final double percentage;
  final int transactionCount;
  final Color color;
  final IconData icon;

  const CategoryStat({
    required this.categoryId,
    required this.name,
    required this.totalAmount,
    required this.percentage,
    required this.transactionCount,
    required this.color,
    required this.icon,
  });
}
