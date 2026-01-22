import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../../transactions/domain/entities/transaction_entity.dart';
import '../../../budget/domain/entities/category_entity.dart';

class ModernTransactionCard extends StatelessWidget {
  final TransactionEntity transaction;
  final NumberFormat currencyFormat;
  final Color kCardBackground;
  final Color kPrimarySlate;
  final Color kSecondarySlate;
  final Color kAccentSlate;
  final Color kBorderSlate;

  const ModernTransactionCard({
    super.key,
    required this.transaction,
    required this.currencyFormat,
    required this.kCardBackground,
    required this.kPrimarySlate,
    required this.kSecondarySlate,
    required this.kAccentSlate,
    required this.kBorderSlate,
  });

  @override
  Widget build(BuildContext context) {
    final category = CategoryEntity.getById(transaction.category);
    final isExpense = transaction.isExpense;

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: kCardBackground,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: kBorderSlate),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: kAccentSlate,
              shape: BoxShape.circle,
            ),
            child: Icon(category.icon, color: kPrimarySlate, size: 20),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  transaction.description ?? category.name,
                  style: TextStyle(
                    color: kPrimarySlate,
                    fontWeight: FontWeight.bold,
                    fontSize: 15,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  DateFormat('d MMM, yyyy').format(transaction.date),
                  style: TextStyle(color: kSecondarySlate, fontSize: 12),
                ),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 120),
                child: FittedBox(
                  fit: BoxFit.scaleDown,
                  alignment: Alignment.centerRight,
                  child: Text(
                    (isExpense ? '-' : '+') +
                        currencyFormat.format(transaction.amount),
                    style: TextStyle(
                      color: isExpense
                          ? const Color(0xFFEF4444) // Red-500
                          : const Color(0xFF22C55E), // Green-500
                      fontWeight: FontWeight.bold,
                      fontSize: 15,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 4),
              Text(
                category.name,
                style: TextStyle(
                  color: kSecondarySlate,
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
