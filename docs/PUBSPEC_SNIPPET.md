Pubspec snippet recomendado — Educa+

Abaixo há um exemplo de dependências recomendadas para um app Flutter offline-first usando Drift (SQLite), Riverpod e ferramentas de geração (json_serializable / freezed).

Observação: não especifiquei versões concretas aqui — prefira usar `flutter pub add <package>` para obter a versão mais apropriada ao seu SDK, ou copie e ajuste as versões conforme sua política de dependências.

---
# Adicione ao seu `pubspec.yaml`

environment:
  sdk: "">=3.0.0 <4.0.0" # ajuste conforme seu SDK

dependencies:
  flutter:
    sdk: flutter
  cupertino_icons: ^1.0.2

  # State management
  flutter_riverpod: ^2.0.0

  # SQLite - Drift (recomendado para schema/migrations)
  drift: ^2.0.0
  # runtime para Flutter usando sqflite (alternativa leve)
  sqflite: ^2.0.0
  path_provider: ^2.0.0
  path: ^1.8.0

  # JSON (backup/export) and serialization helpers
  json_annotation: ^4.0.0

  # Optional: classes imutáveis e utilities
  freezed_annotation: ^2.0.0

  # Utilities
  intl: ^0.18.0 # opcional para formatação de datas

dev_dependencies:
  flutter_test:
    sdk: flutter

  # Code generation
  build_runner: ^2.4.0
  drift_dev: ^2.0.0      # para gerar código do Drift
  json_serializable: ^6.0.0
  freezed: ^2.0.0

  # Linting
  flutter_lints: ^2.0.0

---

Notas e passos de instalação

1) Instale dependências:

```bash
flutter pub get
```

2) Rodar o gerador (geral — Drift, json_serializable, freezed):

```bash
# executa geradores e remove outputs conflitantes
flutter pub run build_runner build --delete-conflicting-outputs
```

Algumas observações específicas sobre Drift

- Você pode usar o runtime `sqflite` (como mostrado) ou a biblioteca `sqlite3`/`drift_native` dependendo do alvo e preferências. Com `sqflite` o app fica compatível com iOS/Android sem necessidade de libs nativas adicionais.
- Para testes locais e CI você pode usar um DB em memória com Drift.

Alternativa minimalista (se quiser evitar geração de código)

- Substitua `drift` por `sqflite` e remova `drift_dev`, `build_runner`, `freezed` e `json_serializable` se preferir escrever mappers manuais. Isso reduz dependências, porém aumenta o boilerplate e a responsabilidade por migrações manuais.

Próximos passos sugeridos

- Quer que eu gere um `pubspec.yaml` completo (com versões fixas) no repositório? Posso também gerar um `main.dart` scaffold e um provider bootstrap usando Riverpod para você executar o app em branco rapidamente.
- Se preferir, posso gerar os contratos de domínio (interfaces) em `lib/domain/repositories` imediatamente.
