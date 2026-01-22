import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class BudgetStatusCard extends StatelessWidget {
  final double totalSpent;
  final double budgetLimit;
  final bool isBudgetSet;
  final VoidCallback? onSetBudgetTap;
  final NumberFormat currencyFormat;
  final Color kCardBackground;
  final Color kPrimarySlate;
  final Color kSecondarySlate;
  final Color kAccentSlate;
  final Color kBorderSlate;

  const BudgetStatusCard({
    super.key,
    required this.totalSpent,
    required this.budgetLimit,
    this.isBudgetSet = true,
    this.onSetBudgetTap,
    required this.currencyFormat,
    required this.kCardBackground,
    required this.kPrimarySlate,
    required this.kSecondarySlate,
    required this.kAccentSlate,
    required this.kBorderSlate,
  });

  @override
  Widget build(BuildContext context) {
    // If budget is not set, show CTA
    if (!isBudgetSet) {
      return Container(
        margin: const EdgeInsets.symmetric(horizontal: 20),
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: kCardBackground,
          borderRadius: BorderRadius.circular(24),
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
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: kAccentSlate,
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.account_balance_wallet_outlined,
                size: 32,
                color: kPrimarySlate,
              ),
            ),
            const SizedBox(height: 16),
            Text(
              "No Monthly Budget Set",
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: kPrimarySlate,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              "Set a budget to track your spending and save more.",
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 14,
                color: kSecondarySlate,
                height: 1.5,
              ),
            ),
            const SizedBox(height: 20),
            SizedBox(
              width: double.infinity,
              height: 48,
              child: ElevatedButton(
                onPressed: onSetBudgetTap,
                style: ElevatedButton.styleFrom(
                  backgroundColor: kPrimarySlate,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  elevation: 0,
                ),
                child: Text(
                  "Set Budget",
                  style: TextStyle(
                    // FIXED: In Dark Mode, kPrimarySlate is White. Text must be Black.
                    color: kPrimarySlate == Colors.white
                        ? Colors.black
                        : Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          ],
        ),
      );
    }

    final remaining = budgetLimit - totalSpent;
    final progress = (totalSpent / budgetLimit).clamp(0.0, 1.0);
    final percentFormat = NumberFormat.percentPattern();

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: kCardBackground,
        borderRadius: BorderRadius.circular(24),
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
          // Header
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                "MONTHLY BUDGET",
                style: TextStyle(
                  color: kSecondarySlate,
                  fontSize: 10,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 1.0,
                ),
              ),
              Flexible(
                child: FittedBox(
                  fit: BoxFit.scaleDown,
                  alignment: Alignment.centerRight,
                  child: Text(
                    currencyFormat.format(budgetLimit),
                    style: TextStyle(
                      color: kPrimarySlate,
                      fontSize: 14,
                      fontWeight: FontWeight.w900,
                      letterSpacing: -0.5,
                    ),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          // Progress Bar
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: LinearProgressIndicator(
              value: progress,
              backgroundColor: kAccentSlate,
              valueColor: AlwaysStoppedAnimation<Color>(
                remaining < 0 ? const Color(0xFFEF4444) : kPrimarySlate,
              ),
              minHeight: 12,
            ),
          ),
          const SizedBox(height: 16),
          // Stats Row
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "Spent",
                    style: TextStyle(
                      color: kSecondarySlate,
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 4),
                  ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 160),
                    child: FittedBox(
                      fit: BoxFit.scaleDown,
                      alignment: Alignment.centerLeft,
                      child: Text(
                        currencyFormat.format(totalSpent),
                        style: TextStyle(
                          color: kPrimarySlate,
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          letterSpacing: -0.5,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    "Remaining",
                    style: TextStyle(
                      color: kSecondarySlate,
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 4),
                  ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 160),
                    child: FittedBox(
                      fit: BoxFit.scaleDown,
                      alignment: Alignment.centerRight,
                      child: Text(
                        currencyFormat.format(remaining),
                        style: TextStyle(
                          color: remaining < 0
                              ? const Color(0xFFEF4444) // Red-500
                              : const Color(0xFF22C55E), // Green-500
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          letterSpacing: -0.5,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 8),
          // Percent Text
          Align(
            alignment: Alignment.centerRight,
            child: Text(
              "${percentFormat.format(progress)} Used",
              style: TextStyle(
                color: kSecondarySlate,
                fontSize: 10,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
