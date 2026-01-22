import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../../../transactions/presentation/providers/transaction_provider.dart';
import '../../../budget/presentation/providers/budget_provider.dart';
import '../../../settings/presentation/providers/settings_provider.dart';
import '../../../transactions/domain/entities/transaction_entity.dart';
import '../../../budget/domain/entities/category_entity.dart';

class SharedReadonlyScreen extends StatelessWidget {
  const SharedReadonlyScreen({super.key});

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
    final isDark = Theme.of(context).brightness == Brightness.dark;

    // Theme Colors
    final kAppBackground = isDark ? const Color(0xFF0F172A) : Colors.white;
    final kPrimarySlate = isDark ? Colors.white : const Color(0xFF0F172A);
    final kSecondarySlate = isDark
        ? const Color(0xFF94A3B8)
        : const Color(0xFF64748B);
    final kCardBackground = isDark ? const Color(0xFF1E293B) : Colors.white;
    final kBorderSlate = isDark
        ? const Color(0xFF334155)
        : const Color(0xFFE2E8F0);
    final kAccentSlate = isDark
        ? const Color(0xFF1E293B)
        : const Color(0xFFF8FAFC);

    return Scaffold(
      backgroundColor: kAppBackground,
      appBar: AppBar(
        title: Text(
          'Shared View',
          style: TextStyle(color: kPrimarySlate, fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        backgroundColor: kAppBackground,
        elevation: 0,
        iconTheme: IconThemeData(color: kPrimarySlate),
        actions: [
          IconButton(
            icon: Icon(Icons.visibility_outlined, color: kSecondarySlate),
            onPressed: () => _showReadOnlyInfo(context),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Read-Only Banner
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: const Color(0xFF3B82F6).withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: const Color(0xFF3B82F6).withValues(alpha: 0.2),
                ),
              ),
              child: Row(
                children: [
                  const Icon(
                    Icons.visibility_outlined,
                    color: Color(0xFF3B82F6),
                    size: 20,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      'You have read-only access to this account.',
                      style: TextStyle(
                        fontSize: 13,
                        color: const Color(0xFF3B82F6),
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 32),

            // Dashboard Summary
            _buildDashboardSummary(
              context,
              kPrimarySlate,
              kSecondarySlate,
              kCardBackground,
              kBorderSlate,
              isDark,
            ),

            const SizedBox(height: 32),

            // Recent Transactions
            _buildRecentTransactions(
              context,
              kPrimarySlate,
              kSecondarySlate,
              kCardBackground,
              kBorderSlate,
              kAccentSlate,
            ),

            const SizedBox(height: 32),

            // Budget Overview
            _buildBudgetOverview(
              context,
              kPrimarySlate,
              kSecondarySlate,
              kCardBackground,
              kBorderSlate,
              kAccentSlate,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDashboardSummary(
    BuildContext context,
    Color kPrimary,
    Color kSecondary,
    Color kCardBg,
    Color kBorder,
    bool isDark,
  ) {
    final transactionProvider = context.watch<TransactionProvider>();
    final settings = context.watch<SettingsProvider>();
    final currencySymbol = _getCurrencySymbol(settings.currency);

    final totalIncome = transactionProvider.totalIncome;
    final totalExpense = transactionProvider.totalExpense;
    final balance = totalIncome - totalExpense;

    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: kCardBg,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: kBorder),
        boxShadow: isDark
            ? []
            : [
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
          Text(
            'Overview',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: kPrimary,
            ),
          ),
          const SizedBox(height: 20),
          _buildSummaryRow(
            'Income',
            '$currencySymbol${NumberFormat("#,##0").format(totalIncome)}',
            const Color(0xFF22C55E),
            kSecondary,
          ),
          const SizedBox(height: 12),
          _buildSummaryRow(
            'Expenses',
            '$currencySymbol${NumberFormat("#,##0").format(totalExpense)}',
            const Color(0xFFEF4444),
            kSecondary,
          ),
          const SizedBox(height: 12),
          Divider(color: kBorder),
          const SizedBox(height: 12),
          _buildSummaryRow(
            'Balance',
            '$currencySymbol${NumberFormat("#,##0").format(balance)}',
            kPrimary,
            kSecondary,
            isBold: true,
          ),
        ],
      ),
    );
  }

  Widget _buildSummaryRow(
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
            fontSize: 15,
            color: labelColor,
            fontWeight: FontWeight.w500,
          ),
        ),
        Text(
          value,
          style: TextStyle(
            fontSize: 16,
            color: valueColor,
            fontWeight: isBold ? FontWeight.bold : FontWeight.w600,
          ),
        ),
      ],
    );
  }

