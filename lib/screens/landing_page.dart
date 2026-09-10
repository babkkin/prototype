import 'package:flutter/material.dart';
import 'manage_profiles.dart';
import 'medicine.dart';
import 'symptom.dart';

class LandingPage extends StatelessWidget {
  const LandingPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24.0),
          child: Center(
            child: ConstrainedBox(
              // Keeps content from stretching edge-to-edge on tablets/web
              constraints: const BoxConstraints(maxWidth: 400),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.stretch, // makes buttons full-width
                children: [
                  Text(
                    'Welcome to Placeholder!',
                    textAlign: TextAlign.center,
                    style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    'This is the landing page of the app.',
                    textAlign: TextAlign.center,
                    style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                          color: Colors.grey[600],
                        ),
                  ),
                  const SizedBox(height: 40),

                  OutlinedButton(
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                    ),
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => const ManageProfilesScreen()),
                      );
                    },
                    child: const Text('Manage Profiles'),
                  ),
                  const SizedBox(height: 12),

                  OutlinedButton(
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                    ),
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => const MedicineScreen()),
                      );
                    },
                    child: const Text('Medicines'),
                  ),
                  const SizedBox(height: 12),

                  OutlinedButton(
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                    ),
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => const SymptomsScreen()),
                      );
                    },
                    child: const Text('Symptoms'),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}