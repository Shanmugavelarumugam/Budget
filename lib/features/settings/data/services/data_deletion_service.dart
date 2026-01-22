import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';

/// Service to handle complete data deletion for user reset
class DataDeletionService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  /// Delete ALL user data from Firestore
  /// This includes: transactions, budgets (with category subcollections), categories, goals, shared_members, audit_logs
  Future<void> deleteAllUserData(String userId) async {
    try {
      debugPrint('🗑️ Starting deletion for user: $userId');

      // List of top-level subcollections to delete
      final collections = [
        'transactions',
        'budgets', // This will be handled specially to delete subcollections
        'categories',
        'goals',
        'shared_members',
        'audit_logs',
        'alerts',
      ];

      // Delete each collection
      for (final collection in collections) {
        debugPrint('🗑️ Deleting collection: $collection');

        if (collection == 'budgets') {
          // Special handling for budgets - delete category subcollections first
          await _deleteBudgetsWithCategories(userId);
        } else {
          // Regular collection deletion
          final snapshot = await _firestore
              .collection('users')
              .doc(userId)
              .collection(collection)
              .get();

          debugPrint(
            '📊 Found ${snapshot.docs.length} documents in $collection',
          );

          for (final doc in snapshot.docs) {
            await doc.reference.delete();
          }
        }

        debugPrint('✅ Deleted $collection');
      }

      // Delete the user document itself
      debugPrint('🗑️ Deleting user document');
      await _firestore.collection('users').doc(userId).delete();

      debugPrint('✅ All Firestore data deleted for user: $userId');
    } catch (e) {
      debugPrint('❌ Error deleting Firestore data: $e');
      rethrow;
    }
  }

  /// Delete budgets and their category subcollections
  Future<void> _deleteBudgetsWithCategories(String userId) async {
    final budgetsSnapshot = await _firestore
        .collection('users')
        .doc(userId)
        .collection('budgets')
        .get();

    debugPrint('📊 Found ${budgetsSnapshot.docs.length} budget documents');

    for (final budgetDoc in budgetsSnapshot.docs) {
      // Delete category subcollection for this budget
      final categoriesSnapshot = await budgetDoc.reference
          .collection('categories')
          .get();

      debugPrint(
        '📊 Found ${categoriesSnapshot.docs.length} categories in budget ${budgetDoc.id}',
      );

      for (final categoryDoc in categoriesSnapshot.docs) {
        await categoryDoc.reference.delete();
      }

      // Delete the budget document itself
      await budgetDoc.reference.delete();
    }
  }

  /// Delete only guest/local data (for guest users)
  Future<void> deleteGuestData() async {
    // This is handled by TransactionProvider.clearGuestData()
    debugPrint('✅ Guest data cleared');
  }
}
