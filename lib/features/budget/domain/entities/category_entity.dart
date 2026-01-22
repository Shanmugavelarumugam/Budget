import 'package:flutter/material.dart';

class CategoryEntity {
  final String id;
  final String name;
  final IconData icon;
  final Color color;

  const CategoryEntity({
    required this.id,
    required this.name,
    required this.icon,
    required this.color,
  });

  // Predefined default categories
  static List<CategoryEntity> defaults = [
    const CategoryEntity(
      id: 'food',
      name: 'Food',
      icon: Icons.fastfood,
      color: Colors.orange,
    ),
    const CategoryEntity(
      id: 'rent',
      name: 'Rent',
      icon: Icons.home,
      color: Colors.blue,
    ),
    const CategoryEntity(
      id: 'transport',
      name: 'Transport',
      icon: Icons.directions_bus,
      color: Colors.indigo,
    ),
    const CategoryEntity(
      id: 'shopping',
      name: 'Shopping',
      icon: Icons.shopping_bag,
      color: Colors.purple,
    ),
    const CategoryEntity(
      id: 'entertainment',
      name: 'Entertainment',
      icon: Icons.movie,
      color: Colors.red,
    ),
    const CategoryEntity(
      id: 'health',
      name: 'Health',
      icon: Icons.local_hospital,
      color: Colors.green,
    ),
    const CategoryEntity(
      id: 'salary',
      name: 'Salary',
      icon: Icons.attach_money,
      color: Colors.green,
    ),
    const CategoryEntity(
      id: 'freelance',
      name: 'Freelance',
      icon: Icons.computer,
      color: Colors.teal,
    ),
    const CategoryEntity(
      id: 'other',
      name: 'Other',
      icon: Icons.category,
      color: Colors.grey,
    ),
  ];

  static CategoryEntity getById(String id) {
    return defaults.firstWhere(
      (c) => c.id == id,
      orElse: () => defaults.last,
    ); // Default to 'Other' if not found
  }
}
