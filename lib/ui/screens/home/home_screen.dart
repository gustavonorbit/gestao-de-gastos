import 'package:flutter/material.dart';
import 'package:educa_plus/ui/screens/classes/list_classes_screen.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // Home now shows the Turmas list directly so the app opens into the main content
    return const ListClassesScreen();
  }
}
