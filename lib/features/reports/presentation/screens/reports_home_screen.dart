import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../../../transactions/presentation/providers/transaction_provider.dart';
import '../../../auth/presentation/providers/auth_provider.dart';
import '../../../settings/presentation/providers/settings_provider.dart';
import '../../../../routes/route_names.dart';
import '../../../dashboard/presentation/widgets/blurred_blob.dart';

class ReportsHomeScreen extends StatefulWidget {
  const ReportsHomeScreen({super.key});

  @override
  State<ReportsHomeScreen> createState() => _ReportsHomeScreenState();
}

class _ReportsHomeScreenState extends State<ReportsHomeScreen> {
  DateTime _selectedDate = DateTime(DateTime.now().year, DateTime.now().month);

  @override
  Widget build(BuildContext context) {
    final transactionProvider = context.watch<TransactionProvider>();
    final auth = context.watch<AuthProvider>();
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

    final isGuest = auth.user?.isGuest ?? false;

    // Filter Transactions for the selected month
    final filteredTransactions = transactionProvider.transactions.where((t) {
      return t.date.month == _selectedDate.month &&
          t.date.year == _selectedDate.year;
    }).toList();

    final totalIncome = filteredTransactions
        .where((t) => t.isIncome)
        .fold(0.0, (sum, t) => sum + t.amount);
    final totalExpense = filteredTransactions
        .where((t) => t.isExpense)
        .fold(0.0, (sum, t) => sum + t.amount);
    final netSavings = totalIncome - totalExpense;

    final currencySymbol = _getCurrencySymbol(settings.currency);

    return Scaffold(
      backgroundColor: kAppBackground,
      appBar: AppBar(
        title: Text(
          'Financial Insights',
          style: TextStyle(
            color: kPrimarySlate,
            fontWeight: FontWeight.w900,
            fontSize: 22,
            letterSpacing: -0.5,
          ),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        scrolledUnderElevation: 0,
        centerTitle: false,
      ),
      extendBodyBehindAppBar: true,
      body: Stack(
        children: [
          // Background Blobs for Visual Depth
          Positioned(
            top: -100,
            left: -100,
            child: BlurredBlob(
              color: isDark
                  ? const Color(0xFF1E3A8A).withValues(alpha: 0.15)
                  : const Color(0xFFEFF6FF),
              size: 400,
            ),
          ),
          Positioned(
            bottom: -50,
            right: -100,
            child: BlurredBlob(
              color: isDark
                  ? const Color(0xFF581C87).withValues(alpha: 0.15)
                  : const Color(0xFFF5F3FF),
              size: 350,
            ),
          ),

          SafeArea(
            child: transactionProvider.transactions.isEmpty
                ? _buildEmptyState(context, kSecondarySlate, kPrimarySlate)
                : SingleChildScrollView(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 20,
                      vertical: 16,
                    ),
                    physics: const BouncingScrollPhysics(),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // 1. Time Selector (The Control Point)
                        _buildTimeSelector(
                          isDark,
                          kPrimarySlate,
                          kSecondarySlate,
                          kBorderSlate,
                          kAccentColor,
                        ),

                        const SizedBox(height: 24),

                        if (isGuest) _buildGuestNotice(isDark),

                        // 2. Summary Overview (Top Card)
                        _buildSummaryCard(
                          isDark,
                          kPrimarySlate,
                          kSecondarySlate,
                          kBorderSlate,
                          totalIncome,
                          totalExpense,
                          netSavings,
                          currencySymbol,
                        ),

                        const SizedBox(height: 32),

                        // 3. Quick Report Cards (Entry Points)
                        _buildSectionHeader(
                          "DETAILED ANALYSIS",
                          kSecondarySlate,
                        ),
                        _buildReportCard(
                          context,
                          title: "Category-wise Spending",
                          subtitle: "Where did your money go?",
                          icon: Icons.pie_chart_rounded,
                          route: RouteNames.categoryReport,
                          color: const Color(0xFF6366F1),
                          isDark: isDark,
                          kPrimary: kPrimarySlate,
                          kSecondary: kSecondarySlate,
                          kBorder: kBorderSlate,
                        ),
                        _buildReportCard(
                          context,
                          title: "Income vs Expense",
                          subtitle: "Balance over this period",
                          icon: Icons.compare_arrows_rounded,
                          route: RouteNames.monthlyReport,
                          color: const Color(0xFF10B981),
                          isDark: isDark,
                          kPrimary: kPrimarySlate,
                          kSecondary: kSecondarySlate,
                          kBorder: kBorderSlate,
                        ),
                        _buildReportCard(
                          context,
                          title: "Budget vs Actual",
                          subtitle: "Tracking adherence",
                          icon: Icons.track_changes_rounded,
                          route: RouteNames.budgetVsActual,
                          color: const Color(0xFFF59E0B),
                          isDark: isDark,
                          kPrimary: kPrimarySlate,
                          kSecondary: kSecondarySlate,
                          kBorder: kBorderSlate,
                        ),

                        const SizedBox(height: 32),

                        // 4. Top Insights
                        _buildSectionHeader(
                          "MONTHLY INSIGHTS",
                          kSecondarySlate,
                        ),
                        if (filteredTransactions.isEmpty)
                          _buildInsightItem(
                            "No data available for the selected period.",
                            Icons.cloud_off_rounded,
                            kSecondarySlate,
                            isDark,
                            kPrimarySlate,
                            kBorderSlate,
                          )
                        else
                          _buildInsightsList(
                            filteredTransactions,
                            totalExpense,
                            isDark,
                            kPrimarySlate,
                            kSecondarySlate,
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
            onPressed: () {
              setState(() {
                _selectedDate = DateTime(
                  _selectedDate.year,
                  _selectedDate.month - 1,
                );
              });
            },
            icon: Icon(Icons.chevron_left_rounded, color: kPrimary),
            visualDensity: VisualDensity.compact,
          ),
          const SizedBox(width: 12),
          Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Text(
                DateFormat('MMMM yyyy').format(_selectedDate).toUpperCase(),
                style: TextStyle(
                  color: kPrimary,
                  fontWeight: FontWeight.w900,
                  fontSize: 14,
                  letterSpacing: 0.5,
                ),
              ),
              if (_selectedDate.month == DateTime.now().month &&
                  _selectedDate.year == DateTime.now().year)
                Text(
                  "CURRENT MONTH",
                  style: TextStyle(
                    color: kAccent,
                    fontSize: 9,
                    fontWeight: FontWeight.w900,
                    letterSpacing: 1.0,
                  ),
                ),
            ],
          ),
          const SizedBox(width: 12),
          IconButton(
            onPressed:
                _selectedDate.year >= DateTime.now().year &&
                    _selectedDate.month >= DateTime.now().month
                ? null
                : () {
                    setState(() {
                      _selectedDate = DateTime(
                        _selectedDate.year,
                        _selectedDate.month + 1,
                      );
                    });
                  },
            icon: Icon(
              Icons.chevron_right_rounded,
              color:
                  _selectedDate.year >= DateTime.now().year &&
                      _selectedDate.month >= DateTime.now().month
                  ? kSecondary.withValues(alpha: 0.3)
                  : kPrimary,
            ),
            visualDensity: VisualDensity.compact,
          ),
        ],
      ),
    );
  }

