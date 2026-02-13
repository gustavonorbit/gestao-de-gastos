Escolha de bibliotecas — resumo e recomendação

Requisitos principais: simplicidade, estabilidade, offline-first, sem backend obrigatório.

Opções para SQLite:
- drift (recomendado):
  - Prós: schema tipado, geração de código, migrações integradas, suporte a DB em memória (bom para testes), consultas seguras, API de transações.
  - Contras: adiciona geração de código e dependências de build_runner; curva inicial leve.
- sqflite:
  - Prós: leve, sem geração de código, muito usado e estável.
  - Contras: migrações e mapeamento manual (mais boilerplate), menos verificação em tempo de compilação.

State management:
- Riverpod (recomendado): testável, simples, desacoplado de BuildContext; ótimo para apps offline-first simples.

Outras utilidades recomendadas:
- json_serializable + build_runner: para serialização de DTOs/backup JSON.
- freezed (opcional): para gerar classes imutáveis e copyWith em entidades de domínio (ajuda com testabilidade).
- path_provider: para localizar diretórios de backup e exportação.
- intl (opcional): formatação de datas e localidade.

Recomendação final:
- Usar drift + Riverpod + json_serializable.
- Motivo: drift facilita migrações e segurança do schema (importante para bases locais que serão mantidas por anos) e Riverpod mantém o estado simples e testável.

Se você prioriza dependências mínimas e quer evitar geração de código, escolher sqflite é aceitável — mas compensará com mais código manual para mappers e migrações.

Próximo passo: se concordar com drift + Riverpod, eu preparo o arquivo de dependências (pubspec.yaml snippet) e o scaffold inicial do projeto Flutter.