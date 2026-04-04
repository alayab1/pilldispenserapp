import 'package:flutter/material.dart';
import 'screens/home_screen.dart';

void main() {
  runApp(const PillApp());
}

class PillApp extends StatelessWidget {
  const PillApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'WALL-E Meds',
      debugShowCheckedModeBanner: false,
      theme: ThemeData.dark().copyWith(
        scaffoldBackgroundColor: const Color(0xFF1A1610),
        colorScheme: const ColorScheme.dark(
          primary: Color(0xFFE8A838),
          secondary: Color(0xFFE8A838),
        ),
      ),
      home: const HomeScreen(),
    );
  }
}