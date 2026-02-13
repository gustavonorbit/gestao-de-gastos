enum AulaTipo {
  individual,
  dupla,
}

extension AulaTipoX on AulaTipo {
  /// Persistência como inteiro no banco.
  ///
  /// Mantemos 1=individual e 2=dupla para ficar compatível com o legado
  /// (que usava `duracaoMinutos` com esses valores para sinalizar o tipo).
  int get dbValue => this == AulaTipo.dupla ? 2 : 1;

  static AulaTipo fromDbValue(int? value) {
    return (value == 2) ? AulaTipo.dupla : AulaTipo.individual;
  }
}

class Aula {
  final int? id;
  final int turmaId;
  final String titulo;
  final String? descricao;
  final DateTime data;
  final AulaTipo tipo;

  /// Campo legado: estamos usando como “contagem de presença” por enquanto.
  ///
  /// Ex.: aula individual = 1, aula dupla = 2.
  final int? duracaoMinutos;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  Aula({
    this.id,
    required this.turmaId,
    required this.titulo,
    this.descricao,
    required this.data,
    this.tipo = AulaTipo.individual,
    this.duracaoMinutos,
    this.createdAt,
    this.updatedAt,
  });

  /// Constrói a Aula inferindo o tipo a partir do legado `duracaoMinutos`.
  ///
  /// Útil para manter compatibilidade enquanto evoluímos persistência.
  factory Aula.legacy({
    int? id,
    required int turmaId,
    required String titulo,
    String? descricao,
    required DateTime data,
    int? duracaoMinutos,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return Aula(
      id: id,
      turmaId: turmaId,
      titulo: titulo,
      descricao: descricao,
      data: data,
      tipo: AulaTipoX.fromDbValue(duracaoMinutos),
      duracaoMinutos: duracaoMinutos,
      createdAt: createdAt,
      updatedAt: updatedAt,
    );
  }

  /// Compatibilidade: quantas abas de presença existem para essa aula.
  int get presencaAbas => (tipo == AulaTipo.dupla) ? 2 : 1;

  Aula copyWith({
    int? id,
    int? turmaId,
    String? titulo,
    String? descricao,
    DateTime? data,
    AulaTipo? tipo,
    int? duracaoMinutos,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return Aula(
      id: id ?? this.id,
      turmaId: turmaId ?? this.turmaId,
      titulo: titulo ?? this.titulo,
      descricao: descricao ?? this.descricao,
      data: data ?? this.data,
      tipo: tipo ?? this.tipo,
      duracaoMinutos: duracaoMinutos ?? this.duracaoMinutos,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}
