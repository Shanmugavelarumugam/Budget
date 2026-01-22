import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../../budget/domain/entities/category_entity.dart';
import '../../../../routes/route_names.dart';

class TopSpendingCard extends StatelessWidget {
  final List<MapEntry<String, double>> topCategories;
  final double totalExpense;
  final NumberFormat currencyFormat;
  final Color kCardBackground;
  final Color kPrimarySlate;
  final Color kSecondarySlate;
  final Color kAccentSlate;
  final Color kBorderSlate;

  const TopSpendingCard({
    super.key,
    required this.topCategories,
    required this.totalExpense,
    required this.currencyFormat,
    required this.kCardBackground,
    required this.kPrimarySlate,
    required this.kSecondarySlate,
    required this.kAccentSlate,
    required this.kBorderSlate,
  });

  @override
  Widget build(BuildContext context) {
    if (topCategories.isEmpty) return const SizedBox.shrink();

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: kCardBackground,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: kBorderSlate),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                "TOP SPENDING",
                style: TextStyle(
                  color: kSecondarySlate,
                  fontSize: 10,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 1.0,
                ),
              ),
              GestureDetector(
                onTap: () {
                  Navigator.pushNamed(context, RouteNames.reports);
                },
                child: Text(
                  "Reports",
                  style: TextStyle(
                    color: const Color(0xFF6366F1),
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),

          // List of category rows
          ...topCategories.take(3).map((entry) {
            final category = CategoryEntity.getById(entry.key);
            final amount = entry.value;
            final progress = totalExpense > 0 ? (amount / totalExpense) : 0.0;

            return Padding(
              padding: const EdgeInsets.only(bottom: 20.0),
              child: Column(
                children: [
                  Row(
                    children: [
                      // Icon
                      Container(
                        width: 36,
                        height: 36,
                        decoration: BoxDecoration(
                          color: category.color.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Icon(
                          category.icon,
                          color: category.color,
                          size: 18,
                        ),
                      ),
                      const SizedBox(width: 12),
                      // Text Info
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  category.name,
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 14,
                                    color: kPrimarySlate,
                                  ),
                                ),
                                Text(
                                  currencyFormat.format(amount),
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 13,
                                    color: kPrimarySlate,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 8),
                            // Bar
                            ClipRRect(
                              borderRadius: BorderRadius.circular(4),
                              child: LinearProgressIndicator(
                                value: progress,
                                backgroundColor: kAccentSlate,
                                valueColor: AlwaysStoppedAnimation<Color>(
                                  category.color,
                                ),
                                minHeight: 6,
                              ),
                            ),
                            const SizedBox(height: 8),
                            // Percentage Label
                            Align(
                              alignment: Alignment.centerRight,
                              child: Text(
                                "${(progress * 100).toStringAsFixed(0)}% of total",
                                style: TextStyle(
                                  fontSize: 11,
                                  color: kSecondarySlate,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            );
          }),
        ],
      ),
    );
  }
}
