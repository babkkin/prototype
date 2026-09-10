import 'package:flutter/material.dart';

class SymptomsScreen extends StatelessWidget {
  const SymptomsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Symptoms'),
      ),
      body: const Center(
        child: Text('Symptoms Content'),
      ),
    );
  }
}