  Widget _buildRecentTransactions(
    BuildContext context,
    Color kPrimary,
    Color kSecondary,
    Color kCardBg,
    Color kBorder,
    Color kAccent,
  ) {
    final transactionProvider = context.watch<TransactionProvider>();
    final settings = context.watch<SettingsProvider>();
    final currencySymbol = _getCurrencySymbol(settings.currency);

    final recentTransactions = transactionProvider.transactions
        .take(5)
        .toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Recent Transactions',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: kPrimary,
              ),
            ),
            Icon(Icons.lock_outline_rounded, size: 16, color: kSecondary),
          ],
        ),
        const SizedBox(height: 16),
        if (recentTransactions.isEmpty)
          Container(
            padding: const EdgeInsets.all(32),
            decoration: BoxDecoration(
              color: kCardBg,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: kBorder),
            ),
            child: Center(
              child: Text(
                'No transactions',
                style: TextStyle(color: kSecondary),
              ),
            ),
          )
        else
          ...recentTransactions.map((transaction) {
            final category = CategoryEntity.getById(transaction.category);
            final isExpense = transaction.type == TransactionType.expense;

            return Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: kCardBg,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: kBorder),
                ),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: category.color.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Icon(
                        category.icon,
                        color: category.color,
                        size: 20,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            category.name,
                            style: TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.w600,
                              color: kPrimary,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            DateFormat.yMMMd().format(transaction.date),
                            style: TextStyle(fontSize: 13, color: kSecondary),
                          ),
                        ],
                      ),
                    ),
                    Text(
                      '${isExpense ? "-" : "+"}$currencySymbol${NumberFormat("#,##0").format(transaction.amount)}',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: isExpense
                            ? const Color(0xFFEF4444)
                            : const Color(0xFF22C55E),
                      ),
                    ),
                  ],
                ),
              ),
            );
          }),
      ],
    );
  }

  Widget _buildBudgetOverview(
    BuildContext context,
    Color kPrimary,
    Color kSecondary,
    Color kCardBg,
    Color kBorder,
    Color kAccent,
  ) {
    final budgetProvider = context.watch<BudgetProvider>();
    final transactionProvider = context.watch<TransactionProvider>();
    final settings = context.watch<SettingsProvider>();
    final currencySymbol = _getCurrencySymbol(settings.currency);

    final currentBudget = budgetProvider.currentBudget;

    if (currentBudget == null) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Budget',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: kPrimary,
                ),
              ),
              Icon(Icons.lock_outline_rounded, size: 16, color: kSecondary),
            ],
          ),
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.all(32),
            decoration: BoxDecoration(
              color: kCardBg,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: kBorder),
            ),
            child: Center(
              child: Text('No budget set', style: TextStyle(color: kSecondary)),
            ),
          ),
        ],
      );
    }

    final budgetLimit = currentBudget.amount;
    final totalSpent = transactionProvider.totalExpense;
    final remaining = budgetLimit - totalSpent;
    final progress = (totalSpent / budgetLimit).clamp(0.0, 1.0);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Budget',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: kPrimary,
              ),
            ),
            Icon(Icons.lock_outline_rounded, size: 16, color: kSecondary),
          ],
        ),
        const SizedBox(height: 16),
        Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: kCardBg,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: kBorder),
          ),
          child: Column(
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: LinearProgressIndicator(
                  value: progress,
                  minHeight: 12,
                  backgroundColor: kAccent,
                  valueColor: AlwaysStoppedAnimation<Color>(
                    remaining < 0
                        ? const Color(0xFFEF4444)
                        : const Color(0xFF8B5CF6),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Spent',
                    style: TextStyle(fontSize: 14, color: kSecondary),
                  ),
                  Text(
                    '$currencySymbol${NumberFormat("#,##0").format(totalSpent)} / $currencySymbol${NumberFormat("#,##0").format(budgetLimit)}',
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.bold,
                      color: kPrimary,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }

  void _showReadOnlyInfo(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Read-Only Access'),
        content: const Text(
          'You can view all financial data but cannot:\n\n'
          '• Add or edit transactions\n'
          '• Modify budgets\n'
          '• Change settings\n'
          '• Export data\n\n'
          'Contact the account owner to request changes.',
        ),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Got it'),
          ),
        ],
      ),
    );
  }
}
