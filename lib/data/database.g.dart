// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'database.dart';

// ignore_for_file: type=lint
class $TurmasTable extends Turmas with TableInfo<$TurmasTable, Turma> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $TurmasTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
      'id', aliasedName, false,
      hasAutoIncrement: true,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('PRIMARY KEY AUTOINCREMENT'));
  static const VerificationMeta _nomeMeta = const VerificationMeta('nome');
  @override
  late final GeneratedColumn<String> nome = GeneratedColumn<String>(
      'nome', aliasedName, false,
      additionalChecks:
          GeneratedColumn.checkTextLength(minTextLength: 1, maxTextLength: 255),
      type: DriftSqlType.string,
      requiredDuringInsert: true);
  static const VerificationMeta _disciplinaMeta =
      const VerificationMeta('disciplina');
  @override
  late final GeneratedColumn<String> disciplina = GeneratedColumn<String>(
      'disciplina', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _anoLetivoMeta =
      const VerificationMeta('anoLetivo');
  @override
  late final GeneratedColumn<int> anoLetivo = GeneratedColumn<int>(
      'ano_letivo', aliasedName, false,
      type: DriftSqlType.int, requiredDuringInsert: true);
  static const VerificationMeta _ativaMeta = const VerificationMeta('ativa');
  @override
  late final GeneratedColumn<bool> ativa = GeneratedColumn<bool>(
      'ativa', aliasedName, false,
      type: DriftSqlType.bool,
      requiredDuringInsert: false,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('CHECK ("ativa" IN (0, 1))'),
      defaultValue: const Constant(true));
  static const VerificationMeta _isDeletedMeta =
      const VerificationMeta('isDeleted');
  @override
  late final GeneratedColumn<bool> isDeleted = GeneratedColumn<bool>(
      'is_deleted', aliasedName, false,
      type: DriftSqlType.bool,
      requiredDuringInsert: false,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('CHECK ("is_deleted" IN (0, 1))'),
      defaultValue: const Constant(false));
  static const VerificationMeta _createdAtMeta =
      const VerificationMeta('createdAt');
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
      'created_at', aliasedName, true,
      type: DriftSqlType.dateTime, requiredDuringInsert: false);
  static const VerificationMeta _updatedAtMeta =
      const VerificationMeta('updatedAt');
  @override
  late final GeneratedColumn<DateTime> updatedAt = GeneratedColumn<DateTime>(
      'updated_at', aliasedName, true,
      type: DriftSqlType.dateTime, requiredDuringInsert: false);
  @override
  List<GeneratedColumn> get $columns =>
      [id, nome, disciplina, anoLetivo, ativa, isDeleted, createdAt, updatedAt];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'turmas';
  @override
  VerificationContext validateIntegrity(Insertable<Turma> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('nome')) {
      context.handle(
          _nomeMeta, nome.isAcceptableOrUnknown(data['nome']!, _nomeMeta));
    } else if (isInserting) {
      context.missing(_nomeMeta);
    }
    if (data.containsKey('disciplina')) {
      context.handle(
          _disciplinaMeta,
          disciplina.isAcceptableOrUnknown(
              data['disciplina']!, _disciplinaMeta));
    }
    if (data.containsKey('ano_letivo')) {
      context.handle(_anoLetivoMeta,
          anoLetivo.isAcceptableOrUnknown(data['ano_letivo']!, _anoLetivoMeta));
    } else if (isInserting) {
      context.missing(_anoLetivoMeta);
    }
    if (data.containsKey('ativa')) {
      context.handle(
          _ativaMeta, ativa.isAcceptableOrUnknown(data['ativa']!, _ativaMeta));
    }
    if (data.containsKey('is_deleted')) {
      context.handle(_isDeletedMeta,
          isDeleted.isAcceptableOrUnknown(data['is_deleted']!, _isDeletedMeta));
    }
    if (data.containsKey('created_at')) {
      context.handle(_createdAtMeta,
          createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta));
    }
    if (data.containsKey('updated_at')) {
      context.handle(_updatedAtMeta,
          updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta));
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  Turma map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Turma(
      id: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}id'])!,
      nome: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}nome'])!,
      disciplina: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}disciplina']),
      anoLetivo: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}ano_letivo'])!,
      ativa: attachedDatabase.typeMapping
          .read(DriftSqlType.bool, data['${effectivePrefix}ativa'])!,
      isDeleted: attachedDatabase.typeMapping
          .read(DriftSqlType.bool, data['${effectivePrefix}is_deleted'])!,
      createdAt: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}created_at']),
      updatedAt: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}updated_at']),
    );
  }

  @override
  $TurmasTable createAlias(String alias) {
    return $TurmasTable(attachedDatabase, alias);
  }
}

class Turma extends DataClass implements Insertable<Turma> {
  final int id;
  final String nome;
  final String? disciplina;
  final int anoLetivo;
  final bool ativa;
  final bool isDeleted;
  final DateTime? createdAt;
  final DateTime? updatedAt;
  const Turma(
      {required this.id,
      required this.nome,
      this.disciplina,
      required this.anoLetivo,
      required this.ativa,
      required this.isDeleted,
      this.createdAt,
      this.updatedAt});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['nome'] = Variable<String>(nome);
    if (!nullToAbsent || disciplina != null) {
      map['disciplina'] = Variable<String>(disciplina);
    }
    map['ano_letivo'] = Variable<int>(anoLetivo);
    map['ativa'] = Variable<bool>(ativa);
    map['is_deleted'] = Variable<bool>(isDeleted);
    if (!nullToAbsent || createdAt != null) {
      map['created_at'] = Variable<DateTime>(createdAt);
    }
    if (!nullToAbsent || updatedAt != null) {
      map['updated_at'] = Variable<DateTime>(updatedAt);
    }
    return map;
  }

  TurmasCompanion toCompanion(bool nullToAbsent) {
    return TurmasCompanion(
      id: Value(id),
      nome: Value(nome),
      disciplina: disciplina == null && nullToAbsent
          ? const Value.absent()
          : Value(disciplina),
      anoLetivo: Value(anoLetivo),
      ativa: Value(ativa),
      isDeleted: Value(isDeleted),
      createdAt: createdAt == null && nullToAbsent
          ? const Value.absent()
          : Value(createdAt),
      updatedAt: updatedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(updatedAt),
    );
  }

  factory Turma.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Turma(
      id: serializer.fromJson<int>(json['id']),
      nome: serializer.fromJson<String>(json['nome']),
      disciplina: serializer.fromJson<String?>(json['disciplina']),
      anoLetivo: serializer.fromJson<int>(json['anoLetivo']),
      ativa: serializer.fromJson<bool>(json['ativa']),
      isDeleted: serializer.fromJson<bool>(json['isDeleted']),
      createdAt: serializer.fromJson<DateTime?>(json['createdAt']),
      updatedAt: serializer.fromJson<DateTime?>(json['updatedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'nome': serializer.toJson<String>(nome),
      'disciplina': serializer.toJson<String?>(disciplina),
      'anoLetivo': serializer.toJson<int>(anoLetivo),
      'ativa': serializer.toJson<bool>(ativa),
      'isDeleted': serializer.toJson<bool>(isDeleted),
      'createdAt': serializer.toJson<DateTime?>(createdAt),
      'updatedAt': serializer.toJson<DateTime?>(updatedAt),
    };
  }

  Turma copyWith(
          {int? id,
          String? nome,
          Value<String?> disciplina = const Value.absent(),
          int? anoLetivo,
          bool? ativa,
          bool? isDeleted,
          Value<DateTime?> createdAt = const Value.absent(),
          Value<DateTime?> updatedAt = const Value.absent()}) =>
      Turma(
        id: id ?? this.id,
        nome: nome ?? this.nome,
        disciplina: disciplina.present ? disciplina.value : this.disciplina,
        anoLetivo: anoLetivo ?? this.anoLetivo,
        ativa: ativa ?? this.ativa,
        isDeleted: isDeleted ?? this.isDeleted,
        createdAt: createdAt.present ? createdAt.value : this.createdAt,
        updatedAt: updatedAt.present ? updatedAt.value : this.updatedAt,
      );
  Turma copyWithCompanion(TurmasCompanion data) {
    return Turma(
      id: data.id.present ? data.id.value : this.id,
      nome: data.nome.present ? data.nome.value : this.nome,
      disciplina:
          data.disciplina.present ? data.disciplina.value : this.disciplina,
      anoLetivo: data.anoLetivo.present ? data.anoLetivo.value : this.anoLetivo,
      ativa: data.ativa.present ? data.ativa.value : this.ativa,
      isDeleted: data.isDeleted.present ? data.isDeleted.value : this.isDeleted,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('Turma(')
          ..write('id: $id, ')
          ..write('nome: $nome, ')
          ..write('disciplina: $disciplina, ')
          ..write('anoLetivo: $anoLetivo, ')
          ..write('ativa: $ativa, ')
          ..write('isDeleted: $isDeleted, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
      id, nome, disciplina, anoLetivo, ativa, isDeleted, createdAt, updatedAt);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Turma &&
          other.id == this.id &&
          other.nome == this.nome &&
          other.disciplina == this.disciplina &&
          other.anoLetivo == this.anoLetivo &&
          other.ativa == this.ativa &&
          other.isDeleted == this.isDeleted &&
          other.createdAt == this.createdAt &&
          other.updatedAt == this.updatedAt);
}

class TurmasCompanion extends UpdateCompanion<Turma> {
  final Value<int> id;
  final Value<String> nome;
  final Value<String?> disciplina;
  final Value<int> anoLetivo;
  final Value<bool> ativa;
  final Value<bool> isDeleted;
  final Value<DateTime?> createdAt;
  final Value<DateTime?> updatedAt;
  const TurmasCompanion({
    this.id = const Value.absent(),
    this.nome = const Value.absent(),
    this.disciplina = const Value.absent(),
    this.anoLetivo = const Value.absent(),
    this.ativa = const Value.absent(),
    this.isDeleted = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
  });
  TurmasCompanion.insert({
    this.id = const Value.absent(),
    required String nome,
    this.disciplina = const Value.absent(),
    required int anoLetivo,
    this.ativa = const Value.absent(),
    this.isDeleted = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
  })  : nome = Value(nome),
        anoLetivo = Value(anoLetivo);
  static Insertable<Turma> custom({
    Expression<int>? id,
    Expression<String>? nome,
    Expression<String>? disciplina,
    Expression<int>? anoLetivo,
    Expression<bool>? ativa,
    Expression<bool>? isDeleted,
    Expression<DateTime>? createdAt,
    Expression<DateTime>? updatedAt,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (nome != null) 'nome': nome,
      if (disciplina != null) 'disciplina': disciplina,
      if (anoLetivo != null) 'ano_letivo': anoLetivo,
      if (ativa != null) 'ativa': ativa,
      if (isDeleted != null) 'is_deleted': isDeleted,
      if (createdAt != null) 'created_at': createdAt,
      if (updatedAt != null) 'updated_at': updatedAt,
    });
  }

  TurmasCompanion copyWith(
      {Value<int>? id,
      Value<String>? nome,
      Value<String?>? disciplina,
      Value<int>? anoLetivo,
      Value<bool>? ativa,
      Value<bool>? isDeleted,
      Value<DateTime?>? createdAt,
      Value<DateTime?>? updatedAt}) {
    return TurmasCompanion(
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
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (nome.present) {
      map['nome'] = Variable<String>(nome.value);
    }
    if (disciplina.present) {
      map['disciplina'] = Variable<String>(disciplina.value);
    }
    if (anoLetivo.present) {
      map['ano_letivo'] = Variable<int>(anoLetivo.value);
    }
    if (ativa.present) {
      map['ativa'] = Variable<bool>(ativa.value);
    }
    if (isDeleted.present) {
      map['is_deleted'] = Variable<bool>(isDeleted.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<DateTime>(updatedAt.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('TurmasCompanion(')
          ..write('id: $id, ')
          ..write('nome: $nome, ')
          ..write('disciplina: $disciplina, ')
          ..write('anoLetivo: $anoLetivo, ')
          ..write('ativa: $ativa, ')
          ..write('isDeleted: $isDeleted, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt')
          ..write(')'))
        .toString();
  }
}

class $AulasTable extends Aulas with TableInfo<$AulasTable, Aula> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $AulasTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
      'id', aliasedName, false,
      hasAutoIncrement: true,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('PRIMARY KEY AUTOINCREMENT'));
  static const VerificationMeta _turmaIdMeta =
      const VerificationMeta('turmaId');
  @override
  late final GeneratedColumn<int> turmaId = GeneratedColumn<int>(
      'turma_id', aliasedName, false,
      type: DriftSqlType.int, requiredDuringInsert: true);
  static const VerificationMeta _tituloMeta = const VerificationMeta('titulo');
  @override
  late final GeneratedColumn<String> titulo = GeneratedColumn<String>(
      'titulo', aliasedName, false,
      additionalChecks:
          GeneratedColumn.checkTextLength(minTextLength: 1, maxTextLength: 255),
      type: DriftSqlType.string,
      requiredDuringInsert: true);
  static const VerificationMeta _descricaoMeta =
      const VerificationMeta('descricao');
  @override
  late final GeneratedColumn<String> descricao = GeneratedColumn<String>(
      'descricao', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _dataMeta = const VerificationMeta('data');
  @override
  late final GeneratedColumn<DateTime> data = GeneratedColumn<DateTime>(
      'data', aliasedName, false,
      type: DriftSqlType.dateTime, requiredDuringInsert: true);
  static const VerificationMeta _aulaTipoMeta =
      const VerificationMeta('aulaTipo');
  @override
  late final GeneratedColumn<int> aulaTipo = GeneratedColumn<int>(
      'aula_tipo', aliasedName, false,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      defaultValue: const Constant(1));
  static const VerificationMeta _duracaoMinutosMeta =
      const VerificationMeta('duracaoMinutos');
  @override
  late final GeneratedColumn<int> duracaoMinutos = GeneratedColumn<int>(
      'duracao_minutos', aliasedName, true,
      type: DriftSqlType.int, requiredDuringInsert: false);
  static const VerificationMeta _createdAtMeta =
      const VerificationMeta('createdAt');
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
      'created_at', aliasedName, true,
      type: DriftSqlType.dateTime, requiredDuringInsert: false);
  static const VerificationMeta _updatedAtMeta =
      const VerificationMeta('updatedAt');
  @override
  late final GeneratedColumn<DateTime> updatedAt = GeneratedColumn<DateTime>(
      'updated_at', aliasedName, true,
      type: DriftSqlType.dateTime, requiredDuringInsert: false);
  @override
  List<GeneratedColumn> get $columns => [
        id,
        turmaId,
        titulo,
        descricao,
        data,
        aulaTipo,
        duracaoMinutos,
        createdAt,
        updatedAt
      ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'aulas';
  @override
  VerificationContext validateIntegrity(Insertable<Aula> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('turma_id')) {
      context.handle(_turmaIdMeta,
          turmaId.isAcceptableOrUnknown(data['turma_id']!, _turmaIdMeta));
    } else if (isInserting) {
      context.missing(_turmaIdMeta);
    }
    if (data.containsKey('titulo')) {
      context.handle(_tituloMeta,
          titulo.isAcceptableOrUnknown(data['titulo']!, _tituloMeta));
    } else if (isInserting) {
      context.missing(_tituloMeta);
    }
    if (data.containsKey('descricao')) {
      context.handle(_descricaoMeta,
          descricao.isAcceptableOrUnknown(data['descricao']!, _descricaoMeta));
    }
    if (data.containsKey('data')) {
      context.handle(
          _dataMeta, this.data.isAcceptableOrUnknown(data['data']!, _dataMeta));
    } else if (isInserting) {
      context.missing(_dataMeta);
    }
    if (data.containsKey('aula_tipo')) {
      context.handle(_aulaTipoMeta,
          aulaTipo.isAcceptableOrUnknown(data['aula_tipo']!, _aulaTipoMeta));
    }
    if (data.containsKey('duracao_minutos')) {
      context.handle(
          _duracaoMinutosMeta,
          duracaoMinutos.isAcceptableOrUnknown(
              data['duracao_minutos']!, _duracaoMinutosMeta));
    }
    if (data.containsKey('created_at')) {
      context.handle(_createdAtMeta,
          createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta));
    }
    if (data.containsKey('updated_at')) {
      context.handle(_updatedAtMeta,
          updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta));
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  Aula map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Aula(
      id: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}id'])!,
      turmaId: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}turma_id'])!,
      titulo: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}titulo'])!,
      descricao: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}descricao']),
      data: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}data'])!,
      aulaTipo: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}aula_tipo'])!,
      duracaoMinutos: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}duracao_minutos']),
      createdAt: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}created_at']),
      updatedAt: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}updated_at']),
    );
  }

  @override
  $AulasTable createAlias(String alias) {
    return $AulasTable(attachedDatabase, alias);
  }
}

class Aula extends DataClass implements Insertable<Aula> {
  final int id;
  final int turmaId;
  final String titulo;
  final String? descricao;
  final DateTime data;

