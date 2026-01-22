import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../../../../routes/route_names.dart';
import '../../presentation/providers/goal_provider.dart';
import '../../domain/entities/goal_entity.dart';
import '../../../dashboard/presentation/widgets/blurred_blob.dart';
import '../../../auth/presentation/providers/auth_provider.dart';
import '../../../settings/presentation/providers/settings_provider.dart';

class GoalsListScreen extends StatefulWidget {
  const GoalsListScreen({super.key});

  @override
  State<GoalsListScreen> createState() => _GoalsListScreenState();
}

class _GoalsListScreenState extends State<GoalsListScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final auth = context.read<AuthProvider>();
      context.read<GoalProvider>().updateUser(auth.user);
    });
  }

  @override
  Widget build(BuildContext context) {
    final goalProvider = context.watch<GoalProvider>();
    final settings = context.watch<SettingsProvider>();
    final isDark = Theme.of(context).brightness == Brightness.dark;

    // Theme Colors (Matches BudgetOverview)
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
          'Savings Goals',
          style: TextStyle(color: kPrimarySlate, fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        backgroundColor: kAppBackground,
        elevation: 0,
        iconTheme: IconThemeData(color: kPrimarySlate),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => Navigator.pushNamed(context, RouteNames.addGoal),
        backgroundColor: kPrimarySlate,
        foregroundColor: isDark ? Colors.black : Colors.white,
        elevation: 4,
        icon: const Icon(Icons.add_rounded),
        label: const Text(
          "New Goal",
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
      ),
      body: Stack(
        children: [
          // Subtle Background Blob
          Positioned(
            top: -100,
            right: -50,
            child: BlurredBlob(
              color: isDark
                  ? kPrimaryPurple.withValues(alpha: 0.15)
                  : const Color(0xFFF3E8FF),
              size: 300,
            ),
          ),

          goalProvider.isLoading
              ? const Center(child: CircularProgressIndicator())
              : goalProvider.goals.isEmpty
              ? _buildEmptyState(kSecondarySlate, kPrimarySlate)
              : ListView.separated(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 20,
                    vertical: 24,
                  ),
                  itemCount: goalProvider.goals.length,
                  separatorBuilder: (context, index) =>
                      const SizedBox(height: 16),
                  itemBuilder: (context, index) {
                    final goal = goalProvider.goals[index];
                    return _buildGoalCard(
                      context,
                      goal,
                      isDark,
                      kPrimarySlate,
                      kSecondarySlate,
                      kCardBackground,
                      kBorderSlate,
                      kPrimaryPurple,
                      currencySymbol,
                    );
                  },
                ),
        ],
      ),
    );
  }

  Widget _buildGoalCard(
    BuildContext context,
    GoalEntity goal,
    bool isDark,
    Color kPrimary,
    Color kSecondary,
    Color kCardBg,
    Color kBorder,
    Color kAccent,
    String symbol,
  ) {
    final isCompleted = goal.isCompleted;
    final progressColor = isCompleted ? const Color(0xFF10B981) : kAccent;

    return Container(
      decoration: BoxDecoration(
        color: kCardBg,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: isCompleted
              ? const Color(0xFF10B981).withValues(alpha: 0.3)
              : kBorder,
        ),
        boxShadow: isDark
            ? []
            : [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.03),
                  blurRadius: 15,
                  offset: const Offset(0, 8),
                ),
              ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () => Navigator.pushNamed(
            context,
            RouteNames.goalDetails,
            arguments: goal,
          ),
          borderRadius: BorderRadius.circular(24),
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: progressColor.withValues(alpha: 0.1),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        isCompleted
                            ? Icons.emoji_events_rounded
                            : Icons.flag_rounded,
                        color: progressColor,
                        size: 20,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            goal.name,
                            style: TextStyle(
                              color: kPrimary,
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            isCompleted
                                ? "Goal Reached!"
                                : "Target: $symbol${NumberFormat.compact().format(goal.targetAmount)}",
                            style: TextStyle(color: kSecondary, fontSize: 13),
                          ),
                        ],
                      ),
                    ),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text(
                          "$symbol${NumberFormat.compact().format(goal.currentAmount)}",
                          style: TextStyle(
                            color: kPrimary,
                            fontWeight: FontWeight.w900,
                            fontSize: 16,
                          ),
                        ),
                        Text(
                          "${(goal.progress * 100).toInt()}%",
                          style: TextStyle(
                            color: progressColor,
                            fontWeight: FontWeight.bold,
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),

                const SizedBox(height: 16),

                // Slim Progress Bar
                ClipRRect(
                  borderRadius: BorderRadius.circular(6),
                  child: LinearProgressIndicator(
                    value: goal.progress,
                    backgroundColor: isDark
                        ? Colors.black26
                        : const Color(0xFFF1F5F9),
                    color: progressColor,
                    minHeight: 8,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildEmptyState(Color kSecondary, Color kPrimary) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.savings_outlined,
            size: 64,
            color: kSecondary.withValues(alpha: 0.5),
          ),
          const SizedBox(height: 16),
          Text(
            "No goals yet",
            style: TextStyle(
              color: kPrimary,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            "Set a target and start saving!",
            style: TextStyle(color: kSecondary, fontSize: 14),
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
