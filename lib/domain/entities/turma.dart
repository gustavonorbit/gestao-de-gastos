class Turma {
  final int? id;
  final String nome;
  final String? disciplina;
  final int anoLetivo;
  final bool ativa;
  final bool isDeleted;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  const Turma({
    this.id,
    required this.nome,
    this.disciplina,
    required this.anoLetivo,
    this.ativa = true,
    this.isDeleted = false,
    this.createdAt,
    this.updatedAt,
  });

  Turma copyWith({
    int? id,
    String? nome,
    String? disciplina,
    int? anoLetivo,
    bool? ativa,
    bool? isDeleted,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return Turma(
      id: id ?? this.id,
      nome: nome ?? this.nome,
      disciplina: disciplina ?? this.disciplina,
      anoLetivo: anoLetivo ?? this.anoLetivo,
      ativa: ativa ?? this.ativa,
      isDeleted: isDeleted ?? this.isDeleted,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  String toString() {
    return 'Turma{id: $id, nome: $nome, disciplina: $disciplina, anoLetivo: $anoLetivo, ativa: $ativa, isDeleted: $isDeleted}';
  }
}