  /// Tipo explícito da aula:
  /// - 1 = individual
  /// - 2 = dupla
  ///
  /// Mantemos inteiro para permitir migração simples a partir do legado
  /// `duracao_minutos` (que já usava 1/2 para sinalizar tipo).
  final int aulaTipo;
  final int? duracaoMinutos;
  final DateTime? createdAt;
  final DateTime? updatedAt;
  const Aula(
      {required this.id,
      required this.turmaId,
      required this.titulo,
      this.descricao,
      required this.data,
      required this.aulaTipo,
      this.duracaoMinutos,
      this.createdAt,
      this.updatedAt});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['turma_id'] = Variable<int>(turmaId);
    map['titulo'] = Variable<String>(titulo);
    if (!nullToAbsent || descricao != null) {
      map['descricao'] = Variable<String>(descricao);
    }
    map['data'] = Variable<DateTime>(data);
    map['aula_tipo'] = Variable<int>(aulaTipo);
    if (!nullToAbsent || duracaoMinutos != null) {
      map['duracao_minutos'] = Variable<int>(duracaoMinutos);
    }
    if (!nullToAbsent || createdAt != null) {
      map['created_at'] = Variable<DateTime>(createdAt);
    }
    if (!nullToAbsent || updatedAt != null) {
      map['updated_at'] = Variable<DateTime>(updatedAt);
    }
    return map;
  }

  AulasCompanion toCompanion(bool nullToAbsent) {
    return AulasCompanion(
      id: Value(id),
      turmaId: Value(turmaId),
      titulo: Value(titulo),
      descricao: descricao == null && nullToAbsent
          ? const Value.absent()
          : Value(descricao),
      data: Value(data),
      aulaTipo: Value(aulaTipo),
      duracaoMinutos: duracaoMinutos == null && nullToAbsent
          ? const Value.absent()
          : Value(duracaoMinutos),
      createdAt: createdAt == null && nullToAbsent
          ? const Value.absent()
          : Value(createdAt),
      updatedAt: updatedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(updatedAt),
    );
  }

  factory Aula.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Aula(
      id: serializer.fromJson<int>(json['id']),
      turmaId: serializer.fromJson<int>(json['turmaId']),
      titulo: serializer.fromJson<String>(json['titulo']),
      descricao: serializer.fromJson<String?>(json['descricao']),
      data: serializer.fromJson<DateTime>(json['data']),
      aulaTipo: serializer.fromJson<int>(json['aulaTipo']),
      duracaoMinutos: serializer.fromJson<int?>(json['duracaoMinutos']),
      createdAt: serializer.fromJson<DateTime?>(json['createdAt']),
      updatedAt: serializer.fromJson<DateTime?>(json['updatedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'turmaId': serializer.toJson<int>(turmaId),
      'titulo': serializer.toJson<String>(titulo),
      'descricao': serializer.toJson<String?>(descricao),
      'data': serializer.toJson<DateTime>(data),
      'aulaTipo': serializer.toJson<int>(aulaTipo),
      'duracaoMinutos': serializer.toJson<int?>(duracaoMinutos),
      'createdAt': serializer.toJson<DateTime?>(createdAt),
      'updatedAt': serializer.toJson<DateTime?>(updatedAt),
    };
  }

  Aula copyWith(
          {int? id,
          int? turmaId,
          String? titulo,
          Value<String?> descricao = const Value.absent(),
          DateTime? data,
          int? aulaTipo,
          Value<int?> duracaoMinutos = const Value.absent(),
          Value<DateTime?> createdAt = const Value.absent(),
          Value<DateTime?> updatedAt = const Value.absent()}) =>
      Aula(
        id: id ?? this.id,
        turmaId: turmaId ?? this.turmaId,
        titulo: titulo ?? this.titulo,
        descricao: descricao.present ? descricao.value : this.descricao,
        data: data ?? this.data,
        aulaTipo: aulaTipo ?? this.aulaTipo,
        duracaoMinutos:
            duracaoMinutos.present ? duracaoMinutos.value : this.duracaoMinutos,
        createdAt: createdAt.present ? createdAt.value : this.createdAt,
        updatedAt: updatedAt.present ? updatedAt.value : this.updatedAt,
      );
  Aula copyWithCompanion(AulasCompanion data) {
    return Aula(
      id: data.id.present ? data.id.value : this.id,
      turmaId: data.turmaId.present ? data.turmaId.value : this.turmaId,
      titulo: data.titulo.present ? data.titulo.value : this.titulo,
      descricao: data.descricao.present ? data.descricao.value : this.descricao,
      data: data.data.present ? data.data.value : this.data,
      aulaTipo: data.aulaTipo.present ? data.aulaTipo.value : this.aulaTipo,
      duracaoMinutos: data.duracaoMinutos.present
          ? data.duracaoMinutos.value
          : this.duracaoMinutos,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('Aula(')
          ..write('id: $id, ')
          ..write('turmaId: $turmaId, ')
          ..write('titulo: $titulo, ')
          ..write('descricao: $descricao, ')
          ..write('data: $data, ')
          ..write('aulaTipo: $aulaTipo, ')
          ..write('duracaoMinutos: $duracaoMinutos, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, turmaId, titulo, descricao, data,
      aulaTipo, duracaoMinutos, createdAt, updatedAt);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Aula &&
          other.id == this.id &&
          other.turmaId == this.turmaId &&
          other.titulo == this.titulo &&
          other.descricao == this.descricao &&
          other.data == this.data &&
          other.aulaTipo == this.aulaTipo &&
          other.duracaoMinutos == this.duracaoMinutos &&
          other.createdAt == this.createdAt &&
          other.updatedAt == this.updatedAt);
}

class AulasCompanion extends UpdateCompanion<Aula> {
  final Value<int> id;
  final Value<int> turmaId;
  final Value<String> titulo;
  final Value<String?> descricao;
  final Value<DateTime> data;
  final Value<int> aulaTipo;
  final Value<int?> duracaoMinutos;
  final Value<DateTime?> createdAt;
  final Value<DateTime?> updatedAt;
  const AulasCompanion({
    this.id = const Value.absent(),
    this.turmaId = const Value.absent(),
    this.titulo = const Value.absent(),
    this.descricao = const Value.absent(),
    this.data = const Value.absent(),
    this.aulaTipo = const Value.absent(),
    this.duracaoMinutos = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
  });
  AulasCompanion.insert({
    this.id = const Value.absent(),
    required int turmaId,
    required String titulo,
    this.descricao = const Value.absent(),
    required DateTime data,
    this.aulaTipo = const Value.absent(),
    this.duracaoMinutos = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
  })  : turmaId = Value(turmaId),
        titulo = Value(titulo),
        data = Value(data);
  static Insertable<Aula> custom({
    Expression<int>? id,
    Expression<int>? turmaId,
    Expression<String>? titulo,
    Expression<String>? descricao,
    Expression<DateTime>? data,
    Expression<int>? aulaTipo,
    Expression<int>? duracaoMinutos,
    Expression<DateTime>? createdAt,
    Expression<DateTime>? updatedAt,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (turmaId != null) 'turma_id': turmaId,
      if (titulo != null) 'titulo': titulo,
      if (descricao != null) 'descricao': descricao,
      if (data != null) 'data': data,
      if (aulaTipo != null) 'aula_tipo': aulaTipo,
      if (duracaoMinutos != null) 'duracao_minutos': duracaoMinutos,
      if (createdAt != null) 'created_at': createdAt,
      if (updatedAt != null) 'updated_at': updatedAt,
    });
  }

  AulasCompanion copyWith(
      {Value<int>? id,
      Value<int>? turmaId,
      Value<String>? titulo,
      Value<String?>? descricao,
      Value<DateTime>? data,
      Value<int>? aulaTipo,
      Value<int?>? duracaoMinutos,
      Value<DateTime?>? createdAt,
      Value<DateTime?>? updatedAt}) {
    return AulasCompanion(
      id: id ?? this.id,
      turmaId: turmaId ?? this.turmaId,
      titulo: titulo ?? this.titulo,
      descricao: descricao ?? this.descricao,
      data: data ?? this.data,
      aulaTipo: aulaTipo ?? this.aulaTipo,
      duracaoMinutos: duracaoMinutos ?? this.duracaoMinutos,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (turmaId.present) {
      map['turma_id'] = Variable<int>(turmaId.value);
    }
    if (titulo.present) {
      map['titulo'] = Variable<String>(titulo.value);
    }
    if (descricao.present) {
      map['descricao'] = Variable<String>(descricao.value);
    }
    if (data.present) {
      map['data'] = Variable<DateTime>(data.value);
    }
    if (aulaTipo.present) {
      map['aula_tipo'] = Variable<int>(aulaTipo.value);
    }
    if (duracaoMinutos.present) {
      map['duracao_minutos'] = Variable<int>(duracaoMinutos.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<DateTime>(updatedAt.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('AulasCompanion(')
          ..write('id: $id, ')
          ..write('turmaId: $turmaId, ')
          ..write('titulo: $titulo, ')
          ..write('descricao: $descricao, ')
          ..write('data: $data, ')
          ..write('aulaTipo: $aulaTipo, ')
          ..write('duracaoMinutos: $duracaoMinutos, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt')
          ..write(')'))
        .toString();
  }
}

class $NomesPadraoTable extends NomesPadrao
    with TableInfo<$NomesPadraoTable, NomesPadraoData> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $NomesPadraoTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
      'id', aliasedName, false,
      hasAutoIncrement: true,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('PRIMARY KEY AUTOINCREMENT'));
  static const VerificationMeta _valorMeta = const VerificationMeta('valor');
  @override
  late final GeneratedColumn<String> valor = GeneratedColumn<String>(
      'valor', aliasedName, false,
      additionalChecks:
          GeneratedColumn.checkTextLength(minTextLength: 1, maxTextLength: 100),
      type: DriftSqlType.string,
      requiredDuringInsert: true);
  static const VerificationMeta _ordemMeta = const VerificationMeta('ordem');
  @override
  late final GeneratedColumn<int> ordem = GeneratedColumn<int>(
      'ordem', aliasedName, false,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      defaultValue: const Constant(0));
  @override
  List<GeneratedColumn> get $columns => [id, valor, ordem];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'nomes_padrao';
  @override
  VerificationContext validateIntegrity(Insertable<NomesPadraoData> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('valor')) {
      context.handle(
          _valorMeta, valor.isAcceptableOrUnknown(data['valor']!, _valorMeta));
    } else if (isInserting) {
      context.missing(_valorMeta);
    }
    if (data.containsKey('ordem')) {
      context.handle(
          _ordemMeta, ordem.isAcceptableOrUnknown(data['ordem']!, _ordemMeta));
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  NomesPadraoData map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return NomesPadraoData(
      id: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}id'])!,
      valor: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}valor'])!,
      ordem: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}ordem'])!,
    );
  }

  @override
  $NomesPadraoTable createAlias(String alias) {
    return $NomesPadraoTable(attachedDatabase, alias);
  }
}

class NomesPadraoData extends DataClass implements Insertable<NomesPadraoData> {
  final int id;
  final String valor;
  final int ordem;
  const NomesPadraoData(
      {required this.id, required this.valor, required this.ordem});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['valor'] = Variable<String>(valor);
    map['ordem'] = Variable<int>(ordem);
    return map;
  }

  NomesPadraoCompanion toCompanion(bool nullToAbsent) {
    return NomesPadraoCompanion(
      id: Value(id),
      valor: Value(valor),
      ordem: Value(ordem),
    );
  }

  factory NomesPadraoData.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return NomesPadraoData(
      id: serializer.fromJson<int>(json['id']),
      valor: serializer.fromJson<String>(json['valor']),
      ordem: serializer.fromJson<int>(json['ordem']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'valor': serializer.toJson<String>(valor),
      'ordem': serializer.toJson<int>(ordem),
    };
  }

  NomesPadraoData copyWith({int? id, String? valor, int? ordem}) =>
      NomesPadraoData(
        id: id ?? this.id,
        valor: valor ?? this.valor,
        ordem: ordem ?? this.ordem,
      );
  NomesPadraoData copyWithCompanion(NomesPadraoCompanion data) {
    return NomesPadraoData(
      id: data.id.present ? data.id.value : this.id,
      valor: data.valor.present ? data.valor.value : this.valor,
      ordem: data.ordem.present ? data.ordem.value : this.ordem,
    );
  }

  @override
  String toString() {
    return (StringBuffer('NomesPadraoData(')
          ..write('id: $id, ')
          ..write('valor: $valor, ')
          ..write('ordem: $ordem')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, valor, ordem);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is NomesPadraoData &&
          other.id == this.id &&
          other.valor == this.valor &&
          other.ordem == this.ordem);
}

class NomesPadraoCompanion extends UpdateCompanion<NomesPadraoData> {
  final Value<int> id;
  final Value<String> valor;
  final Value<int> ordem;
  const NomesPadraoCompanion({
    this.id = const Value.absent(),
    this.valor = const Value.absent(),
    this.ordem = const Value.absent(),
  });
  NomesPadraoCompanion.insert({
    this.id = const Value.absent(),
    required String valor,
    this.ordem = const Value.absent(),
  }) : valor = Value(valor);
  static Insertable<NomesPadraoData> custom({
    Expression<int>? id,
    Expression<String>? valor,
    Expression<int>? ordem,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (valor != null) 'valor': valor,
      if (ordem != null) 'ordem': ordem,
    });
  }

  NomesPadraoCompanion copyWith(
      {Value<int>? id, Value<String>? valor, Value<int>? ordem}) {
    return NomesPadraoCompanion(
      id: id ?? this.id,
      valor: valor ?? this.valor,
      ordem: ordem ?? this.ordem,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (valor.present) {
      map['valor'] = Variable<String>(valor.value);
    }
    if (ordem.present) {
      map['ordem'] = Variable<int>(ordem.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('NomesPadraoCompanion(')
          ..write('id: $id, ')
          ..write('valor: $valor, ')
          ..write('ordem: $ordem')
          ..write(')'))
        .toString();
  }
}

class $AlunosTable extends Alunos with TableInfo<$AlunosTable, Aluno> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $AlunosTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
      'id', aliasedName, false,
      hasAutoIncrement: true,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('PRIMARY KEY AUTOINCREMENT'));
  static const VerificationMeta _turmaIdMeta =
      const VerificationMeta('turmaId');
  @override
  late final GeneratedColumn<int> turmaId = GeneratedColumn<int>(
      'turma_id', aliasedName, false,
      type: DriftSqlType.int,
      requiredDuringInsert: true,
      defaultConstraints: GeneratedColumn.constraintIsAlways(
          'REFERENCES turmas (id) ON DELETE RESTRICT'));
  static const VerificationMeta _nomeMeta = const VerificationMeta('nome');
  @override
  late final GeneratedColumn<String> nome = GeneratedColumn<String>(
      'nome', aliasedName, false,
      additionalChecks:
          GeneratedColumn.checkTextLength(minTextLength: 1, maxTextLength: 255),
      type: DriftSqlType.string,
      requiredDuringInsert: true);
  static const VerificationMeta _numeroChamadaMeta =
      const VerificationMeta('numeroChamada');
  @override
  late final GeneratedColumn<int> numeroChamada = GeneratedColumn<int>(
      'numero_chamada', aliasedName, true,
      type: DriftSqlType.int, requiredDuringInsert: false);
  static const VerificationMeta _ativoMeta = const VerificationMeta('ativo');
  @override
  late final GeneratedColumn<bool> ativo = GeneratedColumn<bool>(
      'ativo', aliasedName, false,
      type: DriftSqlType.bool,
      requiredDuringInsert: false,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('CHECK ("ativo" IN (0, 1))'),
      defaultValue: const Constant(true));
  static const VerificationMeta _createdAtMeta =
      const VerificationMeta('createdAt');
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
      'created_at', aliasedName, true,
      type: DriftSqlType.dateTime, requiredDuringInsert: false);
  static const VerificationMeta _updatedAtMeta =
      const VerificationMeta('updatedAt');
  @override
  late final GeneratedColumn<DateTime> updatedAt = GeneratedColumn<DateTime>(
      'updated_at', aliasedName, true,
      type: DriftSqlType.dateTime, requiredDuringInsert: false);
  @override
  List<GeneratedColumn> get $columns =>
      [id, turmaId, nome, numeroChamada, ativo, createdAt, updatedAt];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'alunos';
  @override
  VerificationContext validateIntegrity(Insertable<Aluno> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('turma_id')) {
      context.handle(_turmaIdMeta,
          turmaId.isAcceptableOrUnknown(data['turma_id']!, _turmaIdMeta));
    } else if (isInserting) {
      context.missing(_turmaIdMeta);
    }
    if (data.containsKey('nome')) {
      context.handle(
          _nomeMeta, nome.isAcceptableOrUnknown(data['nome']!, _nomeMeta));
    } else if (isInserting) {
      context.missing(_nomeMeta);
    }
    if (data.containsKey('numero_chamada')) {
      context.handle(
          _numeroChamadaMeta,
          numeroChamada.isAcceptableOrUnknown(
              data['numero_chamada']!, _numeroChamadaMeta));
    }
    if (data.containsKey('ativo')) {
      context.handle(
          _ativoMeta, ativo.isAcceptableOrUnknown(data['ativo']!, _ativoMeta));
    }
    if (data.containsKey('created_at')) {
      context.handle(_createdAtMeta,
          createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta));
    }
    if (data.containsKey('updated_at')) {
      context.handle(_updatedAtMeta,
          updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta));
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  Aluno map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Aluno(
      id: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}id'])!,
      turmaId: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}turma_id'])!,
      nome: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}nome'])!,
      numeroChamada: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}numero_chamada']),
      ativo: attachedDatabase.typeMapping
          .read(DriftSqlType.bool, data['${effectivePrefix}ativo'])!,
      createdAt: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}created_at']),
      updatedAt: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}updated_at']),
    );
  }

  @override
  $AlunosTable createAlias(String alias) {
    return $AlunosTable(attachedDatabase, alias);
  }
}

