import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import 'package:budgets/features/transactions/presentation/providers/transaction_provider.dart';
import '../../../transactions/domain/entities/transaction_entity.dart';
import '../../../auth/presentation/providers/auth_provider.dart';
import '../../../settings/presentation/providers/settings_provider.dart';
import '../../domain/entities/category_entity.dart';
import '../providers/budget_provider.dart';

class BudgetOverviewScreen extends StatefulWidget {
  const BudgetOverviewScreen({super.key});

  @override
  State<BudgetOverviewScreen> createState() => _BudgetOverviewScreenState();
}

class _BudgetOverviewScreenState extends State<BudgetOverviewScreen> {
  final _amountController = TextEditingController();
  bool _isSaving = false;
  bool _isEditing = false; // Toggle to show edit mode

  @override
  void initState() {
    super.initState();
    _initData();
  }

  void _initData() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final budgetProvider = context.read<BudgetProvider>();
      if (budgetProvider.currentBudget != null) {
        _amountController.text = budgetProvider.currentBudget!.amount
            .toStringAsFixed(0);
      } else {
        // Default to edit mode if no budget exists
        setState(() => _isEditing = true);
      }
    });
  }

  @override
  void dispose() {
    _amountController.dispose();
    super.dispose();
  }

  Future<void> _saveBudget() async {
    final amountText = _amountController.text.replaceAll(',', '');
    final amount = double.tryParse(amountText);

    if (amount == null || amount <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Please enter a valid amount")),
      );
      return;
    }

    setState(() => _isSaving = true);

    try {
      await context.read<BudgetProvider>().setBudget(amount);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            // NO CONST
            content: Text("Budget updated successfully"),
            backgroundColor: Theme.of(context).brightness == Brightness.dark
                ? Colors.white
                : const Color(0xFF0F172A),
          ),
        );
        setState(() => _isEditing = false); // Exit edit mode
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text("Error saving budget: $e")));
      }
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final transactionProvider = context.watch<TransactionProvider>();
    final budgetProvider = context.watch<BudgetProvider>();
    final auth = context.watch<AuthProvider>();
    final settings = context.watch<SettingsProvider>();
    final isGuest = auth.user?.isGuest ?? false;

    final currentBudget = budgetProvider.currentBudget;
    final hasBudget = currentBudget != null;

    final showEditMode = !hasBudget || _isEditing;

    // Dynamic Theme Colors
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final kAppBackground = isDark ? const Color(0xFF0F172A) : Colors.white;
    final kPrimarySlate = isDark ? Colors.white : const Color(0xFF0F172A);
    final kSecondarySlate = isDark
        ? const Color(0xFF94A3B8)
        : const Color(0xFF64748B);
    final kAccentSlate = isDark
        ? const Color(0xFF1E293B)
        : const Color(0xFFF8FAFC);

    // final kBorderSlate = isDark ? const Color(0xFF334155) : const Color(0xFFE2E8F0);
    // const kPrimaryPurple = Color(0xFF8B5CF6);

    return Scaffold(
      backgroundColor: kAppBackground,
      appBar: AppBar(
        backgroundColor: kAppBackground,
        elevation: 0,
        title: Text(
          "Monthly Budget",
          style: TextStyle(color: kPrimarySlate, fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        iconTheme: IconThemeData(color: kPrimarySlate),
        actions: [
          if (!showEditMode)
            IconButton(
              icon: const Icon(Icons.edit_outlined),
              onPressed: () {
                setState(() {
                  _isEditing = true;
                  _amountController.text = currentBudget.amount.toStringAsFixed(
                    0,
                  );
                });
              },
            ),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: showEditMode
                ? _buildEditView(context, settings.currency)
                : _buildOverviewView(
                    context,
                    transactionProvider,
                    budgetProvider,
                    settings.currency,
                  ),
          ),

          if (isGuest)
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(12),
              color: kAccentSlate,
              child: Text(
                "Budgets are saved locally in Guest Mode.",
                textAlign: TextAlign.center,
                style: TextStyle(color: kSecondarySlate, fontSize: 12),
              ),
            ),

          // Safe area spacing for bottom nav matches dashboard
          const SizedBox(height: 80),
        ],
      ),
    );
  }

  Widget _buildEditView(BuildContext context, String currencyCode) {
    final now = DateTime.now();
    final monthName = DateFormat('MMMM yyyy').format(now);

    // Theme Colors
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final kPrimarySlate = isDark ? Colors.white : const Color(0xFF0F172A);
    final kSecondarySlate = isDark
        ? const Color(0xFF94A3B8)
        : const Color(0xFF64748B);

    final currencySymbol = _getCurrencySymbol(currencyCode);

    return Padding(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _buildMonthHeader(monthName, context),
          const SizedBox(height: 40),
          Text(
            "What is your spending limit?",
            textAlign: TextAlign.center,
            style: TextStyle(
              color: kSecondarySlate,
              fontSize: 16,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 16),
          TextField(
            controller: _amountController,
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 40,
              fontWeight: FontWeight.w900,
              color: kPrimarySlate,
            ),
            decoration: InputDecoration(
              hintText: "0",
              prefixText: currencySymbol,
              prefixStyle: TextStyle(
                fontSize: 40,
                fontWeight: FontWeight.w900,
                color: kPrimarySlate,
              ),
              border: InputBorder.none,
              hintStyle: TextStyle(
                color: kSecondarySlate.withValues(alpha: 0.3),
              ),
            ),
            inputFormatters: [
              FilteringTextInputFormatter.allow(RegExp(r'[0-9.]')),
            ],
          ),
          const Spacer(),
          SizedBox(
            height: 56,
            child: ElevatedButton(
              onPressed: _isSaving ? null : _saveBudget,
              style: ElevatedButton.styleFrom(
                backgroundColor: kPrimarySlate,
                foregroundColor: kPrimarySlate == Colors.white
                    ? Colors.black
                    : Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                elevation: 0,
              ),
              child: _isSaving
                  ? const SizedBox(
                      height: 24,
                      width: 24,
                      child: CircularProgressIndicator(
                        color: Colors.white,
                        strokeWidth: 2,
                      ),
                    )
                  : const Text(
                      "Save Limit",
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
            ),
          ),

          if (_isEditing &&
              context.read<BudgetProvider>().currentBudget != null)
            Padding(
              padding: const EdgeInsets.only(top: 16.0),
              child: TextButton(
                onPressed: () => setState(() => _isEditing = false),
                child: Text("Cancel", style: TextStyle(color: kSecondarySlate)),
              ),
            ),

          const SizedBox(height: 24),
        ],
      ),
    );
  }

  Widget _buildOverviewView(
    BuildContext context,
    TransactionProvider transactionProvider,
    BudgetProvider budgetProvider,
    String currencyCode,
  ) {
    // Theme Colors
    final isDark = Theme.of(context).brightness == Brightness.dark;
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

    final budgetLimit = budgetProvider.currentBudget!.amount;
    final totalSpent = transactionProvider.totalExpense;
    final remaining = budgetLimit - totalSpent;
    final progress = (totalSpent / budgetLimit).clamp(0.0, 1.0);

    final currencySymbol = _getCurrencySymbol(currencyCode);
    final currencyFormat = NumberFormat.currency(
      locale: 'en_IN',
      symbol: currencySymbol,
      decimalDigits: 0, // No decimals for Indian users
    );
    final percentFormat = NumberFormat.percentPattern();

    final now = DateTime.now();
    final monthName = DateFormat('MMMM yyyy').format(now);

    return SingleChildScrollView(
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
                      remaining < 0 ? const Color(0xFFEF4444) : kPrimaryPurple,
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
                      "Used",
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
                  "Budget Limit",
                  currencyFormat.format(budgetLimit),
                  kPrimarySlate,
                  kSecondarySlate,
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  child: Divider(height: 1, color: kBorderSlate),
                ),
                _buildStatRow(
                  "Total Spent",
                  currencyFormat.format(totalSpent),
                  kPrimarySlate,
                  kSecondarySlate,
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  child: Divider(height: 1, color: kBorderSlate),
                ),
                _buildStatRow(
                  "Remaining",
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

          // Quick Actions
          Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: () {
                    Navigator.pushNamed(context, '/budget-details');
                  },
                  icon: Icon(Icons.analytics_outlined, color: kPrimarySlate),
                  label: Text(
                    'View Details',
                    style: TextStyle(color: kPrimarySlate),
                  ),
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    side: BorderSide(color: kBorderSlate),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: () {
                    Navigator.pushNamed(context, '/set-monthly-budget');
                  },
                  icon: Icon(Icons.edit_outlined, color: kPrimarySlate),
                  label: Text(
                    'Edit Budget',
                    style: TextStyle(color: kPrimarySlate),
                  ),
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    side: BorderSide(color: kBorderSlate),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 12),

          // Category Budgets Button
          SizedBox(
            width: double.infinity,
            child: OutlinedButton.icon(
              onPressed: () {
                Navigator.pushNamed(context, '/set-category-budget');
              },
              icon: Icon(Icons.category_outlined, color: kPrimarySlate),
              label: Text(
                'Set Category Budgets',
                style: TextStyle(color: kPrimarySlate),
              ),
              style: OutlinedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 16),
                side: BorderSide(color: kBorderSlate),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ),

          // Category Budget Summary (if set)
          if (budgetProvider.categoryBudgets.isNotEmpty) ...[
            const SizedBox(height: 24),

            // Section Title
            Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: Text(
                'Category Budgets',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: kPrimarySlate,
                ),
              ),
            ),

            // Category Budget Cards (Compact - top 3)
            ...budgetProvider.categoryBudgets.entries.take(3).map((entry) {
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

              final categoryProgress = (categorySpent / categoryBudget.amount)
                  .clamp(0.0, 1.0);

              // Determine status color
              Color statusColor;
              if (categorySpent > categoryBudget.amount) {
                statusColor = const Color(0xFFEF4444); // Red
              } else if (categoryProgress >= 0.8) {
                statusColor = const Color(0xFFF59E0B); // Orange
              } else {
                statusColor = const Color(0xFF22C55E); // Green
              }

              return Padding(
                padding: const EdgeInsets.only(bottom: 8.0),
                child: Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: kCardBackground,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: kBorderSlate),
                  ),
                  child: Row(
                    children: [
                      // Category icon
                      Container(
                        padding: const EdgeInsets.all(6),
                        decoration: BoxDecoration(
                          color: category.color.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Icon(
                          category.icon,
                          color: category.color,
                          size: 16,
                        ),
                      ),
                      const SizedBox(width: 12),

                      // Category name and progress
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
                                    fontSize: 14,
                                    fontWeight: FontWeight.w600,
                                    color: kPrimarySlate,
                                  ),
                                ),
                                Text(
                                  '${(categoryProgress * 100).toStringAsFixed(0)}%',
                                  style: TextStyle(
                                    fontSize: 12,
                                    fontWeight: FontWeight.bold,
                                    color: statusColor,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 6),
                            ClipRRect(
                              borderRadius: BorderRadius.circular(2),
                              child: LinearProgressIndicator(
                                value: categoryProgress,
                                minHeight: 4,
                                backgroundColor: kAccentSlate,
                                valueColor: AlwaysStoppedAnimation<Color>(
                                  statusColor,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              );
            }),

            // View All link if more than 3
            if (budgetProvider.categoryBudgets.length > 3)
              Padding(
                padding: const EdgeInsets.only(top: 8),
                child: TextButton(
                  onPressed: () {
                    Navigator.pushNamed(context, '/budget-details');
                  },
                  child: Text(
                    'View all ${budgetProvider.categoryBudgets.length} categories',
                    style: TextStyle(color: kSecondarySlate),
                  ),
                ),
              ),
          ],
        ],
      ),
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

  Widget _buildMonthHeader(String monthName, BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final kPrimarySlate = isDark ? Colors.white : const Color(0xFF0F172A);
    final kSecondarySlate = isDark
        ? const Color(0xFF94A3B8)
        : const Color(0xFF64748B);
    final kAccentSlate = isDark
        ? const Color(0xFF1E293B)
        : const Color(0xFFF8FAFC);
    final kBorderSlate = isDark
        ? const Color(0xFF334155)
        : const Color(0xFFE2E8F0);

    return Container(
      padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 16),
      decoration: BoxDecoration(
        color: kAccentSlate,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: kBorderSlate),
      ),
      child: Column(
        children: [
          Text(
            "BUDGET FOR",
            style: TextStyle(
              color: kSecondarySlate,
              fontSize: 12,
              fontWeight: FontWeight.bold,
              letterSpacing: 1.0,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            monthName.toUpperCase(),
            style: TextStyle(
              color: kPrimarySlate,
              fontSize: 20,
              fontWeight: FontWeight.w900,
              letterSpacing: -0.5,
            ),
          ),
        ],
      ),
    );
  }

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
        return '\$';
    }
  }
}
