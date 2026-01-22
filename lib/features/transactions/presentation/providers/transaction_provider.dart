import 'dart:async';
import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:uuid/uuid.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../domain/entities/transaction_entity.dart';
import '../../domain/repositories/transaction_repository.dart';
import '../../../auth/domain/entities/user_entity.dart';
import '../../data/models/transaction_model.dart';
import '../../data/services/guest_data_migration_service.dart';

/// TransactionProvider manages ONLY transaction state
/// Budget logic has been moved to BudgetProvider (features/budget/presentation/providers)
class TransactionProvider extends ChangeNotifier {
  final TransactionRepository _repository;

  List<TransactionEntity> _transactions = [];
  StreamSubscription<List<TransactionEntity>>? _subscription;
  UserEntity? _currentUser;
  UserEntity? get currentUser => _currentUser;
  bool _isLoading = false;

  // Conversion Banner State
  int _guestTransactionCount = 0;
  bool _conversionBannerDismissed = false;
  SharedPreferences? _prefs;
  bool _prefsInitialized = false;

  TransactionProvider(this._repository);

  /// Ensures SharedPreferences is initialized before use
  /// This is called lazily to avoid async constructor issues
  Future<void> _ensurePrefsInitialized() async {
    if (_prefsInitialized) return;

    try {
      _prefs = await SharedPreferences.getInstance();
      _guestTransactionCount = _prefs?.getInt('guest_transaction_count') ?? 0;
      _conversionBannerDismissed =
          _prefs?.getBool('conversion_banner_dismissed') ?? false;
      _prefsInitialized = true;
    } catch (e) {
      // print('Error initializing SharedPreferences: $e');
      // Continue without preferences - app will still work
      _prefsInitialized = true;
    }
  }

  List<TransactionEntity> get transactions => _transactions;
  bool get isLoading => _isLoading;

  // Computed properties
  double get totalIncome => _transactions
      .where((t) => t.isIncome)
      .fold(0.0, (currentSum, t) => currentSum + t.amount);

  double get totalExpense => _transactions
      .where((t) => t.isExpense)
      .fold(0.0, (currentSum, t) => currentSum + t.amount);

  double get balance => totalIncome - totalExpense;

  int _startOfMonth = 1;

  // New Getters for Monthly Stats
  List<TransactionEntity> get monthlyTransactions {
    final now = DateTime.now();
    DateTime start;
    DateTime end;

    if (now.day >= _startOfMonth) {
      start = DateTime(now.year, now.month, _startOfMonth);
      end = DateTime(now.year, now.month + 1, _startOfMonth);
    } else {
      start = DateTime(now.year, now.month - 1, _startOfMonth);
      end = DateTime(now.year, now.month, _startOfMonth);
    }

    return _transactions.where((t) {
      return t.date.isAfter(start.subtract(const Duration(seconds: 1))) &&
          t.date.isBefore(end);
    }).toList();
  }

  double get monthlyIncome => monthlyTransactions
      .where((t) => t.isIncome)
      .fold(0.0, (acc, t) => acc + t.amount);

  double get monthlyExpense => monthlyTransactions
      .where((t) => t.isExpense)
      .fold(0.0, (acc, t) => acc + t.amount);

  double get monthlyBalance => monthlyIncome - monthlyExpense;

  void updateStartOfMonth(int day) {
    _startOfMonth = day;
    notifyListeners();
  }

  // Conversion Banner Logic
  // RULE: Conversion banners must NEVER appear for authenticated users,
  // even if local data exists. This prevents edge cases during migration.
  bool get shouldShowConversionBanner {
    // CRITICAL: Must be guest user - this is the first and most important check
    if (_currentUser?.isGuest != true) return false;

    // Don't show if user has dismissed it
    if (_conversionBannerDismissed) return false;

    // Show after 1st or 2nd transaction only
    return _guestTransactionCount >= 1 && _guestTransactionCount <= 2;
  }

  Future<void> dismissConversionBanner() async {
    await _ensurePrefsInitialized();
    _conversionBannerDismissed = true;
    await _prefs?.setBool('conversion_banner_dismissed', true);
    notifyListeners();
  }

  Future<void> resetGuestState() async {
    await _ensurePrefsInitialized();
    _guestTransactionCount = 0;
    _conversionBannerDismissed = false;
    await _prefs?.setInt('guest_transaction_count', 0);
    await _prefs?.setBool('conversion_banner_dismissed', false);
    notifyListeners();
  }

  /// Migrates guest data to Firestore for a newly registered user
  ///
  /// CRITICAL SAFETY RULE:
  /// Guest data is only deleted AFTER successful Firestore write.
  /// If migration fails, guest data is preserved for retry.
  ///
  /// Returns true if migration succeeded or was already completed
  /// Returns false if migration failed (guest data preserved)
  Future<bool> migrateGuestDataToUser(String userId) async {
    try {
      final migrationService = GuestDataMigrationService();

      // Attempt migration
      final success = await migrationService.migrateGuestDataToFirestore(
        userId,
      );

      if (success) {
        // Migration succeeded - reset guest state
        await resetGuestState();
        // print('Guest data successfully migrated to user $userId');
        return true;
      } else {
        // Migration failed - guest data preserved
        // print('Migration failed - guest data preserved for retry');
        return false;
      }
    } catch (e) {
      // print('Error during migration: $e');
      return false;
    }
  }

