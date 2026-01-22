import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../../../transactions/presentation/providers/transaction_provider.dart';
import '../../../transactions/domain/entities/transaction_entity.dart';
import '../../../auth/presentation/providers/auth_provider.dart';
import '../../../settings/presentation/providers/settings_provider.dart';
import '../../../budget/presentation/providers/budget_provider.dart';
import '../../../../routes/route_names.dart';
import 'conversion_banner.dart';
import 'budget_status_card.dart';
import 'category_budget_summary.dart';
import 'top_spending_card.dart';
import 'modern_transaction_card.dart';

class HomeTab extends StatelessWidget {
  final VoidCallback? onSetBudgetTap;
  final VoidCallback? onSeeAllTransactions;
  final VoidCallback? onDrawerMenuTap;

  const HomeTab({
    super.key,
    this.onSetBudgetTap,
    this.onSeeAllTransactions,
    this.onDrawerMenuTap,
  });

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();
    final transactionProvider = context.watch<TransactionProvider>();
    final budgetProvider = context.watch<BudgetProvider>();
    final settings = context.watch<SettingsProvider>(); // Listen to settings

    final user = auth.user;
    final isGuest = user?.isGuest ?? false;

    // Budget Logic (from BudgetProvider)
    final currentBudget = budgetProvider.currentBudget;
    final budgetLimit =
        currentBudget?.amount ?? 5000.0; // Default or locally stored
    final isBudgetSet = currentBudget != null;

    // Use MONTHLY Data from Provider (Respecting Start of Month)
    final balance = transactionProvider.balance;
    final income = transactionProvider.monthlyIncome;
    final expense = transactionProvider.monthlyExpense;

    final transactions = transactionProvider.transactions;
    final recentTransactions = transactions.take(5);

    // Group Transactions by Date
    final groupedTransactions = <String, List<TransactionEntity>>{};
    for (var t in recentTransactions) {
      final dateKey = _getDateKey(t.date);
      if (!groupedTransactions.containsKey(dateKey)) {
        groupedTransactions[dateKey] = [];
      }
      groupedTransactions[dateKey]!.add(t);
    }

