-- Migration V1: Tabela inicial de turmas
CREATE TABLE IF NOT EXISTS turmas (
  id INTEGER PRIMARY KEY AUTOINCREMENT,
  nome TEXT NOT NULL,
  disciplina TEXT,
  ano_letivo INTEGER NOT NULL,
  ativa INTEGER NOT NULL DEFAULT 1,
  created_at TEXT,
  updated_at TEXT
);