class Aluno extends DataClass implements Insertable<Aluno> {
  final int id;
  final int turmaId;
  final String nome;
  final int? numeroChamada;
  final bool ativo;
  final DateTime? createdAt;
  final DateTime? updatedAt;
  const Aluno(
      {required this.id,
      required this.turmaId,
      required this.nome,
      this.numeroChamada,
      required this.ativo,
      this.createdAt,
      this.updatedAt});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['turma_id'] = Variable<int>(turmaId);
    map['nome'] = Variable<String>(nome);
    if (!nullToAbsent || numeroChamada != null) {
      map['numero_chamada'] = Variable<int>(numeroChamada);
    }
    map['ativo'] = Variable<bool>(ativo);
    if (!nullToAbsent || createdAt != null) {
      map['created_at'] = Variable<DateTime>(createdAt);
    }
    if (!nullToAbsent || updatedAt != null) {
      map['updated_at'] = Variable<DateTime>(updatedAt);
    }
    return map;
  }

  AlunosCompanion toCompanion(bool nullToAbsent) {
    return AlunosCompanion(
      id: Value(id),
      turmaId: Value(turmaId),
      nome: Value(nome),
      numeroChamada: numeroChamada == null && nullToAbsent
          ? const Value.absent()
          : Value(numeroChamada),
      ativo: Value(ativo),
      createdAt: createdAt == null && nullToAbsent
          ? const Value.absent()
          : Value(createdAt),
      updatedAt: updatedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(updatedAt),
    );
  }

  factory Aluno.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Aluno(
      id: serializer.fromJson<int>(json['id']),
      turmaId: serializer.fromJson<int>(json['turmaId']),
      nome: serializer.fromJson<String>(json['nome']),
      numeroChamada: serializer.fromJson<int?>(json['numeroChamada']),
      ativo: serializer.fromJson<bool>(json['ativo']),
      createdAt: serializer.fromJson<DateTime?>(json['createdAt']),
      updatedAt: serializer.fromJson<DateTime?>(json['updatedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'turmaId': serializer.toJson<int>(turmaId),
      'nome': serializer.toJson<String>(nome),
      'numeroChamada': serializer.toJson<int?>(numeroChamada),
      'ativo': serializer.toJson<bool>(ativo),
      'createdAt': serializer.toJson<DateTime?>(createdAt),
      'updatedAt': serializer.toJson<DateTime?>(updatedAt),
    };
  }

  Aluno copyWith(
          {int? id,
          int? turmaId,
          String? nome,
          Value<int?> numeroChamada = const Value.absent(),
          bool? ativo,
          Value<DateTime?> createdAt = const Value.absent(),
          Value<DateTime?> updatedAt = const Value.absent()}) =>
      Aluno(
        id: id ?? this.id,
        turmaId: turmaId ?? this.turmaId,
        nome: nome ?? this.nome,
        numeroChamada:
            numeroChamada.present ? numeroChamada.value : this.numeroChamada,
        ativo: ativo ?? this.ativo,
        createdAt: createdAt.present ? createdAt.value : this.createdAt,
        updatedAt: updatedAt.present ? updatedAt.value : this.updatedAt,
      );
  Aluno copyWithCompanion(AlunosCompanion data) {
    return Aluno(
      id: data.id.present ? data.id.value : this.id,
      turmaId: data.turmaId.present ? data.turmaId.value : this.turmaId,
      nome: data.nome.present ? data.nome.value : this.nome,
      numeroChamada: data.numeroChamada.present
          ? data.numeroChamada.value
          : this.numeroChamada,
      ativo: data.ativo.present ? data.ativo.value : this.ativo,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('Aluno(')
          ..write('id: $id, ')
          ..write('turmaId: $turmaId, ')
          ..write('nome: $nome, ')
          ..write('numeroChamada: $numeroChamada, ')
          ..write('ativo: $ativo, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
      id, turmaId, nome, numeroChamada, ativo, createdAt, updatedAt);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Aluno &&
          other.id == this.id &&
          other.turmaId == this.turmaId &&
          other.nome == this.nome &&
          other.numeroChamada == this.numeroChamada &&
          other.ativo == this.ativo &&
          other.createdAt == this.createdAt &&
          other.updatedAt == this.updatedAt);
}

class AlunosCompanion extends UpdateCompanion<Aluno> {
  final Value<int> id;
  final Value<int> turmaId;
  final Value<String> nome;
  final Value<int?> numeroChamada;
  final Value<bool> ativo;
  final Value<DateTime?> createdAt;
  final Value<DateTime?> updatedAt;
  const AlunosCompanion({
    this.id = const Value.absent(),
    this.turmaId = const Value.absent(),
    this.nome = const Value.absent(),
    this.numeroChamada = const Value.absent(),
    this.ativo = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
  });
  AlunosCompanion.insert({
    this.id = const Value.absent(),
    required int turmaId,
    required String nome,
    this.numeroChamada = const Value.absent(),
    this.ativo = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
  })  : turmaId = Value(turmaId),
        nome = Value(nome);
  static Insertable<Aluno> custom({
    Expression<int>? id,
    Expression<int>? turmaId,
    Expression<String>? nome,
    Expression<int>? numeroChamada,
    Expression<bool>? ativo,
    Expression<DateTime>? createdAt,
    Expression<DateTime>? updatedAt,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (turmaId != null) 'turma_id': turmaId,
      if (nome != null) 'nome': nome,
      if (numeroChamada != null) 'numero_chamada': numeroChamada,
      if (ativo != null) 'ativo': ativo,
      if (createdAt != null) 'created_at': createdAt,
      if (updatedAt != null) 'updated_at': updatedAt,
    });
  }

  AlunosCompanion copyWith(
      {Value<int>? id,
      Value<int>? turmaId,
      Value<String>? nome,
      Value<int?>? numeroChamada,
      Value<bool>? ativo,
      Value<DateTime?>? createdAt,
      Value<DateTime?>? updatedAt}) {
    return AlunosCompanion(
      id: id ?? this.id,
      turmaId: turmaId ?? this.turmaId,
      nome: nome ?? this.nome,
      numeroChamada: numeroChamada ?? this.numeroChamada,
      ativo: ativo ?? this.ativo,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (turmaId.present) {
      map['turma_id'] = Variable<int>(turmaId.value);
    }
    if (nome.present) {
      map['nome'] = Variable<String>(nome.value);
    }
    if (numeroChamada.present) {
      map['numero_chamada'] = Variable<int>(numeroChamada.value);
    }
    if (ativo.present) {
      map['ativo'] = Variable<bool>(ativo.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<DateTime>(updatedAt.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('AlunosCompanion(')
          ..write('id: $id, ')
          ..write('turmaId: $turmaId, ')
          ..write('nome: $nome, ')
          ..write('numeroChamada: $numeroChamada, ')
          ..write('ativo: $ativo, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt')
          ..write(')'))
        .toString();
  }
}

class $PresencasTable extends Presencas
    with TableInfo<$PresencasTable, Presenca> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $PresencasTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
      'id', aliasedName, false,
      hasAutoIncrement: true,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('PRIMARY KEY AUTOINCREMENT'));
  static const VerificationMeta _aulaIdMeta = const VerificationMeta('aulaId');
  @override
  late final GeneratedColumn<int> aulaId = GeneratedColumn<int>(
      'aula_id', aliasedName, false,
      type: DriftSqlType.int, requiredDuringInsert: true);
  static const VerificationMeta _alunoIdMeta =
      const VerificationMeta('alunoId');
  @override
  late final GeneratedColumn<int> alunoId = GeneratedColumn<int>(
      'aluno_id', aliasedName, false,
      type: DriftSqlType.int, requiredDuringInsert: true);
  static const VerificationMeta _aulaIndexMeta =
      const VerificationMeta('aulaIndex');
  @override
  late final GeneratedColumn<int> aulaIndex = GeneratedColumn<int>(
      'aula_index', aliasedName, false,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      defaultValue: const Constant(0));
  static const VerificationMeta _presenteMeta =
      const VerificationMeta('presente');
  @override
  late final GeneratedColumn<bool> presente = GeneratedColumn<bool>(
      'presente', aliasedName, false,
      type: DriftSqlType.bool,
      requiredDuringInsert: false,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('CHECK ("presente" IN (0, 1))'),
      defaultValue: const Constant(true));
  static const VerificationMeta _justificativaMeta =
      const VerificationMeta('justificativa');
  @override
  late final GeneratedColumn<String> justificativa = GeneratedColumn<String>(
      'justificativa', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _createdAtMeta =
      const VerificationMeta('createdAt');
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
      'created_at', aliasedName, true,
      type: DriftSqlType.dateTime, requiredDuringInsert: false);
  static const VerificationMeta _updatedAtMeta =
      const VerificationMeta('updatedAt');
  @override
  late final GeneratedColumn<DateTime> updatedAt = GeneratedColumn<DateTime>(
      'updated_at', aliasedName, true,
      type: DriftSqlType.dateTime, requiredDuringInsert: false);
  @override
  List<GeneratedColumn> get $columns => [
        id,
        aulaId,
        alunoId,
        aulaIndex,
        presente,
        justificativa,
        createdAt,
        updatedAt
      ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'presencas';
  @override
  VerificationContext validateIntegrity(Insertable<Presenca> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('aula_id')) {
      context.handle(_aulaIdMeta,
          aulaId.isAcceptableOrUnknown(data['aula_id']!, _aulaIdMeta));
    } else if (isInserting) {
      context.missing(_aulaIdMeta);
    }
    if (data.containsKey('aluno_id')) {
      context.handle(_alunoIdMeta,
          alunoId.isAcceptableOrUnknown(data['aluno_id']!, _alunoIdMeta));
    } else if (isInserting) {
      context.missing(_alunoIdMeta);
    }
    if (data.containsKey('aula_index')) {
      context.handle(_aulaIndexMeta,
          aulaIndex.isAcceptableOrUnknown(data['aula_index']!, _aulaIndexMeta));
    }
    if (data.containsKey('presente')) {
      context.handle(_presenteMeta,
          presente.isAcceptableOrUnknown(data['presente']!, _presenteMeta));
    }
    if (data.containsKey('justificativa')) {
      context.handle(
          _justificativaMeta,
          justificativa.isAcceptableOrUnknown(
              data['justificativa']!, _justificativaMeta));
    }
    if (data.containsKey('created_at')) {
      context.handle(_createdAtMeta,
          createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta));
    }
    if (data.containsKey('updated_at')) {
      context.handle(_updatedAtMeta,
          updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta));
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  List<Set<GeneratedColumn>> get uniqueKeys => [
        {aulaId, alunoId, aulaIndex},
      ];
  @override
  Presenca map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Presenca(
      id: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}id'])!,
      aulaId: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}aula_id'])!,
      alunoId: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}aluno_id'])!,
      aulaIndex: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}aula_index'])!,
      presente: attachedDatabase.typeMapping
          .read(DriftSqlType.bool, data['${effectivePrefix}presente'])!,
      justificativa: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}justificativa']),
      createdAt: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}created_at']),
      updatedAt: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}updated_at']),
    );
  }

  @override
  $PresencasTable createAlias(String alias) {
    return $PresencasTable(attachedDatabase, alias);
  }
}

class Presenca extends DataClass implements Insertable<Presenca> {
  final int id;
  final int aulaId;
  final int alunoId;
  final int aulaIndex;
  final bool presente;
  final String? justificativa;
  final DateTime? createdAt;
  final DateTime? updatedAt;
  const Presenca(
      {required this.id,
      required this.aulaId,
      required this.alunoId,
      required this.aulaIndex,
      required this.presente,
      this.justificativa,
      this.createdAt,
      this.updatedAt});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['aula_id'] = Variable<int>(aulaId);
    map['aluno_id'] = Variable<int>(alunoId);
    map['aula_index'] = Variable<int>(aulaIndex);
    map['presente'] = Variable<bool>(presente);
    if (!nullToAbsent || justificativa != null) {
      map['justificativa'] = Variable<String>(justificativa);
    }
    if (!nullToAbsent || createdAt != null) {
      map['created_at'] = Variable<DateTime>(createdAt);
    }
    if (!nullToAbsent || updatedAt != null) {
      map['updated_at'] = Variable<DateTime>(updatedAt);
    }
    return map;
  }

  PresencasCompanion toCompanion(bool nullToAbsent) {
    return PresencasCompanion(
      id: Value(id),
      aulaId: Value(aulaId),
      alunoId: Value(alunoId),
      aulaIndex: Value(aulaIndex),
      presente: Value(presente),
      justificativa: justificativa == null && nullToAbsent
          ? const Value.absent()
          : Value(justificativa),
      createdAt: createdAt == null && nullToAbsent
          ? const Value.absent()
          : Value(createdAt),
      updatedAt: updatedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(updatedAt),
    );
  }

  factory Presenca.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Presenca(
      id: serializer.fromJson<int>(json['id']),
      aulaId: serializer.fromJson<int>(json['aulaId']),
      alunoId: serializer.fromJson<int>(json['alunoId']),
      aulaIndex: serializer.fromJson<int>(json['aulaIndex']),
      presente: serializer.fromJson<bool>(json['presente']),
      justificativa: serializer.fromJson<String?>(json['justificativa']),
      createdAt: serializer.fromJson<DateTime?>(json['createdAt']),
      updatedAt: serializer.fromJson<DateTime?>(json['updatedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'aulaId': serializer.toJson<int>(aulaId),
      'alunoId': serializer.toJson<int>(alunoId),
      'aulaIndex': serializer.toJson<int>(aulaIndex),
      'presente': serializer.toJson<bool>(presente),
      'justificativa': serializer.toJson<String?>(justificativa),
      'createdAt': serializer.toJson<DateTime?>(createdAt),
      'updatedAt': serializer.toJson<DateTime?>(updatedAt),
    };
  }

  Presenca copyWith(
          {int? id,
          int? aulaId,
          int? alunoId,
          int? aulaIndex,
          bool? presente,
          Value<String?> justificativa = const Value.absent(),
          Value<DateTime?> createdAt = const Value.absent(),
          Value<DateTime?> updatedAt = const Value.absent()}) =>
      Presenca(
        id: id ?? this.id,
        aulaId: aulaId ?? this.aulaId,
        alunoId: alunoId ?? this.alunoId,
        aulaIndex: aulaIndex ?? this.aulaIndex,
        presente: presente ?? this.presente,
        justificativa:
            justificativa.present ? justificativa.value : this.justificativa,
        createdAt: createdAt.present ? createdAt.value : this.createdAt,
        updatedAt: updatedAt.present ? updatedAt.value : this.updatedAt,
      );
  Presenca copyWithCompanion(PresencasCompanion data) {
    return Presenca(
      id: data.id.present ? data.id.value : this.id,
      aulaId: data.aulaId.present ? data.aulaId.value : this.aulaId,
      alunoId: data.alunoId.present ? data.alunoId.value : this.alunoId,
      aulaIndex: data.aulaIndex.present ? data.aulaIndex.value : this.aulaIndex,
      presente: data.presente.present ? data.presente.value : this.presente,
      justificativa: data.justificativa.present
          ? data.justificativa.value
          : this.justificativa,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('Presenca(')
          ..write('id: $id, ')
          ..write('aulaId: $aulaId, ')
          ..write('alunoId: $alunoId, ')
          ..write('aulaIndex: $aulaIndex, ')
          ..write('presente: $presente, ')
          ..write('justificativa: $justificativa, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, aulaId, alunoId, aulaIndex, presente,
      justificativa, createdAt, updatedAt);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Presenca &&
          other.id == this.id &&
          other.aulaId == this.aulaId &&
          other.alunoId == this.alunoId &&
          other.aulaIndex == this.aulaIndex &&
          other.presente == this.presente &&
          other.justificativa == this.justificativa &&
          other.createdAt == this.createdAt &&
          other.updatedAt == this.updatedAt);
}

class PresencasCompanion extends UpdateCompanion<Presenca> {
  final Value<int> id;
  final Value<int> aulaId;
  final Value<int> alunoId;
  final Value<int> aulaIndex;
  final Value<bool> presente;
  final Value<String?> justificativa;
  final Value<DateTime?> createdAt;
  final Value<DateTime?> updatedAt;
  const PresencasCompanion({
    this.id = const Value.absent(),
    this.aulaId = const Value.absent(),
    this.alunoId = const Value.absent(),
    this.aulaIndex = const Value.absent(),
    this.presente = const Value.absent(),
    this.justificativa = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
  });
  PresencasCompanion.insert({
    this.id = const Value.absent(),
    required int aulaId,
    required int alunoId,
    this.aulaIndex = const Value.absent(),
    this.presente = const Value.absent(),
    this.justificativa = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
  })  : aulaId = Value(aulaId),
        alunoId = Value(alunoId);
  static Insertable<Presenca> custom({
    Expression<int>? id,
    Expression<int>? aulaId,
    Expression<int>? alunoId,
    Expression<int>? aulaIndex,
    Expression<bool>? presente,
    Expression<String>? justificativa,
    Expression<DateTime>? createdAt,
    Expression<DateTime>? updatedAt,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (aulaId != null) 'aula_id': aulaId,
      if (alunoId != null) 'aluno_id': alunoId,
      if (aulaIndex != null) 'aula_index': aulaIndex,
      if (presente != null) 'presente': presente,
      if (justificativa != null) 'justificativa': justificativa,
      if (createdAt != null) 'created_at': createdAt,
      if (updatedAt != null) 'updated_at': updatedAt,
    });
  }

  PresencasCompanion copyWith(
      {Value<int>? id,
      Value<int>? aulaId,
      Value<int>? alunoId,
      Value<int>? aulaIndex,
      Value<bool>? presente,
      Value<String?>? justificativa,
      Value<DateTime?>? createdAt,
      Value<DateTime?>? updatedAt}) {
    return PresencasCompanion(
      id: id ?? this.id,
      aulaId: aulaId ?? this.aulaId,
      alunoId: alunoId ?? this.alunoId,
      aulaIndex: aulaIndex ?? this.aulaIndex,
      presente: presente ?? this.presente,
      justificativa: justificativa ?? this.justificativa,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (aulaId.present) {
      map['aula_id'] = Variable<int>(aulaId.value);
    }
    if (alunoId.present) {
      map['aluno_id'] = Variable<int>(alunoId.value);
    }
    if (aulaIndex.present) {
      map['aula_index'] = Variable<int>(aulaIndex.value);
    }
    if (presente.present) {
      map['presente'] = Variable<bool>(presente.value);
    }
    if (justificativa.present) {
      map['justificativa'] = Variable<String>(justificativa.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<DateTime>(updatedAt.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('PresencasCompanion(')
          ..write('id: $id, ')
          ..write('aulaId: $aulaId, ')
          ..write('alunoId: $alunoId, ')
          ..write('aulaIndex: $aulaIndex, ')
          ..write('presente: $presente, ')
          ..write('justificativa: $justificativa, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt')
          ..write(')'))
        .toString();
  }
}

class $ConteudosAulaTable extends ConteudosAula
    with TableInfo<$ConteudosAulaTable, ConteudosAulaData> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $ConteudosAulaTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
      'id', aliasedName, false,
      hasAutoIncrement: true,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('PRIMARY KEY AUTOINCREMENT'));
  static const VerificationMeta _aulaIdMeta = const VerificationMeta('aulaId');
  @override
  late final GeneratedColumn<int> aulaId = GeneratedColumn<int>(
      'aula_id', aliasedName, false,
      type: DriftSqlType.int, requiredDuringInsert: true);
  static const VerificationMeta _textoMeta = const VerificationMeta('texto');
  @override
  late final GeneratedColumn<String> texto = GeneratedColumn<String>(
      'texto', aliasedName, false,
      additionalChecks: GeneratedColumn.checkTextLength(
          minTextLength: 0, maxTextLength: 5000),
      type: DriftSqlType.string,
      requiredDuringInsert: true);
  static const VerificationMeta _createdAtMeta =
      const VerificationMeta('createdAt');
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
      'created_at', aliasedName, true,
      type: DriftSqlType.dateTime, requiredDuringInsert: false);
  static const VerificationMeta _updatedAtMeta =
      const VerificationMeta('updatedAt');
  @override
  late final GeneratedColumn<DateTime> updatedAt = GeneratedColumn<DateTime>(
      'updated_at', aliasedName, true,
      type: DriftSqlType.dateTime, requiredDuringInsert: false);
  @override
  List<GeneratedColumn> get $columns =>
      [id, aulaId, texto, createdAt, updatedAt];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'conteudos_aula';
  @override
  VerificationContext validateIntegrity(Insertable<ConteudosAulaData> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('aula_id')) {
      context.handle(_aulaIdMeta,
          aulaId.isAcceptableOrUnknown(data['aula_id']!, _aulaIdMeta));
    } else if (isInserting) {
      context.missing(_aulaIdMeta);
    }
    if (data.containsKey('texto')) {
      context.handle(
          _textoMeta, texto.isAcceptableOrUnknown(data['texto']!, _textoMeta));
    } else if (isInserting) {
      context.missing(_textoMeta);
    }
    if (data.containsKey('created_at')) {
      context.handle(_createdAtMeta,
          createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta));
    }
    if (data.containsKey('updated_at')) {
      context.handle(_updatedAtMeta,
          updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta));
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  ConteudosAulaData map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return ConteudosAulaData(
      id: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}id'])!,
      aulaId: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}aula_id'])!,
      texto: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}texto'])!,
      createdAt: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}created_at']),
      updatedAt: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}updated_at']),
    );
  }

  @override
  $ConteudosAulaTable createAlias(String alias) {
    return $ConteudosAulaTable(attachedDatabase, alias);
  }
}

