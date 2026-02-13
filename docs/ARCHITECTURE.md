Educa+ — Arquitetura (resumo)

Camadas:
- UI: telas simples, widgets reutilizáveis, navegação direta. Salvar sempre no repositório (não em UI).
- Domínio: entidades puras (Turma, Aluno, Aula, Presenca, Nota, Configuracao), contratos de repositório (interfaces) e casos de uso (use-cases).
- Dados: implementação dos repositórios, models de persistência, mappers, database singleton e migrações.

Princípios:
- Offline-first: todas operações funcionam sem rede; dados locais em SQLite.
- Soft-delete: "ativo" ao invés de exclusão física.
- Simplicidade: interfaces pequenas e previsíveis.
- Resiliência: uso de transações para operações multi-entity.

Estrutura de pastas (detalhada):
- lib/app: inicialização e injeção de providers
- lib/core: utilitários e erros compartilhados
- lib/data: database, datasources/local, models, repositories, migrations
- lib/domain: entities, repositories (interfaces), usecases
- lib/ui: screens/{home,classes,students,lessons,attendance,grades,settings}, widgets, styles
- lib/services: backup, import/export JSON, CSV helpers
- lib/providers: Riverpod providers e StateNotifiers

Modelagem (resumo):
- Turma(id, nome, disciplina, ano_letivo, ativa, created_at, updated_at)
- Aluno(id, nome, numero_chamada, turma_id, ativo, created_at, updated_at)
- Aula(id, turma_id, data, conteudo, observacoes, created_at)
- Presenca(id, aula_id, aluno_id, presente, justificativa, created_at)
- Nota(id, aluno_id, aula_id, valor, tipo, created_at)
- Config(chave, valor)

Migrações: arquivos incremental em lib/data/migrations; manter schema_version e criar backup automático antes de aplicar migração.

Backup/Restore: exportar para JSON com versão do schema; import com checagem de compatibilidade e opções de merge/substituir.