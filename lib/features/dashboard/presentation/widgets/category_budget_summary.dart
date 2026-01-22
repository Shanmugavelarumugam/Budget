import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../../budget/domain/entities/category_entity.dart';
import '../../../transactions/domain/entities/transaction_entity.dart';
import '../../../budget/presentation/providers/budget_provider.dart';
import '../../../transactions/presentation/providers/transaction_provider.dart';
import '../../../../routes/route_names.dart';

class CategoryBudgetSummary extends StatelessWidget {
  final BudgetProvider budgetProvider;
  final TransactionProvider transactionProvider;
  final Color kCardBackground;
  final Color kPrimarySlate;
  final Color kSecondarySlate;
  final Color kAccentSlate;
  final Color kBorderSlate;

  const CategoryBudgetSummary({
    super.key,
    required this.budgetProvider,
    required this.transactionProvider,
    required this.kCardBackground,
    required this.kPrimarySlate,
    required this.kSecondarySlate,
    required this.kAccentSlate,
    required this.kBorderSlate,
  });

  @override
  Widget build(BuildContext context) {
    if (budgetProvider.categoryBudgets.isEmpty) return const SizedBox.shrink();

    final currencyFormat = NumberFormat.currency(
      locale: 'en_IN',
      symbol: '₹',
      decimalDigits: 0,
    );

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
                "CATEGORY BUDGETS",
                style: TextStyle(
                  color: kSecondarySlate,
                  fontSize: 10,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 1.0,
                ),
              ),
              GestureDetector(
                onTap: () {
                  Navigator.pushNamed(context, RouteNames.budgetDetails);
                },
                child: Text(
                  "See All",
                  style: TextStyle(
                    color: const Color(0xFF6366F1), // Royal Blue/Indigo
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),

          // List of category rows
          ...budgetProvider.categoryBudgets.entries.take(3).map((entry) {
            final categoryId = entry.key;
            final categoryBudget = entry.value;
            final category = CategoryEntity.getById(categoryId);

            final categorySpent = transactionProvider.transactions
                .where(
                  (t) =>
                      t.category == categoryId &&
                      t.type == TransactionType.expense,
                )
                .fold(0.0, (sum, t) => sum + t.amount);

            final progress = (categorySpent / categoryBudget.amount).clamp(
              0.0,
              1.0,
            );
            final isOver = categorySpent > categoryBudget.amount;

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
                                  "${(progress * 100).toStringAsFixed(0)}%",
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 12,
                                    color: isOver
                                        ? const Color(0xFFEF4444)
                                        : kSecondarySlate,
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
                                  isOver
                                      ? const Color(0xFFEF4444)
                                      : category.color,
                                ),
                                minHeight: 6,
                              ),
                            ),
                            const SizedBox(height: 8),
                            // Amounts
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  "${currencyFormat.format(categorySpent)} spent",
                                  style: TextStyle(
                                    fontSize: 11,
                                    color: kSecondarySlate,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                                Text(
                                  "${currencyFormat.format(categoryBudget.amount)} limit",
                                  style: TextStyle(
                                    fontSize: 11,
                                    color: kSecondarySlate,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ],
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
