import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../../presentation/providers/goal_provider.dart'; // Re-added GoalProvider
import '../../../../core/utils/digit_normalizer.dart';
import '../../domain/entities/goal_entity.dart';
import '../../../dashboard/presentation/widgets/blurred_blob.dart';
import '../../../settings/presentation/providers/settings_provider.dart';

class GoalDetailsScreen extends StatefulWidget {
  final GoalEntity initialGoal;

  const GoalDetailsScreen({super.key, required this.initialGoal});

  @override
  State<GoalDetailsScreen> createState() => _GoalDetailsScreenState();
}

class _GoalDetailsScreenState extends State<GoalDetailsScreen> {
  late String _goalId;

  @override
  void initState() {
    super.initState();
    _goalId = widget.initialGoal.id;
  }

  @override
  Widget build(BuildContext context) {
    // Listen to provider updates
    final goalProvider = context.watch<GoalProvider>();
    final settings = context.watch<SettingsProvider>();

    // Safety check for deleted goals
    final goalIndex = goalProvider.goals.indexWhere((g) => g.id == _goalId);
    if (goalIndex == -1) {
      return const SizedBox.shrink();
    }

    final goal = goalProvider.goals[goalIndex];
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
    const kPrimaryPurple = Color(0xFF8B5CF6);

    final currencySymbol = _getCurrencySymbol(settings.currency);

    return Scaffold(
      backgroundColor: kAppBackground,
      appBar: AppBar(
        title: Text(
          "Goal Details",
          style: TextStyle(color: kPrimarySlate, fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        backgroundColor: kAppBackground,
        elevation: 0,
        iconTheme: IconThemeData(color: kPrimarySlate),
        actions: [
          IconButton(
            icon: const Icon(
              Icons.delete_outline_rounded,
              color: Colors.redAccent,
            ),
            onPressed: () => _confirmDelete(context, goal.id),
          ),
        ],
      ),
      body: Stack(
        children: [
          Positioned(
            top: -150,
            right: -100,
            child: BlurredBlob(
              color: goal.isCompleted
                  ? const Color(0xFF10B981).withValues(alpha: 0.1)
                  : kPrimaryPurple.withValues(alpha: 0.1),
              size: 400,
            ),
          ),

          SafeArea(
            child: Column(
              children: [
                Expanded(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 24,
                      vertical: 20,
                    ),
                    child: Column(
                      children: [
                        // Hero Progress
                        _buildHeroProgress(
                          goal,
                          isDark,
                          kPrimarySlate,
                          kSecondarySlate,
                          kCardBackground,
                          kBorderSlate,
                          kPrimaryPurple,
                          currencySymbol,
                        ),

                        const SizedBox(height: 32),

                        // Action: Add Savings
                        if (!goal.isCompleted)
                          SizedBox(
                            width: double.infinity,
                            height: 56,
                            child: ElevatedButton.icon(
                              onPressed: () => _showContributionDialog(
                                context,
                                goal,
                                currencySymbol,
                                kPrimarySlate,
                                isDark,
                              ),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: kPrimarySlate,
                                foregroundColor: isDark
                                    ? Colors.black
                                    : Colors.white,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(16),
                                ),
                                elevation: 0,
                              ),
                              icon: const Icon(Icons.savings_rounded),
                              label: const Text(
                                "Add Savings",
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16,
                                ),
                              ),
                            ),
                          )
                        else
                          Container(
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            width: double.infinity,
                            decoration: BoxDecoration(
                              color: const Color(
                                0xFF10B981,
                              ).withValues(alpha: 0.1),
                              borderRadius: BorderRadius.circular(16),
                              border: Border.all(
                                color: const Color(
                                  0xFF10B981,
                                ).withValues(alpha: 0.3),
                              ),
                            ),
                            child: const Center(
                              child: Text(
                                "Goal Achieved! 🎉",
                                style: TextStyle(
                                  color: Color(0xFF10B981),
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16,
                                ),
                              ),
                            ),
                          ),

                        const SizedBox(height: 32),

                        // Detailed Breakdown
                        _buildBreakdownSection(
                          goal,
                          kPrimarySlate,
                          kSecondarySlate,
                          currencySymbol,
                        ),

                        _buildRecentHistory(
                          goal,
                          kPrimarySlate,
                          kSecondarySlate,
                          currencySymbol,
                        ),
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

  Widget _buildHeroProgress(
    GoalEntity goal,
    bool isDark,
    Color kPrimary,
    Color kSecondary,
    Color kCardBg,
    Color kBorder,
    Color kAccent,
    String symbol,
  ) {
    final progressColor = goal.isCompleted ? const Color(0xFF10B981) : kAccent;

    return Container(
      padding: const EdgeInsets.all(32),
      decoration: BoxDecoration(
        color: kCardBg,
        borderRadius: BorderRadius.circular(32),
        border: Border.all(color: kBorder),
        boxShadow: isDark
            ? []
            : [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.05),
                  blurRadius: 20,
                  offset: const Offset(0, 10),
                ),
              ],
      ),
      child: Column(
        children: [
          SizedBox(
            height: 160,
            width: 160,
            child: Stack(
              fit: StackFit.expand,
              children: [
                CircularProgressIndicator(
                  value: goal.progress,
                  strokeWidth: 12,
                  backgroundColor: isDark
                      ? Colors.black12
                      : const Color(0xFFF1F5F9),
                  valueColor: AlwaysStoppedAnimation<Color>(progressColor),
                  strokeCap: StrokeCap.round,
                ),
                Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        "${(goal.progress * 100).toInt()}%",
                        style: TextStyle(
                          color: kPrimary,
                          fontSize: 32,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                      Text(
                        "Saved",
                        style: TextStyle(
                          color: kSecondary,
                          fontSize: 13,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),
          Text(
            goal.name,
            textAlign: TextAlign.center,
            style: TextStyle(
              color: kPrimary,
              fontSize: 20,
              fontWeight: FontWeight.w900,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            "Target: $symbol${NumberFormat("#,##0").format(goal.targetAmount)}",
            style: TextStyle(
              color: kSecondary,
              fontSize: 15,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBreakdownSection(
    GoalEntity goal,
    Color kPrimary,
    Color kSecondary,
    String symbol,
  ) {
    return Column(
      children: [
        _buildStatRow(
          "Saved So Far",
          "$symbol${NumberFormat("#,##0").format(goal.currentAmount)}",
          kPrimary,
          kSecondary,
          isBold: true,
        ),
        const Padding(
          padding: EdgeInsets.symmetric(vertical: 16),
          child: Divider(height: 1),
        ),
        _buildStatRow(
          "Remaining",
          "$symbol${NumberFormat("#,##0").format(goal.remainingAmount)}",
          kPrimary,
          kSecondary,
          isBold: true,
        ),
        const Padding(
          padding: EdgeInsets.symmetric(vertical: 16),
          child: Divider(height: 1),
        ),
        _buildStatRow(
          "Target Date",
          goal.targetDate != null
              ? DateFormat.yMMMd().format(goal.targetDate!)
              : "No date set",
          kPrimary,
          kSecondary,
        ),
        if (goal.description != null && goal.description!.isNotEmpty) ...[
          const Padding(
            padding: EdgeInsets.symmetric(vertical: 16),
            child: Divider(height: 1),
          ),
          Align(
            alignment: Alignment.centerLeft,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "NOTES",
                  style: TextStyle(
                    color: kSecondary,
                    fontSize: 11,
                    fontWeight: FontWeight.w900,
                    letterSpacing: 1.0,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  goal.description!,
                  style: TextStyle(color: kPrimary, fontSize: 15, height: 1.5),
                ),
              ],
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildRecentHistory(
    GoalEntity goal,
    Color kPrimary,
    Color kSecondary,
    String symbol,
  ) {
    if (goal.logs.isEmpty) return const SizedBox.shrink();

    // Sort logs by date descending (newest first)
    final sortedLogs = List<GoalLogEntity>.from(goal.logs)
      ..sort((a, b) => b.date.compareTo(a.date));

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 32),
        Text(
          "HISTORY",
          style: TextStyle(
            color: kSecondary,
            fontSize: 11,
            fontWeight: FontWeight.w900,
            letterSpacing: 1.0,
          ),
        ),
        const SizedBox(height: 16),
        ...sortedLogs.map((log) {
          return Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    DateFormat.yMMMd().format(log.date),
                    style: TextStyle(
                      color: kSecondary,
                      fontSize: 15,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  Text(
                    '+$symbol${NumberFormat("#,##0").format(log.amount)}',
                    style: TextStyle(
                      color: const Color(0xFF10B981), // Green for success
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ],
              ),
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 16),
                child: Divider(
                  height: 1,
                  color: kSecondary.withValues(alpha: 0.1),
                ),
              ),
            ],
          );
        }),
      ],
    );
  }

  Widget _buildStatRow(
    String label,
    String value,
    Color kPrimary,
    Color kSecondary, {
    bool isBold = false,
  }) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: TextStyle(
            color: kSecondary,
            fontSize: 15,
            fontWeight: FontWeight.w500,
          ),
        ),
        Text(
          value,
          style: TextStyle(
            color: kPrimary,
            fontSize: 16,
            fontWeight: isBold ? FontWeight.w800 : FontWeight.w600,
          ),
        ),
      ],
    );
  }

  void _showContributionDialog(
    BuildContext context,
    GoalEntity goal,
    String symbol,
    Color kPrimary,
    bool isDark,
  ) {
    final amountController = TextEditingController();
    showModelBottomSheetStyled(
      context,
      amountController,
      symbol,
      goal,
      kPrimary,
      isDark,
    );
  }

  void showModelBottomSheetStyled(
    BuildContext context,
    TextEditingController controller,
    String symbol,
    GoalEntity goal,
    Color kPrimary,
    bool isDark,
  ) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(context).viewInsets.bottom + 24,
          top: 24,
          left: 24,
          right: 24,
        ),
        decoration: BoxDecoration(
          color: Theme.of(context).scaffoldBackgroundColor,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(32)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              "Add Savings",
              textAlign: TextAlign.center,
              style: TextStyle(
                color: kPrimary,
                fontSize: 20,
                fontWeight: FontWeight.w900,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              "How much do you want to add?",
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.grey, fontSize: 14),
            ),
            const SizedBox(height: 32),
            TextField(
              controller: controller,
              keyboardType: const TextInputType.numberWithOptions(
                decimal: true,
              ),
              textAlign: TextAlign.center,
              style: TextStyle(
                color: kPrimary,
                fontSize: 32,
                fontWeight: FontWeight.w900,
              ),
              decoration: InputDecoration(
                hintText: '0',
                prefixText: symbol,
                prefixStyle: TextStyle(
                  fontSize: 32,
                  fontWeight: FontWeight.w900,
                  color: kPrimary,
                ),
                border: InputBorder.none,
              ),
              autofocus: true,
              inputFormatters: [DigitNormalizer()],
            ),
            const SizedBox(height: 32),
            SizedBox(
              height: 56,
              child: ElevatedButton(
                onPressed: () {
                  final amount = double.tryParse(controller.text);
                  if (amount != null && amount > 0) {
                    context.read<GoalProvider>().contributeToGoal(
                      goal.id,
                      amount,
                    );
                    Navigator.pop(context);
                  }
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: kPrimary,
                  foregroundColor: isDark ? Colors.black : Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  elevation: 0,
                ),
                child: const Text(
                  "Add Amount",
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _confirmDelete(BuildContext context, String goalId) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Delete Goal?"),
        content: const Text(
          "Are you sure you want to delete this goal? This action cannot be undone.",
        ),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Cancel"),
          ),
          TextButton(
            onPressed: () {
              context.read<GoalProvider>().deleteGoal(goalId);
              Navigator.pop(context);
              Navigator.pop(context);
            },
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text("Delete"),
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
