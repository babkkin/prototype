import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'data/app_database.dart';
import 'screens/landing_page.dart';

void main() {
  final database = AppDatabase();

  runApp(
    // Provider makes the database available to any screen below this
    // point in the widget tree via context.watch<AppDatabase>() or
    // context.read<AppDatabase>() — that's how ManageProfilesScreen
    // gets access to it without it being passed in manually.
    Provider<AppDatabase>(
      create: (_) => database,
      dispose: (_, db) => db.close(),
      child: const MyApp(),
    ),
  );
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