  Widget _buildSummaryCard(
    bool isDark,
    Color kPrimary,
    Color kSecondary,
    Color kBorder,
    double income,
    double expense,
    double savings,
    String symbol,
  ) {
    final format = NumberFormat.currency(symbol: symbol, decimalDigits: 0);
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: isDark
            ? const Color(0xFF1E293B).withValues(alpha: 0.7)
            : Colors.white,
        borderRadius: BorderRadius.circular(32),
        border: Border.all(color: kBorder.withValues(alpha: 0.5), width: 1.5),
        boxShadow: isDark
            ? []
            : [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.04),
                  blurRadius: 30,
                  offset: const Offset(0, 15),
                ),
              ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          _buildSummaryItem(
            "INCOME",
            income,
            const Color(0xFF10B981),
            kSecondary,
            format,
          ),
          _buildSummaryItem(
            "EXPENSES",
            expense,
            const Color(0xFFEF4444),
            kSecondary,
            format,
          ),
          _buildSummaryItem(
            "NET SAVINGS",
            savings,
            const Color(0xFF6366F1),
            kSecondary,
            format,
          ),
        ],
      ),
    );
  }

  Widget _buildSummaryItem(
    String label,
    double amount,
    Color color,
    Color kSecondary,
    NumberFormat format,
  ) {
    return Column(
      children: [
        Text(
          label,
          style: TextStyle(
            color: kSecondary,
            fontSize: 9,
            fontWeight: FontWeight.w900,
            letterSpacing: 1.2,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          format.format(amount.abs()),
          style: TextStyle(
            color: amount < 0 && label == "NET SAVINGS"
                ? const Color(0xFFEF4444)
                : color,
            fontSize: 16,
            fontWeight: FontWeight.w900,
            letterSpacing: -0.5,
          ),
        ),
      ],
    );
  }

  Widget _buildReportCard(
    BuildContext context, {
    required String title,
    required String subtitle,
    required IconData icon,
    required String route,
    required Color color,
    required bool isDark,
    required Color kPrimary,
    required Color kSecondary,
    required Color kBorder,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: isDark
            ? const Color(0xFF1E293B).withValues(alpha: 0.7)
            : Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: kBorder.withValues(alpha: 0.5)),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () => Navigator.pushNamed(context, route),
          borderRadius: BorderRadius.circular(24),
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: color.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Icon(icon, color: color, size: 26),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: TextStyle(
                          color: kPrimary,
                          fontWeight: FontWeight.w900,
                          fontSize: 17,
                          letterSpacing: -0.4,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        subtitle,
                        style: TextStyle(
                          color: kSecondary,
                          fontSize: 13,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
                Icon(
                  Icons.chevron_right_rounded,
                  color: kSecondary.withValues(alpha: 0.5),
                  size: 20,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildInsightsList(
    List filteredTransactions,
    double totalExpense,
    bool isDark,
    Color kPrimary,
    Color kSecondary,
    Color kBorder,
  ) {
    final expenses = filteredTransactions.where((t) => t.isExpense).toList();
    if (expenses.isEmpty) {
      return _buildInsightItem(
        "No expenses recorded for this month.",
        Icons.info_outline_rounded,
        kSecondary,
        isDark,
        kPrimary,
        kBorder,
      );
    }

    final categoryTotals = <String, double>{};
    for (var t in expenses) {
      categoryTotals[t.category] = (categoryTotals[t.category] ?? 0) + t.amount;
    }

    final highestCategory = categoryTotals.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));

    final topCat = highestCategory.first;

    return Column(
      children: [
        _buildInsightItem(
          "${topCat.key} was your highest spending category.",
          Icons.trending_up_rounded,
          const Color(0xFFEF4444),
          isDark,
          kPrimary,
          kBorder,
        ),
        _buildInsightItem(
          "You've managed ${filteredTransactions.length} transactions this month.",
          Icons.analytics_outlined,
          const Color(0xFF6366F1),
          isDark,
          kPrimary,
          kBorder,
        ),
        if (totalExpense > 0)
          _buildInsightItem(
            "Overall, you've maintained clear financial visibility. 🎉",
            Icons.check_circle_outline_rounded,
            const Color(0xFF10B981),
            isDark,
            kPrimary,
            kBorder,
          ),
      ],
    );
  }

  Widget _buildInsightItem(
    String text,
    IconData icon,
    Color color,
    bool isDark,
    Color kPrimary,
    Color kBorder,
  ) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withValues(alpha: 0.1)),
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
                fontWeight: FontWeight.w700,
                height: 1.4,
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
          color: kSecondary.withValues(alpha: 0.6),
          letterSpacing: 1.5,
        ),
      ),
    );
  }

  Widget _buildGuestNotice(bool isDark) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      margin: const EdgeInsets.only(bottom: 24),
      decoration: BoxDecoration(
        color: const Color(0xFF6366F1).withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: const Color(0xFF6366F1).withValues(alpha: 0.2),
        ),
      ),
      child: Row(
        children: [
          const Icon(
            Icons.cloud_off_rounded,
            color: Color(0xFF6366F1),
            size: 18,
          ),
          const SizedBox(width: 12),
          const Expanded(
            child: Text(
              "Reports are based on local guest data. Cloud sync is not available.",
              style: TextStyle(
                color: Color(0xFF6366F1),
                fontSize: 11,
                fontWeight: FontWeight.w800,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState(
    BuildContext context,
    Color kSecondary,
    Color kPrimary,
  ) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.assessment_outlined,
            size: 80,
            color: kSecondary.withValues(alpha: 0.2),
          ),
          const SizedBox(height: 24),
          Text(
            "Start your analysis",
            style: TextStyle(
              color: kPrimary,
              fontSize: 20,
              fontWeight: FontWeight.w900,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            "Your spending patterns will appear here.",
            style: TextStyle(
              color: kSecondary,
              fontSize: 14,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 32),
          ElevatedButton(
            onPressed: () =>
                Navigator.pushNamed(context, RouteNames.addTransaction),
            style: ElevatedButton.styleFrom(
              backgroundColor: kPrimary,
              foregroundColor: Theme.of(context).brightness == Brightness.dark
                  ? Colors.black
                  : Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 18),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
              ),
              elevation: 0,
            ),
            child: const Text(
              "Add First Transaction",
              style: TextStyle(fontWeight: FontWeight.w900, fontSize: 15),
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
        return '₹';
    }
  }
}
