import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../../../transactions/presentation/providers/transaction_provider.dart';
import '../../../auth/presentation/providers/auth_provider.dart';
import '../../../settings/presentation/providers/settings_provider.dart';
import '../../../budget/domain/entities/category_entity.dart';
import '../../../dashboard/presentation/widgets/blurred_blob.dart';
import '../../../../routes/route_names.dart';
import 'dart:math' as math;

class CategoryWiseReportScreen extends StatefulWidget {
  const CategoryWiseReportScreen({super.key});

  @override
  State<CategoryWiseReportScreen> createState() =>
      _CategoryWiseReportScreenState();
}

class _CategoryWiseReportScreenState extends State<CategoryWiseReportScreen> {
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

    // Filter and group expenses by category
    final monthlyExpenses = transactionProvider.transactions.where((t) {
      return t.isExpense &&
          t.date.month == _selectedDate.month &&
          t.date.year == _selectedDate.year;
    }).toList();

    final categoryTotals = <String, double>{};
    double totalSpend = 0;
    for (var t in monthlyExpenses) {
      categoryTotals[t.category] = (categoryTotals[t.category] ?? 0) + t.amount;
      totalSpend += t.amount;
    }

    final sortedCategories = categoryTotals.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));

    final currencySymbol = _getCurrencySymbol(settings.currency);

    return Scaffold(
      backgroundColor: kAppBackground,
      appBar: AppBar(
        title: Text(
          'Spending by Category',
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
          // Background Blobs
          Positioned(
            top: -100,
            right: -100,
            child: BlurredBlob(
              color: isDark
                  ? const Color(0xFF1E3A8A).withValues(alpha: 0.15)
                  : const Color(0xFFEFF6FF),
              size: 400,
            ),
          ),

          SafeArea(
            child: Column(
              children: [
                // Month Selector
                Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 20,
                    vertical: 8,
                  ),
                  child: _buildTimeSelector(
                    isDark,
                    kPrimarySlate,
                    kSecondarySlate,
                    kBorderSlate,
                    kAccentColor,
                  ),
                ),

                if (isGuest)
                  Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 20,
                      vertical: 8,
                    ),
                    child: _buildGuestNotice(isDark),
                  ),

                Expanded(
                  child: monthlyExpenses.isEmpty
                      ? _buildEmptyState(kSecondarySlate)
                      : SingleChildScrollView(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 20,
                            vertical: 16,
                          ),
                          child: Column(
                            children: [
                              // Chart Visualization
                              _buildChartSection(
                                sortedCategories,
                                totalSpend,
                                isDark,
                                kPrimarySlate,
                                kSecondarySlate,
                              ),

                              const SizedBox(height: 32),

                              // Category List
                              _buildSectionHeader(
                                "CATEGORY BREAKDOWN",
                                kSecondarySlate,
                              ),
                              ...sortedCategories.map((entry) {
                                final category = CategoryEntity.getById(
                                  entry.key,
                                );
                                final percentage =
                                    (entry.value / totalSpend) * 100;
                                return _buildCategoryRow(
                                  category,
                                  entry.value,
                                  percentage,
                                  currencySymbol,
                                  isDark,
                                  kPrimarySlate,
                                  kSecondarySlate,
                                  kBorderSlate,
                                );
                              }),

                              const SizedBox(height: 100),
                            ],
                          ),
                        ),
                ),
              ],
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
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
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
          Text(
            DateFormat('MMMM yyyy').format(_selectedDate).toUpperCase(),
            style: TextStyle(
              color: kPrimary,
              fontWeight: FontWeight.w900,
              fontSize: 13,
              letterSpacing: 0.5,
            ),
          ),
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

  Widget _buildChartSection(
    List<MapEntry<String, double>> data,
    double total,
    bool isDark,
    Color kPrimary,
    Color kSecondary,
  ) {
    return Container(
      padding: const EdgeInsets.all(32),
      decoration: BoxDecoration(
        color: isDark
            ? const Color(0xFF1E293B).withValues(alpha: 0.5)
            : Colors.white,
        borderRadius: BorderRadius.circular(32),
        boxShadow: isDark
            ? []
            : [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.02),
                  blurRadius: 20,
                  offset: const Offset(0, 10),
                ),
              ],
      ),
      child: Column(
        children: [
          SizedBox(
            height: 200,
            width: 200,
            child: Stack(
              children: [
                CustomPaint(
                  size: const Size(200, 200),
                  painter: DonutChartPainter(data),
                ),
                Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        "TOTAL SPENT",
                        style: TextStyle(
                          color: kSecondary,
                          fontSize: 10,
                          fontWeight: FontWeight.w800,
                          letterSpacing: 1.0,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        NumberFormat.compact().format(total),
                        style: TextStyle(
                          color: kPrimary,
                          fontSize: 28,
                          fontWeight: FontWeight.w900,
                          letterSpacing: -1.0,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCategoryRow(
    CategoryEntity category,
    double amount,
    double percentage,
    String symbol,
    bool isDark,
    Color kPrimary,
    Color kSecondary,
    Color kBorder,
  ) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: isDark
            ? const Color(0xFF1E293B).withValues(alpha: 0.7)
            : Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: kBorder.withValues(alpha: 0.5)),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () {
            // Drill down: Navigate to filtered transactions
            Navigator.pushNamed(
              context,
              RouteNames.transactions,
              arguments: {'category': category.name},
            );
          },
          borderRadius: BorderRadius.circular(20),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: category.color.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: Icon(category.icon, color: category.color, size: 22),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        category.name,
                        style: TextStyle(
                          color: kPrimary,
                          fontWeight: FontWeight.w900,
                          fontSize: 15,
                        ),
                      ),
                      const SizedBox(height: 4),
                      ClipRRect(
                        borderRadius: BorderRadius.circular(4),
                        child: LinearProgressIndicator(
                          value: percentage / 100,
                          backgroundColor: kBorder.withValues(alpha: 0.3),
                          color: category.color,
                          minHeight: 4,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 24),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      "$symbol${NumberFormat("#,##0").format(amount)}",
                      style: TextStyle(
                        color: kPrimary,
                        fontWeight: FontWeight.w900,
                        fontSize: 15,
                      ),
                    ),
                    Text(
                      "${percentage.toStringAsFixed(1)}%",
                      style: TextStyle(
                        color: kSecondary,
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSectionHeader(String title, Color kSecondary) {
    return Padding(
      padding: const EdgeInsets.only(left: 4, bottom: 16),
      child: Align(
        alignment: Alignment.centerLeft,
        child: Text(
          title,
          style: TextStyle(
            fontSize: 10,
            fontWeight: FontWeight.w900,
            color: kSecondary.withValues(alpha: 0.8),
            letterSpacing: 1.5,
          ),
        ),
      ),
    );
  }

  Widget _buildEmptyState(Color kSecondary) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.donut_large_rounded,
            size: 80,
            color: kSecondary.withValues(alpha: 0.2),
          ),
          const SizedBox(height: 24),
          Text(
            "No spending found",
            style: TextStyle(
              color: kSecondary,
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            "Add some transactions to see a breakdown.",
            style: TextStyle(
              color: kSecondary.withValues(alpha: 0.7),
              fontSize: 13,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildGuestNotice(bool isDark) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFF6366F1).withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: const Color(0xFF6366F1).withValues(alpha: 0.1),
        ),
      ),
      child: Row(
        children: [
          const Icon(Icons.info_outline, color: Color(0xFF6366F1), size: 16),
          const SizedBox(width: 12),
          const Text(
            "Based on data stored on this device",
            style: TextStyle(
              color: Color(0xFF6366F1),
              fontSize: 11,
              fontWeight: FontWeight.w700,
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

class DonutChartPainter extends CustomPainter {
  final List<MapEntry<String, double>> data;

  DonutChartPainter(this.data);

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2;
    final total = data.fold(0.0, (sum, entry) => sum + entry.value);

    if (total == 0) return;

    double startAngle = -math.pi / 2;
    final paint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 30
      ..strokeCap = StrokeCap.round;

    for (var entry in data) {
      final sweepAngle = (entry.value / total) * 2 * math.pi;
      final category = CategoryEntity.getById(entry.key);

      paint.color = category.color;
      canvas.drawArc(
        Rect.fromCircle(center: center, radius: radius - 15),
        startAngle + 0.05, // Small gap
        sweepAngle - 0.1,
        false,
        paint,
      );
      startAngle += sweepAngle;
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}
