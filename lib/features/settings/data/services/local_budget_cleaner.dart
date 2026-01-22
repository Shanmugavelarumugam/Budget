import 'package:flutter/foundation.dart';
import 'package:hive_flutter/hive_flutter.dart';

/// Service to clear all local budget data
class LocalBudgetCleaner {
  /// Clear ALL budget data from Hive
  /// This includes:
  /// - Monthly budgets (budget_{monthId})
  /// - Category budgets (category_budgets_{monthId})
  static Future<void> clearAllBudgets() async {
    try {
      final box = Hive.box('guest_transactions');

      // Get all keys
      final allKeys = box.keys.toList();

      // Find and delete all budget-related keys
      for (final key in allKeys) {
        final keyStr = key.toString();

        // Delete budget keys (budget_2024-01, budget_2024-02, etc.)
        if (keyStr.startsWith('budget_')) {
          await box.delete(key);
          debugPrint('🗑️ Deleted budget key: $key');
        }

        // Delete category budget keys (category_budgets_2024-01, etc.)
        if (keyStr.startsWith('category_budgets_')) {
          await box.delete(key);
          debugPrint('🗑️ Deleted category budgets key: $key');
        }
      }

      debugPrint('✅ All budget data cleared from local storage');
    } catch (e) {
      debugPrint('❌ Error clearing budget data: $e');
      rethrow;
    }
  }
}
