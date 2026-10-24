import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'ui/theme.dart';
import 'screens/home_screen.dart';

void main() {
  runApp(const ProviderScope(child: GymApp()));
}

class GymApp extends StatelessWidget {
  const GymApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Gym Tracker',
      theme: buildTheme(),
      home: const HomeScreen(),
    );
  }
}
