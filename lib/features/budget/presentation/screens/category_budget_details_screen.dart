import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../../../transactions/domain/entities/transaction_entity.dart';
import '../../../settings/presentation/providers/settings_provider.dart';
import '../../domain/entities/category_entity.dart';
import '../../../transactions/presentation/providers/transaction_provider.dart';

class CategoryBudgetDetailsScreen extends StatelessWidget {
  final CategoryEntity category;
  final double budgetAmount;

  const CategoryBudgetDetailsScreen({
    super.key,
    required this.category,
    required this.budgetAmount,
  });

  String _getCurrencySymbol(String currencyCode) {
    switch (currencyCode) {
      case 'INR':
        return '₹';
      case 'USD':
        return '\$';
      case 'EUR':
        return '€';
      case 'GBP':
        return '£';
      default:
        return currencyCode;
    }
  }

  @override
  Widget build(BuildContext context) {
    final settings = context.watch<SettingsProvider>();
    final transactionProvider = context.watch<TransactionProvider>();

    // Filter transactions for this category
    final categoryTransactions =
        transactionProvider.transactions
            .where(
              (t) =>
                  t.category == category.id &&
                  t.type == TransactionType.expense,
            )
            .toList()
          ..sort((a, b) => b.date.compareTo(a.date)); // Sort by date descending

    final totalSpent = categoryTransactions.fold(
      0.0,
      (sum, t) => sum + t.amount,
    );
    final remaining = budgetAmount - totalSpent;
    final progress = (totalSpent / budgetAmount).clamp(0.0, 1.0);

    final currencyCode = settings.currency;
    final currencySymbol = _getCurrencySymbol(currencyCode);
    final currencyFormat = NumberFormat.currency(
      locale: 'en_IN',
      symbol: currencySymbol,
      decimalDigits: 0,
    );

    final isDark = Theme.of(context).brightness == Brightness.dark;
    final kAppBackground = isDark ? const Color(0xFF0F172A) : Colors.white;
    final kPrimarySlate = isDark ? Colors.white : const Color(0xFF0F172A);
    final kSecondarySlate = isDark
        ? const Color(0xFF94A3B8)
        : const Color(0xFF64748B);
    final kCardBackground = isDark ? const Color(0xFF1E293B) : Colors.white;
    final kBorderSlate = isDark
        ? const Color(0xFF334155)
        : const Color(0xFFE2E8F0);

    Color statusColor;
    if (remaining < 0) {
      statusColor = const Color(0xFFEF4444);
    } else if (progress >= 0.8) {
      statusColor = const Color(0xFFF59E0B);
    } else {
      statusColor = const Color(0xFF22C55E);
    }

    return Scaffold(
      backgroundColor: kAppBackground,
      appBar: AppBar(
        title: Text(
          category.name,
          style: TextStyle(color: kPrimarySlate, fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        backgroundColor: kAppBackground,
        elevation: 0,
        iconTheme: IconThemeData(color: kPrimarySlate),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Summary Card
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: kCardBackground,
                borderRadius: BorderRadius.circular(24),
                border: Border.all(color: kBorderSlate),
                boxShadow: isDark
                    ? []
                    : [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.05),
                          blurRadius: 10,
                          offset: const Offset(0, 4),
                        ),
                      ],
              ),
              child: Column(
                children: [
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: category.color.withValues(alpha: 0.1),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(category.icon, color: category.color, size: 32),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    currencyFormat.format(totalSpent),
                    style: TextStyle(
                      fontSize: 32,
                      fontWeight: FontWeight.w900,
                      color: kPrimarySlate,
                    ),
                  ),
                  Text(
                    'spent of ${currencyFormat.format(budgetAmount)}',
                    style: TextStyle(
                      color: kSecondarySlate,
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 24),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: LinearProgressIndicator(
                      value: progress,
                      minHeight: 12,
                      backgroundColor: isDark
                          ? Colors.black12
                          : const Color(0xFFF1F5F9),
                      valueColor: AlwaysStoppedAnimation<Color>(statusColor),
                    ),
                  ),
                  const SizedBox(height: 12),
                  Align(
                    alignment: Alignment.centerRight,
                    child: Text(
                      remaining >= 0
                          ? '${currencyFormat.format(remaining)} left'
                          : '${currencyFormat.format(remaining.abs())} over budget',
                      style: TextStyle(
                        color: statusColor,
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                      ),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 32),

            // History Section
            Text(
              "HISTORY",
              style: TextStyle(
                color: kSecondarySlate,
                fontSize: 12,
                fontWeight: FontWeight.w900,
                letterSpacing: 1.0,
              ),
            ),
            const SizedBox(height: 16),

            if (categoryTransactions.isEmpty)
              Padding(
                padding: const EdgeInsets.all(32.0),
                child: Center(
                  child: Text(
                    "No transactions yet",
                    style: TextStyle(color: kSecondarySlate),
                  ),
                ),
              )
            else
              ...categoryTransactions.map((transaction) {
                return Padding(
                  padding: const EdgeInsets.only(bottom: 16.0),
                  child: Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: kCardBackground,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: kBorderSlate),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              DateFormat.yMMMd().format(transaction.date),
                              style: TextStyle(
                                color: kPrimarySlate,
                                fontWeight: FontWeight.bold,
                                fontSize: 13, // Smaller date
                              ),
                            ),
                            const SizedBox(height: 4),
                            if (transaction.description != null &&
                                transaction.description!.isNotEmpty)
                              Text(
                                transaction.description!,
                                style: TextStyle(
                                  color: kSecondarySlate,
                                  fontSize: 12, // Subtitle for note
                                ),
                              )
                            else
                              Text(
                                DateFormat.jm().format(
                                  transaction.date,
                                ), // Time if no note
                                style: TextStyle(
                                  color: kSecondarySlate,
                                  fontSize: 12,
                                ),
                              ),
                          ],
                        ),
                        Text(
                          currencyFormat.format(transaction.amount),
                          style: TextStyle(
                            color: kPrimarySlate,
                            fontWeight: FontWeight.w900,
                            fontSize: 16,
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              }),
          ],
        ),
      ),
    );
  }
}
