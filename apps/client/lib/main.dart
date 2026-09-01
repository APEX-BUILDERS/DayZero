import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'features/workspace/workspace_generator_screen.dart';

void main() {
  runApp(const ProviderScope(child: DayZeroApp()));
}

class DayZeroApp extends StatelessWidget {
  const DayZeroApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'DayZero',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF216869),
          primary: const Color(0xFF216869),
          secondary: const Color(0xFFE0A458),
          tertiary: const Color(0xFF4B7F52),
          surface: const Color(0xFFF8FAF9),
        ),
        scaffoldBackgroundColor: const Color(0xFFF8FAF9),
        useMaterial3: true,
      ),
      home: const WorkspaceGeneratorScreen(),
    );
  }
}
