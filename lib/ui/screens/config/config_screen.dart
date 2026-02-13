import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:educa_plus/app/feature_flags.dart';

class ConfigScreen extends StatelessWidget {
  const ConfigScreen({super.key});

  Widget _buildConfigCard({
    required BuildContext context,
    required IconData icon,
    required String title,
    required String subtitle,
    required String route,
  }) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final borderRadius = BorderRadius.circular(14.0);

    return Material(
      color: colorScheme.surfaceVariant,
      elevation: 1,
      borderRadius: borderRadius,
      child: InkWell(
        borderRadius: borderRadius,
        onTap: () => context.push(route),
        child: Container(
          constraints: const BoxConstraints(minHeight: 72),
          padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 16),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Container(
                width: 56,
                height: 56,
                decoration: BoxDecoration(
                  color: colorScheme.primary.withOpacity(0.10),
                  shape: BoxShape.circle,
                ),
                child: Center(
                  child: Icon(icon,
                      size: 30, color: colorScheme.primary),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      title,
                      style: theme.textTheme.bodyLarge?.copyWith(
                        fontSize: 17,
                        fontWeight: FontWeight.w700,
                        color: colorScheme.onSurface,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      subtitle,
                      style: theme.textTheme.bodyMedium?.copyWith(
                        fontSize: 13.5,
                        color: colorScheme.onSurface.withOpacity(0.75),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 12),
              Icon(Icons.chevron_right, color: colorScheme.primary),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      appBar: AppBar(title: const Text('Configurações')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: ListView(
          children: [
            _buildConfigCard(
              context: context,
              icon: Icons.accessibility_new,
              title: 'Acessibilidade',
              subtitle: 'Ajustes de visual e usabilidade',
              route: '/configuracoes/acessibilidade',
            ),
            const SizedBox(height: 14),
            _buildConfigCard(
              context: context,
              icon: Icons.restore_from_trash,
              title: 'Lixeira',
              subtitle: 'Turmas removidas do sistema',
              route: '/configuracoes/lixeira',
            ),
            const SizedBox(height: 14),
            if (isBackupEnabled) ...[
              _buildConfigCard(
                context: context,
                icon: Icons.cloud_upload_outlined,
                title: 'Backup',
                subtitle: 'Segurança e recuperação de dados',
                route: '/configuracoes/backup',
              ),
              const SizedBox(height: 14),
            ],
            const SizedBox(height: 8),
            // small footer spacing to make the list look airy on small devices
            SizedBox(height: theme.visualDensity.vertical * 8 + 8),
          ],
        ),
      ),
    );
  }
}
