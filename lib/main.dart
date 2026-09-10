import 'package:flutter/material.dart';
import 'screens/landing_page.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Placeholder App',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        // 1. Core color scheme — generates a full palette from one seed color
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF2E7D6B), // pick any brand color
        ),
        useMaterial3: true,

        // 2. Text styles — reused via Theme.of(context).textTheme.___
        textTheme: const TextTheme(
          headlineMedium: TextStyle(
            fontSize: 28,
            fontWeight: FontWeight.bold,
          ),
          bodyLarge: TextStyle(
            fontSize: 16,
          ),
        ),

        // 3. Default button styling — applies to every OutlinedButton in the app
        outlinedButtonTheme: OutlinedButtonThemeData(
          style: OutlinedButton.styleFrom(
            padding: const EdgeInsets.symmetric(vertical: 16),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
          ),
        ),
      ),
      home: const LandingPage(),
    );
  }
}