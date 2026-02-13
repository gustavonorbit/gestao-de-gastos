class NomePadrao {
  final int? id;
  final String valor;
  final int ordem;

  NomePadrao({this.id, required this.valor, this.ordem = 0});

  NomePadrao copyWith({int? id, String? valor, int? ordem}) {
    return NomePadrao(
      id: id ?? this.id,
      valor: valor ?? this.valor,
      ordem: ordem ?? this.ordem,
    );
  }
}