class ConteudosAulaData extends DataClass
    implements Insertable<ConteudosAulaData> {
  final int id;
  final int aulaId;
  final String texto;
  final DateTime? createdAt;
  final DateTime? updatedAt;
  const ConteudosAulaData(
      {required this.id,
      required this.aulaId,
      required this.texto,
      this.createdAt,
      this.updatedAt});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['aula_id'] = Variable<int>(aulaId);
    map['texto'] = Variable<String>(texto);
    if (!nullToAbsent || createdAt != null) {
      map['created_at'] = Variable<DateTime>(createdAt);
    }
    if (!nullToAbsent || updatedAt != null) {
      map['updated_at'] = Variable<DateTime>(updatedAt);
    }
    return map;
  }

  ConteudosAulaCompanion toCompanion(bool nullToAbsent) {
    return ConteudosAulaCompanion(
      id: Value(id),
      aulaId: Value(aulaId),
      texto: Value(texto),
      createdAt: createdAt == null && nullToAbsent
          ? const Value.absent()
          : Value(createdAt),
      updatedAt: updatedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(updatedAt),
    );
  }

  factory ConteudosAulaData.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return ConteudosAulaData(
      id: serializer.fromJson<int>(json['id']),
      aulaId: serializer.fromJson<int>(json['aulaId']),
      texto: serializer.fromJson<String>(json['texto']),
      createdAt: serializer.fromJson<DateTime?>(json['createdAt']),
      updatedAt: serializer.fromJson<DateTime?>(json['updatedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'aulaId': serializer.toJson<int>(aulaId),
      'texto': serializer.toJson<String>(texto),
      'createdAt': serializer.toJson<DateTime?>(createdAt),
      'updatedAt': serializer.toJson<DateTime?>(updatedAt),
    };
  }

  ConteudosAulaData copyWith(
          {int? id,
          int? aulaId,
          String? texto,
          Value<DateTime?> createdAt = const Value.absent(),
          Value<DateTime?> updatedAt = const Value.absent()}) =>
      ConteudosAulaData(
        id: id ?? this.id,
        aulaId: aulaId ?? this.aulaId,
        texto: texto ?? this.texto,
        createdAt: createdAt.present ? createdAt.value : this.createdAt,
        updatedAt: updatedAt.present ? updatedAt.value : this.updatedAt,
      );
  ConteudosAulaData copyWithCompanion(ConteudosAulaCompanion data) {
    return ConteudosAulaData(
      id: data.id.present ? data.id.value : this.id,
      aulaId: data.aulaId.present ? data.aulaId.value : this.aulaId,
      texto: data.texto.present ? data.texto.value : this.texto,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('ConteudosAulaData(')
          ..write('id: $id, ')
          ..write('aulaId: $aulaId, ')
          ..write('texto: $texto, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, aulaId, texto, createdAt, updatedAt);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is ConteudosAulaData &&
          other.id == this.id &&
          other.aulaId == this.aulaId &&
          other.texto == this.texto &&
          other.createdAt == this.createdAt &&
          other.updatedAt == this.updatedAt);
}

class ConteudosAulaCompanion extends UpdateCompanion<ConteudosAulaData> {
  final Value<int> id;
  final Value<int> aulaId;
  final Value<String> texto;
  final Value<DateTime?> createdAt;
  final Value<DateTime?> updatedAt;
  const ConteudosAulaCompanion({
    this.id = const Value.absent(),
    this.aulaId = const Value.absent(),
    this.texto = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
  });
  ConteudosAulaCompanion.insert({
    this.id = const Value.absent(),
    required int aulaId,
    required String texto,
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
  })  : aulaId = Value(aulaId),
        texto = Value(texto);
  static Insertable<ConteudosAulaData> custom({
    Expression<int>? id,
    Expression<int>? aulaId,
    Expression<String>? texto,
    Expression<DateTime>? createdAt,
    Expression<DateTime>? updatedAt,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (aulaId != null) 'aula_id': aulaId,
      if (texto != null) 'texto': texto,
      if (createdAt != null) 'created_at': createdAt,
      if (updatedAt != null) 'updated_at': updatedAt,
    });
  }

  ConteudosAulaCompanion copyWith(
      {Value<int>? id,
      Value<int>? aulaId,
      Value<String>? texto,
      Value<DateTime?>? createdAt,
      Value<DateTime?>? updatedAt}) {
    return ConteudosAulaCompanion(
      id: id ?? this.id,
      aulaId: aulaId ?? this.aulaId,
      texto: texto ?? this.texto,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (aulaId.present) {
      map['aula_id'] = Variable<int>(aulaId.value);
    }
    if (texto.present) {
      map['texto'] = Variable<String>(texto.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<DateTime>(updatedAt.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('ConteudosAulaCompanion(')
          ..write('id: $id, ')
          ..write('aulaId: $aulaId, ')
          ..write('texto: $texto, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt')
          ..write(')'))
        .toString();
  }
}

class $ObservacoesAulaTable extends ObservacoesAula
    with TableInfo<$ObservacoesAulaTable, ObservacoesAulaData> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $ObservacoesAulaTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
      'id', aliasedName, false,
      hasAutoIncrement: true,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('PRIMARY KEY AUTOINCREMENT'));
  static const VerificationMeta _aulaIdMeta = const VerificationMeta('aulaId');
  @override
  late final GeneratedColumn<int> aulaId = GeneratedColumn<int>(
      'aula_id', aliasedName, false,
      type: DriftSqlType.int, requiredDuringInsert: true);
  static const VerificationMeta _textoMeta = const VerificationMeta('texto');
  @override
  late final GeneratedColumn<String> texto = GeneratedColumn<String>(
      'texto', aliasedName, false,
      additionalChecks: GeneratedColumn.checkTextLength(
          minTextLength: 0, maxTextLength: 5000),
      type: DriftSqlType.string,
      requiredDuringInsert: true);
  static const VerificationMeta _createdAtMeta =
      const VerificationMeta('createdAt');
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
      'created_at', aliasedName, true,
      type: DriftSqlType.dateTime, requiredDuringInsert: false);
  static const VerificationMeta _updatedAtMeta =
      const VerificationMeta('updatedAt');
  @override
  late final GeneratedColumn<DateTime> updatedAt = GeneratedColumn<DateTime>(
      'updated_at', aliasedName, true,
      type: DriftSqlType.dateTime, requiredDuringInsert: false);
  @override
  List<GeneratedColumn> get $columns =>
      [id, aulaId, texto, createdAt, updatedAt];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'observacoes_aula';
  @override
  VerificationContext validateIntegrity(
      Insertable<ObservacoesAulaData> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('aula_id')) {
      context.handle(_aulaIdMeta,
          aulaId.isAcceptableOrUnknown(data['aula_id']!, _aulaIdMeta));
    } else if (isInserting) {
      context.missing(_aulaIdMeta);
    }
    if (data.containsKey('texto')) {
      context.handle(
          _textoMeta, texto.isAcceptableOrUnknown(data['texto']!, _textoMeta));
    } else if (isInserting) {
      context.missing(_textoMeta);
    }
    if (data.containsKey('created_at')) {
      context.handle(_createdAtMeta,
          createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta));
    }
    if (data.containsKey('updated_at')) {
      context.handle(_updatedAtMeta,
          updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta));
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  ObservacoesAulaData map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return ObservacoesAulaData(
      id: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}id'])!,
      aulaId: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}aula_id'])!,
      texto: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}texto'])!,
      createdAt: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}created_at']),
      updatedAt: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}updated_at']),
    );
  }

  @override
  $ObservacoesAulaTable createAlias(String alias) {
    return $ObservacoesAulaTable(attachedDatabase, alias);
  }
}

class ObservacoesAulaData extends DataClass
    implements Insertable<ObservacoesAulaData> {
  final int id;
  final int aulaId;
  final String texto;
  final DateTime? createdAt;
  final DateTime? updatedAt;
  const ObservacoesAulaData(
      {required this.id,
      required this.aulaId,
      required this.texto,
      this.createdAt,
      this.updatedAt});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['aula_id'] = Variable<int>(aulaId);
    map['texto'] = Variable<String>(texto);
    if (!nullToAbsent || createdAt != null) {
      map['created_at'] = Variable<DateTime>(createdAt);
    }
    if (!nullToAbsent || updatedAt != null) {
      map['updated_at'] = Variable<DateTime>(updatedAt);
    }
    return map;
  }

  ObservacoesAulaCompanion toCompanion(bool nullToAbsent) {
    return ObservacoesAulaCompanion(
      id: Value(id),
      aulaId: Value(aulaId),
      texto: Value(texto),
      createdAt: createdAt == null && nullToAbsent
          ? const Value.absent()
          : Value(createdAt),
      updatedAt: updatedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(updatedAt),
    );
  }

  factory ObservacoesAulaData.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return ObservacoesAulaData(
      id: serializer.fromJson<int>(json['id']),
      aulaId: serializer.fromJson<int>(json['aulaId']),
      texto: serializer.fromJson<String>(json['texto']),
      createdAt: serializer.fromJson<DateTime?>(json['createdAt']),
      updatedAt: serializer.fromJson<DateTime?>(json['updatedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'aulaId': serializer.toJson<int>(aulaId),
      'texto': serializer.toJson<String>(texto),
      'createdAt': serializer.toJson<DateTime?>(createdAt),
      'updatedAt': serializer.toJson<DateTime?>(updatedAt),
    };
  }

  ObservacoesAulaData copyWith(
          {int? id,
          int? aulaId,
          String? texto,
          Value<DateTime?> createdAt = const Value.absent(),
          Value<DateTime?> updatedAt = const Value.absent()}) =>
      ObservacoesAulaData(
        id: id ?? this.id,
        aulaId: aulaId ?? this.aulaId,
        texto: texto ?? this.texto,
        createdAt: createdAt.present ? createdAt.value : this.createdAt,
        updatedAt: updatedAt.present ? updatedAt.value : this.updatedAt,
      );
  ObservacoesAulaData copyWithCompanion(ObservacoesAulaCompanion data) {
    return ObservacoesAulaData(
      id: data.id.present ? data.id.value : this.id,
      aulaId: data.aulaId.present ? data.aulaId.value : this.aulaId,
      texto: data.texto.present ? data.texto.value : this.texto,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('ObservacoesAulaData(')
          ..write('id: $id, ')
          ..write('aulaId: $aulaId, ')
          ..write('texto: $texto, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, aulaId, texto, createdAt, updatedAt);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is ObservacoesAulaData &&
          other.id == this.id &&
          other.aulaId == this.aulaId &&
          other.texto == this.texto &&
          other.createdAt == this.createdAt &&
          other.updatedAt == this.updatedAt);
}

class ObservacoesAulaCompanion extends UpdateCompanion<ObservacoesAulaData> {
  final Value<int> id;
  final Value<int> aulaId;
  final Value<String> texto;
  final Value<DateTime?> createdAt;
  final Value<DateTime?> updatedAt;
  const ObservacoesAulaCompanion({
    this.id = const Value.absent(),
    this.aulaId = const Value.absent(),
    this.texto = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
  });
  ObservacoesAulaCompanion.insert({
    this.id = const Value.absent(),
    required int aulaId,
    required String texto,
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
  })  : aulaId = Value(aulaId),
        texto = Value(texto);
  static Insertable<ObservacoesAulaData> custom({
    Expression<int>? id,
    Expression<int>? aulaId,
    Expression<String>? texto,
    Expression<DateTime>? createdAt,
    Expression<DateTime>? updatedAt,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (aulaId != null) 'aula_id': aulaId,
      if (texto != null) 'texto': texto,
      if (createdAt != null) 'created_at': createdAt,
      if (updatedAt != null) 'updated_at': updatedAt,
    });
  }

  ObservacoesAulaCompanion copyWith(
      {Value<int>? id,
      Value<int>? aulaId,
      Value<String>? texto,
      Value<DateTime?>? createdAt,
      Value<DateTime?>? updatedAt}) {
    return ObservacoesAulaCompanion(
      id: id ?? this.id,
      aulaId: aulaId ?? this.aulaId,
      texto: texto ?? this.texto,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (aulaId.present) {
      map['aula_id'] = Variable<int>(aulaId.value);
    }
    if (texto.present) {
      map['texto'] = Variable<String>(texto.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<DateTime>(updatedAt.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('ObservacoesAulaCompanion(')
          ..write('id: $id, ')
          ..write('aulaId: $aulaId, ')
          ..write('texto: $texto, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt')
          ..write(')'))
        .toString();
  }
}

class $NotasAulaTable extends NotasAula
    with TableInfo<$NotasAulaTable, NotasAulaData> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $NotasAulaTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
      'id', aliasedName, false,
      hasAutoIncrement: true,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('PRIMARY KEY AUTOINCREMENT'));
  static const VerificationMeta _aulaIdMeta = const VerificationMeta('aulaId');
  @override
  late final GeneratedColumn<int> aulaId = GeneratedColumn<int>(
      'aula_id', aliasedName, false,
      type: DriftSqlType.int, requiredDuringInsert: true);
  static const VerificationMeta _tipoMeta = const VerificationMeta('tipo');
  @override
  late final GeneratedColumn<String> tipo = GeneratedColumn<String>(
      'tipo', aliasedName, false,
      additionalChecks:
          GeneratedColumn.checkTextLength(minTextLength: 1, maxTextLength: 30),
      type: DriftSqlType.string,
      requiredDuringInsert: true);
  static const VerificationMeta _valorTotalMeta =
      const VerificationMeta('valorTotal');
  @override
  late final GeneratedColumn<double> valorTotal = GeneratedColumn<double>(
      'valor_total', aliasedName, true,
      type: DriftSqlType.double, requiredDuringInsert: false);
  static const VerificationMeta _createdAtMeta =
      const VerificationMeta('createdAt');
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
      'created_at', aliasedName, true,
      type: DriftSqlType.dateTime, requiredDuringInsert: false);
  static const VerificationMeta _updatedAtMeta =
      const VerificationMeta('updatedAt');
  @override
  late final GeneratedColumn<DateTime> updatedAt = GeneratedColumn<DateTime>(
      'updated_at', aliasedName, true,
      type: DriftSqlType.dateTime, requiredDuringInsert: false);
  static const VerificationMeta _tituloMeta = const VerificationMeta('titulo');
  @override
  late final GeneratedColumn<String> titulo = GeneratedColumn<String>(
      'titulo', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  @override
  List<GeneratedColumn> get $columns =>
      [id, aulaId, tipo, valorTotal, createdAt, updatedAt, titulo];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'notas_aula';
  @override
  VerificationContext validateIntegrity(Insertable<NotasAulaData> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('aula_id')) {
      context.handle(_aulaIdMeta,
          aulaId.isAcceptableOrUnknown(data['aula_id']!, _aulaIdMeta));
    } else if (isInserting) {
      context.missing(_aulaIdMeta);
    }
    if (data.containsKey('tipo')) {
      context.handle(
          _tipoMeta, tipo.isAcceptableOrUnknown(data['tipo']!, _tipoMeta));
    } else if (isInserting) {
      context.missing(_tipoMeta);
    }
    if (data.containsKey('valor_total')) {
      context.handle(
          _valorTotalMeta,
          valorTotal.isAcceptableOrUnknown(
              data['valor_total']!, _valorTotalMeta));
    }
    if (data.containsKey('created_at')) {
      context.handle(_createdAtMeta,
          createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta));
    }
    if (data.containsKey('updated_at')) {
      context.handle(_updatedAtMeta,
          updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta));
    }
    if (data.containsKey('titulo')) {
      context.handle(_tituloMeta,
          titulo.isAcceptableOrUnknown(data['titulo']!, _tituloMeta));
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  List<Set<GeneratedColumn>> get uniqueKeys => [
        {aulaId},
      ];
  @override
  NotasAulaData map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return NotasAulaData(
      id: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}id'])!,
      aulaId: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}aula_id'])!,
      tipo: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}tipo'])!,
      valorTotal: attachedDatabase.typeMapping
          .read(DriftSqlType.double, data['${effectivePrefix}valor_total']),
      createdAt: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}created_at']),
      updatedAt: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}updated_at']),
      titulo: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}titulo']),
    );
  }

  @override
  $NotasAulaTable createAlias(String alias) {
    return $NotasAulaTable(attachedDatabase, alias);
  }
}

