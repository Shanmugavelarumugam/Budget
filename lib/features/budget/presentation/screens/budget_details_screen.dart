import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../../../transactions/presentation/providers/transaction_provider.dart';
import '../../../transactions/domain/entities/transaction_entity.dart';
import '../../../settings/presentation/providers/settings_provider.dart';
import '../../domain/entities/category_entity.dart';
import '../providers/budget_provider.dart';
import 'category_budget_details_screen.dart'; // Import the new screen

/// Screen showing detailed budget breakdown with progress and statistics
class BudgetDetailsScreen extends StatelessWidget {
  const BudgetDetailsScreen({super.key});

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

  Widget _buildMonthHeader(String monthName, BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final kPrimarySlate = isDark ? Colors.white : const Color(0xFF0F172A);
    final kSecondarySlate = isDark
        ? const Color(0xFF94A3B8)
        : const Color(0xFF64748B);

    return Column(
      children: [
        Text(
          monthName,
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w600,
            color: kPrimarySlate,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          'Budget breakdown and progress',
          style: TextStyle(fontSize: 14, color: kSecondarySlate),
        ),
      ],
    );
  }

  Widget _buildStatRow(
    String label,
    String value,
    Color valueColor,
    Color labelColor, {
    bool isBold = false,
  }) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: TextStyle(
            color: labelColor,
            fontSize: 14,
            fontWeight: FontWeight.w500,
          ),
        ),
        Flexible(
          child: Text(
            value,
            textAlign: TextAlign.end,
            style: TextStyle(
              color: valueColor,
              fontSize: 16,
              fontWeight: isBold ? FontWeight.w900 : FontWeight.bold,
            ),
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final transactionProvider = context.watch<TransactionProvider>();
    final budgetProvider = context.watch<BudgetProvider>();
    final settings = context.watch<SettingsProvider>();

    final currentBudget = budgetProvider.currentBudget;

    // If no budget, show message
    if (currentBudget == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Budget Details')),
        body: const Center(
          child: Text('No budget set. Please set a budget first.'),
        ),
      );
    }

    final currencyCode = settings.currency;
    final currencySymbol = _getCurrencySymbol(currencyCode);
    final currencyFormat = NumberFormat.currency(
      locale: 'en_IN',
      symbol: currencySymbol,
      decimalDigits: 0, // No decimals for Indian users
    );
    final percentFormat = NumberFormat.percentPattern();

    final budgetLimit = currentBudget.amount;
    final totalSpent = transactionProvider.totalExpense;
    final remaining = budgetLimit - totalSpent;
    final progress = (totalSpent / budgetLimit).clamp(0.0, 1.0);

    final now = DateTime.now();
    final monthName = DateFormat('MMMM yyyy').format(now);

    // Theme Colors
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final kAppBackground = isDark ? const Color(0xFF0F172A) : Colors.white;
    final kPrimarySlate = isDark ? Colors.white : const Color(0xFF0F172A);
    final kSecondarySlate = isDark
        ? const Color(0xFF94A3B8)
        : const Color(0xFF64748B);
    final kAccentSlate = isDark
        ? const Color(0xFF1E293B)
        : const Color(0xFFF8FAFC);
    final kCardBackground = isDark ? const Color(0xFF1E293B) : Colors.white;
    final kBorderSlate = isDark
        ? const Color(0xFF334155)
        : const Color(0xFFE2E8F0);
    const kPrimaryPurple = Color(0xFF8B5CF6);

    return Scaffold(
      backgroundColor: kAppBackground,
      appBar: AppBar(
        backgroundColor: kAppBackground,
        elevation: 0,
        title: Text(
          'Budget Details',
          style: TextStyle(color: kPrimarySlate, fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        iconTheme: IconThemeData(color: kPrimarySlate),
        actions: [
          IconButton(
            icon: const Icon(Icons.edit_outlined),
            tooltip: 'Edit Budget',
            onPressed: () {
              Navigator.pushNamed(context, '/set-monthly-budget');
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _buildMonthHeader(monthName, context),
            const SizedBox(height: 32),

            // Circular Progress / Main Status
            Center(
              child: Stack(
                alignment: Alignment.center,
                children: [
                  SizedBox(
                    width: 200,
                    height: 200,
                    child: CircularProgressIndicator(
                      value: progress,
                      strokeWidth: 16,
                      backgroundColor: kAccentSlate,
                      valueColor: AlwaysStoppedAnimation<Color>(
                        remaining < 0
                            ? const Color(0xFFEF4444)
                            : kPrimaryPurple,
                      ),
                      strokeCap: StrokeCap.round,
                    ),
                  ),
                  Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        percentFormat.format(progress),
                        style: TextStyle(
                          fontSize: 32,
                          fontWeight: FontWeight.w900,
                          color: kPrimarySlate,
                        ),
                      ),
                      Text(
                        'Used',
                        style: TextStyle(
                          color: kSecondarySlate,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            const SizedBox(height: 40),

            // Stats Grid
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: kCardBackground,
                borderRadius: BorderRadius.circular(20),
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
                children: [
                  _buildStatRow(
                    'Budget Limit',
                    currencyFormat.format(budgetLimit),
                    kPrimarySlate,
                    kSecondarySlate,
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    child: Divider(height: 1, color: kBorderSlate),
                  ),
                  _buildStatRow(
                    'Total Spent',
                    currencyFormat.format(totalSpent),
                    kPrimarySlate,
                    kSecondarySlate,
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    child: Divider(height: 1, color: kBorderSlate),
                  ),
                  _buildStatRow(
                    'Remaining',
                    currencyFormat.format(remaining),
                    remaining < 0
                        ? const Color(0xFFEF4444)
                        : const Color(0xFF22C55E),
                    kSecondarySlate,
                    isBold: true,
                  ),
                ],
              ),
            ),

            const SizedBox(height: 24),

            // Additional info card
            if (remaining < 0)
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: const Color(0xFFEF4444).withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: const Color(0xFFEF4444).withValues(alpha: 0.3),
                  ),
                ),
                child: Row(
                  children: [
                    const Icon(
                      Icons.warning_amber_rounded,
                      color: Color(0xFFEF4444),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        "You've exceeded your budget by ${currencyFormat.format(remaining.abs())}",
                        style: const TextStyle(
                          color: Color(0xFFEF4444),
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),
              ),

            // Category Budgets Section
            if (budgetProvider.categoryBudgets.isNotEmpty) ...[
              const SizedBox(height: 32),

              // Section Header
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Category Budgets',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: kPrimarySlate,
                    ),
                  ),
                  TextButton.icon(
                    onPressed: () {
                      Navigator.pushNamed(context, '/set-category-budget');
                    },
                    icon: Icon(
                      Icons.edit_outlined,
                      size: 16,
                      color: kSecondarySlate,
                    ),
                    label: Text(
                      'Edit',
                      style: TextStyle(color: kSecondarySlate),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 16),

              // Category Budget Cards
              ...budgetProvider.categoryBudgets.entries.map((entry) {
                final categoryId = entry.key;
                final categoryBudget = entry.value;
                final category = CategoryEntity.getById(categoryId);

                // Get spending for this category
                final categorySpent = transactionProvider.transactions
                    .where(
                      (t) =>
                          t.category == categoryId &&
                          t.type == TransactionType.expense,
                    )
                    .fold(0.0, (sum, t) => sum + t.amount);

                final categoryRemaining = categoryBudget.amount - categorySpent;
                final categoryProgress = (categorySpent / categoryBudget.amount)
                    .clamp(0.0, 1.0);

                // Determine status color
                Color statusColor;
                if (categoryRemaining < 0) {
                  statusColor = const Color(0xFFEF4444); // Red - over budget
                } else if (categoryProgress >= 0.8) {
                  statusColor = const Color(0xFFF59E0B); // Orange - near limit
                } else {
                  statusColor = const Color(0xFF22C55E); // Green - under budget
                }

                return Padding(
                  padding: const EdgeInsets.only(bottom: 12.0),
                  child: GestureDetector(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => CategoryBudgetDetailsScreen(
                            category: category,
                            budgetAmount: categoryBudget.amount,
                          ),
                        ),
                      );
                    },
                    child: Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: kCardBackground,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: kBorderSlate),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Category header
                          Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.all(8),
                                decoration: BoxDecoration(
                                  color: category.color.withValues(alpha: 0.1),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Icon(
                                  category.icon,
                                  color: category.color,
                                  size: 20,
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Text(
                                  category.name,
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w600,
                                    color: kPrimarySlate,
                                  ),
                                ),
                              ),
                              Text(
                                '${(categoryProgress * 100).toStringAsFixed(0)}%',
                                style: TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.bold,
                                  color: statusColor,
                                ),
                              ),
                            ],
                          ),

                          const SizedBox(height: 12),

                          // Progress bar
                          ClipRRect(
                            borderRadius: BorderRadius.circular(4),
                            child: LinearProgressIndicator(
                              value: categoryProgress,
                              minHeight: 8,
                              backgroundColor: kAccentSlate,
                              valueColor: AlwaysStoppedAnimation<Color>(
                                statusColor,
                              ),
                            ),
                          ),

                          const SizedBox(height: 12),

                          // Amounts
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                '${currencyFormat.format(categorySpent)} / ${currencyFormat.format(categoryBudget.amount)}',
                                style: TextStyle(
                                  fontSize: 14,
                                  color: kSecondarySlate,
                                ),
                              ),
                              Text(
                                categoryRemaining >= 0
                                    ? '${currencyFormat.format(categoryRemaining)} left'
                                    : '${currencyFormat.format(categoryRemaining.abs())} over',
                                style: TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w600,
                                  color: statusColor,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              }),
            ],
          ],
        ),
      ),
    );
  }
}
