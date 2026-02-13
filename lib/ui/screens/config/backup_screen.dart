import 'package:flutter/material.dart';

// NOTE:
// This screen is kept in the codebase for future reactivation (Plano VIP).
// The UI is intentionally hidden behind a centralized feature flag
// (`lib/app/feature_flags.dart`) so it does not appear to end users in the
// MVP. Do NOT remove this file or the related services — simply toggle the
// flag when the product team decides to enable the feature.

class BackupScreen extends StatelessWidget {
  const BackupScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Backup')),
      // The screen remains available internally but the route and its menu
      // entry are hidden by default. Keep the body minimal to avoid user-facing
      // placeholder text if it is accidentally navigated to during development.
      body: const Center(child: Text('')),
    );
  }
}
