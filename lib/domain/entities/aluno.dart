class Aluno {
  final int? id;
  final int turmaId;
  final String nome;
  final int? numeroChamada;
  final bool ativo;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  const Aluno({
    this.id,
    required this.turmaId,
    required this.nome,
    this.numeroChamada,
    this.ativo = true,
    this.createdAt,
    this.updatedAt,
  });

  Aluno copyWith({
    int? id,
    int? turmaId,
    String? nome,
    int? numeroChamada,
    bool? ativo,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return Aluno(
      id: id ?? this.id,
      turmaId: turmaId ?? this.turmaId,
      nome: nome ?? this.nome,
      numeroChamada: numeroChamada ?? this.numeroChamada,
      ativo: ativo ?? this.ativo,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}