class NotasAulaData extends DataClass implements Insertable<NotasAulaData> {
  final int id;
  final int aulaId;
  final String tipo;
  final double? valorTotal;
  final DateTime? createdAt;
  final DateTime? updatedAt;
  final String? titulo;
  const NotasAulaData(
      {required this.id,
      required this.aulaId,
      required this.tipo,
      this.valorTotal,
      this.createdAt,
      this.updatedAt,
      this.titulo});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['aula_id'] = Variable<int>(aulaId);
    map['tipo'] = Variable<String>(tipo);
    if (!nullToAbsent || valorTotal != null) {
      map['valor_total'] = Variable<double>(valorTotal);
    }
    if (!nullToAbsent || createdAt != null) {
      map['created_at'] = Variable<DateTime>(createdAt);
    }
    if (!nullToAbsent || updatedAt != null) {
      map['updated_at'] = Variable<DateTime>(updatedAt);
    }
    if (!nullToAbsent || titulo != null) {
      map['titulo'] = Variable<String>(titulo);
    }
    return map;
  }

  NotasAulaCompanion toCompanion(bool nullToAbsent) {
    return NotasAulaCompanion(
      id: Value(id),
      aulaId: Value(aulaId),
      tipo: Value(tipo),
      valorTotal: valorTotal == null && nullToAbsent
          ? const Value.absent()
          : Value(valorTotal),
      createdAt: createdAt == null && nullToAbsent
          ? const Value.absent()
          : Value(createdAt),
      updatedAt: updatedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(updatedAt),
      titulo:
          titulo == null && nullToAbsent ? const Value.absent() : Value(titulo),
    );
  }

  factory NotasAulaData.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return NotasAulaData(
      id: serializer.fromJson<int>(json['id']),
      aulaId: serializer.fromJson<int>(json['aulaId']),
      tipo: serializer.fromJson<String>(json['tipo']),
      valorTotal: serializer.fromJson<double?>(json['valorTotal']),
      createdAt: serializer.fromJson<DateTime?>(json['createdAt']),
      updatedAt: serializer.fromJson<DateTime?>(json['updatedAt']),
      titulo: serializer.fromJson<String?>(json['titulo']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'aulaId': serializer.toJson<int>(aulaId),
      'tipo': serializer.toJson<String>(tipo),
      'valorTotal': serializer.toJson<double?>(valorTotal),
      'createdAt': serializer.toJson<DateTime?>(createdAt),
      'updatedAt': serializer.toJson<DateTime?>(updatedAt),
      'titulo': serializer.toJson<String?>(titulo),
    };
  }

  NotasAulaData copyWith(
          {int? id,
          int? aulaId,
          String? tipo,
          Value<double?> valorTotal = const Value.absent(),
          Value<DateTime?> createdAt = const Value.absent(),
          Value<DateTime?> updatedAt = const Value.absent(),
          Value<String?> titulo = const Value.absent()}) =>
      NotasAulaData(
        id: id ?? this.id,
        aulaId: aulaId ?? this.aulaId,
        tipo: tipo ?? this.tipo,
        valorTotal: valorTotal.present ? valorTotal.value : this.valorTotal,
        createdAt: createdAt.present ? createdAt.value : this.createdAt,
        updatedAt: updatedAt.present ? updatedAt.value : this.updatedAt,
        titulo: titulo.present ? titulo.value : this.titulo,
      );
  NotasAulaData copyWithCompanion(NotasAulaCompanion data) {
    return NotasAulaData(
      id: data.id.present ? data.id.value : this.id,
      aulaId: data.aulaId.present ? data.aulaId.value : this.aulaId,
      tipo: data.tipo.present ? data.tipo.value : this.tipo,
      valorTotal:
          data.valorTotal.present ? data.valorTotal.value : this.valorTotal,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
      titulo: data.titulo.present ? data.titulo.value : this.titulo,
    );
  }

  @override
  String toString() {
    return (StringBuffer('NotasAulaData(')
          ..write('id: $id, ')
          ..write('aulaId: $aulaId, ')
          ..write('tipo: $tipo, ')
          ..write('valorTotal: $valorTotal, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('titulo: $titulo')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode =>
      Object.hash(id, aulaId, tipo, valorTotal, createdAt, updatedAt, titulo);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is NotasAulaData &&
          other.id == this.id &&
          other.aulaId == this.aulaId &&
          other.tipo == this.tipo &&
          other.valorTotal == this.valorTotal &&
          other.createdAt == this.createdAt &&
          other.updatedAt == this.updatedAt &&
          other.titulo == this.titulo);
}

class NotasAulaCompanion extends UpdateCompanion<NotasAulaData> {
  final Value<int> id;
  final Value<int> aulaId;
  final Value<String> tipo;
  final Value<double?> valorTotal;
  final Value<DateTime?> createdAt;
  final Value<DateTime?> updatedAt;
  final Value<String?> titulo;
  const NotasAulaCompanion({
    this.id = const Value.absent(),
    this.aulaId = const Value.absent(),
    this.tipo = const Value.absent(),
    this.valorTotal = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.titulo = const Value.absent(),
  });
  NotasAulaCompanion.insert({
    this.id = const Value.absent(),
    required int aulaId,
    required String tipo,
    this.valorTotal = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.titulo = const Value.absent(),
  })  : aulaId = Value(aulaId),
        tipo = Value(tipo);
  static Insertable<NotasAulaData> custom({
    Expression<int>? id,
    Expression<int>? aulaId,
    Expression<String>? tipo,
    Expression<double>? valorTotal,
    Expression<DateTime>? createdAt,
    Expression<DateTime>? updatedAt,
    Expression<String>? titulo,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (aulaId != null) 'aula_id': aulaId,
      if (tipo != null) 'tipo': tipo,
      if (valorTotal != null) 'valor_total': valorTotal,
      if (createdAt != null) 'created_at': createdAt,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (titulo != null) 'titulo': titulo,
    });
  }

  NotasAulaCompanion copyWith(
      {Value<int>? id,
      Value<int>? aulaId,
      Value<String>? tipo,
      Value<double?>? valorTotal,
      Value<DateTime?>? createdAt,
      Value<DateTime?>? updatedAt,
      Value<String?>? titulo}) {
    return NotasAulaCompanion(
      id: id ?? this.id,
      aulaId: aulaId ?? this.aulaId,
      tipo: tipo ?? this.tipo,
      valorTotal: valorTotal ?? this.valorTotal,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      titulo: titulo ?? this.titulo,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (aulaId.present) {
      map['aula_id'] = Variable<int>(aulaId.value);
    }
    if (tipo.present) {
      map['tipo'] = Variable<String>(tipo.value);
    }
    if (valorTotal.present) {
      map['valor_total'] = Variable<double>(valorTotal.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<DateTime>(updatedAt.value);
    }
    if (titulo.present) {
      map['titulo'] = Variable<String>(titulo.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('NotasAulaCompanion(')
          ..write('id: $id, ')
          ..write('aulaId: $aulaId, ')
          ..write('tipo: $tipo, ')
          ..write('valorTotal: $valorTotal, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('titulo: $titulo')
          ..write(')'))
        .toString();
  }
}

class $NotasAlunoTable extends NotasAluno
    with TableInfo<$NotasAlunoTable, NotasAlunoData> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $NotasAlunoTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
      'id', aliasedName, false,
      hasAutoIncrement: true,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('PRIMARY KEY AUTOINCREMENT'));
  static const VerificationMeta _aulaIdMeta = const VerificationMeta('aulaId');
  @override
  late final GeneratedColumn<int> aulaId = GeneratedColumn<int>(
      'aula_id', aliasedName, false,
      type: DriftSqlType.int, requiredDuringInsert: true);
  static const VerificationMeta _alunoIdMeta =
      const VerificationMeta('alunoId');
  @override
  late final GeneratedColumn<int> alunoId = GeneratedColumn<int>(
      'aluno_id', aliasedName, false,
      type: DriftSqlType.int, requiredDuringInsert: true);
  static const VerificationMeta _valorMeta = const VerificationMeta('valor');
  @override
  late final GeneratedColumn<double> valor = GeneratedColumn<double>(
      'valor', aliasedName, false,
      type: DriftSqlType.double, requiredDuringInsert: true);
  static const VerificationMeta _createdAtMeta =
      const VerificationMeta('createdAt');
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
      'created_at', aliasedName, true,
      type: DriftSqlType.dateTime, requiredDuringInsert: false);
  static const VerificationMeta _updatedAtMeta =
      const VerificationMeta('updatedAt');
  @override
  late final GeneratedColumn<DateTime> updatedAt = GeneratedColumn<DateTime>(
      'updated_at', aliasedName, true,
      type: DriftSqlType.dateTime, requiredDuringInsert: false);
  @override
  List<GeneratedColumn> get $columns =>
      [id, aulaId, alunoId, valor, createdAt, updatedAt];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'notas_aluno';
  @override
  VerificationContext validateIntegrity(Insertable<NotasAlunoData> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('aula_id')) {
      context.handle(_aulaIdMeta,
          aulaId.isAcceptableOrUnknown(data['aula_id']!, _aulaIdMeta));
    } else if (isInserting) {
      context.missing(_aulaIdMeta);
    }
    if (data.containsKey('aluno_id')) {
      context.handle(_alunoIdMeta,
          alunoId.isAcceptableOrUnknown(data['aluno_id']!, _alunoIdMeta));
    } else if (isInserting) {
      context.missing(_alunoIdMeta);
    }
    if (data.containsKey('valor')) {
      context.handle(
          _valorMeta, valor.isAcceptableOrUnknown(data['valor']!, _valorMeta));
    } else if (isInserting) {
      context.missing(_valorMeta);
    }
    if (data.containsKey('created_at')) {
      context.handle(_createdAtMeta,
          createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta));
    }
    if (data.containsKey('updated_at')) {
      context.handle(_updatedAtMeta,
          updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta));
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  List<Set<GeneratedColumn>> get uniqueKeys => [
        {aulaId, alunoId},
      ];
  @override
  NotasAlunoData map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return NotasAlunoData(
      id: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}id'])!,
      aulaId: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}aula_id'])!,
      alunoId: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}aluno_id'])!,
      valor: attachedDatabase.typeMapping
          .read(DriftSqlType.double, data['${effectivePrefix}valor'])!,
      createdAt: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}created_at']),
      updatedAt: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}updated_at']),
    );
  }

  @override
  $NotasAlunoTable createAlias(String alias) {
    return $NotasAlunoTable(attachedDatabase, alias);
  }
}

