import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'conteudo_screen.dart';
import 'notas_screen.dart';
import 'observacoes_screen.dart';
import '../../widgets/aula_date_badge.dart';
import 'package:educa_plus/providers/aula_provider.dart';
import 'package:educa_plus/app/providers.dart' show aulaRepositoryProvider;
import 'package:educa_plus/domain/entities/aula.dart' as domain;


class AulaHubScreen extends ConsumerWidget {
  final int turmaId;
  final int aulaId;
  final String aulaTitle;

  // Used for screens that need the same subtitle as the Aulas screen.
  final String turmaName;

  /// 1 = aula individual (uma aba), 2 = aula dupla (duas abas).
  final int tipoPresenca;

  const AulaHubScreen({
    super.key,
    required this.turmaId,
    required this.aulaId,
    required this.aulaTitle,
    required this.turmaName,
    this.tipoPresenca = 1,
  });

  String _cleanTurmaDisplayName(String turmaName) {
    final name = turmaName.trim();
    if (name.isEmpty) return '';

    // Keep the same behavior as ListLessonsScreen.
    const seps = [' - ', ' — ', ' | ', ' • ', ' / '];
    for (final sep in seps) {
      final idx = name.indexOf(sep);
      if (idx > 0 && idx + sep.length < name.length) {
        return name.substring(idx + sep.length).trim();
      }
    }
    return name;
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final turmaDisplayName = _cleanTurmaDisplayName(turmaName);
  final aulaAsync = ref.watch(aulaProvider(aulaId));

    final tipoPresencaFromDb = aulaAsync.maybeWhen(
      data: (a) =>
          ((a?.tipo ?? domain.AulaTipo.individual) == domain.AulaTipo.dupla)
              ? 2
              : 1,
      orElse: () => 1,
    );

    return Scaffold(
      appBar: AppBar(
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 12),
            child: aulaAsync.maybeWhen(
              data: (a) => a != null ? AulaDateBadge(date: a.data) : const SizedBox.shrink(),
              orElse: () => const SizedBox.shrink(),
            ),
          ),
        ],
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              aulaTitle,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              textAlign: TextAlign.center,
            ),
            Transform.scale(
              scale: 0.8694,
              alignment: Alignment.center,
              child: Text(
                turmaDisplayName.isNotEmpty ? turmaDisplayName : ' ',
                textAlign: TextAlign.center,
              ),
            ),
          ],
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: GridView.count(
          crossAxisCount: 2,
          mainAxisSpacing: 14,
          crossAxisSpacing: 14,
          childAspectRatio: 1.05,
          children: [
            _AulaHubActionCard(
              icon: Icons.how_to_reg,
              title: 'Presença',
              onTap: () {
                final turmaNome = Uri.encodeComponent(turmaName);
                () async {
                  final result = await context.push<bool>(
                    '/turmas/$turmaId/aulas/$aulaId/presenca?turmaNome=$turmaNome&tipo=$tipoPresencaFromDb',
                  );

                  // If Presença was saved, refresh this screen's state if needed.
                  // AulaHubScreen is Stateless today, so there's nothing to reload
                  // here, but we keep the contract for future data (export/status).
                  if (result == true && context.mounted) {
                    // no-op
                  }
                }();
              },
            ),
            _AulaHubActionCard(
              icon: Icons.menu_book_outlined,
              title: 'Conteúdo',
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => ConteudoScreen(
                      aulaId: aulaId,
                      turmaId: turmaId,
                      subtitle:
                          turmaDisplayName.isNotEmpty ? turmaDisplayName : null,
                    ),
                  ),
                );
              },
            ),
            _AulaHubActionCard(
              icon: Icons.star_outline,
              title: 'Notas',
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => NotasScreen(
                      aulaId: aulaId,
                      turmaId: turmaId,
                      subtitle:
                          turmaDisplayName.isNotEmpty ? turmaDisplayName : null,
                    ),
                  ),
                );
              },
            ),
            _AulaHubActionCard(
              icon: Icons.notes_outlined,
              title: 'Observações',
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => ObservacoesScreen(
                      aulaId: aulaId,
                      turmaId: turmaId,
                      subtitle:
                          turmaDisplayName.isNotEmpty ? turmaDisplayName : null,
                    ),
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}

class _AulaHubActionCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final VoidCallback? onTap;

  const _AulaHubActionCard({
    required this.icon,
    required this.title,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(16),
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: cs.primary.withOpacity(0.14)),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.04),
                blurRadius: 14,
                offset: const Offset(0, 7),
              )
            ],
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, size: 46, color: cs.primary),
              const SizedBox(height: 12),
              Text(
                title,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  color: cs.onSurface,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
