import '../entities/transaction_entity.dart';

abstract class TransactionRepository {
  Future<void> addTransaction(TransactionEntity transaction);
  Future<void> deleteTransaction(String userId, String transactionId);
  Future<void> updateTransaction(TransactionEntity transaction);
  Stream<List<TransactionEntity>> getTransactions(String userId);
}