  /// Gets the count of guest transactions available for migration
  Future<int> getGuestTransactionCount() async {
    final migrationService = GuestDataMigrationService();
    return await migrationService.getGuestTransactionCount();
  }

  void updateUser(UserEntity? user) {
    if (_currentUser?.uid == user?.uid) return;
    _currentUser = user;
    _initStream();
  }

  void _initStream() {
    _subscription?.cancel();
    _transactions = [];
    notifyListeners();

    if (_currentUser == null) return;

    _isLoading = true;
    notifyListeners();

    // Handle Guest User Local Storage
    if (_currentUser!.isGuest) {
      _loadGuestTransactions();
      return;
    }

    // Load Transactions
    _subscription = _repository
        .getTransactions(_currentUser!.uid)
        .listen(
          (data) {
            _transactions = data;
            _isLoading = false;
            notifyListeners();
          },
          onError: (error) {
            // print("Error fetching transactions: $error");
            _isLoading = false;
            notifyListeners();
          },
        );
  }

  void _loadGuestTransactions() {
    try {
      final box = Hive.box('guest_transactions');
      final data = box.values.toList();

      final List<TransactionEntity> loadedTransactions = [];

      for (var e in data) {
        try {
          if (e is Map) {
            final map = Map<String, dynamic>.from(e);
            loadedTransactions.add(TransactionModel.fromLocalMap(map));
          }
        } catch (innerError) {
          // Skip one corrupted item instead of failing for all
          // debugPrint("Error parsing single guest transaction: $innerError");
        }
      }

      // Sort by date descending
      loadedTransactions.sort((a, b) => b.date.compareTo(a.date));

      _transactions = loadedTransactions;
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      // debugPrint("Critical error loading guest transactions: $e");
      _transactions = [];
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> addTransaction(TransactionEntity transaction) async {
    // Guest Mode (Check both provider state AND transaction source)
    if (_currentUser?.isGuest == true || transaction.userId == 'guest') {
      try {
        final box = Hive.box('guest_transactions');
        // Ensure ID
        String id = transaction.id.isEmpty ? const Uuid().v4() : transaction.id;

        final newTransaction = TransactionEntity(
          id: id,
          userId: 'guest',
          amount: transaction.amount,
          type: transaction.type,
          category: transaction.category,
          date: transaction.date,
          description: transaction.description,
        );

        final model = TransactionModel.fromEntity(newTransaction);
        await box.put(id, model.toLocalMap()); // Save to Hive (Local format)

        // Increment transaction count for conversion banner
        await _ensurePrefsInitialized();
        _guestTransactionCount++;
        await _prefs?.setInt('guest_transaction_count', _guestTransactionCount);

        // Refresh local list
        _loadGuestTransactions();
      } catch (e) {
        // print("Error saving guest transaction: $e");
        rethrow;
      }
      return;
    }

    // Normal Mode
    try {
      await _repository.addTransaction(transaction);
    } catch (e) {
      rethrow;
    }
  }

  Future<void> updateTransaction(TransactionEntity transaction) async {
    // Guest Mode
    if (_currentUser?.isGuest == true || transaction.userId == 'guest') {
      try {
        final box = Hive.box('guest_transactions');
        final model = TransactionModel.fromEntity(transaction);
        await box.put(transaction.id, model.toLocalMap());
        _loadGuestTransactions();
      } catch (e) {
        rethrow;
      }
      return;
    }

    // Normal Mode
    try {
      await _repository.updateTransaction(transaction);
    } catch (e) {
      rethrow;
    }
  }

  Future<void> deleteTransaction(String id) async {
    if (_currentUser == null) return;

    // Guest Mode (Identify by current state)
    if (_currentUser?.isGuest == true || _currentUser?.uid == 'guest') {
      try {
        final box = Hive.box('guest_transactions');
        await box.delete(id);
        _loadGuestTransactions();
      } catch (e) {
        // print("Error deleting guest transaction: $e");
      }
      return;
    }

    // Normal Mode
    try {
      await _repository.deleteTransaction(_currentUser!.uid, id);
    } catch (e) {
      rethrow;
    }
  }

  Future<void> clearGuestData() async {
    try {
      final box = Hive.box('guest_transactions');
      await box.clear();
      _transactions = [];

      // Reset conversion banner state
      await resetGuestState();

      notifyListeners();
    } catch (e) {
      // print("Error clearing guest data: $e");
    }
  }

  @override
  void dispose() {
    _subscription?.cancel();
    super.dispose();
  }
}
