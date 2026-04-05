import 'package:flutter/material.dart';
import 'screens/login_screen.dart';
import 'services/bluetooth_service.dart';

void main() {
  runApp(const PillApp());
}

class PillApp extends StatefulWidget {
  const PillApp({super.key});

  @override
  State<PillApp> createState() => _PillAppState();
}

class _PillAppState extends State<PillApp> {
  final BluetoothService _btService = BluetoothService();

  @override
  void dispose() {
    _btService.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'WALL-E Meds',
      debugShowCheckedModeBanner: false,
      theme: ThemeData.dark().copyWith(
        scaffoldBackgroundColor: const Color(0xFF2B2B2B),
        colorScheme: const ColorScheme.dark(
          primary: Color(0xFFE8A838),
          secondary: Color(0xFFE8A838),
        ),
      ),
      home: LoginScreen(btService: _btService),
    );
  }
}