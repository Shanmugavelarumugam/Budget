import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../../../transactions/presentation/providers/transaction_provider.dart';
import '../../../settings/presentation/providers/settings_provider.dart';
import '../../../dashboard/presentation/widgets/blurred_blob.dart';
import '../../../../routes/route_names.dart';

class MonthlyReportScreen extends StatefulWidget {
  const MonthlyReportScreen({super.key});

  @override
  State<MonthlyReportScreen> createState() => _MonthlyReportScreenState();
}

class _MonthlyReportScreenState extends State<MonthlyReportScreen> {
  DateTime _selectedDate = DateTime(DateTime.now().year, DateTime.now().month);

  @override
  Widget build(BuildContext context) {
    final transactionProvider = context.watch<TransactionProvider>();
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
      return t.date.month == _selectedDate.month &&
          t.date.year == _selectedDate.year;
    }).toList();

    final totalIncome = monthlyTransactions
        .where((t) => t.isIncome)
        .fold(0.0, (sum, t) => sum + t.amount);
    final totalExpense = monthlyTransactions
        .where((t) => t.isExpense)
        .fold(0.0, (sum, t) => sum + t.amount);
    final netSavings = totalIncome - totalExpense;

    final currencySymbol = _getCurrencySymbol(settings.currency);

    return Scaffold(
      backgroundColor: kAppBackground,
      appBar: AppBar(
        title: Text(
          'Monthly Health Check',
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
            left: -100,
            child: BlurredBlob(
              color: isDark
                  ? const Color(0xFF1E3A8A).withValues(alpha: 0.15)
                  : const Color(0xFFEFF6FF),
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

                  // Summary Cards
                  Row(
                    children: [
                      Expanded(
                        child: _buildCompactSummaryCard(
                          "INCOME",
                          totalIncome,
                          const Color(0xFF10B981),
                          isDark,
                          kBorderSlate,
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: _buildCompactSummaryCard(
                          "EXPENSE",
                          totalExpense,
                          const Color(0xFFEF4444),
                          isDark,
                          kBorderSlate,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  _buildSavingsCard(
                    netSavings,
                    isDark,
                    kPrimarySlate,
                    kSecondarySlate,
                    kBorderSlate,
                    currencySymbol,
                  ),

                  const SizedBox(height: 40),

                  // Highlights Section
                  _buildSectionHeader("FINANCIAL HIGHLIGHTS", kSecondarySlate),
                  _buildHighlightTile(
                    "Balance Progress",
                    netSavings >= 0
                        ? "You saved ${NumberFormat.compact().format(netSavings)} this month."
                        : "You spent more than you earned.",
                    netSavings >= 0
                        ? Icons.trending_up_rounded
                        : Icons.trending_down_rounded,
                    netSavings >= 0
                        ? const Color(0xFF10B981)
                        : const Color(0xFFEF4444),
                    isDark,
                    kPrimarySlate,
                    kBorderSlate,
                  ),

                  // Action Links
                  const SizedBox(height: 40),
                  _buildSectionHeader("QUICK ACTIONS", kSecondarySlate),
                  _buildActionLink(
                    context,
                    "View Detailed Spending",
                    "Deep dive into category distribution",
                    Icons.pie_chart_rounded,
                    RouteNames.categoryReport,
                    isDark,
                    kPrimarySlate,
                    kSecondarySlate,
                    kBorderSlate,
                  ),
                  _buildActionLink(
                    context,
                    "Check Budget Status",
                    "Compare actual spend vs. your plan",
                    Icons.track_changes_rounded,
                    RouteNames.budgetVsActual,
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
            onPressed:
                _selectedDate.month == DateTime.now().month &&
                    _selectedDate.year == DateTime.now().year
                ? null
                : () => setState(
                    () => _selectedDate = DateTime(
                      _selectedDate.year,
                      _selectedDate.month + 1,
                    ),
                  ),
            icon: Icon(
              Icons.chevron_right_rounded,
              color:
                  _selectedDate.month == DateTime.now().month &&
                      _selectedDate.year == DateTime.now().year
                  ? kSecondary.withValues(alpha: 0.3)
                  : kPrimary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCompactSummaryCard(
    String label,
    double amount,
    Color color,
    bool isDark,
    Color kBorder,
  ) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: isDark
            ? const Color(0xFF1E293B).withValues(alpha: 0.5)
            : Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: kBorder.withValues(alpha: 0.5)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: TextStyle(
              color: color,
              fontSize: 10,
              fontWeight: FontWeight.w900,
              letterSpacing: 1.0,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            NumberFormat.compact().format(amount),
            style: TextStyle(
              color: isDark ? Colors.white : const Color(0xFF0F172A),
              fontSize: 20,
              fontWeight: FontWeight.w900,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSavingsCard(
    double amount,
    bool isDark,
    Color kPrimary,
    Color kSecondary,
    Color kBorder,
    String symbol,
  ) {
    final isPositive = amount >= 0;
    final color = isPositive
        ? const Color(0xFF10B981)
        : const Color(0xFFEF4444);

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(28),
        border: Border.all(color: color.withValues(alpha: 0.15)),
      ),
      child: Column(
        children: [
          Text(
            "NET SAVINGS",
            style: TextStyle(
              color: color,
              fontSize: 11,
              fontWeight: FontWeight.w900,
              letterSpacing: 1.5,
            ),
          ),
          const SizedBox(height: 12),
          Text(
            "$symbol${NumberFormat("#,##0").format(amount)}",
            style: TextStyle(
              color: color,
              fontSize: 32,
              fontWeight: FontWeight.w900,
              letterSpacing: -1.0,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            isPositive
                ? "Great job! You stayed profitable."
                : "Watch out! Your spending exceeded income.",
            style: TextStyle(
              color: color.withValues(alpha: 0.8),
              fontSize: 12,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHighlightTile(
    String title,
    String subtitle,
    IconData icon,
    Color color,
    bool isDark,
    Color kPrimary,
    Color kBorder,
  ) {
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
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: color, size: 20),
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
                    fontSize: 15,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  subtitle,
                  style: TextStyle(
                    color: kPrimary.withValues(alpha: 0.6),
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionLink(
    BuildContext context,
    String title,
    String subtitle,
    IconData icon,
    String route,
    bool isDark,
    Color kPrimary,
    Color kSecondary,
    Color kBorder,
  ) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: isDark
            ? const Color(0xFF1E293B).withValues(alpha: 0.5)
            : Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: kBorder.withValues(alpha: 0.5)),
      ),
      child: ListTile(
        onTap: () => Navigator.pushNamed(context, route),
        leading: Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: kPrimary.withValues(alpha: 0.05),
            borderRadius: BorderRadius.circular(16),
          ),
          child: Icon(icon, color: kPrimary, size: 22),
        ),
        title: Text(
          title,
          style: TextStyle(
            color: kPrimary,
            fontWeight: FontWeight.w900,
            fontSize: 15,
          ),
        ),
        subtitle: Text(
          subtitle,
          style: TextStyle(color: kSecondary, fontSize: 12),
        ),
        trailing: Icon(
          Icons.arrow_forward_ios_rounded,
          size: 14,
          color: kSecondary,
        ),
        contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 4),
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
