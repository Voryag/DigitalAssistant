import 'package:flutter/material.dart';
import 'screens/login_screen.dart';

void main() {
  runApp(const DigitalAssistantApp());
}

class DigitalAssistantApp extends StatelessWidget {
  const DigitalAssistantApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Цифровой Ассистент',
      theme: ThemeData(
        brightness: Brightness.dark,
        scaffoldBackgroundColor: const Color(0xFF0D1B2A),
        colorScheme: const ColorScheme.dark(
          primary: Color(0xFF1B6EF3),
          secondary: Color(0xFF415A77),
          surface: Color(0xFF1B2838),
          onSurface: Colors.white,
        ),
        appBarTheme: const AppBarTheme(
          backgroundColor: Color(0xFF0A1628),
          elevation: 0,
        ),
        cardTheme: const CardThemeData(
          color: Color(0xFF1B2838),
          elevation: 4,
        ),
        chipTheme: const ChipThemeData(
          backgroundColor: Color(0xFF1B6EF3),
          labelStyle: TextStyle(color: Colors.white),
        ),
        useMaterial3: true,
      ),
      home: const LoginScreen(),
      debugShowCheckedModeBanner: false,
    );
  }
}