class NotasAlunoData extends DataClass implements Insertable<NotasAlunoData> {
  final int id;
  final int aulaId;
  final int alunoId;
  final double valor;
  final DateTime? createdAt;
  final DateTime? updatedAt;
  const NotasAlunoData(
      {required this.id,
      required this.aulaId,
      required this.alunoId,
      required this.valor,
      this.createdAt,
      this.updatedAt});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['aula_id'] = Variable<int>(aulaId);
    map['aluno_id'] = Variable<int>(alunoId);
    map['valor'] = Variable<double>(valor);
    if (!nullToAbsent || createdAt != null) {
      map['created_at'] = Variable<DateTime>(createdAt);
    }
    if (!nullToAbsent || updatedAt != null) {
      map['updated_at'] = Variable<DateTime>(updatedAt);
    }
    return map;
  }

  NotasAlunoCompanion toCompanion(bool nullToAbsent) {
    return NotasAlunoCompanion(
      id: Value(id),
      aulaId: Value(aulaId),
      alunoId: Value(alunoId),
      valor: Value(valor),
      createdAt: createdAt == null && nullToAbsent
          ? const Value.absent()
          : Value(createdAt),
      updatedAt: updatedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(updatedAt),
    );
  }

  factory NotasAlunoData.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return NotasAlunoData(
      id: serializer.fromJson<int>(json['id']),
      aulaId: serializer.fromJson<int>(json['aulaId']),
      alunoId: serializer.fromJson<int>(json['alunoId']),
      valor: serializer.fromJson<double>(json['valor']),
      createdAt: serializer.fromJson<DateTime?>(json['createdAt']),
      updatedAt: serializer.fromJson<DateTime?>(json['updatedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'aulaId': serializer.toJson<int>(aulaId),
      'alunoId': serializer.toJson<int>(alunoId),
      'valor': serializer.toJson<double>(valor),
      'createdAt': serializer.toJson<DateTime?>(createdAt),
      'updatedAt': serializer.toJson<DateTime?>(updatedAt),
    };
  }

  NotasAlunoData copyWith(
          {int? id,
          int? aulaId,
          int? alunoId,
          double? valor,
          Value<DateTime?> createdAt = const Value.absent(),
          Value<DateTime?> updatedAt = const Value.absent()}) =>
      NotasAlunoData(
        id: id ?? this.id,
        aulaId: aulaId ?? this.aulaId,
        alunoId: alunoId ?? this.alunoId,
        valor: valor ?? this.valor,
        createdAt: createdAt.present ? createdAt.value : this.createdAt,
        updatedAt: updatedAt.present ? updatedAt.value : this.updatedAt,
      );
  NotasAlunoData copyWithCompanion(NotasAlunoCompanion data) {
    return NotasAlunoData(
      id: data.id.present ? data.id.value : this.id,
      aulaId: data.aulaId.present ? data.aulaId.value : this.aulaId,
      alunoId: data.alunoId.present ? data.alunoId.value : this.alunoId,
      valor: data.valor.present ? data.valor.value : this.valor,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('NotasAlunoData(')
          ..write('id: $id, ')
          ..write('aulaId: $aulaId, ')
          ..write('alunoId: $alunoId, ')
          ..write('valor: $valor, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode =>
      Object.hash(id, aulaId, alunoId, valor, createdAt, updatedAt);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is NotasAlunoData &&
          other.id == this.id &&
          other.aulaId == this.aulaId &&
          other.alunoId == this.alunoId &&
          other.valor == this.valor &&
          other.createdAt == this.createdAt &&
          other.updatedAt == this.updatedAt);
}

class NotasAlunoCompanion extends UpdateCompanion<NotasAlunoData> {
  final Value<int> id;
  final Value<int> aulaId;
  final Value<int> alunoId;
  final Value<double> valor;
  final Value<DateTime?> createdAt;
  final Value<DateTime?> updatedAt;
  const NotasAlunoCompanion({
    this.id = const Value.absent(),
    this.aulaId = const Value.absent(),
    this.alunoId = const Value.absent(),
    this.valor = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
  });
  NotasAlunoCompanion.insert({
    this.id = const Value.absent(),
    required int aulaId,
    required int alunoId,
    required double valor,
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
  })  : aulaId = Value(aulaId),
        alunoId = Value(alunoId),
        valor = Value(valor);
  static Insertable<NotasAlunoData> custom({
    Expression<int>? id,
    Expression<int>? aulaId,
    Expression<int>? alunoId,
    Expression<double>? valor,
    Expression<DateTime>? createdAt,
    Expression<DateTime>? updatedAt,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (aulaId != null) 'aula_id': aulaId,
      if (alunoId != null) 'aluno_id': alunoId,
      if (valor != null) 'valor': valor,
      if (createdAt != null) 'created_at': createdAt,
      if (updatedAt != null) 'updated_at': updatedAt,
    });
  }

  NotasAlunoCompanion copyWith(
      {Value<int>? id,
      Value<int>? aulaId,
      Value<int>? alunoId,
      Value<double>? valor,
      Value<DateTime?>? createdAt,
      Value<DateTime?>? updatedAt}) {
    return NotasAlunoCompanion(
      id: id ?? this.id,
      aulaId: aulaId ?? this.aulaId,
      alunoId: alunoId ?? this.alunoId,
      valor: valor ?? this.valor,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (aulaId.present) {
      map['aula_id'] = Variable<int>(aulaId.value);
    }
    if (alunoId.present) {
      map['aluno_id'] = Variable<int>(alunoId.value);
    }
    if (valor.present) {
      map['valor'] = Variable<double>(valor.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<DateTime>(updatedAt.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('NotasAlunoCompanion(')
          ..write('id: $id, ')
          ..write('aulaId: $aulaId, ')
          ..write('alunoId: $alunoId, ')
          ..write('valor: $valor, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt')
          ..write(')'))
        .toString();
  }
}

abstract class _$AppDatabase extends GeneratedDatabase {
  _$AppDatabase(QueryExecutor e) : super(e);
  $AppDatabaseManager get managers => $AppDatabaseManager(this);
  late final $TurmasTable turmas = $TurmasTable(this);
  late final $AulasTable aulas = $AulasTable(this);
  late final $NomesPadraoTable nomesPadrao = $NomesPadraoTable(this);
  late final $AlunosTable alunos = $AlunosTable(this);
  late final $PresencasTable presencas = $PresencasTable(this);
  late final $ConteudosAulaTable conteudosAula = $ConteudosAulaTable(this);
  late final $ObservacoesAulaTable observacoesAula =
      $ObservacoesAulaTable(this);
  late final $NotasAulaTable notasAula = $NotasAulaTable(this);
  late final $NotasAlunoTable notasAluno = $NotasAlunoTable(this);
  @override
  Iterable<TableInfo<Table, Object?>> get allTables =>
      allSchemaEntities.whereType<TableInfo<Table, Object?>>();
  @override
  List<DatabaseSchemaEntity> get allSchemaEntities => [
        turmas,
        aulas,
        nomesPadrao,
        alunos,
        presencas,
        conteudosAula,
        observacoesAula,
        notasAula,
        notasAluno
      ];
}

typedef $$TurmasTableCreateCompanionBuilder = TurmasCompanion Function({
  Value<int> id,
  required String nome,
  Value<String?> disciplina,
  required int anoLetivo,
  Value<bool> ativa,
  Value<bool> isDeleted,
  Value<DateTime?> createdAt,
  Value<DateTime?> updatedAt,
});
typedef $$TurmasTableUpdateCompanionBuilder = TurmasCompanion Function({
  Value<int> id,
  Value<String> nome,
  Value<String?> disciplina,
  Value<int> anoLetivo,
  Value<bool> ativa,
  Value<bool> isDeleted,
  Value<DateTime?> createdAt,
  Value<DateTime?> updatedAt,
});

final class $$TurmasTableReferences
    extends BaseReferences<_$AppDatabase, $TurmasTable, Turma> {
  $$TurmasTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static MultiTypedResultKey<$AlunosTable, List<Aluno>> _alunosRefsTable(
          _$AppDatabase db) =>
      MultiTypedResultKey.fromTable(db.alunos,
          aliasName: $_aliasNameGenerator(db.turmas.id, db.alunos.turmaId));

  $$AlunosTableProcessedTableManager get alunosRefs {
    final manager = $$AlunosTableTableManager($_db, $_db.alunos)
        .filter((f) => f.turmaId.id.sqlEquals($_itemColumn<int>('id')!));

    final cache = $_typedResult.readTableOrNull(_alunosRefsTable($_db));
    return ProcessedTableManager(
        manager.$state.copyWith(prefetchedData: cache));
  }
}

class $$TurmasTableFilterComposer
    extends Composer<_$AppDatabase, $TurmasTable> {
  $$TurmasTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get nome => $composableBuilder(
      column: $table.nome, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get disciplina => $composableBuilder(
      column: $table.disciplina, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get anoLetivo => $composableBuilder(
      column: $table.anoLetivo, builder: (column) => ColumnFilters(column));

  ColumnFilters<bool> get ativa => $composableBuilder(
      column: $table.ativa, builder: (column) => ColumnFilters(column));

  ColumnFilters<bool> get isDeleted => $composableBuilder(
      column: $table.isDeleted, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
      column: $table.createdAt, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get updatedAt => $composableBuilder(
      column: $table.updatedAt, builder: (column) => ColumnFilters(column));

  Expression<bool> alunosRefs(
      Expression<bool> Function($$AlunosTableFilterComposer f) f) {
    final $$AlunosTableFilterComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.id,
        referencedTable: $db.alunos,
        getReferencedColumn: (t) => t.turmaId,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$AlunosTableFilterComposer(
              $db: $db,
              $table: $db.alunos,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return f(composer);
  }
}

class $$TurmasTableOrderingComposer
    extends Composer<_$AppDatabase, $TurmasTable> {
  $$TurmasTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get nome => $composableBuilder(
      column: $table.nome, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get disciplina => $composableBuilder(
      column: $table.disciplina, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get anoLetivo => $composableBuilder(
      column: $table.anoLetivo, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<bool> get ativa => $composableBuilder(
      column: $table.ativa, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<bool> get isDeleted => $composableBuilder(
      column: $table.isDeleted, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
      column: $table.createdAt, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get updatedAt => $composableBuilder(
      column: $table.updatedAt, builder: (column) => ColumnOrderings(column));
}

class $$TurmasTableAnnotationComposer
    extends Composer<_$AppDatabase, $TurmasTable> {
  $$TurmasTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get nome =>
      $composableBuilder(column: $table.nome, builder: (column) => column);

  GeneratedColumn<String> get disciplina => $composableBuilder(
      column: $table.disciplina, builder: (column) => column);

  GeneratedColumn<int> get anoLetivo =>
      $composableBuilder(column: $table.anoLetivo, builder: (column) => column);

  GeneratedColumn<bool> get ativa =>
      $composableBuilder(column: $table.ativa, builder: (column) => column);

  GeneratedColumn<bool> get isDeleted =>
      $composableBuilder(column: $table.isDeleted, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<DateTime> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);

  Expression<T> alunosRefs<T extends Object>(
      Expression<T> Function($$AlunosTableAnnotationComposer a) f) {
    final $$AlunosTableAnnotationComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.id,
        referencedTable: $db.alunos,
        getReferencedColumn: (t) => t.turmaId,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$AlunosTableAnnotationComposer(
              $db: $db,
              $table: $db.alunos,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return f(composer);
  }
}

class $$TurmasTableTableManager extends RootTableManager<
    _$AppDatabase,
    $TurmasTable,
    Turma,
    $$TurmasTableFilterComposer,
    $$TurmasTableOrderingComposer,
    $$TurmasTableAnnotationComposer,
    $$TurmasTableCreateCompanionBuilder,
    $$TurmasTableUpdateCompanionBuilder,
    (Turma, $$TurmasTableReferences),
    Turma,
    PrefetchHooks Function({bool alunosRefs})> {
  $$TurmasTableTableManager(_$AppDatabase db, $TurmasTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$TurmasTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$TurmasTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$TurmasTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback: ({
            Value<int> id = const Value.absent(),
            Value<String> nome = const Value.absent(),
            Value<String?> disciplina = const Value.absent(),
            Value<int> anoLetivo = const Value.absent(),
            Value<bool> ativa = const Value.absent(),
            Value<bool> isDeleted = const Value.absent(),
            Value<DateTime?> createdAt = const Value.absent(),
            Value<DateTime?> updatedAt = const Value.absent(),
          }) =>
              TurmasCompanion(
            id: id,
            nome: nome,
            disciplina: disciplina,
            anoLetivo: anoLetivo,
            ativa: ativa,
            isDeleted: isDeleted,
            createdAt: createdAt,
            updatedAt: updatedAt,
          ),
          createCompanionCallback: ({
            Value<int> id = const Value.absent(),
            required String nome,
            Value<String?> disciplina = const Value.absent(),
            required int anoLetivo,
            Value<bool> ativa = const Value.absent(),
            Value<bool> isDeleted = const Value.absent(),
            Value<DateTime?> createdAt = const Value.absent(),
            Value<DateTime?> updatedAt = const Value.absent(),
          }) =>
              TurmasCompanion.insert(
            id: id,
            nome: nome,
            disciplina: disciplina,
            anoLetivo: anoLetivo,
            ativa: ativa,
            isDeleted: isDeleted,
            createdAt: createdAt,
            updatedAt: updatedAt,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) =>
                  (e.readTable(table), $$TurmasTableReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: ({alunosRefs = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [if (alunosRefs) db.alunos],
              addJoins: null,
              getPrefetchedDataCallback: (items) async {
                return [
                  if (alunosRefs)
                    await $_getPrefetchedData<Turma, $TurmasTable, Aluno>(
                        currentTable: table,
                        referencedTable:
                            $$TurmasTableReferences._alunosRefsTable(db),
                        managerFromTypedResult: (p0) =>
                            $$TurmasTableReferences(db, table, p0).alunosRefs,
                        referencedItemsForCurrentItem: (item,
                                referencedItems) =>
                            referencedItems.where((e) => e.turmaId == item.id),
                        typedResults: items)
                ];
              },
            );
          },
        ));
}

typedef $$TurmasTableProcessedTableManager = ProcessedTableManager<
    _$AppDatabase,
    $TurmasTable,
    Turma,
    $$TurmasTableFilterComposer,
    $$TurmasTableOrderingComposer,
    $$TurmasTableAnnotationComposer,
    $$TurmasTableCreateCompanionBuilder,
    $$TurmasTableUpdateCompanionBuilder,
    (Turma, $$TurmasTableReferences),
    Turma,
    PrefetchHooks Function({bool alunosRefs})>;
typedef $$AulasTableCreateCompanionBuilder = AulasCompanion Function({
  Value<int> id,
  required int turmaId,
  required String titulo,
  Value<String?> descricao,
  required DateTime data,
  Value<int> aulaTipo,
  Value<int?> duracaoMinutos,
  Value<DateTime?> createdAt,
  Value<DateTime?> updatedAt,
});
typedef $$AulasTableUpdateCompanionBuilder = AulasCompanion Function({
  Value<int> id,
  Value<int> turmaId,
  Value<String> titulo,
  Value<String?> descricao,
  Value<DateTime> data,
  Value<int> aulaTipo,
  Value<int?> duracaoMinutos,
  Value<DateTime?> createdAt,
  Value<DateTime?> updatedAt,
});

class $$AulasTableFilterComposer extends Composer<_$AppDatabase, $AulasTable> {
  $$AulasTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get turmaId => $composableBuilder(
      column: $table.turmaId, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get titulo => $composableBuilder(
      column: $table.titulo, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get descricao => $composableBuilder(
      column: $table.descricao, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get data => $composableBuilder(
      column: $table.data, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get aulaTipo => $composableBuilder(
      column: $table.aulaTipo, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get duracaoMinutos => $composableBuilder(
      column: $table.duracaoMinutos,
      builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
      column: $table.createdAt, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get updatedAt => $composableBuilder(
      column: $table.updatedAt, builder: (column) => ColumnFilters(column));
}

class $$AulasTableOrderingComposer
    extends Composer<_$AppDatabase, $AulasTable> {
  $$AulasTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get turmaId => $composableBuilder(
      column: $table.turmaId, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get titulo => $composableBuilder(
      column: $table.titulo, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get descricao => $composableBuilder(
      column: $table.descricao, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get data => $composableBuilder(
      column: $table.data, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get aulaTipo => $composableBuilder(
      column: $table.aulaTipo, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get duracaoMinutos => $composableBuilder(
      column: $table.duracaoMinutos,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
      column: $table.createdAt, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get updatedAt => $composableBuilder(
      column: $table.updatedAt, builder: (column) => ColumnOrderings(column));
}

class $$AulasTableAnnotationComposer
    extends Composer<_$AppDatabase, $AulasTable> {
  $$AulasTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<int> get turmaId =>
      $composableBuilder(column: $table.turmaId, builder: (column) => column);

  GeneratedColumn<String> get titulo =>
      $composableBuilder(column: $table.titulo, builder: (column) => column);

  GeneratedColumn<String> get descricao =>
      $composableBuilder(column: $table.descricao, builder: (column) => column);

  GeneratedColumn<DateTime> get data =>
      $composableBuilder(column: $table.data, builder: (column) => column);

  GeneratedColumn<int> get aulaTipo =>
      $composableBuilder(column: $table.aulaTipo, builder: (column) => column);

  GeneratedColumn<int> get duracaoMinutos => $composableBuilder(
      column: $table.duracaoMinutos, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<DateTime> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);
}

class $$AulasTableTableManager extends RootTableManager<
    _$AppDatabase,
    $AulasTable,
    Aula,
    $$AulasTableFilterComposer,
    $$AulasTableOrderingComposer,
    $$AulasTableAnnotationComposer,
    $$AulasTableCreateCompanionBuilder,
    $$AulasTableUpdateCompanionBuilder,
    (Aula, BaseReferences<_$AppDatabase, $AulasTable, Aula>),
    Aula,
    PrefetchHooks Function()> {
  $$AulasTableTableManager(_$AppDatabase db, $AulasTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$AulasTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$AulasTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$AulasTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback: ({
            Value<int> id = const Value.absent(),
            Value<int> turmaId = const Value.absent(),
            Value<String> titulo = const Value.absent(),
            Value<String?> descricao = const Value.absent(),
            Value<DateTime> data = const Value.absent(),
            Value<int> aulaTipo = const Value.absent(),
            Value<int?> duracaoMinutos = const Value.absent(),
            Value<DateTime?> createdAt = const Value.absent(),
            Value<DateTime?> updatedAt = const Value.absent(),
          }) =>
              AulasCompanion(
            id: id,
            turmaId: turmaId,
            titulo: titulo,
            descricao: descricao,
            data: data,
            aulaTipo: aulaTipo,
            duracaoMinutos: duracaoMinutos,
            createdAt: createdAt,
            updatedAt: updatedAt,
          ),
          createCompanionCallback: ({
            Value<int> id = const Value.absent(),
            required int turmaId,
            required String titulo,
            Value<String?> descricao = const Value.absent(),
            required DateTime data,
            Value<int> aulaTipo = const Value.absent(),
            Value<int?> duracaoMinutos = const Value.absent(),
            Value<DateTime?> createdAt = const Value.absent(),
            Value<DateTime?> updatedAt = const Value.absent(),
          }) =>
              AulasCompanion.insert(
            id: id,
            turmaId: turmaId,
            titulo: titulo,
            descricao: descricao,
            data: data,
            aulaTipo: aulaTipo,
            duracaoMinutos: duracaoMinutos,
            createdAt: createdAt,
            updatedAt: updatedAt,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ));
}

typedef $$AulasTableProcessedTableManager = ProcessedTableManager<
    _$AppDatabase,
    $AulasTable,
    Aula,
    $$AulasTableFilterComposer,
    $$AulasTableOrderingComposer,
    $$AulasTableAnnotationComposer,
    $$AulasTableCreateCompanionBuilder,
    $$AulasTableUpdateCompanionBuilder,
    (Aula, BaseReferences<_$AppDatabase, $AulasTable, Aula>),
    Aula,
    PrefetchHooks Function()>;
typedef $$NomesPadraoTableCreateCompanionBuilder = NomesPadraoCompanion
    Function({
  Value<int> id,
  required String valor,
  Value<int> ordem,
});
typedef $$NomesPadraoTableUpdateCompanionBuilder = NomesPadraoCompanion
    Function({
  Value<int> id,
  Value<String> valor,
  Value<int> ordem,
});

class $$NomesPadraoTableFilterComposer
    extends Composer<_$AppDatabase, $NomesPadraoTable> {
  $$NomesPadraoTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get valor => $composableBuilder(
      column: $table.valor, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get ordem => $composableBuilder(
      column: $table.ordem, builder: (column) => ColumnFilters(column));
}

class $$NomesPadraoTableOrderingComposer
    extends Composer<_$AppDatabase, $NomesPadraoTable> {
  $$NomesPadraoTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get valor => $composableBuilder(
      column: $table.valor, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get ordem => $composableBuilder(
      column: $table.ordem, builder: (column) => ColumnOrderings(column));
}

class $$NomesPadraoTableAnnotationComposer
    extends Composer<_$AppDatabase, $NomesPadraoTable> {
  $$NomesPadraoTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get valor =>
      $composableBuilder(column: $table.valor, builder: (column) => column);

  GeneratedColumn<int> get ordem =>
      $composableBuilder(column: $table.ordem, builder: (column) => column);
}

class $$NomesPadraoTableTableManager extends RootTableManager<
    _$AppDatabase,
    $NomesPadraoTable,
    NomesPadraoData,
    $$NomesPadraoTableFilterComposer,
    $$NomesPadraoTableOrderingComposer,
    $$NomesPadraoTableAnnotationComposer,
    $$NomesPadraoTableCreateCompanionBuilder,
    $$NomesPadraoTableUpdateCompanionBuilder,
    (
      NomesPadraoData,
      BaseReferences<_$AppDatabase, $NomesPadraoTable, NomesPadraoData>
    ),
    NomesPadraoData,
    PrefetchHooks Function()> {
  $$NomesPadraoTableTableManager(_$AppDatabase db, $NomesPadraoTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$NomesPadraoTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$NomesPadraoTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$NomesPadraoTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback: ({
            Value<int> id = const Value.absent(),
            Value<String> valor = const Value.absent(),
            Value<int> ordem = const Value.absent(),
          }) =>
              NomesPadraoCompanion(
            id: id,
            valor: valor,
            ordem: ordem,
          ),
          createCompanionCallback: ({
            Value<int> id = const Value.absent(),
            required String valor,
            Value<int> ordem = const Value.absent(),
          }) =>
              NomesPadraoCompanion.insert(
            id: id,
            valor: valor,
            ordem: ordem,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ));
}

typedef $$NomesPadraoTableProcessedTableManager = ProcessedTableManager<
    _$AppDatabase,
    $NomesPadraoTable,
    NomesPadraoData,
    $$NomesPadraoTableFilterComposer,
    $$NomesPadraoTableOrderingComposer,
    $$NomesPadraoTableAnnotationComposer,
    $$NomesPadraoTableCreateCompanionBuilder,
    $$NomesPadraoTableUpdateCompanionBuilder,
    (
      NomesPadraoData,
      BaseReferences<_$AppDatabase, $NomesPadraoTable, NomesPadraoData>
    ),
    NomesPadraoData,
    PrefetchHooks Function()>;
typedef $$AlunosTableCreateCompanionBuilder = AlunosCompanion Function({
  Value<int> id,
  required int turmaId,
  required String nome,
  Value<int?> numeroChamada,
  Value<bool> ativo,
  Value<DateTime?> createdAt,
  Value<DateTime?> updatedAt,
});
typedef $$AlunosTableUpdateCompanionBuilder = AlunosCompanion Function({
  Value<int> id,
  Value<int> turmaId,
  Value<String> nome,
  Value<int?> numeroChamada,
  Value<bool> ativo,
  Value<DateTime?> createdAt,
  Value<DateTime?> updatedAt,
});

final class $$AlunosTableReferences
    extends BaseReferences<_$AppDatabase, $AlunosTable, Aluno> {
  $$AlunosTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static $TurmasTable _turmaIdTable(_$AppDatabase db) => db.turmas
      .createAlias($_aliasNameGenerator(db.alunos.turmaId, db.turmas.id));

  $$TurmasTableProcessedTableManager get turmaId {
    final $_column = $_itemColumn<int>('turma_id')!;

    final manager = $$TurmasTableTableManager($_db, $_db.turmas)
        .filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_turmaIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
        manager.$state.copyWith(prefetchedData: [item]));
  }
}

class $$AlunosTableFilterComposer
    extends Composer<_$AppDatabase, $AlunosTable> {
  $$AlunosTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get nome => $composableBuilder(
      column: $table.nome, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get numeroChamada => $composableBuilder(
      column: $table.numeroChamada, builder: (column) => ColumnFilters(column));

  ColumnFilters<bool> get ativo => $composableBuilder(
      column: $table.ativo, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
      column: $table.createdAt, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get updatedAt => $composableBuilder(
      column: $table.updatedAt, builder: (column) => ColumnFilters(column));

  $$TurmasTableFilterComposer get turmaId {
    final $$TurmasTableFilterComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.turmaId,
        referencedTable: $db.turmas,
        getReferencedColumn: (t) => t.id,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$TurmasTableFilterComposer(
              $db: $db,
              $table: $db.turmas,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return composer;
  }
}

class $$AlunosTableOrderingComposer
    extends Composer<_$AppDatabase, $AlunosTable> {
  $$AlunosTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get nome => $composableBuilder(
      column: $table.nome, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get numeroChamada => $composableBuilder(
      column: $table.numeroChamada,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<bool> get ativo => $composableBuilder(
      column: $table.ativo, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
      column: $table.createdAt, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get updatedAt => $composableBuilder(
      column: $table.updatedAt, builder: (column) => ColumnOrderings(column));

  $$TurmasTableOrderingComposer get turmaId {
    final $$TurmasTableOrderingComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.turmaId,
        referencedTable: $db.turmas,
        getReferencedColumn: (t) => t.id,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$TurmasTableOrderingComposer(
              $db: $db,
              $table: $db.turmas,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return composer;
  }
}

class $$AlunosTableAnnotationComposer
    extends Composer<_$AppDatabase, $AlunosTable> {
  $$AlunosTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get nome =>
      $composableBuilder(column: $table.nome, builder: (column) => column);

  GeneratedColumn<int> get numeroChamada => $composableBuilder(
      column: $table.numeroChamada, builder: (column) => column);

  GeneratedColumn<bool> get ativo =>
      $composableBuilder(column: $table.ativo, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<DateTime> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);

  $$TurmasTableAnnotationComposer get turmaId {
    final $$TurmasTableAnnotationComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.turmaId,
        referencedTable: $db.turmas,
        getReferencedColumn: (t) => t.id,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$TurmasTableAnnotationComposer(
              $db: $db,
              $table: $db.turmas,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return composer;
  }
}

class $$AlunosTableTableManager extends RootTableManager<
    _$AppDatabase,
    $AlunosTable,
    Aluno,
    $$AlunosTableFilterComposer,
    $$AlunosTableOrderingComposer,
    $$AlunosTableAnnotationComposer,
    $$AlunosTableCreateCompanionBuilder,
    $$AlunosTableUpdateCompanionBuilder,
    (Aluno, $$AlunosTableReferences),
    Aluno,
    PrefetchHooks Function({bool turmaId})> {
  $$AlunosTableTableManager(_$AppDatabase db, $AlunosTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$AlunosTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$AlunosTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$AlunosTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback: ({
            Value<int> id = const Value.absent(),
            Value<int> turmaId = const Value.absent(),
            Value<String> nome = const Value.absent(),
            Value<int?> numeroChamada = const Value.absent(),
            Value<bool> ativo = const Value.absent(),
            Value<DateTime?> createdAt = const Value.absent(),
            Value<DateTime?> updatedAt = const Value.absent(),
          }) =>
              AlunosCompanion(
            id: id,
            turmaId: turmaId,
            nome: nome,
            numeroChamada: numeroChamada,
            ativo: ativo,
            createdAt: createdAt,
            updatedAt: updatedAt,
          ),
          createCompanionCallback: ({
            Value<int> id = const Value.absent(),
            required int turmaId,
            required String nome,
            Value<int?> numeroChamada = const Value.absent(),
            Value<bool> ativo = const Value.absent(),
            Value<DateTime?> createdAt = const Value.absent(),
            Value<DateTime?> updatedAt = const Value.absent(),
          }) =>
              AlunosCompanion.insert(
            id: id,
            turmaId: turmaId,
            nome: nome,
            numeroChamada: numeroChamada,
            ativo: ativo,
            createdAt: createdAt,
            updatedAt: updatedAt,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) =>
                  (e.readTable(table), $$AlunosTableReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: ({turmaId = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [],
              addJoins: <
                  T extends TableManagerState<
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic>>(state) {
                if (turmaId) {
                  state = state.withJoin(
                    currentTable: table,
                    currentColumn: table.turmaId,
                    referencedTable: $$AlunosTableReferences._turmaIdTable(db),
                    referencedColumn:
                        $$AlunosTableReferences._turmaIdTable(db).id,
                  ) as T;
                }

                return state;
              },
              getPrefetchedDataCallback: (items) async {
                return [];
              },
            );
          },
        ));
}

typedef $$AlunosTableProcessedTableManager = ProcessedTableManager<
    _$AppDatabase,
    $AlunosTable,
    Aluno,
    $$AlunosTableFilterComposer,
    $$AlunosTableOrderingComposer,
    $$AlunosTableAnnotationComposer,
    $$AlunosTableCreateCompanionBuilder,
    $$AlunosTableUpdateCompanionBuilder,
    (Aluno, $$AlunosTableReferences),
    Aluno,
    PrefetchHooks Function({bool turmaId})>;
typedef $$PresencasTableCreateCompanionBuilder = PresencasCompanion Function({
  Value<int> id,
  required int aulaId,
  required int alunoId,
  Value<int> aulaIndex,
  Value<bool> presente,
  Value<String?> justificativa,
  Value<DateTime?> createdAt,
  Value<DateTime?> updatedAt,
});
typedef $$PresencasTableUpdateCompanionBuilder = PresencasCompanion Function({
  Value<int> id,
  Value<int> aulaId,
  Value<int> alunoId,
  Value<int> aulaIndex,
  Value<bool> presente,
  Value<String?> justificativa,
  Value<DateTime?> createdAt,
  Value<DateTime?> updatedAt,
});

class $$PresencasTableFilterComposer
    extends Composer<_$AppDatabase, $PresencasTable> {
  $$PresencasTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get aulaId => $composableBuilder(
      column: $table.aulaId, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get alunoId => $composableBuilder(
      column: $table.alunoId, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get aulaIndex => $composableBuilder(
      column: $table.aulaIndex, builder: (column) => ColumnFilters(column));

  ColumnFilters<bool> get presente => $composableBuilder(
      column: $table.presente, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get justificativa => $composableBuilder(
      column: $table.justificativa, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
      column: $table.createdAt, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get updatedAt => $composableBuilder(
      column: $table.updatedAt, builder: (column) => ColumnFilters(column));
}

class $$PresencasTableOrderingComposer
    extends Composer<_$AppDatabase, $PresencasTable> {
  $$PresencasTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get aulaId => $composableBuilder(
      column: $table.aulaId, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get alunoId => $composableBuilder(
      column: $table.alunoId, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get aulaIndex => $composableBuilder(
      column: $table.aulaIndex, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<bool> get presente => $composableBuilder(
      column: $table.presente, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get justificativa => $composableBuilder(
      column: $table.justificativa,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
      column: $table.createdAt, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get updatedAt => $composableBuilder(
      column: $table.updatedAt, builder: (column) => ColumnOrderings(column));
}

class $$PresencasTableAnnotationComposer
    extends Composer<_$AppDatabase, $PresencasTable> {
  $$PresencasTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<int> get aulaId =>
      $composableBuilder(column: $table.aulaId, builder: (column) => column);

  GeneratedColumn<int> get alunoId =>
      $composableBuilder(column: $table.alunoId, builder: (column) => column);

  GeneratedColumn<int> get aulaIndex =>
      $composableBuilder(column: $table.aulaIndex, builder: (column) => column);

  GeneratedColumn<bool> get presente =>
      $composableBuilder(column: $table.presente, builder: (column) => column);

  GeneratedColumn<String> get justificativa => $composableBuilder(
      column: $table.justificativa, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<DateTime> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);
}

class $$PresencasTableTableManager extends RootTableManager<
    _$AppDatabase,
    $PresencasTable,
    Presenca,
    $$PresencasTableFilterComposer,
    $$PresencasTableOrderingComposer,
    $$PresencasTableAnnotationComposer,
    $$PresencasTableCreateCompanionBuilder,
    $$PresencasTableUpdateCompanionBuilder,
    (Presenca, BaseReferences<_$AppDatabase, $PresencasTable, Presenca>),
    Presenca,
    PrefetchHooks Function()> {
  $$PresencasTableTableManager(_$AppDatabase db, $PresencasTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$PresencasTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$PresencasTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$PresencasTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback: ({
            Value<int> id = const Value.absent(),
            Value<int> aulaId = const Value.absent(),
            Value<int> alunoId = const Value.absent(),
            Value<int> aulaIndex = const Value.absent(),
            Value<bool> presente = const Value.absent(),
            Value<String?> justificativa = const Value.absent(),
            Value<DateTime?> createdAt = const Value.absent(),
            Value<DateTime?> updatedAt = const Value.absent(),
          }) =>
              PresencasCompanion(
            id: id,
            aulaId: aulaId,
            alunoId: alunoId,
            aulaIndex: aulaIndex,
            presente: presente,
            justificativa: justificativa,
            createdAt: createdAt,
            updatedAt: updatedAt,
          ),
          createCompanionCallback: ({
            Value<int> id = const Value.absent(),
            required int aulaId,
            required int alunoId,
            Value<int> aulaIndex = const Value.absent(),
            Value<bool> presente = const Value.absent(),
            Value<String?> justificativa = const Value.absent(),
            Value<DateTime?> createdAt = const Value.absent(),
            Value<DateTime?> updatedAt = const Value.absent(),
          }) =>
              PresencasCompanion.insert(
            id: id,
            aulaId: aulaId,
            alunoId: alunoId,
            aulaIndex: aulaIndex,
            presente: presente,
            justificativa: justificativa,
            createdAt: createdAt,
            updatedAt: updatedAt,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ));
}

typedef $$PresencasTableProcessedTableManager = ProcessedTableManager<
    _$AppDatabase,
    $PresencasTable,
    Presenca,
    $$PresencasTableFilterComposer,
    $$PresencasTableOrderingComposer,
    $$PresencasTableAnnotationComposer,
    $$PresencasTableCreateCompanionBuilder,
    $$PresencasTableUpdateCompanionBuilder,
    (Presenca, BaseReferences<_$AppDatabase, $PresencasTable, Presenca>),
    Presenca,
    PrefetchHooks Function()>;
typedef $$ConteudosAulaTableCreateCompanionBuilder = ConteudosAulaCompanion
    Function({
  Value<int> id,
  required int aulaId,
  required String texto,
  Value<DateTime?> createdAt,
  Value<DateTime?> updatedAt,
});
typedef $$ConteudosAulaTableUpdateCompanionBuilder = ConteudosAulaCompanion
    Function({
  Value<int> id,
  Value<int> aulaId,
  Value<String> texto,
  Value<DateTime?> createdAt,
  Value<DateTime?> updatedAt,
});

class $$ConteudosAulaTableFilterComposer
    extends Composer<_$AppDatabase, $ConteudosAulaTable> {
  $$ConteudosAulaTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get aulaId => $composableBuilder(
      column: $table.aulaId, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get texto => $composableBuilder(
      column: $table.texto, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
      column: $table.createdAt, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get updatedAt => $composableBuilder(
      column: $table.updatedAt, builder: (column) => ColumnFilters(column));
}

class $$ConteudosAulaTableOrderingComposer
    extends Composer<_$AppDatabase, $ConteudosAulaTable> {
  $$ConteudosAulaTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get aulaId => $composableBuilder(
      column: $table.aulaId, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get texto => $composableBuilder(
      column: $table.texto, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
      column: $table.createdAt, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get updatedAt => $composableBuilder(
      column: $table.updatedAt, builder: (column) => ColumnOrderings(column));
}

class $$ConteudosAulaTableAnnotationComposer
    extends Composer<_$AppDatabase, $ConteudosAulaTable> {
  $$ConteudosAulaTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<int> get aulaId =>
      $composableBuilder(column: $table.aulaId, builder: (column) => column);

  GeneratedColumn<String> get texto =>
      $composableBuilder(column: $table.texto, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<DateTime> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);
}

class $$ConteudosAulaTableTableManager extends RootTableManager<
    _$AppDatabase,
    $ConteudosAulaTable,
    ConteudosAulaData,
    $$ConteudosAulaTableFilterComposer,
    $$ConteudosAulaTableOrderingComposer,
    $$ConteudosAulaTableAnnotationComposer,
    $$ConteudosAulaTableCreateCompanionBuilder,
    $$ConteudosAulaTableUpdateCompanionBuilder,
    (
      ConteudosAulaData,
      BaseReferences<_$AppDatabase, $ConteudosAulaTable, ConteudosAulaData>
    ),
    ConteudosAulaData,
    PrefetchHooks Function()> {
  $$ConteudosAulaTableTableManager(_$AppDatabase db, $ConteudosAulaTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$ConteudosAulaTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$ConteudosAulaTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$ConteudosAulaTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback: ({
            Value<int> id = const Value.absent(),
            Value<int> aulaId = const Value.absent(),
            Value<String> texto = const Value.absent(),
            Value<DateTime?> createdAt = const Value.absent(),
            Value<DateTime?> updatedAt = const Value.absent(),
          }) =>
              ConteudosAulaCompanion(
            id: id,
            aulaId: aulaId,
            texto: texto,
            createdAt: createdAt,
            updatedAt: updatedAt,
          ),
          createCompanionCallback: ({
            Value<int> id = const Value.absent(),
            required int aulaId,
            required String texto,
            Value<DateTime?> createdAt = const Value.absent(),
            Value<DateTime?> updatedAt = const Value.absent(),
          }) =>
              ConteudosAulaCompanion.insert(
            id: id,
            aulaId: aulaId,
            texto: texto,
            createdAt: createdAt,
            updatedAt: updatedAt,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ));
}

typedef $$ConteudosAulaTableProcessedTableManager = ProcessedTableManager<
    _$AppDatabase,
    $ConteudosAulaTable,
    ConteudosAulaData,
    $$ConteudosAulaTableFilterComposer,
    $$ConteudosAulaTableOrderingComposer,
    $$ConteudosAulaTableAnnotationComposer,
    $$ConteudosAulaTableCreateCompanionBuilder,
    $$ConteudosAulaTableUpdateCompanionBuilder,
    (
      ConteudosAulaData,
      BaseReferences<_$AppDatabase, $ConteudosAulaTable, ConteudosAulaData>
    ),
    ConteudosAulaData,
    PrefetchHooks Function()>;
typedef $$ObservacoesAulaTableCreateCompanionBuilder = ObservacoesAulaCompanion
    Function({
  Value<int> id,
  required int aulaId,
  required String texto,
  Value<DateTime?> createdAt,
  Value<DateTime?> updatedAt,
});
typedef $$ObservacoesAulaTableUpdateCompanionBuilder = ObservacoesAulaCompanion
    Function({
  Value<int> id,
  Value<int> aulaId,
  Value<String> texto,
  Value<DateTime?> createdAt,
  Value<DateTime?> updatedAt,
});

class $$ObservacoesAulaTableFilterComposer
    extends Composer<_$AppDatabase, $ObservacoesAulaTable> {
  $$ObservacoesAulaTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get aulaId => $composableBuilder(
      column: $table.aulaId, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get texto => $composableBuilder(
      column: $table.texto, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
      column: $table.createdAt, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get updatedAt => $composableBuilder(
      column: $table.updatedAt, builder: (column) => ColumnFilters(column));
}

class $$ObservacoesAulaTableOrderingComposer
    extends Composer<_$AppDatabase, $ObservacoesAulaTable> {
  $$ObservacoesAulaTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get aulaId => $composableBuilder(
      column: $table.aulaId, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get texto => $composableBuilder(
      column: $table.texto, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
      column: $table.createdAt, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get updatedAt => $composableBuilder(
      column: $table.updatedAt, builder: (column) => ColumnOrderings(column));
}

class $$ObservacoesAulaTableAnnotationComposer
    extends Composer<_$AppDatabase, $ObservacoesAulaTable> {
  $$ObservacoesAulaTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<int> get aulaId =>
      $composableBuilder(column: $table.aulaId, builder: (column) => column);

  GeneratedColumn<String> get texto =>
      $composableBuilder(column: $table.texto, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<DateTime> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);
}

class $$ObservacoesAulaTableTableManager extends RootTableManager<
    _$AppDatabase,
    $ObservacoesAulaTable,
    ObservacoesAulaData,
    $$ObservacoesAulaTableFilterComposer,
    $$ObservacoesAulaTableOrderingComposer,
    $$ObservacoesAulaTableAnnotationComposer,
    $$ObservacoesAulaTableCreateCompanionBuilder,
    $$ObservacoesAulaTableUpdateCompanionBuilder,
    (
      ObservacoesAulaData,
      BaseReferences<_$AppDatabase, $ObservacoesAulaTable, ObservacoesAulaData>
    ),
    ObservacoesAulaData,
    PrefetchHooks Function()> {
  $$ObservacoesAulaTableTableManager(
      _$AppDatabase db, $ObservacoesAulaTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$ObservacoesAulaTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$ObservacoesAulaTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$ObservacoesAulaTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback: ({
            Value<int> id = const Value.absent(),
            Value<int> aulaId = const Value.absent(),
            Value<String> texto = const Value.absent(),
            Value<DateTime?> createdAt = const Value.absent(),
            Value<DateTime?> updatedAt = const Value.absent(),
          }) =>
              ObservacoesAulaCompanion(
            id: id,
            aulaId: aulaId,
            texto: texto,
            createdAt: createdAt,
            updatedAt: updatedAt,
          ),
          createCompanionCallback: ({
            Value<int> id = const Value.absent(),
            required int aulaId,
            required String texto,
            Value<DateTime?> createdAt = const Value.absent(),
            Value<DateTime?> updatedAt = const Value.absent(),
          }) =>
              ObservacoesAulaCompanion.insert(
            id: id,
            aulaId: aulaId,
            texto: texto,
            createdAt: createdAt,
            updatedAt: updatedAt,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ));
}

typedef $$ObservacoesAulaTableProcessedTableManager = ProcessedTableManager<
    _$AppDatabase,
    $ObservacoesAulaTable,
    ObservacoesAulaData,
    $$ObservacoesAulaTableFilterComposer,
    $$ObservacoesAulaTableOrderingComposer,
    $$ObservacoesAulaTableAnnotationComposer,
    $$ObservacoesAulaTableCreateCompanionBuilder,
    $$ObservacoesAulaTableUpdateCompanionBuilder,
    (
      ObservacoesAulaData,
      BaseReferences<_$AppDatabase, $ObservacoesAulaTable, ObservacoesAulaData>
    ),
    ObservacoesAulaData,
    PrefetchHooks Function()>;
typedef $$NotasAulaTableCreateCompanionBuilder = NotasAulaCompanion Function({
  Value<int> id,
  required int aulaId,
  required String tipo,
  Value<double?> valorTotal,
  Value<DateTime?> createdAt,
  Value<DateTime?> updatedAt,
  Value<String?> titulo,
});
typedef $$NotasAulaTableUpdateCompanionBuilder = NotasAulaCompanion Function({
  Value<int> id,
  Value<int> aulaId,
  Value<String> tipo,
  Value<double?> valorTotal,
  Value<DateTime?> createdAt,
  Value<DateTime?> updatedAt,
  Value<String?> titulo,
});

class $$NotasAulaTableFilterComposer
    extends Composer<_$AppDatabase, $NotasAulaTable> {
  $$NotasAulaTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get aulaId => $composableBuilder(
      column: $table.aulaId, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get tipo => $composableBuilder(
      column: $table.tipo, builder: (column) => ColumnFilters(column));

  ColumnFilters<double> get valorTotal => $composableBuilder(
      column: $table.valorTotal, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
      column: $table.createdAt, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get updatedAt => $composableBuilder(
      column: $table.updatedAt, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get titulo => $composableBuilder(
      column: $table.titulo, builder: (column) => ColumnFilters(column));
}

class $$NotasAulaTableOrderingComposer
    extends Composer<_$AppDatabase, $NotasAulaTable> {
  $$NotasAulaTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get aulaId => $composableBuilder(
      column: $table.aulaId, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get tipo => $composableBuilder(
      column: $table.tipo, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<double> get valorTotal => $composableBuilder(
      column: $table.valorTotal, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
      column: $table.createdAt, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get updatedAt => $composableBuilder(
      column: $table.updatedAt, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get titulo => $composableBuilder(
      column: $table.titulo, builder: (column) => ColumnOrderings(column));
}

class $$NotasAulaTableAnnotationComposer
    extends Composer<_$AppDatabase, $NotasAulaTable> {
  $$NotasAulaTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<int> get aulaId =>
      $composableBuilder(column: $table.aulaId, builder: (column) => column);

  GeneratedColumn<String> get tipo =>
      $composableBuilder(column: $table.tipo, builder: (column) => column);

  GeneratedColumn<double> get valorTotal => $composableBuilder(
      column: $table.valorTotal, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<DateTime> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);

  GeneratedColumn<String> get titulo =>
      $composableBuilder(column: $table.titulo, builder: (column) => column);
}

class $$NotasAulaTableTableManager extends RootTableManager<
    _$AppDatabase,
    $NotasAulaTable,
    NotasAulaData,
    $$NotasAulaTableFilterComposer,
    $$NotasAulaTableOrderingComposer,
    $$NotasAulaTableAnnotationComposer,
    $$NotasAulaTableCreateCompanionBuilder,
    $$NotasAulaTableUpdateCompanionBuilder,
    (
      NotasAulaData,
      BaseReferences<_$AppDatabase, $NotasAulaTable, NotasAulaData>
    ),
    NotasAulaData,
    PrefetchHooks Function()> {
  $$NotasAulaTableTableManager(_$AppDatabase db, $NotasAulaTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$NotasAulaTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$NotasAulaTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$NotasAulaTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback: ({
            Value<int> id = const Value.absent(),
            Value<int> aulaId = const Value.absent(),
            Value<String> tipo = const Value.absent(),
            Value<double?> valorTotal = const Value.absent(),
            Value<DateTime?> createdAt = const Value.absent(),
            Value<DateTime?> updatedAt = const Value.absent(),
            Value<String?> titulo = const Value.absent(),
          }) =>
              NotasAulaCompanion(
            id: id,
            aulaId: aulaId,
            tipo: tipo,
            valorTotal: valorTotal,
            createdAt: createdAt,
            updatedAt: updatedAt,
            titulo: titulo,
          ),
          createCompanionCallback: ({
            Value<int> id = const Value.absent(),
            required int aulaId,
            required String tipo,
            Value<double?> valorTotal = const Value.absent(),
            Value<DateTime?> createdAt = const Value.absent(),
            Value<DateTime?> updatedAt = const Value.absent(),
            Value<String?> titulo = const Value.absent(),
          }) =>
              NotasAulaCompanion.insert(
            id: id,
            aulaId: aulaId,
            tipo: tipo,
            valorTotal: valorTotal,
            createdAt: createdAt,
            updatedAt: updatedAt,
            titulo: titulo,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ));
}

typedef $$NotasAulaTableProcessedTableManager = ProcessedTableManager<
    _$AppDatabase,
    $NotasAulaTable,
    NotasAulaData,
    $$NotasAulaTableFilterComposer,
    $$NotasAulaTableOrderingComposer,
    $$NotasAulaTableAnnotationComposer,
    $$NotasAulaTableCreateCompanionBuilder,
    $$NotasAulaTableUpdateCompanionBuilder,
    (
      NotasAulaData,
      BaseReferences<_$AppDatabase, $NotasAulaTable, NotasAulaData>
    ),
    NotasAulaData,
    PrefetchHooks Function()>;
typedef $$NotasAlunoTableCreateCompanionBuilder = NotasAlunoCompanion Function({
  Value<int> id,
  required int aulaId,
  required int alunoId,
  required double valor,
  Value<DateTime?> createdAt,
  Value<DateTime?> updatedAt,
});
typedef $$NotasAlunoTableUpdateCompanionBuilder = NotasAlunoCompanion Function({
  Value<int> id,
  Value<int> aulaId,
  Value<int> alunoId,
  Value<double> valor,
  Value<DateTime?> createdAt,
  Value<DateTime?> updatedAt,
});

class $$NotasAlunoTableFilterComposer
    extends Composer<_$AppDatabase, $NotasAlunoTable> {
  $$NotasAlunoTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get aulaId => $composableBuilder(
      column: $table.aulaId, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get alunoId => $composableBuilder(
      column: $table.alunoId, builder: (column) => ColumnFilters(column));

  ColumnFilters<double> get valor => $composableBuilder(
      column: $table.valor, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
      column: $table.createdAt, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get updatedAt => $composableBuilder(
      column: $table.updatedAt, builder: (column) => ColumnFilters(column));
}

class $$NotasAlunoTableOrderingComposer
    extends Composer<_$AppDatabase, $NotasAlunoTable> {
  $$NotasAlunoTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get aulaId => $composableBuilder(
      column: $table.aulaId, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get alunoId => $composableBuilder(
      column: $table.alunoId, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<double> get valor => $composableBuilder(
      column: $table.valor, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
      column: $table.createdAt, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get updatedAt => $composableBuilder(
      column: $table.updatedAt, builder: (column) => ColumnOrderings(column));
}

class $$NotasAlunoTableAnnotationComposer
    extends Composer<_$AppDatabase, $NotasAlunoTable> {
  $$NotasAlunoTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<int> get aulaId =>
      $composableBuilder(column: $table.aulaId, builder: (column) => column);

  GeneratedColumn<int> get alunoId =>
      $composableBuilder(column: $table.alunoId, builder: (column) => column);

  GeneratedColumn<double> get valor =>
      $composableBuilder(column: $table.valor, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<DateTime> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);
}

class $$NotasAlunoTableTableManager extends RootTableManager<
    _$AppDatabase,
    $NotasAlunoTable,
    NotasAlunoData,
    $$NotasAlunoTableFilterComposer,
    $$NotasAlunoTableOrderingComposer,
    $$NotasAlunoTableAnnotationComposer,
    $$NotasAlunoTableCreateCompanionBuilder,
    $$NotasAlunoTableUpdateCompanionBuilder,
    (
      NotasAlunoData,
      BaseReferences<_$AppDatabase, $NotasAlunoTable, NotasAlunoData>
    ),
    NotasAlunoData,
    PrefetchHooks Function()> {
  $$NotasAlunoTableTableManager(_$AppDatabase db, $NotasAlunoTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$NotasAlunoTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$NotasAlunoTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$NotasAlunoTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback: ({
            Value<int> id = const Value.absent(),
            Value<int> aulaId = const Value.absent(),
            Value<int> alunoId = const Value.absent(),
            Value<double> valor = const Value.absent(),
            Value<DateTime?> createdAt = const Value.absent(),
            Value<DateTime?> updatedAt = const Value.absent(),
          }) =>
              NotasAlunoCompanion(
            id: id,
            aulaId: aulaId,
            alunoId: alunoId,
            valor: valor,
            createdAt: createdAt,
            updatedAt: updatedAt,
          ),
          createCompanionCallback: ({
            Value<int> id = const Value.absent(),
            required int aulaId,
            required int alunoId,
            required double valor,
            Value<DateTime?> createdAt = const Value.absent(),
            Value<DateTime?> updatedAt = const Value.absent(),
          }) =>
              NotasAlunoCompanion.insert(
            id: id,
            aulaId: aulaId,
            alunoId: alunoId,
            valor: valor,
            createdAt: createdAt,
            updatedAt: updatedAt,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ));
}

typedef $$NotasAlunoTableProcessedTableManager = ProcessedTableManager<
    _$AppDatabase,
    $NotasAlunoTable,
    NotasAlunoData,
    $$NotasAlunoTableFilterComposer,
    $$NotasAlunoTableOrderingComposer,
    $$NotasAlunoTableAnnotationComposer,
    $$NotasAlunoTableCreateCompanionBuilder,
    $$NotasAlunoTableUpdateCompanionBuilder,
    (
      NotasAlunoData,
      BaseReferences<_$AppDatabase, $NotasAlunoTable, NotasAlunoData>
    ),
    NotasAlunoData,
    PrefetchHooks Function()>;

class $AppDatabaseManager {
  final _$AppDatabase _db;
  $AppDatabaseManager(this._db);
  $$TurmasTableTableManager get turmas =>
      $$TurmasTableTableManager(_db, _db.turmas);
  $$AulasTableTableManager get aulas =>
      $$AulasTableTableManager(_db, _db.aulas);
  $$NomesPadraoTableTableManager get nomesPadrao =>
      $$NomesPadraoTableTableManager(_db, _db.nomesPadrao);
  $$AlunosTableTableManager get alunos =>
      $$AlunosTableTableManager(_db, _db.alunos);
  $$PresencasTableTableManager get presencas =>
      $$PresencasTableTableManager(_db, _db.presencas);
  $$ConteudosAulaTableTableManager get conteudosAula =>
      $$ConteudosAulaTableTableManager(_db, _db.conteudosAula);
  $$ObservacoesAulaTableTableManager get observacoesAula =>
      $$ObservacoesAulaTableTableManager(_db, _db.observacoesAula);
  $$NotasAulaTableTableManager get notasAula =>
      $$NotasAulaTableTableManager(_db, _db.notasAula);
  $$NotasAlunoTableTableManager get notasAluno =>
      $$NotasAlunoTableTableManager(_db, _db.notasAluno);
}