    // Calculate Top Spending (Monthly)
    final monthlyTransactions = transactionProvider.monthlyTransactions;
    final expenseTransactions = monthlyTransactions.where((t) => t.isExpense);
    final categoryTotals = <String, double>{};
    for (var t in expenseTransactions) {
      categoryTotals[t.category] = (categoryTotals[t.category] ?? 0) + t.amount;
    }
    final sortedCategories = categoryTotals.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));
    final topCategories = sortedCategories.take(3).toList();

    // Dynamic Currency & Theme
    final currencySymbol = _getCurrencySymbol(settings.currency);
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

    final currencyFormat = NumberFormat.currency(
      locale: 'en_IN', // We can keep locale or map settings.currency to locale
      symbol: currencySymbol,
      decimalDigits: 0, // No decimals for Indian users
    );

    return Stack(
      children: [
        CustomScrollView(
          slivers: [
            // 1. Header Row
            SliverPadding(
              padding: EdgeInsets.only(
                top: MediaQuery.of(context).padding.top + 8,
                left: 20,
                right: 20,
                bottom: 24,
              ),
              sliver: SliverToBoxAdapter(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        Container(
                          width: 44,
                          height: 44,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            border: Border.all(color: kBorderSlate, width: 2),
                            color: kAccentSlate,
                            image: user?.photoUrl != null
                                ? DecorationImage(
                                    image: NetworkImage(user!.photoUrl!),
                                    fit: BoxFit.cover,
                                  )
                                : null,
                          ),
                          child: user?.photoUrl == null
                              ? Icon(Icons.person, color: kSecondarySlate)
                              : null,
                        ),
                        const SizedBox(width: 12),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              "WELCOME BACK",
                              style: TextStyle(
                                color: kSecondarySlate,
                                fontSize: 10,
                                fontWeight: FontWeight.bold,
                                letterSpacing: 1.0,
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              user?.displayName ??
                                  (isGuest ? "Guest User" : "User"),
                              style: TextStyle(
                                color: kPrimarySlate,
                                fontWeight: FontWeight.w900,
                                fontSize: 20,
                                letterSpacing: -0.5,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            color: kCardBackground,
                            shape: BoxShape.circle,
                            border: Border.all(color: kBorderSlate),
                          ),
                          child: Icon(
                            Icons.notifications_outlined,
                            color: kPrimarySlate,
                            size: 20,
                          ),
                        ),
                        const SizedBox(width: 12),
                        GestureDetector(
                          onTap: onDrawerMenuTap,
                          child: Container(
                            padding: const EdgeInsets.all(10),
                            decoration: BoxDecoration(
                              color: kCardBackground,
                              shape: BoxShape.circle,
                              border: Border.all(color: kBorderSlate),
                            ),
                            child: Icon(
                              Icons.segment_rounded,
                              color: kPrimarySlate,
                              size: 20,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),

            // 2. ATM Card Structure
            SliverToBoxAdapter(
              child: Container(
                margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 0),
                height: 220,
                width: double.infinity,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(24),
                  gradient: const LinearGradient(
                    colors: [
                      Color(0xFF0F172A), // Slate 900
                      Color(0xFF334155), // Slate 700
                    ],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.4),
                      blurRadius: 20,
                      offset: const Offset(0, 10),
                    ),
                  ],
                ),
                child: Stack(
                  children: [
                    // Texture/Circles
                    Positioned(
                      top: -40,
                      right: -40,
                      child: Container(
                        width: 150,
                        height: 150,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: Colors.white.withValues(alpha: 0.1),
                        ),
                      ),
                    ),
                    Positioned(
                      bottom: -40,
                      left: -40,
                      child: Container(
                        width: 150,
                        height: 150,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: Colors.white.withValues(alpha: 0.05),
                        ),
                      ),
                    ),

                    // Content
                    Padding(
                      padding: const EdgeInsets.all(24.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              // Imitate Chip
                              Container(
                                width: 40,
                                height: 28,
                                decoration: BoxDecoration(
                                  color: Colors.amber.withValues(alpha: 0.8),
                                  borderRadius: BorderRadius.circular(6),
                                ),
                              ),
                              const Text(
                                "VISA",
                                style: TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.w900,
                                  fontStyle: FontStyle.italic,
                                  fontSize: 22,
                                ),
                              ),
                            ],
                          ),

                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                "Total Balance",
                                style: TextStyle(
                                  color: Colors.white.withValues(alpha: 0.8),
                                  fontSize: 14,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                              const SizedBox(height: 4),
                              FittedBox(
                                fit: BoxFit.scaleDown,
                                alignment: Alignment.centerLeft,
                                child: Text(
                                  currencyFormat.format(balance),
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 32,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ],
                          ),

                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              const Text(
                                "**** **** **** 2002",
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 16,
                                  letterSpacing: 1.5,
                                  fontFamily: 'monospace',
                                ),
                              ),
                              Text(
                                "11/18",
                                style: TextStyle(
                                  color: Colors.white.withValues(alpha: 0.8),
                                  fontSize: 14,
                                  fontFamily: 'monospace',
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),

            const SliverPadding(padding: EdgeInsets.only(bottom: 24)),

            // 3. Stats Row (Income / Expense)
            SliverPadding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              sliver: SliverToBoxAdapter(
                child: Row(
                  children: [
                    Expanded(
                      child: Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: kCardBackground,
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(color: kBorderSlate),
                        ),
                        child: Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(8),
                              decoration: BoxDecoration(
                                color: const Color(
                                  0xFFD9F46C,
                                ).withValues(alpha: 0.1),
                                shape: BoxShape.circle,
                              ),
                              child: const Icon(
                                Icons.arrow_downward,
                                color: Color(0xFF6B8E23),
                                size: 18,
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              // Prevent overflow
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    "Income",
                                    style: TextStyle(
                                      color: kSecondarySlate,
                                      fontSize: 12,
                                    ),
                                  ),
                                  Text(
                                    currencyFormat.format(income),
                                    maxLines: 1,
                                    style: TextStyle(
                                      color: kPrimarySlate,
                                      fontWeight: FontWeight.bold,
                                      fontSize: 14,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: kCardBackground,
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(color: kBorderSlate),
                        ),
                        child: Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(8),
                              decoration: BoxDecoration(
                                color: Colors.red.withValues(alpha: 0.1),
                                shape: BoxShape.circle,
                              ),
                              child: const Icon(
                                Icons.arrow_upward,
                                color: Colors.red,
                                size: 18,
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              // Prevent overflow
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    "Expense",
                                    style: TextStyle(
                                      color: kSecondarySlate,
                                      fontSize: 12,
                                    ),
                                  ),
                                  Text(
                                    currencyFormat.format(expense),
                                    maxLines: 1,
                                    style: TextStyle(
                                      color: kPrimarySlate,
                                      fontWeight: FontWeight.bold,
                                      fontSize: 14,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),

            const SliverPadding(padding: EdgeInsets.only(bottom: 24)),

            // Budget Status Card
            SliverToBoxAdapter(
              child: BudgetStatusCard(
                totalSpent: expense,
                budgetLimit: budgetLimit,
                isBudgetSet: isBudgetSet,
                onSetBudgetTap: onSetBudgetTap,
                currencyFormat: currencyFormat,
                kCardBackground: kCardBackground,
                kPrimarySlate: kPrimarySlate,
                kSecondarySlate: kSecondarySlate,
                kAccentSlate: kAccentSlate,
                kBorderSlate: kBorderSlate,
              ),
            ),

            const SliverPadding(padding: EdgeInsets.only(bottom: 16)),

            // Category Budget Summary (if set)
            if (budgetProvider.categoryBudgets.isNotEmpty)
              SliverToBoxAdapter(
                child: CategoryBudgetSummary(
                  budgetProvider: budgetProvider,
                  transactionProvider: transactionProvider,
                  kCardBackground: kCardBackground,
                  kPrimarySlate: kPrimarySlate,
                  kSecondarySlate: kSecondarySlate,
                  kAccentSlate: kAccentSlate,
                  kBorderSlate: kBorderSlate,
                ),
              ),

            if (budgetProvider.categoryBudgets.isNotEmpty)
              const SliverPadding(padding: EdgeInsets.only(bottom: 16)),

            const SliverPadding(padding: EdgeInsets.only(bottom: 32)),

            // Conversion Banner (Guest Mode)
            const SliverToBoxAdapter(child: ConversionBanner()),

            // Recent Transactions Header
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Recent Transactions',
                      style: TextStyle(
                        color: kPrimarySlate,
                        fontSize: 18,
                        fontWeight: FontWeight.w900,
                        letterSpacing: -0.5,
                      ),
                    ),
                    GestureDetector(
                      onTap: onSeeAllTransactions,
                      child: Text(
                        'See All',
                        style: TextStyle(
                          color: kPrimarySlate,
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),

            const SliverPadding(padding: EdgeInsets.only(bottom: 16)),

            // Transactions List (Modern Cards)
            if (groupedTransactions.isEmpty)
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.all(32.0),
                  child: Center(
                    child: Text(
                      "No transactions yet.",
                      style: TextStyle(color: kSecondarySlate),
                    ),
                  ),
                ),
              )
            else
              SliverList(
                delegate: SliverChildBuilderDelegate((context, index) {
                  final dateKey = groupedTransactions.keys.elementAt(index);
                  final transactionsForDate = groupedTransactions[dateKey]!;

                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: transactionsForDate
                        .map(
                          (t) => ModernTransactionCard(
                            transaction: t,
                            currencyFormat: currencyFormat,
                            kCardBackground: kCardBackground,
                            kPrimarySlate: kPrimarySlate,
                            kSecondarySlate: kSecondarySlate,
                            kAccentSlate: kAccentSlate,
                            kBorderSlate: kBorderSlate,
                          ),
                        )
                        .toList(),
                  );
                }, childCount: groupedTransactions.length),
              ),

            const SliverPadding(padding: EdgeInsets.only(bottom: 24)),

            // Top Spending Categories (Moved here)
            if (topCategories.isNotEmpty)
              SliverToBoxAdapter(
                child: TopSpendingCard(
                  topCategories: topCategories,
                  totalExpense: expense,
                  currencyFormat: currencyFormat,
                  kCardBackground: kCardBackground,
                  kPrimarySlate: kPrimarySlate,
                  kSecondarySlate: kSecondarySlate,
                  kAccentSlate: kAccentSlate,
                  kBorderSlate: kBorderSlate,
                ),
              ),

            // Bottom spacer for FAB and Guest Banner
            SliverPadding(
              padding: EdgeInsets.only(bottom: isGuest ? 180 : 100),
            ),
          ],
        ),

        // Guest Mode Overlay (Bottom)
        if (isGuest)
          Positioned(
            left: 20,
            right: 20,
            bottom: 100, // Above NavBar
            child: Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: kCardBackground,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: kBorderSlate),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.05),
                    blurRadius: 10,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Row(
                children: [
                  Icon(Icons.info_outline, color: kSecondarySlate),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      "You are in Guest Mode. Data will not be saved.",
                      style: TextStyle(color: kPrimarySlate, fontSize: 12),
                    ),
                  ),
                  TextButton(
                    onPressed: () {
                      Navigator.of(context).pushNamedAndRemoveUntil(
                        RouteNames.welcome,
                        (route) => false,
                      );
                    },
                    style: TextButton.styleFrom(
                      foregroundColor: const Color(0xFF8B5CF6),
                    ),
                    child: const Text("Sign In"),
                  ),
                ],
              ),
            ),
          ),
      ],
    );
  }

  String _getDateKey(DateTime date) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final yesterday = today.subtract(const Duration(days: 1));
    final transactionDate = DateTime(date.year, date.month, date.day);

    if (transactionDate == today) return 'Today';
    if (transactionDate == yesterday) return 'Yesterday';
    return DateFormat('MMM d, yyyy').format(date);
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
        return currencyCode;
    }
  }
}
