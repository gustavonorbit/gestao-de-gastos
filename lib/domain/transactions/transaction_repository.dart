import 'transaction.dart';

abstract class TransactionRepository {
  /// Returns all transactions.
  Future<List<Transaction>> getAll();

  /// Inserts or updates a transaction.
  Future<void> upsert(Transaction transaction);

  /// Deletes a transaction by id.
  Future<void> delete(int id);
}
