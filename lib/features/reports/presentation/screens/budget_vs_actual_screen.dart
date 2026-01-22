import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../../../transactions/presentation/providers/transaction_provider.dart';
import '../../../budget/presentation/providers/budget_provider.dart';
import '../../../settings/presentation/providers/settings_provider.dart';
import '../../../budget/domain/entities/category_entity.dart';
import '../../../dashboard/presentation/widgets/blurred_blob.dart';
import '../../../../routes/route_names.dart';

class BudgetVsActualScreen extends StatefulWidget {
  const BudgetVsActualScreen({super.key});

  @override
  State<BudgetVsActualScreen> createState() => _BudgetVsActualScreenState();
}

class _BudgetVsActualScreenState extends State<BudgetVsActualScreen> {
  DateTime _selectedDate = DateTime(DateTime.now().year, DateTime.now().month);

  @override
  Widget build(BuildContext context) {
    final transactionProvider = context.watch<TransactionProvider>();
    final budgetProvider = context.watch<BudgetProvider>();
    final settings = context.watch<SettingsProvider>();

    final isDark = Theme.of(context).brightness == Brightness.dark;
    final kAppBackground = isDark ? const Color(0xFF0F172A) : Colors.white;
    final kPrimarySlate = isDark ? Colors.white : const Color(0xFF0F172A);
    final kSecondarySlate = isDark
        ? const Color(0xFF94A3B8)
        : const Color(0xFF64748B);
    final kBorderSlate = isDark
        ? const Color(0xFF334155)
        : const Color(0xFFE2E8F0);
    const kAccentColor = Color(0xFF6366F1);

    // Filter Transactions for the selected month
    final monthlyTransactions = transactionProvider.transactions.where((t) {
      return t.isExpense &&
          t.date.month == _selectedDate.month &&
          t.date.year == _selectedDate.year;
    }).toList();

    final actualTotal = monthlyTransactions.fold(
      0.0,
      (sum, t) => sum + t.amount,
    );

    // Budget logic (Assuming current month for simplicity as Provider usually handles current)
    // For historical comparison, BudgetProvider might need adjustment, but here we use current budget amount as reference.
    final budgetLimit = budgetProvider.currentBudget?.amount ?? 5000.0;
    final remaining = budgetLimit - actualTotal;
    final progress = (actualTotal / budgetLimit).clamp(0.0, 1.0);

    final currencySymbol = _getCurrencySymbol(settings.currency);

    return Scaffold(
      backgroundColor: kAppBackground,
      appBar: AppBar(
        title: Text(
          'Budget adherence',
          style: TextStyle(
            color: kPrimarySlate,
            fontWeight: FontWeight.w900,
            fontSize: 20,
            letterSpacing: -0.5,
          ),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: false,
        iconTheme: IconThemeData(color: kPrimarySlate),
      ),
      extendBodyBehindAppBar: true,
      body: Stack(
        children: [
          Positioned(
            top: -50,
            right: -100,
            child: BlurredBlob(
              color: isDark
                  ? const Color(0xFF581C87).withValues(alpha: 0.15)
                  : const Color(0xFFF5F3FF),
              size: 400,
            ),
          ),

          SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildTimeSelector(
                    isDark,
                    kPrimarySlate,
                    kSecondarySlate,
                    kBorderSlate,
                    kAccentColor,
                  ),

                  const SizedBox(height: 32),

                  // 1. Overall Budget Card
                  _buildOverallBudgetCard(
                    actualTotal,
                    budgetLimit,
                    remaining,
                    progress,
                    isDark,
                    kPrimarySlate,
                    kSecondarySlate,
                    kBorderSlate,
                    currencySymbol,
                  ),

                  const SizedBox(height: 40),

                  // 2. Category-wise Comparison
                  _buildSectionHeader("CATEGORY PERFORMANCE", kSecondarySlate),
                  _buildCategoryComparisonList(
                    monthlyTransactions,
                    budgetProvider,
                    isDark,
                    kPrimarySlate,
                    kSecondarySlate,
                    kBorderSlate,
                    currencySymbol,
                  ),

                  const SizedBox(height: 40),

                  // 3. Insights
                  _buildSectionHeader("BUDGET INSIGHTS", kSecondarySlate),
                  _buildInsightsList(
                    actualTotal,
                    budgetLimit,
                    remaining,
                    isDark,
                    kPrimarySlate,
                    kBorderSlate,
                  ),

                  const SizedBox(height: 100),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTimeSelector(
    bool isDark,
    Color kPrimary,
    Color kSecondary,
    Color kBorder,
    Color kAccent,
  ) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: isDark
            ? const Color(0xFF1E293B).withValues(alpha: 0.7)
            : Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: kBorder.withValues(alpha: 0.5)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          IconButton(
            onPressed: () => setState(
              () => _selectedDate = DateTime(
                _selectedDate.year,
                _selectedDate.month - 1,
              ),
            ),
            icon: Icon(Icons.chevron_left_rounded, color: kPrimary),
          ),
          const SizedBox(width: 12),
          Text(
            DateFormat('MMMM yyyy').format(_selectedDate).toUpperCase(),
            style: TextStyle(
              color: kPrimary,
              fontWeight: FontWeight.w900,
              fontSize: 13,
              letterSpacing: 0.5,
            ),
          ),
          const SizedBox(width: 12),
          IconButton(
            onPressed: () => setState(
              () => _selectedDate = DateTime(
                _selectedDate.year,
                _selectedDate.month + 1,
              ),
            ),
            icon: Icon(Icons.chevron_right_rounded, color: kPrimary),
          ),
        ],
      ),
    );
  }

  Widget _buildOverallBudgetCard(
    double actual,
    double budget,
    double remaining,
    double progress,
    bool isDark,
    Color kPrimary,
    Color kSecondary,
    Color kBorder,
    String symbol,
  ) {
    final statusColor = progress > 0.9
        ? const Color(0xFFEF4444)
        : progress > 0.7
        ? const Color(0xFFF59E0B)
        : const Color(0xFF10B981);

    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: isDark
            ? const Color(0xFF1E293B).withValues(alpha: 0.7)
            : Colors.white,
        borderRadius: BorderRadius.circular(32),
        border: Border.all(color: kBorder.withValues(alpha: 0.5), width: 1.5),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "ACTUAL SPENT",
                    style: TextStyle(
                      color: kSecondary,
                      fontSize: 10,
                      fontWeight: FontWeight.w800,
                      letterSpacing: 1.0,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    "$symbol${NumberFormat("#,##0").format(actual)}",
                    style: TextStyle(
                      color: kPrimary,
                      fontSize: 24,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                ],
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    "PLAN LIMIT",
                    style: TextStyle(
                      color: kSecondary,
                      fontSize: 10,
                      fontWeight: FontWeight.w800,
                      letterSpacing: 1.0,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    "$symbol${NumberFormat("#,##0").format(budget)}",
                    style: TextStyle(
                      color: kPrimary.withValues(alpha: 0.7),
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 24),
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: LinearProgressIndicator(
              value: progress,
              backgroundColor: kBorder.withValues(alpha: 0.3),
              color: statusColor,
              minHeight: 12,
            ),
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                remaining >= 0
                    ? "Under by $symbol${NumberFormat("#,##0").format(remaining)}"
                    : "Over by $symbol${NumberFormat("#,##0").format(remaining.abs())}",
                style: TextStyle(
                  color: statusColor,
                  fontWeight: FontWeight.w800,
                  fontSize: 13,
                ),
              ),
              Text(
                "${(progress * 100).toInt()}% USED",
                style: TextStyle(
                  color: kSecondary,
                  fontWeight: FontWeight.w800,
                  fontSize: 13,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildCategoryComparisonList(
    List monthlyTransactions,
    BudgetProvider budgetProvider,
    bool isDark,
    Color kPrimary,
    Color kSecondary,
    Color kBorder,
    String symbol,
  ) {
    final catTotals = <String, double>{};
    for (var t in monthlyTransactions) {
      catTotals[t.category] = (catTotals[t.category] ?? 0) + t.amount;
    }

    // Include all categories that have a budget, even if no spending
    for (var cb in budgetProvider.categoryBudgets.values) {
      if (!catTotals.containsKey(CategoryEntity.getById(cb.categoryId).name)) {
        // This is a bit tricky since transactions use category names while budget uses category IDs
        // Normalized comparison needed but for this implementation let's map by name.
      }
    }

    return Column(
      children: budgetProvider.categoryBudgets.values.map((cb) {
        final category = CategoryEntity.getById(cb.categoryId);
        final actual = catTotals[category.name] ?? 0.0;
        final budget = cb.amount;
        final progress = (actual / budget).clamp(0.0, 1.0);
        final isOver = actual > budget;

        return Container(
          margin: const EdgeInsets.only(bottom: 12),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: isDark
                ? const Color(0xFF1E293B).withValues(alpha: 0.5)
                : Colors.white,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: kBorder.withValues(alpha: 0.5)),
          ),
          child: Column(
            children: [
              Row(
                children: [
                  Icon(category.icon, color: category.color, size: 18),
                  const SizedBox(width: 12),
                  Text(
                    category.name,
                    style: TextStyle(
                      color: kPrimary,
                      fontWeight: FontWeight.w900,
                      fontSize: 15,
                    ),
                  ),
                  const Spacer(),
                  if (isOver)
                    Icon(
                      Icons.error_rounded,
                      color: const Color(0xFFEF4444),
                      size: 16,
                    )
                  else
                    Icon(
                      Icons.check_circle_rounded,
                      color: const Color(0xFF10B981),
                      size: 16,
                    ),
                ],
              ),
              const SizedBox(height: 12),
              ClipRRect(
                borderRadius: BorderRadius.circular(4),
                child: LinearProgressIndicator(
                  value: progress,
                  backgroundColor: kBorder.withValues(alpha: 0.2),
                  color: isOver ? const Color(0xFFEF4444) : category.color,
                  minHeight: 4,
                ),
              ),
              const SizedBox(height: 8),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    "$symbol${NumberFormat.compact().format(actual)} / $symbol${NumberFormat.compact().format(budget)}",
                    style: TextStyle(
                      color: kSecondary,
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  Text(
                    isOver
                        ? "+$symbol${NumberFormat.compact().format(actual - budget)}"
                        : "-$symbol${NumberFormat.compact().format(budget - actual)}",
                    style: TextStyle(
                      color: isOver
                          ? const Color(0xFFEF4444)
                          : const Color(0xFF10B981),
                      fontSize: 12,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ],
              ),
            ],
          ),
        );
      }).toList(),
    );
  }

  Widget _buildInsightsList(
    double actual,
    double budget,
    double remaining,
    bool isDark,
    Color kPrimary,
    Color kBorder,
  ) {
    return Column(
      children: [
        _buildSimpleInsight(
          remaining >= 0
              ? "You're doing great! Stay consistent to reach your goal."
              : "You've exceeded your plan. Review recent high categories.",
          remaining >= 0
              ? Icons.emoji_events_rounded
              : Icons.priority_high_rounded,
          remaining >= 0 ? const Color(0xFF10B981) : const Color(0xFFF59E0B),
          isDark,
          kPrimary,
          kBorder,
        ),
        const SizedBox(height: 12),
        SizedBox(
          width: double.infinity,
          height: 56,
          child: OutlinedButton(
            onPressed: () =>
                Navigator.pushNamed(context, RouteNames.budgetOverview),
            style: OutlinedButton.styleFrom(
              side: BorderSide(color: kBorder),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
              ),
            ),
            child: Text(
              "Adjust My Budget Plan",
              style: TextStyle(color: kPrimary, fontWeight: FontWeight.w800),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildSimpleInsight(
    String text,
    IconData icon,
    Color color,
    bool isDark,
    Color kPrimary,
    Color kBorder,
  ) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          Icon(icon, color: color, size: 20),
          const SizedBox(width: 14),
          Expanded(
            child: Text(
              text,
              style: TextStyle(
                color: kPrimary,
                fontSize: 13,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(String title, Color kSecondary) {
    return Padding(
      padding: const EdgeInsets.only(left: 4, bottom: 16),
      child: Text(
        title,
        style: TextStyle(
          fontSize: 10,
          fontWeight: FontWeight.w900,
          color: kSecondary.withValues(alpha: 0.8),
          letterSpacing: 1.5,
        ),
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
        return '₹';
    }
  }
}
