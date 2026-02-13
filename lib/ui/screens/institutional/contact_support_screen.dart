import 'dart:io' show Platform;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:educa_plus/app/feature_flags.dart';

class ContactSupportScreen extends StatefulWidget {
  const ContactSupportScreen({Key? key}) : super(key: key);

  @override
  State<ContactSupportScreen> createState() => _ContactSupportScreenState();
}

class _ContactSupportScreenState extends State<ContactSupportScreen> {
  final TextEditingController _contactController = TextEditingController();
  final TextEditingController _bugController = TextEditingController();

  @override
  void dispose() {
    _contactController.dispose();
    _bugController.dispose();
    super.dispose();
  }

  Widget _buildCard({required Widget leading, required String title, required Widget child}) {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      elevation: 1,
      margin: const EdgeInsets.symmetric(vertical: 6),
      child: Padding(
        padding: const EdgeInsets.all(14.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                leading,
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    title,
                    style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            child,
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      appBar: AppBar(
        title: const Text('Contato e suporte'),
      ),
      body: GestureDetector(
        behavior: HitTestBehavior.translucent,
        onTap: () => FocusScope.of(context).unfocus(),
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Support / Donation card (top)
              // Hidden in the MVP. The UI remains in source for future
              // reactivation (e.g. Plano VIP). Controlled by a centralized
              // feature flag so the code can be restored without surgery.
              if (isDonationEnabled) _buildCard(
                leading: CircleAvatar(
                  radius: 20,
                  backgroundColor: theme.colorScheme.primary.withOpacity(0.12),
                  child: Icon(Icons.volunteer_activism, color: theme.colorScheme.primary, size: 22),
                ),
                title: 'Apoiar o projeto',
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'O Diário do Professor Offline é um projeto independente.\nSe ele te ajuda no dia a dia, considere apoiar o desenvolvimento.',
                      style: TextStyle(fontSize: 14),
                    ),
                    const SizedBox(height: 10),
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: theme.colorScheme.primary.withOpacity(0.06),
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(color: theme.colorScheme.primary.withOpacity(0.10)),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          const Icon(Icons.qr_code, size: 44),
                          const SizedBox(height: 6),
                          const Text('Doação via PIX', style: TextStyle(fontSize: 17, fontWeight: FontWeight.w700)),
                          const SizedBox(height: 10),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              SelectableText(
                                'ensinajaapp@gmail.com',
                                style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
                              ),
                              const SizedBox(width: 8),
                              IconButton(
                                padding: EdgeInsets.zero,
                                constraints: const BoxConstraints(minWidth: 32, minHeight: 32),
                                icon: const Icon(Icons.content_copy, size: 18),
                                tooltip: 'Copiar chave PIX',
                                onPressed: () async {
                                  const pixKey = 'ensinajaapp@gmail.com';
                                  await Clipboard.setData(const ClipboardData(text: pixKey));
                                  if (!mounted) return;
                                  ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                                    content: Text('Chave PIX copiada para a área de transferência.'),
                                  ));
                                },
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              // Contact card (middle)
              _buildCard(
                leading: CircleAvatar(
                  backgroundColor: theme.colorScheme.primary.withOpacity(0.12),
                  child: Icon(Icons.email_outlined, color: theme.colorScheme.primary),
                ),
                title: 'Fale com a gente',
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Envie sugestões, dúvidas ou feedback sobre o Diário do Professor Offline.',
                      style: TextStyle(fontSize: 14),
                    ),
                    const SizedBox(height: 8),
                    TextField(
                      controller: _contactController,
                      minLines: 2,
                      maxLines: 4,
                      decoration: const InputDecoration(
                        hintText: 'Escreva sua mensagem aqui…',
                        border: OutlineInputBorder(),
                        contentPadding: EdgeInsets.symmetric(vertical: 10, horizontal: 12),
                      ),
                    ),
                    const SizedBox(height: 8),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: () async {
                          final text = _contactController.text.trim();
                          if (text.isEmpty) {
                            ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                              content: Text('Escreva uma mensagem antes de enviar.'),
                            ));
                            return;
                          }

                          final platform = Platform.isIOS ? 'iOS' : 'Android';
                          final subject = 'Diário do Professor Offline — Contato';
                          final body = StringBuffer();
                          body.writeln('Mensagem:');
                          body.writeln(text);
                          body.writeln();
                          body.writeln('------------------------');
                          body.writeln('App: Diário do Professor Offline');
                          body.writeln('Plataforma: $platform');
                          body.writeln('Versão do app: não disponível');

                          final uri = Uri(
                            scheme: 'mailto',
                            path: 'ensinajaapp@gmail.com',
                            queryParameters: {
                              'subject': subject,
                              'body': body.toString(),
                            },
                          );

                          final launched = await launchUrl(uri, mode: LaunchMode.externalApplication);
                          if (!launched) {
                            if (!mounted) return;
                            ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                              content: Text('Não foi possível abrir o aplicativo de e-mail.'),
                            ));
                          } else {
                            if (!mounted) return;
                            _contactController.clear();
                          }
                        },
                        child: const Text('Enviar mensagem'),
                      ),
                    ),
                  ],
                ),
              ),

              // Report problem card (last)
              _buildCard(
                leading: CircleAvatar(
                  backgroundColor: theme.colorScheme.primary.withOpacity(0.12),
                  child: Icon(Icons.bug_report_outlined, color: theme.colorScheme.primary),
                ),
                title: 'Reportar problema',
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Encontrou algum erro ou algo que não funcionou como esperado?',
                      style: TextStyle(fontSize: 14),
                    ),
                    const SizedBox(height: 8),
                    TextField(
                      controller: _bugController,
                      minLines: 2,
                      maxLines: 4,
                      decoration: const InputDecoration(
                        hintText: 'Descreva o problema…',
                        border: OutlineInputBorder(),
                        contentPadding: EdgeInsets.symmetric(vertical: 10, horizontal: 12),
                      ),
                    ),
                    const SizedBox(height: 8),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: () async {
                          final text = _bugController.text.trim();
                          if (text.isEmpty) {
                            ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                              content: Text('Descreva o problema antes de enviar.'),
                            ));
                            return;
                          }

                          final platform = Platform.isIOS ? 'iOS' : 'Android';
                          final subject = 'Diário do Professor Offline — Bug report';
                          final body = StringBuffer();
                          body.writeln('Descrição do problema:');
                          body.writeln(text);
                          body.writeln();
                          body.writeln('------------------------');
                          body.writeln('App: Diário do Professor Offline');
                          body.writeln('Plataforma: $platform');
                          body.writeln('Versão do app: não disponível');
                          body.writeln('Passos para reproduzir:');

                          final uri = Uri(
                            scheme: 'mailto',
                            path: 'ensinajaapp@gmail.com',
                            queryParameters: {
                              'subject': subject,
                              'body': body.toString(),
                            },
                          );

                          final launched = await launchUrl(uri, mode: LaunchMode.externalApplication);
                          if (!launched) {
                            if (!mounted) return;
                            ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                              content: Text('Não foi possível abrir o aplicativo de e-mail.'),
                            ));
                          } else {
                            if (!mounted) return;
                            _bugController.clear();
                          }
                        },
                        child: const Text('Reportar'),
                      ),
                    ),
                  ],
                ),
              ),

              if (isDonationEnabled) ...[
                const SizedBox(height: 24),
                Center(
                  child: Text(
                    'Obrigado por apoiar o Diário do Professor Offline — sua contribuição ajuda a manter o projeto vivo.',
                    textAlign: TextAlign.center,
                    style: TextStyle(color: theme.colorScheme.onBackground.withOpacity(0.7)),
                  ),
                ),
                const SizedBox(height: 24),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
