// Domain entity for a financial transaction.
//
// Note: to remain consistent with existing entities in the project,
// `id` and `createdAt` are nullable to allow constructing instances
// before persistence. This is a deliberate assumption to match
// repository/entity patterns already used in the codebase.

class Transaction {
  final int? id;
  final double valor;
  final DateTime data;
  final String? descricao;
  final String categoria;
  final bool isReceita;
  final DateTime? createdAt;

  Transaction({
    this.id,
    required this.valor,
    required this.data,
    this.descricao,
    required this.categoria,
    this.isReceita = false,
    this.createdAt,
  });

  Transaction copyWith({
    int? id,
    double? valor,
    DateTime? data,
    String? descricao,
    String? categoria,
    bool? isReceita,
    DateTime? createdAt,
  }) {
    return Transaction(
      id: id ?? this.id,
      valor: valor ?? this.valor,
      data: data ?? this.data,
      descricao: descricao ?? this.descricao,
      categoria: categoria ?? this.categoria,
      isReceita: isReceita ?? this.isReceita,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}
