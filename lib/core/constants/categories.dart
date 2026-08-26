import 'package:flutter/material.dart';

class ExpenseCategoryItem {
  final String id;
  final String name;
  final IconData icon;
  final Color defaultColor;

  const ExpenseCategoryItem({
    required this.id,
    required this.name,
    required this.icon,
    required this.defaultColor,
  });
}

class AppCategories {
  static const List<ExpenseCategoryItem> items = [
    ExpenseCategoryItem(
      id: 'food',
      name: 'Food & Dining',
      icon: Icons.restaurant_rounded,
      defaultColor: Color(0xFFFF7043),
    ),
    ExpenseCategoryItem(
      id: 'shopping',
      name: 'Shopping',
      icon: Icons.shopping_bag_rounded,
      defaultColor: Color(0xFFAB47BC),
    ),
    ExpenseCategoryItem(
      id: 'transport',
      name: 'Transportation',
      icon: Icons.directions_car_rounded,
      defaultColor: Color(0xFF42A5F5),
    ),
    ExpenseCategoryItem(
      id: 'housing',
      name: 'Housing & Rent',
      icon: Icons.home_rounded,
      defaultColor: Color(0xFF26A69A),
    ),
    ExpenseCategoryItem(
      id: 'entertainment',
      name: 'Entertainment',
      icon: Icons.movie_filter_rounded,
      defaultColor: Color(0xFFFFCA28),
    ),
    ExpenseCategoryItem(
      id: 'health',
      name: 'Health & Medical',
      icon: Icons.favorite_rounded,
      defaultColor: Color(0xFFEF5350),
    ),
    ExpenseCategoryItem(
      id: 'utilities',
      name: 'Bills & Utilities',
      icon: Icons.bolt_rounded,
      defaultColor: Color(0xFF5C6BC0),
    ),
    ExpenseCategoryItem(
      id: 'education',
      name: 'Education',
      icon: Icons.school_rounded,
      defaultColor: Color(0xFF66BB6A),
    ),
    ExpenseCategoryItem(
      id: 'investment',
      name: 'Investments',
      icon: Icons.trending_up_rounded,
      defaultColor: Color(0xFF29B6F6),
    ),
    ExpenseCategoryItem(
      id: 'other',
      name: 'Miscellaneous',
      icon: Icons.category_rounded,
      defaultColor: Color(0xFF8D6E63),
    ),
  ];

  static ExpenseCategoryItem getById(String id) {
    return items.firstWhere(
      (element) => element.id.toLowerCase() == id.toLowerCase(),
      orElse: () => items.last,
    );
  }

  static ExpenseCategoryItem getByName(String name) {
    return items.firstWhere(
      (element) => element.name.toLowerCase() == name.toLowerCase(),
      orElse: () => items.last,
    );
  }
}
