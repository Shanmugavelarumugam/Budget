import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../../domain/entities/transaction_entity.dart';
import '../models/transaction_model.dart';

/// Guest Data Migration Service
///
/// CRITICAL SAFETY RULE:
/// Guest data must only be deleted AFTER Firestore batch write succeeds.
/// Never before. Never during.
///
/// This protects against:
/// - Network failure
/// - App crash
/// - Partial migration
class GuestDataMigrationService {
  final FlutterSecureStorage _storage;

  GuestDataMigrationService({FlutterSecureStorage? storage})
    : _storage = storage ?? const FlutterSecureStorage();

  /// Migrates guest transaction data to Firestore for a newly registered user
  ///
  /// This operation is:
  /// 1. Idempotent - Running it twice doesn't duplicate data
  /// 2. Transactional - All or nothing (best effort)
  /// 3. One-time only - Flag prevents re-running
  ///
  /// Returns true if migration was successful or already completed
  /// Returns false if migration failed (guest data is preserved)
  Future<bool> migrateGuestDataToFirestore(String userId) async {
    try {
      // Check if migration already completed (idempotency)
      final migrationFlag = await _storage.read(
        key: 'migration_completed_$userId',
      );
      if (migrationFlag == 'true') {
        // print('Migration already completed for user $userId');
        return true;
      }

      // Read guest transactions from Hive
      final guestBox = Hive.box('guest_transactions');
      if (guestBox.isEmpty) {
        // print('No guest data to migrate');
        await _storage.write(key: 'migration_completed_$userId', value: 'true');
        return true;
      }

      final transactions = guestBox.values.toList();
      // print('Found ${transactions.length} guest transactions to migrate');

      // CRITICAL SECTION: Write to Firestore FIRST
      // Guest data is NOT deleted until this succeeds
      final batch = FirebaseFirestore.instance.batch();

      for (var txnData in transactions) {
        final map = Map<String, dynamic>.from(txnData as Map);
        final txn = TransactionModel.fromLocalMap(map);

        // Create new transaction with user's ID
        final updatedTxn = TransactionEntity(
          id: txn.id,
          userId: userId, // Update to real user ID
          amount: txn.amount,
          type: txn.type,
          category: txn.category,
          date: txn.date,
          description: txn.description,
        );

        final docRef = FirebaseFirestore.instance
            .collection('users')
            .doc(userId)
            .collection('transactions')
            .doc(txn.id);

        final model = TransactionModel.fromEntity(updatedTxn);
        batch.set(docRef, model.toMap());
      }

      // Commit the batch - this is the critical operation
      await batch.commit();
      /* print(
        'Successfully migrated ${transactions.length} transactions to Firestore',
      ); */

      // ONLY NOW: Clear guest data after successful Firestore write
      await guestBox.clear();
      // print('Cleared guest transaction data');

      // Mark migration as completed
      await _storage.write(key: 'migration_completed_$userId', value: 'true');
      // print('Migration completed and flagged');

      return true;
    } catch (e) {
      // CRITICAL: DO NOT clear guest data on failure
      // User can retry migration later
      // print('Migration failed: $e');
      // print('Guest data preserved for retry');
      return false;
    }
  }

  /// Checks if migration has been completed for a user
  Future<bool> isMigrationCompleted(String userId) async {
    final flag = await _storage.read(key: 'migration_completed_$userId');
    return flag == 'true';
  }

  /// Resets migration flag (for testing purposes only)
  Future<void> resetMigrationFlag(String userId) async {
    await _storage.delete(key: 'migration_completed_$userId');
  }

  /// Gets the count of guest transactions available for migration
  Future<int> getGuestTransactionCount() async {
    try {
      final guestBox = Hive.box('guest_transactions');
      return guestBox.length;
    } catch (e) {
      // print('Error getting guest transaction count: $e');
      return 0;
    }
  }

  /// Preview guest data before migration (for UI display)
  Future<List<TransactionEntity>> previewGuestData() async {
    try {
      final guestBox = Hive.box('guest_transactions');
      final transactions = <TransactionEntity>[];

      for (var txnData in guestBox.values) {
        final map = Map<String, dynamic>.from(txnData as Map);
        final txn = TransactionModel.fromLocalMap(map);
        transactions.add(txn);
      }

      return transactions;
    } catch (e) {
      // print('Error previewing guest data: $e');
      return [];
    }
  }
}
